const express = require("express");
const router = express.Router();
const sql = require("../DB/connection");
const supabase = require("../supabaseClient");
const multer = require("multer");

// use memory storage so file.buffer is available
const upload = multer({ storage: multer.memoryStorage() });

router.post("/applications", async (req, res) => {
  console.log("Received application submission:");
  try {
    const {
      job_id,
      applicant_id,
      full_name,
      email,
      phone,
      date_of_birth,
      address,
      highest_qualification,
      field_of_study,
      university_name,
      graduation_year,
      cv_file_url
    } = req.body;

    console.log(req.body);
    // ✅ Basic validation
    if (!job_id || !applicant_id || !full_name || !email || !cv_file_url) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields: job_id, applicant_id, full_name, email, cv_file_url"
      });
    }

    // ✅ Insert into DB
    const rows = await sql`
      INSERT INTO job_applications (
        job_id,
        applicant_id,
        full_name,
        email,
        phone,
        date_of_birth,
        address,
        highest_qualification,
        field_of_study,
        university_name,
        graduation_year,
        cv_file_url
      )
      VALUES (
        ${job_id},
        ${applicant_id},
        ${full_name},
        ${email},
        ${phone || null},
        ${date_of_birth || null},
        ${address || null},
        ${highest_qualification || null},
        ${field_of_study || null},
        ${university_name || null},
        ${graduation_year || null},
        ${cv_file_url}
      )
      RETURNING *;
    `;

    const application = rows[0];

    return res.status(201).json({
      success: true,
      message: "Application submitted successfully",
      application
    });
  } catch (error) {
    console.error("Error inserting application:", error);
    return res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
});

// GET /applications/:applicant_id - Fetch all applications for an applicant
router.get("/applications/:applicant_id", async (req, res) => {
  try {
    const { applicant_id } = req.params;
    console.log("Fetching applications for applicant_id:", applicant_id);

    if (!applicant_id) {
      return res.status(400).json({
        success: false,
        error: "Missing applicant_id parameter"
      });
    }

    const applications = await sql`
      SELECT 
        j.title AS title,
        j.company_name AS company,
        j.company_logo_url AS logo,
        to_char(ja.submitted_at, 'Mon DD, YYYY') AS date,
        ja.status AS status,
        ja.id AS applicationId,
        j.role_type AS position,
        j.stipend AS salary,
        j.location AS location,
        COALESCE(j.role_overview::text, j.company_description) AS description,
        j.required_skills AS requirements,
        EXTRACT(DAY FROM (now() - ja.submitted_at))::int AS daysAgo,
        j.id AS jobId,
        ja.submitted_at AS submittedAt
      FROM job_applications ja
      JOIN jobs j ON ja.job_id = j.id
      WHERE ja.applicant_id = ${applicant_id}
      ORDER BY ja.submitted_at DESC;
    `;

    if (!applications || applications.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No applications found for this applicant",
        applications: []
      });
    }

    console.log(`Found ${applications.length} applications for applicant ${applicant_id}`);

    return res.status(200).json({
      success: true,
      message: "Applications fetched successfully",
      applications: applications,
      count: applications.length
    });

  } catch (error) {
    console.error("Error fetching applications:", error);
    return res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
});

// GET /applications/:applicant_id/stats - Get application statistics for an applicant
router.get("/applications/:applicant_id/stats", async (req, res) => {
  try {
    const { applicant_id } = req.params;
    console.log("Fetching application stats for applicant_id:", applicant_id);

    if (!applicant_id) {
      return res.status(400).json({
        success: false,
        error: "Missing applicant_id parameter"
      });
    }

    // Get time-based application statistics
    const applicationStats = await sql`
      SELECT 
        -- All time
        COUNT(*) AS total_applications,
        COUNT(*) FILTER (WHERE status <> 'applied') AS non_applied_applications,
        
        -- Last 7 days
        COUNT(*) FILTER (
            WHERE submitted_at >= NOW() - INTERVAL '7 days'
        ) AS total_last_7_days,
        
        COUNT(*) FILTER (
            WHERE submitted_at >= NOW() - INTERVAL '7 days'
              AND status <> 'applied'
        ) AS non_applied_last_7_days,

        -- Last 30 days
        COUNT(*) FILTER (
            WHERE submitted_at >= NOW() - INTERVAL '30 days'
        ) AS total_last_30_days,
        
        COUNT(*) FILTER (
            WHERE submitted_at >= NOW() - INTERVAL '30 days'
              AND status <> 'applied'
        ) AS non_applied_last_30_days

      FROM job_applications
      WHERE applicant_id = ${applicant_id};
    `;

    // Get saved internships count with time filters
    const savedStats = await sql`
      SELECT 
        -- All time
        COUNT(*) AS saved_count,
        
        -- Last 7 days
        COUNT(*) FILTER (
            WHERE saved_at >= NOW() - INTERVAL '7 days'
        ) AS saved_last_7_days,
        
        -- Last 30 days
        COUNT(*) FILTER (
            WHERE saved_at >= NOW() - INTERVAL '30 days'
        ) AS saved_last_30_days
        
      FROM saved_internships
      WHERE applicant_id = ${applicant_id};
    `;

    const stats = {
      // All time stats
      total_applications: parseInt(applicationStats[0]?.total_applications || 0),
      non_applied_applications: parseInt(applicationStats[0]?.non_applied_applications || 0),
      saved_count: parseInt(savedStats[0]?.saved_count || 0),
      
      // Last 7 days stats
      last_7_days: {
        total_applications: parseInt(applicationStats[0]?.total_last_7_days || 0),
        non_applied_applications: parseInt(applicationStats[0]?.non_applied_last_7_days || 0),
        saved_count: parseInt(savedStats[0]?.saved_last_7_days || 0)
      },
      
      // Last 30 days stats
      last_30_days: {
        total_applications: parseInt(applicationStats[0]?.total_last_30_days || 0),
        non_applied_applications: parseInt(applicationStats[0]?.non_applied_last_30_days || 0),
        saved_count: parseInt(savedStats[0]?.saved_last_30_days || 0)
      }
    };

    console.log(`Stats for applicant ${applicant_id}:`, stats);

    return res.status(200).json({
      success: true,
      message: "Statistics fetched successfully",
      stats: stats
    });

  } catch (error) {
    console.error("Error fetching application stats:", error);
    return res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
});

module.exports = router;