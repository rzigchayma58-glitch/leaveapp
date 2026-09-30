-- 🚨 CORRECTION URGENTE - Types de congé manquants
-- Exécutez ce script dans votre base de données MySQL

USE leaveapp;

-- 1. Créer la table leave_types si elle n'existe pas
CREATE TABLE IF NOT EXISTS leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Insérer les types de congé manquants (seulement s'ils n'existent pas)
INSERT IGNORE INTO leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée sans décompte', 1);

-- 3. Vérifier que les types sont bien créés
SELECT * FROM leave_types WHERE id IN (1, 2, 3, 4);

-- 4. Message de confirmation
SELECT '✅ TYPES DE CONGÉ CORRIGÉS ! Relancez votre app Flutter maintenant.' as result;