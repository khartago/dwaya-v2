const Pharmacy = require('../models/Pharmacy');
const bcrypt = require('bcryptjs');

// Get all pharmacies
exports.getPharmacies = async (req, res) => {
  try {
    const pharmacies = await Pharmacy.find()
      .populate('region', 'name')
      .populate('ville', 'name');
    res.status(200).json(pharmacies);
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Get a single pharmacy by ID
exports.getPharmacyById = async (req, res) => {
  try {
    const { id } = req.params;
    const pharmacy = await Pharmacy.findById(id)
      .populate('region', 'name')
      .populate('ville', 'name');
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found.' });
    }
    res.status(200).json(pharmacy);
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Create a new pharmacy
exports.createPharmacy = async (req, res) => {
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
      lien_google_maps,
    } = req.body;

    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

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

    await newPharmacy.save();
    res.status(201).json({ message: 'Pharmacy created successfully.', pharmacy: newPharmacy });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Update an existing pharmacy
exports.updatePharmacy = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nom,
      region,
      ville,
      adresse,
      telephone,
      email,
      abonnement,
      lien_google_maps,
    } = req.body;

    const pharmacy = await Pharmacy.findById(id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found.' });
    }

    pharmacy.nom = nom || pharmacy.nom;
    pharmacy.region = region || pharmacy.region;
    pharmacy.ville = ville || pharmacy.ville;
    pharmacy.adresse = adresse || pharmacy.adresse;
    pharmacy.telephone = telephone || pharmacy.telephone;
    pharmacy.email = email || pharmacy.email;
    pharmacy.abonnement = abonnement || pharmacy.abonnement;
    pharmacy.lien_google_maps = lien_google_maps || pharmacy.lien_google_maps;

    await pharmacy.save();
    res.status(200).json({ message: 'Pharmacy updated successfully.', pharmacy });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Delete a pharmacy
exports.deletePharmacy = async (req, res) => {
  try {
    const { id } = req.params;
    const pharmacy = await Pharmacy.findByIdAndDelete(id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found.' });
    }
    res.status(200).json({ message: 'Pharmacy deleted successfully.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Toggle pharmacy status
exports.togglePharmacyStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { actif } = req.body;

    if (typeof actif !== 'boolean') {
      return res.status(400).json({ message: 'Invalid status value.' });
    }

    const pharmacy = await Pharmacy.findById(id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found.' });
    }

    pharmacy.actif = actif;
    await pharmacy.save();

    res.status(200).json({
      message: `Pharmacy ${actif ? 'activated' : 'deactivated'} successfully.`,
      pharmacy,
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};

// Extend subscription duration
exports.extendSubscription = async (req, res) => {
  try {
    const { id } = req.params;
    const { additionalMonths } = req.body;

    if (!additionalMonths || additionalMonths <= 0) {
      return res.status(400).json({ message: 'Invalid subscription extension.' });
    }

    const pharmacy = await Pharmacy.findById(id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found.' });
    }

    const currentEndDate = pharmacy.abonnement.date_fin;
    pharmacy.abonnement.date_fin = new Date(currentEndDate.setMonth(currentEndDate.getMonth() + additionalMonths));
    await pharmacy.save();

    res.status(200).json({
      message: `Subscription extended by ${additionalMonths} month(s).`,
      pharmacy,
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};
