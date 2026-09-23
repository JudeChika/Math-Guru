import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'fractions_percentages_logic.dart';
import 'fractions_percentages_models.dart';

class FractionsPercentagesScreen extends StatefulWidget {
  const FractionsPercentagesScreen({super.key});

  @override
  State<FractionsPercentagesScreen> createState() => _FractionsPercentagesScreenState();
}

class _FractionsPercentagesScreenState extends State<FractionsPercentagesScreen> {
  final TextEditingController _inputController = TextEditingController();
  FractionsPercentagesResult? _result;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value.')));
      return;
    }
    setState(() {
      _result = FractionsPercentagesLogic.solve(_inputController.text);
    });
  }

  Widget _buildConversionPath(ConversionPath path, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Conversion to ${path.targetFormat}:",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.green.shade200)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  path.finalAnswerLaTeX,
                  textStyle: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text("Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < path.workingsLaTeX.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          path.workingsLaTeX[i],
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Text("Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
        const SizedBox(height: 8),
        ...path.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                      e.value.mathLaTeX,
                      textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),
        )),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fractions & Percentages')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Enter a Decimal, Fraction, or Percentage. We will automatically convert it into the other two formats!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Value to Convert",
                hintText: "e.g. 0.85, 4/5, 2 1/2, or 92%",
                prefixIcon: const Icon(Icons.transform, color: Colors.deepPurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _solve(),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Convert & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Original Input: ", style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold)),
                  Math.tex(_result!.originalInputLaTeX, textStyle: const TextStyle(fontSize: 22, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  Text(" (${_result!.inputType})", style: const TextStyle(fontSize: 14, color: Colors.black45)),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 24),

              ..._result!.conversions.map((path) => _buildConversionPath(path, theme)).toList(),
            ]
          ],
        ),
      ),
    );
  }
}