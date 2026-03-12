<?php
// Inclure le fichier de configuration
require_once __DIR__ . '/../includes/config.php';

// Définir l'en-tête de réponse
header('Content-Type: application/json');

// Vérifier la connexion à la base de données
try {
    $pdo = getDbConnection();
    $dbStatus = 'connected';
} catch (Exception $e) {
    $dbStatus = 'error: ' . $e->getMessage();
}

// Préparer la réponse
$response = [
    'status' => 'ok',
    'service' => 'Structure API',
    'version' => '1.0.0',
    'timestamp' => time(),
    'database' => $dbStatus,
    'environment' => 'development'
];

// Envoyer la réponse
sendJsonResponse(200, $response);
