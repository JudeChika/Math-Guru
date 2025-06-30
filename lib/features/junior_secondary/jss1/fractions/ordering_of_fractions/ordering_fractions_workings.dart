import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ordering_fractions_models.dart';
import 'fraction_display.dart';

class OrderingFractionsWorkings extends StatelessWidget {
  final int lcm;
  final List<WorkingStep> steps;

  const OrderingFractionsWorkings({super.key, required this.lcm, required this.steps});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    final tableStyle = GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workings:', style: textStyle),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text("LCM of denominators: ", style: tableStyle),
              Math.tex(
                "\\mathrm{LCM}(${steps.map((s) => s.denominator).join(", ")}) = $lcm",
                textStyle: GoogleFonts.poppins(
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
            headingTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.purple),
            dataTextStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
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
                    color: Colors.deepPurple, fontFamily: 'Poppins',
                  )),
                  DataCell(
                    FractionDisplay(
                      numerator: s.lcm,
                      denominator: 1,
                      fontSize: 16,
                      color: Colors.deepPurple, fontFamily: 'Poppins',
                    ),
                  ),
                  DataCell(
                    Text("${s.numerator} × ${s.factor} = ${s.value}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                  ),
                ]),
            ],
            headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
            dataRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          ),
        ),
      ],
    );
  }
}