import 'package:flutter_test/flutter_test.dart';
import 'package:pagos_app_flutter/main.dart';

void main() {
  testWidgets('Verifica que la pantalla de servicios se carga correctamente', (WidgetTester tester) async {
    // Construir nuestra app y desencadenar un frame.
    await tester.pumpWidget(PagosApp());

    // Verificar que el título de la app está presente.
    expect(find.text('Servicios'), findsOneWidget);

    // Verificar que el botón de registrar pago está presente.
    expect(find.text('Registrar Pago'), findsOneWidget);

    // Verificar que el botón de historial está presente.
    expect(find.text('Historial'), findsOneWidget);
  });
}