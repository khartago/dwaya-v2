const express = require('express');
const router = express.Router();
const Region = require('../models/Region');
const City = require('../models/City');

// Récupération de toutes les régions (GET /api/regions)
router.get('/', async (req, res) => {
  try {
    const regions = await Region.find().sort({ name: 1 });
    res.status(200).json(regions);
  } catch (err) {
    console.error('Erreur récupération régions :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// Récupération des villes d'une région (GET /api/regions/:regionId/cities)
router.get('/:regionId/cities', async (req, res) => {
  const { regionId } = req.params;
  try {
    const cities = await City.find({ region: regionId }).sort({ name: 1 });
    res.status(200).json(cities);
  } catch (err) {
    console.error('Erreur récupération villes :', err);
    res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
