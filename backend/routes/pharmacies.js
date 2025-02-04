const express = require('express');
const router = express.Router();
const {
  getPharmacies,
  getPharmacyById,
  createPharmacy,
  updatePharmacy,
  deletePharmacy,
  togglePharmacyStatus,
  extendSubscription,
} = require('../controllers/pharmacyController');
const { verifyAdmin, verifyToken } = require('../middlewares/auth');

// Get all pharmacies
router.get('/', verifyToken, verifyAdmin, getPharmacies);

// Get a single pharmacy by ID
router.get('/:id', verifyToken, verifyAdmin, getPharmacyById);

// Create a new pharmacy
router.post('/', verifyToken, verifyAdmin, createPharmacy);

// Update an existing pharmacy
router.put('/:id', verifyToken, verifyAdmin, updatePharmacy);

// Delete a pharmacy
router.delete('/:id', verifyToken, verifyAdmin, deletePharmacy);

// Toggle pharmacy status (activate/deactivate)
router.patch('/:id/status', verifyToken, verifyAdmin, togglePharmacyStatus);

// Extend subscription duration
router.patch('/:id/subscription', verifyToken, verifyAdmin, extendSubscription);

module.exports = router;
