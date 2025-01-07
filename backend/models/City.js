const mongoose = require('mongoose');

const citySchema = new mongoose.Schema({
  name: { type: String, required: true },
  region: { type: mongoose.Schema.Types.ObjectId, ref: 'Region', required: true }
});

module.exports = mongoose.model('City', citySchema);
