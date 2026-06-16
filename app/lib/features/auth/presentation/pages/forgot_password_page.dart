import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/password_reset_controller.dart';

/// Pantalla de recuperación de contraseña. Envía el email de reset vía Supabase.
///
/// Pantalla funcional mínima (sin pulir). Maneja los tres estados del envío:
/// enviando / enviado / error.
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
      appBar: AppBar(title: const Text('Recuperar contraseña')),
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
                    'Introduce tu email y te enviaremos instrucciones para '
                    'restablecer tu contraseña.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enabled: !isLoading && !isSent,
                  ),
                  if (isSent) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Si ese email tiene una cuenta, te hemos enviado las '
                      'instrucciones. Revisa tu bandeja de entrada.',
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
                  if (isSent)
                    AppButton(
                      label: 'Volver',
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  else
                    AppButton(
                      label: 'Enviar email',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
