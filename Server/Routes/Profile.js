
const express = require("express");
const router = express.Router();
const sql = require("../DB/connection");
const supabase = require("../supabaseClient");
const multer = require("multer");

// use memory storage so file.buffer is available
const upload = multer({ storage: multer.memoryStorage() });

// POST /upload
// expects multipart/form-data with field "cv" and body field "applicant_id"
router.post("/upload", upload.single("cv"), async (req, res) => {
  try {
    console.log("File upload request received");
    const { applicant_id } = req.body;
    const file = req.file;

    if (!applicant_id) {
      return res.status(400).json({ error: "Applicant ID is required" });
    }
    if (!file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    const bucket = process.env.SUPABASE_PDF;
    if (!bucket) {
      return res.status(500).json({ error: "Storage bucket not configured" });
    }

    // 0) Ensure applicant exists and get current cv_url (if any)
    const existingRows = await sql`
      SELECT cv_url
      FROM applicants
      WHERE applicant_id = ${applicant_id}
    `;
    if (!existingRows || existingRows.length === 0) {
      return res.status(404).json({ error: "Applicant not found" });
    }
    const currentCvUrl = (existingRows[0] && existingRows[0].cv_url) ? existingRows[0].cv_url : "";

    // Build candidate filenames to remove (covers different naming conventions)
    const candidates = new Set();
    // you said you named the file as the applicant id — include that
    candidates.add(String(applicant_id));
    // also include applicant_id.pdf in case older uploads used extension
    candidates.add(`${String(applicant_id)}.pdf`);

    // if current cv_url exists, try to derive the object key from it and add
    try {
      if (currentCvUrl) {
        // attempt to parse URL and extract last path segment (object key)
        const parsed = new URL(currentCvUrl);
        const pathParts = parsed.pathname.split("/");
        const last = pathParts.pop() || pathParts.pop(); // handle trailing slash
        if (last) candidates.add(last);
      }
    } catch (e) {
      // If URL parsing fails, try naive extraction
      if (currentCvUrl) {
        const idx = currentCvUrl.lastIndexOf("/");
        if (idx >= 0 && idx < currentCvUrl.length - 1) {
          candidates.add(currentCvUrl.substring(idx + 1).split("?")[0]);
        }
      }
    }

    const filenamesToRemove = Array.from(candidates).filter(Boolean);
    if (filenamesToRemove.length > 0) {
      try {
        // remove accepts an array of object keys
        const { error: removeError } = await supabase.storage.from(bucket).remove(filenamesToRemove);
        if (removeError) {
          const msg = (removeError.message || "").toString().toLowerCase();
          // ignore common "not found" messages; otherwise log and continue
          if (!msg.includes("not found") && !msg.includes("could not be found") && !msg.includes("no such key")) {
            // We choose to continue but log so you can debug; if you prefer fail-fast, return 500 here.
            console.error("Non-ignorable remove() error:", removeError);
            // optional: return res.status(500).json({ error: "Failed to remove existing file" });
          } else {
            console.log("No existing file to remove (or already removed).");
          }
        } else {
          console.log("Existing file(s) removed (if they existed):", filenamesToRemove);
        }
      } catch (e) {
        // Unexpected error from remove(); log and continue
        console.warn("Ignored remove() exception (continuing):", e);
      }
    }

    // Prepare upload filename. You told me you name files as the applicant id.
    const filename = String(applicant_id); // change to `${applicant_id}.pdf` if you want extension

    // Upload new file (use upsert: false because we explicitly removed old file)
    const { error: uploadError } = await supabase.storage
      .from(bucket)
      .upload(filename, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    // If uploadError mentions existing resource, it's ok (race) — otherwise return error
    if (uploadError) {
      const em = (uploadError.message || "").toString().toLowerCase();
      if (!em.includes("the resource already exists") && !em.includes("already exists")) {
        console.error("Upload Error:", uploadError);
        return res.status(500).json({ error: "File upload failed" });
      } else {
        console.warn("Upload reported resource already exists (proceeding):", uploadError);
      }
    }

    // Get public URL
    const { data: publicUrlData } = supabase.storage.from(bucket).getPublicUrl(filename);
    const publicUrl = publicUrlData?.publicUrl ?? "";

    // Update DB with the new public URL and return updated row
    try {
      const updated = await sql`
        UPDATE applicants
        SET cv_url = ${publicUrl}
        WHERE applicant_id = ${applicant_id}
        RETURNING *;
      `;

      if (!updated || updated.length === 0) {
        // uploaded but applicant not found in DB (shouldn't happen because we checked earlier)
        // cleanup uploaded file to avoid orphan
        try {
          await supabase.storage.from(bucket).remove([filename]);
        } catch (cleanupErr) {
          console.warn("Failed to cleanup uploaded file after DB not found:", cleanupErr);
        }
        return res.status(404).json({ error: "Applicant not found when updating DB" });
      }

      console.log("Database updated with CV URL for:", applicant_id);
      return res.json({
        message: "Upload successful",
        applicant_id,
        cvUrl: publicUrl,
        applicant: updated[0],
      });
    } catch (err) {
      console.error("Error updating database:", err);
      // cleanup uploaded file to avoid orphan
      try {
        await supabase.storage.from(bucket).remove([filename]);
      } catch (remErr) {
        console.warn("Failed to cleanup uploaded file after DB error:", remErr);
      }
      return res.status(500).json({ error: "Failed to update database" });
    }
  } catch (err) {
    console.error("Server error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
});


router.get("/applicants/:applicant_id", async (req, res) => {
  try {
    if (!req.params.applicant_id) {
      return res.status(400).json({ error: "Applicant ID is required" });
    }
    const applicantId = req.params.applicant_id;
    const applicants = await sql`
      SELECT 
        applicant_id,
        user_id,
        full_name,
        university_name,
        major,
        phone_number,
        student_email,
        cv_url
      FROM applicants
      where applicant_id = ${applicantId}
      ;
    `;
    res.json(applicants);
  } catch (err) {
    console.error("Error fetching applicants:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /applicants/:applicant_id
// Note: using POST to perform a partial update (you asked for POST; PATCH is more RESTful for partial updates).
router.post("/update/:applicant_id", async (req, res) => {
  try {
    const applicantId = req.params.applicant_id;
    if (!applicantId) return res.status(400).json({ error: "Applicant ID is required" });

    // coerce undefined -> null so COALESCE in SQL works reliably
    const {
      full_name = null,
      university_name = null,
      major = null,
      phone_number = null,
      student_email = null,
      cv_url = null,
    } = req.body ?? {};

    // check that at least one real value is provided (not undefined AND not missing completely)
    const anyProvided = Object.keys(req.body ?? {}).some(k =>
      ["full_name","university_name","major","phone_number","student_email","cv_url"].includes(k)
    );
    if (!anyProvided) return res.status(400).json({ error: "No fields provided to update" });

    const updated = await sql`
      UPDATE applicants
      SET
        full_name       = COALESCE(${full_name}, full_name),
        university_name = COALESCE(${university_name}, university_name),
        major           = COALESCE(${major}, major),
        phone_number    = COALESCE(${phone_number}, phone_number),
        student_email   = COALESCE(${student_email}, student_email),
        cv_url          = COALESCE(${cv_url}, cv_url)
      WHERE applicant_id = ${applicantId}
      RETURNING *;
    `;

    if (!updated || updated.length === 0) return res.status(404).json({ error: "Applicant not found" });

    res.json({ success: true, applicant: updated[0] });
  } catch (err) {
    if (err && (err.code === "23505" || err.code === 23505)) {
      const constraint = (err.constraint || err.detail || "").toString();
      if (constraint.includes("student_email")) return res.status(409).json({ error: "Student email already in use" });
      return res.status(409).json({ error: "Unique constraint violation" });
    }

    console.error("Error updating applicant:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});




module.exports = router;