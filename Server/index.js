require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./Routes/Authentication');
const jobRoutes = require('./Routes/Jobs');
const profileRoutes = require('./Routes/Profile');
const applicationRoutes = require('./Routes/Application');

const app = express();
app.use(cors());
app.use(express.json());

// Use authentication routes
app.use('/api/auth', authRoutes);
app.use('/api', jobRoutes);
app.use('/api', profileRoutes);
app.use('/api', applicationRoutes);

const PORT = process.env.PORT || 4000;
app.listen(5000, '0.0.0.0', () => {
    console.log('Server running on http://0.0.0.0:5000');
});
