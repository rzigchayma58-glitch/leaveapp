-- 🎯 CRÉATION TABLE DEMANDES POUR rh_xtensus
USE rh_xtensus;

-- Créer la table des demandes de congé
CREATE TABLE IF NOT EXISTS flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- 👤 UTILISATEURS
    requester_id BIGINT NOT NULL,
    approver_id BIGINT NULL,
    
    -- 📋 TYPE ET DÉTAILS
    leave_type_id INT NOT NULL,
    
    -- 📅 DATES ET DURÉE
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    requested_days DECIMAL(5,2) NOT NULL,
    
    -- ⏰ HEURES (Pour autorisation d'absence)
    start_time TIME NULL,
    end_time TIME NULL,
    
    -- 📝 DÉTAILS
    reason TEXT,
    
    -- ✅ STATUS
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    
    -- 📅 SUIVI DES DATES
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    decision_comment TEXT,
    
    -- 📱 MÉTADONNÉES FLUTTER
    created_from VARCHAR(50) DEFAULT 'FLUTTER_APP',
    
    -- 🔗 INDEX
    INDEX idx_requester (requester_id),
    INDEX idx_leave_type (leave_type_id),
    INDEX idx_status (status),
    INDEX idx_submitted (submitted_at),
    
    -- Foreign Keys
    FOREIGN KEY (requester_id) REFERENCES users(id),
    FOREIGN KEY (leave_type_id) REFERENCES flutter_leave_types(id)
);

-- Vérifier que la table est créée
SELECT 'TABLE flutter_leave_requests CRÉÉE !' as status;
DESCRIBE flutter_leave_requests;