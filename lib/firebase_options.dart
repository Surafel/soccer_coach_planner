// Placeholder until Firebase is set up for this app.
//
// Running `flutterfire configure` (see docs/firebase-setup.md) replaces this
// file with the club's real Firebase settings. Until then the app keeps all
// data on each device, exactly as before.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Firebase is not configured for this app yet. '
        'Run `flutterfire configure` (see docs/firebase-setup.md).',
      );
}
