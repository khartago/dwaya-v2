const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('MongoDB connecté avec succès');
  } catch (err) {
    console.error('Erreur de connexion à MongoDB :', err);
    process.exit(1); // Arrêter le processus si la BD n'est pas joignable
  }
}

module.exports = connectDB;
