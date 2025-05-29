import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to Math Guru!',
          style: textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
