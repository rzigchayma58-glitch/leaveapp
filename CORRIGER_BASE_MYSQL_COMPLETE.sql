-- 🔧 CORRECTION COMPLÈTE BASE MYSQL POUR XCONGES
-- Exécutez ce script dans votre base de données leaveapp

USE leaveapp;

-- ====================================
-- 1. DIAGNOSTIC DES TABLES EXISTANTES
-- ====================================

-- Voir toutes les tables liées aux congés
SELECT TABLE_NAME, TABLE_COMMENT 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'leaveapp' 
  AND (TABLE_NAME LIKE '%leave%' OR TABLE_NAME LIKE '%conge%');

-- ====================================
-- 2. CRÉATION/CORRECTION TABLE LEAVE_TYPES
-- ====================================

-- Créer la table leave_types si elle n'existe pas
CREATE TABLE IF NOT EXISTS leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer les types de congé standards
INSERT IGNORE INTO leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée sans décompte', 1),
(5, 'Congé sans solde', 'Congé sans rémunération', 365),
(6, 'Congé formation', 'Congé pour formation professionnelle', 20);

-- ====================================
-- 3. CORRECTION TABLE CONGE_DEMANDES
-- ====================================

-- Vérifier la structure actuelle
DESCRIBE conge_demandes;

-- Ajouter la colonne leaveTypeId si elle n'existe pas
ALTER TABLE conge_demandes 
ADD COLUMN IF NOT EXISTS leaveTypeId BIGINT AFTER id;

-- Ajouter l'index et la contrainte foreign key
ALTER TABLE conge_demandes 
ADD INDEX IF NOT EXISTS idx_leave_type_id (leaveTypeId);

ALTER TABLE conge_demandes 
ADD CONSTRAINT IF NOT EXISTS fk_conge_demandes_leave_type 
FOREIGN KEY (leaveTypeId) REFERENCES leave_types(id);

-- S'assurer que toutes les colonnes nécessaires existent
ALTER TABLE conge_demandes 
ADD COLUMN IF NOT EXISTS requesterId BIGINT AFTER leaveTypeId,
ADD COLUMN IF NOT EXISTS approverId BIGINT AFTER requesterId,
ADD COLUMN IF NOT EXISTS startDate DATE NOT NULL AFTER approverId,
ADD COLUMN IF NOT EXISTS endDate DATE NOT NULL AFTER startDate,
ADD COLUMN IF NOT EXISTS requestedDays DECIMAL(5,2) DEFAULT 1.0 AFTER endDate,
ADD COLUMN IF NOT EXISTS reason TEXT AFTER requestedDays,
ADD COLUMN IF NOT EXISTS status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING' AFTER reason,
ADD COLUMN IF NOT EXISTS submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status,
ADD COLUMN IF NOT EXISTS decisionAt TIMESTAMP NULL AFTER submittedAt,
ADD COLUMN IF NOT EXISTS decisionComment TEXT AFTER decisionAt;

-- Ajouter les contraintes foreign key pour les utilisateurs
ALTER TABLE conge_demandes 
ADD CONSTRAINT IF NOT EXISTS fk_conge_demandes_requester 
FOREIGN KEY (requesterId) REFERENCES users(id);

ALTER TABLE conge_demandes 
ADD CONSTRAINT IF NOT EXISTS fk_conge_demandes_approver 
FOREIGN KEY (approverId) REFERENCES users(id);

-- ====================================
-- 4. TABLE LEAVE_BALANCES POUR LES SOLDES
-- ====================================

CREATE TABLE IF NOT EXISTS leave_balances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    userId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    year INT NOT NULL,
    totalDays DECIMAL(5,2) DEFAULT 0,
    usedDays DECIMAL(5,2) DEFAULT 0,
    remainingDays DECIMAL(5,2) GENERATED ALWAYS AS (totalDays - usedDays) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_user_leave_type_year (userId, leaveTypeId, year),
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (leaveTypeId) REFERENCES leave_types(id)
);

-- Insérer des soldes par défaut pour les utilisateurs existants
INSERT IGNORE INTO leave_balances (userId, leaveTypeId, year, totalDays, usedDays)
SELECT 
    u.id as userId,
    lt.id as leaveTypeId,
    YEAR(CURDATE()) as year,
    CASE 
        WHEN lt.id = 1 THEN 30.0  -- Congé annuel: 30 jours
        WHEN lt.id = 2 THEN 90.0  -- Congé maladie: 90 jours
        WHEN lt.id = 3 THEN 5.0   -- Congé exceptionnel: 5 jours
        WHEN lt.id = 6 THEN 20.0  -- Congé formation: 20 jours
        ELSE 0.0
    END as totalDays,
    0.0 as usedDays
FROM users u
CROSS JOIN leave_types lt
WHERE lt.id IN (1, 2, 3, 6) -- Types avec solde
  AND u.enabled = true;

-- ====================================
-- 5. VÉRIFICATIONS FINALES
-- ====================================

-- Vérifier les types de congé créés
SELECT * FROM leave_types ORDER BY id;

-- Vérifier la structure de conge_demandes
DESCRIBE conge_demandes;

-- Vérifier les soldes créés
SELECT 
    u.firstName, 
    u.lastName, 
    lt.name as leave_type, 
    lb.totalDays, 
    lb.usedDays, 
    lb.remainingDays
FROM leave_balances lb
JOIN users u ON lb.userId = u.id
JOIN leave_types lt ON lb.leaveTypeId = lt.id
ORDER BY u.lastName, lt.name;

-- Vérifier les contraintes foreign key
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'leaveapp' 
  AND TABLE_NAME = 'conge_demandes'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ====================================
-- 6. DONNÉES DE TEST (OPTIONNEL)
-- ====================================

-- Créer quelques demandes de test pour vérifier
INSERT IGNORE INTO conge_demandes 
(leaveTypeId, requesterId, startDate, endDate, requestedDays, reason, status, submittedAt)
VALUES 
-- Demande de congé annuel
(1, (SELECT id FROM users WHERE email = 'chaimaa.rz@xtensus.com'), 
 DATE_ADD(CURDATE(), INTERVAL 7 DAY), 
 DATE_ADD(CURDATE(), INTERVAL 9 DAY), 
 3.0, 
 'Congé de test depuis MySQL', 
 'PENDING', 
 NOW()),

-- Demande d'autorisation d'absence  
(4, (SELECT id FROM users WHERE email = 'chaimaa.rz@xtensus.com'), 
 DATE_ADD(CURDATE(), INTERVAL 14 DAY), 
 DATE_ADD(CURDATE(), INTERVAL 14 DAY), 
 0.5, 
 'Rendez-vous médical', 
 'PENDING', 
 NOW());

-- Vérifier les demandes créées
SELECT 
    cd.*,
    lt.name as leave_type_name,
    u.firstName,
    u.lastName
FROM conge_demandes cd
JOIN leave_types lt ON cd.leaveTypeId = lt.id  
JOIN users u ON cd.requesterId = u.id
ORDER BY cd.submittedAt DESC;

-- ====================================
-- RÉSUMÉ
-- ====================================
SELECT 'CORRECTION TERMINÉE ! Votre base MySQL est maintenant configurée pour XCongés' as message;