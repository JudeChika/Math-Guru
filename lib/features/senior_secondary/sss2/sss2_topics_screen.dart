import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> sss2Topics = {
  'Logarithms': [
    'Logarithms of numbers greater than 1',
    'Expressing numbers less than 1 in standard form',
    'Logarithms of numbers less than 1',
    'Powers and roots of numbers less than 1',
    'Solving simple logarithmic equations',
  ],
  'Approximation': [
    'Rounding off',
    'Rounding to decimal places',
    'Significant figure',
    'Approximation',
    'Percentage and relative error',
    'Degree of accuracy',
    'Application of approximation to real-life situations',
  ],
  'Sequences and Series': [
    'Sequence',
    'Series',
    'Arithmetic Progression (AP)',
    'The nth term of an Arithmetic Progression',
    'Sum of terms of an AP',
    'Geometric Progression (GP)',
    'The nth term of a GP',
    'The sum of a GP to infinity',
  ],
  'Quadratic Equations': [
    'Factorisation of perfect squares',
    'Making quadratic expressions into perfect squares',
    'Solving quadratic equations by completing the square method',
    'Quadratic equations with irrational roots',
    'Derivation of quadratic formulae from completing the square',
    'Deriving quadratic equations from the sum and products of roots',
    'Word problems leading to quadratic equations ',
  ],
  'Simultaneous Linear and Quadratic Equations': [
    'Simultaneous linear equations',
    'Simultaneous linear and quadratic equations',
    'Graphical solution of simultaneous linear and quadratic equations',
    'Solving related problems involving graphical solutions of linear and quadratic equations',
    'Word problems involving simultaneous, linear and quadratic equations',
  ],
  'Gradient of a Curve': [
    'Straight line graph',
    'Gradient of a straight line',
    'Equation of a straight line',
    'Gradient of a curve at a given point',
  ],
  'Logical Reasoning': [
    'Statements; proposition',
    'Conditional statements',
    'Tautology and contradiction',
    'Laws of algebra of logical statements',
  ],
  'Linear Inequalities': [
    'Linear inequalities in one variable',
    'Combining inequalities (Range of values)',
    'The cartesian plane',
    'Simultaneous inequalities',
    'Application of inequalities to real-life situations (Linear programming)',
  ],
  'Algebraic Fractions': [
    'Simplification of algebraic fractions',
    'Operations in algebraic fractions',
    'Equation involving fractions',
    'Substitution in fractions',
    'Simultaneous equations involving fractions',
    'Undefined algebraic fractions',
  ],
  'Chord Properties of a Circle': [
    'Chord properties of a circle',
    'Chord theorems',
  ],
  'Circle theorems': [
    'Angles at the centre of the circle',
    'Angles in the same segment of a circle',
    'Cyclic quadrilaterals',
    'Angles on the alternate segments of a circle',
  ],
  'Trigonometry: Sine and Cosine Rules': [
    'Trigonometrical ratios',
    'The sine rule and its application',
    'The cosine rule and its application',
    'Application of sine and cosine rules to other related problems',
  ],
  'Bearings': [
    'Angles of elevations and depression',
    'The cardinal points',
    'Practical problems on bearings and distances',
  ],
  'Histograms of Grouped Data': [
    'Grouping of data',
    'Histogram',
  ],
  'Measures of central tendency and dispersion of disctrete data': [
    'Measures of central tendency',
    'The arithmetic mean',
    'The median',
    'The mode',
    'Mixtures and average rate',
    'Measures of dispersion',
  ],
  'Measures of central tendency and dispersion of grouped data': [
    'Measures of central tendency of grouped data',
    'Mean of grouped data',
    'Median of grouped data',
    'Mode of grouped data',
    'Measures of dispersion of grouped data',
  ],
  'Cumulative frequency graph': [
    'Cumulative frequency',
    'Quartiles and percentiles',
    'Cumulative percentage curve',
  ],
  'Probability': [
    'Experimental and theoretical probability',
    'Mutually exclusive events',
    'Independent events',
    'Probability tree',
  ],
};

class Sss2TopicsScreen extends StatelessWidget {
  const Sss2TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSS 2 Topics'),
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
                  for (final entry in sss2Topics.entries)
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
                  '/sss2-topic/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(subtopic)}',
                );
              },
            ),
        ],
      ),
    );
  }
}