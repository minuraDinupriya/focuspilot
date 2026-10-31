import 'package:flutter/material.dart';
import 'package:focuspilot/app/app_shell.dart';

class FocusPilotApp extends StatelessWidget {
  const FocusPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusPilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const AppShell(),
    );
  }
}
