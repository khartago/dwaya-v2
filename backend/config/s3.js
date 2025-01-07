const AWS = require('aws-sdk');
const dotenv = require('dotenv');

dotenv.config();

// Initialisation du client S3 avec vos credentials
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

module.exports = s3;
