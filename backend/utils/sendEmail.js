// utils/sendEmail.js
const nodemailer = require('nodemailer');
const dotenv = require('dotenv');
dotenv.config();

async function sendEmail(to, subject, text) {
  // Créer un transport SMTP
  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT, 10),
    secure: process.env.EMAIL_SECURE === 'true', // true si SSL
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: process.env.EMAIL_USER, // l'expéditeur (email)
    to: to,                       // destinataire
    subject: subject,
    text: text
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email envoyé à ${to}`);
  } catch (error) {
    console.error('Erreur envoi email:', error);
  }
}

module.exports = { sendEmail };
