const express = require('express');
const router = express.Router();
const { verifyAdmin, verifyToken } = require('../middlewares/auth');
const userController = require('../controllers/userController');

// Get all users with filters
router.get('/', verifyAdmin, userController.getAllUsers);

// Get a single user's details
router.get('/:id', verifyToken, userController.getUserDetails);

// Update a user's details
router.put('/:id', verifyAdmin, userController.updateUserDetails);

// Toggle user active status
router.patch('/:id/status', verifyAdmin, userController.toggleUserStatus);

module.exports = router;
