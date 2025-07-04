import 'package:flutter/material.dart';

class LongDivisionDecimalWidget extends StatelessWidget {
  final int numerator;
  final int denominator;
  final List steps; // compatibility placeholder
  final String decimalQuotient;
  final int maxDecimalPlaces;

  const LongDivisionDecimalWidget({
    super.key,
    required this.numerator,
    required this.denominator,
    required this.steps,
    required this.decimalQuotient,
    this.maxDecimalPlaces = 6,
  });

  List<_DivisionVisualStep> _computeDivisionSteps(int numerator, int denominator, int maxDecimalPlaces) {
    List<_DivisionVisualStep> visuals = [];
    int current = numerator;
    bool hasDecimalPoint = false;
    int decimalCount = 0;
    StringBuffer quotient = StringBuffer();

    // Integer part
    int q = current ~/ denominator;
    int r = current % denominator;
    quotient.write(q);

    visuals.add(_DivisionVisualStep(value: current.toDouble(), isDividend: true, isDecimal: false));
    visuals.add(_DivisionVisualStep(value: (q * denominator).toDouble(), isDividend: false, isDecimal: false));
    visuals.add(_DivisionVisualStep(isSeparator: true));
    visuals.add(_DivisionVisualStep(value: r.toDouble(), isDividend: true, isDecimal: false));

    // Decimal part
    if (r != 0) {
      quotient.write('.');
      hasDecimalPoint = true;
    }

    int remainder = r;
    Set<int> seenRemainders = {};
    while (remainder != 0 && decimalCount < maxDecimalPlaces) {
      if (seenRemainders.contains(remainder)) break; // recurring
      seenRemainders.add(remainder);

      remainder *= 10;
      int digit = remainder ~/ denominator;
      double product = digit * denominator.toDouble();
      double displayDividend = remainder.toDouble();

      visuals.add(_DivisionVisualStep(
        value: displayDividend,
        isDividend: true,
        isDecimal: true,
      ));
      visuals.add(_DivisionVisualStep(
        value: product,
        isDividend: false,
        isDecimal: true,
      ));
      visuals.add(_DivisionVisualStep(isSeparator: true));

      remainder = remainder % denominator;
      visuals.add(_DivisionVisualStep(
        value: remainder.toDouble(),
        isDividend: true,
        isDecimal: true,
      ));

      quotient.write(digit);
      decimalCount++;
    }

    return visuals;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _computeDivisionSteps(numerator, denominator, maxDecimalPlaces);

    // Find where the decimal point falls in the quotient
    String quotientStr = decimalQuotient;
    if (!quotientStr.contains('.') && steps.any((s) => s.isDecimal)) {
      quotientStr += '.';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quotient above the bar
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 40),
                Text(
                  quotientStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bracket and division
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$denominator'),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 0),
                          child: CustomPaint(
                            painter: _LongDivisionBracketPainter(
                                width: 80, height: (steps.length + 1) * 28),
                            child: SizedBox(
                              width: 80,
                              height: (steps.length + 1) * 28,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...steps.map((s) {
                                      if (s.isSeparator) {
                                        return const Divider(
                                            color: Colors.black,
                                            thickness: 1,
                                            height: 8);
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: Text(
                                          s.isDividend
                                              ? _formatNum(s.value, s.isDecimal)
                                              : '-${_formatNum(s.value, s.isDecimal)}',
                                          style: TextStyle(
                                            fontWeight: s.isDividend
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: s.isDividend
                                                ? Colors.black
                                                : Colors.blue,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNum(double val, bool isDecimal) {
    if (val == val.roundToDouble()) {
      return isDecimal ? val.toStringAsFixed(1) : '${val.toInt()}';
    }
    // For recurring decimals, show up to 8 decimal places, but trim trailing zeros
    return val.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _DivisionVisualStep {
  final double value;
  final bool isDividend;
  final bool isSeparator;
  final bool isDecimal;
  _DivisionVisualStep({
    this.value = 0.0,
    this.isDividend = false,
    this.isSeparator = false,
    this.isDecimal = false,
  });
}

class _LongDivisionBracketPainter extends CustomPainter {
  final double width;
  final double height;
  _LongDivisionBracketPainter({this.width = 80, this.height = 120});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    // Left vertical
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, height - 10),
      paint,
    );
    // Top horizontal
    canvas.drawLine(
      const Offset(0, 0),
      Offset(width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}