-- 🔧 CORRECTION POUR TA BASE rh_xtensus
-- Script adapté pour ta vraie base de données

USE rh_xtensus;

-- ========================================
-- 1. TABLE DES TYPES DE CONGÉ (NOUVELLE)
-- ========================================

CREATE TABLE flutter_leave_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_days_per_year INT DEFAULT 30,
    requires_justification BOOLEAN DEFAULT FALSE,
    advance_notice_hours INT DEFAULT 72,
    is_active BOOLEAN DEFAULT TRUE,
    color_hex VARCHAR(7) DEFAULT '#FF6B35',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer les types standards
INSERT INTO flutter_leave_types (id, code, name, description, max_days_per_year, advance_notice_hours) VALUES
(1, 'CONGE_ANNUEL', 'Congé annuel', 'Congé payé annuel standard', 30, 72),
(2, 'AUTORISATION_ABSENCE', 'Autorisation d\'absence', 'Autorisation d\'absence de courte durée', 5, 48),
(3, 'CONGE_MALADIE', 'Congé maladie', 'Congé pour raison médicale', 90, 0),
(4, 'CONGE_EXCEPTIONNEL', 'Congé exceptionnel', 'Congé pour événement familial', 10, 48);

-- ========================================
-- 2. TABLE DES DEMANDES DE CONGÉ (NOUVELLE)
-- ========================================

CREATE TABLE flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- 👤 UTILISATEURS
    requester_id BIGINT NOT NULL,
    approver_id BIGINT NULL,
    
    -- 📋 TYPE ET DÉTAILS
    leave_type_id INT NOT NULL,
    
    -- 📅 DATES ET DURÉE
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    requested_days DECIMAL(5,2) NOT NULL,
    
    -- ⏰ HEURES (Pour autorisation d'absence)
    start_time TIME NULL,
    end_time TIME NULL,
    
    -- 📝 DÉTAILS
    reason TEXT,
    employee_comment TEXT,
    
    -- ✅ STATUS ET APPROBATION
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    
    -- 📅 SUIVI DES DATES
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    decision_comment TEXT,
    rejection_reason ENUM('INSUFFICIENT_BALANCE', 'PEAK_PERIOD', 'TEAM_COVERAGE', 'ADVANCE_NOTICE', 'OTHER') NULL,
    
    -- 📱 MÉTADONNÉES FLUTTER
    created_from VARCHAR(50) DEFAULT 'FLUTTER_APP',
    app_version VARCHAR(20) DEFAULT '1.0.0',
    
    -- 🔗 INDEX ET CONTRAINTES
    INDEX idx_requester (requester_id),
    INDEX idx_approver (approver_id),
    INDEX idx_leave_type (leave_type_id),
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_submitted (submitted_at),
    
    -- Foreign Keys (adaptées à tes tables existantes)
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (leave_type_id) REFERENCES flutter_leave_types(id) ON DELETE RESTRICT
);

-- ========================================
-- 3. TABLE DES SOLDES DE CONGÉ (NOUVELLE)
-- ========================================

CREATE TABLE flutter_leave_balances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    user_id BIGINT NOT NULL,
    leave_type_id INT NOT NULL,
    year INT NOT NULL,
    
    -- 📊 SOLDES
    allocated_days DECIMAL(5,2) DEFAULT 0,
    used_days DECIMAL(5,2) DEFAULT 0,
    pending_days DECIMAL(5,2) DEFAULT 0,
    remaining_days DECIMAL(5,2) GENERATED ALWAYS AS (allocated_days - used_days - pending_days) STORED,
    
    -- 📅 SUIVI
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by BIGINT NULL,
    
    -- 🔗 CONTRAINTES
    UNIQUE KEY unique_user_type_year (user_id, leave_type_id, year),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES flutter_leave_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ========================================
-- 4. INITIALISATION DES SOLDES
-- ========================================

-- Créer des soldes pour tous les utilisateurs existants
INSERT IGNORE INTO flutter_leave_balances (user_id, leave_type_id, year, allocated_days)
SELECT 
    u.id,
    flt.id,
    YEAR(CURDATE()),
    flt.max_days_per_year
FROM users u
CROSS JOIN flutter_leave_types flt
WHERE (u.enabled = TRUE OR u.enabled IS NULL)
  AND flt.is_active = TRUE;

-- ========================================
-- 5. VÉRIFICATIONS FINALES
-- ========================================

SELECT 'STRUCTURE FLUTTER CRÉÉE AVEC SUCCÈS DANS rh_xtensus !' as status;

-- Compter les données créées
SELECT 
    (SELECT COUNT(*) FROM flutter_leave_types) as leave_types_count,
    (SELECT COUNT(*) FROM flutter_leave_balances) as balances_count,
    (SELECT COUNT(*) FROM users WHERE enabled = TRUE OR enabled IS NULL) as active_users_count;

-- Afficher les types disponibles
SELECT * FROM flutter_leave_types WHERE is_active = TRUE;

-- Afficher quelques soldes
SELECT 
    flb.user_id,
    CONCAT(u.firstName, ' ', u.lastName) as user_name,
    flt.name as leave_type,
    flb.allocated_days,
    flb.used_days,
    flb.remaining_days
FROM flutter_leave_balances flb
JOIN users u ON flb.user_id = u.id
JOIN flutter_leave_types flt ON flb.leave_type_id = flt.id
LIMIT 10;

SELECT '🎉 PRÊT POUR FLUTTER ! Tes utilisateurs peuvent maintenant créer des demandes.' as final_message;