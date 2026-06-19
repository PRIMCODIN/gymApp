import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/password_reset_controller.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_footer_prompt.dart';

/// Pantalla de recuperación de contraseña. Estilada según el design system y el
/// mockup. Envía el email de reset vía Supabase; maneja los tres estados del
/// envío (enviando / enviado / error). La lógica no se toca.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final emailError = Validators.email(_emailController.text);
    setState(() => _emailError = emailError);
    if (emailError != null) return;
    ref
        .read(passwordResetControllerProvider.notifier)
        .send(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    final isLoading = state.isLoading;
    final isSent = state.asData?.value == PasswordResetStatus.sent;
    final errorMessage =
        state.hasError ? (state.error as AuthFailure).message : null;

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
              Text('Recuperar contraseña', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Introduce tu correo y te enviaremos un enlace para '
                'restablecerla.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                prefixIcon: Icons.mail_outline,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !isLoading && !isSent,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (isSent) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Si ese correo tiene una cuenta, te hemos enviado las '
                  'instrucciones. Revisa tu bandeja de entrada.',
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
              if (isSent)
                AppButton(
                  label: 'Volver',
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                AppButton(
                  label: 'Continuar',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
              const SizedBox(height: AppSpacing.m),
              AuthFooterPrompt(
                question: '¿Recordaste tu contraseña?',
                action: 'Inicia sesión',
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
