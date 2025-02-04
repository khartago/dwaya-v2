const mongoose = require('mongoose');

const requestSchema = new mongoose.Schema({
  client_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  pharmacies_ids: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Pharmacy' }],
  medicaments: [
    {
      nom: { type: String, required: true },
      quantite: { type: Number, required: true },
      ordonnance: { type: Boolean, required: true }
    }
  ],
  ordonnance_url: { type: String }, // URL for uploaded prescription
  zone: { type: String, enum: ['ville', 'region', 'nationale'], required: true },
  ville: { type: mongoose.Schema.Types.ObjectId, ref: 'City' },
  region: { type: mongoose.Schema.Types.ObjectId, ref: 'Region' },
  status: {
    type: String,
    enum: ['pending', 'in-progress', 'completed', 'expired', 'refused'],
    default: 'pending'
  },
  historique: [
    {
      statut: { type: String },
      date: { type: Date, default: Date.now },
    }
  ],
  date_creation: { type: Date, default: Date.now },
  date_acceptation: { type: Date },
  date_expiration: { type: Date },
  date_retrait: { type: Date }
});

// Middleware to validate `medicaments` or `ordonnance_url`
requestSchema.pre('validate', function (next) {
  if (!this.medicaments || this.medicaments.length === 0) {
    if (!this.ordonnance_url) {
      return next(new Error("Les médicaments ou l'ordonnance sont requis."));
    }
  }
  next();
});

module.exports = mongoose.model('Request', requestSchema);
