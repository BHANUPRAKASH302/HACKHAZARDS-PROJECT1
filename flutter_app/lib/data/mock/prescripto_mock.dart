/// Mock data for Prescripto (Healthcare) domain.

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int experience;
  final String imageInitials;
  final bool isAvailable;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.experience,
    required this.imageInitials,
    this.isAvailable = true,
  });
}

class HealthRecord {
  final String date;
  final String type;
  final String value;
  final String status;
  const HealthRecord({
    required this.date,
    required this.type,
    required this.value,
    required this.status,
  });
}

class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final int daysLeft;
  const Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.daysLeft,
  });
}

// ── Mock Data ─────────────────────────────────────────────────────────────

const List<Doctor> mockDoctors = [
  Doctor(
    id: 'd001',
    name: 'Dr. Anjali Sharma',
    specialty: 'General Physician',
    hospital: 'City Health Centre',
    rating: 4.9,
    experience: 12,
    imageInitials: 'AS',
  ),
  Doctor(
    id: 'd002',
    name: 'Dr. Rahul Verma',
    specialty: 'Cardiologist',
    hospital: 'Apollo Hospitals',
    rating: 4.7,
    experience: 15,
    imageInitials: 'RV',
  ),
  Doctor(
    id: 'd003',
    name: 'Dr. Neha Singh',
    specialty: 'Dermatologist',
    hospital: 'Skin & Care Clinic',
    rating: 4.8,
    experience: 8,
    imageInitials: 'NS',
  ),
  Doctor(
    id: 'd004',
    name: 'Dr. Amit Patel',
    specialty: 'Dentist',
    hospital: 'Bright Smile Dental',
    rating: 4.6,
    experience: 10,
    imageInitials: 'AP',
    isAvailable: false,
  ),
];

const List<HealthRecord> mockHealthRecords = [
  HealthRecord(date: '12 Jun 2026', type: 'Blood Pressure', value: '120/80 mmHg', status: 'Normal'),
  HealthRecord(date: '10 Jun 2026', type: 'Blood Sugar', value: '95 mg/dL', status: 'Normal'),
  HealthRecord(date: '05 Jun 2026', type: 'Cholesterol', value: '185 mg/dL', status: 'Good'),
  HealthRecord(date: '01 Jun 2026', type: 'Haemoglobin', value: '13.5 g/dL', status: 'Normal'),
];

const List<Medicine> mockMedicines = [
  Medicine(name: 'Metformin 500mg', dosage: '1 tablet', frequency: 'Twice daily', daysLeft: 7),
  Medicine(name: 'Atorvastatin 10mg', dosage: '1 tablet', frequency: 'At night', daysLeft: 14),
  Medicine(name: 'Vitamin D3', dosage: '1 capsule', frequency: 'Once daily', daysLeft: 21),
];

const List<String> mockSpecialties = [
  'All', 'General', 'Cardiology', 'Dermatology', 'Dentistry', 'Neurology', 'Orthopedics'
];
