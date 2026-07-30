import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss2/indices_and_standard_form/indices_screen.dart';

class Jss2TopicDetailScreen extends StatelessWidget {
  final String topic;
  final String subtopic;
  const Jss2TopicDetailScreen({
    super.key,
    required this.topic,
    required this.subtopic,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    print('topic: $topic, subtopic: "$subtopic"'); // Debug

    if (subtopic == 'Laws of Indices') {
      return const IndicesAndStandardFormScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('$topic - $subtopic'),
      ),
      body: Center(
        child: Text(
          'Content for $topic\n$subtopic',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}