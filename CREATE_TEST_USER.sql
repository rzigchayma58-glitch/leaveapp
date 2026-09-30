-- 📝 Script de création d'utilisateur de test pour XCongés
-- Backend Spring Boot - Port 8081
-- À exécuter dans MySQL Workbench ou ligne de commande MySQL

USE hr_management; -- Remplacer par le nom de votre base de données

-- 1. Créer l'utilisateur admin de test
-- Mot de passe hashé avec BCrypt pour "password123"
INSERT INTO users (username, email, first_name, last_name, password, role, created_at, updated_at) VALUES 
('admin', 'admin@test.com', 'Admin', 'User', '$2a$10$e0MYzXyjpJS7Pd2AWDbIve6rQoJZzSEf5RhEWqANBOWAhgfQw1Vm2', 'ADMIN', NOW(), NOW());

-- 2. Créer un utilisateur employé de test
INSERT INTO users (username, email, first_name, last_name, password, role, created_at, updated_at) VALUES 
('jean.dupont', 'jean.dupont@test.com', 'Jean', 'Dupont', '$2a$10$e0MYzXyjpJS7Pd2AWDbIve6rQoJZzSEf5RhEWqANBOWAhgfQw1Vm2', 'EMPLOYEE', NOW(), NOW());

-- 3. Créer un manager de test
INSERT INTO users (username, email, first_name, last_name, password, role, created_at, updated_at) VALUES 
('marie.manager', 'marie.manager@test.com', 'Marie', 'Manager', '$2a$10$e0MYzXyjpJS7Pd2AWDbIve6rQoJZzSEf5RhEWqANBOWAhgfQw1Vm2', 'MANAGER', NOW(), NOW());

-- 4. Créer les types de congé
INSERT INTO leave_types (name, description, is_active, created_at) VALUES 
('Congé Annuel', 'Congés payés annuels', TRUE, NOW()),
('Congé Exceptionnel', 'Congés pour événements familiaux', TRUE, NOW()),
('Congé Maladie', 'Arrêt maladie avec certificat médical', TRUE, NOW()),
('RTT', 'Réduction du Temps de Travail', TRUE, NOW());

-- 5. Créer les soldes de congé pour l'employé Jean Dupont (ID 2)
INSERT INTO leave_balances (user_id, leave_type_id, year, total_days, used_days, remaining_days, created_at, updated_at) VALUES 
(2, 1, 2024, 25.0, 5.0, 20.0, NOW(), NOW()),  -- Congé Annuel
(2, 2, 2024, 10.0, 0.0, 10.0, NOW(), NOW()),  -- Congé Exceptionnel
(2, 3, 2024, 15.0, 2.0, 13.0, NOW(), NOW()),  -- Congé Maladie
(2, 4, 2024, 12.0, 0.0, 12.0, NOW(), NOW());  -- RTT

-- 6. Créer une demande de congé d'exemple
INSERT INTO leave_requests (
    requester_id, 
    approver_id, 
    leave_type_id, 
    start_date, 
    end_date, 
    requested_days, 
    reason, 
    status, 
    submitted_at
) VALUES (
    2,  -- Jean Dupont
    3,  -- Marie Manager
    1,  -- Congé Annuel
    '2024-12-20', 
    '2024-12-24', 
    3.0, 
    'Vacances de Noël', 
    'PENDING', 
    NOW()
);

-- 7. Vérification des données créées
SELECT 'Utilisateurs créés:' as Info;
SELECT id, username, email, first_name, last_name, role FROM users WHERE email LIKE '%test.com';

SELECT 'Types de congé créés:' as Info;
SELECT * FROM leave_types;

SELECT 'Soldes créés pour Jean Dupont:' as Info;
SELECT lb.*, lt.name as leave_type_name 
FROM leave_balances lb 
JOIN leave_types lt ON lb.leave_type_id = lt.id 
WHERE lb.user_id = 2;

SELECT 'Demandes créées:' as Info;
SELECT lr.*, u1.username as requester_name, u2.username as approver_name, lt.name as leave_type_name
FROM leave_requests lr
JOIN users u1 ON lr.requester_id = u1.id
LEFT JOIN users u2 ON lr.approver_id = u2.id
JOIN leave_types lt ON lr.leave_type_id = lt.id;

-- 🎯 COMPTES DE TEST CRÉÉS:
-- Email: admin@test.com | Password: password123 | Role: ADMIN
-- Email: jean.dupont@test.com | Password: password123 | Role: EMPLOYEE  
-- Email: marie.manager@test.com | Password: password123 | Role: MANAGER

COMMIT;