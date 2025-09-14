const express = require("express");
const sql = require("../DB/connection");
const https = require("https");
const { GoogleGenerativeAI, SchemaType } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
const { matchJobs } = require("./matchService");

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

// Add this NEW route handler for /alljobs/:applicant_id
router.get("/alljobs/:applicant_id", async (req, res) => {
  try {
    const rows = await sql`SELECT * FROM jobs`;
    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: "No jobs found" });
    }

    const applicantId = req.params.applicant_id;
    // console.log("applicant_id:", applicantId);

    let cvUrl = null;
    try {
      const cv = await sql`SELECT cv_url FROM applicants WHERE applicant_id = ${applicantId}`;
      // console.log("CV query result:", cv);
      cvUrl = cv && cv.length > 0 ? cv[0].cv_url : null;
    } catch (err) {
      // console.error("[Jobs] CV fetch error:", err);
      // Continue without CV - will use local matching
    }

    // console.log("[Jobs] cvUrl:", cvUrl ? "(provided)" : "(none)");

    // Always try to use Gemini with CV if available
    const result = await matchJobs({ jobs: rows, cvUrl });
    // console.log("[Jobs] matchJobs result:", result);
    
    // Filter the original rows to only include matched jobs
    const matchedJobs = rows.filter(job => result.matches.includes(job.id));
    // console.log("[Jobs] Filtered matched jobs:", matchedJobs.length, "out of", rows.length);
    
    return res.json({ 
      success: true, 
      jobs: matchedJobs,
      matches: result.matches,
      scores: result.scores,
      source: result.source,
      totalJobsCount: rows.length,
      matchedJobsCount: matchedJobs.length
    });
  } catch (error) {
    // console.error("[Jobs] /alljobs/:applicant_id error:", error);
    return res.status(500).json({ error: "Failed to fetch jobs" });
  }
});

router.get("/alljobs/:cvurl", async (req, res) => {
  try {
    const rows = await sql`SELECT * FROM jobs`;
    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: "No jobs found" });
    }
    const cvUrl = req.params.cvurl;
    const useGemini = ["1", "true", "yes", "on"].includes(
      (req.query.useGemini || req.query.use_gemini || "")
        .toString()
        .toLowerCase()
    );

    // console.log(
    //   "[Jobs] useGemini query parsed as:",
    //   useGemini,
    //   "cvUrl:",
    //   cvUrl ? "(provided)" : "(none)"
    // );

    // Pass the flag to the matcher
    const result = await matchJobs({ jobs: rows, cvUrl, useGemini });

    return res.json({ success: true, ...result, jobsCount: rows.length });
  } catch (error) {
    console.error("[Jobs] /jobs error:", error);
    return res.status(500).json({ error: "Failed to fetch jobs" });
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

// POST /trigger-matching - Trigger job matching for a specific applicant
router.post("/trigger-matching", async (req, res) => {
  try {
    const { applicant_id } = req.body;
    
    if (!applicant_id) {
      return res.status(400).json({
        success: false,
        error: "applicant_id is required"
      });
    }

    console.log("[Jobs] Triggering job matching for applicant:", applicant_id);

    // Get all jobs
    const rows = await sql`SELECT * FROM jobs`;
    if (!rows || rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "No jobs found"
      });
    }

    // Get applicant's CV URL
    let cvUrl = null;
    try {
      const applicantRows = await sql`
        SELECT cv_url FROM applicants
        WHERE applicant_id = ${applicant_id}
        LIMIT 1
      `;
      if (applicantRows && applicantRows.length > 0) {
        cvUrl = applicantRows[0].cv_url;
        console.log("[Jobs] Found CV URL for applicant:", cvUrl);
      }
    } catch (error) {
      console.warn("[Jobs] Could not fetch CV URL:", error.message);
      // Continue without CV - will use local matching
    }

    // Run the job matching
    const result = await matchJobs({ jobs: rows, cvUrl });
    console.log("[Jobs] Job matching result:", result);

    const matchedJobs = rows.filter(job => result.matches.includes(job.id));
    console.log("[Jobs] Found", matchedJobs.length, "matched jobs out of", rows.length, "total jobs");

    return res.status(200).json({
      success: true,
      message: `Job matching completed. Found ${matchedJobs.length} matching jobs.`,
      matchedCount: matchedJobs.length,
      totalJobs: rows.length,
      matches: result.matches,
      scores: result.scores
    });

  } catch (error) {
    console.error("[Jobs] Error triggering job matching:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to trigger job matching",
      details: error.message
    });
  }
});


module.exports = router;

/*

*/
