<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    exit(0);
}
header('Content-Type: application/json');
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['nombre'], $data['email'], $data['telefono'], $data['servicio_id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos']);
    exit;
}

$nombre = trim($data['nombre']);
$email = trim($data['email']);
$telefono = trim($data['telefono']);
$servicio_id = intval($data['servicio_id']);

if (!$nombre || !$email || !$servicio_id) {
    http_response_code(400);
    echo json_encode(['error' => 'Datos inválidos']);
    exit;
}

// Verificar si el usuario ya existe
$stmt = $mysqli->prepare("SELECT id FROM usuarios WHERE email = ?");
$stmt->bind_param('s', $email);
$stmt->execute();
$stmt->bind_result($usuario_id);
$stmt->fetch();
$stmt->close();

// Si no existe, lo insertamos
if (!$usuario_id) {
    $stmt = $mysqli->prepare("INSERT INTO usuarios (nombre, email, telefono) VALUES (?, ?, ?)");
    $stmt->bind_param('sss', $nombre, $email, $telefono);
    if (!$stmt->execute()) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al crear usuario']);
        exit;
    }
    $usuario_id = $stmt->insert_id;
    $stmt->close();
}

// Obtener el precio del servicio
$stmt = $mysqli->prepare("SELECT precio FROM servicios WHERE id = ?");
$stmt->bind_param('i', $servicio_id);
$stmt->execute();
$stmt->bind_result($precio);
if (!$stmt->fetch()) {
    http_response_code(400);
    echo json_encode(['error' => 'Servicio no encontrado']);
    exit;
}
$stmt->close();

// Validar el precio correctamente
if ($precio <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Precio de servicio inválido']);
    exit;
}

// Registrar el pago con estado PENDIENTE
$stmt = $mysqli->prepare("INSERT INTO pagos (usuario_id, servicio_id, monto, estado) VALUES (?, ?, ?, 'PENDIENTE')");
$stmt->bind_param('iid', $usuario_id, $servicio_id, $precio);
if ($stmt->execute()) {
    echo json_encode(['mensaje' => 'Pago registrado correctamente']);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Error al registrar pago']);
}
$stmt->close();
?>
