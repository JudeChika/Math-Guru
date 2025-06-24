import 'package:flutter/material.dart';
import 'roman_number/roman_converter_screen.dart';
import 'egyptian_number/egyptian_converter_screen.dart';

class Jss1TopicDetailScreen extends StatelessWidget {
  final String topic;
  final String subtopic;
  const Jss1TopicDetailScreen({
    super.key,
    required this.topic,
    required this.subtopic,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (subtopic == 'Roman Number System') {
      return const RomanConverterScreen();
    }
    if (subtopic == 'Egyptian Number System' || subtopic == 'Early Egyptian Number System') {
      return const EgyptianConverterScreen();
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