CREATE ROLE anon NOLOGIN;
CREATE ROLE app_user NOLOGIN;

-- Table
CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  owner_username TEXT NOT NULL,
  content TEXT NOT NULL
);

-- Enable Row Level Security
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Policy: users can only access their own rows
CREATE POLICY user_owns_items ON items
  FOR ALL TO app_user
  USING (owner_username = current_setting('request.jwt.claims.preferred_username', true));

-- Policy: admin role users can access all rows, others only their own
CREATE POLICY admin_can_all ON items
  FOR ALL TO app_user
  USING (
    current_setting('request.jwt.claims.realm_access.roles', true) LIKE '%"admin"%'
    OR owner_username = current_setting('request.jwt.claims.preferred_username', true)
);

-- Policy: allow insert for users with "user" role in JWT
CREATE POLICY user_can_insert ON items
  FOR INSERT TO app_user
  WITH CHECK (
    current_setting('request.jwt.claims.realm_access.roles', true) LIKE '%"app_user"%'
  );

-- Grant schema and table privileges to roles
GRANT USAGE ON SCHEMA public TO anon, app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON items TO app_user;
