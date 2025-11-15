import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and other services here in future
  // await AppDatabase().database; // Pre-initialize database if needed

  runApp(
    const ProviderScope(
      child: HisaabApp(),
    ),
  );
}
