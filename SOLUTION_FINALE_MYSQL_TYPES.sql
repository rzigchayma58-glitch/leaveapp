-- 🎯 SOLUTION FINALE - Corriger les types de congé MySQL
-- Exécute ce script dans ta base de données leaveapp

USE leaveapp;

-- ========================================
-- 1. DIAGNOSTIC ACTUEL
-- ========================================

SELECT 'ÉTAT ACTUEL DE LA BASE:' as diagnostic;

-- Vérifier si la table existe
SELECT 
    COUNT(*) as table_exists 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'leaveapp' 
  AND TABLE_NAME = 'leave_types';

-- Voir le contenu actuel
SELECT 'Contenu actuel:' as info;
SELECT * FROM leave_types LIMIT 10;

-- ========================================
-- 2. CORRIGER/CRÉER LA TABLE
-- ========================================

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

-- Vider la table pour repartir à zéro
DELETE FROM leave_types;

-- Réinitialiser l'auto-increment
ALTER TABLE leave_types AUTO_INCREMENT = 1;

-- ========================================
-- 3. INSÉRER LES TYPES CORRECTS
-- ========================================

INSERT INTO leave_types (id, name, description, max_days, is_active) VALUES 
(1, 'Congé annuel', 'Congé payé annuel standard', 30, TRUE),
(2, 'Autorisation d\'absence', 'Autorisation d\'absence de courte durée', 5, TRUE),
(3, 'Congé maladie', 'Congé pour raison médicale', 90, TRUE),
(4, 'Congé exceptionnel', 'Congé pour événement familial exceptionnel', 10, TRUE),
(5, 'Congé sans solde', 'Congé sans rémunération', 365, TRUE),
(6, 'Congé formation', 'Congé pour formation professionnelle', 20, TRUE);

-- ========================================
-- 4. VÉRIFICATION FINALE
-- ========================================

SELECT 'RÉSULTAT FINAL:' as verification;
SELECT * FROM leave_types WHERE is_active = TRUE ORDER BY id;

SELECT 
    COUNT(*) as total_types_actifs 
FROM leave_types 
WHERE is_active = TRUE;

-- ========================================
-- 5. TEST DE L'ENDPOINT
-- ========================================

-- Ce SELECT simule ce que ton endpoint /api/leave-types devrait retourner
SELECT 'SIMULATION ENDPOINT /api/leave-types:' as test_endpoint;
SELECT 
    id,
    name,
    description,
    is_active,
    max_days
FROM leave_types 
WHERE is_active = TRUE 
ORDER BY id;

-- ========================================
-- 6. VÉRIFIER LES CONTRAINTES
-- ========================================

-- S'assurer que la table leave_requests peut référencer leave_types
SELECT 'VÉRIFICATION FOREIGN KEYS:' as fk_check;
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'leaveapp'
  AND REFERENCED_TABLE_NAME = 'leave_types';

-- ========================================
-- MESSAGES FINAUX
-- ========================================

SELECT 
    '✅ CORRECTION TERMINÉE !' as status,
    'Ton endpoint /api/leave-types devrait maintenant retourner 6 types de congé' as message;

SELECT 
    'PROCHAINE ÉTAPE:' as todo,
    'Redémarre ton serveur Spring Boot et teste l\'app Flutter' as action;