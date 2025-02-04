const axios = require('axios');

// Firebase Cloud Messaging (FCM) Implementation
exports.sendNotification = async ({ to, title, body, data }) => {
  try {
    const response = await axios.post(
      'https://fcm.googleapis.com/fcm/send',
      {
        to,
        notification: { title, body },
        data,
      },
      {
        headers: {
          Authorization: `key=${process.env.FCM_SERVER_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );
    console.log('Notification sent:', response.data);
  } catch (error) {
    console.error('Error sending notification:', error.response?.data || error.message);
  }
};
