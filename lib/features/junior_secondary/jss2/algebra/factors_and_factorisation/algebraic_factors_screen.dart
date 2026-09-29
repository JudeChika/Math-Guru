import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'algebraic_factors_logic.dart';
import 'algebraic_factors_models.dart';

class AlgebraicFactorsScreen extends StatefulWidget {
  const AlgebraicFactorsScreen({super.key});

  @override
  State<AlgebraicFactorsScreen> createState() => _AlgebraicFactorsScreenState();
}

class _AlgebraicFactorsScreenState extends State<AlgebraicFactorsScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: Factors, 1: HCF, 2: LCM

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Controllers
  final TextEditingController _singleTermCtrl = TextEditingController();
  final List<TextEditingController> _multiTermCtrls = [TextEditingController(), TextEditingController()];

  FactorsResult? _result;

  @override
  void dispose() {
    _aiController.dispose();
    _singleTermCtrl.dispose();
    for (var c in _multiTermCtrls) { c.dispose(); }
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
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final prompt = '''
      Extract data from the math problem for Algebraic Factors and Multiples.
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no conversational text.
      2. "topic" must be exactly "factors", "hcf", or "lcm".
      3. For "factors", extract the single term into "singleTerm".
      4. For "hcf" or "lcm", extract all the terms to compare into the "terms" array.
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "topic": "hcf",
         "singleTerm": "",
         "terms": ["12ab^2", "30a^2b"]
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';

      // Safety net: Strip out any markdown code blocks
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        String t = jsonMap['topic'] ?? 'factors';
        if (t == 'factors') {
          _topicMode = 0;
          _singleTermCtrl.text = jsonMap['singleTerm']?.toString() ?? '';
        } else if (t == 'hcf') {
          _topicMode = 1;
          _populateMultiTerms(jsonMap['terms']);
        } else if (t == 'lcm') {
          _topicMode = 2;
          _populateMultiTerms(jsonMap['terms']);
        }
        _inputMode = 1; // Switch to Manual view
      });
      _solveManual();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Translation failed. Please enter the values manually.")));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _populateMultiTerms(dynamic termsData) {
    if (termsData is List && termsData.isNotEmpty) {
      _multiTermCtrls.clear();
      for (var t in termsData) {
        _multiTermCtrls.add(TextEditingController(text: t.toString()));
      }
      // Ensure at least 2 boxes exist
      while (_multiTermCtrls.length < 2) {
        _multiTermCtrls.add(TextEditingController());
      }
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = AlgebraicFactorsLogic.solveAllFactors(_singleTermCtrl.text);
      } else if (_topicMode == 1) {
        _result = AlgebraicFactorsLogic.solveHCF(_multiTermCtrls.map((c) => c.text).toList());
      } else {
        _result = AlgebraicFactorsLogic.solveLCM(_multiTermCtrls.map((c) => c.text).toList());
      }
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
                Expanded(child: Text("Paste a problem asking for Factors, HCF, or LCM. The AI will extract the algebraic terms automatically!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. Find the LCM of 10m^2 and 15m^2h", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("All Factors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Find HCF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Find LCM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            TextField(
              controller: _singleTermCtrl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(labelText: "Algebraic Term", hintText: "e.g. 5a^2x", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ] else ...[
            const Text("Algebraic Terms to Compare:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: List.generate(_multiTermCtrls.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _multiTermCtrls[index], textAlign: TextAlign.center,
                            decoration: InputDecoration(hintText: "Term ${index + 1} (e.g. 12ab^2)", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ),
                        if (_multiTermCtrls.length > 2)
                          IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() { _multiTermCtrls[index].dispose(); _multiTermCtrls.removeAt(index); }))
                      ],
                    ),
                  );
                }),
              ),
            ),
            TextButton.icon(onPressed: () => setState(() => _multiTermCtrls.add(TextEditingController())), icon: const Icon(Icons.add, size: 18), label: const Text("Add Another Term"))
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.bolt, color: Colors.white), label: const Text("Calculate & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _result!.finalAnswers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${entry.key}:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(entry.value, textStyle: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.green))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50, elevation: 0.5, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  if (_result!.workingsLaTeX[i].isEmpty) const SizedBox(height: 16)
                  else Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(_result!.workingsLaTeX[i], textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple))),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algebraic Factors & Multiples')),
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