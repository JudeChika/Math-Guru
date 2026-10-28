import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> jss3Topics = {
  'Binary number system': [
    'Conversion of Binary to Base 10',
    'Conversion of other number bases to Binary',
    'Application of Binary numbers to computers',
    'Punch Tape',
    'Flow Chart',
  ],
  'Word problems': [
    'Sum and difference',
    'Product',
    'Sums and differences combined with products',
    'Word problems involving fractions',
    'Changing numerical expressions into words',
    'Problems involving equations',
  ],
  'Proportion': [
    'Direct proportion',
    'Indirect proportion',
    'Reciprocals',
    'Reciprocals from the calculator',
  ],
  'Compound interest': [
    'Simple interest',
    'Compound interest',
  ],
  'Rational and non-rational numbers': [
    'Rational numbers',
    'Non-rational numbers',
    'Square roots',
  ],
  'Basic operations involving binary numbers': [
    'Addition and subtraction of binary numbers',
    'Multiplication and division in base 2',
  ],
  'Factorisation of simple algebraic expression': [
    'Expansion of algebraic expressions',
    'HCF of algebraic expressions',
    'Factorisation by taking out common factors',
    'Simplifying calculations by factorisation',
    'Factorisation by grouping like terms',
  ],
  'Factorisation of quadratic expressions': [
    'Expansion of algebraic expression',
    'Coefficients of terms',
    'Factorisation of quadratic expression',
    'Perfect squares',
    'Factorisation of quadratic expression',
    'Difference of two squares',
  ],
  'Equations involving fractions': [
    'Solving simple equations involving fractions',
    'Simple equations with monomial denominators',
    'Simple equations with binomial denominators',
    'Word problems involving algebraic fractions',
  ],
  'Simultaneous linear equations': [
    'Simultaneous linear equations',
    'Graphical method',
    'Substitution method',
    'Elimination method',
  ],
  'Substitution and change of subject of formulae': [
    'Formulae and substitution',
    'Changing the subject of a formula',
  ],
  'Similar figures': [
    'Similar figures',
    'Similar triangles',
    'Enlargement and scale factors',
  ],
  'Areas and volumes of similar shapes': [
    'Areas of similar plane shapes',
    'Volumes of similar solid shapes',
  ],
  'Tangent of acute angle': [
    'Finding the tangent of an acute angle',
    'Finding tangent of acute angles by measurement',
    'Use of the tangent ratio',
    'Use of tangent table',
    'Application of tangents of angles in solving practical problems',
  ],
  'Sine and cosine of an acute angle': [
    'Sine and cosine of an acute angle',
    'Sines and cosines of acute angles by drawing and measurement',
    'Use of sine and cosine tables',
    'Using sine and cosine to solve right-angled triangle problems',
    'Applications of sines and cosines of acute angles to solve word problems',
  ],
  'Areas of plane shapes': [
    'Area of plane shapes',
    'Areas of plane shapes, using trigonometry',
    'Concentric circles and sectors of circle',
    'Real life activities involving area',
  ],
  'Geometrical constructions': [
    'Construction',
    'Constructions of plane shapes',
  ],
  'Measures of central tendency': [
    'Averages',
    'The mean',
    'Finding the mean from a frequency table',
    'The median',
    'The mode',
    'The range',
  ],
  'Data presentation': [
    'Bar charts',
    'Pie charts',
  ],
};

class Jss3TopicsScreen extends StatelessWidget {
  const Jss3TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSS 3 Topics'),
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
                  for (final entry in jss3Topics.entries)
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
                  '/jss3-topic/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(subtopic)}',
                );
              },
            ),
        ],
      ),
    );
  }
}