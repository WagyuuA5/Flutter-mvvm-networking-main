import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/post/presentation/pages/post_list_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MVVMNetworkingApp(),
    ),
  );
}

class MVVMNetworkingApp extends StatelessWidget {
  const MVVMNetworkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVVM Networking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const PostListPage(),
    );
  }
}
