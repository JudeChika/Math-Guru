import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'estimation_logic.dart';
import 'estimation_models.dart';

class EstimationScreen extends StatefulWidget {
  const EstimationScreen({super.key});

  @override
  State<EstimationScreen> createState() => _EstimationScreenState();
}

class _EstimationScreenState extends State<EstimationScreen> {
  final TextEditingController _exprController = TextEditingController();
  int _selectedMethod = 0; // 0 for Method 1, 1 for Method 2
  EstimationResult? _result;
  bool _isLoadingAI = false;

  @override
  void dispose() {
    _exprController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final currentText = _exprController.text;
    final selection = _exprController.selection;

    if (selection.start >= 0) {
      final newText = currentText.replaceRange(selection.start, selection.end, text);
      _exprController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _exprController.text += text;
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_exprController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a calculation.')));
      return;
    }
    setState(() {
      _result = EstimationLogic.solve(_exprController.text);
    });
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _exprController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem first.')));
      return;
    }

    // Check if it already looks like pure math (no letters), then just solve normally
    if (!RegExp(r'[a-zA-Z]').hasMatch(inputText)) {
      _solve();
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null; // Clear previous results while loading
    });

    try {
      // Using your working valid key
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';

      // Updated to Google's active model for 2026!
      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);

      // Strict Prompt Engineering: Force the AI to output ONLY math, so our Dart parser doesn't crash.
      final prompt = '''
      You are a math translator. The user will give you a math word problem. 
      Your job is to extract the exact mathematical calculation needed to solve it.
      
      RULES:
      1. Respond ONLY with the mathematical expression.
      2. Use ONLY numbers and operators (+, -, *, /, (), ^).
      3. DO NOT include the final answer.
      4. DO NOT include units, words, or explanations.
      
      Word problem: $inputText
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final extractedMath = response.text?.trim() ?? '';

      if (extractedMath.isEmpty) {
        throw Exception("AI failed to extract math.");
      }

      // Update the text field so the student sees how their words were translated!
      _exprController.text = extractedMath;

      // Pass the AI's math expression into our existing flawless logic engine
      setState(() {
        _result = EstimationLogic.solve(extractedMath);
      });

    } catch (e) {
      // Print the exact error to the debug console so you can see what went wrong
      print("Gemini AI Error: $e");

      String errorMsg = 'AI Translation failed: Try entering the math manually.';
      if (e.toString().contains('API key not valid')) {
        errorMsg = 'AI Error: Invalid API Key. Please check your Gemini API key.';
      } else if (e.toString().contains('is not found')) {
        errorMsg = 'AI Error: Model not found. Please update the model string.';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'AI Error: No internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  void _showTranslationGuide(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Word Problem Translator", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text("Don't know how to turn the English words into Math? Look for these keywords!", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildGuideCard(Icons.add_circle, Colors.green, "Addition (+)", ["Sum", "Total", "Altogether", "More than", "Increased by"]),
                    _buildGuideCard(Icons.remove_circle, Colors.red, "Subtraction (-)", ["Difference", "Left over", "Remaining", "Fewer than", "Decreased by"]),
                    _buildGuideCard(Icons.cancel, Colors.blue, "Multiplication (×)", ["Times", "Product", "Each", "Per", "Twice", "Of"]),
                    _buildGuideCard(Icons.safety_divider, Colors.orange, "Division (÷)", ["Share", "Split", "Average", "Out of", "Quotient"]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Got it!", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
    );
  }

  Widget _buildGuideCard(IconData icon, Color color, String title, List<String> words) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: words.map((w) => Chip(
                label: Text(w, style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white,
                side: BorderSide(color: color.withOpacity(0.2)),
              )).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMathBtn(String text, String tooltip) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      tooltip: tooltip,
      backgroundColor: Colors.grey.shade200,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () => _insertText(text),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Error",
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isMethod1 = _selectedMethod == 0;
    final finalAnswerLaTeX = isMethod1 ? _result!.m1FinalAnswerLaTeX : _result!.m2FinalAnswerLaTeX;
    final workingsLaTeX = isMethod1 ? _result!.m1WorkingsLaTeX : _result!.m2WorkingsLaTeX;
    final steps = isMethod1 ? _result!.m1Steps : _result!.m2Steps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),

        // Method Switcher
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedMethod,
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Method 1 (Round First)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Method 2 (Calculate First)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            },
            onValueChanged: (int? value) {
              if (value != null) setState(() => _selectedMethod = value);
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),

        const SizedBox(height: 24),
        const Text("Final Estimated Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Math.tex(
                    finalAnswerLaTeX,
                    textStyle: const TextStyle(fontSize: 42, color: Colors.green, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                for (int i = 0; i < workingsLaTeX.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          (i == 0 || workingsLaTeX[i].contains('\\frac') && i == 1)
                              ? workingsLaTeX[i]
                              : "= ${workingsLaTeX[i]}",
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estimation (Word Problems)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 12),
                      Expanded(child: Text("Turn complex word problems into simple math!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("Enter your calculation below. We'll show you two different ways to estimate the final answer.", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // The Translation Gap Bridge Button
            TextButton.icon(
              onPressed: () => _showTranslationGuide(context),
              icon: const Icon(Icons.help_outline, color: Colors.deepPurple),
              label: const Text("🤔 How do I turn my word problem into math?", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 14)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.deepPurple.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _exprController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Word Problem OR Calculation",
                hintText: "e.g. A shop buys 1440 pencils at 55 each...",
                prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _solve(),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildMathBtn('+', 'Add'),
                _buildMathBtn('-', 'Subtract / Negative'),
                _buildMathBtn('*', 'Multiply'),
                _buildMathBtn('/', 'Divide / Fraction'),
                _buildMathBtn('(', 'Open Bracket'),
                _buildMathBtn(')', 'Close Bracket'),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoadingAI)
              const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _solveWithAI,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text("✨ Translate & Estimate with AI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _solve,
                    icon: const Icon(Icons.bolt, color: Colors.deepPurple),
                    label: const Text("Manual Estimate (Math Only)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.deepPurple, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

            _buildResultView(theme),
          ],
        ),
      ),
    );
  }
}