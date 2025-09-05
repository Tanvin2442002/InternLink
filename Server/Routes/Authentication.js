const express = require('express');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const sql = require('../DB/connection');
// const nodemailer = require('nodemailer');

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

// Forgot password route
// router.post('/forgot-password', async (req, res) => {
//   const { email } = req.body;

//   if (!email) {
//     return res.status(400).json({ error: 'Email is required' });
//   }

//   try {
//     // Check if user exists
//     const user = await sql`
//       SELECT user_id, email FROM users WHERE email = ${email}
//     `;

//     if (user.length === 0) {
//       // For security, don't reveal if email exists or not
//       return res.json({ 
//         message: 'If an account with that email exists, a password reset link has been sent.' 
//       });
//     }

//     // Generate reset token
//     const resetToken = crypto.randomBytes(32).toString('hex');
//     const resetTokenExpiry = new Date(Date.now() + 3600000); // 1 hour from now

//     // Store reset token in database
//     await sql`
//       INSERT INTO password_reset_tokens (user_id, token, expires_at)
//       VALUES (${user[0].user_id}, ${resetToken}, ${resetTokenExpiry})
//       ON CONFLICT (user_id) 
//       DO UPDATE SET 
//         token = ${resetToken}, 
//         expires_at = ${resetTokenExpiry},
//         created_at = NOW()
//     `;

//     // Create reset URL (you'll need to handle this in your app)
//     const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;

//     // Send email (configure your email service)
//     await sendResetEmail(email, resetUrl, resetToken);

//     res.json({ 
//       message: 'If an account with that email exists, a password reset link has been sent.' 
//     });

//   } catch (error) {
//     console.error('Forgot password error:', error);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// // Reset password route
// router.post('/reset-password', async (req, res) => {
//   const { token, newPassword } = req.body;

//   if (!token || !newPassword) {
//     return res.status(400).json({ error: 'Token and new password are required' });
//   }

//   if (newPassword.length < 6) {
//     return res.status(400).json({ error: 'Password must be at least 6 characters long' });
//   }

//   try {
//     // Find valid reset token
//     const resetRecord = await sql`
//       SELECT user_id, expires_at FROM password_reset_tokens 
//       WHERE token = ${token} AND expires_at > NOW()
//     `;

//     if (resetRecord.length === 0) {
//       return res.status(400).json({ error: 'Invalid or expired reset token' });
//     }

//     // Hash new password
//     const saltRounds = 10;
//     const passwordHash = await bcrypt.hash(newPassword, saltRounds);

//     // Update user password
//     await sql`
//       UPDATE users 
//       SET password_hash = ${passwordHash}
//       WHERE user_id = ${resetRecord[0].user_id}
//     `;

//     // Delete used reset token
//     await sql`
//       DELETE FROM password_reset_tokens 
//       WHERE token = ${token}
//     `;

//     res.json({ message: 'Password reset successfully' });

//   } catch (error) {
//     console.error('Reset password error:', error);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// // Email sending function
// async function sendResetEmail(email, resetUrl, token) {
//   // Configure your email service here
//   // This is a mock implementation - replace with your actual email service
  
//   if (process.env.NODE_ENV === 'development') {
//     // In development, just log the reset info
//     console.log('=== PASSWORD RESET EMAIL (DEV MODE) ===');
//     console.log('To:', email);
//     console.log('Reset URL:', resetUrl);
//     console.log('Token:', token);
//     console.log('=====================================');
//     return;
//   }

//   // For production, configure a real email service like:
//   // - SendGrid
//   // - AWS SES
//   // - Nodemailer with SMTP
  
//   try {
//     // Example with nodemailer (you'll need to configure SMTP settings)
//     const transporter = nodemailer.createTransporter({
//       host: process.env.SMTP_HOST,
//       port: process.env.SMTP_PORT,
//       secure: false,
//       auth: {
//         user: process.env.SMTP_USER,
//         pass: process.env.SMTP_PASS,
//       },
//     });

//     const mailOptions = {
//       from: process.env.FROM_EMAIL || 'noreply@internlink.com',
//       to: email,
//       subject: 'Reset Your InternLink Password',
//       html: `
//         <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
//           <h2 style="color: #6A5AE0;">Reset Your Password</h2>
//           <p>You requested a password reset for your InternLink account.</p>
//           <p>Click the button below to reset your password:</p>
//           <a href="${resetUrl}" style="display: inline-block; background: linear-gradient(135deg, #6A5AE0, #8F41F4); color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold;">Reset Password</a>
//           <p style="margin-top: 20px; color: #666;">This link will expire in 1 hour.</p>
//           <p style="color: #666;">If you didn't request this reset, please ignore this email.</p>
//         </div>
//       `,
//     };

//     await transporter.sendMail(mailOptions);
//   } catch (error) {
//     console.error('Email sending error:', error);
//     // Don't throw error to avoid revealing email sending issues
//   }
// }

module.exports = router;