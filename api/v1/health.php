<?php
// Inclure le fichier de configuration
require_once __DIR__ . '/../includes/config.php';

// Définir l'en-tête de réponse
header('Content-Type: application/json');

// Vérifier la connexion à la base de données
try {
    \ = getDbConnection();
    \ = 'connected';
} catch (Exception \) {
    \ = 'error: ' . \->getMessage();
}

// Préparer la réponse
\ = [
    'status' => 'ok',
    'service' => 'Structure API',
    'version' => '1.0.0',
    'timestamp' => time(),
    'database' => \,
    'environment' => 'development'
];

// Envoyer la réponse
sendJsonResponse(200, \);
