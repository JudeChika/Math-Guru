import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'word_problems_logic.dart';
import 'word_problems_models.dart';

class WordProblemsScreen extends StatefulWidget {
  const WordProblemsScreen({super.key});

  @override
  State<WordProblemsScreen> createState() => _WordProblemsScreenState();
}

class _WordProblemsScreenState extends State<WordProblemsScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Controllers
  final TextEditingController _variableCtrl = TextEditingController(text: "x");
  final TextEditingController _declarationCtrl = TextEditingController(text: "Let the number be x.");
  final TextEditingController _equationCtrl = TextEditingController();
  final TextEditingController _conclusionCtrl = TextEditingController(text: "The number is {answer}.");

  WordProblemResult? _result;

  @override
  void dispose() {
    _aiController.dispose();
    _variableCtrl.dispose();
    _declarationCtrl.dispose();
    _equationCtrl.dispose();
    _conclusionCtrl.dispose();
    super.dispose();
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _aiController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem.')));
      return;
    }

    setState(() { _isLoadingAI = true; _result = null; });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);

      final prompt = '''
      You are a strict math data extractor for JSS2 Word Problems involving equations.
      Extract the translation from English to Algebra.
      
      RULES:
      1. Return ONLY valid JSON. No markdown, no conversational text.
      2. "variable" is the single letter chosen (e.g., "x", "b", "n").
      3. "declaration" is Step 1 (e.g., "Let the number be n.").
      4. "breakdown" is an array of strings showing Step 2 translation (e.g., ["I multiply n by 5: 5n", "I add 15: 5n + 15"]).
      5. "equation" is Step 3, the final algebraic equation to be solved (e.g., "5n + 15 = 100").
      6. "conclusion_template" is Step 5, how to state the final answer. Use "{answer}" as the placeholder (e.g., "The number is {answer}.", "The breadth of the rectangle is {answer} m.").
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
        "variable": "n",
        "declaration": "Let the number be n.",
        "breakdown": ["I multiply n by 5: 5n", "I add 15: 5n + 15"],
        "equation": "5n + 15 = 100",
        "conclusion_template": "The number is {answer}."
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';

      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();
      final jsonMap = json.decode(rawOutput);

      // Create translation object
      WordProblemTranslation translation = WordProblemTranslation(
        variable: jsonMap['variable']?.toString() ?? 'x',
        declaration: jsonMap['declaration']?.toString() ?? 'Let the unknown be x.',
        breakdown: (jsonMap['breakdown'] as List?)?.map((e) => e.toString()).toList() ?? [],
        equation: jsonMap['equation']?.toString() ?? '',
        conclusionTemplate: jsonMap['conclusion_template']?.toString() ?? 'The answer is {answer}.',
      );

      // Automatically sync manual fields to show students the mapped translation
      _variableCtrl.text = translation.variable;
      _declarationCtrl.text = translation.declaration;
      _equationCtrl.text = translation.equation;
      _conclusionCtrl.text = translation.conclusionTemplate;

      setState(() {
        _result = WordProblemsLogic.solve(translation);
        _inputMode = 1; // Switch to Manual view to show the translation
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Translation failed. Please enter the equation manually.")));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    if (_equationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an equation.')));
      return;
    }

    WordProblemTranslation manualTrans = WordProblemTranslation(
      variable: _variableCtrl.text.trim().isEmpty ? "x" : _variableCtrl.text.trim(),
      declaration: _declarationCtrl.text.trim().isEmpty ? "Let the unknown be ${_variableCtrl.text}." : _declarationCtrl.text.trim(),
      breakdown: ["Translated to algebra: ${_equationCtrl.text}"],
      equation: _equationCtrl.text.trim(),
      conclusionTemplate: _conclusionCtrl.text.trim().isEmpty ? "The answer is {answer}." : _conclusionCtrl.text.trim(),
    );

    setState(() {
      _result = WordProblemsLogic.solve(manualTrans);
    });
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("✨ AI Word Problem", style: TextStyle(fontWeight: FontWeight.bold))),
              1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("🛠️ Manual Builder", style: TextStyle(fontWeight: FontWeight.bold))),
            },
            onValueChanged: (int? value) { if (value != null) setState(() => _inputMode = value); },
            thumbColor: Colors.deepPurple.shade100, backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),

        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text("Paste any word problem. The AI will translate the English into an Algebraic Equation automatically!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. I think of a number. I multiply it by 5. I add 15. The result is 100...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
            child: const Row(
              children: [
                Icon(Icons.translate, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(child: Text("Manually build the translation. Choose a letter, write the equation, and set the conclusion template.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _variableCtrl, textAlign: TextAlign.center,
                  decoration: InputDecoration(labelText: "Letter", hintText: "e.g. n", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: TextField(
                  controller: _declarationCtrl,
                  decoration: InputDecoration(labelText: "Declaration", hintText: "e.g. Let the number be n", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _equationCtrl, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(labelText: "Mathematical Equation", hintText: "e.g. 5n + 15 = 100", isDense: true, filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conclusionCtrl,
            decoration: InputDecoration(labelText: "Conclusion Template", hintText: "e.g. The number is {answer}.", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.bolt, color: Colors.white), label: const Text("Solve Equation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    final translation = _result!.translation;
    int checkIndex = _result!.workingsLaTeX.indexWhere((w) => w.contains("Check:"));
    List<String> mainWorkings = checkIndex != -1 ? _result!.workingsLaTeX.sublist(0, checkIndex > 0 ? checkIndex - 1 : 0) : _result!.workingsLaTeX;
    List<String> checkWorkings = checkIndex != -1 ? _result!.workingsLaTeX.sublist(checkIndex) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("1. From Words to Algebra:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue.shade50, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepRow("Step 1", "Choose a letter for the unknown.", translation.declaration),
                const Divider(height: 24, color: Colors.black12),
                _buildStepRow("Step 2", "Write down the information algebraically.", translation.breakdown.join('\n')),
                const Divider(height: 24, color: Colors.black12),
                _buildStepRow("Step 3", "Make an equation.", translation.equation, isMath: true),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("2. Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
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
                for (int i = 0; i < mainWorkings.length; i++)
                  if (mainWorkings[i].isEmpty)
                    const SizedBox(height: 12)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                            i == 0 || mainWorkings[i].contains('\\text{') || mainWorkings[i].contains('=')
                                ? mainWorkings[i]
                                : "\\Rightarrow ${mainWorkings[i]}",
                            textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("3. Final Conclusion & Check:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Card(
          color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepRow("Step 5", "Give the answer in written form.", translation.conclusionTemplate.replaceAll('{answer}', _result!.finalAnswerPlain)),
                const Divider(height: 24, color: Colors.black12),
                _buildStepRow("Step 6", "Check the result.", ""),
                Card(
                  color: Colors.white, elevation: 0, margin: const EdgeInsets.only(top: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.green.shade100)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < checkWorkings.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(checkWorkings[i], textStyle: const TextStyle(fontSize: 16, color: Colors.deepPurple))),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("4. Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        ..._result!.solvingSteps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, foregroundColor: Colors.deepPurple, child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)))
                ]
              ],
            ),
          ),
        )),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepRow(String stepName, String description, String content, {bool isMath = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stepName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        if (content.isNotEmpty)
          isMath
              ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(content, textStyle: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold)))
              : Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Problems')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(Theme.of(context)),
          ],
        ),
      ),
    );
  }
}