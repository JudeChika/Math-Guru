import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss1/statistics/bar_chart/bar_chart_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/algebraic_expressions/directed_algebraic_terms/directed_algebra_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/algebraic_expressions/expanding_expressions/expanding_expressions_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/algebraic_expressions/removing_brackets/removing_brackets_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/algebraic_expressions/substitution/substitution_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/angles_between_lines/geometry_angles_screen.dart' hide GeometryAnglesScreen;
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/heptagon_angles/heptagon_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/hexagon_angles/hexagon_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/n_gon_angles/n_gon_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/octagon_angles/octagon_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/pentagon_angles/pentagon_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/quadrilateral_angles/quadrilateral_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/triangle_angles/triangle_angles_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/approximation_and_estimation/approximation/approximation_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/approximation_and_estimation/estimation/estimation_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/approximation_and_estimation/rate/rate_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/approximation_and_estimation/ratio/ratio_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/directed_numbers/basic_operations/directed_numbers_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/fractions_proportions_ratio_rate/fractions_percentages/fractions_percentages_screen.dart';
import 'package:math_guru/features/junior_secondary/jss2/fractions_proportions_ratio_rate/proportion/proportion_screen.dart';
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
    if (subtopic == 'Angles in a Triangle') {
      return const TriangleAnglesScreen();
    }
    if (subtopic == 'Angles in a Quadrilateral') {
      return const QuadrilateralAnglesScreen();
    }
    if (subtopic == 'Angles in a Pentagon') {
      return const PentagonAnglesScreen();
    }
    if (subtopic == 'Angles in a Hexagon') {
      return const HexagonAnglesScreen();
    }
    if (subtopic == 'Angles in a Heptagon') {
      return const HeptagonAnglesScreen();
    }
    if (subtopic == 'Angles in an Octagon') {
      return const OctagonAnglesScreen();
    }
    if (subtopic == 'n-gon Angles') {
      return const NSidedPolygonScreen();
    }
    if (subtopic == 'Directed Algebraic terms') {
      return const DirectedAlgebraScreen();
    }
    if (subtopic == 'Substitution') {
      return const SubstitutionScreen();
    }
    if (subtopic == 'Removing Brackets') {
      return const RemovingBracketsScreen();
    }
    if (subtopic == 'Expanding Algebraic Expressions') {
      return const ExpandingExpressionsScreen();
    }
    if (subtopic == 'Approximation') {
      return const ApproximationScreen();
    }
    if (subtopic == 'Estimation') {
      return const EstimationScreen();
    }
    if (subtopic == 'Fractions & Percentages') {
      return const FractionsPercentagesScreen();
    }
    if (subtopic == 'Proportions') {
      return const ProportionScreen();
    }
    if (subtopic == 'Ratio') {
      return const RatioScreen();
    }
    if (subtopic == 'Rate') {
      return const RateScreen();
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