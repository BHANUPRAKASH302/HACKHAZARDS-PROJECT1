const express = require('express');
const router = express.Router();
const Review = require('../models/Review');

// @route   POST /api/reviews
// @desc    Add a new review
router.post('/', async (req, res) => {
  try {
    const { userName, rating, comment } = req.body;
    
    if (!rating || !comment) {
      return res.status(400).json({ error: 'Rating and comment are required' });
    }

    const newReview = new Review({
      userName: userName || 'Anonymous User',
      rating,
      comment
    });

    const savedReview = await newReview.save();
    res.status(201).json(savedReview);
  } catch (error) {
    console.error('Error adding review:', error);
    res.status(500).json({ error: 'Server error while adding review' });
  }
});

// @route   GET /api/reviews
// @desc    Get all reviews sorted by newest
router.get('/', async (req, res) => {
  try {
    const reviews = await Review.find().sort({ createdAt: -1 });
    res.status(200).json(reviews);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({ error: 'Server error while fetching reviews' });
  }
});

module.exports = router;
