-- Additional tables to enhance the recruiter functionality

-- 1. Application Status History - Track all status changes
CREATE TABLE public.application_status_history (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL,
  recruiter_id UUID NULL,
  old_status TEXT NOT NULL,
  new_status TEXT NOT NULL,
  notes TEXT NULL,
  changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT application_status_history_pkey PRIMARY KEY (id),
  CONSTRAINT application_status_history_application_id_fkey 
    FOREIGN KEY (application_id) REFERENCES job_applications (id) ON DELETE CASCADE,
  CONSTRAINT application_status_history_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE SET NULL
) TABLESPACE pg_default;

-- 2. Recruiter Notifications - For application updates, new applicants etc.
CREATE TABLE public.recruiter_notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,
  type TEXT NOT NULL, -- 'new_application', 'status_change', 'job_expiring', etc.
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  related_job_id UUID NULL,
  related_application_id UUID NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT recruiter_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT recruiter_notifications_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE,
  CONSTRAINT recruiter_notifications_job_id_fkey 
    FOREIGN KEY (related_job_id) REFERENCES jobs (id) ON DELETE SET NULL,
  CONSTRAINT recruiter_notifications_application_id_fkey 
    FOREIGN KEY (related_application_id) REFERENCES job_applications (id) ON DELETE SET NULL
) TABLESPACE pg_default;

-- 3. Interview Schedules - For managing interviews
CREATE TABLE public.interview_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL,
  recruiter_id UUID NOT NULL,
  interview_type TEXT NOT NULL, -- 'phone', 'video', 'in_person', 'technical'
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  location TEXT NULL, -- for in-person or meeting link for video
  status TEXT NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'completed', 'cancelled', 'rescheduled'
  notes TEXT NULL,
  feedback JSONB NULL, -- interviewer feedback
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT interview_schedules_pkey PRIMARY KEY (id),
  CONSTRAINT interview_schedules_application_id_fkey 
    FOREIGN KEY (application_id) REFERENCES job_applications (id) ON DELETE CASCADE,
  CONSTRAINT interview_schedules_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 4. Saved Applicants - For recruiters to save promising candidates
CREATE TABLE public.saved_applicants (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,
  applicant_id UUID NOT NULL,
  tags TEXT[] NULL, -- custom tags like 'high_potential', 'senior_developer', etc.
  notes TEXT NULL,
  saved_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT saved_applicants_pkey PRIMARY KEY (id),
  CONSTRAINT saved_applicants_recruiter_applicant_unique 
    UNIQUE (recruiter_id, applicant_id),
  CONSTRAINT saved_applicants_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE,
  CONSTRAINT saved_applicants_applicant_id_fkey 
    FOREIGN KEY (applicant_id) REFERENCES applicants (applicant_id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 5. Job Templates - For recruiters to save job posting templates
CREATE TABLE public.job_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,
  template_name TEXT NOT NULL,
  title TEXT NOT NULL,
  role_type TEXT NULL,
  employment_type TEXT NULL,
  role_overview JSONB NULL,
  required_skills TEXT[] NULL,
  perks JSONB NULL,
  eligibility JSONB NULL,
  tags TEXT[] NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT job_templates_pkey PRIMARY KEY (id),
  CONSTRAINT job_templates_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 6. Bulk Actions Log - Track bulk operations on applications
CREATE TABLE public.bulk_actions_log (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,
  action_type TEXT NOT NULL, -- 'status_change', 'delete', 'archive'
  affected_count INTEGER NOT NULL,
  details JSONB NULL, -- store details like old/new status, filters used, etc.
  performed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT bulk_actions_log_pkey PRIMARY KEY (id),
  CONSTRAINT bulk_actions_log_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 7. Company Profiles - Extended company information
CREATE TABLE public.company_profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,
  company_name TEXT NOT NULL,
  company_size TEXT NULL, -- 'startup', 'small', 'medium', 'large', 'enterprise'
  industry TEXT NULL,
  founded_year INTEGER NULL,
  headquarters TEXT NULL,
  company_culture JSONB NULL,
  benefits JSONB NULL,
  social_links JSONB NULL, -- LinkedIn, Twitter, etc.
  verification_status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT company_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT company_profiles_recruiter_id_fkey 
    FOREIGN KEY (recruiter_id) REFERENCES recruiters (recruiter_id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- Add indexes for better performance
CREATE INDEX idx_application_status_history_application_id ON application_status_history(application_id);
CREATE INDEX idx_application_status_history_changed_at ON application_status_history(changed_at);
CREATE INDEX idx_recruiter_notifications_recruiter_id ON recruiter_notifications(recruiter_id);
CREATE INDEX idx_recruiter_notifications_is_read ON recruiter_notifications(is_read);
CREATE INDEX idx_interview_schedules_recruiter_id ON interview_schedules(recruiter_id);
CREATE INDEX idx_interview_schedules_scheduled_at ON interview_schedules(scheduled_at);
CREATE INDEX idx_saved_applicants_recruiter_id ON saved_applicants(recruiter_id);
CREATE INDEX idx_job_templates_recruiter_id ON job_templates(recruiter_id);
CREATE INDEX idx_bulk_actions_log_recruiter_id ON bulk_actions_log(recruiter_id);
CREATE INDEX idx_company_profiles_recruiter_id ON company_profiles(recruiter_id);

-- Update jobs table to add missing status column if not exists
-- ALTER TABLE jobs ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';

-- Add triggers for automatic notifications (optional)
-- This would automatically create notifications when new applications come in
CREATE OR REPLACE FUNCTION create_application_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO recruiter_notifications (
    recruiter_id,
    type,
    title,
    message,
    related_job_id,
    related_application_id
  )
  SELECT 
    j.recruiter_id,
    'new_application',
    'New Application Received',
    'You have received a new application for ' || j.title || ' from ' || NEW.full_name,
    NEW.job_id,
    NEW.id
  FROM jobs j
  WHERE j.id = NEW.job_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new applications
DROP TRIGGER IF EXISTS trigger_new_application_notification ON job_applications;
CREATE TRIGGER trigger_new_application_notification
  AFTER INSERT ON job_applications
  FOR EACH ROW
  EXECUTE FUNCTION create_application_notification();