import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Email-and-password sign-in, with account creation and password reset.
/// Email links and Google sign-in were left out because they need extra,
/// per-platform setup (the Android build's signing key changes every CI run).
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _creatingAccount = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  Future<void> _submit() async {
    if (_email.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (_creatingAccount) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _passwordController.text,
        );
        await credential.user?.sendEmailVerification();
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email,
          password: _passwordController.text,
        );
      }
      // The auth gate takes over from here.
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.isEmpty) {
      setState(() => _error = 'Enter your email first, then tap "Forgot password?".');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('If $_email has an account, a reset link is on its way.')),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _messageFor(e));
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'That email already has an account. Sign in instead.';
      case 'weak-password':
        return 'Choose a password with at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      default:
        return e.message ?? 'Something went wrong (${e.code}).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_creatingAccount ? 'Create account' : 'Sign in')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Coaches sign in to see the club\'s shared groups, '
                    'sessions and schedules.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: [
                      _creatingAccount ? AutofillHints.newPassword : AutofillHints.password,
                    ],
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_creatingAccount ? 'Create account' : 'Sign in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _creatingAccount = !_creatingAccount;
                              _error = null;
                            }),
                    child: Text(
                      _creatingAccount
                          ? 'Already have an account? Sign in'
                          : 'New coach? Create an account',
                    ),
                  ),
                  if (!_creatingAccount)
                    TextButton(
                      onPressed: _busy ? null : _resetPassword,
                      child: const Text('Forgot password?'),
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

/// Shown after creating an account until the coach clicks the link in the
/// verification email. Requiring a verified email stops someone from
/// signing up with an approved coach's address.
class VerifyEmailScreen extends StatefulWidget {
  final User user;
  final VoidCallback onVerified;

  const VerifyEmailScreen({super.key, required this.user, required this.onVerified});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _checkVerified() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        // A fresh token carries the verified flag the database checks.
        await refreshed.getIdToken(true);
        widget.onVerified();
      } else {
        setState(() => _message = 'Not verified yet. Click the link in the email, then try again.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Something went wrong (${e.code}).');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await widget.user.sendEmailVerification();
      setState(() => _message = 'Sent another email to ${widget.user.email}.');
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.code == 'too-many-requests'
          ? 'An email was sent recently. Wait a minute before asking for another.'
          : e.message ?? 'Something went wrong (${e.code}).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'We sent a link to ${widget.user.email}. Click it to verify '
                  'your email, then come back here. Check your spam folder if '
                  'you don\'t see it.',
                  textAlign: TextAlign.center,
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _checkVerified,
                  child: const Text('I\'ve verified my email'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : _resend,
                  child: const Text('Send the email again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
