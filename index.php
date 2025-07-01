<?php
// index.php
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>App de Pago de Servicios</title>
    <style>
        /* Estilos modernos y limpios */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f7f8;
            margin: 0; padding: 0;
            color: #333;
        }
        header {
            background: #007BFF;
            color: white;
            padding: 1rem;
            text-align: center;
        }
        nav {
            background: #0056b3;
            display: flex;
            justify-content: center;
            padding: 0.5rem 0;
        }
        nav a {
            color: white;
            margin: 0 1rem;
            text-decoration: none;
            font-weight: bold;
        }
        nav a:hover {
            text-decoration: underline;
        }
        main {
            max-width: 900px;
            margin: 2rem auto;
            background: white;
            padding: 2rem;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,.1);
        }
        h2 {
            color: #007BFF;
        }
        footer {
            text-align: center;
            padding: 1rem;
            margin-top: 2rem;
            color: #777;
        }
        .button-link {
            background: #007BFF;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
        }
        .button-link:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
<header>
    <h1>Aplicación de Pago de Servicios</h1>
</header>
<nav>
    <a href="index.php">Inicio</a>
    <a href="servicios.php">Servicios Disponibles</a>
    <a href="registrar_pago.php">Registrar Pago</a>
    <a href="pagos.php">Historial de Pagos</a>
</nav>
<main>
    <h2>Bienvenido</h2>
    <p>Esta aplicación permite registrar pagos de servicios, consultar servicios disponibles y ver el historial de pagos realizados.</p>
    <p>Use el menú para navegar entre las opciones.</p>
</main>
<footer>
    &copy; <?php echo date('Y'); ?> App de Pago de Servicios
</footer>
</body>
</html>
