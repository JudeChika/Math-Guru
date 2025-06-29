import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss1/fractions/mixed_improper/mixed_improper_screen.dart';
import 'package:math_guru/features/junior_secondary/jss1/number_base_system/binary_conversion/binary_conversion_screen.dart';
import 'factors_multiples/hcf/hcf_screen.dart';
import 'factors_multiples/lcm/lcm_screen.dart';
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