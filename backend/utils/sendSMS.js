// utils/sendSMS.js
const twilio = require('twilio');
const dotenv = require('dotenv');
dotenv.config();

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

/**
 * Envoie un SMS via Twilio
 * @param {string} to   - Numéro destinataire (format +336..., +216..., etc.)
 * @param {string} body - Contenu du SMS
 */
async function sendSMS(to, body) {
  try {
    const message = await client.messages.create({
      to,
      from: process.env.TWILIO_PHONE_NUMBER, // votre numéro Twilio
      body
    });
    console.log('SMS envoyé :', message.sid);
  } catch (error) {
    console.error('Erreur envoi SMS:', error);
  }
}

module.exports = { sendSMS };
