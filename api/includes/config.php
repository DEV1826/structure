<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_USER', 'root');        // À modifier selon votre configuration
define('DB_PASS', '');            // À modifier selon votre configuration
define('DB_NAME', 'structure_backend'); // Le nom de votre base de données existante

// Configuration de l'API
define('JWT_SECRET', 'votre_clé_secrète_très_longue_et_sécurisée');
define('JWT_EXPIRE', 3600); // Durée de validité du token en secondes (1h)

// Fonction pour se connecter à la base de données
function getDbConnection() {
    try {
        \ = new PDO(
            \"mysql:host=\" . DB_HOST . \";dbname=\" . DB_NAME . \";charset=utf8mb4\",
            DB_USER,
            DB_PASS,
            array(
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            )
        );
        return \;
    } catch(PDOException \) {
        http_response_code(500);
        die(json_encode(['error' => 'Database connection failed: ' . \->getMessage()]));
    }
}

// Fonction pour envoyer une réponse JSON
function sendJsonResponse(\, \) {
    http_response_code(\);
    header('Content-Type: application/json');
    echo json_encode(\, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}
