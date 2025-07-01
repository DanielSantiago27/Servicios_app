<?php
$conn = new mysqli("localhost", "root", "", "pagos_servicios");

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

$sql = "
    SELECT 
        pagos.id,
        usuarios.nombre AS nombre_usuario,
        usuarios.email,
        servicios.nombre AS nombre_servicio,
        pagos.fecha_pago,
        pagos.monto,
        pagos.estado
    FROM pagos
    INNER JOIN usuarios ON pagos.usuario_id = usuarios.id
    INNER JOIN servicios ON pagos.servicio_id = servicios.id
";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $data = array();
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode($data, JSON_UNESCAPED_UNICODE); // Para caracteres como tildes
} else {
    echo json_encode([]);
}
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchData() async {
  final response = await http.get(Uri.parse('http://localhost/api.php'));

  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    // Procesa los datos aquí
  } else {
    throw Exception('Error al cargar datos');
  }
}

$conn->close();
?>

