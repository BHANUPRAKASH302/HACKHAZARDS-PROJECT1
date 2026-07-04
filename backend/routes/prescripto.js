const express = require('express');
const mongoose = require('mongoose');
const doctorSchema = require('../models/Doctor');
const bookingSchema = require('../models/Booking');
const { authenticateToken } = require('./auth');

const router = express.Router();

// Connect to Prescripto_Data database
const db = mongoose.connection.useDb('Prescripto_Data', { useCache: true });
const Doctor = db.models.Doctor || db.model('Doctor', doctorSchema);
const Booking = db.models.Booking || db.model('Booking', bookingSchema);

// Doctor seeding function
async function seedDoctors() {
  try {
    const count = await Doctor.countDocuments();
    if (count === 0) {
      const doctorsList = [
        {
          name: 'Dr. Anjali Sharma',
          specialty: 'General Physician',
          hospital: 'City Health Centre',
          experience: 12,
          rating: 4.9,
          consultationFee: 500,
          profileImage: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Rahul Verma',
          specialty: 'Cardiology',
          hospital: 'Apollo Hospitals',
          experience: 15,
          rating: 4.7,
          consultationFee: 1000,
          profileImage: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Neha Singh',
          specialty: 'Dermatology',
          hospital: 'Skin & Care Clinic',
          experience: 8,
          rating: 4.8,
          consultationFee: 700,
          profileImage: 'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Amit Patel',
          specialty: 'Dentistry',
          hospital: 'Bright Smile Dental',
          experience: 10,
          rating: 4.6,
          consultationFee: 600,
          profileImage: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300',
          isAvailable: false
        },
        {
          name: 'Dr. Priya Nair',
          specialty: 'Gynecology',
          hospital: 'Metropolis Hospital',
          experience: 14,
          rating: 4.9,
          consultationFee: 800,
          profileImage: 'https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Vikram Mehta',
          specialty: 'Neurology',
          hospital: 'Brain & Spine Institute',
          experience: 18,
          rating: 4.9,
          consultationFee: 1200,
          profileImage: 'https://images.unsplash.com/photo-1536064485894-ce84015ef3b5?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Rajesh Kumar',
          specialty: 'Orthopedics',
          hospital: 'Fortis Healthcare',
          experience: 11,
          rating: 4.5,
          consultationFee: 650,
          profileImage: 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Kavita Rao',
          specialty: 'Pediatrics',
          hospital: 'Kids Care Hospital',
          experience: 9,
          rating: 4.8,
          consultationFee: 600,
          profileImage: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Sanjay Dutt',
          specialty: 'Psychiatry',
          hospital: 'Mind & Soul Wellness',
          experience: 16,
          rating: 4.7,
          consultationFee: 900,
          profileImage: 'https://images.unsplash.com/photo-1582750433449-64c656df174a?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        },
        {
          name: 'Dr. Alok Mishra',
          specialty: 'Ophthalmology',
          hospital: 'Netradham Eye Hospital',
          experience: 13,
          rating: 4.6,
          consultationFee: 500,
          profileImage: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300',
          isAvailable: true
        }
      ];

      await Doctor.insertMany(doctorsList);
      console.log('[Prescripto] Successfully seeded 10 doctors inside Prescripto_Data database!');
    }
  } catch (err) {
    console.error('[Prescripto] Error seeding doctors:', err);
  }
}

// 1. GET /api/prescripto/doctors
router.get('/doctors', async (req, res) => {
  try {
    const doctors = await Doctor.find({});
    res.status(200).json(doctors);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. GET /api/prescripto/bookings
router.get('/bookings', authenticateToken, async (req, res) => {
  try {
    const userEmail = req.user.email;
    console.log(`[Prescripto] GET /bookings → querying for userEmail: "${userEmail}"`);
    const bookings = await Booking.find({ userEmail }).sort({ createdAt: -1 });
    console.log(`[Prescripto] GET /bookings → found ${bookings.length} booking(s) for "${userEmail}"`);
    res.status(200).json(bookings);
  } catch (error) {
    console.error('[Prescripto] GET /bookings error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// 3. POST /api/prescripto/bookings
router.post('/bookings', authenticateToken, async (req, res) => {
  try {
    const userEmail = req.user.email;
    const {
      doctorId,
      doctorName,
      specialty,
      consultationFee,
      patientName,
      patientAge,
      patientGender,
      healthIssue,
      symptomsDescription,
      healthRating,
      appointmentDate
    } = req.body;

    // Accept specialty from either top-level or nested doctor object
    const resolvedSpecialty = specialty || req.body?.doctor?.specialty || 'General';
    const resolvedFee = consultationFee || req.body?.doctor?.consultationFee || 500;
    const resolvedDoctorId = doctorId || req.body?.doctor?.id || 'unknown';
    const resolvedDoctorName = doctorName || req.body?.doctor?.name;

    if (!resolvedDoctorName || !patientName || !patientAge || !patientGender || !healthIssue || !healthRating || !appointmentDate) {
      return res.status(400).json({ error: 'Missing required booking details (patientName, patientAge, patientGender, healthIssue, healthRating, appointmentDate).' });
    }

    const booking = new Booking({
      userEmail,
      doctor: {
        id: resolvedDoctorId,
        name: resolvedDoctorName,
        specialty: resolvedSpecialty,
        consultationFee: parseInt(resolvedFee, 10) || 500
      },
      patientName,
      patientAge: parseInt(patientAge, 10),
      patientGender,
      healthIssue,
      symptomsDescription: symptomsDescription || '',
      healthRating: parseInt(healthRating, 10),
      appointmentDate: new Date(appointmentDate)
    });

    await booking.save();
    console.log(`[Prescripto] POST /bookings → created booking ${booking._id} for "${userEmail}" (patient: ${patientName})`);
    res.status(201).json(booking);
  } catch (error) {
    console.error('[Prescripto] POST /bookings error:', error.message);
    res.status(500).json({ error: error.message });
  }
});


// 4. POST /api/prescripto/bookings/:id/confirm
router.post('/bookings/:id/confirm', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await Booking.findOneAndUpdate(
      { _id: id, userEmail: req.user.email },
      { status: 'Completed' },
      { new: true }
    );
    if (!booking) {
      return res.status(404).json({ error: 'Booking not found.' });
    }
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 5. POST /api/prescripto/bookings/:id/cancel
router.post('/bookings/:id/cancel', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await Booking.findOneAndUpdate(
      { _id: id, userEmail: req.user.email },
      { status: 'Cancelled' },
      { new: true }
    );
    if (!booking) {
      return res.status(404).json({ error: 'Booking not found.' });
    }
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 6. PUT /api/prescripto/bookings/:id/reschedule
router.put('/bookings/:id/reschedule', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { appointmentDate } = req.body;
    if (!appointmentDate) {
      return res.status(400).json({ error: 'appointmentDate is required.' });
    }
    const booking = await Booking.findOneAndUpdate(
      { _id: id, userEmail: req.user.email },
      { appointmentDate: new Date(appointmentDate) },
      { new: true }
    );
    if (!booking) {
      return res.status(404).json({ error: 'Booking not found.' });
    }
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 7. DELETE /api/prescripto/bookings/:id
router.delete('/bookings/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await Booking.findOneAndDelete({ _id: id, userEmail: req.user.email });
    if (!result) {
      return res.status(404).json({ error: 'Booking not found.' });
    }
    res.status(200).json({ message: 'Booking deleted successfully.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = {
  router,
  seedDoctors
};
