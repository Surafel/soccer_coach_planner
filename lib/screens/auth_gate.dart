import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/data_store.dart';
import '../services/firestore_remote.dart';
import '../services/shared_data_import.dart';
import 'root_screen.dart';
import 'sign_in_screen.dart';

/// Front door when the app uses the club's shared data: coaches sign in,
/// verify their email, and must be on the club's approved list before they
/// can see anything. The database's security rules enforce the same.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const SignInScreen();
        if (!user.emailVerified) {
          return VerifyEmailScreen(user: user, onVerified: () => setState(() {}));
        }
        return _ApprovedCoachGate(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

Future<void> _signOut() => FirebaseAuth.instance.signOut();

class _ApprovedCoachGate extends StatefulWidget {
  final User user;

  const _ApprovedCoachGate({super.key, required this.user});

  @override
  State<_ApprovedCoachGate> createState() => _ApprovedCoachGateState();
}

enum _Stage { checking, notApproved, offerCopy, ready, failed }

class _ApprovedCoachGateState extends State<_ApprovedCoachGate> {
  final _remote = FirestoreRemote();
  late final _store = SyncedDataStore(_remote);
  _Stage _stage = _Stage.checking;
  bool _copying = false;
  String _failure = '';

  String get _email => widget.user.email!.toLowerCase();
  String get _approvedFlagKey => 'approved_coach.${widget.user.uid}';

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _stage = _Stage.checking);
    try {
      await _checkAccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = e is FirebaseException && e.code == 'permission-denied'
            ? 'The club database refused access. Its security rules may not be set up yet.'
            : 'Couldn\'t check your access: $e';
        _stage = _Stage.failed;
      });
    }
  }

  Future<void> _checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    bool approved;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('approvedCoaches')
          .doc(_email)
          .get();
      approved = doc.exists;
      await prefs.setBool(_approvedFlagKey, approved);
    } on FirebaseException catch (e) {
      if (e.code != 'unavailable') rethrow;
      // Offline: trust the last answer, so the app still opens from the
      // cached data. The database checks again once back online.
      approved = prefs.getBool(_approvedFlagKey) ?? false;
      if (!approved) {
        if (!mounted) return;
        setState(() {
          _failure = 'Connect to the internet to finish signing in.';
          _stage = _Stage.failed;
        });
        return;
      }
    }
    if (!approved) {
      if (mounted) setState(() => _stage = _Stage.notApproved);
      return;
    }

    var offerCopy = false;
    try {
      offerCopy = !await _remote.hasAnyData(allCollections) && await deviceHasOwnData();
    } on FirebaseException catch (e) {
      if (e.code != 'unavailable') rethrow;
    }
    if (mounted) setState(() => _stage = offerCopy ? _Stage.offerCopy : _Stage.ready);
  }

  Future<void> _copyDeviceData() async {
    setState(() => _copying = true);
    try {
      await copyDeviceDataTo(_store);
      if (mounted) setState(() => _stage = _Stage.ready);
    } catch (_) {
      if (!mounted) return;
      setState(() => _copying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not copy the data. Check your connection and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case _Stage.failed:
        return _MessageScreen(
          title: 'Can\'t sign in yet',
          message: _failure,
          actionLabel: 'Try again',
          onAction: _check,
        );
      case _Stage.notApproved:
        return _MessageScreen(
          title: 'Waiting for approval',
          message: '$_email isn\'t on the club\'s list of coaches yet. Ask the '
              'club admin to approve this email address, then try again.',
          actionLabel: 'Try again',
          onAction: _check,
        );
      case _Stage.offerCopy:
        return _MessageScreen(
          title: 'Share this device\'s data?',
          message: 'The club has no shared data yet. Copy the groups, players, '
              'coaches, sessions, drills and schedules saved on this device so '
              'every coach sees them?',
          actionLabel: 'Copy to the club',
          onAction: _copying ? null : _copyDeviceData,
          secondaryLabel: 'Start empty',
          onSecondary: _copying ? null : () => setState(() => _stage = _Stage.ready),
          busy: _copying,
        );
      case _Stage.ready:
        return RootScreen(
          store: _store,
          signedInEmail: widget.user.email,
          onSignOut: _signOut,
        );
    }
  }
}

class _MessageScreen extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool busy;

  const _MessageScreen({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [TextButton(onPressed: _signOut, child: const Text('Sign out'))],
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
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (busy)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  FilledButton(onPressed: onAction, child: Text(actionLabel)),
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 8),
                    TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
