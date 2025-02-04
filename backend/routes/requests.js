const express = require('express');
const router = express.Router();
const multer = require('multer');
const requestController = require('../controllers/requestController');
const authMiddleware = require('../middlewares/auth');

const upload = multer({ dest: 'uploads/' }); // Temporary directory for S3 uploads

// Client Routes
router.post(
  '/',
  authMiddleware.verifyClient,
  upload.single('ordonnance'), // To handle ordonnance uploads
  requestController.createRequest
);

// Pharmacy Routes
router.get(
  '/pharmacy',
  authMiddleware.verifyPharmacy,
  requestController.getRequestsForPharmacy
);
router.patch(
  '/:requestId/accept',
  authMiddleware.verifyPharmacy,
  requestController.acceptRequest
);
router.patch(
  '/:requestId/refuse',
  authMiddleware.verifyPharmacy,
  requestController.refuseRequest
);

// Admin Routes
router.get('/', authMiddleware.verifyAdmin, requestController.getAllRequests);
router.get('/:id', authMiddleware.verifyAdmin, requestController.getRequestById);
router.patch('/:requestId/reassign', authMiddleware.verifyAdmin, requestController.reassignRequest);
router.patch('/:id/status', authMiddleware.verifyAdmin, requestController.updateRequestStatus);
router.delete('/:id', authMiddleware.verifyAdmin, requestController.deleteRequest);

module.exports = router;
