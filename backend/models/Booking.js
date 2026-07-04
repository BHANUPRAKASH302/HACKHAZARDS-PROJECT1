const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userEmail: { type: String, required: true, index: true },
  doctor: {
    id: { type: String, required: true },
    name: { type: String, required: true },
    specialty: { type: String, required: true },
    consultationFee: { type: Number, required: true }
  },
  patientName: { type: String, required: true },
  patientAge: { type: Number, required: true },
  patientGender: { type: String, required: true },
  healthIssue: { type: String, required: true },
  symptomsDescription: { type: String, default: '' },
  healthRating: { type: Number, required: true, min: 1, max: 5 },
  appointmentDate: { type: Date, required: true },
  status: { type: String, enum: ['Pending', 'Confirmed', 'Cancelled', 'Completed'], default: 'Pending' }
}, {
  collection: 'Bookings',
  timestamps: true
});

module.exports = bookingSchema;
