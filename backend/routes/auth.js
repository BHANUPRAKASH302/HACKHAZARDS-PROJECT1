const express = require('express');
const jwt = require('jsonwebtoken');
const { authenticator } = require('otplib');
const qrcode = require('qrcode');
const { OAuth2Client } = require('google-auth-library');
const mongoose = require('mongoose');
const crypto = require('crypto');
const dotenv = require('dotenv');

dotenv.config();

const router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const USER_DB_NAME = process.env.USER_DB_NAME || 'User_Data';
const TOKEN_TTL = process.env.JWT_EXPIRES_IN || '24h';
const JWT_SECRET = process.env.JWT_SECRET || 'change-this-development-secret';
const PASSWORD_ITERATIONS = 210000;
const PASSWORD_KEY_LENGTH = 64;
const PASSWORD_DIGEST = 'sha512';
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// ----------------------------------------------------
// User Schema & Model (MongoDB: User_Data.Users)
// ----------------------------------------------------
const profileHistorySchema = new mongoose.Schema({
  changedAt: { type: Date, default: Date.now },
  fields: [{ type: String }],
}, { _id: false });

const userSchema = new mongoose.Schema({
  fullName: { type: String, trim: true },
  name: { type: String, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true, index: true },
  password: { type: String, select: false },
  googleId: { type: String, sparse: true, index: true },
  profileImage: { type: String },
  bio: { type: String, default: '' },
  phoneNumber: { type: String, default: '' },
  preferences: { type: mongoose.Schema.Types.Mixed, default: {} },
  firstName: { type: String, default: '' },
  lastName: { type: String, default: '' },
  role: { type: String, default: '' },
  location: { type: String, default: '' },
  instagram: { type: String, default: '' },
  linkedin: { type: String, default: '' },
  github: { type: String, default: '' },
  x: { type: String, default: '' },
  telegram: { type: String, default: '' },
  loginMethod: { type: String, enum: ['email', 'google', 'email_google'], default: 'email' },
  loginProvider: { type: String, default: 'email' },
  mfaEnabled: { type: Boolean, default: false },
  mfaSecret: { type: String, select: false },
  tempMfaSecret: { type: String, select: false },
  passwordResetTokenHash: { type: String, select: false },
  passwordResetExpires: { type: Date, select: false },
  profileUpdateHistory: { type: [profileHistorySchema], default: [] },
  sessionVersion: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  lastLoginAt: { type: Date },
}, {
  collection: 'Users',
  timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' },
});

const userDb = mongoose.connection.useDb(USER_DB_NAME, { useCache: true });
const User = userDb.models.User || userDb.model('User', userSchema);

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function normalizeText(value, maxLength = 500) {
  return String(value || '').trim().slice(0, maxLength);
}

function validateEmail(email) {
  return EMAIL_REGEX.test(email);
}

function validatePassword(password) {
  if (typeof password !== 'string' || password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  if (!/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    return 'Password must include at least one letter and one number.';
  }
  return null;
}

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto
    .pbkdf2Sync(password, salt, PASSWORD_ITERATIONS, PASSWORD_KEY_LENGTH, PASSWORD_DIGEST)
    .toString('hex');
  return `pbkdf2$${PASSWORD_DIGEST}$${PASSWORD_ITERATIONS}$${salt}$${hash}`;
}

function verifyPassword(password, storedHash) {
  if (!storedHash) return false;

  if (storedHash.startsWith('pbkdf2$')) {
    const [, digest, iterationText, salt, expectedHash] = storedHash.split('$');
    const iterations = Number(iterationText);
    if (!digest || !iterations || !salt || !expectedHash) return false;

    const actualHash = crypto
      .pbkdf2Sync(password, salt, iterations, Buffer.from(expectedHash, 'hex').length, digest)
      .toString('hex');
    return crypto.timingSafeEqual(Buffer.from(actualHash, 'hex'), Buffer.from(expectedHash, 'hex'));
  }

  // Legacy migration path for older hackathon records that used raw SHA-256.
  const legacyHash = crypto.createHash('sha256').update(password).digest('hex');
  return legacyHash === storedHash;
}

function safeUser(user) {
  return {
    id: user._id.toString(),
    userId: user._id.toString(),
    fullName: user.fullName || user.name || '',
    name: user.name || user.fullName || '',
    email: user.email,
    googleId: user.googleId || null,
    profileImage: user.profileImage || '',
    bio: user.bio || '',
    phoneNumber: user.phoneNumber || '',
    preferences: user.preferences || {},
    loginMethod: user.loginMethod || user.loginProvider || 'email',
    loginProvider: user.loginProvider || user.loginMethod || 'email',
    mfaEnabled: Boolean(user.mfaEnabled),
    accountCreationDate: user.createdAt,
    createdAt: user.createdAt,
    lastLoginDate: user.lastLoginAt,
    lastLoginAt: user.lastLoginAt,
    profileUpdateHistory: user.profileUpdateHistory || [],
    firstName: user.firstName || '',
    lastName: user.lastName || '',
    role: user.role || '',
    location: user.location || '',
    instagram: user.instagram || '',
    linkedin: user.linkedin || '',
    github: user.github || '',
    x: user.x || '',
    telegram: user.telegram || '',
  };
}

function signAuthToken(user) {
  return jwt.sign(
    { id: user._id.toString(), email: user.email, sessionVersion: user.sessionVersion || 0 },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL },
  );
}

async function getAuthenticatedUser(decoded) {
  const user = await User.findById(decoded.id);
  if (!user) return null;
  if ((decoded.sessionVersion || 0) !== (user.sessionVersion || 0)) return null;
  return user;
}

// ----------------------------------------------------
// JWT Helper Middleware
// ----------------------------------------------------
async function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Access token missing' });
  }

  if (token === 'local-demo-token') {
    try {
      const demoUser = await User.findOne({ email: 'demo@multidomain.ai' });
      if (demoUser) {
        req.user = { id: demoUser._id.toString(), email: demoUser.email, sessionVersion: demoUser.sessionVersion || 0 };
        req.authUser = demoUser;
        return next();
      }
      // Demo user not seeded yet — return a clear 401 rather than falling through
      return res.status(401).json({ error: 'Demo user not found. Please restart the server to seed the demo account.' });
    } catch (e) {
      console.error('Local demo authentication failed:', e);
      return res.status(500).json({ error: 'Demo authentication error: ' + e.message });
    }
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await getAuthenticatedUser(decoded);
    if (!user) return res.status(403).json({ error: 'Session is invalid or expired' });
    req.user = decoded;
    req.authUser = user;
    return next();
  } catch (error) {
    return res.status(403).json({ error: 'Token is invalid or expired' });
  }
}

// ----------------------------------------------------
// Authentication Routes
// ----------------------------------------------------
router.post('/register', async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    const fullName = normalizeText(req.body.fullName || req.body.name, 120);
    const { password } = req.body;

    if (!fullName) return res.status(400).json({ error: 'Full name is required' });
    if (!validateEmail(email)) return res.status(400).json({ error: 'Enter a valid email address' });
    const passwordError = validatePassword(password);
    if (passwordError) return res.status(400).json({ error: passwordError });

    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(409).json({ error: 'User already exists' });

    const user = await User.create({
      email,
      fullName,
      name: fullName,
      password: hashPassword(password),
      loginMethod: 'email',
      loginProvider: 'email',
      lastLoginAt: new Date(),
    });

    const token = signAuthToken(user);
    res.status(201).json({ message: 'User registered successfully', token, user: safeUser(user) });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    const { password } = req.body;
    if (!validateEmail(email) || !password) return res.status(400).json({ error: 'Email and password required' });

    const user = await User.findOne({ email }).select('+password +mfaSecret');
    if (!user || !user.password) return res.status(401).json({ error: 'Invalid credentials' });

    const isMatch = verifyPassword(password, user.password);
    if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

    if (!user.password.startsWith('pbkdf2$')) {
      user.password = hashPassword(password);
    }

    if (user.mfaEnabled) {
      const tempToken = jwt.sign(
        { id: user._id.toString(), email: user.email, mfaPending: true, sessionVersion: user.sessionVersion || 0 },
        JWT_SECRET,
        { expiresIn: '5m' },
      );
      await user.save();
      return res.status(200).json({ mfaRequired: true, tempToken });
    }

    user.lastLoginAt = new Date();
    user.loginProvider = user.googleId ? 'email_google' : 'email';
    user.loginMethod = user.googleId ? 'email_google' : 'email';
    await user.save();

    const token = signAuthToken(user);
    return res.status(200).json({ token, user: safeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Login failed', message: error.message });
  }
});

router.post('/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken is required' });
    if (!process.env.GOOGLE_CLIENT_ID) return res.status(500).json({ error: 'Google Client ID is not configured on the backend' });

    let payload;
    try {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      payload = ticket.getPayload();
    } catch (error) {
      if (process.env.ALLOW_MOCK_GOOGLE === 'true' && idToken.startsWith('mock_token_')) {
        payload = {
          email: `${idToken.replace('mock_token_', '')}@gmail.com`,
          name: 'Developer User',
          picture: '',
          sub: 'mock-google-user',
        };
      } else {
        return res.status(401).json({ error: 'Invalid Google token' });
      }
    }

    const email = normalizeEmail(payload.email);
    if (!validateEmail(email)) return res.status(401).json({ error: 'Google account did not provide a valid email' });

    const googleId = payload.sub;
    const fullName = normalizeText(payload.name || email.split('@')[0], 120);
    const picture = payload.picture || '';
    let user = await User.findOne({ $or: [{ email }, { googleId }] });

    if (!user) {
      user = await User.create({
        email,
        fullName,
        name: fullName,
        googleId,
        profileImage: picture,
        loginMethod: 'google',
        loginProvider: 'google',
        lastLoginAt: new Date(),
      });
    } else {
      user.googleId = user.googleId || googleId;
      user.fullName = user.fullName || fullName;
      user.name = user.name || fullName;
      user.profileImage = user.profileImage || picture;
      user.lastLoginAt = new Date();
      user.loginMethod = user.password ? 'email_google' : 'google';
      user.loginProvider = user.loginMethod;
      await user.save();
    }

    if (user.mfaEnabled) {
      const tempToken = jwt.sign(
        { id: user._id.toString(), email: user.email, mfaPending: true, sessionVersion: user.sessionVersion || 0 },
        JWT_SECRET,
        { expiresIn: '5m' },
      );
      return res.status(200).json({ mfaRequired: true, tempToken });
    }

    const token = signAuthToken(user);
    return res.status(200).json({ token, user: safeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Google sign-in failed', message: error.message });
  }
});

router.get('/me', authenticateToken, async (req, res) => {
  res.status(200).json({ user: safeUser(req.authUser) });
});

router.post('/logout', authenticateToken, async (_req, res) => {
  res.status(200).json({ message: 'Logged out successfully' });
});

router.post('/forgot-password', async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    if (!validateEmail(email)) return res.status(400).json({ error: 'Enter a valid email address' });

    const user = await User.findOne({ email }).select('+passwordResetTokenHash +passwordResetExpires');
    const response = { message: 'If an account exists, password reset instructions have been prepared.' };
    if (!user) return res.status(200).json(response);

    const resetToken = crypto.randomBytes(32).toString('hex');
    user.passwordResetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');
    user.passwordResetExpires = new Date(Date.now() + 15 * 60 * 1000);
    await user.save();

    if (process.env.NODE_ENV !== 'production') {
      response.resetToken = resetToken;
    }

    return res.status(200).json(response);
  } catch (error) {
    return res.status(500).json({ error: 'Password reset request failed', message: error.message });
  }
});

router.post('/reset-password', async (req, res) => {
  try {
    const { token, password } = req.body;
    const passwordError = validatePassword(password);
    if (!token || passwordError) return res.status(400).json({ error: passwordError || 'Reset token is required' });

    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const user = await User.findOne({
      passwordResetTokenHash: tokenHash,
      passwordResetExpires: { $gt: new Date() },
    }).select('+passwordResetTokenHash +passwordResetExpires +password');

    if (!user) return res.status(400).json({ error: 'Reset token is invalid or expired' });

    user.password = hashPassword(password);
    user.passwordResetTokenHash = undefined;
    user.passwordResetExpires = undefined;
    user.sessionVersion = (user.sessionVersion || 0) + 1;
    await user.save();

    return res.status(200).json({ message: 'Password updated successfully' });
  } catch (error) {
    return res.status(500).json({ error: 'Password reset failed', message: error.message });
  }
});

router.post('/change-password', authenticateToken, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const passwordError = validatePassword(newPassword);
    if (!currentPassword || passwordError) return res.status(400).json({ error: passwordError || 'Current password is required' });

    const user = await User.findById(req.user.id).select('+password');
    if (!user || !user.password) return res.status(400).json({ error: 'Password login is not enabled for this account' });

    if (!verifyPassword(currentPassword, user.password)) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    user.password = hashPassword(newPassword);
    user.sessionVersion = (user.sessionVersion || 0) + 1;
    await user.save();

    const token = signAuthToken(user);
    return res.status(200).json({ message: 'Password changed successfully', token, user: safeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Password change failed', message: error.message });
  }
});

// ----------------------------------------------------
// MFA Routes
// ----------------------------------------------------
router.post('/mfa/setup', authenticateToken, async (req, res) => {
  try {
    const user = req.authUser;
    const secret = authenticator.generateSecret();
    user.tempMfaSecret = secret;
    await user.save();

    const otpauth = authenticator.keyuri(user.email, 'Multi-Domain AI', secret);
    const qrCodeDataUrl = await qrcode.toDataURL(otpauth);

    res.status(200).json({ secret, qrCodeDataUrl });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/mfa/verify', authenticateToken, async (req, res) => {
  try {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'MFA code is required' });

    const user = await User.findById(req.user.id).select('+tempMfaSecret +mfaSecret');
    if (!user || !user.tempMfaSecret) return res.status(400).json({ error: 'MFA not initiated' });

    const isValid = authenticator.verify({ token: code, secret: user.tempMfaSecret });
    if (!isValid) return res.status(400).json({ error: 'Invalid MFA code' });

    user.mfaSecret = user.tempMfaSecret;
    user.mfaEnabled = true;
    user.tempMfaSecret = undefined;
    await user.save();

    res.status(200).json({ message: 'MFA enabled successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/mfa/login', async (req, res) => {
  try {
    const { tempToken, code } = req.body;
    if (!tempToken || !code) return res.status(400).json({ error: 'tempToken and code are required' });

    let decoded;
    try {
      decoded = jwt.verify(tempToken, JWT_SECRET);
    } catch (error) {
      return res.status(401).json({ error: 'Temporary token expired or invalid' });
    }

    const user = await User.findById(decoded.id).select('+mfaSecret');
    if (!user || !user.mfaSecret || decoded.mfaPending !== true) {
      return res.status(400).json({ error: 'MFA not set up for this account' });
    }

    const isValid = authenticator.verify({ token: code, secret: user.mfaSecret });
    if (!isValid) return res.status(401).json({ error: 'Invalid MFA code' });

    user.lastLoginAt = new Date();
    await user.save();

    const token = signAuthToken(user);
    res.status(200).json({ token, user: safeUser(user) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

async function seedDemoUser() {
  try {
    const email = 'demo@multidomain.ai';
    const count = await User.countDocuments({ email });
    if (count === 0) {
      const passwordHash = hashPassword('Demo@1234');
      const demoUser = new User({
        fullName: 'Demo User',
        name: 'Demo User',
        email: email,
        password: passwordHash,
        bio: 'Local demo account',
        preferences: { notifications: true, soundEffects: true },
        loginMethod: 'email',
        loginProvider: 'email',
        createdAt: new Date(),
        lastLoginAt: new Date(),
        firstName: 'Demo',
        lastName: 'User',
        role: 'Full Stack Developer',
        location: 'New York, USA',
        instagram: 'https://instagram.com/demouser',
        linkedin: 'https://linkedin.com/in/demouser',
        github: 'https://github.com/demouser',
        x: 'https://x.com/demouser',
        telegram: 'https://web.telegram.org/a/#8873481129'
      });
      await demoUser.save();
      console.log('[Auth] Successfully seeded demo@multidomain.ai user inside MongoDB!');
    }
  } catch (err) {
    console.error('[Auth] Error seeding demo user:', err);
  }
}

module.exports = {
  router,
  authenticateToken,
  User,
  safeUser,
  hashPassword,
  verifyPassword,
  validatePassword,
  validateEmail,
  normalizeEmail,
  seedDemoUser,
};
