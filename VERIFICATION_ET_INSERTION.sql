-- 🔍 VÉRIFICATION ET INSERTION DES DONNÉES MANQUANTES
-- Pour la base rh_xtensus

USE rh_xtensus;

-- 1. Vérifier ce qui existe déjà
SELECT 'CONTENU ACTUEL DE LA TABLE:' as info;
SELECT * FROM flutter_leave_types;

-- 2. Insérer seulement les données manquantes (IGNORE évite les doublons)
INSERT IGNORE INTO flutter_leave_types (id, code, name, description, max_days_per_year, advance_notice_hours, is_active) VALUES
(1, 'CONGE_ANNUEL', 'Congé annuel', 'Congé payé annuel standard', 30, 72, TRUE),
(2, 'AUTORISATION_ABSENCE', 'Autorisation d\'absence', 'Autorisation d\'absence de courte durée', 5, 48, TRUE),
(3, 'CONGE_MALADIE', 'Congé maladie', 'Congé pour raison médicale', 90, 0, TRUE),
(4, 'CONGE_EXCEPTIONNEL', 'Congé exceptionnel', 'Congé pour événement familial', 10, 48, TRUE);

-- 3. Vérifier le résultat final
SELECT 'RÉSULTAT APRÈS INSERTION:' as info;
SELECT * FROM flutter_leave_types ORDER BY id;

-- 4. Compter les types actifs
SELECT CONCAT('✅ ', COUNT(*), ' types de congé disponibles') as status 
FROM flutter_leave_types WHERE is_active = TRUE;