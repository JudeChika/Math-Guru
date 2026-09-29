import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'factorisation_logic.dart';
import 'factorisation_models.dart';

class FactorisationScreen extends StatefulWidget {
  const FactorisationScreen({super.key});

  @override
  State<FactorisationScreen> createState() => _FactorisationScreenState();
}

class _FactorisationScreenState extends State<FactorisationScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: Factorise, 1: Complete Bracket

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Controllers
  final TextEditingController _exprCtrl = TextEditingController();
  final TextEditingController _fullCtrl = TextEditingController();
  final TextEditingController _outCtrl = TextEditingController();
  final TextEditingController _inCtrl = TextEditingController();

  FactorisationResult? _result;

  @override
  void dispose() {
    _aiController.dispose();
    _exprCtrl.dispose();
    _fullCtrl.dispose();
    _outCtrl.dispose();
    _inCtrl.dispose();
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
      Extract data from the math problem for Factorisation of Binomials.
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no conversational text.
      2. "topic" must be "factorise" or "complete_bracket".
      3. For "factorise", extract the expression into "expression".
      4. For "complete_bracket", extract the full expression, outside factor, and inside bracket. Use empty strings for missing/blank parts.
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "topic": "complete_bracket",
         "expression": "",
         "full": "15ax + 10a",
         "outside": "5a",
         "inside": ""
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        String t = jsonMap['topic'] ?? 'factorise';
        if (t == 'factorise') {
          _topicMode = 0;
          _exprCtrl.text = jsonMap['expression']?.toString() ?? '';
        } else {
          _topicMode = 1;
          _fullCtrl.text = jsonMap['full']?.toString() ?? '';
          _outCtrl.text = jsonMap['outside']?.toString() ?? '';
          _inCtrl.text = jsonMap['inside']?.toString() ?? '';
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

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = FactorisationLogic.solveFactorise(_exprCtrl.text);
      } else {
        _result = FactorisationLogic.solveCompleteBracket(_fullCtrl.text, _outCtrl.text, _inCtrl.text);
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
                Expanded(child: Text("Paste a problem asking to factorise or complete the brackets. The AI will extract the expressions automatically!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. Factorise 4n^2 - 2n", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Factorise Expression", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Complete the Bracket", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            TextField(
              controller: _exprCtrl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(labelText: "Expression", hintText: "e.g. 12y + 8z", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  const Text("Leave exactly ONE field blank:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 16),
                  TextField(controller: _fullCtrl, textAlign: TextAlign.center, decoration: InputDecoration(labelText: "Full Expression", hintText: "e.g. 15ax + 10a", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("=", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _outCtrl, textAlign: TextAlign.center, decoration: InputDecoration(labelText: "Outside Factor", hintText: "5a", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("(", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                      Expanded(child: TextField(controller: _inCtrl, textAlign: TextAlign.center, decoration: InputDecoration(labelText: "Inside Bracket", hintText: "?", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(")", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.bolt, color: Colors.white), label: const Text("Factorise & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(entry.value, textStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green))),
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
      appBar: AppBar(title: const Text('Factorisation of Binomials')),
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