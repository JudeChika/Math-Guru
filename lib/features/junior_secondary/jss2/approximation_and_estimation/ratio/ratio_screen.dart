import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ratio_logic.dart';
import 'ratio_models.dart';

class RatioScreen extends StatefulWidget {
  const RatioScreen({super.key});

  @override
  State<RatioScreen> createState() => _RatioScreenState();
}

class _RatioScreenState extends State<RatioScreen> {
  int _inputMode = 0; // 0: AI Word Problem, 1: Manual Builder

  // AI Controllers
  final TextEditingController _wordProblemController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Mode State
  int _mainMode = 0; // 0: Simplify, 1: Fill Gap, 2: Sharing, 3: Percentages
  int _pctMode = 0;  // 0: Find % of x, 1: Express as %, 2: Find 100%

  // Mode 0 Controllers
  final List<TextEditingController> _simplifyCtrls = [TextEditingController(), TextEditingController()];

  // Mode 1 Controllers (a:b = c:d)
  final List<TextEditingController> _equivCtrls = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];

  // Mode 2 Controllers
  final TextEditingController _shareTotalCtrl = TextEditingController();
  final List<TextEditingController> _shareRatioCtrls = [TextEditingController(), TextEditingController()];

  // Mode 3 Controllers
  final TextEditingController _pctVal1Ctrl = TextEditingController();
  final TextEditingController _pctVal2Ctrl = TextEditingController();

  RatioResult? _result;

  @override
  void dispose() {
    _wordProblemController.dispose();
    for (var c in _simplifyCtrls) { c.dispose(); }
    for (var c in _equivCtrls) { c.dispose(); }
    _shareTotalCtrl.dispose();
    for (var c in _shareRatioCtrls) { c.dispose(); }
    _pctVal1Ctrl.dispose();
    _pctVal2Ctrl.dispose();
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_mainMode == 0) {
        _result = RatioLogic.solveSimplify(_simplifyCtrls.map((c) => c.text).toList());
      } else if (_mainMode == 1) {
        _result = RatioLogic.solveEquivalent(_equivCtrls[0].text, _equivCtrls[1].text, _equivCtrls[2].text, _equivCtrls[3].text);
      } else if (_mainMode == 2) {
        _result = RatioLogic.solveSharing(_shareTotalCtrl.text, _shareRatioCtrls.map((c) => c.text).toList());
      } else if (_mainMode == 3) {
        _result = RatioLogic.solvePercentage(_pctMode, _pctVal1Ctrl.text, _pctVal2Ctrl.text);
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

      const prompt = '''
      You are a strict math data extractor for JSS2 students. 
      Read the word problem and extract the variables for ratios and percentages.
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no backticks, no comments.
      2. Determine the problemType from these exactly: "simplify", "equivalent", "sharing", "percentage_find_val", "percentage_express", "percentage_find_whole".
      3. Ignore units (like cm, kg, Naira) in the numbers. Return strictly numbers as strings.
      4. For ratios, split the parts into separate strings (e.g. ratio 2:3 becomes ["2", "3"]).
      
      JSON FORMAT EXACTLY LIKE THIS (Use empty strings/arrays for unused fields):
      {
        "problemType": "sharing",
        "simplifyValues": [],
        "equivalentValues": ["", "", "", ""], 
        "sharingTotal": "35",
        "sharingRatios": ["2", "3"],
        "pctVal1": "",
        "pctVal2": ""
      }
      
      Word problem: "\$inputText"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String rawOutput = response.text?.trim() ?? '';

      // Clean up any markdown blocks safely using RegEx
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      if (rawOutput.isEmpty) throw Exception("AI failed to extract data.");

      final parsedJson = json.decode(rawOutput);

      setState(() {
        String type = parsedJson['problemType'];

        if (type == 'simplify') {
          _mainMode = 0;
          List<dynamic> vals = parsedJson['simplifyValues'] ?? [];
          _simplifyCtrls.clear();
          for (var v in vals) {
            _simplifyCtrls.add(TextEditingController(text: v.toString()));
          }
        } else if (type == 'equivalent') {
          _mainMode = 1;
          List<dynamic> vals = parsedJson['equivalentValues'] ?? ["", "", "", ""];
          for (int i = 0; i < 4; i++) {
            _equivCtrls[i].text = i < vals.length ? vals[i].toString() : "";
          }
        } else if (type == 'sharing') {
          _mainMode = 2;
          _shareTotalCtrl.text = parsedJson['sharingTotal']?.toString() ?? "";
          List<dynamic> rVals = parsedJson['sharingRatios'] ?? [];
          _shareRatioCtrls.clear();
          for (var v in rVals) {
            _shareRatioCtrls.add(TextEditingController(text: v.toString()));
          }
        } else if (type.startsWith('percentage')) {
          _mainMode = 3;
          if (type == 'percentage_find_val') {
            _pctMode = 0;
          } else if (type == 'percentage_express') _pctMode = 1;
          else if (type == 'percentage_find_whole') _pctMode = 2;

          _pctVal1Ctrl.text = parsedJson['pctVal1']?.toString() ?? "";
          _pctVal2Ctrl.text = parsedJson['pctVal2']?.toString() ?? "";
        }

        _inputMode = 1; // Automatically switch to manual view to show mapping!
      });

      // Automatically execute the math once populated
      _solve();

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
    if (_mainMode == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter the ratio to simplify. We will automatically clear decimals and find the Lowest Terms!"),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_simplifyCtrls.length * 2 - 1, (index) {
              if (index.isOdd) return const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(":", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)));
              int ctrlIndex = index ~/ 2;
              return Expanded(
                child: TextField(
                  controller: _simplifyCtrls[ctrlIndex],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(hintText: "e.g. 600", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _simplifyCtrls.length < 4 ? () => setState(() => _simplifyCtrls.add(TextEditingController())) : null,
                icon: const Icon(Icons.add, color: Colors.deepPurple), label: const Text("Add Part", style: TextStyle(color: Colors.deepPurple)),
              ),
              TextButton.icon(
                onPressed: _simplifyCtrls.length > 2 ? () => setState(() { _simplifyCtrls.last.dispose(); _simplifyCtrls.removeLast(); }) : null,
                icon: const Icon(Icons.remove, color: Colors.red), label: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      );
    } else if (_mainMode == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter three numbers and leave ONE box entirely blank for the unknown variable."),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSmallField(_equivCtrls[0], "e.g. 2")),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(":", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              Expanded(child: _buildSmallField(_equivCtrls[1], "e.g. 7")),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("=", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              Expanded(child: _buildSmallField(_equivCtrls[2], "blank")),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(":", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              Expanded(child: _buildSmallField(_equivCtrls[3], "e.g. 28")),
            ],
          ),
        ],
      );
    } else if (_mainMode == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter the total amount to share, then define the ratio blocks."),
          const SizedBox(height: 16),
          TextField(
            controller: _shareTotalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: "Total Amount to Share", hintText: "e.g. 35", prefixIcon: const Icon(Icons.pie_chart, color: Colors.deepPurple), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          const Text("Ratio:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_shareRatioCtrls.length * 2 - 1, (index) {
              if (index.isOdd) return const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(":", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)));
              int ctrlIndex = index ~/ 2;
              return Expanded(child: _buildSmallField(_shareRatioCtrls[ctrlIndex], "e.g. ${ctrlIndex + 2}"));
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _shareRatioCtrls.length < 5 ? () => setState(() => _shareRatioCtrls.add(TextEditingController())) : null,
                icon: const Icon(Icons.add, color: Colors.deepPurple), label: const Text("Add Person/Part", style: TextStyle(color: Colors.deepPurple)),
              ),
              TextButton.icon(
                onPressed: _shareRatioCtrls.length > 2 ? () => setState(() { _shareRatioCtrls.last.dispose(); _shareRatioCtrls.removeLast(); }) : null,
                icon: const Icon(Icons.remove, color: Colors.red), label: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _pctMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find x% of y", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Express x as % of y", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("If x% is y, find 100%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              },
              onValueChanged: (int? value) {
                if (value != null) setState(() { _pctMode = value; _result = null; _pctVal1Ctrl.clear(); _pctVal2Ctrl.clear(); });
              },
              thumbColor: Colors.deepPurple.shade100,
            ),
          ),
          const SizedBox(height: 16),
          if (_pctMode == 0) ...[
            _buildHelperBanner("Find a percentage of a quantity (e.g. Find 15% of 2.8kg)."),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Find  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal1Ctrl, "15")),
                const Text("  %  of  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal2Ctrl, "2.8")),
              ],
            )
          ] else if (_pctMode == 1) ...[
            _buildHelperBanner("Express one quantity as a percentage of another (e.g. Express 3.3 as a % of 7.5)."),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Express  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal1Ctrl, "3.3")),
                const Text("  as a % of  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal2Ctrl, "7.5")),
              ],
            )
          ] else ...[
            _buildHelperBanner("Use the Unitary Method to find the original total (e.g. If 85% is ₦646, find 100%)."),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("If  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal1Ctrl, "85")),
                const Text("  % is equal to  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_pctVal2Ctrl, "646")),
              ],
            )
          ]
        ],
      );
    }
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildHelperBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildResultView() {
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
        const Text("1. Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: _result!.finalAnswers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${entry.key}: ${entry.value}",
                        style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
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
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          _result!.workingsLaTeX[i],
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("3. Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ratios & Percentages')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 24),

            if (_inputMode == 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(child: Text("Paste your word problem below. The AI will instantly classify it, map out the variables, and solve it!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
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
                  hintText: "e.g. A farmer divides 240 cattle among his 3 children in the ratio 5:4:3. How many does each get?",
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
                  groupValue: _mainMode,
                  children: const {
                    0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Simplify", style: TextStyle(fontWeight: FontWeight.bold))),
                    1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Fill Gap", style: TextStyle(fontWeight: FontWeight.bold))),
                    2: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Share", style: TextStyle(fontWeight: FontWeight.bold))),
                    3: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Percents", style: TextStyle(fontWeight: FontWeight.bold))),
                  },
                  onValueChanged: (int? value) {
                    if (value != null) setState(() { _mainMode = value; _result = null; });
                  },
                  thumbColor: Colors.deepPurple.shade100,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 24),

              _buildInputSection(),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _solve,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text("Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            _buildResultView(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}