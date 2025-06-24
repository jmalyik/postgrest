CREATE ROLE anon NOLOGIN;
CREATE ROLE app_user NOLOGIN;

-- Tábla
CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  owner_username TEXT NOT NULL,
  content TEXT NOT NULL
);

-- RLS
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Policy: csak saját sorok
CREATE POLICY user_owns_items ON items
  FOR ALL TO app_user
  USING (owner_username = current_setting('request.jwt.claims.preferred_username', true));

-- Így az admin role-jú felhasználók minden sorhoz hozzáférnek, mások csak a sajátjukhoz.
CREATE POLICY admin_can_all ON items
  FOR ALL TO app_user
  USING (
    current_setting('request.jwt.claims.realm_access.roles', true) LIKE '%"admin"%'
    OR owner_username = current_setting('request.jwt.claims.preferred_username', true)
);

-- Role-hoz csatlakozás
GRANT USAGE ON SCHEMA public TO anon, app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON items TO app_user;
