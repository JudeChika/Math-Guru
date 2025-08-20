import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'binary_multiplication_logic.dart';
import 'binary_multiplication_models.dart';

class BinaryMultiplicationScreen extends StatefulWidget {
  const BinaryMultiplicationScreen({super.key});

  @override
  State<BinaryMultiplicationScreen> createState() => _BinaryMultiplicationScreenState();
}

class _BinaryMultiplicationScreenState extends State<BinaryMultiplicationScreen> {
  final TextEditingController _multiplicandController = TextEditingController();
  final TextEditingController _multiplierController = TextEditingController();
  BinaryMultiplicationResult? _result;

  void _performMultiplication() {
    setState(() {
      _result = BinaryMultiplicationLogic.multiplyBinaryNumbers(
        _multiplicandController.text,
        _multiplierController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Multiplication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter binary numbers to multiply:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Input fields
            TextField(
              controller: _multiplicandController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Multiplicand (First Number)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 1101",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performMultiplication(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _multiplierController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Multiplier (Second Number)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 1010",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performMultiplication(),
            ),
            const SizedBox(height: 16),

            // Multiply button
            Center(
              child: ElevatedButton(
                onPressed: _performMultiplication,
                child: const Text("Multiply", style: TextStyle(fontFamily: 'Poppins')),
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
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "${_result!.multiplicand}_2 \\times ${_result!.multiplier}_2 = ${_result!.binaryProduct}_2",
                            textStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "= ${_result!.decimalProduct}_{10}",
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

  Widget _buildResultCard(BinaryMultiplicationResult result, ThemeData theme) {
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
              "Binary Numbers: ${result.multiplicand} × ${result.multiplier}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            // Legend for binary multiplication rules
            _buildLegendCard(theme),
            const SizedBox(height: 12),

            // Working display as table
            Text(
              "Working:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            _buildWorkingTable(result, theme),

            const SizedBox(height: 12),

            // Step-by-step explanation
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
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
              "Binary Multiplication Rules",
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
                Math.tex("0 \\times 0 = 0"),
                const SizedBox(height: 8),
                Math.tex("0 \\times 1 = 0"),
                const SizedBox(height: 8),
                Math.tex("1 \\times 0 = 0"),
                const SizedBox(height: 8),
                Math.tex("1 \\times 1 = 1"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingTable(BinaryMultiplicationResult result, ThemeData theme) {
    // Find max length for padding - only for alignment purposes
    List<String> allNumbers = [
      result.multiplicand,
      result.multiplier,
      result.binaryProduct,
      ...result.partialProducts
    ];
    int maxLength = allNumbers.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    List<DataRow> rows = [];

    // Multiplicand row (Multiplication section - Blue tint)
    rows.add(DataRow(
      color: WidgetStateProperty.all(Colors.blue.shade50),
      cells: [
        DataCell(
          SizedBox(
            width: 30,
            child: Center(
              child: Math.tex(
                "",
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
        // Multiplicand digits - right aligned, no padding with zeros
        ...List.generate(maxLength, (index) {
          int digitIndex = maxLength - 1 - index;
          int multiplicandIndex = result.multiplicand.length - 1 - (maxLength - 1 - index);
          String digit = (multiplicandIndex >= 0 && multiplicandIndex < result.multiplicand.length)
              ? result.multiplicand[multiplicandIndex]
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
        // Multiplicand notation
        DataCell(
          SizedBox(
            width: 80,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                "(${result.multiplicand})_2",
                textStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    ));

    // Multiplier row (Multiplication section - Blue tint)
    rows.add(DataRow(
      color: WidgetStateProperty.all(Colors.blue.shade50),
      cells: [
        DataCell(
          SizedBox(
            width: 30,
            child: Center(
              child: Math.tex(
                "\\times",
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
        // Multiplier digits - right aligned, no padding with zeros
        ...List.generate(maxLength, (index) {
          int multiplierIndex = result.multiplier.length - 1 - (maxLength - 1 - index);
          String digit = (multiplierIndex >= 0 && multiplierIndex < result.multiplier.length)
              ? result.multiplier[multiplierIndex]
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
        // Multiplier notation
        DataCell(
          SizedBox(
            width: 80,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                "(${result.multiplier})_2",
                textStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    ));

    // Partial products rows (Addition section - Orange tint)
    for (int i = 0; i < result.partialProducts.length; i++) {
      String partialProduct = result.partialProducts[i];

      // Determine operator for this row
      String operator = "";
      if (i == 0) {
        operator = ""; // First partial product has no operator
      } else if (i == result.partialProducts.length - 1) {
        operator = "+"; // Last partial product gets the + sign
      } else {
        operator = ""; // Middle partial products have no operator
      }

      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.purple.shade50),
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: Center(
                child: Math.tex(
                  operator,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          // Partial product digits - right aligned, show actual digits including zeros from multiplication
          ...List.generate(maxLength, (index) {
            int partialIndex = partialProduct.length - 1 - (maxLength - 1 - index);
            String digit = (partialIndex >= 0 && partialIndex < partialProduct.length)
                ? partialProduct[partialIndex]
                : "";

            return DataCell(
              SizedBox(
                width: 40,
                child: Center(
                  child: digit.isEmpty ? const SizedBox() : Math.tex(
                    digit,
                    textStyle: const TextStyle(fontSize: 14, color: Colors.deepPurpleAccent),
                  ),
                ),
              ),
            );
          }),
          // Partial product notation
          DataCell(
            SizedBox(
              width: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "($partialProduct)_2",
                  textStyle: const TextStyle(fontSize: 10, color: Colors.deepPurpleAccent),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    // Result row (Result section - Purple tint)
    rows.add(DataRow(
      color: WidgetStateProperty.all(Colors.deepPurple.shade100),
      cells: [
        // Equals sign
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
        // Result digits - right aligned, no padding with zeros
        ...List.generate(maxLength, (index) {
          int resultIndex = result.binaryProduct.length - 1 - (maxLength - 1 - index);
          String digit = (resultIndex >= 0 && resultIndex < result.binaryProduct.length)
              ? result.binaryProduct[resultIndex]
              : "";

          return DataCell(
            SizedBox(
              width: 40,
              child: Center(
                child: digit.isEmpty ? const SizedBox() : Math.tex(
                  digit,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }),
        // Result notation
        DataCell(
          SizedBox(
            width: 80,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                "= (${result.binaryProduct})_2",
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    ));

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
              width: 80,
              child: Text(
                "Notation",
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
    _multiplicandController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }
}