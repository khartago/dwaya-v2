const express = require('express');
const router = express.Router();
const Joi = require('joi');
const bcrypt = require('bcrypt');
const auth = require('../middlewares/auth');

const User = require('../models/User');
const Region = require('../models/Region');
const City = require('../models/City');

const updateSchema = Joi.object({
  nom: Joi.string().optional(),
  prenom: Joi.string().optional(),
  telephone: Joi.string().optional(),
  email: Joi.string().email().optional(),
  mot_de_passe: Joi.string().min(6).optional(),
  region: Joi.string().optional(),
  ville: Joi.string().optional(),
  actif: Joi.boolean().optional()
});

// Liste des clients (GET /api/users) - Admin only
router.get('/', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès refusé.' });
  }
  try {
    const users = await User.find({ role: 'client' })
      .populate('region', 'name')
      .populate('ville', 'name')
      .sort({ nom: 1 });

    res.status(200).json(users);
  } catch (error) {
    console.error('Erreur récupération utilisateurs :', error);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Mise à jour d'un utilisateur (PUT /api/users/:id) - Admin ou utilisateur lui-même
router.put('/:id', auth, async (req, res) => {
  const { id } = req.params;

  if (req.user.role !== 'admin' && req.user.id !== id) {
    return res.status(403).json({ message: 'Accès refusé.' });
  }

  const { error } = updateSchema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé.' });

    const {
      nom,
      prenom,
      telephone,
      email,
      mot_de_passe,
      region,
      ville,
      actif
    } = req.body;

    if (nom) user.nom = nom;
    if (prenom) user.prenom = prenom;
    if (telephone) user.telephone = telephone;
    if (email) user.email = email;
    if (mot_de_passe) {
      const salt = await bcrypt.genSalt(10);
      user.mot_de_passe = await bcrypt.hash(mot_de_passe, salt);
    }
    if (typeof actif === 'boolean' && req.user.role === 'admin') {
      user.actif = actif;
    }

    // Gestion région / ville
    if (region) {
      const regionObj = await Region.findOne({ name: region });
      if (!regionObj) {
        return res.status(400).json({ message: 'Région invalide.' });
      }
      user.region = regionObj._id;
      if (ville) {
        const cityObj = await City.findOne({
          name: ville,
          region: regionObj._id
        });
        if (!cityObj) {
          return res.status(400).json({ message: 'Ville invalide.' });
        }
        user.ville = cityObj._id;
      }
    }

    await user.save();

    res.status(200).json({ message: 'Utilisateur mis à jour.', user });
  } catch (err) {
    console.error('Erreur mise à jour user :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
