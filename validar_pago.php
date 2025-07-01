<?php

include 'db.php';

$data = json_decode(file_get_contents("php://input"));

if (isset($data->pago_id)) {
    $pago_id = $data->pago_id;

    $query = "UPDATE pagos SET estado = 'completado' WHERE id = ? AND estado = 'pendiente'";
    $stmt = $mysqli->prepare($query);
    $stmt->bind_param("i", $pago_id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Estado actualizado a completado']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se encontró un pago pendiente con ese ID']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'Error al ejecutar la consulta']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'ID de pago no proporcionado']);
}
?>
