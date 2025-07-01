import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



Future<void> fetchData() async {
  final response = await http.get(Uri.parse('https://servicios-app-1.onrender.com/api.php'));

  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    print(data);
  } else {
    throw Exception('Error al cargar datos');
  }
}

void main() {
  runApp(PagosApp());
}

const String apiBaseUrl = 'https://servicios-api.onrender.com/';



class PagosApp extends StatelessWidget {
  final Color primaryColor = Color(0xFF1976D2); 
  final Color secondaryColor = Color(0xFFBBDEFB); 
  final Color errorColor = Color(0xFFD32F2F); 
  final Color successColor = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Pago de Servicios',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: secondaryColor,
          primary: primaryColor,
          error: errorColor,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', 
      ),
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ServiciosPage(),
    RegistrarPagoPage(),
    HistorialPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _titles = ['Servicios', 'Registrar Pago', 'Historial'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pago'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}

class ServiciosPage extends StatefulWidget {
  @override
  _ServiciosPageState createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  late Future<List<Servicio>> servicios;

  @override
  void initState() {
    super.initState();
    servicios = fetchServicios();
  }

  Future<List<Servicio>> fetchServicios() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/servicios.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error cargando servicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Servicio>>(
      future: servicios,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(child: Text('No hay servicios disponibles.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final servicio = items[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(servicio.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(servicio.descripcion),
                  trailing: Text('\$${servicio.precio.toStringAsFixed(2)}', style: TextStyle(color: Color(0xFF1976D2))),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;

  Servicio({required this.id, required this.nombre, required this.descripcion, required this.precio});

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
    );
  }
}

class RegistrarPagoPage extends StatefulWidget {
  @override
  _RegistrarPagoPageState createState() => _RegistrarPagoPageState();
}

class _RegistrarPagoPageState extends State<RegistrarPagoPage> {
  final _formKey = GlobalKey<FormState>();
  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  String _nombre = '';
  String _email = '';
  String _telefono = '';
  String? _metodoPago;
  bool _isLoading = false;
  String? _mensaje;
  String _numeroTarjeta = '';
  String _fechaExpiracion = '';
  String _cvv = '';

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  String _generarNumeroReferencia() {
    final now = DateTime.now();
    final random = Random();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    final randomNum = random.nextInt(9999).toString().padLeft(4, '0');
    return 'REF${timestamp}${randomNum}';
  }

  Future<void> _cargarServicios() async {
    try {
      final servicios = await http.get(Uri.parse('$apiBaseUrl/servicios.php'));
      if (servicios.statusCode == 200) {
        List<dynamic> data = jsonDecode(servicios.body);
        setState(() {
          _servicios = data.map((json) => Servicio.fromJson(json)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error cargando servicios';
      });
    }
  }

  Future<void> _enviarPago() async {
    if (!_formKey.currentState!.validate() || _servicioSeleccionado == null || _metodoPago == null) {
      setState(() {
        _mensaje = 'Por favor completa todos los campos correctamente.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _mensaje = null;
    });

    _formKey.currentState!.save();

    // Si el método de pago es tarjeta, procesar el pago
    if (_metodoPago == 'tarjeta') {
      try {
        // Simulación de procesamiento de pago
        final paymentResult = await procesarPagoConTarjeta(
          _nombre,
          _email,
          _telefono,
          _servicioSeleccionado!.id,
          _numeroTarjeta,
          _fechaExpiracion,
          _cvv,
        );

        if (paymentResult['success']) {
          final payload = jsonEncode({
            'nombre': _nombre,
            'email': _email,
            'telefono': _telefono,
            'servicio_id': _servicioSeleccionado!.id,
            'metodo_pago': _metodoPago,
            'estado': 'pendiente', 
          });

          await http.post(
            Uri.parse('$apiBaseUrl/registrar_pago.php'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          );

          setState(() {
            _mensaje = 'Pago registrado como pendiente.';
            _formKey.currentState!.reset();
            _servicioSeleccionado = null;
            _metodoPago = null;
            _numeroTarjeta = '';
            _fechaExpiracion = '';
            _cvv = '';
          });
        } else {
          setState(() {
            _mensaje = 'Error al procesar el pago con tarjeta.';
          });
        }
      } catch (e) {
        setState(() {
          _mensaje = 'Error de conexión al servidor: $e';
        });
      }
    } else if (_metodoPago == 'transferencia') {
      // Generar número de referencia para transferencia
      String numeroReferencia = _generarNumeroReferencia();

      final payload = jsonEncode({
        'nombre': _nombre,
        'email': _email,
        'telefono': _telefono,
        'servicio_id': _servicioSeleccionado!.id,
        'metodo_pago': _metodoPago,
        'numero_referencia': numeroReferencia,
        'estado': 'pendiente', // Siempre establecer como pendiente
      });

      try {
        final res = await http.post(
          Uri.parse('$apiBaseUrl/registrar_pago.php'),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        );

        if (res.statusCode == 200) {
          setState(() {
            _mensaje = 'Pago registrado correctamente. Número de referencia: $numeroReferencia';
            _formKey.currentState!.reset();
            _servicioSeleccionado = null;
            _metodoPago = null;
          });
        } else {
          setState(() {
            _mensaje = 'Error al registrar el pago.';
          });
        }
      } catch (e) {
        setState(() {
          _mensaje = 'Error de conexión al servidor: $e';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> procesarPagoConTarjeta(String nombre, String email, String telefono, int servicioId, String numeroTarjeta, String fechaExpiracion, String cvv) async {
    await Future.delayed(Duration(seconds: 2)); 
    return {'success': true}; 
  }

  Widget _buildDropdown() {
    if (_servicios.isEmpty) {
      return Text('Cargando servicios...');
    }
    return DropdownButtonFormField<Servicio>(
      decoration: InputDecoration(labelText: 'Servicio a pagar'),
      value: _servicioSeleccionado,
      items: _servicios
          .map((servicio) => DropdownMenuItem(
                child: Text('${servicio.nombre} - \$${servicio.precio.toStringAsFixed(2)}'),
                value: servicio,
              ))
          .toList(),
      onChanged: (val) => setState(() => _servicioSeleccionado = val),
      validator: (val) => val == null ? 'Selecciona un servicio' : null,
    );
  }

  Widget _buildMetodoPagoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Método de Pago'),
      value: _metodoPago,
      items: [
        DropdownMenuItem(child: Text('Transferencia Bancaria'), value: 'transferencia'),
        DropdownMenuItem(child: Text('Tarjeta de Crédito/Débito'), value: 'tarjeta'),
      ],
      onChanged: (val) {
        setState(() {
          _metodoPago = val;
          // Reiniciar campos de tarjeta si se cambia el método de pago
          if (val != 'tarjeta') {
            _numeroTarjeta = '';
            _fechaExpiracion = '';
            _cvv = '';
          }
        });
      },
      validator: (val) => val == null ? 'Selecciona un método de pago' : null,
    );
  }

  Widget _buildCardFields() {
    return Column(
      children: [
        _buildTextField('Número de Tarjeta', (v) => _numeroTarjeta = v!.trim(), keyboardType: TextInputType.number),
        _buildTextField('Fecha de Expiración (MM/AA)', (v) => _fechaExpiracion = v!.trim(), keyboardType: TextInputType.datetime),
        _buildTextField('CVV', (v) => _cvv = v!.trim(), keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved, {TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Asegúrate de que este widget esté presente
        child: Column(children: [
          if (_mensaje != null) _buildMensaje(),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField('Nombre completo', (v) => _nombre = v!.trim()),
                _buildTextField('Correo electrónico', (v) => _email = v!.trim(), keyboardType: TextInputType.emailAddress),
                _buildTextField('Teléfono (opcional)', (v) => _telefono = v?.trim() ?? '', keyboardType: TextInputType.phone),
                SizedBox(height: 16),
                _buildDropdown(),
                SizedBox(height: 16),
                _buildMetodoPagoDropdown(),
                if (_metodoPago == 'tarjeta') _buildCardFields(),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _enviarPago,
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Registrar Pago'),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMensaje() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _mensaje!.toLowerCase().contains('error') ? Colors.red[50] : Colors.green[50],
          border: Border.all(
            color: _mensaje!.toLowerCase().contains('error') ? Colors.red : Colors.green,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _mensaje!,
          style: TextStyle(
            color: _mensaje!.toLowerCase().contains('error') ? Colors.red[800] : Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HistorialPage extends StatefulWidget {
  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late Future<List<Pago>> _pagos;

  @override
  void initState() {
    super.initState();
    _pagos = _fetchPagos();
  }

  Future<List<Pago>> _fetchPagos() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/pagos.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pago.fromJson(json)).toList();
    } else {
      throw Exception('Error cargando pagos');
    }
  }

  Future<void> _validarPago(int pagoId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/validar_pago.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pago_id': pagoId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pago validado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Recargar la lista de pagos
          setState(() {
            _pagos = _fetchPagos();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Error al validar el pago'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoValidacion(Pago pago) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Confirmar la validación del siguiente pago?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Cliente: ${pago.usuario}'),
              Text('Servicio: ${pago.servicio}'),
              Text('Monto: \$${pago.monto.toStringAsFixed(2)}'),
              if (pago.numeroReferencia != null)
                Text('Referencia: ${pago.numeroReferencia}'),
              Text('Estado actual: ${pago.estado}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Validar'),
              onPressed: () {
                Navigator.of(context).pop();
                _validarPago(pago.id);
              },
            ),
          ],
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'validado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pago>>(
      future: _pagos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pagos registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _pagos = _fetchPagos();
              });
            },
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pago = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('${pago.usuario} - ${pago.servicio}', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${pago.email}', style: TextStyle(color: Colors.black54)),
                        Text('Fecha: ${pago.fechaPago}', style: TextStyle(color: Colors.black54)),
                        if (pago.numeroReferencia != null)
                          Text('Ref: ${pago.numeroReferencia}', style: TextStyle(color: Colors.black54)),
                        Row(
                          children: [
                            Text('Estado: '),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getEstadoColor(pago.estado),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pago.estado.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${pago.monto.toStringAsFixed(2)}', 
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                        if (pago.estado.toLowerCase() == 'pendiente')
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                            onPressed: () => _mostrarDialogoValidacion(pago),
                            tooltip: 'Validar pago',
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class Pago {
  final int id;
  final String usuario;
  final String email;
  final String servicio;
  final double monto;
  final String fechaPago;
  final String estado;
  final String? numeroReferencia;

  Pago({
    required this.id,
    required this.usuario,
    required this.email,
    required this.servicio,
    required this.monto,
    required this.fechaPago,
    required this.estado,
    this.numeroReferencia,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: int.parse(json['id'].toString()),
      usuario: json['usuario'],
      email: json['email'],
      servicio: json['servicio'],
      monto: double.parse(json['monto'].toString()),
      fechaPago: json['fecha_pago'],
      estado: json['estado'],
      numeroReferencia: json['numero_referencia'],
    );
  }
}