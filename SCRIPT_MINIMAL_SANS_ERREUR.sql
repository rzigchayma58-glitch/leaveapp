-- 🎯 SCRIPT MINIMAL - Juste insérer les données dans la table existante
USE rh_xtensus;

-- 1. Vérifier ce qui existe
SELECT 'CONTENU ACTUEL:' as info;
SELECT * FROM flutter_leave_types;

-- 2. Insérer seulement les données (IGNORE évite les erreurs de doublon)
INSERT IGNORE INTO flutter_leave_types (id, name, description, is_active) VALUES
(1, 'Congé annuel', 'Congé payé annuel standard', TRUE),
(2, 'Autorisation d\'absence', 'Autorisation d\'absence de courte durée', TRUE),
(3, 'Congé maladie', 'Congé pour raison médicale', TRUE),
(4, 'Congé exceptionnel', 'Congé pour événement familial', TRUE);

-- 3. Résultat final
SELECT 'RÉSULTAT:' as info;
SELECT * FROM flutter_leave_types ORDER BY id;

-- 4. Confirmation
SELECT CONCAT('✅ ', COUNT(*), ' types de congé disponibles pour Flutter') as status 
FROM flutter_leave_types WHERE is_active = TRUE;