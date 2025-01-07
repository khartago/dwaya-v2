const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = require('./config/db');
const subscriptionChecker = require('./cronJobs/subscriptionChecker');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const pharmacyRoutes = require('./routes/pharmacies');
const requestRoutes = require('./routes/requests');
const messageRoutes = require('./routes/messages');
const reclamationRoutes = require('./routes/reclamations');
const regionRoutes = require('./routes/regions');
const adminRoutes = require('./routes/admin'); // New admin routes

const User = require('./models/User');
const Pharmacy = require('./models/Pharmacy');
const jwt = require('jsonwebtoken');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Restrict in production
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"]
  }
});

// Security & parsing
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// Database connection
connectDB();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/pharmacies', pharmacyRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/reclamations', reclamationRoutes);
app.use('/api/regions', regionRoutes);
app.use('/api/admin', adminRoutes); // Added admin routes

// Handle 404
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée.' });
});

// Socket.IO authentication (optional)
io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  if (!token) {
    return next(new Error("Token manquant."));
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.user = decoded;

    let user;
    if (decoded.role === 'client' || decoded.role === 'admin') {
      user = await User.findById(decoded.id);
    } else if (decoded.role === 'pharmacie') {
      user = await Pharmacy.findById(decoded.id);
    }

    if (!user || !user.actif) {
      return next(new Error("Compte désactivé ou introuvable."));
    }

    next();
  } catch (err) {
    next(new Error("Token invalide."));
  }
});

// Socket.IO events
io.on('connection', (socket) => {
  console.log(`Nouvel utilisateur connecté : ${socket.user.id}`);

  socket.on('join_request', (requestId) => {
    socket.join(requestId);
    console.log(`Socket ${socket.user.id} rejoint la room ${requestId}`);
  });

  socket.on('leave_request', (requestId) => {
    socket.leave(requestId);
    console.log(`Socket ${socket.user.id} quitte la room ${requestId}`);
  });

  socket.on('new_message', async ({ requestId, message }) => {
    // Example: Save to DB and emit to others
    // ... 
    io.to(requestId).emit('message_received', {
      expediteur: socket.user.id,
      message
    });
  });

  socket.on('disconnect', () => {
    console.log(`Utilisateur déconnecté : ${socket.user.id}`);
  });
});

// Initialize CRON job with Socket.IO if needed
subscriptionChecker(io);

// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});
