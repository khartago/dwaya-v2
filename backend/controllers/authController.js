// controllers/authController.js

const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
// const sendEmail = require('../utils/email'); // Décommentez si vous utilisez sendEmail

// Générer un JWT
const generateToken = (user) => {
  const payload = {
    user: {
      id: user.id,
      role: user.role,
    },
  };

  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
};

// INSCRIPTION
exports.register = async (req, res) => {
  const {
    nom,
    prenom,
    telephone,
    email,
    mot_de_passe,
    region,
    ville,
    adresse,
    lien_google_maps,
    abonnement,
    role, // Facultatif, par défaut 'client'
  } = req.body;

  try {
    // Vérifier si l'utilisateur existe déjà par téléphone ou email
    let user = await User.findOne({
      $or: [{ telephone }, { email }],
    });
    if (user) {
      return res
        .status(400)
        .json({ msg: 'Utilisateur déjà enregistré avec ce numéro de téléphone ou cet email' });
    }

    // Créer un nouvel utilisateur
    user = new User({
      nom,
      prenom,
      telephone,
      email,
      mot_de_passe,
      region,
      ville,
      adresse,
      lien_google_maps,
      abonnement,
      role, // Facultatif
    });

    await user.save();

    // Générer le JWT
    const token = generateToken(user);

    res.status(201).json({ token, role: user.role });
  } catch (err) {
    console.error(err.message);
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ msg: messages.join(', ') });
    }
    res.status(500).json({ msg: 'Erreur interne du serveur' });
  }
};

// CONNEXION
exports.login = async (req, res) => {
  const { telephone, mot_de_passe } = req.body;

  try {
    // Vérifier si l'utilisateur existe
    let user = await User.findOne({ telephone });
    if (!user) {
      return res.status(400).json({ msg: 'Identifiants invalides' });
    }

    // Vérifier le mot de passe
    const isMatch = await user.comparePassword(mot_de_passe);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Identifiants invalides' });
    }

    // Générer le JWT
    const token = generateToken(user);

    // Mettre à jour la date de dernière connexion
    user.date_derniere_connexion = Date.now();
    await user.save();

    res.json({ token, role: user.role });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Erreur interne du serveur' });
  }
};

// DEMANDE DE RÉINITIALISATION DE MOT DE PASSE
exports.forgotPassword = async (req, res) => {
  const { telephone } = req.body;

  try {
    const user = await User.findOne({ telephone });
    if (!user) {
      return res.status(400).json({ msg: 'Utilisateur non trouvé' });
    }

    // Générer un token de réinitialisation
    const resetToken = crypto.randomBytes(20).toString('hex');

    // Définir le token et son expiration sur l'utilisateur
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 15 * 60 * 1000; // 15 minutes
    await user.save();

    // Créer le lien de réinitialisation
    const resetUrl = `http://${req.headers.host}/reset-password/${resetToken}`;

    // Envoyer l'email de réinitialisation
    const message = `Vous avez demandé une réinitialisation de votre mot de passe.\n\n
Cliquez sur le lien suivant pour réinitialiser votre mot de passe:\n\n
${resetUrl}\n\n
Si vous n'avez pas fait cette demande, veuillez ignorer cet email.`;

    // Décommentez et configurez la fonction sendEmail si vous avez implémenté l'envoi d'email
    // await sendEmail(user.email, 'Réinitialisation de votre mot de passe', message);

    // Pour cet exemple, nous renvoyons simplement le token (à ne PAS faire en production)
    res.json({ resetToken });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Erreur interne du serveur' });
  }
};

// RÉINITIALISATION DU MOT DE PASSE
exports.resetPassword = async (req, res) => {
  const { token } = req.params;
  const { mot_de_passe } = req.body;

  try {
    // Trouver l'utilisateur avec le token et vérifier l'expiration
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ msg: 'Token invalide ou expiré' });
    }

    // Mettre à jour le mot de passe
    user.mot_de_passe = mot_de_passe;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    // Envoyer une confirmation par email
    const message = `Bonjour ${user.prenom},\n\nVotre mot de passe a été réinitialisé avec succès.\n\nSi vous n'avez pas effectué cette opération, veuillez contacter notre support immédiatement.`;

    // Décommentez et configurez la fonction sendEmail si vous avez implémenté l'envoi d'email
    // await sendEmail(user.email, 'Votre mot de passe a été réinitialisé', message);

    res.json({ msg: 'Mot de passe réinitialisé avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Erreur interne du serveur' });
  }
};

// ROUTE PROTÉGÉE EXEMPLE
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-mot_de_passe');
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Erreur interne du serveur');
  }
};
