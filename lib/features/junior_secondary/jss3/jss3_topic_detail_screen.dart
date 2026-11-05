import 'package:flutter/material.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/binary_computer_applications/binary_computer_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/binary_to_base10/binary_to_base10_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/flow_chart/flow_chart_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/other_bases_to_binary/other_bases_to_binary_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_number_system/punch_tape/punch_tape_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/binary_operations/binary_mul_div/binary_mul_div_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/compound_interest/compound_interest/compound_interest_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/compound_interest/simple_interest/simple_interest_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_algebra/common_factors/common_factors_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_algebra/expansion/expansion_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_algebra/grouping_terms/grouping_terms_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_algebra/hcf_algebra/hcf_algebraic_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_algebra/simplify_calculations/simplify_calculations_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_quadratic_equation/coefficients_of_terms/coefficients_of_terms_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_quadratic_equation/difference_of_two_squares/difference_of_two_squares_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_quadratic_equation/perfect_squares/perfect_squares_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_quadratic_equation/quadratic_expansion/quadratic_expansion_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/factorisation_quadratic_equation/quadratic_factorisation/quadratic_factorisation_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/proportion/direct_proportion/direct_proportion_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/proportion/indirect_proportion/indirect_proportion_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/proportion/reciprocals/reciprocals_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/rational_and_nonrational_numbers/non_rational_numbers/non_rational_numbers_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/rational_and_nonrational_numbers/rational_numbers/rational_numbers_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/rational_and_nonrational_numbers/square_roots/square_roots_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simple_equations_involving_fractions/binomial_denominators/binomial_denominators_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simple_equations_involving_fractions/monomial_denominators/monomial_denominators_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simple_equations_involving_fractions/simple_equations_fractions/simple_equations_fractions_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simple_equations_involving_fractions/word_problems_fractions/word_problems_fractions_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simultaneous_linear_equations/elimination_method/elimination_method_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simultaneous_linear_equations/graphical_method/graphical_method_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simultaneous_linear_equations/simultaneous_intro/simultaneous_intro_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simultaneous_linear_equations/simultaneous_word_problems/simultaneous_word_problems_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/simultaneous_linear_equations/substitution_method/substitution_method_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/substitution_formulae_change/formulae_substitution/formulae_substitution_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/fraction_word_problems/fraction_word_problems_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/numerical_to_words/numerical_to_words_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/problems_involving_equations/problems_involving_equations_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/product/product_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/sum_and_difference/sum_and_difference_screen.dart';
import 'package:math_guru/features/junior_secondary/jss3/word_problems/sum_diff_product/sum_diff_product_screen.dart';

import 'binary_operations/binary_add_sub/binary_add_sub_screen.dart';

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
    if (subtopic == 'Changing numerical expressions into words') {
      return const NumericalToWordsScreen();
    }
    if (subtopic == 'Problems involving equations') {
      return const ProblemsInvolvingEquationsScreen();
    }
    if (subtopic == 'Direct proportion') {
      return const DirectProportionScreen();
    }
    if (subtopic == 'Indirect proportion') {
      return const IndirectProportionScreen();
    }
    if (subtopic == 'Reciprocals') {
      return const ReciprocalsScreen();
    }
    if (subtopic == 'Simple interest') {
      return const SimpleInterestScreen();
    }
    if (subtopic == 'Compound interest') {
      return const CompoundInterestScreen();
    }
    if (subtopic == 'Rational numbers') {
      return const RationalNumbersScreen();
    }
    if (subtopic == 'Non-rational numbers') {
      return const NonRationalNumbersScreen();
    }
    if (subtopic == 'Square roots') {
      return const SquareRootsScreen();
    }
    if (subtopic == 'Addition and subtraction of binary numbers') {
      return const BinaryAddSubScreen();
    }
    if (subtopic == 'Multiplication and division in base 2') {
      return const BinaryMulDivScreen();
    }
    if (subtopic == 'Expansion of algebraic expressions') {
      return const ExpansionScreen();
    }
    if (subtopic == 'HCF of algebraic expressions') {
      return const HcfAlgebraicScreen();
    }
    if (subtopic == 'Factorisation by taking out common factors') {
      return const CommonFactorsScreen();
    }
    if (subtopic == 'Simplifying calculations by factorisation') {
      return const SimplifyCalculationsScreen();
    }
    if (subtopic == 'Factorisation by grouping like terms') {
      return const GroupingTermsScreen();
    }
    if (subtopic == 'Expansion of algebraic expression') {
      return const QuadraticExpansionScreen();
    }
    if (subtopic == 'Coefficients of terms') {
      return const CoefficientsOfTermsScreen();
    }
    if (subtopic == 'Factorisation of quadratic expression') {
      return const QuadraticFactorisationScreen();
    }
    if (subtopic == 'Perfect squares') {
      return const PerfectSquaresScreen();
    }
    if (subtopic == 'Difference of two squares') {
      return const DifferenceOfTwoSquaresScreen();
    }
    if (subtopic == 'Solving simple equations involving fractions') {
      return const SimpleEquationsFractionsScreen();
    }
    if (subtopic == 'Simple equations with monomial denominators') {
      return const MonomialDenominatorsScreen();
    }
    if (subtopic == 'Simple equations with binomial denominators') {
      return const BinomialDenominatorsScreen();
    }
    if (subtopic == 'Word problems involving algebraic fractions') {
      return const WordProblemsFractionsScreen();
    }
    if (subtopic == 'Simultaneous linear equations') {
      return const SimultaneousIntroScreen();
    }
    if (subtopic == 'Graphical method') {
      return const GraphicalMethodScreen();
    }
    if (subtopic == 'Substitution method') {
      return const SubstitutionMethodScreen();
    }
    if (subtopic == 'Elimination method') {
      return const EliminationMethodScreen();
    }
    if (subtopic == 'Word problems involving simultaneous linear equations') {
      return const SimultaneousWordProblemsScreen();
    }
    if (subtopic == 'Formulae and substitution') {
      return const FormulaeSubstitutionScreen();
    }
    if (subtopic == 'Changing the subject of a formula') {
      return const FormulaeSubstitutionScreen();
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