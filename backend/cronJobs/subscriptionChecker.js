const cron = require('node-cron');
const Pharmacy = require('../models/Pharmacy');
const moment = require('moment');

/**
 * Vérifie chaque jour à minuit si l'abonnement d'une pharmacie est expiré
 * et désactive le compte si besoin.
 */
function subscriptionChecker(io) {
  // S’exécute tous les jours à minuit
  cron.schedule('0 0 * * *', async () => {
    try {
      const now = new Date();
      const expiredPharmacies = await Pharmacy.find({
        'abonnement.date_fin': { $lt: now },
        'abonnement.actif': true
      });

      for (const pharmacy of expiredPharmacies) {
        pharmacy.abonnement.actif = false;
        await pharmacy.save();
        console.log(`Pharmacie ${pharmacy.nom} désactivée (abonnement expiré).`);

        // Exemple: émettre un event Socket.IO (si nécessaire)
        if (io) {
          io.emit('subscription_expired', {
            pharmacyId: pharmacy._id,
            nom: pharmacy.nom
          });
        }
      }
    } catch (error) {
      console.error('Erreur dans subscriptionChecker:', error);
    }
  });
}

module.exports = subscriptionChecker;
