-- 🚨 CORRECTION IMMÉDIATE - Ajouter les types de congé manquants

USE leaveapp;

-- Vérifier d'abord ce qui existe
SELECT 'AVANT CORRECTION:' as status;
SELECT * FROM leave_types;

-- Créer la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer ou mettre à jour les types
INSERT INTO leave_types (id, name, description, max_days, is_active) 
VALUES 
(1, 'Conge', 'Congé payé annuel', 30, TRUE),
(2, 'Autorisation d\'absence', 'Autorisation d\'absence ponctuelle', 1, TRUE),
(3, 'Congé maladie', 'Congé pour maladie', 90, TRUE),
(4, 'Congé exceptionnel', 'Congé pour événement familial', 5, TRUE)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    is_active = TRUE,
    updated_at = NOW();

-- Vérifier le résultat
SELECT 'APRÈS CORRECTION:' as status;
SELECT * FROM leave_types WHERE is_active = TRUE;

-- Compter les types actifs
SELECT COUNT(*) as types_actifs FROM leave_types WHERE is_active = TRUE;