const mongoose = require('mongoose');

const reclamationSchema = new mongoose.Schema({
  type: { type: String, enum: ["client", "pharmacie"], required: true },
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, refPath: 'utilisateur_model', required: true },
  utilisateur_model: { type: String, enum: ['User', 'Pharmacy'], required: true },
  sujet: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, enum: ["ouverte", "en cours", "résolue"], default: "ouverte" },
  date_creation: { type: Date, default: Date.now },
  date_resolution: { type: Date },
  reponse: { type: String } 
});

module.exports = mongoose.model('Reclamation', reclamationSchema);
