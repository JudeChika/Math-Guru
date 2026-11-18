import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Data structure for topics and their subtopics
const Map<String, List<String>> sss1Topics = {
  'Number Base System': [
    'Conversion of numbers in base 10 to other bases',
    'Conversion of numbers in other bases to base 10',
    'Conversion of decimal fractions from other bases to base 10 (Bicimal numbers)',
    'Basic operations involving number base system',
    'Equations involving number base system',
    'Application of number base system to computers',
  ],
  'Modular Arithmetic': [
    'Addition, Subtraction, Multiplication and Division',
    'Circular variables and modular arithmetic',
    'Algebraic processes involving modular arithmetic',
    'Simple equations in modular arithmetic',
    'Application of modular arithmetic to real-life situations',
    'Menstrual arithmetic',
  ],
  'Indices': [
    'Standard form',
    'Indices',
    'Product of indices (Product law)',
    'Fractional indices',
    'Problems involving indicial equations',
  ],
  'Logarithms': [
    'Relationship between indices and logarithms ',
    'Meaning of logarithms',
    'Use of graphs in logarithms',
    'Use of logarithm tables',
    'Antilogarithm tables',
    'Application of logarithms to capital markets',
  ],
  'Sets (1)': [
    'Introduction',
    'Set notation',
    'Elements',
    'Types of sets',
  ],
  'Sets (2)': [
    'Operations on sets',
    'Application of Venn diagrams to solving problems on sets',
  ],
  'Change of Subject of Formulae and Variation': [
    'Change of subject of formulae',
    'Direct variation',
    'Inverse variation',
    'Joint variation',
    'Partial variation',
  ],
  'Quadratic Equations': [
    'Introduction',
    'Factorisation of quadratic expressions',
    'Difference of two squares',
    'Construction of quadratic equations with given roots',
    'Graphs of quadratic equations',
    'Word problems leading to quadratic equations',
  ],
  'Logical Reasoning (1)': [
    'Introduction',
    'Simple statements',
    'True and false statements',
    'Negation of logical statements',
    'Truth tables',
    'Application to real-life situations',
    'Importance of logic to life',
  ],
  'Logical Reasoning (2)': [
    'Compound statements',
    'Connectives',
    'Disjunction',
    'Implicative (or conditional) statements',
    'Bi-conditional statements',
    'Tautology',
    'Contradiction',
  ],
  'Basic Geometrical Constructions': [
    'Revision of basic geometrical constructions',
    'Construction of triangles',
  ],
  'Constructions: Quadrilaterals and Loci': [
    'Construction of quadrilaterals and loci',
    'Locus of a point',
  ],
  'Basic Geometric Theorems (1): Triangles and Polygons': [
    'Introduction',
    'Angles',
    'Elementary theorems',
    'Polygons',
    'Isosceles and equilateral triangles',
  ],
  'Basic Geometric Theorems (2): Parallelograms and Equal Intercepts': [
    'Quadrilaterals',
    'More elementary theorems',
    'Congruent triangles',
    'Intercept',
  ],
  'Trigonometry (1):  trigonometrical ratios': [
    'Sine, cosine and tangent',
    'Complementary angles',
    'Pythagoras theorem',
    'Special angles: 45°, 30° and 60°',
  ],
  'Trigonometry (2):  general angles and graphs': [
    'Introduction',
    'Trigonometrical ratios of angles between 0° and 360°',
    'Trigonometrical ratios of allied angles',
    'Graphs of sine and cosine functions',
  ],
  'Plane shapes: mensuration': [
    'Areas and perimeters of plane shapes',
    'Length of an arc of a circle',
    'Perimeters of sectors and segments',
    'Areas of sectors and segments of a circle',
    'Relationship between the sector of a circle and the surface area of a cone',
  ],
  'Surface area and volume of solid shapes': [
    'Surface areas of solids',
    'Volume of solid shapes',
    'Surface area and volume of frustum',
    'Surface areas and volumes of compound shapes',
  ],
  'Statistics (1)': [
    'Introduction',
    'Frequency tables',
    'Graphical representation of data',
  ],
  'Statistics (2)': [
    'Pie chart',
    'Frequency polygons',
  ],
};

class Sss1TopicsScreen extends StatelessWidget {
  const Sss1TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSS 1 Topics'),
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
                  for (final entry in sss1Topics.entries)
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
                  '/sss1-topic/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(subtopic)}',
                );
              },
            ),
        ],
      ),
    );
  }
}