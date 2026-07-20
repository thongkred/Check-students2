-- Migration schema for Cloudflare D1 Database

-- Enable foreign keys (Note: Cloudflare D1 handles foreign keys differently but standard schema applies)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT CHECK(role IN ('Admin', 'Teacher', 'Executive')) NOT NULL,
  prefix TEXT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  line_token TEXT
);

CREATE TABLE IF NOT EXISTS academic_years (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year TEXT NOT NULL,
  term TEXT NOT NULL,
  is_active INTEGER DEFAULT 0,
  UNIQUE(year, term)
);

CREATE TABLE IF NOT EXISTS classrooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  grade_level TEXT NOT NULL,
  room_number TEXT NOT NULL,
  academic_year_id INTEGER NOT NULL,
  advisor_id INTEGER,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
  FOREIGN KEY (advisor_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_code TEXT UNIQUE NOT NULL,
  prefix TEXT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  classroom_id INTEGER NOT NULL,
  roll_number INTEGER,
  parent_line_token TEXT,
  rfid_tag TEXT,
  qr_code TEXT,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attendance_statuses (
  code TEXT PRIMARY KEY,
  name_th TEXT NOT NULL,
  name_en TEXT NOT NULL
);

-- Seed initial statuses
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('PRESENT', 'มา', 'Present');
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('LATE', 'สาย', 'Late');
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('ABSENT', 'ขาด', 'Absent');
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('LEAVE', 'ลา', 'Leave');
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('SICK', 'ป่วย', 'Sick');
INSERT OR IGNORE INTO attendance_statuses (code, name_th, name_en) VALUES ('ACTIVITY', 'กิจกรรม', 'Activity');

CREATE TABLE IF NOT EXISTS attendances (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  attendance_date TEXT NOT NULL,
  status_code TEXT NOT NULL,
  remark TEXT,
  checked_by INTEGER,
  checked_at TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (status_code) REFERENCES attendance_statuses(code),
  FOREIGN KEY (checked_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE(student_id, attendance_date)
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action TEXT NOT NULL,
  details TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Default Admin User (admin / adminpassword123)
-- hash value corresponding to adminpassword123 via bcrypt
INSERT OR IGNORE INTO users (id, username, password_hash, role, prefix, first_name, last_name, email)
VALUES (1, 'admin', '$2a$10$tMh4zN19U0Z4YhNl3bAexOWu0wN9i2F.mBvH8Gg4Lw1h/u6B06P6O', 'Admin', 'นาย', 'ผู้ดูแล', 'ระบบ', 'admin@school.mail');

-- Default academic year
INSERT OR IGNORE INTO academic_years (id, year, term, is_active) VALUES (1, '2569', '1', 1);
