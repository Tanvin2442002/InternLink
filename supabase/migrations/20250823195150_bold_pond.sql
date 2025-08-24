/*
  # Create password reset tokens table

  1. New Tables
    - `password_reset_tokens`
      - `id` (serial, primary key)
      - `user_id` (integer, foreign key to users table)
      - `token` (text, unique reset token)
      - `expires_at` (timestamp, when token expires)
      - `created_at` (timestamp, when token was created)

  2. Security
    - Enable RLS on `password_reset_tokens` table
    - Add unique constraint on user_id to allow only one active token per user
    - Add index on token for fast lookups
    - Add index on expires_at for cleanup queries

  3. Constraints
    - Foreign key constraint to users table
    - Unique constraint on user_id (one token per user)
    - Unique constraint on token
*/

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_password_reset_user 
    FOREIGN KEY (user_id) 
    REFERENCES users(user_id) 
    ON DELETE CASCADE,
  CONSTRAINT unique_user_reset_token 
    UNIQUE (user_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_password_reset_token ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_password_reset_expires ON password_reset_tokens(expires_at);
CREATE INDEX IF NOT EXISTS idx_password_reset_user_id ON password_reset_tokens(user_id);

-- Enable RLS
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;

-- RLS policies (restrictive - only backend should access these)
CREATE POLICY "Service role can manage reset tokens"
  ON password_reset_tokens
  FOR ALL
  TO service_role
  USING (true);

-- Cleanup function for expired tokens (optional)
CREATE OR REPLACE FUNCTION cleanup_expired_reset_tokens()
RETURNS void AS $$
BEGIN
  DELETE FROM password_reset_tokens WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;