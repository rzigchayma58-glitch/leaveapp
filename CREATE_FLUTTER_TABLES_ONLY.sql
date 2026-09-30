-- 🚀 NOUVELLES TABLES DÉDIÉES FLUTTER XCONGES
-- Tables séparées pour éviter de modifier l'existant
-- Exécutez seulement ce script dans votre base leaveapp

USE leaveapp;

-- =====================================
-- 1. TABLE FLUTTER_LEAVE_TYPES (NOUVELLE)
-- =====================================

CREATE TABLE flutter_leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer les types pour Flutter
INSERT INTO flutter_leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée sans décompte', 1);

-- =====================================
-- 2. TABLE FLUTTER_LEAVE_REQUESTS (NOUVELLE)
-- =====================================

CREATE TABLE flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Relations utilisateur
    requesterId BIGINT NOT NULL,
    approverId BIGINT NULL,
    
    -- Type de congé
    leaveTypeId BIGINT NOT NULL,
    
    -- Dates et durée
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    requestedDays DECIMAL(5,2) DEFAULT 1.0,
    
    -- Détails
    reason TEXT,
    
    -- Status et suivi
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    decisionAt TIMESTAMP NULL,
    decisionComment TEXT,
    
    -- Métadonnées Flutter
    created_from VARCHAR(50) DEFAULT 'FLUTTER_APP',
    device_info TEXT,
    app_version VARCHAR(20) DEFAULT '1.0.0',
    
    -- Index et contraintes
    INDEX idx_requester (requesterId),
    INDEX idx_approver (approverId),
    INDEX idx_leave_type (leaveTypeId),
    INDEX idx_status (status),
    INDEX idx_submitted (submittedAt),
    
    -- Foreign keys vers tables existantes
    FOREIGN KEY (requesterId) REFERENCES users(id),
    FOREIGN KEY (approverId) REFERENCES users(id),
    FOREIGN KEY (leaveTypeId) REFERENCES flutter_leave_types(id)
);

-- =====================================
-- 3. TABLE FLUTTER_LEAVE_BALANCES (NOUVELLE)
-- =====================================

CREATE TABLE flutter_leave_balances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    userId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    year INT NOT NULL,
    
    -- Soldes
    totalDays DECIMAL(5,2) DEFAULT 0,
    usedDays DECIMAL(5,2) DEFAULT 0,
    remainingDays DECIMAL(5,2) GENERATED ALWAYS AS (totalDays - usedDays) STORED,
    
    -- Suivi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Contraintes
    UNIQUE KEY unique_flutter_balance (userId, leaveTypeId, year),
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (leaveTypeId) REFERENCES flutter_leave_types(id)
);

-- =====================================
-- 4. SOLDES INITIAUX POUR UTILISATEURS EXISTANTS
-- =====================================

-- Créer des soldes par défaut pour tous les utilisateurs existants
INSERT IGNORE INTO flutter_leave_balances (userId, leaveTypeId, year, totalDays, usedDays)
SELECT 
    u.id as userId,
    flt.id as leaveTypeId,
    YEAR(CURDATE()) as year,
    CASE 
        WHEN flt.id = 1 THEN 30.0  -- Congé annuel: 30 jours
        WHEN flt.id = 2 THEN 90.0  -- Congé maladie: 90 jours  
        WHEN flt.id = 3 THEN 5.0   -- Congé exceptionnel: 5 jours
        WHEN flt.id = 4 THEN 0.0   -- Autorisation: pas de solde
        ELSE 0.0
    END as totalDays,
    0.0 as usedDays
FROM users u
CROSS JOIN flutter_leave_types flt
WHERE u.enabled = true OR u.enabled IS NULL;

-- =====================================  
-- 5. DEMANDES DE TEST POUR VÉRIFIER
-- =====================================

-- Créer quelques demandes de test avec vos utilisateurs existants
INSERT INTO flutter_leave_requests 
(leaveTypeId, requesterId, startDate, endDate, requestedDays, reason, status, created_from)
SELECT 
    1 as leaveTypeId, -- Congé annuel
    u.id as requesterId,
    DATE_ADD(CURDATE(), INTERVAL 7 DAY) as startDate,
    DATE_ADD(CURDATE(), INTERVAL 11 DAY) as endDate,
    5.0 as requestedDays,
    CONCAT('Demande test pour ', u.firstName) as reason,
    'PENDING' as status,
    'MYSQL_SETUP' as created_from
FROM users u 
WHERE u.email IN ('aa.bb@xtensus.com', 'chaimaa.rz@xtensus.com')
LIMIT 2;

-- =====================================
-- 6. VUES POUR FACILITER LES REQUÊTES FLUTTER
-- =====================================

-- Vue complète des demandes avec infos utilisateur et type
CREATE OR REPLACE VIEW flutter_leave_requests_view AS
SELECT 
    flr.id,
    flr.requesterId,
    CONCAT(req.firstName, ' ', req.lastName) as requesterName,
    req.email as requesterEmail,
    
    flr.approverId,
    CONCAT(app.firstName, ' ', app.lastName) as approverName,
    app.email as approverEmail,
    
    flr.leaveTypeId,
    flt.name as leaveTypeName,
    flt.description as leaveTypeDescription,
    
    flr.startDate,
    flr.endDate,
    flr.requestedDays,
    flr.reason,
    flr.status,
    flr.submittedAt,
    flr.decisionAt,
    flr.decisionComment,
    flr.created_from,
    flr.app_version
    
FROM flutter_leave_requests flr
JOIN users req ON flr.requesterId = req.id
LEFT JOIN users app ON flr.approverId = app.id  
JOIN flutter_leave_types flt ON flr.leaveTypeId = flt.id
ORDER BY flr.submittedAt DESC;

-- Vue des soldes avec infos utilisateur
CREATE OR REPLACE VIEW flutter_balances_view AS
SELECT 
    flb.id,
    flb.userId,
    CONCAT(u.firstName, ' ', u.lastName) as userName,
    u.email as userEmail,
    
    flb.leaveTypeId,
    flt.name as leaveTypeName,
    
    flb.year,
    flb.totalDays,
    flb.usedDays,
    flb.remainingDays
    
FROM flutter_leave_balances flb
JOIN users u ON flb.userId = u.id
JOIN flutter_leave_types flt ON flb.leaveTypeId = flt.id
ORDER BY u.lastName, flt.name;

-- =====================================
-- 7. VÉRIFICATIONS FINALES
-- =====================================

-- Compter les données créées
SELECT 'NOUVELLES TABLES FLUTTER CRÉÉES' as status;

SELECT COUNT(*) as types_count FROM flutter_leave_types;
SELECT COUNT(*) as balances_count FROM flutter_leave_balances; 
SELECT COUNT(*) as requests_count FROM flutter_leave_requests;

-- Afficher les types de congé
SELECT * FROM flutter_leave_types;

-- Afficher quelques soldes
SELECT * FROM flutter_balances_view LIMIT 5;

-- Afficher les demandes de test
SELECT * FROM flutter_leave_requests_view LIMIT 5;

SELECT '🎉 FLUTTER TABLES PRÊTES ! Votre app peut maintenant enregistrer les demandes !' as final_message;