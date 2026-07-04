const express = require('express');
const {
  authenticateToken,
  User,
  safeUser,
  normalizeEmail,
  validateEmail,
} = require('./auth');

const router = express.Router();

function cleanText(value, maxLength = 500) {
  if (value === undefined || value === null) return '';
  return String(value).trim().slice(0, maxLength);
}

function cleanProfileImage(value) {
  if (!value) return '';
  const text = String(value).trim();
  const isAllowed =
    text.startsWith('http://') ||
    text.startsWith('https://') ||
    text.startsWith('data:image/') ||
    text.startsWith('/uploads/');
  return isAllowed ? text.slice(0, 2_000_000) : '';
}

function cleanPreferences(preferences) {
  if (!preferences || typeof preferences !== 'object' || Array.isArray(preferences)) return {};
  const allowed = ['notifications', 'soundEffects', 'darkMode', 'language', 'primaryDomain'];
  return allowed.reduce((acc, key) => {
    if (Object.prototype.hasOwnProperty.call(preferences, key)) {
      acc[key] = preferences[key];
    }
    return acc;
  }, {});
}

function appendHistory(user, fields) {
  if (!fields.length) return;
  user.profileUpdateHistory = [
    { changedAt: new Date(), fields },
    ...(user.profileUpdateHistory || []),
  ].slice(0, 25);
}

async function updateProfile(req, res) {
  try {
    const user = req.authUser;
    const changedFields = [];

    if (req.body.fullName !== undefined || req.body.name !== undefined) {
      const fullName = cleanText(req.body.fullName || req.body.name, 120);
      if (!fullName) return res.status(400).json({ error: 'Full name cannot be empty' });
      user.fullName = fullName;
      user.name = fullName;
      changedFields.push('fullName');
    }

    if (req.body.email !== undefined) {
      const email = normalizeEmail(req.body.email);
      if (!validateEmail(email)) return res.status(400).json({ error: 'Enter a valid email address' });
      const existing = await User.findOne({ email, _id: { $ne: user._id } });
      if (existing) return res.status(409).json({ error: 'Email is already in use' });
      user.email = email;
      changedFields.push('email');
    }

    if (req.body.phoneNumber !== undefined) {
      const phone = cleanText(req.body.phoneNumber, 32);
      if (phone && !/^[+\d][+\d\s().-]{6,31}$/.test(phone)) {
        return res.status(400).json({ error: 'Enter a valid phone number' });
      }
      user.phoneNumber = phone;
      changedFields.push('phoneNumber');
    }

    if (req.body.bio !== undefined) {
      user.bio = cleanText(req.body.bio, 280);
      changedFields.push('bio');
    }

    if (req.body.firstName !== undefined) {
      user.firstName = cleanText(req.body.firstName, 80);
      changedFields.push('firstName');
    }

    if (req.body.lastName !== undefined) {
      user.lastName = cleanText(req.body.lastName, 80);
      changedFields.push('lastName');
    }

    if (req.body.role !== undefined) {
      user.role = cleanText(req.body.role, 120);
      changedFields.push('role');
    }

    if (req.body.location !== undefined) {
      user.location = cleanText(req.body.location, 120);
      changedFields.push('location');
    }

    if (req.body.instagram !== undefined) {
      user.instagram = cleanText(req.body.instagram, 250);
      changedFields.push('instagram');
    }

    if (req.body.linkedin !== undefined) {
      user.linkedin = cleanText(req.body.linkedin, 250);
      changedFields.push('linkedin');
    }

    if (req.body.github !== undefined) {
      user.github = cleanText(req.body.github, 250);
      changedFields.push('github');
    }

    if (req.body.x !== undefined) {
      user.x = cleanText(req.body.x, 250);
      changedFields.push('x');
    }

    if (req.body.telegram !== undefined) {
      user.telegram = cleanText(req.body.telegram, 250);
      changedFields.push('telegram');
    }

    if (req.body.profileImage !== undefined) {
      user.profileImage = cleanProfileImage(req.body.profileImage);
      changedFields.push('profileImage');
    }

    if (req.body.preferences !== undefined) {
      user.preferences = {
        ...(user.preferences || {}),
        ...cleanPreferences(req.body.preferences),
      };
      changedFields.push('preferences');
    }

    appendHistory(user, [...new Set(changedFields)]);
    await user.save();

    res.status(200).json(safeUser(user));
  } catch (error) {
    res.status(500).json({ error: 'Profile update failed', message: error.message });
  }
}

router.get('/', authenticateToken, async (req, res) => {
  res.status(200).json(safeUser(req.authUser));
});

router.patch('/', authenticateToken, updateProfile);
router.post('/update', authenticateToken, updateProfile);

router.delete('/', authenticateToken, async (req, res) => {
  try {
    await User.deleteOne({ _id: req.authUser._id });
    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Account deletion failed', message: error.message });
  }
});

module.exports = router;
