/**************************************
 * routes/requests.js
 *************************************/
const express = require('express');
const router = express.Router();

const multer = require('multer');
const Joi = require('joi');
const { v4: uuidv4 } = require('uuid');
const moment = require('moment');

const auth = require('../middlewares/auth');
const s3 = require('../config/s3');

const Request = require('../models/Request');
const Region = require('../models/Region');
const City = require('../models/City');
const Pharmacy = require('../models/Pharmacy');
const User = require('../models/User');

const { sendNotification } = require('../utils/sendNotification');

//-------------------------------------
// Configuration Multer pour l’ordonnance
//-------------------------------------
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (req, file, cb) => {
    if (
      file.mimetype === 'image/jpeg' ||
      file.mimetype === 'image/png' ||
      file.mimetype === 'application/pdf'
    ) {
      cb(null, true);
    } else {
      cb(new Error('Type de fichier non supporté'), false);
    }
  }
});

//-------------------------------------
// Schéma Joi pour la création de demande
//-------------------------------------
const requestSchema = Joi.object({
  medicaments: Joi.array().items(
    Joi.object({
      nom: Joi.string().required(),
      quantite: Joi.number().integer().min(1).required(),
      ordonnance: Joi.boolean().required()
    })
  ).optional(),
  zone: Joi.string().valid('ville', 'region', 'nationale').required(),
  ville: Joi.string().when('zone', { is: 'ville', then: Joi.required() }),
  region: Joi.string().when('zone', { is: 'region', then: Joi.required() })
});

//-------------------------------------
// POST /api/requests
// Création d’une demande (Client)
//-------------------------------------
router.post('/', auth, upload.single('ordonnance'), async (req, res) => {
  if (req.user.role !== 'client') {
    return res.status(403).json({ message: 'Accès réservé aux clients.' });
  }

  // 1) Validation des champs
  const { error } = requestSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { medicaments, zone, ville, region } = req.body;
  const clientId = req.user.id;

  try {
    // 2) Vérifier et charger la région/ville
    let regionObj = null;
    let cityObj = null;

    if (zone === 'ville') {
      regionObj = await Region.findOne({ name: region });
      if (!regionObj) {
        return res.status(400).json({ message: 'Région invalide.' });
      }
      cityObj = await City.findOne({ name: ville, region: regionObj._id });
      if (!cityObj) {
        return res.status(400).json({ message: 'Ville invalide.' });
      }
    } else if (zone === 'region') {
      regionObj = await Region.findOne({ name: region });
      if (!regionObj) {
        return res.status(400).json({ message: 'Région invalide.' });
      }
    }

    // 3) Upload d’ordonnance si présente
    let ordonnanceUrl = null;
    if (req.file) {
      const params = {
        Bucket: process.env.AWS_S3_BUCKET_NAME,
        Key: `ordonnances/${uuidv4()}-${req.file.originalname}`,
        Body: req.file.buffer,
        ContentType: req.file.mimetype,
        ACL: 'private'
      };
      const uploadResult = await s3.upload(params).promise();
      ordonnanceUrl = uploadResult.Location;
    }

    // 4) Créer la demande
    const newRequest = new Request({
      client_id: clientId,
      medicaments: medicaments || [],
      zone,
      ville: cityObj ? cityObj._id : null,
      region: regionObj ? regionObj._id : null,
      ordonnance_url: ordonnanceUrl
    });
    await newRequest.save();

    // 5) Récupérer les pharmacies concernées
    let relevantPharmacies = [];
    if (zone === 'ville' && regionObj && cityObj) {
      relevantPharmacies = await Pharmacy.find({
        region: regionObj._id,
        ville: cityObj._id,
        'abonnement.actif': true
      });
    } else if (zone === 'region' && regionObj) {
      relevantPharmacies = await Pharmacy.find({
        region: regionObj._id,
        'abonnement.actif': true
      });
    } else {
      // zone = 'nationale'
      relevantPharmacies = await Pharmacy.find({ 'abonnement.actif': true });
    }

    // 6) Notifier les pharmacies (si elles ont un fcm_token)
    for (const pharmacy of relevantPharmacies) {
      if (pharmacy.fcm_token) {
        await sendNotification(
          pharmacy.fcm_token,
          'Nouvelle Demande',
          `Un client a créé une demande de médicaments`,
          { requestId: newRequest._id.toString() }
        );
      }
    }

    // 7) Mettre à jour la demande avec la liste des pharmacies
    newRequest.pharmacies_ids = relevantPharmacies.map(ph => ph._id);
    await newRequest.save();

    // 8) Réponse finale
    return res.status(201).json({ message: 'Demande créée avec succès.', request: newRequest });

  } catch (err) {
    console.error('Erreur création demande :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// PATCH /api/requests/:id/status
// Acceptation ou Refus d’une demande (Pharmacie)
//-------------------------------------
router.patch('/:id/status', auth, async (req, res) => {
  if (req.user.role !== 'pharmacie') {
    return res.status(403).json({ message: 'Accès réservé aux pharmacies.' });
  }

  const { id } = req.params;
  const { status } = req.body; // in-progress ou refused

  try {
    const request = await Request.findById(id).populate('client_id');
    if (!request) {
      return res.status(404).json({ message: 'Demande introuvable.' });
    }

    // Vérifier que la pharmacie est autorisée
    if (!request.pharmacies_ids.includes(req.user.id)) {
      return res.status(403).json({ message: 'Demande non associée à cette pharmacie.' });
    }

    if (!['in-progress', 'refused'].includes(status)) {
      return res.status(400).json({ message: 'Status invalide. (in-progress ou refused)' });
    }

    // Mettre à jour la demande
    request.status = status;
    if (status === 'in-progress') {
      request.date_acceptation = new Date();
      // Vous pouvez définir une date_expiration si besoin
      // request.date_expiration = moment().add(24, 'hours').toDate();
    }
    await request.save();

    // Notifier le client
    const client = request.client_id; // déjà populé
    if (client && client.fcm_token) {
      let notifBody = 'Votre demande a été prise en charge.';
      if (status === 'refused') {
        notifBody = 'Votre demande a été refusée par la pharmacie.';
      }

      await sendNotification(
        client.fcm_token,
        'Mise à jour de votre demande',
        notifBody,
        { requestId: request._id.toString() }
      );
    }

    return res.status(200).json({ message: `Demande ${status}`, request });

  } catch (err) {
    console.error('Erreur lors de la mise à jour du statut :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// PATCH /api/requests/:id/complete
// Clôturer une demande (Pharmacie)
//-------------------------------------
router.patch('/:id/complete', auth, async (req, res) => {
  if (req.user.role !== 'pharmacie') {
    return res.status(403).json({ message: 'Accès réservé aux pharmacies.' });
  }

  const { id } = req.params;

  try {
    const request = await Request.findById(id).populate('client_id');
    if (!request) {
      return res.status(404).json({ message: 'Demande introuvable.' });
    }

    if (!request.pharmacies_ids.includes(req.user.id)) {
      return res.status(403).json({ message: 'Demande non associée à cette pharmacie.' });
    }

    if (request.status !== 'in-progress') {
      return res.status(400).json({ message: 'La demande n’est pas en cours.' });
    }

    // Passage en "completed"
    request.status = 'completed';
    request.date_retrait = new Date();
    await request.save();

    // Notifier le client
    const client = request.client_id;
    if (client && client.fcm_token) {
      await sendNotification(
        client.fcm_token,
        'Demande clôturée',
        'Votre demande a été clôturée par la pharmacie.',
        { requestId: request._id.toString() }
      );
    }

    return res.status(200).json({ message: 'Demande clôturée avec succès.', request });
  } catch (err) {
    console.error('Erreur clôture demande :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
