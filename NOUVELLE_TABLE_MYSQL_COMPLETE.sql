-- 🚀 NOUVELLE STRUCTURE MYSQL COMPLÈTE POUR XCONGES
-- Cette structure supportera tout le workflow : Employé → Manager → Historique

USE leaveapp;

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
    device_info JSON NULL,
    
    -- 🔗 INDEX ET CONTRAINTES
    INDEX idx_requester (requester_id),
    INDEX idx_approver (approver_id),
    INDEX idx_leave_type (leave_type_id),
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_submitted (submitted_at),
    
    -- Foreign Keys
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
-- 4. HISTORIQUE DES ACTIONS (NOUVELLE)
-- ========================================

CREATE TABLE flutter_leave_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    leave_request_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    action_type ENUM('CREATED', 'SUBMITTED', 'APPROVED', 'REJECTED', 'CANCELLED', 'MODIFIED') NOT NULL,
    
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    
    comment TEXT,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    FOREIGN KEY (leave_request_id) REFERENCES flutter_leave_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_request (leave_request_id),
    INDEX idx_user (user_id),
    INDEX idx_action_date (action_date)
);

-- ========================================
-- 5. INITIALISATION DES SOLDES
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
WHERE u.enabled = TRUE 
  AND flt.is_active = TRUE;

-- ========================================
-- 6. VUES POUR FACILITER LES REQUÊTES
-- ========================================

-- Vue complète des demandes avec toutes les infos
CREATE OR REPLACE VIEW flutter_leave_requests_complete AS
SELECT 
    flr.id,
    flr.requester_id,
    CONCAT(req.firstName, ' ', req.lastName) as requester_name,
    req.email as requester_email,
    
    flr.approver_id,
    CONCAT(app.firstName, ' ', app.lastName) as approver_name,
    
    flr.leave_type_id,
    flt.name as leave_type_name,
    flt.code as leave_type_code,
    flt.color_hex,
    
    flr.start_date,
    flr.end_date,
    flr.start_time,
    flr.end_time,
    flr.requested_days,
    flr.reason,
    flr.employee_comment,
    flr.status,
    flr.submitted_at,
    flr.reviewed_at,
    flr.decision_comment,
    flr.rejection_reason,
    flr.created_from,
    
    -- Calculs utiles
    DATEDIFF(flr.end_date, flr.start_date) + 1 as calendar_days,
    CASE 
        WHEN flr.status = 'PENDING' THEN '⏳'
        WHEN flr.status = 'APPROVED' THEN '✅'
        WHEN flr.status = 'REJECTED' THEN '❌'
        WHEN flr.status = 'CANCELLED' THEN '🚫'
    END as status_icon
    
FROM flutter_leave_requests flr
JOIN users req ON flr.requester_id = req.id
LEFT JOIN users app ON flr.approver_id = app.id  
JOIN flutter_leave_types flt ON flr.leave_type_id = flt.id
ORDER BY flr.submitted_at DESC;

-- Vue des soldes avec calculs
CREATE OR REPLACE VIEW flutter_balances_summary AS
SELECT 
    flb.user_id,
    CONCAT(u.firstName, ' ', u.lastName) as user_name,
    u.email,
    
    flb.year,
    
    SUM(flb.allocated_days) as total_allocated,
    SUM(flb.used_days) as total_used,
    SUM(flb.pending_days) as total_pending,
    SUM(flb.remaining_days) as total_remaining,
    
    -- Détail par type
    GROUP_CONCAT(
        CONCAT(flt.name, ': ', flb.remaining_days, '/', flb.allocated_days)
        SEPARATOR ' | '
    ) as balance_details
    
FROM flutter_leave_balances flb
JOIN users u ON flb.user_id = u.id
JOIN flutter_leave_types flt ON flb.leave_type_id = flt.id
GROUP BY flb.user_id, flb.year
ORDER BY u.lastName, u.firstName;

-- ========================================
-- 7. TRIGGERS POUR AUTOMATISER LA GESTION
-- ========================================

DELIMITER //

-- Trigger pour mettre à jour les soldes automatiquement
CREATE TRIGGER update_leave_balance_on_approval
AFTER UPDATE ON flutter_leave_requests
FOR EACH ROW
BEGIN
    -- Quand une demande est approuvée
    IF NEW.status = 'APPROVED' AND OLD.status = 'PENDING' THEN
        -- Déplacer de pending vers used
        UPDATE flutter_leave_balances 
        SET 
            used_days = used_days + NEW.requested_days,
            pending_days = pending_days - NEW.requested_days
        WHERE user_id = NEW.requester_id 
          AND leave_type_id = NEW.leave_type_id 
          AND year = YEAR(NEW.start_date);
        
        -- Enregistrer dans l'historique
        INSERT INTO flutter_leave_history (leave_request_id, user_id, action_type, old_status, new_status, comment)
        VALUES (NEW.id, NEW.approver_id, 'APPROVED', OLD.status, NEW.status, NEW.decision_comment);
    END IF;
    
    -- Quand une demande est rejetée
    IF NEW.status = 'REJECTED' AND OLD.status = 'PENDING' THEN
        -- Libérer les jours pending
        UPDATE flutter_leave_balances 
        SET pending_days = pending_days - NEW.requested_days
        WHERE user_id = NEW.requester_id 
          AND leave_type_id = NEW.leave_type_id 
          AND year = YEAR(NEW.start_date);
        
        -- Enregistrer dans l'historique
        INSERT INTO flutter_leave_history (leave_request_id, user_id, action_type, old_status, new_status, comment)
        VALUES (NEW.id, NEW.approver_id, 'REJECTED', OLD.status, NEW.status, NEW.decision_comment);
    END IF;
END//

-- Trigger pour réserver les jours à la soumission
CREATE TRIGGER reserve_days_on_submission
AFTER INSERT ON flutter_leave_requests
FOR EACH ROW
BEGIN
    -- Réserver les jours dans pending
    UPDATE flutter_leave_balances 
    SET pending_days = pending_days + NEW.requested_days
    WHERE user_id = NEW.requester_id 
      AND leave_type_id = NEW.leave_type_id 
      AND year = YEAR(NEW.start_date);
    
    -- Enregistrer dans l'historique
    INSERT INTO flutter_leave_history (leave_request_id, user_id, action_type, new_status, comment)
    VALUES (NEW.id, NEW.requester_id, 'CREATED', NEW.status, 'Demande créée depuis Flutter');
END//

DELIMITER ;

-- ========================================
-- 8. VÉRIFICATIONS FINALES
-- ========================================

SELECT 'STRUCTURE FLUTTER CRÉÉE AVEC SUCCÈS !' as status;

-- Compter les données créées
SELECT 
    (SELECT COUNT(*) FROM flutter_leave_types) as leave_types_count,
    (SELECT COUNT(*) FROM flutter_leave_balances) as balances_count,
    (SELECT COUNT(*) FROM users WHERE enabled = TRUE) as active_users_count;

-- Afficher les types disponibles
SELECT * FROM flutter_leave_types WHERE is_active = TRUE;

-- Afficher quelques soldes
SELECT * FROM flutter_balances_summary LIMIT 5;

SELECT '🎉 PRÊT POUR FLUTTER ! Vos utilisateurs peuvent maintenant créer des demandes.' as final_message;