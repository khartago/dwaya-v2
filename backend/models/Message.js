const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  request_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Request', required: true },
  expediteur_id: { type: mongoose.Schema.Types.ObjectId, required: true },
  expediteur_model: { type: String, enum: ['User', 'Pharmacy'], required: true },
  destinataire_id: { type: mongoose.Schema.Types.ObjectId, required: true },
  destinataire_model: { type: String, enum: ['User', 'Pharmacy'], required: true },
  message: { type: String, required: true },
  date_envoi: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Message', messageSchema);
