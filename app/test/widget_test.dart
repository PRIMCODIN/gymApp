// Smoke test de las pantallas de auth.
//
// No inicializa Supabase: solo verifica que la UI de auth se construye y muestra
// los controles básicos, y que desde login se navega a la pantalla de registro
// (pantalla aparte, no un toggle) con sus campos extra. Las acciones (que sí
// tocan Supabase) no se disparan aquí.
// Usa el theme central porque los componentes base consumen la `AppPalette`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/app_text_field.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';

void main() {
  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const LoginPage(),
        ),
      ),
    );
    // El estado inicial del controller es async (loading); un pump lo resuelve a
    // AsyncData y la pantalla muestra los controles en vez del indicador de carga.
    await tester.pump();
  }

  testWidgets('LoginPage muestra los controles de inicio de sesión', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    // Las etiquetas de los campos se renderizan como hintText (un Text findable).
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
    // 'Iniciar sesión' es el título de la pantalla; el botón es 'Entrar'.
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('¿Olvidaste?'), findsOneWidget);
  });

  testWidgets('navegar a registro muestra los campos de la cuenta nueva', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    // El registro vive en una pantalla aparte (SignUpPage); el enlace del pie
    // navega hacia ella.
    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(4));
    // 'Crear cuenta' aparece dos veces: como título y como botón de envío.
    expect(find.text('Crear cuenta'), findsNWidgets(2));
  });
}
