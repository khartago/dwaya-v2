const User = require('../models/User');
const Pharmacy = require('../models/Pharmacy');
const Request = require('../models/Request');

exports.getDashboardStats = async (req, res) => {
  try {
    const totalClients = await User.countDocuments({ role: 'client' });
    const totalPharmacies = await Pharmacy.countDocuments();
    const activePharmacies = await Pharmacy.countDocuments({ 'abonnement.actif': true });
    const inactivePharmacies = totalPharmacies - activePharmacies;

    const activeRequests = await Request.countDocuments({ status: { $in: ['pending', 'in-progress'] } });
    const completedRequests = await Request.countDocuments({ status: 'completed' });
    const refusedExpiredRequests = await Request.countDocuments({ status: { $in: ['refused', 'expired'] } });

    res.status(200).json({
      totalClients,
      totalPharmacies,
      activePharmacies,
      inactivePharmacies,
      activeRequests,
      completedRequests,
      refusedExpiredRequests,
    });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};

exports.getClients = async (req, res) => {
  try {
    const clients = await User.find({ role: 'client' });
    res.status(200).json(clients);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};

exports.getPharmacies = async (req, res) => {
  try {
    const pharmacies = await Pharmacy.find();
    res.status(200).json(pharmacies);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};

exports.getRequests = async (req, res) => {
  try {
    const requests = await Request.find();
    res.status(200).json(requests);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
};
