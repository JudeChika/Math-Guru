import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> jss2Topics = {
  'Numbers & Numeration': [
    'Roman Number System',
    'Egyptian Number System',
    'Hindu Number System',
    'Counting',
    'Place-value',
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
    'Conversion to decimal',
    'Conversion to percentage',
    'Number line',
    'Addition & Subtraction',
    'Multiplication',
    'Division',
  ],
  'Estimation': [
    'Dimensions & Distances',
    'Capacity & Mass Objects',
    'Estimation of other things',
  ],
  'Approximation': [
    'Addition & Subtraction',
    'Multiplication & Division',
    'Rounding off Numbers',
  ],
  'Basic Operations involving the Binary System': [
    'Addition',
    'Subtraction',
    'Multiplication',
    'Division',
  ],
  'Algebra': [
    'Basic Operations',
    'Simplifying Expressions',
    'Translation of Word Problems into Mathematical Statements',
    'Translation of Algebraic Sentences into Words',
  ],
  'Perimeter of Plane Shapes': [
    'Square',
    'Rectangle',
    'Triangle',
    'Polygon',
    'Trapezium',
    'Parallelogram',
    'Circle',
  ],
  'Area of Plane Shapes': [
    'Square',
    'Rectangle',
    'Triangle',
    'Polygon',
    'Trapezium',
    'Parallelogram',
    'Circle',
  ],
  'Volume': [
    'Cube',
    'Cuboid',
  ],
  'Capacity': [
    'Litres',
    'Cubic Centimeters',
    'Millilitres',
    'Meter Cube',
    'Meters',
    'Kilolitres',
    'Volume or Capacity of Container',
    'Volume or Capacity of Right-angled Triangular Prism',
  ],
  'Angles': [
    'Angle of Rotation',
    'Angle in Degrees',
    'Conversion to Degrees',
    'Conversion to Time',
    'Vertically Opposite Angles',
    'Angles on a Straight Line',
    'Angles at a Point',
    'Right Angles',
    'Triangles',
  ],
  'Data Collection/Statistics': [
    'Decision Making',
    'Frequency Distribution Table',
    'Bar Chart',
    'Line Graph',
    'Arithmetic Mean, Median, Mode',
  ],
};

class Jss2TopicsScreen extends StatelessWidget {
  const Jss2TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSS 2 Topics'),
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
                  for (final entry in jss2Topics.entries)
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
                  '/jss2-topic/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(subtopic)}',
                );
              },
            ),
        ],
      ),
    );
  }
}