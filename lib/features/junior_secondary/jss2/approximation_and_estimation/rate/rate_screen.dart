import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'rate_logic.dart';
import 'rate_models.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _inputMode = 0; // 0 for AI Translator, 1 for Manual Builder

  // AI Controllers
  final TextEditingController _wordProblemController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Builder Controllers
  int _manualMode = 0; // 0: Standard Rate, 1: Reduction Rate

  // Standard Rate Controllers
  final TextEditingController _numQtyController = TextEditingController();
  final TextEditingController _numUnitController = TextEditingController();
  final TextEditingController _denQtyController = TextEditingController();
  final TextEditingController _denUnitController = TextEditingController();

  // Reduction Rate Controllers
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();

  RateResult? _result;

  @override
  void dispose() {
    _wordProblemController.dispose();
    _numQtyController.dispose();
    _numUnitController.dispose();
    _denQtyController.dispose();
    _denUnitController.dispose();
    _oldPriceController.dispose();
    _newPriceController.dispose();
    super.dispose();
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();

    setState(() {
      if (_manualMode == 0) {
        _result = RateLogic.solveStandard(
            _numQtyController.text, _numUnitController.text,
            _denQtyController.text, _denUnitController.text
        );
      } else {
        _result = RateLogic.solveReduction(
            _oldPriceController.text, _newPriceController.text
        );
      }
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
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);

      final prompt = '''
      You are a strict math data extractor for JSS2 students learning Rates.
      Read the word problem and extract the variables.
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no backticks, no explanations.
      2. If it is a price reduction/discount problem, set "type" to "reduction" and extract "oldPrice" and "newPrice" as pure numbers.
      3. If it is a speed, wage, consumption, or general rate problem, set "type" to "standard".
         - Extract the quantity to be divided as "numQty" (e.g. 160) and its unit as "numUnit" (e.g. km, ₦).
         - Extract the base quantity/time as "denQty" (e.g. 2) and its unit as "denUnit" (e.g. h, days).
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
        "type": "standard",
        "numQty": "",
        "numUnit": "",
        "denQty": "",
        "denUnit": "",
        "oldPrice": "",
        "newPrice": ""
      }
      
      Word problem: "$inputText"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String rawOutput = response.text?.trim() ?? '';

      // Clean up any markdown blocks safely using RegEx
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      if (rawOutput.isEmpty) throw Exception("AI failed to extract data.");

      final parsedJson = json.decode(rawOutput);

      setState(() {
        if (parsedJson['type'] == 'reduction') {
          _manualMode = 1;
          _oldPriceController.text = parsedJson['oldPrice']?.toString() ?? "";
          _newPriceController.text = parsedJson['newPrice']?.toString() ?? "";
        } else {
          _manualMode = 0;
          _numQtyController.text = parsedJson['numQty']?.toString() ?? "";
          _numUnitController.text = parsedJson['numUnit']?.toString() ?? "";
          _denQtyController.text = parsedJson['denQty']?.toString() ?? "";
          _denUnitController.text = parsedJson['denUnit']?.toString() ?? "";
        }

        _inputMode = 1; // Switch to manual view to show the AI's mapping!
      });

      // Automatically execute the math once populated
      _solveManual();

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
            child: Row(
              children: const [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text("Paste your word problem below. The AI will extract the quantities and automatically find the rate!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
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
              hintText: "e.g. A car goes 160 km in 2 h. What is its rate in km/h?",
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
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _manualMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Standard Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Discount / Reduction", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) {
                if (value != null) setState(() { _manualMode = value; _result = null; });
              },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_manualMode == 0) ...[
            const Text("Given Facts:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("For  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(flex: 2, child: _buildSmallField(_denQtyController, "e.g. 2")),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: _buildSmallField(_denUnitController, "hours (h)")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("The value is  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(flex: 2, child: _buildSmallField(_numQtyController, "e.g. 160")),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: _buildSmallField(_numUnitController, "km")),
              ],
            ),
          ] else ...[
            const Text("Reduction Details:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Old Price: ₦", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallField(_oldPriceController, "e.g. 400")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("New Price: ₦", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallField(_newPriceController, "e.g. 360")),
              ],
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: const Text("Find the Rate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    textStyle: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)
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
      appBar: AppBar(title: const Text('Rates')),
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