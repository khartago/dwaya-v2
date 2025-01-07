const express = require('express');
const router = express.Router();
const Joi = require('joi');
const auth = require('../middlewares/auth');

const Reclamation = require('../models/Reclamation');
const User = require('../models/User');
const Pharmacy = require('../models/Pharmacy');

const reclamationSchema = Joi.object({
  type: Joi.string().valid('client', 'pharmacie').required(),
  sujet: Joi.string().required(),
  description: Joi.string().required()
});

// Création réclamation (POST /api/reclamations)
router.post('/', auth, async (req, res) => {
  const { error } = reclamationSchema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  const { type, sujet, description } = req.body;

  try {
    let utilisateur;
    let utilisateur_model;

    if (req.user.role === 'client') {
      utilisateur = await User.findById(req.user.id);
      utilisateur_model = 'User';
    } else if (req.user.role === 'pharmacie') {
      utilisateur = await Pharmacy.findById(req.user.id);
      utilisateur_model = 'Pharmacy';
    } else {
      return res.status(400).json({ message: 'Seul client ou pharmacie peut créer une réclamation.' });
    }

    if (!utilisateur) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    const newReclamation = new Reclamation({
      type,
      utilisateur_id: req.user.id,
      utilisateur_model,
      sujet,
      description
    });

    await newReclamation.save();

    res.status(201).json({ message: 'Réclamation créée.', reclamation: newReclamation });
  } catch (err) {
    console.error('Erreur création réclamation :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Récupération (GET /api/reclamations) - Admin
router.get('/', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès réservé à l\'admin.' });
  }

  try {
    const { type, status } = req.query;
    const filter = {};
    if (type) filter.type = type;
    if (status) filter.status = status;

    const reclamations = await Reclamation.find(filter)
      .populate('utilisateur_id', 'nom prenom telephone email')
      .sort({ date_creation: -1 });

    res.status(200).json(reclamations);
  } catch (err) {
    console.error('Erreur récupération réclamations :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Mise à jour statut réclamation (PATCH /api/reclamations/:id/status) - Admin
router.patch('/:id/status', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès réservé à l\'admin.' });
  }

  const { id } = req.params;
  const { status } = req.body;

  if (!['ouverte', 'en cours', 'résolue'].includes(status)) {
    return res.status(400).json({ message: 'Status invalide.' });
  }

  try {
    const reclamation = await Reclamation.findById(id);
    if (!reclamation) {
      return res.status(404).json({ message: 'Réclamation introuvable.' });
    }

    reclamation.status = status;
    if (status === 'résolue') {
      reclamation.date_resolution = new Date();
    }
    await reclamation.save();

    res.status(200).json({ message: 'Statut mis à jour.', reclamation });
  } catch (err) {
    console.error('Erreur mise à jour réclamation :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Réponse admin (POST /api/reclamations/:id/reponse) - Admin
router.post('/:id/reponse', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès réservé à l\'admin.' });
  }

  const { id } = req.params;
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({ message: 'message est requis.' });
  }

  try {
    const reclamation = await Reclamation.findById(id);
    if (!reclamation) {
      return res.status(404).json({ message: 'Réclamation introuvable.' });
    }

    reclamation.reponse = message;
    if (reclamation.status !== 'résolue') {
      reclamation.status = 'en cours';
    }

    await reclamation.save();

    res.status(200).json({ message: 'Réponse ajoutée.', reclamation });
  } catch (err) {
    console.error('Erreur réponse réclamation :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
