const express = require("express");
const sql = require("../DB/connection");

const router = express.Router();

// GET /recruiter/notifications/:recruiter_id - Get recruiter notifications
router.get("/recruiter/notifications/:recruiter_id", async (req, res) => {
  try {
    console.log("🔔 [RECRUITER EXT] GET /recruiter/notifications/:recruiter_id - CALLED");
    const { recruiter_id } = req.params;
    const { page = 1, limit = 20, unread_only = false } = req.query;

    console.log("📋 [RECRUITER EXT] Recruiter ID:", recruiter_id);
    console.log("📄 [RECRUITER EXT] Query params:", { page, limit, unread_only });

    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    let whereClause = `WHERE recruiter_id = '${recruiter_id}'`;
    if (unread_only === 'true') {
      whereClause += ` AND is_read = FALSE`;
    }

    const notifications = await sql.unsafe(`
      SELECT *
      FROM recruiter_notifications
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT ${parseInt(limit)} OFFSET ${offset}
    `);

    const unreadCount = await sql`
      SELECT COUNT(*) as count
      FROM recruiter_notifications
      WHERE recruiter_id = ${recruiter_id} AND is_read = FALSE
    `;

    console.log("✅ [RECRUITER EXT] Notifications retrieved successfully - Count:", notifications.length);
    return res.status(200).json({
      success: true,
      notifications: notifications,
      unread_count: unreadCount[0]?.count || 0
    });

  } catch (error) {
    console.error("💥 [RECRUITER EXT] Error getting notifications:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get notifications"
    });
  }
});

// PUT /recruiter/notifications/:notification_id/read - Mark notification as read
router.put("/recruiter/notifications/:notification_id/read", async (req, res) => {
  try {
    console.log("🔄 [RECRUITER EXT] PUT /recruiter/notifications/:notification_id/read - CALLED");
    const { notification_id } = req.params;
    console.log("📋 [RECRUITER EXT] Notification ID:", notification_id);

    await sql`
      UPDATE recruiter_notifications 
      SET is_read = TRUE 
      WHERE id = ${notification_id}
    `;

    console.log("✅ [RECRUITER EXT] Notification marked as read successfully");
    return res.status(200).json({
      success: true,
      message: "Notification marked as read"
    });

  } catch (error) {
    console.error("💥 [RECRUITER EXT] Error marking notification as read:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to mark notification as read"
    });
  }
});

// POST /recruiter/interviews - Schedule an interview
router.post("/recruiter/interviews", async (req, res) => {
  try {
    console.log("➕ [RECRUITER EXT] POST /recruiter/interviews - CALLED");
    const {
      application_id,
      recruiter_id,
      interview_type,
      scheduled_at,
      duration_minutes = 60,
      location,
      notes
    } = req.body;

    console.log("📋 [RECRUITER EXT] Scheduling interview for application:", application_id);

    if (!application_id || !recruiter_id || !interview_type || !scheduled_at) {
      console.log("❌ [RECRUITER EXT] Missing required fields for interview scheduling");
      return res.status(400).json({
        success: false,
        error: "Application ID, recruiter ID, interview type, and scheduled time are required"
      });
    }

    const interview = await sql`
      INSERT INTO interview_schedules (
        application_id,
        recruiter_id,
        interview_type,
        scheduled_at,
        duration_minutes,
        location,
        notes
      )
      VALUES (
        ${application_id},
        ${recruiter_id},
        ${interview_type},
        ${scheduled_at},
        ${duration_minutes},
        ${location || null},
        ${notes || null}
      )
      RETURNING *
    `;

    return res.status(201).json({
      success: true,
      message: "Interview scheduled successfully",
      interview: interview[0]
    });

  } catch (error) {
    console.error("💥 [RECRUITER EXT] Error scheduling interview:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to schedule interview"
    });
  }
});

// GET /recruiter/interviews/:recruiter_id - Get all interviews for recruiter
router.get("/recruiter/interviews/:recruiter_id", async (req, res) => {
  try {
    const { recruiter_id } = req.params;
    const { status, date_from, date_to } = req.query;

    console.log("[Recruiter] Getting interviews for recruiter:", recruiter_id);

    let whereClause = `WHERE i.recruiter_id = '${recruiter_id}'`;
    
    if (status) {
      whereClause += ` AND i.status = '${status}'`;
    }
    if (date_from) {
      whereClause += ` AND i.scheduled_at >= '${date_from}'`;
    }
    if (date_to) {
      whereClause += ` AND i.scheduled_at <= '${date_to}'`;
    }

    const interviews = await sql.unsafe(`
      SELECT 
        i.*,
        ja.full_name as applicant_name,
        ja.email as applicant_email,
        j.title as job_title
      FROM interview_schedules i
      INNER JOIN job_applications ja ON i.application_id = ja.id
      INNER JOIN jobs j ON ja.job_id = j.id
      ${whereClause}
      ORDER BY i.scheduled_at ASC
    `);

    return res.status(200).json({
      success: true,
      interviews: interviews
    });

  } catch (error) {
    console.error("💥 [RECRUITER EXT] Error getting interviews:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get interviews"
    });
  }
});

// PUT /recruiter/interviews/:interview_id - Update interview
router.put("/recruiter/interviews/:interview_id", async (req, res) => {
  try {
    const { interview_id } = req.params;
    const {
      scheduled_at,
      duration_minutes,
      location,
      status,
      notes,
      feedback
    } = req.body;

    console.log("[Recruiter] Updating interview:", interview_id);

    const updates = [];
    const values = [];
    let paramIndex = 1;

    const fields = {
      scheduled_at, duration_minutes, location, status, notes, feedback
    };

    Object.entries(fields).forEach(([key, value]) => {
      if (value !== undefined) {
        updates.push(`${key} = $${paramIndex++}`);
        values.push(value);
      }
    });

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: "No fields to update"
      });
    }

    updates.push(`updated_at = NOW()`);
    values.push(interview_id);

    const updateQuery = `
      UPDATE interview_schedules 
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING *
    `;

    const result = await sql.unsafe(updateQuery, values);

    return res.status(200).json({
      success: true,
      message: "Interview updated successfully",
      interview: result[0]
    });

  } catch (error) {
    console.error("[Recruiter] Error updating interview:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to update interview"
    });
  }
});

// POST /recruiter/saved-applicants - Save an applicant
router.post("/recruiter/saved-applicants", async (req, res) => {
  try {
    const { recruiter_id, applicant_id, tags, notes } = req.body;

    if (!recruiter_id || !applicant_id) {
      return res.status(400).json({
        success: false,
        error: "Recruiter ID and applicant ID are required"
      });
    }

    console.log("[Recruiter] Saving applicant:", applicant_id);

    const saved = await sql`
      INSERT INTO saved_applicants (recruiter_id, applicant_id, tags, notes)
      VALUES (${recruiter_id}, ${applicant_id}, ${tags || null}, ${notes || null})
      ON CONFLICT (recruiter_id, applicant_id) 
      DO UPDATE SET 
        tags = EXCLUDED.tags,
        notes = EXCLUDED.notes,
        saved_at = NOW()
      RETURNING *
    `;

    return res.status(201).json({
      success: true,
      message: "Applicant saved successfully",
      saved_applicant: saved[0]
    });

  } catch (error) {
    console.error("[Recruiter] Error saving applicant:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to save applicant"
    });
  }
});

// GET /recruiter/saved-applicants/:recruiter_id - Get saved applicants
router.get("/recruiter/saved-applicants/:recruiter_id", async (req, res) => {
  try {
    const { recruiter_id } = req.params;
    const { page = 1, limit = 10 } = req.query;

    console.log("[Recruiter] Getting saved applicants for:", recruiter_id);

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const savedApplicants = await sql.unsafe(`
      SELECT 
        sa.*,
        a.full_name,
        a.student_email,
        a.university_name,
        a.major,
        a.graduation_year,
        a.cv_url
      FROM saved_applicants sa
      INNER JOIN applicants a ON sa.applicant_id = a.applicant_id
      WHERE sa.recruiter_id = '${recruiter_id}'
      ORDER BY sa.saved_at DESC
      LIMIT ${parseInt(limit)} OFFSET ${offset}
    `);

    return res.status(200).json({
      success: true,
      saved_applicants: savedApplicants
    });

  } catch (error) {
    console.error("[Recruiter] Error getting saved applicants:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get saved applicants"
    });
  }
});

// POST /recruiter/job-templates - Create job template
router.post("/recruiter/job-templates", async (req, res) => {
  try {
    const {
      recruiter_id,
      template_name,
      title,
      role_type,
      employment_type,
      role_overview,
      required_skills,
      perks,
      eligibility,
      tags,
      is_default = false
    } = req.body;

    if (!recruiter_id || !template_name || !title) {
      return res.status(400).json({
        success: false,
        error: "Recruiter ID, template name, and title are required"
      });
    }

    console.log("[Recruiter] Creating job template:", template_name);

    const template = await sql`
      INSERT INTO job_templates (
        recruiter_id,
        template_name,
        title,
        role_type,
        employment_type,
        role_overview,
        required_skills,
        perks,
        eligibility,
        tags,
        is_default
      )
      VALUES (
        ${recruiter_id},
        ${template_name},
        ${title},
        ${role_type || null},
        ${employment_type || null},
        ${role_overview || null},
        ${required_skills || null},
        ${perks || null},
        ${eligibility || null},
        ${tags || null},
        ${is_default}
      )
      RETURNING *
    `;

    return res.status(201).json({
      success: true,
      message: "Job template created successfully",
      template: template[0]
    });

  } catch (error) {
    console.error("[Recruiter] Error creating job template:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to create job template"
    });
  }
});

// GET /recruiter/job-templates/:recruiter_id - Get job templates
router.get("/recruiter/job-templates/:recruiter_id", async (req, res) => {
  try {
    const { recruiter_id } = req.params;

    console.log("[Recruiter] Getting job templates for:", recruiter_id);

    const templates = await sql`
      SELECT * FROM job_templates
      WHERE recruiter_id = ${recruiter_id}
      ORDER BY is_default DESC, template_name ASC
    `;

    return res.status(200).json({
      success: true,
      templates: templates
    });

  } catch (error) {
    console.error("[Recruiter] Error getting job templates:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to get job templates"
    });
  }
});

// POST /recruiter/bulk-actions - Perform bulk actions on applications
router.post("/recruiter/bulk-actions", async (req, res) => {
  try {
    const {
      recruiter_id,
      action_type,
      application_ids,
      new_status,
      notes
    } = req.body;

    if (!recruiter_id || !action_type || !application_ids || application_ids.length === 0) {
      return res.status(400).json({
        success: false,
        error: "Recruiter ID, action type, and application IDs are required"
      });
    }

    console.log("[Recruiter] Performing bulk action:", action_type, "on", application_ids.length, "applications");

    let affectedCount = 0;
    let details = { action_type, application_ids };

    if (action_type === 'status_change' && new_status) {
      const result = await sql`
        UPDATE job_applications ja
        SET status = ${new_status}, updated_at = NOW()
        FROM jobs j
        WHERE ja.job_id = j.id 
          AND j.recruiter_id = ${recruiter_id}
          AND ja.id = ANY(${application_ids})
      `;
      
      affectedCount = result.count;
      details.new_status = new_status;
    }

    // Log the bulk action
    await sql`
      INSERT INTO bulk_actions_log (
        recruiter_id,
        action_type,
        affected_count,
        details
      )
      VALUES (
        ${recruiter_id},
        ${action_type},
        ${affectedCount},
        ${JSON.stringify(details)}
      )
    `;

    return res.status(200).json({
      success: true,
      message: `Bulk ${action_type} completed`,
      affected_count: affectedCount
    });

  } catch (error) {
    console.error("💥 [RECRUITER EXT] Error performing bulk action:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to perform bulk action"
    });
  }
});

module.exports = router;