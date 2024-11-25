import 'package:flutter/material.dart';

class HomeDetailsPage extends StatelessWidget {
  const HomeDetailsPage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: const Center(
        child: Text('HomeDetailsPage'),
      ),
    );
  }
}