<?php
$host = 'localhost';
$db   = 'pagos_servicios';
$user = 'root';
$pass = ''; 

$mysqli = new mysqli($host, $user, $pass, $db);

if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['error' => 'Error de conexión a base de datos']);
    exit;
}

$mysqli->set_charset("utf8mb4");
?>
