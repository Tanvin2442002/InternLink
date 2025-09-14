const express = require("express");
const router = express.Router();
const sql = require("../DB/connection");
router.post("/jobpost", async (req, res) => {
  try {
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
      tags,
      extra_meta,
      status,
    } = req.body;

    // required field check
    if (!title) {
      return res.status(400).json({ success: false, error: "Job title is required" });
    }

    const [job] = await sql`
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
        tags,
        extra_meta,
        status
      )
      VALUES (
        ${recruiter_id || null},
        ${company_name || null},
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
        ${tags || null},
        ${extra_meta || null},
        ${status || "Active"}
      )
      RETURNING *
    `;

    return res.status(201).json({ success: true, job });
  } catch (error) {
    console.error("Error inserting job:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

// UPDATE a job by ID
router.put("/jobposts/:id", async (req, res) => {
  try {
    const jobId = req.params.id;

    if (!jobId) {
      return res.status(400).json({ success: false, error: "Missing job id" });
    }

    // only update provided fields
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
      tags,
      extra_meta,
      status,
    } = req.body;

    const [updatedJob] = await sql`
      UPDATE jobs
      SET 
        recruiter_id = COALESCE(${recruiter_id}, recruiter_id),
        company_name = COALESCE(${company_name}, company_name),
        company_logo_url = COALESCE(${company_logo_url}, company_logo_url),
        company_description = COALESCE(${company_description}, company_description),
        title = COALESCE(${title}, title),
        role_type = COALESCE(${role_type}, role_type),
        employment_type = COALESCE(${employment_type}, employment_type),
        duration_months = COALESCE(${duration_months}, duration_months),
        stipend = COALESCE(${stipend}, stipend),
        location = COALESCE(${location}, location),
        closing_date = COALESCE(${closing_date}, closing_date),
        role_overview = COALESCE(${role_overview}, role_overview),
        required_skills = COALESCE(${required_skills}, required_skills),
        perks = COALESCE(${perks}, perks),
        eligibility = COALESCE(${eligibility}, eligibility),
        tags = COALESCE(${tags}, tags),
        extra_meta = COALESCE(${extra_meta}, extra_meta),
        status = COALESCE(${status}, status),
        updated_at = now()
      WHERE id = ${jobId}
      RETURNING *
    `;

    if (!updatedJob) {
      return res.status(404).json({ success: false, error: "Job not found" });
    }

    return res.status(200).json({ success: true, job: updatedJob });
  } catch (error) {
    console.error("Error updating job:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

// DELETE a job by ID
router.delete("/jobposts/:id", async (req, res) => {
  try {
    const jobId = req.params.id;

    if (!jobId) {
      return res.status(400).json({ success: false, error: "Missing job id" });
    }

    const result = await sql`
      DELETE FROM jobs
      WHERE id = ${jobId}
      RETURNING *
    `;

    if (!result || result.length === 0) {
      return res.status(404).json({ success: false, error: "Job not found" });
    }

    return res.status(200).json({ success: true, message: "Job deleted successfully" });
  } catch (error) {
    console.error("Error deleting job:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});


export default router;
