const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  specialty: { type: String, required: true },
  hospital: { type: String, required: true },
  experience: { type: Number, required: true },
  rating: { type: Number, required: true },
  consultationFee: { type: Number, required: true }, // in INR
  profileImage: { type: String, required: true },
  isAvailable: { type: Boolean, default: true }
}, {
  collection: 'Doctors',
  timestamps: true
});

module.exports = doctorSchema;
