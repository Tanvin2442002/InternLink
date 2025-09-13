const express = require("express");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const sql = require("../DB/connection");
const pdfParse = require("pdf-parse");
const https = require("https");
const http = require("http");

const router = express.Router();

// Initialize Gemini
const GEMINI_KEY = process.env.GEMINI_API_KEY;
let model = null;
if (GEMINI_KEY) {
  try {
    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    console.log("🤖 [CHATBOT] Gemini model initialized successfully");
  } catch (e) {
    console.warn("⚠️ [CHATBOT] Gemini init failed:", e.message);
  }
} else {
  console.warn("⚠️ [CHATBOT] GEMINI_API_KEY not found in environment variables");
}

// Fetch PDF content helper function
function fetchPdfBuffer(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith("https") ? https : http;
    client
      .get(url, (res) => {
        if (res.statusCode < 200 || res.statusCode >= 300) {
          return reject(new Error(`Bad status: ${res.statusCode}`));
        }
        const data = [];
        res.on("data", (chunk) => data.push(chunk));
        res.on("end", () => resolve(Buffer.concat(data)));
      })
      .on("error", reject);
  });
}

// GET /chatbot/suggestions - Get CV improvement suggestions
router.get("/chatbot/suggestions/:applicant_id", async (req, res) => {
  try {
    const { applicant_id } = req.params;
    
    if (!applicant_id) {
      return res.status(400).json({
        success: false,
        error: "applicant_id is required"
      });
    }

    if (!model) {
      return res.status(503).json({
        success: false,
        error: "AI service unavailable"
      });
    }

    console.log("[Chatbot] Getting CV suggestions for applicant:", applicant_id);

    // Get applicant's CV URL and profile info
    const applicantRows = await sql`
      SELECT cv_url, full_name, university_name, major, phone_number, student_email
      FROM applicants
      WHERE applicant_id = ${applicant_id}
      LIMIT 1
    `;

    if (!applicantRows || applicantRows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Applicant not found"
      });
    }

    const applicant = applicantRows[0];
    let cvText = "";

    // Extract CV content if available
    if (applicant.cv_url) {
      try {
        console.log("[Chatbot] Fetching CV:", applicant.cv_url);
        const buffer = await fetchPdfBuffer(applicant.cv_url);
        const pdfData = await pdfParse(buffer);
        cvText = pdfData.text || "";
        console.log("[Chatbot] Extracted CV text length:", cvText.length);
      } catch (error) {
        console.warn("[Chatbot] CV fetch/parse failed:", error.message);
      }
    }

    // Create comprehensive prompt for CV analysis
    const prompt = `
You are an expert career advisor and CV reviewer specializing in internship applications. 

APPLICANT PROFILE:
- Name: ${applicant.full_name || 'Not provided'}
- University: ${applicant.university_name || 'Not provided'}
- Major: ${applicant.major || 'Not provided'}
- Email: ${applicant.student_email || 'Not provided'}

CV CONTENT:
${cvText || 'No CV uploaded yet'}

TASK: Provide personalized CV improvement suggestions for this student applying for internships.

ANALYSIS AREAS:
1. **Content & Structure**: Assess overall organization, section clarity, and completeness
2. **Skills Presentation**: Evaluate technical and soft skills listing and evidence
3. **Experience Description**: Review work experience, projects, and achievements quantification
4. **Education & Achievements**: Check academic details and accomplishments
5. **Professional Formatting**: Consider readability, length, and visual appeal
6. **Missing Elements**: Identify key sections or information that should be added

RESPONSE FORMAT:
Provide a JSON response with the following structure:
{
  "overall_score": "rating from 1-10",
  "strengths": ["list of 2-3 current strengths"],
  "priority_improvements": [
    {
      "category": "area to improve",
      "issue": "specific problem identified", 
      "suggestion": "actionable improvement advice",
      "impact": "how this will help their applications"
    }
  ],
  "quick_wins": ["list of 2-3 easy improvements they can make today"],
  "advanced_tips": ["list of 2-3 strategic improvements for competitive advantage"],
  "sector_specific": "advice tailored to their major/target industry"
}

Focus on actionable, specific advice that a student can implement. Be encouraging but honest about areas needing improvement.
`.trim();

    const result = await model.generateContent(prompt);
    const aiResponse = result?.response?.text?.() ?? "";
    console.log("[Chatbot] Gemini CV analysis response length:", aiResponse.length);

    // Parse AI response
    let suggestions = {};
    try {
      // Extract JSON from potential markdown wrapper
      let jsonText = aiResponse;
      if (aiResponse.includes("```json")) {
        const start = aiResponse.indexOf("```json") + 7;
        const end = aiResponse.indexOf("```", start);
        if (end > start) {
          jsonText = aiResponse.slice(start, end).trim();
        }
      } else if (aiResponse.includes("```")) {
        const start = aiResponse.indexOf("```") + 3;
        const end = aiResponse.indexOf("```", start);
        if (end > start) {
          jsonText = aiResponse.slice(start, end).trim();
        }
      }

      // Try to parse as JSON
      const jsonMatch = jsonText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        suggestions = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error("No JSON found in response");
      }
    } catch (error) {
      console.warn("[Chatbot] Failed to parse AI response as JSON:", error.message);
      
      // Fallback: create structured response from text
      suggestions = {
        overall_score: "7",
        strengths: ["CV uploaded and accessible", "Student profile information available"],
        priority_improvements: [
          {
            category: "Content Analysis",
            issue: "Unable to parse detailed CV structure",
            suggestion: "Ensure CV has clear sections: Contact, Education, Experience, Skills, Projects",
            impact: "Better organization makes it easier for recruiters to find key information"
          }
        ],
        quick_wins: ["Add clear section headers", "Use consistent formatting", "Include contact information"],
        advanced_tips: ["Quantify achievements with numbers", "Tailor CV for each application", "Add relevant projects"],
        sector_specific: `For ${applicant.major || 'your field'}, emphasize technical skills and relevant coursework`
      };
    }

    return res.status(200).json({
      success: true,
      suggestions: suggestions,
      hasCV: !!applicant.cv_url,
      cvLength: cvText.length,
      applicantInfo: {
        name: applicant.full_name,
        university: applicant.university_name,
        major: applicant.major
      }
    });

  } catch (error) {
    console.error("[Chatbot] Error generating CV suggestions:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to generate CV suggestions",
      details: error.message
    });
  }
});

// POST /chatbot/chat - General chatbot conversation
router.post("/chatbot/chat", async (req, res) => {
  try {
    const { message, applicant_id, conversation_history = [] } = req.body;
    
    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        error: "Message is required"
      });
    }

    if (!model) {
      return res.status(503).json({
        success: false,
        error: "AI service unavailable"
      });
    }

    console.log("[Chatbot] Processing chat message for applicant:", applicant_id);

    // Get applicant context if provided
    let applicantContext = "";
    if (applicant_id) {
      try {
        const applicantRows = await sql`
          SELECT cv_url, full_name, university_name, major
          FROM applicants
          WHERE applicant_id = ${applicant_id}
          LIMIT 1
        `;
        
        if (applicantRows && applicantRows.length > 0) {
          const applicant = applicantRows[0];
          applicantContext = `
STUDENT CONTEXT:
- Name: ${applicant.full_name || 'Not provided'}
- University: ${applicant.university_name || 'Not provided'}  
- Major: ${applicant.major || 'Not provided'}
- Has CV: ${applicant.cv_url ? 'Yes' : 'No'}
          `.trim();
        }
      } catch (error) {
        console.warn("[Chatbot] Could not fetch applicant context:", error.message);
      }
    }

    // Build conversation context
    let conversationContext = "";
    if (conversation_history.length > 0) {
      conversationContext = "RECENT CONVERSATION:\n" + 
        conversation_history.slice(-6).map(msg => 
          `${msg.role === 'user' ? 'Student' : 'Assistant'}: ${msg.content}`
        ).join('\n') + "\n\n";
    }

    // Create comprehensive chatbot prompt
    const prompt = `
You are InternLink Assistant, an expert career advisor specializing in internships, CV improvement, and job applications. You help students with:

1. **CV/Resume Improvement**: Structure, content, formatting, and industry-specific advice
2. **Interview Preparation**: Common questions, STAR method, technical prep
3. **Application Strategy**: Where to apply, how to tailor applications, follow-up
4. **Career Guidance**: Industry insights, skill development, networking
5. **Internship Search**: Finding opportunities, company research, application timing

${applicantContext}

${conversationContext}

CURRENT QUESTION: ${message}

RESPONSE GUIDELINES:
- Provide specific, actionable advice
- Be encouraging but realistic
- Reference the student's context when relevant
- Keep responses conversational but professional
- Suggest concrete next steps when appropriate
- If asked about CV improvement, offer to provide detailed analysis
- For technical questions, provide practical examples
- Stay focused on internship/career topics

Respond naturally as a helpful career advisor would.
`.trim();

    const result = await model.generateContent(prompt);
    const aiResponse = result?.response?.text?.() ?? "";
    console.log("[Chatbot] Generated response length:", aiResponse.length);

    // Clean up response if needed
    let cleanResponse = aiResponse.trim();
    
    // Remove any markdown formatting that might interfere
    cleanResponse = cleanResponse.replace(/```[\s\S]*?```/g, '');
    cleanResponse = cleanResponse.replace(/^\*\*|\*\*$/g, '');
    
    return res.status(200).json({
      success: true,
      response: cleanResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error("[Chatbot] Error processing chat:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to process chat message",
      details: error.message
    });
  }
});

module.exports = router;