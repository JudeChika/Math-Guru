import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> jss1Topics = {
  'Numbers & Numeration': [
    'Roman Number System',
    'Early Egyptian Number System',
    'Hindu Number System',
    'Counting',
    'Place-value',
    'Unit Conversion',
  ],
  'Factors & Multiples': [
    'LCM',
    'HCF',
  ],
  'Number Base System': [
    'Counting in binary',
    'Binary Conversion',
  ],
  'Fractions': [
    'Mixed Numbers & Improper Fractions',
    'Ordering of Fractions',
    'Equivalent Fractions',
    'Conversion to decimal',
    'Conversion to percentage',
    'Number line',
    'Addition & Subtraction',
    'Multiplication',
    'Division',
  ],
  'Approximation': [
    'Rounding off Numbers',
    'Addition & Subtraction Approximation',
    'Multiplication & Division',
  ],
  'Basic Operations involving the Binary System': [
    'Binary Addition',
    'Binary Subtraction',
    'Binary Multiplication',
    'Binary Division',
  ],
  'Algebra': [
    'World Problems involving the use of Letters',
    'Basic Operations',
    'Simplifying Expressions Involving Brackets',
  ],
  'Perimeter of Plane Shapes': [
    'Square',
    'Rectangle',
    'Triangle',
    'Polygon',
    'Trapezium',
    'Parallelogram',
    'Circle',
    'Quadrant'
  ],
  'Area of Plane Shapes': [
    'Area of Square',
    'Area of Rectangle',
    'Area of Triangle',
    'Area of Polygon',
    'Area of Trapezium',
    'Area of Parallelogram',
    'Area of Circle',
  ],
  'Volume': [
    'Cube',
    'Cuboid',
    'Capacity of Container',
    'Capacity of Right-angled Triangular Prism',
  ],
  'Angles': [
    'Angle of Rotation',
    'Geometry Angles',
  ],
  'Data Collection/Statistics': [
    'Decision Making',
    'Bar Chart',
    'Line Graph',
  ],
};

class Jss1TopicsScreen extends StatelessWidget {
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
              child: ListView(
                children: [
                  for (final entry in jss1Topics.entries)
                    _TopicExpansionTile(
                      topic: entry.key,
                      subtopics: entry.value,
                    ),
                ],
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
  final List<String> subtopics;
  const _TopicExpansionTile({required this.topic, required this.subtopics});

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
        children: [
          for (final subtopic in subtopics)
            ListTile(
              title: Text(
                subtopic,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: (textTheme.bodySmall?.fontSize ?? 12) + 3, // Slightly larger than bodySmall but smaller than bodyMedium
                  color: Colors.black,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () {
                context.push(
                  '/jss1-topic/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(subtopic)}',
                );
              },
            ),
        ],
      ),
    );
  }
}