const express = require("express");
const sql = require("../DB/connection");

const router = express.Router();

router.get("/jobs/:id", async (req, res) => {
  try {
    const jobId = req.params.id;
    // console.log('Fetching job with ID:', jobId);
    if (!jobId) {
      return res.status(400).json({ success: false, error: "Missing job id" });
    }

    // simple single-table select
    const rows = await sql`
      SELECT * FROM jobs
      WHERE id = ${jobId}
      LIMIT 1
    `;

    if (!rows || rows.length === 0) {
      return res.status(404).json({ success: false, error: "Job not found" });
    }
    const job = rows[0];

    return res.status(200).json({ success: true, job });
  } catch (error) {
    console.error("Error fetching job:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

router.get("/jobs", async (req, res) => {
  try {
    // Fetch all jobs from the database
    const rows = await sql`
      SELECT * FROM jobs
    `;

    if (!rows || rows.length === 0) {
      return res.status(404).json({ success: false, error: "No jobs found" });
    }

    return res.status(200).json({ success: true, jobs: rows });
  } catch (error) {
    console.error("Error fetching jobs:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

router.post("/saved-internships", async (req, res) => {
  const { applicant_id, job_id } = req.body;

  if (!applicant_id || !job_id) {
    return res
      .status(400)
      .json({ success: false, error: "applicant_id and job_id are required" });
  }

  try {
    // Insert the saved internship
    const row = await sql`
      INSERT INTO saved_internships (applicant_id, job_id)
      VALUES (${applicant_id}, ${job_id})
      ON CONFLICT (applicant_id, job_id) DO NOTHING
      RETURNING *
    `;

    if (!row || row.length === 0) {
      // Already saved
      return res
        .status(409)
        .json({ success: false, error: "Internship already saved" });
    }

    return res.status(201).json({ success: true, savedInternship: row[0] });
  } catch (error) {
    console.error("Error saving internship:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

// GET /saved-internships/:applicant_id
router.get("/saved-internships/:applicant_id", async (req, res) => {
  const { applicant_id } = req.params;
  // console.log('Fetching saved internships for applicant_id:', applicant_id);
  if (!applicant_id) {
    return res
      .status(400)
      .json({ success: false, error: "applicant_id is required" });
  }

  try {
    const rows = await sql`
      SELECT *
      FROM saved_internships, jobs
      WHERE saved_internships.job_id = jobs.id
      AND saved_internships.applicant_id = ${applicant_id}
      ORDER BY saved_at DESC
    `;

    if (!rows || rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "No saved internships found for this user",
      });
    }

    return res.status(200).json({ success: true, savedInternships: rows });
  } catch (error) {
    console.error("Error fetching saved internships:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

module.exports = router;
