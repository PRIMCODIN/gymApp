// Smoke test de la pantalla de login.
//
// No inicializa Supabase: solo verifica que la UI de auth se construye y muestra
// los controles básicos, y que el toggle a modo registro añade los campos extra.
// Las acciones (que sí tocan Supabase) no se disparan aquí.
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

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });

  testWidgets('al cambiar a registro aparecen nombre y confirmación', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pump();

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(4));
    expect(find.text('Registrarse'), findsOneWidget);
  });
}
