const Request = require('../models/Request');
const Pharmacy = require('../models/Pharmacy');
const User = require('../models/User');
const { sendNotification } = require('../utils/notificationService');
const { uploadToS3 } = require('../utils/s3Service');

// Get all requests (Admin only)
exports.getAllRequests = async (req, res) => {
  try {
    const { status, region, ville, startDate, endDate } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (region) filter.region = region;
    if (ville) filter.ville = ville;
    if (startDate || endDate) {
      filter.date_creation = {};
      if (startDate) filter.date_creation.$gte = new Date(startDate);
      if (endDate) filter.date_creation.$lte = new Date(endDate);
    }

    const requests = await Request.find(filter)
      .populate('client_id', 'nom prenom telephone')
      .populate('pharmacies_ids', 'nom region ville')
      .populate('region', 'name')
      .populate('ville', 'name')
      .sort({ date_creation: -1 });

    res.status(200).json(requests);
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Get requests for a pharmacy
exports.getRequestsForPharmacy = async (req, res) => {
  try {
    const requests = await Request.find({
      pharmacies_ids: { $ne: req.user._id },
      status: "pending",
      $or: [{ ville: req.user.ville }, { region: req.user.region }],
    })
      .populate('client_id', 'nom prenom telephone')
      .populate('region', 'name')
      .populate('ville', 'name')
      .sort({ date_creation: -1 });

    res.status(200).json(requests);
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Create a new request (Client only)
exports.createRequest = async (req, res) => {
  try {
    const { medicaments, zone, ville, region } = req.body;
    let ordonnance_url = null;

    // Handle ordonnance upload to S3
    if (req.file) {
      ordonnance_url = await uploadToS3(req.file);
    }

    if (!medicaments && !ordonnance_url) {
      return res.status(400).json({
        message: "Les médicaments ou l'ordonnance sont requis."
      });
    }

    const newRequest = new Request({
      client_id: req.user._id,
      medicaments,
      ordonnance_url,
      zone,
      ville,
      region,
    });

    await newRequest.save();

    // Notify eligible pharmacies
    const pharmacies = await Pharmacy.find({
      actif: true,
      ...(zone === 'ville' && { ville }),
      ...(zone === 'region' && { region }),
    });

    pharmacies.forEach((pharmacy) => {
      sendNotification({
        to: pharmacy.fcm_token,
        title: "Nouvelle Demande",
        body: `Une nouvelle demande est disponible dans votre zone.`,
        data: { requestId: newRequest._id },
      });
    });

    res.status(201).json({ message: "Demande créée avec succès.", newRequest });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Accept a request (Pharmacy only)
exports.acceptRequest = async (req, res) => {
  try {
    const { requestId } = req.params;

    const request = await Request.findById(requestId);
    if (!request || request.status !== "pending") {
      return res.status(400).json({ message: "Demande non disponible." });
    }

    // Define expiration time based on the zone
    let expirationDuration;
    if (request.zone === "ville" || request.zone === "region") {
      expirationDuration = 2 * 60 * 60 * 1000; // 2 hours for local and regional requests
    } else if (request.zone === "nationale") {
      expirationDuration = 24 * 60 * 60 * 1000; // 24 hours for national requests
    }

    // Update the request
    request.status = "in-progress";
    request.pharmacies_ids = [req.user._id];
    request.date_acceptation = new Date();
    request.date_expiration = new Date(Date.now() + expirationDuration); // Set expiration time

    await request.save();

    // Notify the client about acceptance
    const client = await User.findById(request.client_id);
    if (client?.fcm_token) {
      sendNotification({
        to: client.fcm_token,
        title: "Demande Acceptée",
        body: `Votre demande a été acceptée par la pharmacie ${req.user.nom}.`,
        data: { requestId },
      });
    }

    res.status(200).json({ message: "Demande acceptée.", request });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Refuse a request (Pharmacy only)
exports.refuseRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const request = await Request.findById(requestId);

    if (!request || request.status !== "pending") {
      return res.status(400).json({ message: "Demande non disponible." });
    }

    request.pharmacies_ids = request.pharmacies_ids.filter(
      (id) => id.toString() !== req.user._id.toString()
    );

    await request.save();

    res.status(200).json({ message: "Demande refusée." });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Reassign a request (Admin only)
exports.reassignRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { pharmacies_ids } = req.body;

    const request = await Request.findById(requestId);
    if (!request) {
      return res.status(404).json({ message: "Demande non trouvée." });
    }

    request.pharmacies_ids = pharmacies_ids;
    request.status = "pending"; // Reset to pending for reassignment
    await request.save();

    res.status(200).json({ message: "Demande réassignée avec succès.", request });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Update request status (Admin only)
exports.updateRequestStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const request = await Request.findById(id);
    if (!request) {
      return res.status(404).json({ message: "Demande non trouvée." });
    }

    request.status = status;
    await request.save();

    res.status(200).json({ message: "Statut de la demande mis à jour.", request });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};

// Delete request (Admin only)
exports.deleteRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const request = await Request.findByIdAndDelete(id);
    if (!request) {
      return res.status(404).json({ message: "Demande non trouvée." });
    }

    res.status(200).json({ message: "Demande supprimée avec succès." });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur.", error: err.message });
  }
};
