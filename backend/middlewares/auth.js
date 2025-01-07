const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pharmacy = require('../models/Pharmacy');

exports.verifyToken = async (req, res, next) => {
  const token = req.header('Authorization');
  if (!token) return res.status(401).json({ message: 'Accès refusé. Pas de token.' });

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(400).json({ message: 'Token invalide.' });
  }
};

exports.verifyAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (user && user.role === 'admin') {
      next();
    } else {
      res.status(403).json({ message: 'Accès interdit. Admin requis.' });
    }
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};

exports.verifyClient = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (user && user.role === 'client') {
      next();
    } else {
      res.status(403).json({ message: 'Accès interdit. Client requis.' });
    }
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};

exports.verifyPharmacy = async (req, res, next) => {
  try {
    const pharmacy = await Pharmacy.findById(req.user._id);
    if (pharmacy && pharmacy.actif) {
      next();
    } else {
      res.status(403).json({ message: 'Accès interdit. Pharmacie requise.' });
    }
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};
