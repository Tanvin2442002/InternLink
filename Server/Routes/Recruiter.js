const express = require("express");
const sql = require("../DB/connection");

const router = express.Router();

// Add this helper function at the top after the router declaration
async function getRecruiterIdFromUserId(user_id) {
  try {
    const result = await sql`
      SELECT recruiter_id FROM recruiters WHERE user_id = ${user_id} LIMIT 1
    `;
    return result.length > 0 ? result[0].recruiter_id : null;
  } catch (error) {
    console.error("💥 [RECRUITER API] Error getting recruiter_id:", error);
    return null;
  }
}

// GET /recruiter/profile/:recruiter_id - Get recruiter profile
router.get("/recruiter/profile/:recruiter_id", async (req, res) => {
  try {
    const { recruiter_id } = req.params;

    console.log("🔍 [RECRUITER API] GET /recruiter/profile/:recruiter_id - CALLED");
    console.log("📋 [RECRUITER API] Recruiter ID:", recruiter_id);

    if (!recruiter_id) {
      console.log("❌ [RECRUITER API] Missing recruiter ID");
      return res.status(400).json({
        success: false,
        error: "Recruiter ID is required"
      });
    }

    const recruiterRows = await sql`
      SELECT 
        recruiter_id,
        user_id,
        full_name,
        company_name,
        position_title,
        company_website,
        work_email
      FROM recruiters
      WHERE user_id = ${recruiter_id}
      LIMIT 1
    `;

    if (!recruiterRows || recruiterRows.length === 0) {
      console.log("❌ [RECRUITER API] Recruiter not found:", recruiter_id);
      return res.status(404).json({
        success: false,
        error: "Recruiter not found"
      });
    }

    const recruiter = recruiterRows[0];

    console.log("✅ [RECRUITER API] Profile retrieved successfully");
    return res.status(200).json({
      success: true,
      recruiter: recruiter
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error getting profile:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get recruiter profile",
      details: error.message
    });
  }
});

// PUT /recruiter/profile/:recruiter_id - Update recruiter profile
router.put("/recruiter/profile/:recruiter_id", async (req, res) => {
  try {
    const { recruiter_id } = req.params;
    const {
      full_name,
      company_name,
      position_title,
      company_website,
      work_email
    } = req.body;

    console.log("🔄 [RECRUITER API] PUT /recruiter/profile/:recruiter_id - CALLED");
    console.log("📋 [RECRUITER API] Updating recruiter:", recruiter_id);
    console.log("📝 [RECRUITER API] Update data:", { full_name, company_name, position_title });

    if (!recruiter_id) {
      console.log("❌ [RECRUITER API] Missing recruiter ID");
      return res.status(400).json({
        success: false,
        error: "Recruiter ID is required"
      });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramIndex = 1;

    const fields = {
      full_name, company_name, position_title, company_website, work_email
    };

    Object.entries(fields).forEach(([key, value]) => {
      if (value !== undefined) {
        updates.push(`${key} = $${paramIndex++}`);
        values.push(value);
      }
    });

    if (updates.length === 0) {
      console.log("❌ [RECRUITER API] No fields to update");
      return res.status(400).json({
        success: false,
        error: "No fields to update"
      });
    }

    // updates.push(`updated_at = NOW()`);
    values.push(recruiter_id);

    const updateQuery = `
      UPDATE recruiters 
      SET ${updates.join(', ')}
      WHERE user_id = $${paramIndex}
      RETURNING *
    `;

    const result = await sql.unsafe(updateQuery, values);

    if (result.length === 0) {
      console.log("❌ [RECRUITER API] Recruiter not found for update:", recruiter_id);
      return res.status(404).json({
        success: false,
        error: "Recruiter not found"
      });
    }

    console.log("✅ [RECRUITER API] Profile updated successfully");
    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      recruiter: result[0]
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error updating profile:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to update recruiter profile",
      details: error.message
    });
  }
});

// GET /recruiter/jobs/:recruiter_id - Get all jobs for recruiter
router.get("/recruiter/jobs/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { page = 1, limit = 10, status } = req.query;

    console.log("🔍 [RECRUITER API] GET /recruiter/jobs/:user_id - CALLED");
    console.log("📋 [RECRUITER API] User ID:", user_id);

    if (!user_id) {
      console.log("❌ [RECRUITER API] Missing user ID");
      return res.status(400).json({
        success: false,
        error: "User ID is required"
      });
    }

    // Get recruiter_id from user_id
    const recruiter_id = await getRecruiterIdFromUserId(user_id);
    
    if (!recruiter_id) {
      console.log("❌ [RECRUITER API] Recruiter not found for user_id:", user_id);
      return res.status(404).json({
        success: false,
        error: "Recruiter not found"
      });
    }

    console.log("✅ [RECRUITER API] Found recruiter_id:", recruiter_id);

    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    let whereClause = `WHERE recruiter_id = '${recruiter_id}'`;
    if (status) {
      whereClause += ` AND status = '${status}'`;
    }

    const jobsRows = await sql.unsafe(`
      SELECT 
        id, 
        recruiter_id, 
        company_name,
        title,
        role_type,
        employment_type,
        duration_months,
        stipend,
        location,
        closing_date,
        role_overview,
        required_skills,
        perks,
        eligibility,
        tags,
        created_at,
        updated_at
      FROM jobs
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT ${parseInt(limit)} OFFSET ${offset}
    `);

    console.log("✅ [RECRUITER API] Jobs retrieved successfully - Count:", jobsRows.length);
    return res.status(200).json({
      success: true,
      jobs: jobsRows
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error getting jobs:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get recruiter jobs",
      details: error.message
    });
  }
});

// POST /recruiter/jobs - Create new job posting
router.post("/recruiter/jobs", async (req, res) => {
  try {
    console.log("➕ [RECRUITER API] POST /recruiter/jobs - CALLED");
    
    const {
      recruiter_id,
      company_name,
      company_logo_url,
      company_description,
      title,
      role_type,
      employment_type,
      duration_months,
      stipend,
      location,
      closing_date,
      role_overview,
      required_skills,
      perks,
      eligibility,
      tags
    } = req.body;

    if (!recruiter_id || !title || !company_name) {
      console.log("❌ [RECRUITER API] Missing required fields for job creation");
      return res.status(400).json({
        success: false,
        error: "Recruiter ID, title, and company name are required"
      });
    }

    console.log("📋 [RECRUITER API] Creating job:", title, "for recruiter:", recruiter_id);

    const jobResult = await sql`
      INSERT INTO jobs (
        recruiter_id,
        company_name,
        company_logo_url,
        company_description,
        title,
        role_type,
        employment_type,
        duration_months,
        stipend,
        location,
        closing_date,
        role_overview,
        required_skills,
        perks,
        eligibility,
        tags
      )
      VALUES (
        ${recruiter_id},
        ${company_name},
        ${company_logo_url || null},
        ${company_description || null},
        ${title},
        ${role_type || null},
        ${employment_type || null},
        ${duration_months || null},
        ${stipend || null},
        ${location || null},
        ${closing_date || null},
        ${role_overview || null},
        ${required_skills || null},
        ${perks || null},
        ${eligibility || null},
        ${tags || null}
      )
      RETURNING *
    `;

    console.log("✅ [RECRUITER API] Job created successfully - ID:", jobResult[0]?.id);
    return res.status(201).json({
      success: true,
      message: "Job created successfully",
      job: jobResult[0]
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error creating job:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to create job posting",
      details: error.message
    });
  }
});

// PUT /recruiter/jobs/:job_id - Update job posting
router.put("/recruiter/jobs/:job_id", async (req, res) => {
  try {
    console.log("🔄 [RECRUITER API] PUT /recruiter/jobs/:job_id - CALLED");
    const { job_id } = req.params;
    console.log("📋 [RECRUITER API] Updating job ID:", job_id);

    const {
      title,
      role_type,
      employment_type,
      duration_months,
      stipend,
      location,
      closing_date,
      role_overview,
      required_skills,
      perks,
      eligibility,
      tags,
      status
    } = req.body;

    if (!job_id) {
      console.log("❌ [RECRUITER API] Missing job ID");
      return res.status(400).json({
        success: false,
        error: "Job ID is required"
      });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramIndex = 1;

    const fields = {
      title, role_type, employment_type, duration_months, stipend,
      location, closing_date, role_overview, required_skills,
      perks, eligibility, tags, status
    };

    Object.entries(fields).forEach(([key, value]) => {
      if (value !== undefined) {
        updates.push(`${key} = $${paramIndex++}`);
        values.push(value);
      }
    });

    if (updates.length === 0) {
      console.log("❌ [RECRUITER API] No fields to update");
      return res.status(400).json({
        success: false,
        error: "No fields to update"
      });
    }

    updates.push(`updated_at = NOW()`);
    values.push(job_id);

    const updateQuery = `
      UPDATE jobs 
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING *
    `;

    const result = await sql.unsafe(updateQuery, values);

    if (result.length === 0) {
      console.log("❌ [RECRUITER API] Job not found for update:", job_id);
      return res.status(404).json({
        success: false,
        error: "Job not found"
      });
    }

    console.log("✅ [RECRUITER API] Job updated successfully");
    return res.status(200).json({
      success: true,
      message: "Job updated successfully",
      job: result[0]
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error updating job:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to update job",
      details: error.message
    });
  }
});

// DELETE /recruiter/jobs/:job_id - Delete/deactivate job posting
router.delete("/recruiter/jobs/:job_id", async (req, res) => {
  try {
    console.log("🗑️ [RECRUITER API] DELETE /recruiter/jobs/:job_id - CALLED");
    const { job_id } = req.params;
    console.log("📋 [RECRUITER API] Deleting job ID:", job_id);

    if (!job_id) {
      console.log("❌ [RECRUITER API] Missing job ID");
      return res.status(400).json({
        success: false,
        error: "Job ID is required"
      });
    }

    // Update status to inactive instead of actually deleting
    const result = await sql`
      UPDATE jobs 
      SET status = 'inactive', updated_at = NOW()
      WHERE id = ${job_id}
      RETURNING *
    `;

    if (result.length === 0) {
      console.log("❌ [RECRUITER API] Job not found for deletion:", job_id);
      return res.status(404).json({
        success: false,
        error: "Job not found"
      });
    }

    console.log("✅ [RECRUITER API] Job deleted successfully");
    return res.status(200).json({
      success: true,
      message: "Job deleted successfully"
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error deleting job:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to delete job",
      details: error.message
    });
  }
});

// GET /recruiter/applications/:recruiter_id - Get applications for recruiter's jobs
router.get("/recruiter/applications/:user_id", async (req, res) => {
  try {
    console.log("🔍 [RECRUITER API] GET /recruiter/applications/:user_id - CALLED");
    const { user_id } = req.params;
    const { page = 1, limit = 10, status, job_id, search } = req.query;

    console.log("📋 [RECRUITER API] User ID:", user_id);

    if (!user_id) {
      console.log("❌ [RECRUITER API] Missing user ID");
      return res.status(400).json({
        success: false,
        error: "User ID is required"
      });
    }

    // Get recruiter_id from user_id
    const recruiter_id = await getRecruiterIdFromUserId(user_id);
    
    if (!recruiter_id) {
      console.log("❌ [RECRUITER API] Recruiter not found for user_id:", user_id);
      return res.status(404).json({
        success: false,
        error: "Recruiter not found"
      });
    }

    console.log("✅ [RECRUITER API] Found recruiter_id:", recruiter_id);

    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    let whereClause = `WHERE j.recruiter_id = '${recruiter_id}'`;
    
    if (status) {
      whereClause += ` AND ja.status = '${status}'`;
    }
    if (job_id) {
      whereClause += ` AND ja.job_id = '${job_id}'`;
    }
    if (search) {
      whereClause += ` AND (ja.full_name ILIKE '%${search}%' OR ja.email ILIKE '%${search}%')`;
    }

    const applicationsRows = await sql.unsafe(`
      SELECT 
        ja.id,
        ja.job_id,
        ja.full_name,
        ja.email,
        ja.phone,
        ja.cv_file_url,
        ja.status,
        ja.submitted_at,
        j.title as job_title,
        j.company_name
      FROM job_applications ja
      INNER JOIN jobs j ON ja.job_id = j.id
      ${whereClause}
      ORDER BY ja.submitted_at DESC
      LIMIT ${parseInt(limit)} OFFSET ${offset}
    `);

    console.log("✅ [RECRUITER API] Applications retrieved successfully - Count:", applicationsRows.length);
    return res.status(200).json({
      success: true,
      applications: applicationsRows
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error getting applications:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get applications",
      details: error.message
    });
  }
});

// PUT /recruiter/applications/:application_id/status - Update application status
router.put("/recruiter/applications/:application_id/status", async (req, res) => {
  try {
    console.log("🔄 [RECRUITER API] PUT /recruiter/applications/:application_id/status - CALLED");
    const { application_id } = req.params;
    const { status, recruiter_notes } = req.body;

    console.log("📋 [RECRUITER API] Application ID:", application_id);
    console.log("📝 [RECRUITER API] New status:", status);

    if (!application_id || !status) {
      console.log("❌ [RECRUITER API] Missing application ID or status");
      return res.status(400).json({
        success: false,
        error: "Application ID and status are required"
      });
    }

    const validStatuses = ['applied', 'reviewed', 'shortlisted', 'interviewed', 'offered', 'hired', 'rejected'];
    if (!validStatuses.includes(status)) {
      console.log("❌ [RECRUITER API] Invalid status:", status);
      return res.status(400).json({
        success: false,
        error: "Invalid status value"
      });
    }

    const result = await sql`
      UPDATE job_applications 
      SET 
        status = ${status}
      WHERE id = ${application_id}
      RETURNING *
    `;

    if (result.length === 0) {
      console.log("❌ [RECRUITER API] Application not found:", application_id);
      return res.status(404).json({
        success: false,
        error: "Application not found"
      });
    }

    console.log("✅ [RECRUITER API] Application status updated successfully");
    return res.status(200).json({
      success: true,
      message: "Application status updated successfully",
      application: result[0]
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error updating application status:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to update application status",
      details: error.message
    });
  }
});

// GET /recruiter/analytics/:user_id - Get analytics dashboard
router.get("/recruiter/analytics/:user_id", async (req, res) => {
  try {
    console.log("📊 [RECRUITER API] GET /recruiter/analytics/:user_id - CALLED");
    const { user_id } = req.params;
    const { period = "month" } = req.query;

    console.log("📋 [RECRUITER API] User ID:", user_id);
    console.log("📅 [RECRUITER API] Period:", period);

    if (!user_id) {
      console.log("❌ [RECRUITER API] Missing user ID");
      return res.status(400).json({
        success: false,
        error: "User ID is required"
      });
    }

    // Get recruiter_id from user_id
    console.log("🔍 [RECRUITER API] Getting recruiter_id from user_id...");
    const recruiter_id = await getRecruiterIdFromUserId(user_id);
    
    if (!recruiter_id) {
      console.log("❌ [RECRUITER API] Recruiter not found for user_id:", user_id);
      return res.status(404).json({
        success: false,
        error: "Recruiter not found"
      });
    }

    console.log("✅ [RECRUITER API] Found recruiter_id:", recruiter_id);

    // Date range calculation
    let dateFilter = "";
    switch(period) {
      case "week":
        dateFilter = "AND ja.submitted_at >= NOW() - INTERVAL '7 days'";
        break;
      case "month":
        dateFilter = "AND ja.submitted_at >= NOW() - INTERVAL '30 days'";
        break;
      case "quarter":
        dateFilter = "AND ja.submitted_at >= NOW() - INTERVAL '90 days'";
        break;
      default:
        dateFilter = "AND ja.submitted_at >= NOW() - INTERVAL '30 days'";
    }

    console.log("🔍 [RECRUITER API] Date filter:", dateFilter);

    // Get total jobs
    console.log("🔍 [RECRUITER API] Fetching total jobs...");
    const totalJobsResult = await sql`
      SELECT COUNT(*) as total FROM jobs WHERE recruiter_id = ${recruiter_id}
    `;

    // Get active jobs - Note: check what status values exist in your DB
    console.log("🔍 [RECRUITER API] Fetching active jobs...");
    const activeJobsResult = await sql`
      SELECT COUNT(*) as total FROM jobs 
      WHERE recruiter_id = ${recruiter_id} AND (status = 'active' OR status IS NULL)
    `;

    // Get total applications
    console.log("🔍 [RECRUITER API] Fetching total applications...");
    const totalApplicationsResult = await sql.unsafe(`
      SELECT COUNT(*) as total 
      FROM job_applications ja
      INNER JOIN jobs j ON ja.job_id = j.id
      WHERE j.recruiter_id = '${recruiter_id}' ${dateFilter}
    `);

    // Get applications by status
    console.log("🔍 [RECRUITER API] Fetching applications by status...");
    const applicationsByStatusResult = await sql.unsafe(`
      SELECT COALESCE(ja.status, 'applied') as status, COUNT(*) as count
      FROM job_applications ja
      INNER JOIN jobs j ON ja.job_id = j.id
      WHERE j.recruiter_id = '${recruiter_id}' ${dateFilter}
      GROUP BY ja.status
    `);

    // Get recent activity
    console.log("🔍 [RECRUITER API] Fetching recent activity...");
    const recentActivityResult = await sql.unsafe(`
      SELECT ja.id, ja.full_name, COALESCE(ja.status, 'applied') as status, 
             ja.submitted_at as created_at, j.title as job_title
      FROM job_applications ja
      INNER JOIN jobs j ON ja.job_id = j.id
      WHERE j.recruiter_id = '${recruiter_id}'
      ORDER BY ja.submitted_at DESC
      LIMIT 10
    `);

    // Get top performing jobs
    console.log("🔍 [RECRUITER API] Fetching top performing jobs...");
    const topJobsResult = await sql.unsafe(`
      SELECT j.id, j.title, COUNT(ja.id) as application_count
      FROM jobs j
      LEFT JOIN job_applications ja ON j.id = ja.job_id
      WHERE j.recruiter_id = '${recruiter_id}'
      GROUP BY j.id, j.title
      ORDER BY application_count DESC
      LIMIT 5
    `);

    // Format applications by status
    console.log("🔍 [RECRUITER API] Formatting applications by status...");
    const applicationsByStatus = {};
    applicationsByStatusResult.forEach(row => {
      applicationsByStatus[row.status] = parseInt(row.count);
    });

    console.log("📊 [RECRUITER API] Analytics data summary:");
    console.log("📊 [RECRUITER API] Total jobs:", totalJobsResult[0]?.total);
    console.log("📊 [RECRUITER API] Active jobs:", activeJobsResult[0]?.total);
    console.log("📊 [RECRUITER API] Total applications:", totalApplicationsResult[0]?.total);
    console.log("📊 [RECRUITER API] Applications by status:", applicationsByStatus);
    console.log("📊 [RECRUITER API] Recent activity count:", recentActivityResult.length);
    console.log("📊 [RECRUITER API] Top jobs count:", topJobsResult.length);

    console.log("✅ [RECRUITER API] Analytics retrieved successfully");
    return res.status(200).json({
      success: true,
      analytics: {
        total_jobs: parseInt(totalJobsResult[0]?.total || 0),
        active_jobs: parseInt(activeJobsResult[0]?.total || 0),
        total_applications: parseInt(totalApplicationsResult[0]?.total || 0),
        applications_by_status: applicationsByStatus,
        recent_activity: recentActivityResult,
        top_performing_jobs: topJobsResult,
        period: period
      }
    });

  } catch (error) {
    console.error("💥 [RECRUITER API] Error getting analytics:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get analytics",
      details: error.message
    });
  }
});

module.exports = router;