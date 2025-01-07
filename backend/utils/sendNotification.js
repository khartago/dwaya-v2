// utils/sendNotification.js
const admin = require('../config/firebaseAdmin');

/**
 * Envoie une notification Push via Firebase Cloud Messaging.
 * 
 * @param {string} fcmToken   - Le token du device (Android/iOS/web).
 * @param {string} title      - Titre de la notification.
 * @param {string} body       - Corps de la notification.
 * @param {object} data       - Données additionnelles (optionnel).
 */
async function sendNotification(fcmToken, title, body, data = {}) {
  if (!fcmToken) return;

  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      ...data
    },
    token: fcmToken
  };

  try {
    await admin.messaging().send(message);
    console.log('Notification envoyée avec succès');
  } catch (error) {
    console.error('Erreur envoi notification FCM :', error);
  }
}

module.exports = { sendNotification };
