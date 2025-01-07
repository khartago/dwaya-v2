const express = require('express');
const router = express.Router();
const {
  getPharmacies,
  addPharmacy,
  updatePharmacy,
  togglePharmacyStatus,
  extendSubscription,
} = require('../controllers/pharmacyController');
const { verifyToken, verifyAdmin } = require('../middlewares/auth');

// List all pharmacies with filters
router.get('/', verifyToken, verifyAdmin, getPharmacies);

// Add a new pharmacy
router.post('/', verifyToken, verifyAdmin, addPharmacy);

// Update pharmacy details
router.put('/:id', verifyToken, verifyAdmin, updatePharmacy);

// Activate/Deactivate a pharmacy
router.patch('/:id/status', verifyToken, verifyAdmin, togglePharmacyStatus);

// Extend subscription
router.patch('/:id/subscription', verifyToken, verifyAdmin, extendSubscription);

module.exports = router;
