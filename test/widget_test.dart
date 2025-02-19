import 'package:flutter_test/flutter_test.dart';
import 'package:inscribe/main.dart'; // Asegúrate de que el nombre del paquete sea correcto.

void main() {
  testWidgets('Home screen displays correctly', (WidgetTester tester) async {
    // Construye la aplicación.
    await tester.pumpWidget(const MyApp());

    // Verifica que la pantalla de inicio tiene el botón "Registrar Estudiante".
    expect(find.text('Registrar Estudiante'), findsOneWidget);
    expect(find.text('Ver Estudiantes Registrados'), findsOneWidget);
  });

  testWidgets('Navigates to student registration screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Toca el botón "Registrar Estudiante".
    await tester.tap(find.text('Registrar Estudiante'));
    await tester.pumpAndSettle();

    // Verifica que estamos en la pantalla de registro de estudiantes.
    expect(find.text('Registro de Estudiantes'), findsOneWidget);
  });

  testWidgets('Navigates to student list screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Toca el botón "Ver Estudiantes Registrados".
    await tester.tap(find.text('Ver Estudiantes Registrados'));
    await tester.pumpAndSettle();

    // Verifica que estamos en la pantalla de lista de estudiantes.
    expect(find.text('Lista de Estudiantes'), findsOneWidget);
  });
}
