import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss1/statistics/bar_chart/bar_chart_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/angles_between_lines/geometry_angles_screen.dart' hide GeometryAnglesScreen;
import 'package:math_guru/features/junior_secondary/jss2/directed_numbers/basic_operations/directed_numbers_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/statistics_1/frequency_distribution_table/frequency_table_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/statistics_1/pie_chart/pie_chart_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/whole_numbers/divisibility_rules/divisibility_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/whole_numbers/factors_and_primes/factors_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/whole_numbers/hcf_lcm/hcf_lcm_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/whole_numbers/number_patterns/number_patterns_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/whole_numbers/squares_roots/squares_roots_screen.dart';
import 'indices_and_standard_form/laws_of_indices/indices_screen.dart';
import 'indices_and_standard_form/standard_form/standard_form_screen.dart';

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
    if (subtopic == 'Standard Form') {
      return const StandardFormScreen();
    }
    if (subtopic == 'Factors, Prime Factors') {
      return const FactorsScreen();
    }
    if (subtopic == 'HCF & LCM') {
      return const HCFLCMScreen();
    }
    if (subtopic == 'Rules for Divisibility') {
      return const DivisibilityScreen();
    }
    if (subtopic == 'Number Patterns') {
      return const NumberPatternsScreen();
    }
    if (subtopic == 'Squares & Square Roots') {
      return const SquaresAndRootsScreen();
    }
    if (subtopic == 'Basic Operations') {
      return const DirectedNumbersScreen();
    }
    if (subtopic == 'Frequency Distribution Table') {
      return const FrequencyTableScreen();
    }
    if (subtopic == 'Bar Chart') {
      return const BarChartScreen();
    }
    if (subtopic == 'Pie Chart') {
      return const PieChartScreen();
    }
    if (subtopic == 'Angles Between Lines') {
      return const AnglesRulesScreen();
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