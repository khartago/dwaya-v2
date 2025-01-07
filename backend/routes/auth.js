/**************************************
 * routes/auth.js
 *************************************/
const express = require('express');
const router = express.Router();

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');

const s3 = require('../config/s3');
const Region = require('../models/Region');
const City = require('../models/City');
const User = require('../models/User');

const { sendEmail } = require('../utils/sendEmail'); // <-- Pour envoyer un email (optionnel)
const { sendSMS } = require('../utils/sendSMS');     // <-- Pour envoyer un SMS (optionnel)

//-------------------------------------
// 1) Configuration Multer pour l’upload
//-------------------------------------
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB max
  fileFilter: (req, file, cb) => {
    // Autoriser JPEG, PNG, PDF
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
// 2) Schémas Joi
//-------------------------------------
const registerSchema = Joi.object({
  nom: Joi.string().required(),
  prenom: Joi.string().required(),
  telephone: Joi.string().required(),
  email: Joi.string().email().optional(),
  mot_de_passe: Joi.string().min(6).required(),
  region: Joi.string().required(),
  ville: Joi.string().required(),
  fcm_token: Joi.string().optional()
});

const loginSchema = Joi.object({
  telephone: Joi.string().required(),
  mot_de_passe: Joi.string().required(),
  fcm_token: Joi.string().optional()
});

// Pour la réinitialisation
const forgotSchema = Joi.object({
  email: Joi.string().email().optional(),
  telephone: Joi.string().optional()
}).xor('email', 'telephone'); // On exige un email OU un téléphone

const resetSchema = Joi.object({
  email: Joi.string().email().optional(),
  telephone: Joi.string().optional(),
  code: Joi.string().required(),
  new_password: Joi.string().min(6).required()
}).xor('email', 'telephone');

//-------------------------------------
// 3) Route POST /api/auth/register
//-------------------------------------
router.post('/register', upload.single('ordonnance'), async (req, res) => {
  // Validation
  const { error } = registerSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const {
    nom,
    prenom,
    telephone,
    email,
    mot_de_passe,
    region,
    ville,
    fcm_token
  } = req.body;

  try {
    // Vérifier si utilisateur existe déjà
    let existingUser = await User.findOne({ telephone });
    if (existingUser) {
      return res.status(400).json({ message: 'Téléphone déjà utilisé.' });
    }
    if (email) {
      const existingEmail = await User.findOne({ email });
      if (existingEmail) {
        return res.status(400).json({ message: 'Email déjà utilisé.' });
      }
    }

    // Vérifier la région et la ville
    const regionObj = await Region.findOne({ name: region });
    if (!regionObj) {
      return res.status(400).json({ message: 'Région invalide.' });
    }
    const cityObj = await City.findOne({ name: ville, region: regionObj._id });
    if (!cityObj) {
      return res.status(400).json({ message: 'Ville invalide.' });
    }

    // Gérer l'ordonnance (optionnel)
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

    // Création user
    const newUser = new User({
      nom,
      prenom,
      telephone,
      email,
      mot_de_passe,
      region: regionObj._id,
      ville: cityObj._id,
      fcm_token: fcm_token || null
    });

    // Hachage du mot de passe
    const salt = await bcrypt.genSalt(10);
    newUser.mot_de_passe = await bcrypt.hash(newUser.mot_de_passe, salt);
    await newUser.save();

    // Génération JWT
    const token = jwt.sign(
      { id: newUser._id, role: newUser.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    // Réponse
    return res.status(201).json({
      token,
      user: {
        id: newUser._id,
        nom: newUser.nom,
        prenom: newUser.prenom,
        telephone: newUser.telephone,
        email: newUser.email,
        fcm_token: newUser.fcm_token,
        ordonnanceUrl
      }
    });

  } catch (err) {
    console.error('Erreur inscription :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 4) Route POST /api/auth/login
//-------------------------------------
router.post('/login', async (req, res) => {
  const { error } = loginSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { telephone, mot_de_passe, fcm_token } = req.body;

  try {
    const user = await User.findOne({ telephone });
    if (!user) {
      return res.status(401).json({ message: 'Identifiants invalides.' });
    }

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!validPassword) {
      return res.status(401).json({ message: 'Identifiants invalides.' });
    }

    // Mettre à jour le fcm_token si fourni
    if (fcm_token) {
      user.fcm_token = fcm_token;
    }
    user.date_derniere_connexion = new Date();
    await user.save();

    // Générer le token
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    return res.status(200).json({
      token,
      user: {
        id: user._id,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        email: user.email,
        role: user.role,
        fcm_token: user.fcm_token
      }
    });

  } catch (err) {
    console.error('Erreur login :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 5) Route POST /api/auth/forgot-password
//-------------------------------------
router.post('/forgot-password', async (req, res) => {
  const { error } = forgotSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { email, telephone } = req.body;

  try {
    let user;
    if (email) {
      user = await User.findOne({ email });
    } else if (telephone) {
      user = await User.findOne({ telephone });
    }
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    // Générer un code (6 chiffres par ex.)
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    user.reset_code = resetCode;
    user.reset_code_expires = new Date(Date.now() + 15 * 60 * 1000); // +15 min
    await user.save();

    // Envoyer code par email ou SMS
    const msg = `Votre code de réinitialisation est : ${resetCode}`;
    if (email) {
      await sendEmail(email, 'Réinitialisation du mot de passe', msg);
    } else if (telephone) {
      await sendSMS(telephone, msg);
    }

    return res.status(200).json({ message: 'Code de réinitialisation envoyé.' });

  } catch (err) {
    console.error('Erreur forgot-password :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

//-------------------------------------
// 6) Route POST /api/auth/reset-password
//-------------------------------------
router.post('/reset-password', async (req, res) => {
  const { error } = resetSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  const { email, telephone, code, new_password } = req.body;

  try {
    let user;
    if (email) {
      user = await User.findOne({ email });
    } else if (telephone) {
      user = await User.findOne({ telephone });
    }
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    // Vérifier le code
    if (user.reset_code !== code) {
      return res.status(400).json({ message: 'Code invalide.' });
    }
    // Vérifier l’expiration
    if (!user.reset_code_expires || user.reset_code_expires < new Date()) {
      return res.status(400).json({ message: 'Code expiré.' });
    }

    // Mettre à jour le mot de passe
    const salt = await bcrypt.genSalt(10);
    user.mot_de_passe = await bcrypt.hash(new_password, salt);

    // Réinitialiser
    user.reset_code = null;
    user.reset_code_expires = null;
    await user.save();

    return res.status(200).json({ message: 'Mot de passe réinitialisé.' });

  } catch (err) {
    console.error('Erreur reset-password :', err);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
