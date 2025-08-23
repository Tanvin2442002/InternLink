// Services/matchService.js
require('dotenv').config();
const http = require("http");
const https = require("https");
const pdfParse = require("pdf-parse");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Initialize Gemini (optional)
const GEMINI_KEY = process.env.GEMINI_API_KEY;
let model = null;
if (GEMINI_KEY) {
  try {
    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    console.log("[matchService] Gemini model initialized");
  } catch (e) {
    console.warn("[matchService] Gemini init failed:", e.message);
  }
}

// fetch PDF buffer (supports http and https)
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

function normalize(s) {
  if (!s) return "";
  return s
    .toString()
    .toLowerCase()
    .replace(/[^\w\s-]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}
function tokensFromText(s) {
  return new Set(normalize(s).split(/\s+/).filter(Boolean));
}

function jobKeywords(job) {
  const list = [];
  if (job.required_skills) list.push(...job.required_skills);
  if (job.eligibility) list.push(...job.eligibility);
  if (job.role_overview) list.push(...job.role_overview);
  if (job.title) list.push(job.title);
  if (job.company_description) list.push(job.company_description);
  if (job.tags) list.push(...job.tags);
  const kw = new Set();
  list.forEach((v) => {
    if (!v) return;
    if (Array.isArray(v)) v.forEach((x) => tokensFromText(x).forEach((t) => kw.add(t)));
    else tokensFromText(v).forEach((t) => kw.add(t));
  });
  return kw;
}

function cvTokensFromParsed(parsedCv, extractedText) {
  const tok = new Set();
  if (parsedCv) {
    if (Array.isArray(parsedCv.skills)) {
      parsedCv.skills.forEach((s) => tokensFromText(s).forEach((t) => tok.add(t)));
    }
    if (parsedCv.experience) {
      if (Array.isArray(parsedCv.experience)) {
        parsedCv.experience.forEach((e) => tokensFromText(e).forEach((t) => tok.add(t)));
      } else {
        tokensFromText(parsedCv.experience).forEach((t) => tok.add(t));
      }
    }
    if (parsedCv.education) tokensFromText(parsedCv.education).forEach((t) => tok.add(t));
    if (parsedCv.summary) tokensFromText(parsedCv.summary).forEach((t) => tok.add(t));
  }
  if (extractedText) tokensFromText(extractedText).forEach((t) => tok.add(t));
  return tok;
}

function computeMatchScore(cvTokens, jobKw) {
  if (!jobKw || jobKw.size === 0) return 0;
  let overlap = 0;
  jobKw.forEach((kw) => {
    if (cvTokens.has(kw)) overlap++;
  });
  return overlap / jobKw.size;
}

async function callGeminiForRefinement(parsedCv, jobs) {
  if (!model) throw new Error("Gemini not configured");
  const trimmedJobs = jobs.map((j) => ({
    id: j.id,
    title: j.title,
    required_skills: j.required_skills || [],
    eligibility: j.eligibility || [],
    role_overview: j.role_overview || [],
  }));

  const prompt = `
You are a job-matching assistant. Given candidate CV (JSON) and jobs (id + fields), return JSON: {"matches": ["job-id-1", ...]}
Match if at least 30% of (required_skills + eligibility) appear in candidate skills/experience.
Candidate: ${JSON.stringify(parsedCv, null, 2)}
Jobs: ${JSON.stringify(trimmedJobs, null, 2)}
Only return valid JSON with {"matches":[...]}
`.trim(); // <- fixed closing brace

  const result = await model.generateContent(prompt);
  const textOut = result?.response?.text?.() ?? "";
  console.log("[matchService] Gemini Response:", textOut);

  // Extract JSON from markdown code blocks or direct JSON
  let jsonText = textOut;
  
  // Remove markdown code block wrapping if present
  if (textOut.includes("```json")) {
    const start = textOut.indexOf("```json") + 7;
    const end = textOut.indexOf("```", start);
    if (end > start) {
      jsonText = textOut.slice(start, end).trim();
    }
  } else if (textOut.includes("```")) {
    // Handle generic code blocks
    const start = textOut.indexOf("```") + 3;
    const end = textOut.indexOf("```", start);
    if (end > start) {
      jsonText = textOut.slice(start, end).trim();
    }
  }

  console.log("[matchService] Extracted JSON text:", jsonText);

  // Try to parse JSON
  const firstBrace = jsonText.indexOf("{");
  if (firstBrace >= 0) {
    const cleanJson = jsonText.slice(firstBrace);
    const lastBrace = cleanJson.lastIndexOf("}");
    if (lastBrace >= 0) {
      const finalJson = cleanJson.slice(0, lastBrace + 1);
      try {
        const parsed = JSON.parse(finalJson);
        if (parsed && Array.isArray(parsed.matches)) {
          console.log("[matchService] Successfully parsed matches:", parsed.matches);
          return parsed.matches;
        }
      } catch (e) {
        console.warn("[matchService] JSON parse error:", e.message);
      }
    }
  }

  // Fallback: extract probable IDs using regex
  console.log("[matchService] Falling back to regex extraction");
  const ids = [];
  const idRegex = /[0-9a-fA-F-]{8,}/g;
  let m;
  while ((m = idRegex.exec(textOut)) !== null) ids.push(m[0]);
  console.log("[matchService] Regex extracted IDs:", ids);
  return ids;
}

function parseBool(v) {
  if (typeof v === "boolean") return v;
  if (typeof v === "number") return v !== 0;
  if (typeof v === "string") return ["1", "true", "yes", "on"].includes(v.toLowerCase());
  return false;
}

/**
 * matchJobs options:
 *  - jobs: array (required)
 *  - parsedCv: object (optional)
 *  - cvUrl: string (optional)
 *  - useGemini: boolean (optional)
 */
async function matchJobs({ jobs, parsedCv = null, cvUrl = null /*, useGemini = false*/ }) {
  if (!jobs || !Array.isArray(jobs)) throw new Error("jobs array is required");

  let extractedText = "";
  if (!parsedCv && cvUrl) {
    try {
      console.log("[matchService] Fetching CV:", cvUrl);
      // ensure you fetch buffer before parsing:
      const buffer = await fetchPdfBuffer(cvUrl);
      const data = await pdfParse(buffer);
      extractedText = data?.text ?? "";
      console.log("[matchService] Extracted CV text length:", extractedText.length);
    } catch (err) {
      console.warn("[matchService] CV fetch/parse failed:", err.message);
    }
  }

  const cvTokens = cvTokensFromParsed(parsedCv || {}, extractedText);
  const scores = jobs.map((job) => {
    const jobKw = jobKeywords(job);
    const score = computeMatchScore(cvTokens, jobKw);
    return { id: job.id, score };
  });

  const localMatches = scores.filter((r) => r.score >= 0.3).map((r) => r.id);

  // Always try Gemini if model is ready; else use local
  const tryGemini = !!model;
  console.log("[matchService] modelReady:", !!model, "usingGemini:", tryGemini);
  console.log("[matchService] Local matches (score >= 0.3):", localMatches.length, "out of", jobs.length, "jobs");

  if (tryGemini) {
    try {
      const geminiParsedCv = parsedCv || { extracted_text: extractedText };
      const geminiMatches = await callGeminiForRefinement(geminiParsedCv, jobs);
      console.log("[matchService] Gemini matches:", geminiMatches);
      console.log("[matchService] Local matches (score >= 0.3):", localMatches);
      
      // Use score-based filtering (0.3+) as the authoritative source
      // Gemini can reorder but not exclude score-qualified jobs
      const scoreBasedMatches = localMatches;
      
      // Optional: reorder score-based matches using Gemini's preference
      const reorderedMatches = [];
      geminiMatches.forEach(id => {
        if (scoreBasedMatches.includes(id)) {
          reorderedMatches.push(id);
        }
      });
      // Add any remaining score-based matches that Gemini didn't mention
      scoreBasedMatches.forEach(id => {
        if (!reorderedMatches.includes(id)) {
          reorderedMatches.push(id);
        }
      });
      
      console.log("[matchService] Final matches (score-based + Gemini reordered):", reorderedMatches);
      return { matches: reorderedMatches, scores, source: "gemini_reordered" };
    } catch (err) {
      console.warn("[matchService] Gemini error:", err.message);
      return { matches: localMatches, scores, source: "local", geminiError: err.message };
    }
  }
  return { matches: localMatches, scores, source: "local" };
}

module.exports = { matchJobs };
