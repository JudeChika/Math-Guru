import 'package:flutter/material.dart';

class Jss1TopicDetailScreen extends StatelessWidget {
  final String topic;
  final int topicNumber;
  const Jss1TopicDetailScreen({
    super.key,
    required this.topic,
    required this.topicNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('$topic - Topic $topicNumber'),
      ),
      body: Center(
        child: Text(
          'Content for $topic\nTopic $topicNumber',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}