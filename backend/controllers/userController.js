const User = require('../models/User');
const bcrypt = require('bcryptjs');
const Region = require('../models/Region');
const City = require('../models/City');

// Get all users with filters
exports.getAllUsers = async (req, res) => {
  try {
    const { nom, region, ville, actif } = req.query;
    const filters = {};

    if (nom) filters.nom = new RegExp(nom, 'i');
    if (region) filters.region = region;
    if (ville) filters.ville = ville;
    if (actif !== undefined) filters.actif = actif === 'true';

    const users = await User.find(filters)
      .populate('region', 'name')
      .populate('ville', 'name');

    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors du chargement des utilisateurs.', error });
  }
};

// Get a single user's details
exports.getUserDetails = async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('region', 'name')
      .populate('ville', 'name');

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors du chargement des détails de l’utilisateur.', error });
  }
};

// Update a user's details
exports.updateUserDetails = async (req, res) => {
  try {
    const updates = req.body;

    // If updating password, hash it
    if (updates.mot_de_passe) {
      const salt = await bcrypt.genSalt(10);
      updates.mot_de_passe = await bcrypt.hash(updates.mot_de_passe, salt);
    }

    const user = await User.findByIdAndUpdate(req.params.id, updates, {
      new: true,
    });

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour de l’utilisateur.', error });
  }
};

// Toggle user active status
exports.toggleUserStatus = async (req, res) => {
  try {
    const { actif } = req.body;

    if (typeof actif !== 'boolean') {
      return res.status(400).json({ message: 'Valeur invalide pour actif.' });
    }

    const user = await User.findByIdAndUpdate(req.params.id, { actif }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    res.json({ message: `Utilisateur ${actif ? 'activé' : 'désactivé'}.`, user });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors du changement de statut de l’utilisateur.', error });
  }
};
