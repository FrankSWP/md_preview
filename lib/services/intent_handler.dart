import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Bridges the platform-specific file-sharing channels
/// (Android `Intent.ACTION_VIEW`, iOS document opening) into
/// a Dart stream of file URIs.
class IntentHandler {
  /// Emits the URI of every Markdown file shared with the app.
  ///
  /// On Android, the first value is the URI the app was started
  /// with (cold start). Subsequent values are URIs the user
  /// shared while the app was already running.
  Stream<String> get sharedFileUris => _ctrl.stream;
  final _ctrl = StreamController<String>.broadcast();

  StreamSubscription<dynamic>? _sub;

  void start() {
    // Note: receive_sharing_intent's getMediaStream() is a non-broadcast
    // stream, so we must subscribe exactly once. The errors are logged
    // to debugPrint rather than swallowed silently.
    _sub ??= ReceiveSharingIntent.instance.getMediaStream().listen(
      (events) {
        for (final e in events) {
          final uri = normalizeUri(e.path);
          if (uri != null) _ctrl.add(uri);
        }
      },
      onError: (Object e, StackTrace st) {
        debugPrint('IntentHandler: media stream error: $e\n$st');
      },
    );
    // Cold-start: process the URI the app was launched with.
    ReceiveSharingIntent.instance.getInitialMedia().then((events) {
      for (final e in events) {
        final uri = normalizeUri(e.path);
        if (uri != null) _ctrl.add(uri);
      }
    }).catchError((Object e, StackTrace st) {
      debugPrint('IntentHandler: initial media error: $e\n$st');
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _ctrl.close();
  }

  /// Trim a URI received from the platform; returns null if the
  /// input is null/empty.
  static String? normalizeUri(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    return t.isEmpty ? null : t;
  }
}