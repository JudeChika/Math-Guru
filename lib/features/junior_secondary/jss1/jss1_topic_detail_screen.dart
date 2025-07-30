import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss1/approximation/addition_subtraction/addition_subtraction_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/approximation/rounding_off_numbers/rounding_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/conversion_to_percentage/conversion_to_percentage_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/fraction_division/fraction_division_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/fraction_multiplication/fraction_multiplication_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/mixed_improper/mixed_improper_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/number_line/number_line_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/number_base_system/binary_conversion/binary_conversion_screen.dart';
import 'factors_multiples/hcf/hcf_screen.dart';
import 'factors_multiples/lcm/lcm_screen.dart';
import 'fractions/addition_subtraction_fractions/fraction_addition_subtraction_screen.dart';
import 'fractions/conversion_to_decimal/conversion_to_decimal_and_fraction_screen.dart';
import 'fractions/equivalent_fractions/equivalent_fractions_screen.dart';
import 'fractions/ordering_of_fractions/ordering_fractions_screen.dart';
import 'number_base_system/binary_counting/binary_counting_screen.dart';
import 'numbers_and_numeration/counting/counting_converter_screen.dart';
import 'numbers_and_numeration/egyptian_number/egyptian_converter_screen.dart';
import 'numbers_and_numeration/hindu_number/hindu_converter_screen.dart';
import 'numbers_and_numeration/place_value/place_value_screen.dart';
import 'numbers_and_numeration/roman_number/roman_converter_screen.dart';


class Jss1TopicDetailScreen extends StatelessWidget {
  final String topic;
  final String subtopic;
  const Jss1TopicDetailScreen({
    super.key,
    required this.topic,
    required this.subtopic,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (subtopic == 'Roman Number System') {
      return const RomanConverterScreen();
    }
    if (subtopic == 'Egyptian Number System' || subtopic == 'Early Egyptian Number System') {
      return const EgyptianConverterScreen();
    }
    if (subtopic == 'Hindu Number System' || subtopic == 'Early Hindu Number System') {
      return const HinduConverterScreen();
    }
    if (subtopic == 'Counting') {
      return const CountingConverterScreen();
    }
    if (subtopic == 'Place-value') {
      return const PlaceValueScreen();
    }
    if (subtopic == 'LCM') {
      return const LCMScreen();
    }
    if (subtopic == 'HCF') {
      return const HCFScreen();
    }
    if (subtopic == 'Counting in binary') {
      return const BinaryCountingScreen();
    }
    if (subtopic == 'Binary Conversion') {
      return const BinaryConversionScreen();
    }
    if (subtopic == 'Mixed Numbers & Improper Fractions') {
      return const MixedImproperScreen();
    }
    if (subtopic == 'Ordering of Fractions') {
      return const OrderingFractionsScreen();
    }
    if (subtopic == 'Equivalent Fractions') {
      return const EquivalentFractionsScreen();
    }
    if (subtopic == 'Conversion to decimal') {
      return const ConversionToDecimalAndFractionScreen();
    }
    if (subtopic == 'Conversion to percentage') {
      return const ConversionToPercentageScreen();
    }
    if (subtopic == 'Number line') {
      return const NumberLineScreen();
    }
    if (subtopic == 'Addition & Subtraction') {
      return const FractionAdditionSubtractionScreen();
    }
    if (subtopic == 'Multiplication') {
      return const FractionMultiplicationScreen();
    }
    if (subtopic == 'Division') {
      return const FractionDivisionScreen();
    }
    if (subtopic == 'Rounding off Numbers') {
      return const RoundingScreen();
    }
    if (subtopic == 'Addition & Subtraction Approximation') {
      return const ApproximationAddSubtractScreen();
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