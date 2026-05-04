-- PLCIOsim Offline — Schéma SQLite
-- Exécuté automatiquement au premier démarrage

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

-- ─────────────────────────────────────────────
-- UTILISATEURS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    username    TEXT    UNIQUE NOT NULL,
    email       TEXT    UNIQUE,
    password    TEXT    NOT NULL,
    role        TEXT    DEFAULT 'user' CHECK(role IN ('user','admin')),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Utilisateur par défaut (offline — pas de compte requis)
INSERT OR IGNORE INTO users (id, username, email, password, role)
VALUES (1, 'local', 'local@plciosim.local', '$2y$12$placeholder', 'admin');

-- ─────────────────────────────────────────────
-- PROJETS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER DEFAULT 1 REFERENCES users(id) ON DELETE CASCADE,
    title       TEXT    NOT NULL,
    description TEXT    DEFAULT '',
    program     TEXT    NOT NULL DEFAULT '{"tags":[],"rungs":[]}',  -- JSON
    scene       TEXT    DEFAULT NULL,                               -- Nom scène
    io_config   TEXT    DEFAULT '{"inputs":[],"outputs":[]}',       -- JSON config I/O
    is_shared   INTEGER DEFAULT 0,
    upvotes     INTEGER DEFAULT 0,
    tags_meta   TEXT    DEFAULT '[]',      -- JSON — liste d'instructions utilisées
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Trigger pour updated_at automatique
CREATE TRIGGER IF NOT EXISTS projects_updated_at
    AFTER UPDATE ON projects
    BEGIN
        UPDATE projects SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

-- ─────────────────────────────────────────────
-- EXEMPLES (seeds — lecture seule)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS examples (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    order_num        INTEGER DEFAULT 0,
    title            TEXT    NOT NULL,
    description      TEXT    NOT NULL DEFAULT '',
    program          TEXT    NOT NULL DEFAULT '{"tags":[],"rungs":[]}',  -- JSON
    scene            TEXT    DEFAULT NULL,
    io_devices       TEXT    DEFAULT '[]',        -- JSON
    instructions_used TEXT   DEFAULT '[]'         -- JSON
);

-- ─────────────────────────────────────────────
-- CHALLENGES / PROBLEMS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS problems (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    order_num        INTEGER DEFAULT 0,
    title            TEXT    NOT NULL,
    description      TEXT    NOT NULL,
    difficulty       TEXT    DEFAULT 'EASY' CHECK(difficulty IN ('EASY','MEDIUM','HARD')),
    scene            TEXT    DEFAULT NULL,
    io_config        TEXT    NOT NULL DEFAULT '{"inputs":[],"outputs":[]}',   -- JSON
    test_vectors     TEXT    NOT NULL DEFAULT '[]',   -- JSON
    program_template TEXT    DEFAULT NULL             -- JSON (template optionnel)
);

-- ─────────────────────────────────────────────
-- SOLUTIONS (challenges résolus)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS completions (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id      INTEGER DEFAULT 1 REFERENCES users(id),
    problem_id   INTEGER REFERENCES problems(id),
    program      TEXT    DEFAULT NULL,       -- JSON — solution soumise
    attempts     INTEGER DEFAULT 1,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, problem_id)
);

-- ─────────────────────────────────────────────
-- HISTORIQUE IA
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ai_history (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER DEFAULT 1 REFERENCES users(id),
    session_id TEXT    NOT NULL,
    role       TEXT    CHECK(role IN ('user','assistant','system')),
    content    TEXT    NOT NULL,
    tokens     INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- PARAMÈTRES UTILISATEUR
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_settings (
    user_id       INTEGER PRIMARY KEY DEFAULT 1 REFERENCES users(id),
    theme         TEXT    DEFAULT 'light' CHECK(theme IN ('light','dark')),
    layout        INTEGER DEFAULT 1 CHECK(layout IN (1,2,3)),
    language      TEXT    DEFAULT 'fr',
    scan_cycle_ms INTEGER DEFAULT 50,
    ai_enabled    INTEGER DEFAULT 1,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Settings par défaut pour l'utilisateur local
INSERT OR IGNORE INTO user_settings (user_id) VALUES (1);

-- ─────────────────────────────────────────────
-- INDEX POUR PERFORMANCE
-- ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_projects_user    ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_shared  ON projects(is_shared);
CREATE INDEX IF NOT EXISTS idx_completions_user ON completions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_session       ON ai_history(session_id);
CREATE INDEX IF NOT EXISTS idx_examples_order   ON examples(order_num);
CREATE INDEX IF NOT EXISTS idx_problems_order   ON problems(order_num);
