import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/binary_computer_applications/binary_computer_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/binary_to_base10/binary_to_base10_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/flow_chart/flow_chart_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/other_bases_to_binary/other_bases_to_binary_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/punch_tape/punch_tape_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/fraction_word_problems/fraction_word_problems_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/product/product_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/sum_and_difference/sum_and_difference_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/sum_diff_product/sum_diff_product_screen.dart';

class Jss3TopicDetailScreen extends StatelessWidget {
  final String topic;
  final String subtopic;
  const Jss3TopicDetailScreen({
    super.key,
    required this.topic,
    required this.subtopic,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (subtopic == 'Conversion of Binary to Base 10') {
      return const BinaryToBase10Screen();
    }
    if (subtopic == 'Conversion of other number bases to Binary') {
      return const OtherBasesToBinaryScreen();
    }
    if (subtopic == 'Application of Binary numbers to computers') {
      return const BinaryComputerScreen();
    }
    if (subtopic == 'Punch Tape') {
      return const PunchTapeScreen();
    }
    if (subtopic == 'Flow Chart') {
      return const FlowChartScreen();
    }
    if (subtopic == 'Sum and difference') {
      return const SumAndDifferenceScreen();
    }
    if (subtopic == 'Product') {
      return const ProductScreen();
    }
    if (subtopic == 'Sums and differences combined with products') {
      return const SumDiffProductScreen();
    }
    if (subtopic == 'Word problems involving fractions') {
      return const FractionWordProblemsScreen();
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