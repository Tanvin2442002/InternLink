
const express = require("express");
const router = express.Router();
const sql = require("../DB/connection");
const supabase = require("../supabaseClient");
const multer = require("multer");

// use memory storage so file.buffer is available
const upload = multer({ storage: multer.memoryStorage() });

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

    const uniqueFileName = applicant_id;

    // try uploading to Supabase
    const { error: uploadError } = await supabase.storage
      .from(process.env.SUPABASE_PDF)
      .upload(uniqueFileName, file.buffer, {
        contentType: file.mimetype,
        upsert: false, // don't overwrite
      });

    if (uploadError && !uploadError.message.includes("The resource already exists")) {
      console.error("Upload Error:", uploadError);
      return res.status(500).json({ error: "File upload failed" });
    }

    // get public URL
    const { data: publicUrlData } = supabase.storage
      .from(process.env.SUPABASE_PDF)
      .getPublicUrl(uniqueFileName);

    try{
      const url = await sql `UPDATE applicants SET cv_url = ${publicUrlData.publicUrl} WHERE applicant_id = ${applicant_id}`;
      console.log("Database updated with CV URL:", url);
      if (url) {
        return res.json({
          message: "Upload successful",
          applicant_id,
          cvUrl: publicUrlData.publicUrl,
        });
      }
    }catch(err){
      console.error("Error updating database:", err);
      return res.status(500).json({ error: "Failed to update database" });
    }

    return res.json({
      message: "Upload successful",
      applicant_id,
      cvUrl: publicUrlData.publicUrl,
    });
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


module.exports = router;