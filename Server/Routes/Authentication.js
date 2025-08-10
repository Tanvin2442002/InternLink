const express = require('express');
const bcrypt = require('bcrypt');
const sql = require('../DB/connection');

const router = express.Router();

// Sign up route
router.post('/signup', async (req, res) => {
  const { email, password, userType, profileData } = req.body;
  console.log('Received signup request:', { email, userType, profileData });
  try {
    // Check if user already exists
    const existingUser = await sql`
      SELECT * FROM users WHERE email = ${email}
    `;

    if (existingUser.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const newUser = await sql`
      INSERT INTO users (email, password_hash, user_type)
      VALUES (${email}, ${passwordHash}, ${userType})
      RETURNING user_id, email, user_type, created_at
    `;

    const userId = newUser[0].user_id;

    // Create profile based on user type
    if (userType === 'applicant') {
      const { fullName, universityName, major, phoneNumber, studentEmail } = profileData;
      
      await sql`
        INSERT INTO applicants (user_id, full_name, university_name, major, phone_number, student_email)
        VALUES (${userId}, ${fullName}, ${universityName}, ${major}, ${phoneNumber}, ${studentEmail})
      `;
    } else if (userType === 'recruiter') {
      const { fullName, companyName, positionTitle, companyWebsite, workEmail } = profileData;
      
      await sql`
        INSERT INTO recruiters (user_id, full_name, company_name, position_title, company_website, work_email)
        VALUES (${userId}, ${fullName}, ${companyName}, ${positionTitle}, ${companyWebsite}, ${workEmail})
      `;
    }

    res.status(201).json({
      message: 'User created successfully',
      user: newUser[0]
    });

  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login route
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find user by email
    const user = await sql`
      SELECT * FROM users WHERE email = ${email}
    `;

    if (user.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user[0].password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    let profileData = null;
    
    if (user[0].user_type === 'applicant') {
      const applicant = await sql`
        SELECT * FROM applicants WHERE user_id = ${user[0].user_id}
      `;
      profileData = applicant[0];
    } else if (user[0].user_type === 'recruiter') {
      const recruiter = await sql`
        SELECT * FROM recruiters WHERE user_id = ${user[0].user_id}
      `;
      profileData = recruiter[0];
    }

    res.json({
      message: 'Login successful',
      user: {
        user_id: user[0].user_id,
        email: user[0].email,
        user_type: user[0].user_type,
        created_at: user[0].created_at
      },
      profile: profileData
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;