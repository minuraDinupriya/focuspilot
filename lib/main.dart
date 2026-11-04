import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/app.dart';
import 'package:focuspilot/app/app_bloc_observer.dart';
import 'package:focuspilot/app/global_error_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Structured BLoC state transition observability
  Bloc.observer = const AppBlocObserver();

  // 2. Production Crash Observability for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In production, forward to Sentry / Firebase Crashlytics
      debugPrint('[ReleaseCrash] Flutter error: ${details.exception}');
    }
  };

  // 3. Intercept root platform dispatch errors (asynchronous Dart errors outside widget tree)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[PlatformError] Uncaught async error: $error\n$stack');
    return true; // Mark as handled to prevent process termination
  };

  // 4. Custom ErrorWidget to replace the red screen of death in UI builds
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorView(errorDetails: details);
  };

  runApp(const FocusPilotApp());
}
