-- =============================================
-- STRUCTURE-BACKEND - SCRIPT DE CRÉATION DE LA BASE DE DONNÉES
-- =============================================

-- Création de la base de données
DROP DATABASE IF EXISTS structure_backend;
CREATE DATABASE structure_backend 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE structure_backend;

-- =============================================
-- TABLE : role_types
-- Description : Définit les différents rôles utilisateurs
-- =============================================
CREATE TABLE role_types (
    role_name VARCHAR(20) PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des rôles
INSERT INTO role_types (role_name) VALUES 
('SUPER_ADMIN'), -- Administrateur système avec tous les droits
('ADMIN'),       -- Administrateur de structure
('USER');        -- Utilisateur standard

-- =============================================
-- TABLE : structures
-- Description : Stocke les informations des structures
-- =============================================
CREATE TABLE structures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nom de la structure',
    description TEXT COMMENT 'Description détaillée',
    address VARCHAR(500) COMMENT 'Adresse physique',
    phone VARCHAR(50) COMMENT 'Numéro de téléphone',
    email VARCHAR(255) COMMENT 'Adresse email de contact',
    image_url VARCHAR(500) COMMENT 'URL de l\'image de la structure',
    active BOOLEAN DEFAULT TRUE COMMENT 'Indique si la structure est active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_structure_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE : users
-- Description : Gestion des comptes utilisateurs
-- =============================================
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL COMMENT 'Email unique de l\'utilisateur',
    password VARCHAR(255) NOT NULL COMMENT 'Mot de passe haché',
    first_name VARCHAR(100) COMMENT 'Prénom',
    last_name VARCHAR(100) COMMENT 'Nom de famille',
    phone VARCHAR(50) COMMENT 'Téléphone',
    role VARCHAR(20) NOT NULL COMMENT 'Rôle de l\'utilisateur',
    active BOOLEAN DEFAULT TRUE COMMENT 'Compte actif ou non',
    structure_id BIGINT COMMENT 'Structure à laquelle l\'utilisateur est rattaché',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role) REFERENCES role_types(role_name) ON DELETE RESTRICT,
    FOREIGN KEY (structure_id) REFERENCES structures(id) ON DELETE SET NULL,
    CONSTRAINT uk_user_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE : services
-- Description : Services proposés par les structures
-- =============================================
CREATE TABLE services (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nom du service',
    category VARCHAR(100) NOT NULL COMMENT 'Catégorie du service',
    description TEXT COMMENT 'Description détaillée',
    price DECIMAL(10, 2) COMMENT 'Prix du service',
    duration INT COMMENT 'Durée en minutes',
    active BOOLEAN DEFAULT TRUE COMMENT 'Service actif ou non',
    structure_id BIGINT NOT NULL COMMENT 'Structure proposant le service',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (structure_id) REFERENCES structures(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE : transactions
-- Description : Enregistrement des transactions financières
-- =============================================
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reference VARCHAR(100) NOT NULL COMMENT 'Référence unique de la transaction',
    order_id VARCHAR(255) DEFAULT NULL COMMENT 'ID de commande externe (CampostPay, etc.)',
    amount DECIMAL(10, 2) NOT NULL COMMENT 'Montant de la transaction',
    transaction_date DATE NOT NULL COMMENT 'Date de la transaction',
    description TEXT COMMENT 'Détails supplémentaires',
    service_id BIGINT NOT NULL COMMENT 'Service concerné',
    structure_id BIGINT NOT NULL COMMENT 'Structure concernée',
    is_confirmed BOOLEAN DEFAULT FALSE COMMENT 'Transaction confirmée ou non',
    confirmation_date DATE COMMENT 'Date de confirmation',
    customer_name VARCHAR(255) COMMENT 'Nom du client',
    customer_phone VARCHAR(50) COMMENT 'Téléphone du client',
    customer_email VARCHAR(255) COMMENT 'Email du client',
    payment_method VARCHAR(50) COMMENT 'Méthode de paiement',
    status VARCHAR(50) DEFAULT 'PENDING' COMMENT 'Statut (PENDING, SUCCESS, FAILED)',
    receipt_url VARCHAR(500) COMMENT 'URL du reçu PDF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (structure_id) REFERENCES structures(id) ON DELETE CASCADE,
    CONSTRAINT uk_transaction_reference UNIQUE (reference)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INDEX POUR LES PERFORMANCES
-- =============================================

-- Index pour la table structures
CREATE INDEX idx_structures_name ON structures(name);
CREATE INDEX idx_structures_active ON structures(active);

-- Index pour la table users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_structure ON users(structure_id);

-- Index pour la table services
CREATE INDEX idx_services_name ON services(name);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_structure ON services(structure_id);
CREATE INDEX idx_services_active ON services(active);

-- Index pour la table transactions
CREATE INDEX idx_transactions_reference ON transactions(reference);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_confirmed ON transactions(is_confirmed);
CREATE INDEX idx_transactions_service ON transactions(service_id);
CREATE INDEX idx_transactions_structure ON transactions(structure_id);

-- =============================================
-- DONNÉES INITIALES
-- =============================================

-- Structure de démonstration
INSERT INTO structures 
(name, description, address, phone, email, active) 
VALUES 
('Structure de Démonstration', 
 'Structure exemple pour les tests et le développement', 
 '123 Avenue des Tests, Yaoundé, Cameroun', 
 '+237 6XX XXX XXX', 
 'contact@demo-structure.cm', 
 TRUE);

-- Compte administrateur par défaut
-- Mot de passe: admin123 (correspond à application.properties)
-- Hash BCrypt généré pour "admin123"
INSERT INTO users 
(email, password, first_name, last_name, phone, role, active) 
VALUES 
('admin@example.com', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'Super', 
 'Admin', 
 '+237 6XX XXX XXX', 
 'SUPER_ADMIN', 
 TRUE);

-- Services de démonstration
INSERT INTO services 
(name, category, description, price, duration, structure_id, active) 
VALUES 
('Hébergement Standard', 
 'Hébergement', 
 'Chambre standard avec petit déjeuner inclus', 
 25000.00, 
 1440,  -- 24h en minutes
 1, 
 TRUE),
('Salle de Réunion', 
 'Location d\'espace', 
 'Salle équipée pour 10 personnes', 
 15000.00, 
 60,  -- 1h en minutes
 1, 
 TRUE);

-- =============================================
-- VUES POUR LES RAPPORTS
-- =============================================

-- Vue pour les statistiques des structures
CREATE VIEW vw_structure_stats AS
SELECT 
    s.id,
    s.name,
    s.email,
    COUNT(DISTINCT u.id) as user_count,
    COUNT(DISTINCT svc.id) as service_count,
    COUNT(DISTINCT t.id) as transaction_count,
    COALESCE(SUM(CASE WHEN t.is_confirmed = 1 THEN t.amount ELSE 0 END), 0) as total_revenue
FROM 
    structures s
LEFT JOIN users u ON s.id = u.structure_id
LEFT JOIN services svc ON s.id = svc.structure_id
LEFT JOIN transactions t ON s.id = t.structure_id
GROUP BY 
    s.id, s.name, s.email;

-- Vue pour les transactions récentes
CREATE VIEW vw_recent_transactions AS
SELECT 
    t.id,
    t.reference,
    t.amount,
    t.transaction_date,
    t.is_confirmed,
    t.confirmation_date,
    s.name as service_name,
    st.name as structure_name,
    CONCAT(u.first_name, ' ', u.last_name) as user_name
FROM 
    transactions t
JOIN services s ON t.service_id = s.id
JOIN structures st ON t.structure_id = st.id
LEFT JOIN users u ON u.structure_id = st.id
ORDER BY 
    t.transaction_date DESC, t.id DESC;

-- =============================================
-- PROCÉDURES STOCKÉES UTILES
-- =============================================

-- Procédure pour désactiver une structure et tous ses services/utilisateurs
DELIMITER //
CREATE PROCEDURE sp_disable_structure(IN p_structure_id BIGINT)
BEGIN
    -- Désactiver la structure
    UPDATE structures SET active = FALSE WHERE id = p_structure_id;
    
    -- Désactiver tous les services de la structure
    UPDATE services SET active = FALSE WHERE structure_id = p_structure_id;
    
    -- Désactiver tous les utilisateurs de la structure
    UPDATE users SET active = FALSE WHERE structure_id = p_structure_id;
    
    COMMIT;
END //

-- Procédure pour générer des rapports mensuels
CREATE PROCEDURE sp_monthly_report(IN p_year INT, IN p_month INT)
BEGIN
    SELECT 
        s.name as structure_name,
        COUNT(t.id) as transaction_count,
        COALESCE(SUM(t.amount), 0) as total_amount,
        COUNT(DISTINCT t.service_id) as unique_services
    FROM 
        transactions t
    JOIN structures s ON t.structure_id = s.id
    WHERE 
        YEAR(t.transaction_date) = p_year 
        AND MONTH(t.transaction_date) = p_month
        AND t.is_confirmed = 1
    GROUP BY 
        s.id, s.name
    ORDER BY 
        total_amount DESC;
END //

DELIMITER ;

-- =============================================
-- DROITS D'ACCÈS
-- =============================================

-- Création d'un utilisateur avec des droits limités pour l'application
CREATE USER 'structure_app'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON structure_backend.* TO 'structure_app'@'localhost';
FLUSH PRIVILEGES;

-- =============================================
-- FIN DU SCRIPT
-- =============================================

-- Vérification des tables créées
SHOW TABLES;

-- Vérification des vues créées
SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW';