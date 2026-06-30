import 'package:flutter/material.dart';

/// Single source of truth for navigation. `main.dart` listens to the
/// intent stream and uses [rootNavigatorKey] to push the preview
/// screen even when the user is somewhere other than the home page
/// (e.g. Settings, or while the app is starting up).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
