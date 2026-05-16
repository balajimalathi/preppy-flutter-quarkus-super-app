import 'package:core_auth/core_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      final value = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (value is AuthErrorState && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(value.message)));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).clearError();
        });
      }
    });

    final authAsync = ref.watch(authProvider);
    final busy = authAsync.isLoading;

    return PreppyScaffold(
      title: 'Sign in',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AutofillGroup(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: 'email',
                  controller: _email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'password',
                  controller: _password,
                  enabled: !busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitEmailPassword(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : _submitEmailPassword,
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: busy ? null : _google,
                  child: const Text('Continue with Google'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: busy ? null : _signUp,
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitEmailPassword() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      return;
    }
    await ref
        .read(authProvider.notifier)
        .signIn(EmailCredentials(email: email, password: password));
  }

  Future<void> _google() async {
    await ref.read(authProvider.notifier).signIn(const GoogleCredentials());
  }

  Future<void> _signUp() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      return;
    }
    await ref
        .read(authProvider.notifier)
        .signUp(EmailCredentials(email: email, password: password));
  }
}
