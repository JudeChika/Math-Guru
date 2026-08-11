import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> jss2Topics = {
  'Whole Numbers': [
    'Factors, Prime Factors',
    'HCF & LCM',
    'Rules for Divisibility',
    'Number Patterns',
    'Squares & Square Roots',
  ],
  'Indices & Standard Form': [
    'Laws of Indices',
    'Standard Form',
  ],
  'Quadrilaterals': [
    'Parallelogram',
    'Rhombus',
    'Kite',
    'Connections Between Quadrilaterals',
    'Patterns With Shapes',
  ],
  'Directed Numbers': [
    'Addition & Subtraction',
    'Multiplication',
    'Division',
  ],
  'Statistics 1': [
    'Data Presentation',
    'Lists and Tables',
    'Graphs',
  ],
  'Angles 1': [
    'Angles in a Quadrilateral',
    'Angles in a Polygon',
  ],
  'Algebraic Expressions (Expansion)': [
    'Directed Algebraic terms',
    'Removing Brackets',
    'Expanding Algebraic Expressions',
  ],
  'Approximation & Estimation': [
    'Approximation',
    'Estimation',
  ],
  'Fractions, Proportions, Ratio, Rate': [
    'Fractions',
    'Proportions',
    'Ratio',
    'Rate',
  ],
  'Home & Office Transactions': [
    'Personal Arithmetic',
    'Household Arithmetic',
    'Civic Arithmetic',
    'Commercial Transactions',
  ],
  'Algebra, Factors, Factorisation, Fractions': [
    'Algebraic Factors & Multiples',
    'Factorisation',
    'Algebraic Fractions',
  ],
  'Cartesian Planes & Coordinates': [
    'Position of Points',
    'Cartesian Planes',
    'Coordinates',
    'Plotting Points',
    'Meters',
  ],
  'Solving Equations': [
    'Solving Equations 1',
    'Solving Equations 2',
    'World Problems',
  ],
  'Straight Line Graphs': [
    'Linear Graphs',
    'Graphs of Real Life Situations',
    'Travel Graphs',
  ],
  'Triangles & Angles': [
    'Construction of Triangles',
    'To Bisect any Angle',
  ],
  'Scale Drawing': [
    'Scale',
    'Scale Drawing',
    'Reading Scale Drawings',
  ],
  'Pythagoras Rule': [
    'Right-Angled Triangle',
    'Pythagoras Rule',
    'Pythagoras in Real Life',
  ],
  'Statistics 2: Tables, Charts, Schedules': [
    'Reading Tabulated Data',
    'Timetables & Charts',
  ],
  'Cylinders & Cones': [
    'Cylinders',
    'Cones',
    'Measuration & Estimation',
  ],
  'Evaluation & Depression': [
    'Horizontal & Vertical',
    'Elevation',
    'Scale Drawings',
  ],
  'Statistics 3: Probability': [
    'Experimental Probability',
    'Probability as a Fraction',
  ],
  'Linear Inequalities': [
    'Inequalities',
    'Graphs of Inequalities',
    'Solution of Inequalities',
  ],
  'Graphs of Linear Equations': [
    'Linear Equations & Graphs',
    'Properties of Linear Graphs',
  ],
  'Bearings & Distances': [
    'Compass Directions',
    'Bearings',
    'Bearings & Distances',
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