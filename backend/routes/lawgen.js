const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

// ── CSV Helpers ──────────────────────────────────────────────────────────────
function parseCSVLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      result.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  result.push(current.trim());
  return result;
}

function parseCSV(filePath) {
  try {
    if (!fs.existsSync(filePath)) {
      console.warn(`[LawGen API] File not found: ${filePath}`);
      return [];
    }
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n').map(l => l.trim()).filter(l => l.length > 0);
    if (lines.length === 0) return [];
    
    const headers = parseCSVLine(lines[0]);
    const records = [];
    
    // Parse up to 20000 lines max for safety & speed
    const limit = Math.min(lines.length, 25000);
    for (let i = 1; i < limit; i++) {
      const vals = parseCSVLine(lines[i]);
      if (vals.length >= headers.length) {
        const obj = {};
        headers.forEach((h, idx) => {
          obj[h] = vals[idx] || '';
        });
        records.push(obj);
      }
    }
    console.log(`[LawGen API] Loaded ${records.length} records from ${path.basename(filePath)}`);
    return records;
  } catch (err) {
    console.error(`[LawGen API] Error parsing ${filePath}:`, err);
    return [];
  }
}

// ── In-Memory Database / Cache ───────────────────────────────────────────────
let documentsData = {
  Award: [],
  Credit: [],
  Episode: [],
  Keyword: [],
  Person: [],
  Vote: []
};

let lawLibraryData = [];

// Initialize & Load CSVs
function init() {
  console.log('[LawGen API] Loading datasets on startup...');
  const docsDir = path.join(__dirname, '../../Legal_Documents');
  
  documentsData.Award = parseCSV(path.join(docsDir, 'Award'));
  documentsData.Credit = parseCSV(path.join(docsDir, 'Credit'));
  documentsData.Episode = parseCSV(path.join(docsDir, 'Episode'));
  // Note: Handle both uppercase/lowercase filenames for safety
  documentsData.Keyword = parseCSV(path.join(docsDir, 'Keyword')) || parseCSV(path.join(docsDir, 'keyword'));
  documentsData.Person = parseCSV(path.join(docsDir, 'Person')) || parseCSV(path.join(docsDir, 'person'));
  documentsData.Vote = parseCSV(path.join(docsDir, 'Vote')) || parseCSV(path.join(docsDir, 'vote'));

  const libraryPath = path.join(__dirname, '../../Img & Video/Indian_Law_Library.csv');
  lawLibraryData = parseCSV(libraryPath);
}

// Run initialization
init();

// Helper to categorize law by title
function getLawCategory(title) {
  const t = (title || '').toLowerCase();
  if (t.includes('police') || t.includes('offence') || t.includes('criminal') || t.includes('prison') || t.includes('penal') || t.includes('violence') || t.includes('arrest') || t.includes('punishment') || t.includes('forensic')) {
    return 'Criminal & Penal Law';
  }
  if (t.includes('tax') || t.includes('revenue') || t.includes('income') || t.includes('finance') || t.includes('bank') || t.includes('bond') || t.includes('customs') || t.includes('excise') || t.includes('debt') || t.includes('wealth')) {
    return 'Taxation & Finance';
  }
  if (t.includes('company') || t.includes('corporate') || t.includes('contract') || t.includes('commerce') || t.includes('trade') || t.includes('business') || t.includes('partnership') || t.includes('arbitration') || t.includes('patent') || t.includes('copyright') || t.includes('trademark')) {
    return 'Corporate & Commercial Law';
  }
  if (t.includes('labour') || t.includes('employment') || t.includes('wages') || t.includes('workmen') || t.includes('factory') || t.includes('bonus') || t.includes('gratuity') || t.includes('provident') || t.includes('pension')) {
    return 'Labour & Employment Law';
  }
  if (t.includes('accident') || t.includes('motor vehicle') || t.includes('carriage') || t.includes('vessel') || t.includes('port') || t.includes('toll') || t.includes('railway') || t.includes('shipping') || t.includes('highway') || t.includes('canal') || t.includes('dock')) {
    return 'Transport & Maritime Law';
  }
  return 'Civil & Constitutional Law';
}

// ── GET /api/lawgen/documents ────────────────────────────────────────────────
// Select 2 random items from each of the 6 datasets
router.get('/documents', (req, res) => {
  try {
    const response = [];
    
    Object.keys(documentsData).forEach(domain => {
      const items = documentsData[domain];
      if (items.length > 0) {
        // Draw 2 unique random items
        const selected = [];
        const indices = new Set();
        while (indices.size < Math.min(2, items.length)) {
          const randIdx = Math.floor(Math.random() * items.length);
          indices.add(randIdx);
        }
        indices.forEach(idx => {
          selected.push({
            domain,
            ...items[idx]
          });
        });
        response.push(...selected);
      }
    });

    res.status(200).json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/lawgen/library/categories ────────────────────────────────────────
// Get list of categories and counts
router.get('/library/categories', (req, res) => {
  try {
    const categoriesMap = {
      'Civil & Constitutional Law': {
        id: 'civil',
        name: 'Civil & Constitutional Law',
        description: 'Fundamental rights, property disputes, family law, contracts, and constitutional provisions.',
        color: '#D4A017',
        icon: 'gavel',
        count: 0
      },
      'Criminal & Penal Law': {
        id: 'criminal',
        name: 'Criminal & Penal Law',
        description: 'Indian Penal Code (IPC/BNS), police procedure, offences, punishments, and criminal defense.',
        color: '#B91C1C',
        icon: 'shield',
        count: 0
      },
      'Corporate & Commercial Law': {
        id: 'corporate',
        name: 'Corporate & Commercial Law',
        description: 'Company filings, trade, business disputes, intellectual property, contracts, and patents.',
        color: '#1E3A8A',
        icon: 'business',
        count: 0
      },
      'Labour & Employment Law': {
        id: 'labour',
        name: 'Labour & Employment Law',
        description: 'Workplace rights, employee disputes, wages, factory conditions, and pensions.',
        color: '#047857',
        icon: 'people',
        count: 0
      },
      'Transport & Maritime Law': {
        id: 'transport',
        name: 'Transport & Maritime Law',
        description: 'Motor vehicles regulations, shipping, port tolls, railways, and public transit laws.',
        color: '#0369A1',
        icon: 'boat',
        count: 0
      },
      'Taxation & Finance': {
        id: 'taxation',
        name: 'Taxation & Finance',
        description: 'Direct & indirect taxes, avoidance of double taxation, wealth, custom duties, and bank regulations.',
        color: '#701A75',
        icon: 'cash',
        count: 0
      }
    };

    lawLibraryData.forEach(law => {
      const cat = getLawCategory(law.title);
      if (categoriesMap[cat]) {
        categoriesMap[cat].count++;
      }
    });

    res.status(200).json(Object.values(categoriesMap));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/lawgen/library/laws ─────────────────────────────────────────────
// Get laws for a category, supporting search
router.get('/library/laws', (req, res) => {
  try {
    const { category, search } = req.query;
    if (!category) {
      return res.status(400).json({ error: 'category query parameter is required' });
    }

    let filtered = lawLibraryData.filter(law => getLawCategory(law.title) === category);

    if (search) {
      const s = search.toLowerCase();
      filtered = filtered.filter(law => 
        (law.title || '').toLowerCase().includes(s) || 
        (law.source || '').toLowerCase().includes(s)
      );
    }

    // Limit output size to prevent overloading transmission
    res.status(200).json(filtered.slice(0, 100));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/lawgen/advocates ───────────────────────────────────────────────
// Get seeded Indian Advocate list
router.get('/advocates', (req, res) => {
  try {
    const advocates = [
      {
        id: 'adv001',
        name: 'Advocate Rajesh K. Sharma',
        title: 'Senior Supreme Court Advocate',
        specialization: 'Constitutional Law & Criminal Defense',
        description: '18+ years of experience in landmark trials. Former public prosecutor with an exceptional track record in civil litigation, land disputes, and criminal defense.',
        location: 'New Delhi, Delhi',
        contactEmail: 'rajesh.sharma@sc-advocates.in',
        contactPhone: '+91 98765 43210',
        photo: 'assets/images/advocate_rajesh.png',
        available: true,
        rating: 4.9,
        experience: '18 Years'
      },
      {
        id: 'adv002',
        name: 'Advocate Priya S. Nair',
        title: 'Corporate & Intellectual Property Consultant',
        specialization: 'Company Law, Trademark & Patent',
        description: 'Specializes in tech startups, contract drafting, and IPR enforcement. Handles company registration compliance, corporate governance, and patent filings.',
        location: 'Bangalore, Karnataka',
        contactEmail: 'priya.nair@ipr-associates.in',
        contactPhone: '+91 80555 12345',
        photo: 'assets/images/advocate_priya.png',
        available: true,
        rating: 4.8,
        experience: '12 Years'
      },
      {
        id: 'adv003',
        name: 'Advocate Amit V. Patel',
        title: 'Family Law Specialist & Mediator',
        specialization: 'Divorce, Custody, Mediation & Wills',
        description: 'Dedicated to resolving family and inheritance disputes amicably. Known for compassionate representation in complex partition suits and custody negotiations.',
        location: 'Mumbai, Maharashtra',
        contactEmail: 'amit.patel@familylawyers.in',
        contactPhone: '+91 91122 33445',
        photo: 'assets/images/advocate_amit.png',
        available: true,
        rating: 4.7,
        experience: '10 Years'
      }
    ];

    res.status(200).json(advocates);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
