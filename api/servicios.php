<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    exit(0);
}
header('Content-Type: application/json');
require 'db.php';
$result = $mysqli->query("SELECT id, nombre, descripcion, precio FROM servicios ORDER BY nombre");

$servicios = [];

while ($row = $result->fetch_assoc()) {
    $servicios[] = $row;
}

echo json_encode($servicios);
?>
