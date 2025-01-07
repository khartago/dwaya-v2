// config/firebaseAdmin.js
const admin = require('firebase-admin');
const serviceAccount = require('../utils/dwaya-tn-firebase-adminsdk-bntd4-a2901f72fe.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

module.exports = admin;
