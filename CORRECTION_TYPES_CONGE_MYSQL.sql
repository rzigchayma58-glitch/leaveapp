-- 🔧 CORRECTION: INSERTION DES TYPES DE CONGÉ MANQUANTS
-- Exécuter ce script sur votre base MySQL 'rh_xtensus'

USE rh_xtensus;

-- 📋 VÉRIFIER LES TYPES EXISTANTS
SELECT * FROM conge_types;

-- 🧹 NETTOYER LES ANCIENS TYPES (OPTIONNEL - ATTENTION AUX CONTRAINTES)
-- DELETE FROM conge_types; -- Décommentez seulement si pas de demandes existantes

-- ➕ INSÉRER LES TYPES DE CONGÉ DE BASE
INSERT INTO conge_types (id, nom, description, jours_max_par_an, necessite_justificatif, delai_minimum_heures, actif, created_at, updated_at) 
VALUES 
    (1, 'Congé annuel', 'Congés payés annuels', 30, FALSE, 72, TRUE, NOW(), NOW()),
    (2, 'Autorisation d\'absence', 'Autorisation d\'absence ponctuelle', 0, FALSE, 48, TRUE, NOW(), NOW()),
    (3, 'Congé maladie', 'Congé pour maladie', 365, TRUE, 0, TRUE, NOW(), NOW()),
    (4, 'Congé exceptionnel', 'Congé pour événements familiaux', 5, TRUE, 24, TRUE, NOW(), NOW()),
    (5, 'Congé maternité', 'Congé de maternité', 98, TRUE, 0, TRUE, NOW(), NOW()),
    (6, 'Congé paternité', 'Congé de paternité', 14, TRUE, 0, TRUE, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    nom = VALUES(nom),
    description = VALUES(description),
    updated_at = NOW();

-- ✅ VÉRIFIER L'INSERTION
SELECT * FROM conge_types WHERE actif = TRUE ORDER BY id;

-- 📊 COMPTER LES TYPES ACTIFS
SELECT COUNT(*) as total_types_actifs FROM conge_types WHERE actif = TRUE;

-- 🔄 RÉINITIALISER L'AUTO_INCREMENT SI NÉCESSAIRE
-- ALTER TABLE conge_types AUTO_INCREMENT = 7;

-- 📝 NOTES D'UTILISATION:
-- 
-- ID 1: Congé annuel (30 jours/an, délai 72h)
-- ID 2: Autorisation d'absence (0 jours/an, délai 48h) 
-- ID 3: Congé maladie (365 jours/an, pas de délai, justificatif requis)
-- ID 4: Congé exceptionnel (5 jours/an, délai 24h, justificatif requis)
-- ID 5: Congé maternité (98 jours/an, pas de délai, justificatif requis)
-- ID 6: Congé paternité (14 jours/an, pas de délai, justificatif requis)
--
-- 🎯 FLUTTER UTILISE:
-- - LeaveType.leave + sélection dropdown → ID du type sélectionné
-- - LeaveType.absence → ID 2 (Autorisation d'absence)
--
-- 🚀 APRÈS EXÉCUTION:
-- Relancez votre app Flutter, les types seront chargés depuis MySQL
-- Les demandes utiliseront les bons IDs et fonctionneront !