import 'package:core_auth/core_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LogoutButtonStyle { text, icon }

/// Confirms with the user, then calls [AuthNotifier.signOut]. Router redirect
/// to `/login` is handled by app-level [GoRouter] auth guards.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({
    super.key,
    this.label = 'Log out',
    this.style = LogoutButtonStyle.text,
    this.onSignedOut,
  });

  final String label;
  final LogoutButtonStyle style;
  final VoidCallback? onSignedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (style) {
      LogoutButtonStyle.text => TextButton(
        onPressed: () => _confirmAndSignOut(context, ref),
        child: Text(label),
      ),
      LogoutButtonStyle.icon => IconButton(
        tooltip: label,
        icon: const Icon(Icons.logout),
        onPressed: () => _confirmAndSignOut(context, ref),
      ),
    };
  }

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    final signedOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _SignOutConfirmDialog(
        onSignOut: () => ref.read(authProvider.notifier).signOut(),
      ),
    );
    if (signedOut == true) {
      onSignedOut?.call();
    }
  }
}

class _SignOutConfirmDialog extends StatefulWidget {
  const _SignOutConfirmDialog({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  State<_SignOutConfirmDialog> createState() => _SignOutConfirmDialogState();
}

class _SignOutConfirmDialogState extends State<_SignOutConfirmDialog> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await widget.onSignOut();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out?'),
      content: const Text(
        'You will need to sign in again to access your account.',
      ),
      actions: [
        TextButton(
          onPressed: _signingOut
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _signingOut ? null : _signOut,
          child: _signingOut
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign out'),
        ),
      ],
    );
  }
}
