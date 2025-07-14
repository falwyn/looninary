import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Text(
          'Chào mừng bạn đến trang quản trị!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}