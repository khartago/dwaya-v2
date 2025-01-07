const Pharmacy = require('../models/Pharmacy');
const bcrypt = require('bcryptjs');

// Create a new pharmacy
exports.addPharmacy = async (req, res) => {
  try {
    const {
      nom,
      region,
      ville,
      adresse,
      telephone,
      email,
      mot_de_passe,
      abonnement,
      lien_google_maps
    } = req.body;

    // Validate subscription fields
    if (!abonnement || !abonnement.plan || !abonnement.date_debut || !abonnement.date_fin) {
      return res.status(400).json({ message: 'Les détails de l’abonnement sont obligatoires.' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

    // Create a new pharmacy document
    const newPharmacy = new Pharmacy({
      nom,
      region,
      ville,
      adresse,
      telephone,
      email,
      mot_de_passe: hashedPassword,
      abonnement,
      lien_google_maps,
    });

    // Save to the database
    await newPharmacy.save();
    res.status(201).json({ message: 'Pharmacie créée avec succès.', pharmacy: newPharmacy });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de la création de la pharmacie.', error: err.message });
  }
};

// Update an existing pharmacy
exports.updatePharmacy = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    // If password is being updated, hash it
    if (updates.mot_de_passe) {
      updates.mot_de_passe = await bcrypt.hash(updates.mot_de_passe, 10);
    }

    // Update the pharmacy
    const updatedPharmacy = await Pharmacy.findByIdAndUpdate(id, updates, { new: true });
    if (!updatedPharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    res.status(200).json({ message: 'Pharmacie mise à jour avec succès.', pharmacy: updatedPharmacy });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour de la pharmacie.', error: err.message });
  }
};

// Extend subscription
exports.extendSubscription = async (req, res) => {
  try {
    const { id } = req.params;
    const { additionalMonths } = req.body;

    if (!additionalMonths || additionalMonths <= 0) {
      return res.status(400).json({ message: 'Le nombre de mois supplémentaires est invalide.' });
    }

    const pharmacy = await Pharmacy.findById(id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    const currentEndDate = pharmacy.abonnement.date_fin || new Date();
    pharmacy.abonnement.date_fin = new Date(currentEndDate.setMonth(currentEndDate.getMonth() + additionalMonths));
    pharmacy.abonnement.actif = true; // Ensure subscription is active after extension

    await pharmacy.save();
    res.status(200).json({ message: 'Abonnement prolongé avec succès.', pharmacy });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de la prolongation de l\'abonnement.', error: err.message });
  }
};
