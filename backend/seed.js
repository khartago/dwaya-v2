const mongoose = require('mongoose');
const Region = require('./models/Region');
const City = require('./models/City');
const dotenv = require('dotenv');

dotenv.config();

const regionsData = [
  {
    name: 'Tunis',
    cities: ['Tunis', 'Ariana', 'Manouba', 'Ben Arous']
  },
  {
    name: 'Ben Arous',
    cities: ['Ben Arous', 'Radès', 'La Goulette', 'Ezzahra']
  },
  {
    name: 'Bizerte',
    cities: ['Bizerte', 'Menzel Bourguiba', 'Mateur', 'Sejnane']
  },
  // ... Ajoutez toutes les régions/villes
  // Veillez à avoir les 24 gouvernorats de Tunisie
];

async function seedDatabase() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('Connecté à MongoDB pour le seeding.');

    // Vider les collections
    await Region.deleteMany({});
    await City.deleteMany({});
    console.log('Collections Region et City nettoyées.');

    for (const regionData of regionsData) {
      const region = new Region({ name: regionData.name });
      await region.save();

      for (const cityName of regionData.cities) {
        const city = new City({
          name: cityName,
          region: region._id
        });
        await city.save();
      }
    }

    console.log('Données régionales peuplées avec succès.');
    mongoose.disconnect();
  } catch (err) {
    console.error('Erreur seeding :', err);
    mongoose.disconnect();
  }
}

seedDatabase();
