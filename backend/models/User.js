const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  moyenne: { type: Number, default: 0 },
  count: { type: Number, default: 0 }
});

const userSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  prenom: { type: String, required: true },
  telephone: { type: String, required: true, unique: true },
  email: { type: String, unique: true }, // Email facultatif pour les clients
  mot_de_passe: { type: String, required: true }, // Haché avec bcrypt
  role: { type: String, enum: ["client", "admin"], default: "client" },
  region: { type: mongoose.Schema.Types.ObjectId, ref: 'Region', required: true },
  ville: { type: mongoose.Schema.Types.ObjectId, ref: 'City', required: true },
  note: { type: noteSchema, default: () => ({}) },
  fcm_token: { type: String, default: null },
  // Champs pour la réinitialisation de mot de passe
  reset_code: { type: String, default: null },
  reset_code_expires: { type: Date, default: null },
  actif: { type: Boolean, default: true },
  date_inscription: { type: Date, default: Date.now },
  date_derniere_connexion: { type: Date }
});

module.exports = mongoose.model('User', userSchema);
