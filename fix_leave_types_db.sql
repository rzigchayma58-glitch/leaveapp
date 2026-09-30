-- 🔧 SCRIPT POUR CORRIGER LES TYPES DE CONGÉ DANS LA BASE

-- 1. Vérifier les tables existantes
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'leaveapp' 
  AND TABLE_NAME LIKE '%leave%' OR TABLE_NAME LIKE '%conge%';

-- 2. Vérifier le contenu de conge_types
SELECT * FROM conge_types;

-- 3. Vérifier si la table leave_types existe
SELECT * FROM leave_types;

-- 4. Si la table leave_types n'existe pas, la créer et copier les données
CREATE TABLE IF NOT EXISTS leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. Insérer les types de congé standards si vide
INSERT IGNORE INTO leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée', 1);

-- 6. Vérifier le contenu final
SELECT * FROM leave_types ORDER BY id;

-- 7. Vérifier la structure de la table des demandes
DESCRIBE conge_demandes;

-- 8. Si la colonne leaveTypeId n'existe pas, l'ajouter
-- ALTER TABLE conge_demandes ADD COLUMN leaveTypeId BIGINT;

-- 9. Ajouter la contrainte de clé étrangère si nécessaire
-- ALTER TABLE conge_demandes ADD CONSTRAINT fk_leave_type 
-- FOREIGN KEY (leaveTypeId) REFERENCES leave_types(id);