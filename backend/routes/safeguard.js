const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { authenticateToken } = require('./auth');

const contactsPath = path.join(__dirname, '../Contacts.json');
const firPath = path.join(__dirname, '../FIR.json');

// Helper to read JSON
function readJSON(filePath, defaultVal = []) {
  try {
    if (!fs.existsSync(filePath)) {
      return defaultVal;
    }
    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content || JSON.stringify(defaultVal));
  } catch (err) {
    console.error(`Error reading ${filePath}:`, err);
    return defaultVal;
  }
}

// Helper to write JSON
function writeJSON(filePath, data) {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
  } catch (err) {
    console.error(`Error writing ${filePath}:`, err);
  }
}

// Get contacts for the logged-in user
router.get('/contacts', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const allContacts = readJSON(contactsPath, []);
  
  // Find contacts for this user
  const userEntry = allContacts.find(e => e.userId === userId);
  const contacts = userEntry ? userEntry.contacts : [];
  
  res.json({ success: true, data: contacts });
});

// Add contact for the logged-in user
router.post('/contacts', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { name, phone, relation } = req.body;
  
  if (!name || !phone) {
    return res.status(400).json({ success: false, error: 'Name and phone are required' });
  }
  
  const allContacts = readJSON(contactsPath, []);
  let userEntry = allContacts.find(e => e.userId === userId);
  
  if (!userEntry) {
    userEntry = { userId, contacts: [] };
    allContacts.push(userEntry);
  }
  
  if (userEntry.contacts.length >= 3) {
    return res.status(400).json({ success: false, error: 'You can add up to 3 contacts only.' });
  }
  
  const newContact = {
    id: Date.now().toString(),
    name,
    phone,
    relation: relation || 'Family'
  };
  
  userEntry.contacts.push(newContact);
  writeJSON(contactsPath, allContacts);
  
  res.json({ success: true, data: userEntry.contacts });
});

// Delete contact for the logged-in user
router.delete('/contacts/:id', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const contactId = req.params.id;
  
  const allContacts = readJSON(contactsPath, []);
  const userEntry = allContacts.find(e => e.userId === userId);
  
  if (userEntry) {
    userEntry.contacts = userEntry.contacts.filter(c => c.id !== contactId);
    writeJSON(contactsPath, allContacts);
    return res.json({ success: true, data: userEntry.contacts });
  }
  
  res.json({ success: true, data: [] });
});

// Get FIRs for the logged-in user
router.get('/fir', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const allFirs = readJSON(firPath, []);
  const userFirs = allFirs.filter(f => f.userId === userId);
  res.json({ success: true, data: userFirs });
});

// Create FIR for the logged-in user
router.post('/fir', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const allFirs = readJSON(firPath, []);
  
  const {
    fullName, age, occupation, permanentAddress, temporaryAddress, contactNumber,
    incidentNarrative, incidentDate, incidentTime, incidentLocation,
    crimeDescription, motives, propertyStolen, weaponsUsed, specificLaws
  } = req.body;

  if (!fullName || !contactNumber || !incidentNarrative) {
    return res.status(400).json({ success: false, error: 'Complainant name, contact number, and narrative are required' });
  }

  const firNumber = 'FIR-' + Math.floor(100000 + Math.random() * 900000);
  const registrationDateTime = new Date().toISOString();

  const newFir = {
    firNumber,
    registrationDateTime,
    userId,
    complainantDetails: {
      fullName,
      age,
      occupation,
      permanentAddress,
      temporaryAddress,
      contactNumber
    },
    firDetails: {
      incidentNarrative,
      incidentDate,
      incidentTime,
      incidentLocation,
      crimeDescription,
      motives,
      propertyStolen,
      weaponsUsed
    },
    specificLaws: specificLaws || 'Indian Penal Code / Bharatiya Nyaya Sanhita'
  };

  allFirs.push(newFir);
  writeJSON(firPath, allFirs);
  res.json({ success: true, data: newFir });
});

// Delete FIR for the logged-in user
router.delete('/fir/:firNumber', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const firNumber = req.params.firNumber;
  
  let allFirs = readJSON(firPath, []);
  const firIndex = allFirs.findIndex(f => f.firNumber === firNumber && f.userId === userId);
  
  if (firIndex === -1) {
    return res.status(404).json({ success: false, error: 'FIR not found' });
  }

  allFirs.splice(firIndex, 1);
  writeJSON(firPath, allFirs);
  res.json({ success: true, message: 'FIR deleted successfully' });
});

module.exports = router;
