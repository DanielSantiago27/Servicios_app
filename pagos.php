<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    exit(0);
}
header('Content-Type: application/json');
require 'db.php';

$query = "
    SELECT pagos.id, usuarios.nombre AS usuario, usuarios.email, servicios.nombre AS servicio, pagos.monto, pagos.fecha_pago, pagos.estado
    FROM pagos
    INNER JOIN usuarios ON pagos.usuario_id = usuarios.id
    INNER JOIN servicios ON pagos.servicio_id = servicios.id
    ORDER BY pagos.fecha_pago DESC
";

$result = $mysqli->query($query);

$pagos = [];

while ($row = $result->fetch_assoc()) {
    $pagos[] = $row;
}

echo json_encode($pagos);
?>
