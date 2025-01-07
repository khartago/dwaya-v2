/**************************************
 * routes/pharmacies.js
 *************************************/
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const Joi = require('joi');
const moment = require('moment');

const auth = require('../middlewares/auth');
const Region = require('../models/Region');
const City = require('../models/City');
const Pharmacy = require('../models/Pharmacy');

const { sendEmail } = require('../utils/sendEmail'); 
const { sendSMS } = require('../utils/sendSMS');

//-------------------------------------
// 1) Schémas Joi
//-------------------------------------
const createPharmacySchema = Joi.object({
  nom: Joi.string().required(),
  telephone: Joi.string().required(),
  email: Joi.string().email().required(),
  mot_de_passe: Joi.string().min(6).required(),
  region: Joi.string().required(),
  ville: Joi.string().required(),
  adresse: Joi.string().required(),
  abonnement: Joi.object({
    plan: Joi.string().valid('1 mois', '3 mois', '6 mois', '12 mois').required(),
    date_debut: Joi.date().required(),
    date_fin: Joi.date().required(),
    actif: Joi.boolean().required()
  }).required(),
  lien_google_maps: Joi.string().uri().required(),
  fcm_token: Joi.string().optional()
});

const extendSubscriptionSchema = Joi.object({
  plan: Joi.string().valid('1 mois', '3 mois', '6 mois', '12 mois').required()
});

// Pour la connexion spécifique d’une pharmacie (optionnel)
const pharmacyLoginSchema = Joi.object({
  telephone: Joi.string().required(),
  mot_de_passe: Joi.string().required(),
  fcm_token: Joi.string().optional()
});

// Pour le forgot/reset password côté pharmacies
const forgotPharmacySchema = Joi.object({
  email: Joi.string().email().optional(),
  telephone: Joi.string().optional()
}).xor('email', 'telephone');

const resetPharmacySchema = Joi.object({
  email: Joi.string().email().optional(),
  telephone: Joi.string().optional(),
  code: Joi.string().required(),
  new_password: Joi.string().min(6).required()
}).xor('email', 'telephone');

//-------------------------------------
// 2) Route POST /api/pharmacies
//    Création d’une pharmacie (Admin)
//-------------------------------------
router.post('/', auth, async (req, res) => {
  // Seul un admin peut créer une pharmacie
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès refusé. (Admin seulement)' });
  }

  const { error } = createPharmacySchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const {
    nom,
    telephone,
    email,
    mot_de_passe,
    region,
    ville,
    adresse,
    abonnement,
    lien_google_maps,
    fcm_token
  } = req.body;

  try {
    // Vérifier l’unicité
    let existingPharmacy = await Pharmacy.findOne({ telephone });
    if (existingPharmacy) {
      return res.status(400).json({ message: 'Téléphone déjà utilisé.' });
    }
    existingPharmacy = await Pharmacy.findOne({ email });
    if (existingPharmacy) {
      return res.status(400).json({ message: 'Email déjà utilisé.' });
    }

    // Vérifier région/ville
    const regionObj = await Region.findOne({ name: region });
    if (!regionObj) {
      return res.status(400).json({ message: 'Région invalide.' });
    }
    const cityObj = await City.findOne({ name: ville, region: regionObj._id });
    if (!cityObj) {
      return res.status(400).json({ message: 'Ville invalide.' });
    }

    // Créer la pharmacie
    const newPharmacy = new Pharmacy({
      nom,
      telephone,
      email,
      mot_de_passe,
      region: regionObj._id,
      ville: cityObj._id,
      adresse,
      abonnement,
      lien_google_maps,
      fcm_token: fcm_token || null
    });

    // Hash du mot de passe
    const salt = await bcrypt.genSalt(10);
    newPharmacy.mot_de_passe = await bcrypt.hash(newPharmacy.mot_de_passe, salt);

    await newPharmacy.save();

    return res.status(201).json({
      message: 'Pharmacie créée avec succès.',
      pharmacy: newPharmacy
    });

  } catch (err) {
    console.error('Erreur création pharmacie :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 3) (Optionnel) POST /api/pharmacies/login
//    Connexion d’une pharmacie
//-------------------------------------
router.post('/login', async (req, res) => {
  const { error } = pharmacyLoginSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { telephone, mot_de_passe, fcm_token } = req.body;
  try {
    const pharmacy = await Pharmacy.findOne({ telephone });
    if (!pharmacy) {
      return res.status(401).json({ message: 'Identifiants invalides.' });
    }

    const validPassword = await bcrypt.compare(mot_de_passe, pharmacy.mot_de_passe);
    if (!validPassword) {
      return res.status(401).json({ message: 'Identifiants invalides.' });
    }

    // Mettre à jour fcm_token si fourni
    if (fcm_token) {
      pharmacy.fcm_token = fcm_token;
    }
    pharmacy.date_derniere_connexion = new Date();
    await pharmacy.save();

    // Générer un token JWT
    const jwt = require('jsonwebtoken');
    const token = jwt.sign(
      { id: pharmacy._id, role: 'pharmacie' },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    return res.status(200).json({
      token,
      pharmacy: {
        id: pharmacy._id,
        nom: pharmacy.nom,
        telephone: pharmacy.telephone,
        email: pharmacy.email,
        fcm_token: pharmacy.fcm_token
      }
    });

  } catch (err) {
    console.error('Erreur login pharmacie :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 4) GET /api/pharmacies
//    Récupération (admin ou la pharmacie elle-même)
//-------------------------------------
router.get('/', auth, async (req, res) => {
  try {
    const { region, ville, actif } = req.query;
    const filter = {};

    // Si c’est une pharmacie, elle ne voit que ses infos
    if (req.user.role === 'pharmacie') {
      filter._id = req.user.id;
    }

    if (region) {
      const regionObj = await Region.findOne({ name: region });
      if (regionObj) {
        filter.region = regionObj._id;
      }
    }
    if (ville) {
      const cityObj = await City.findOne({ name: ville });
      if (cityObj) {
        filter.ville = cityObj._id;
      }
    }
    if (actif !== undefined) {
      filter['abonnement.actif'] = actif === 'true';
    }

    const pharmacies = await Pharmacy.find(filter)
      .populate('region', 'name')
      .populate('ville', 'name')
      .sort({ nom: 1 });

    return res.status(200).json(pharmacies);

  } catch (err) {
    console.error('Erreur récupération pharmacies :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 5) PATCH /api/pharmacies/:id/extend
//    Extension d’abonnement (admin)
//-------------------------------------
router.patch('/:id/extend', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès refusé (admin seulement).' });
  }

  const { error } = extendSubscriptionSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { plan } = req.body;
  const durationMonths = parseInt(plan.split(' ')[0]); // ex. "3 mois" => 3

  try {
    const pharmacy = await Pharmacy.findById(req.params.id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    if (!pharmacy.abonnement.actif) {
      // Réactiver
      pharmacy.abonnement.actif = true;
      pharmacy.abonnement.date_debut = new Date();
      pharmacy.abonnement.date_fin = moment(pharmacy.abonnement.date_debut)
        .add(durationMonths, 'months')
        .toDate();
    } else {
      // Étendre
      pharmacy.abonnement.date_fin = moment(pharmacy.abonnement.date_fin)
        .add(durationMonths, 'months')
        .toDate();
    }

    pharmacy.abonnement.plan = plan;
    await pharmacy.save();

    return res.status(200).json({
      message: 'Abonnement mis à jour.',
      abonnement: pharmacy.abonnement
    });

  } catch (err) {
    console.error('Erreur extension abonnement :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 6) PATCH /api/pharmacies/:id/status
//    Désactivation ou activation (admin)
//-------------------------------------
router.patch('/:id/status', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Accès refusé (admin seulement).' });
  }

  const { actif } = req.body; // Boolean

  try {
    const pharmacy = await Pharmacy.findById(req.params.id);
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    pharmacy.actif = !!actif; 
    // NB: si vous voulez lier actif et abonnement.actif, faites-le ici

    await pharmacy.save();

    return res.status(200).json({ message: 'Statut mis à jour.', pharmacy });
  } catch (err) {
    console.error('Erreur maj statut :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 7) (Optionnel) POST /api/pharmacies/forgot-password
//-------------------------------------
router.post('/forgot-password', async (req, res) => {
  const { error } = forgotPharmacySchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { email, telephone } = req.body;
  try {
    let pharmacy;
    if (email) {
      pharmacy = await Pharmacy.findOne({ email });
    } else if (telephone) {
      pharmacy = await Pharmacy.findOne({ telephone });
    }
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    // Génération code
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    pharmacy.reset_code = resetCode;
    pharmacy.reset_code_expires = new Date(Date.now() + 15 * 60 * 1000); // +15 min
    await pharmacy.save();

    const msg = `Votre code de réinitialisation (Pharmacie) : ${resetCode}`;
    if (email) {
      await sendEmail(email, 'Réinitialisation mot de passe (Pharmacie)', msg);
    } else if (telephone) {
      await sendSMS(telephone, msg);
    }

    return res.status(200).json({ message: 'Code de réinitialisation envoyé.' });

  } catch (err) {
    console.error('Erreur forgot-password pharma :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 8) (Optionnel) POST /api/pharmacies/reset-password
//-------------------------------------
router.post('/reset-password', async (req, res) => {
  const { error } = resetPharmacySchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { email, telephone, code, new_password } = req.body;

  try {
    let pharmacy;
    if (email) {
      pharmacy = await Pharmacy.findOne({ email });
    } else if (telephone) {
      pharmacy = await Pharmacy.findOne({ telephone });
    }
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacie introuvable.' });
    }

    if (pharmacy.reset_code !== code) {
      return res.status(400).json({ message: 'Code invalide.' });
    }
    if (!pharmacy.reset_code_expires || pharmacy.reset_code_expires < new Date()) {
      return res.status(400).json({ message: 'Code expiré.' });
    }

    const salt = await bcrypt.genSalt(10);
    pharmacy.mot_de_passe = await bcrypt.hash(new_password, salt);

    pharmacy.reset_code = null;
    pharmacy.reset_code_expires = null;
    await pharmacy.save();

    return res.status(200).json({ message: 'Mot de passe réinitialisé (pharmacie).' });

  } catch (err) {
    console.error('Erreur reset-password pharma :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
