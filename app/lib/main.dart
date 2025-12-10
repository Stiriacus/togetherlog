import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TogetherLogApp(),
    ),
  );
}

class TogetherLogApp extends StatelessWidget {
  const TogetherLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TogetherLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'TogetherLog - Coming Soon',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
