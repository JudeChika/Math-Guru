import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'binary_division_logic.dart';
import 'binary_division_models.dart';

class LongDivisionPainter extends CustomPainter {
  final String divisor;
  final String dividend;
  final String quotient;
  final String remainder;
  final List<BinaryDivisionStep> steps;

  LongDivisionPainter({
    required this.divisor,
    required this.dividend,
    required this.quotient,
    required this.remainder,
    required this.steps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );


    // Draw the division bracket
    final bracketPath = Path();
    final startX = size.width / 2 - 60;
    const startY = 50;

    // Horizontal line above dividend
    bracketPath.moveTo(startX + 40, startY as double);
    bracketPath.lineTo(startX + 120, startY as double);

    // Vertical line for division bracket
    bracketPath.moveTo(startX + 40, startY as double);
    bracketPath.lineTo(startX + 40, startY + 20);

    canvas.drawPath(bracketPath, paint);

    // Draw divisor
    textPainter.text = TextSpan(
      text: divisor,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontFamily: 'Poppins',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX - 30, startY + 5));

    // Draw dividend
    textPainter.text = TextSpan(
      text: dividend,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontFamily: 'Poppins',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX + 50, startY + 5));

    // Draw working steps
    double currentY = startY + 40;
    for (var step in steps.where((s) => s.quotientBit == "1")) {
      // Draw step dividend
      textPainter.text = TextSpan(
        text: step.dividend,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + 60, currentY));

      // Draw minus and divisor
      textPainter.text = TextSpan(
        text: "-${step.divisor}",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.blue,
          fontFamily: 'Poppins',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + 50, currentY + 20));

      // Draw line
      canvas.drawLine(
        Offset(startX + 45, currentY + 35),
        Offset(startX + 110, currentY + 35),
        paint..strokeWidth = 1,
      );

      // Draw remainder
      textPainter.text = TextSpan(
        text: step.remainder,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + 60, currentY + 40));

      currentY += 70;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum DivisionMethod { longDivision, repeatedSubtraction }

class BinaryDivisionScreen extends StatefulWidget {
  const BinaryDivisionScreen({super.key});

  @override
  State<BinaryDivisionScreen> createState() => _BinaryDivisionScreenState();
}

class _BinaryDivisionScreenState extends State<BinaryDivisionScreen> {
  final TextEditingController _dividendController = TextEditingController();
  final TextEditingController _divisorController = TextEditingController();
  BinaryDivisionResult? _result;
  DivisionMethod _selectedMethod = DivisionMethod.longDivision;

  void _performDivision() {
    setState(() {
      String method = _selectedMethod == DivisionMethod.longDivision ? "long_division" : "repeated_subtraction";
      _result = BinaryDivisionLogic.divideBinaryNumbers(
        _dividendController.text,
        _divisorController.text,
        method,
      );
    });
  }

  void _onMethodChanged(DivisionMethod method) {
    setState(() {
      _selectedMethod = method;
    });
    if (_result != null) {
      _performDivision();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Division'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter binary numbers for division:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Input fields
            TextField(
              controller: _dividendController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Dividend (Number to be divided)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 10101",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performDivision(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _divisorController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Divisor (Number to divide by)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 111",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performDivision(),
            ),
            const SizedBox(height: 20),

            // Method selection with buttons
            Text(
              "Division Method:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => _onMethodChanged(DivisionMethod.longDivision),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMethod == DivisionMethod.longDivision
                            ? const Color(0xFF6B46C1)
                            : Colors.grey.shade200,
                        foregroundColor: _selectedMethod == DivisionMethod.longDivision
                            ? Colors.white
                            : Colors.black,
                        elevation: _selectedMethod == DivisionMethod.longDivision ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Long Division",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: () => _onMethodChanged(DivisionMethod.repeatedSubtraction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMethod == DivisionMethod.repeatedSubtraction
                            ? const Color(0xFF6B46C1)
                            : Colors.grey.shade200,
                        foregroundColor: _selectedMethod == DivisionMethod.repeatedSubtraction
                            ? Colors.white
                            : Colors.black,
                        elevation: _selectedMethod == DivisionMethod.repeatedSubtraction ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Repeated Subtraction",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Convert button (styled like the image)
            Center(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B46C1), Color(0xFF6B46C1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _performDivision,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Divide",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Centralized main result display
            if (_result != null && _result!.valid)
              Center(
                child: Column(
                      children: [
                        Text(
                          "Result",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "${_result!.dividend}_2 \\div ${_result!.divisor}_2 = ${_result!.binaryQuotient}_2",
                            textStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_result!.binaryRemainder != "0")
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Math.tex(
                              "\\text{remainder } ${_result!.binaryRemainder}_2",
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "= ${_result!.decimalQuotient}_{10}${_result!.decimalRemainder != 0 ? " \\text{ remainder } ${_result!.decimalRemainder}_{10}" : ""}",
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'Poppins',
                              color: Colors.deepPurple.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
              ),

            const SizedBox(height: 18),

            // Result card
            if (_result != null)
              _buildResultCard(_result!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BinaryDivisionResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? 'Invalid input.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Binary Numbers: ${result.dividend} ÷ ${result.divisor}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            // Legend for binary division rules (only for long division)
            if (result.method == "long_division")
              _buildLegendCard(theme),
            const SizedBox(height: 20),

            // Working display
            Text(
              "Working:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),

            if (result.method == "long_division")
              _buildLongDivisionVisual(result, theme)
            else
              _buildRepeatedSubtractionTable(result, theme),

            const SizedBox(height: 20),

            // Step-by-step explanation
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            _buildStepsList(result.stepByStepLaTeX ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendCard(ThemeData theme) {
    return Card(
      color: Colors.purple.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Binary Division Rules",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Math.tex("0 \\div 1 = 0"),
                const SizedBox(height: 8),
                Math.tex("1 \\div 1 = 1"),
                const SizedBox(height: 8),
                Math.tex("0 \\div 0 = \\text{undefined}"),
                const SizedBox(height: 8),
                Math.tex("1 \\div 0 = \\text{undefined}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongDivisionVisual(BinaryDivisionResult result, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            "Long Division Visual:",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              fontFamily: 'Poppins',
            ),
          ),

          // Create the long division layout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Build the visual step by step like the image format
                  CustomPaint(
                    size: const Size(300, 0),
                    painter: LongDivisionPainter(
                      divisor: result.divisor,
                      dividend: result.dividend,
                      quotient: result.binaryQuotient,
                      remainder: result.binaryRemainder,
                      steps: result.longDivisionSteps,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Step-by-step working display in text format
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Quotient line
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            result.binaryQuotient,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                        // Division line with divisor and dividend
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${result.divisor} ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 2,
                              color: Colors.black,
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              child: Text(
                                " ${result.dividend}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Working steps
                        ...result.longDivisionSteps
                            .where((step) => step.quotientBit == "1")
                            .map((step) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              // Current dividend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      step.dividend,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Minus and divisor
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "-",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      step.divisor,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Horizontal line
                              Container(
                                width: 100,
                                height: 1,
                                color: Colors.black,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),

                              // Remainder
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      step.remainder == "0" ? "0" : step.remainder,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),

                        // Final remainder if not zero
                        if (result.binaryRemainder != "0")
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Final Remainder: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  result.binaryRemainder,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatedSubtractionTable(BinaryDivisionResult result, ThemeData theme) {
    List<DataRow> rows = [];

    // Find max length for alignment
    List<String> allNumbers = [
      result.dividend,
      result.divisor,
      ...result.subtractionSteps.map((step) => step.minuend),
      ...result.subtractionSteps.map((step) => step.difference),
    ];
    int maxLength = allNumbers.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    // Initial dividend row
    rows.add(DataRow(
      color: WidgetStateProperty.all(Colors.blue.shade50),
      cells: [
        const DataCell(
          SizedBox(
            width: 30,
            child: Center(child: Text("")),
          ),
        ),
        ...List.generate(maxLength, (index) {
          int dividendIndex = result.dividend.length - 1 - (maxLength - 1 - index);
          String digit = (dividendIndex >= 0 && dividendIndex < result.dividend.length)
              ? result.dividend[dividendIndex]
              : "";

          return DataCell(
            SizedBox(
              width: 40,
              child: Center(
                child: digit.isEmpty ? const SizedBox() : Math.tex(
                  digit,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }),
        DataCell(
          SizedBox(
            width: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                "(${result.dividend})_2",
                textStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    ));

    // Subtraction steps (removed the divider rows)
    for (int i = 0; i < result.subtractionSteps.length; i++) {
      BinarySubtractionStep step = result.subtractionSteps[i];

      // Subtrahend row
      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.orange.shade50),
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: Center(
                child: Math.tex(
                  "-",
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          ...List.generate(maxLength, (index) {
            int subtrahendIndex = step.subtrahend.length - 1 - (maxLength - 1 - index);
            String digit = (subtrahendIndex >= 0 && subtrahendIndex < step.subtrahend.length)
                ? step.subtrahend[subtrahendIndex]
                : "";

            return DataCell(
              SizedBox(
                width: 40,
                child: Center(
                  child: digit.isEmpty ? const SizedBox() : Math.tex(
                    digit,
                    textStyle: const TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
              ),
            );
          }),
          DataCell(
            SizedBox(
              width: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "(${step.subtrahend})_2",
                  textStyle: const TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ));

      // Difference row
      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.green.shade50),
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: Center(
                child: Math.tex(
                  "=",
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          ...List.generate(maxLength, (index) {
            int differenceIndex = step.difference.length - 1 - (maxLength - 1 - index);
            String digit = (differenceIndex >= 0 && differenceIndex < step.difference.length)
                ? step.difference[differenceIndex]
                : "";

            return DataCell(
              SizedBox(
                width: 40,
                child: Center(
                  child: digit.isEmpty ? const SizedBox() : Math.tex(
                    digit,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            );
          }),
          DataCell(
            SizedBox(
              width: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "Step ${step.stepNumber}",
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 8,
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        columns: [
          const DataColumn(label: SizedBox(width: 30, child: Text(""))), // Operator column
          ...List.generate(
            maxLength,
                (index) => DataColumn(
              label: SizedBox(
                width: 40,
                child: Text(
                  "Bit ${maxLength - index - 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const DataColumn(
            label: SizedBox(
              width: 100,
              child: Text(
                "Step",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: rows,
      ),
    );
  }

  Widget _buildStepsList(List<String> steps) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: Colors.deepPurple.shade50,
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text(
                '${idx + 1}',
                style: const TextStyle(
                    color: Colors.deepPurple,
                    fontFamily: 'Poppins'
                )
            ),
          ),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              steps[idx],
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dividendController.dispose();
    _divisorController.dispose();
    super.dispose();
  }
}