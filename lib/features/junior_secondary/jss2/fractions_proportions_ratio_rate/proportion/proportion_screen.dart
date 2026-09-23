import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'proportion_logic.dart';
import 'proportion_models.dart';

class ProportionScreen extends StatefulWidget {
  const ProportionScreen({super.key});

  @override
  State<ProportionScreen> createState() => _ProportionScreenState();
}

class _ProportionScreenState extends State<ProportionScreen> {
  int _inputMode = 0; // 0 for AI Translator, 1 for Manual Builder

  // AI Controllers
  final TextEditingController _wordProblemController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Builder Controllers
  bool _isDirectProportion = true;
  final TextEditingController _givenQtyController = TextEditingController();
  final TextEditingController _givenUnitController = TextEditingController();
  final TextEditingController _givenTgtController = TextEditingController();
  final TextEditingController _targetUnitController = TextEditingController();
  final TextEditingController _newQtyController = TextEditingController();

  ProportionResult? _result;

  @override
  void dispose() {
    _wordProblemController.dispose();
    _givenQtyController.dispose();
    _givenUnitController.dispose();
    _givenTgtController.dispose();
    _targetUnitController.dispose();
    _newQtyController.dispose();
    super.dispose();
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    if (_givenQtyController.text.trim().isEmpty || _givenTgtController.text.trim().isEmpty || _newQtyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all numeric fields.')));
      return;
    }
    setState(() {
      _result = ProportionLogic.solve(
        givenQuantityStr: _givenQtyController.text,
        givenUnit: _givenUnitController.text.isEmpty ? "units" : _givenUnitController.text,
        givenTargetStr: _givenTgtController.text,
        targetUnit: _targetUnitController.text.isEmpty ? "units" : _targetUnitController.text,
        newQuantityStr: _newQtyController.text,
        isDirect: _isDirectProportion,
      );
    });
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _wordProblemController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem first.')));
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null;
    });

    try {
      // Using the user's valid working AQ. auth key
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);

      // Strict Prompt Engineering: Force AI to output a pure JSON object
      final prompt = '''
      You are a strict math data extractor for JSS2 students. 
      Read the word problem and extract the unitary method variables.
      
      Word problem: "$inputText"
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no backticks, no explanations.
      2. Decide if it is Direct Proportion (isDirect: true) or Inverse Proportion (isDirect: false).
         - Direct: More items cost more money. More time means more distance.
         - Inverse: More workers take less time. Faster speed takes less time.
      3. The "givenQuantity" and "givenTarget" must be strictly numbers (e.g. 7, 10).
      4. Extraneous information (like planting "1200 trees" or a wall being "5m long" when asking for time) should be ignored. Just extract the varying elements.
      
      JSON FORMAT:
      {
        "givenQuantity": "number as string",
        "givenUnit": "string (e.g., workers, hours)",
        "givenTarget": "number as string",
        "targetUnit": "string (e.g., days, Naira)",
        "newQuantity": "number or variable as string (e.g., 5 or x)",
        "isDirect": boolean
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String rawOutput = response.text?.trim() ?? '';
      // Clean up any markdown blocks just in case
      if (rawOutput.startsWith('```json')) rawOutput = rawOutput.substring(7);
      if (rawOutput.startsWith('```')) rawOutput = rawOutput.substring(3);
      if (rawOutput.endsWith('```')) rawOutput = rawOutput.substring(0, rawOutput.length - 3);
      rawOutput = rawOutput.trim();

      if (rawOutput.isEmpty) throw Exception("AI failed to extract data.");

      final parsedJson = json.decode(rawOutput);

      // Automatically sync the manual inputs with what the AI deduced to teach the student!
      _givenQtyController.text = parsedJson['givenQuantity'].toString();
      _givenUnitController.text = parsedJson['givenUnit'].toString();
      _givenTgtController.text = parsedJson['givenTarget'].toString();
      _targetUnitController.text = parsedJson['targetUnit'].toString();
      _newQtyController.text = parsedJson['newQuantity'].toString();
      _isDirectProportion = parsedJson['isDirect'] as bool;

      setState(() {
        _result = ProportionLogic.solve(
          givenQuantityStr: _givenQtyController.text,
          givenUnit: _givenUnitController.text,
          givenTargetStr: _givenTgtController.text,
          targetUnit: _targetUnitController.text,
          newQuantityStr: _newQtyController.text,
          isDirect: _isDirectProportion,
        );
      });

    } catch (e) {
      print("Gemini AI Error: $e");
      String errorMsg = 'AI Translator failed. Try entering the values manually.';
      if (e.toString().contains('API key not valid') || e.toString().contains('authentication')) {
        errorMsg = 'AI Error: Invalid API Key or Auth Token.';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'AI Error: No internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() {
        _isLoadingAI = false;
        // Switch to manual mode so they can see how it was parsed!
        _inputMode = 1;
      });
    }
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
            onValueChanged: (int? value) {
              if (value != null) setState(() => _inputMode = value);
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
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
                Expanded(child: Text("Paste your word problem below. The AI will instantly map out the variables and identify the proportion type!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wordProblemController,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Word Problem",
              hintText: "e.g. Seven workers dig a piece of ground in 10 days. How long would 5 workers take?",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI)
            const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else
            ElevatedButton.icon(
              onPressed: _solveWithAI,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text("Translate & Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.balance, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(child: Text("Select the Proportion Type:", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _isDirectProportion,
                    children: const {
                      true: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Direct (+ gives +)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      false: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Inverse (+ gives -)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    },
                    onValueChanged: (bool? value) {
                      if (value != null) setState(() => _isDirectProportion = value);
                    },
                    thumbColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isDirectProportion
                      ? "Direct: If you buy more apples, they cost more money."
                      : "Inverse: If more workers dig a hole, it takes less time.",
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text("The Given Facts:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("If  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(flex: 2, child: _buildSmallField(_givenQtyController, "e.g. 7")),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: _buildSmallField(_givenUnitController, "workers")),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("gives", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: _buildSmallField(_givenTgtController, "10")),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: _buildSmallField(_targetUnitController, "days")),
            ],
          ),

          const SizedBox(height: 16),
          const Text("The Target:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Then  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(flex: 2, child: _buildSmallField(_newQtyController, "e.g. 5")),
              const SizedBox(width: 8),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Text(_givenUnitController.text.isEmpty ? "..." : _givenUnitController.text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  )
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("will give", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade300)),
                    child: Text("? ${_targetUnitController.text}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  )
              ),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: const Text("Apply Unitary Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      onChanged: (_) => setState((){}), // Trigger rebuild to update mirrored text
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                    _result!.finalAnswerLaTeX,
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
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          _result!.workingsLaTeX[i],
                          textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple)
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
        ..._result!.steps.asMap().entries.map((e) => Card(
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
      appBar: AppBar(title: const Text('Proportion (Unitary Method)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(theme),
          ],
        ),
      ),
    );
  }
}