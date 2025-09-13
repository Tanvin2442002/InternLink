require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./Routes/Authentication');
const jobRoutes = require('./Routes/Jobs');
const profileRoutes = require('./Routes/Profile');
const applicationRoutes = require('./Routes/Application');
const chatbotRoutes = require('./Routes/Chatbot');
const recruiterRoutes = require('./Routes/Recruiter');
const recruiterExtendedRoutes = require('./Routes/RecruiterExtended');

const app = express();
app.use(cors());
app.use(express.json());

// Use authentication routes
app.use('/api/auth', authRoutes);
app.use('/api', jobRoutes);
app.use('/api', profileRoutes);
app.use('/api', applicationRoutes);
app.use('/api', chatbotRoutes);
app.use('/api', recruiterRoutes);
app.use('/api', recruiterExtendedRoutes);

const PORT = process.env.PORT || 4000;

console.log("🚀 [SERVER] Starting InternLink Backend Server...");
console.log("📁 [SERVER] Loading route modules:");
console.log("   ✅ Authentication routes");
console.log("   ✅ Job routes"); 
console.log("   ✅ Profile routes");
console.log("   ✅ Application routes");
console.log("   ✅ Chatbot routes");
console.log("   ✅ Recruiter routes");
console.log("   ✅ Recruiter Extended routes");

app.listen(5000, '0.0.0.0', () => {
    console.log("🌟 [SERVER] Server running on http://0.0.0.0:5000");
    console.log("🔗 [SERVER] Available API endpoints:");
    console.log("   📱 /api/auth/* - Authentication");
    console.log("   💼 /api/jobs/* - Job management");
    console.log("   👤 /api/profile/* - User profiles");
    console.log("   📄 /api/applications/* - Applications");
    console.log("   🤖 /api/chatbot/* - AI Chatbot");
    console.log("   🏢 /api/recruiter/* - Recruiter management");
    console.log("📊 [SERVER] Server ready for connections!");
});
