const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  moyenne: { type: Number, default: 0 },
  count: { type: Number, default: 0 }
});

const abonnementSchema = new mongoose.Schema({
  plan: { type: String, enum: ["1 mois", "3 mois", "6 mois", "12 mois"], required: true },
  date_debut: { type: Date, required: true },
  date_fin: { type: Date, required: true },
  actif: { type: Boolean, default: true }
});

const pharmacySchema = new mongoose.Schema({
  nom: { type: String, required: true },
  region: { type: mongoose.Schema.Types.ObjectId, ref: 'Region', required: true },
  ville: { type: mongoose.Schema.Types.ObjectId, ref: 'City', required: true },
  adresse: { type: String, required: true },
  telephone: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  mot_de_passe: { type: String, required: true }, // Haché avec bcrypt
  abonnement: { type: abonnementSchema, required: true },
  lien_google_maps: { type: String, required: true },
  note: { type: noteSchema, default: () => ({}) },
  fcm_token: { type: String, default: null },
  actif: { type: Boolean, default: true },
  date_inscription: { type: Date, default: Date.now },
  date_derniere_connexion: { type: Date }
});

module.exports = mongoose.model('Pharmacy', pharmacySchema);
