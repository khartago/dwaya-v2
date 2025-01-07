const express = require('express');
const router = express.Router();
const Joi = require('joi');
const auth = require('../middlewares/auth');

const Message = require('../models/Message');
const Request = require('../models/Request');

const messageSchema = Joi.object({
  request_id: Joi.string().required(),
  destinataire_id: Joi.string().required(),
  destinataire_model: Joi.string().valid('User', 'Pharmacy').required(),
  message: Joi.string().required()
});

// Envoi d'un message (POST /api/messages) 
// NB: En pratique, on utilisera plutôt Socket.IO pour du temps réel.
router.post('/', auth, async (req, res) => {
  const { error } = messageSchema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  const {
    request_id,
    destinataire_id,
    destinataire_model,
    message
  } = req.body;

  const expediteur_id = req.user.id;
  const expediteur_model = (req.user.role === 'pharmacie') ? 'Pharmacy' : 'User';

  try {
    const request = await Request.findById(request_id);
    if (!request) {
      return res.status(404).json({ message: 'Demande introuvable.' });
    }

    // Vérifier l'autorisation
    if (req.user.role === 'client') {
      if (request.client_id.toString() !== expediteur_id) {
        return res.status(403).json({ message: 'Cette demande ne vous appartient pas.' });
      }
    } else if (req.user.role === 'pharmacie') {
      if (!request.pharmacies_ids.includes(expediteur_id)) {
        return res.status(403).json({ message: 'Non associé à cette demande.' });
      }
    }

    const newMessage = new Message({
      request_id,
      expediteur_id,
      expediteur_model,
      destinataire_id,
      destinataire_model,
      message
    });

    await newMessage.save();

    // TODO: Émission Socket.IO => "new_message"

    res.status(201).json({ message: 'Message envoyé.', data: newMessage });
  } catch (err) {
    console.error('Erreur envoi message :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Récupération de l'historique de messages pour une demande
router.get('/:request_id', auth, async (req, res) => {
  const { request_id } = req.params;

  try {
    const request = await Request.findById(request_id);
    if (!request) return res.status(404).json({ message: 'Demande introuvable.' });

    // Vérifier autorisation
    if (req.user.role === 'client') {
      if (request.client_id.toString() !== req.user.id) {
        return res.status(403).json({ message: 'Demande ne vous appartient pas.' });
      }
    } else if (req.user.role === 'pharmacie') {
      if (!request.pharmacies_ids.includes(req.user.id)) {
        return res.status(403).json({ message: 'Non associé à cette demande.' });
      }
    }

    const messages = await Message.find({ request_id })
      .sort({ date_envoi: 1 });

    res.status(200).json(messages);
  } catch (error) {
    console.error('Erreur récupération messages :', error);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
