const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middlewares/auth');

// Ensure only admins can access these routes
router.use(authMiddleware.verifyAdmin);

// Dashboard routes
router.get('/dashboard', adminController.getDashboardStats);

// Additional admin functionalities can go here
router.get('/clients', adminController.getClients);
router.get('/pharmacies', adminController.getPharmacies);
router.get('/requests', adminController.getRequests);

module.exports = router;
