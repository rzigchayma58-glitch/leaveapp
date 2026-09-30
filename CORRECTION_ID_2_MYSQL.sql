-- 🔧 CORRECTION URGENTE - Ajouter ID 2 manquant dans MySQL
-- Exécute ce script pour résoudre l'erreur "Leave type not found with id: 2"

USE leaveapp;

-- Vérifier l'état actuel
SELECT 'ÉTAT ACTUEL:' as diagnostic;
SELECT * FROM leave_types ORDER BY id;

-- Ajouter l'ID 2 manquant (seulement s'il n'existe pas)
INSERT IGNORE INTO leave_types (id, name, description, is_active) VALUES 
(2, 'Autorisation d\'absence', 'Autorisation d\'absence ponctuelle', TRUE);

-- Vérifier le résultat
SELECT 'APRÈS AJOUT:' as verification;
SELECT * FROM leave_types WHERE id IN (1, 2) ORDER BY id;

-- Test de l'erreur résolue
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM leave_types WHERE id = 2) > 0 
        THEN '✅ ID 2 existe maintenant - Erreur 404 résolue !'
        ELSE '❌ ID 2 manque encore'
    END as status;