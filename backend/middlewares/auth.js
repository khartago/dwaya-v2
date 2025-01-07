const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const User = require('../models/User');
const Pharmacy = require('../models/Pharmacy');

dotenv.config();

module.exports = async function (req, res, next) {
  const authHeader = req.header('Authorization');
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ message: 'Accès refusé. Token manquant.' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    let user;
    if (req.user.role === 'client' || req.user.role === 'admin') {
      user = await User.findById(req.user.id);
    } else if (req.user.role === 'pharmacie') {
      user = await Pharmacy.findById(req.user.id);
    }

    if (!user || !user.actif) {
      return res.status(403).json({ message: 'Compte désactivé ou introuvable.' });
    }

    next();
  } catch (ex) {
    res.status(400).json({ message: 'Token invalide.' });
  }
};
