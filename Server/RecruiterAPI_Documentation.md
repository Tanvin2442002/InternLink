# InternLink Recruiter API Documentation

## Overview
Complete API documentation for the InternLink recruiter management system. This system provides comprehensive functionality for recruiters to manage their profiles, job postings, applications, interviews, and candidate relationships.

## Base URL
```
http://localhost:5000/api
```

## Database Schema

### Core Tables
1. **recruiters** - Recruiter profiles and company information
2. **jobs** - Job postings created by recruiters
3. **job_applications** - Applications submitted by students

### Extended Tables
4. **application_status_history** - Track all status changes for applications
5. **recruiter_notifications** - System notifications for recruiters
6. **interview_schedules** - Interview scheduling and management
7. **saved_applicants** - Recruiter's saved candidate profiles
8. **job_templates** - Reusable job posting templates
9. **bulk_actions_log** - Audit log for bulk operations
10. **company_profiles** - Extended company information and branding

## API Endpoints

### Recruiter Profile Management

#### GET `/recruiter/profile/:recruiter_id`
Get recruiter profile information
- **Parameters**: `recruiter_id` (string)
- **Response**: Recruiter profile data
```json
{
  "success": true,
  "recruiter": {
    "recruiter_id": "uuid",
    "full_name": "John Doe",
    "company_name": "TechCorp",
    "company_email": "john@techcorp.com",
    "company_phone": "+1234567890",
    "company_website": "https://techcorp.com",
    "location": "New York, NY",
    "industry": "Technology",
    "company_size": "100-500",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

#### PUT `/recruiter/profile/:recruiter_id`
Update recruiter profile
- **Parameters**: `recruiter_id` (string)
- **Body**: Updated profile fields
```json
{
  "full_name": "John Smith",
  "company_name": "TechCorp Inc",
  "location": "San Francisco, CA",
  "industry": "SaaS",
  "company_size": "500-1000"
}
```

### Job Management

#### POST `/recruiter/jobs`
Create a new job posting
- **Body**: Job details
```json
{
  "recruiter_id": "uuid",
  "title": "Software Engineer Intern",
  "role_type": "Full-time",
  "employment_type": "Internship",
  "role_overview": "Join our engineering team...",
  "required_skills": "JavaScript, React, Node.js",
  "perks": "Health insurance, free lunch",
  "eligibility": "Computer Science students",
  "tags": "frontend,backend,fullstack"
}
```

#### GET `/recruiter/jobs/:recruiter_id`
Get all jobs for a recruiter
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**: 
  - `page` (number, default: 1)
  - `limit` (number, default: 10)
  - `status` (string, optional: "active", "inactive", "expired")
- **Response**: Paginated job listings

#### PUT `/recruiter/jobs/:job_id`
Update a job posting
- **Parameters**: `job_id` (string)
- **Body**: Updated job fields

#### DELETE `/recruiter/jobs/:job_id`
Delete/deactivate a job posting
- **Parameters**: `job_id` (string)

### Application Management

#### GET `/recruiter/applications/:recruiter_id`
Get all applications for recruiter's jobs
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**:
  - `page` (number, default: 1)
  - `limit` (number, default: 10)
  - `status` (string, optional)
  - `job_id` (string, optional)
- **Response**: Applications with applicant and job details

#### PUT `/recruiter/applications/:application_id/status`
Update application status
- **Parameters**: `application_id` (string)
- **Body**:
```json
{
  "status": "reviewed",
  "recruiter_notes": "Strong candidate, schedule interview"
}
```

#### GET `/recruiter/applications/:application_id/history`
Get status history for an application
- **Parameters**: `application_id` (string)
- **Response**: Timeline of status changes

### Analytics Dashboard

#### GET `/recruiter/analytics/:recruiter_id`
Get comprehensive analytics for recruiter
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**:
  - `period` (string: "week", "month", "quarter", default: "month")
- **Response**: 
```json
{
  "success": true,
  "analytics": {
    "total_jobs": 15,
    "active_jobs": 8,
    "total_applications": 142,
    "applications_by_status": {
      "applied": 45,
      "reviewed": 32,
      "shortlisted": 28,
      "interviewed": 15,
      "offered": 8,
      "hired": 5,
      "rejected": 9
    },
    "recent_activity": [...],
    "top_performing_jobs": [...],
    "application_trends": [...]
  }
}
```

### Notifications

#### GET `/recruiter/notifications/:recruiter_id`
Get recruiter notifications
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**:
  - `page` (number, default: 1)
  - `limit` (number, default: 20)
  - `unread_only` (boolean, default: false)
- **Response**: Notifications with unread count

#### PUT `/recruiter/notifications/:notification_id/read`
Mark notification as read
- **Parameters**: `notification_id` (string)

### Interview Management

#### POST `/recruiter/interviews`
Schedule an interview
- **Body**:
```json
{
  "application_id": "uuid",
  "recruiter_id": "uuid",
  "interview_type": "phone",
  "scheduled_at": "2024-01-15T14:00:00Z",
  "duration_minutes": 60,
  "location": "Google Meet",
  "notes": "Technical interview focusing on algorithms"
}
```

#### GET `/recruiter/interviews/:recruiter_id`
Get all interviews for recruiter
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**:
  - `status` (string, optional)
  - `date_from` (string, optional)
  - `date_to` (string, optional)

#### PUT `/recruiter/interviews/:interview_id`
Update interview details
- **Parameters**: `interview_id` (string)
- **Body**: Updated interview fields including feedback

### Saved Applicants

#### POST `/recruiter/saved-applicants`
Save an applicant for future reference
- **Body**:
```json
{
  "recruiter_id": "uuid",
  "applicant_id": "uuid",
  "tags": "frontend,experienced,relocatable",
  "notes": "Strong React skills, available for relocation"
}
```

#### GET `/recruiter/saved-applicants/:recruiter_id`
Get saved applicants
- **Parameters**: `recruiter_id` (string)
- **Query Parameters**:
  - `page` (number, default: 1)
  - `limit` (number, default: 10)

### Job Templates

#### POST `/recruiter/job-templates`
Create a reusable job template
- **Body**: Template details including all job fields
```json
{
  "recruiter_id": "uuid",
  "template_name": "Software Engineer Template",
  "title": "Software Engineer Intern",
  "role_type": "Internship",
  "employment_type": "Full-time",
  "role_overview": "Template overview...",
  "required_skills": "Programming, Problem Solving",
  "perks": "Standard perks package",
  "eligibility": "CS/IT students",
  "tags": "engineering,intern",
  "is_default": false
}
```

#### GET `/recruiter/job-templates/:recruiter_id`
Get all job templates for recruiter
- **Parameters**: `recruiter_id` (string)

### Bulk Operations

#### POST `/recruiter/bulk-actions`
Perform bulk actions on multiple applications
- **Body**:
```json
{
  "recruiter_id": "uuid",
  "action_type": "status_change",
  "application_ids": ["uuid1", "uuid2", "uuid3"],
  "new_status": "reviewed",
  "notes": "Bulk review completed"
}
```

## Status Codes and Error Handling

### Success Responses
- `200 OK` - Successful GET/PUT operations
- `201 Created` - Successful POST operations

### Error Responses
- `400 Bad Request` - Invalid request data or missing required fields
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### Error Response Format
```json
{
  "success": false,
  "error": "Detailed error message"
}
```

## Database Triggers and Automation

### Automatic Notifications
The system automatically creates notifications for:
- New applications received
- Application status changes
- Interview scheduling
- Job posting expiration warnings

### Audit Logging
All critical operations are logged in `bulk_actions_log` table for compliance and tracking.

## Usage Examples

### Complete Job Posting Flow
1. Create job from template: `GET /recruiter/job-templates/{id}` → `POST /recruiter/jobs`
2. Monitor applications: `GET /recruiter/applications/{recruiter_id}`
3. Review and update status: `PUT /recruiter/applications/{id}/status`
4. Schedule interviews: `POST /recruiter/interviews`
5. Track analytics: `GET /recruiter/analytics/{recruiter_id}`

### Candidate Management Flow
1. Review applications: `GET /recruiter/applications/{recruiter_id}`
2. Save interesting candidates: `POST /recruiter/saved-applicants`
3. Schedule interviews: `POST /recruiter/interviews`
4. Update with feedback: `PUT /recruiter/interviews/{id}`
5. Make hiring decisions: `PUT /recruiter/applications/{id}/status`

## Integration Notes

- All timestamps are in ISO 8601 format (UTC)
- UUIDs are used for all entity identifiers
- Pagination is supported for list operations
- All routes include comprehensive error handling
- Database transactions ensure data consistency
- Notifications are automatically generated for key events

## Testing

Use tools like Postman or curl to test the API endpoints:

```bash
# Get recruiter profile
curl -X GET http://localhost:5000/api/recruiter/profile/{recruiter_id}

# Create job posting
curl -X POST http://localhost:5000/api/recruiter/jobs \
  -H "Content-Type: application/json" \
  -d '{"recruiter_id":"uuid","title":"Software Engineer","role_type":"Internship"}'
```

This API provides a complete foundation for recruiter functionality in the InternLink platform.