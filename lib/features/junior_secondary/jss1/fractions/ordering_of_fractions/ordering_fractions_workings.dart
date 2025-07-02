import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'fraction_display.dart';

import 'ordering_fractions_models.dart';

class OrderingFractionsWorkings extends StatelessWidget {
  final int lcm;
  final List<WorkingStep> steps;

  const OrderingFractionsWorkings({super.key, required this.lcm, required this.steps});

  @override
  Widget build(BuildContext context) {
    const tableStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Workings:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text("LCM of denominators: ", style: tableStyle),
            Math.tex(
              "\\mathrm{LCM}(${steps.map((s) => s.denominator).join(", ")}) = $lcm",
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Multiply each fraction by the LCM:", style: tableStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: tableStyle.copyWith(fontWeight: FontWeight.w600, color: Colors.purple),
            dataTextStyle: tableStyle,
            columns: const [
              DataColumn(label: Text('Fraction')),
              DataColumn(label: Text('× LCM')),
              DataColumn(label: Text('= Value')),
            ],
            rows: [
              for (final s in steps)
                DataRow(cells: [
                  DataCell(FractionDisplay(
                    numerator: s.numerator,
                    denominator: s.denominator,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  )),
                  DataCell(
                    FractionDisplay(
                      numerator: s.lcm,
                      denominator: 1,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  DataCell(
                    Text("${s.numerator} × ${s.factor} = ${s.value}",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                          fontSize: 14,
                        )),
                  ),
                ]),
            ],
            headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
            dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          ),
        ),
      ],
    );
  }
}