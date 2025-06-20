import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Jss1TopicsScreen extends StatelessWidget {
  static const List<String> topics = [
    'Numbers & Numeration',
    'Factors & Multiples',
    'Number Base System',
    'Fractions',
    'Estimation',
    'Approximation',
    'Basic Operations Involving the Binary System',
    'Algebra',
    'Perimeter of Plane Shapes',
    'Area of Plane Shapes',
    'Volume',
    'Capacity',
    'Angles',
    'Data Collection/Statistics',
  ];

  const Jss1TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSS 1 Topics'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a topic",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, idx) => _TopicExpansionTile(topic: topics[idx]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicExpansionTile extends StatelessWidget {
  final String topic;
  const _TopicExpansionTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(
          topic,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.purple,
          ),
        ),
        children: List.generate(3, (i) {
          final topicNum = i + 1;
          return ListTile(
            title: Text(
              'Topic $topicNum',
              style: textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 17),
            onTap: () {
              context.push('/jss1-topic/${Uri.encodeComponent(topic)}/$topicNum');
            },
          );
        }),
      ),
    );
  }
}