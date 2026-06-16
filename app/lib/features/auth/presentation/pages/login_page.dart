import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/password_strength.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/login_controller.dart';
import 'forgot_password_page.dart';

/// Pantalla de login/registro. Un toggle alterna entre los dos modos: en
/// registro se piden además nombre y confirmación de contraseña.
///
/// Pantalla funcional mínima (sin pulir): la lógica de validación vive en
/// `core/validation`, el estado en `LoginController`. El estilo se aborda en un
/// prompt posterior.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  /// `true` = modo registro; `false` = modo inicio de sesión.
  bool _isRegister = false;

  // Errores de validación por campo (null = sin error).
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    // Redibuja la barra de fuerza al escribir la contraseña.
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (_isRegister) setState(() {});
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });
  }

  /// Valida los campos del modo actual. Devuelve `true` si todo es válido.
  bool _validate() {
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    final nameError = _isRegister ? Validators.name(_nameController.text) : null;
    final confirmError = _isRegister
        ? Validators.confirmPassword(
            _confirmController.text,
            _passwordController.text,
          )
        : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _nameError = nameError;
      _confirmError = confirmError;
    });

    return emailError == null &&
        passwordError == null &&
        nameError == null &&
        confirmError == null;
  }

  void _submit() {
    if (!_validate()) return;
    final controller = ref.read(loginControllerProvider.notifier);
    if (_isRegister) {
      controller.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );
    } else {
      controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.isLoading;
    final errorMessage =
        state.hasError ? (state.error as AuthFailure).message : null;
    final needsConfirmation =
        state.asData?.value == AuthFormStatus.emailConfirmationRequired;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegister ? 'Crea tu cuenta' : 'Bienvenido',
                    style: textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isRegister
                        ? 'Regístrate para empezar'
                        : 'Inicia sesión para continuar',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_isRegister) ...[
                    AppTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      errorText: _nameError,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    errorText: _passwordError,
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  if (_isRegister) ...[
                    _PasswordStrengthBar(password: _passwordController.text),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Confirmar contraseña',
                      errorText: _confirmError,
                      obscureText: true,
                      enabled: !isLoading,
                    ),
                  ],
                  if (needsConfirmation) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Te hemos enviado un email de confirmación. Revísalo para '
                      'activar tu cuenta antes de iniciar sesión.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: _isRegister ? 'Registrarse' : 'Iniciar sesión',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  AppButton(
                    label: _isRegister
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Regístrate',
                    variant: AppButtonVariant.neutral,
                    onPressed: isLoading ? null : _toggleMode,
                  ),
                  if (!_isRegister) ...[
                    const SizedBox(height: AppSpacing.s),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              ),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de fuerza de contraseña. Pinta el resultado de
/// [evaluatePasswordStrength]; se oculta si la contraseña está vacía.
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final result = evaluatePasswordStrength(password);
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (result.level) {
      PasswordStrength.weak => colorScheme.error,
      PasswordStrength.medium => colorScheme.tertiary,
      PasswordStrength.strong => colorScheme.primary,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: result.score,
            color: color,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seguridad: ${result.label}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
