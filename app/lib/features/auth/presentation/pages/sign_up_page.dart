import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/password_strength_bar.dart';
import '../state/login_controller.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_prompt.dart';
import '../widgets/auth_social_row.dart';

/// Pantalla de registro. Estilada según el design system y el mockup.
///
/// Comparte `LoginController` con la pantalla de login (expone `signUp`); la
/// lógica de validación y de registro no se toca. Tras un registro correcto que
/// requiere confirmación de email, muestra el aviso correspondiente.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

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

  void _onPasswordChanged() => setState(() {});

  bool _validate() {
    final nameError = Validators.name(_nameController.text);
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmError = Validators.confirmPassword(
      _confirmController.text,
      _passwordController.text,
    );
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmError == null;
  }

  void _submit() {
    if (!_validate()) return;
    ref.read(loginControllerProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
  }

  void _goToLogin() {
    ref.invalidate(loginControllerProvider);
    Navigator.of(context).pop();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthBackButton(),
              const SizedBox(height: AppSpacing.m),
              Text('Crear cuenta', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Regístrate para empezar a seguir tu progreso.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _nameController,
                label: 'Nombre',
                prefixIcon: Icons.person_outline,
                errorText: _nameError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                prefixIcon: Icons.mail_outline,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                controller: _passwordController,
                label: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                errorText: _passwordError,
                isPassword: true,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              PasswordStrengthBar(password: _passwordController.text),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                controller: _confirmController,
                label: 'Confirmar',
                prefixIcon: Icons.lock_outline,
                errorText: _confirmError,
                isPassword: true,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (needsConfirmation) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Te hemos enviado un email de confirmación. Revísalo para '
                  'activar tu cuenta antes de iniciar sesión.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: 'Crear cuenta',
                onPressed: _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.m),
              AuthFooterPrompt(
                question: '¿Ya tienes cuenta?',
                action: 'Inicia sesión',
                onPressed: isLoading ? null : _goToLogin,
              ),
              const SizedBox(height: AppSpacing.l),
              const AuthDivider(),
              const SizedBox(height: AppSpacing.l),
              const AuthSocialRow(),
            ],
          ),
        ),
      ),
    );
  }
}
