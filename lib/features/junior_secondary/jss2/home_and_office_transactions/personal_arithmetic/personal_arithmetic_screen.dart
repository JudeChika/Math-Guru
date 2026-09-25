import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'personal_arithmetic_logic.dart';
import 'personal_arithmetic_models.dart';

class PersonalArithmeticScreen extends StatefulWidget {
  const PersonalArithmeticScreen({super.key});

  @override
  State<PersonalArithmeticScreen> createState() => _PersonalArithmeticScreenState();
}

class _PersonalArithmeticScreenState extends State<PersonalArithmeticScreen> {
  int _inputMode = 0; // 0 for AI, 1 for Manual
  int _topicMode = 0; // 0 for Interest, 1 for Tax

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Interest Controllers
  int _interestSolveMode = 0; // 0: Interest, 1: Rate, 2: Principal, 3: Time
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _interestAmtController = TextEditingController();
  final TextEditingController _instalmentsController = TextEditingController();
  String _timeUnit = 'Years';

  // Tax Controllers
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  final TextEditingController _dependentController = TextEditingController();

  // Dynamic Allowances
  final TextEditingController _personalAllowanceController = TextEditingController();
  final TextEditingController _childAllowanceController = TextEditingController();

  // Dynamic Tax Bands (Using Lower Limit, Upper Limit, Rate)
  List<Map<String, TextEditingController>> _taxBandControllers = [];

  PersonalArithmeticResult? _result;

  @override
  void initState() {
    super.initState();
    // Pre-fill with JSS 2 Textbook defaults using Ranges (Lower to Upper)
    _taxBandControllers = [
      {'lower': TextEditingController(text: '0'), 'upper': TextEditingController(text: '200000'), 'rate': TextEditingController(text: '10')},
      {'lower': TextEditingController(text: '200000'), 'upper': TextEditingController(text: '400000'), 'rate': TextEditingController(text: '15')},
      {'lower': TextEditingController(text: '400000'), 'upper': TextEditingController(text: '600000'), 'rate': TextEditingController(text: '20')},
      {'lower': TextEditingController(text: '600000'), 'upper': TextEditingController(text: ''), 'rate': TextEditingController(text: '25')}, // Empty upper = 'Over'
    ];
  }

  @override
  void dispose() {
    _aiController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    _interestAmtController.dispose();
    _instalmentsController.dispose();
    _incomeController.dispose();
    _childrenController.dispose();
    _dependentController.dispose();
    _personalAllowanceController.dispose();
    _childAllowanceController.dispose();
    for (var band in _taxBandControllers) {
      band['lower']!.dispose();
      band['upper']!.dispose();
      band['rate']!.dispose();
    }
    super.dispose();
  }

  void _addTaxBand() {
    setState(() {
      _taxBandControllers.add({
        'lower': TextEditingController(),
        'upper': TextEditingController(),
        'rate': TextEditingController()
      });
    });
  }

  void _removeTaxBand(int index) {
    setState(() {
      _taxBandControllers[index]['lower']!.dispose();
      _taxBandControllers[index]['upper']!.dispose();
      _taxBandControllers[index]['rate']!.dispose();
      _taxBandControllers.removeAt(index);
    });
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = PersonalArithmeticLogic.solveSimpleInterest(
          solveMode: _interestSolveMode,
          principalStr: _principalController.text,
          rateStr: _rateController.text,
          timeStr: _timeController.text,
          interestStr: _interestAmtController.text,
          timeUnit: _timeUnit,
          instalmentsStr: _instalmentsController.text,
        );
      } else {
        List<TaxBand> bands = [];
        for (var ctrl in _taxBandControllers) {
          String rStr = ctrl['rate']!.text.trim();
          if (rStr.isEmpty) continue; // Skip empty rates
          double r = double.parse(rStr);

          String lowerStr = ctrl['lower']!.text.trim();
          double lowerBound = lowerStr.isEmpty ? 0 : double.parse(lowerStr.replaceAll(RegExp(r'[^\d.]'), ''));

          String upperStr = ctrl['upper']!.text.trim();
          double? upperBound = upperStr.isEmpty ? null : double.parse(upperStr.replaceAll(RegExp(r'[^\d.]'), ''));

          bands.add(TaxBand(lower: lowerBound, upper: upperBound, rate: r));
        }

        _result = PersonalArithmeticLogic.solveIncomeTax(
          incomeStr: _incomeController.text,
          childrenStr: _childrenController.text,
          dependentStr: _dependentController.text,
          personalAllowanceStr: _personalAllowanceController.text,
          childAllowanceStr: _childAllowanceController.text,
          taxBands: bands,
        );
      }
    });
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _aiController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem.')));
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null;
    });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final prompt = '''
      You are a math data extractor for JSS2 students learning Home and Office Transactions.
      Read the word problem and extract the variables.
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no backticks, no explanations.
      2. Decide if the topic is "interest" or "tax".
      3. Do NOT strip currency symbols. If it says \$500 or £400 or ₦20, keep the symbol in the string!
      4. For "interest": 
         - Decide "solveMode": 0 (Find Interest/Amount), 1 (Find Rate), 2 (Find Principal), 3 (Find Time).
         - Extract principal, rate (number), time (number), timeUnit ("Years", "Months", "Weeks"), interestAmt (if given), instalments (number).
         - SPECIAL RULE: If interest says "₦1 on each ₦10 per week", calculate the percentage (1/10 = 10), set "rate" to "10", and "timeUnit" to "Weeks".
         - SPECIAL RULE: If a "Total Amount to be paid back" is given (e.g. borrows 20k, pays back 25k), calculate the interest amount (25k - 20k = 5k) and set "interestAmt" to "5000".
      5. For "tax": Extract income, children (number), dependent (number), personal_allowance (number), child_allowance (number).
      6. For "tax bands": Look for custom tax tables. Convert them into range bounds ("lower" and "upper"). Use "null" for the final 'remaining' band.
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
        "topic": "tax",
        "solveMode": 0,
        "principal": "",
        "rate": "",
        "time": "",
        "interestAmt": "",
        "timeUnit": "Years",
        "instalments": "",
        "income": "₦528000",
        "children": "3",
        "dependent": "37000",
        "personal_allowance": "60000",
        "child_allowance": "25000",
        "tax_bands": [
           {"lower": "0", "upper": "200000", "rate": "10"},
           {"lower": "200000", "upper": "400000", "rate": "15"},
           {"lower": "600000", "upper": "null", "rate": "25"}
        ]
      }
      
      Word problem: "$inputText"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      if (rawOutput.isEmpty) throw Exception("AI failed to extract data.");
      final parsedJson = json.decode(rawOutput);

      setState(() {
        if (parsedJson['topic'] == 'interest') {
          _topicMode = 0;
          _interestSolveMode = parsedJson['solveMode'] is int ? parsedJson['solveMode'] : int.tryParse(parsedJson['solveMode']?.toString() ?? '0') ?? 0;
          _principalController.text = parsedJson['principal']?.toString() ?? "";
          _rateController.text = parsedJson['rate']?.toString() ?? "";
          _timeController.text = parsedJson['time']?.toString() ?? "";
          _interestAmtController.text = parsedJson['interestAmt']?.toString() ?? "";
          _instalmentsController.text = parsedJson['instalments']?.toString() ?? "";

          String tu = parsedJson['timeUnit']?.toString() ?? "Years";
          if (['Years', 'Months', 'Weeks'].contains(tu)) {
            _timeUnit = tu;
          } else {
            _timeUnit = 'Years';
          }
        } else {
          _topicMode = 1;
          _incomeController.text = parsedJson['income']?.toString() ?? "";
          _childrenController.text = parsedJson['children']?.toString() ?? "";
          _dependentController.text = parsedJson['dependent']?.toString() ?? "";
          _personalAllowanceController.text = parsedJson['personal_allowance']?.toString() ?? "";
          _childAllowanceController.text = parsedJson['child_allowance']?.toString() ?? "";

          // Populate dynamic tax bands if AI found any
          if (parsedJson['tax_bands'] != null && (parsedJson['tax_bands'] as List).isNotEmpty) {
            _taxBandControllers.clear();
            for (var b in parsedJson['tax_bands']) {
              _taxBandControllers.add({
                'lower': TextEditingController(text: b['lower']?.toString()),
                'upper': TextEditingController(text: b['upper']?.toString() == 'null' ? '' : b['upper']?.toString()),
                'rate': TextEditingController(text: b['rate']?.toString()),
              });
            }
          }
        }

        _inputMode = 1; // Switch to manual view to show the mapped fields
      });

      _solveManual();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Translation failed. Please enter the values manually.')));
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
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text("Paste a Simple Interest or Income Tax word problem. The AI will extract the numbers, units, and custom tax bands!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Word Problem",
              hintText: "e.g. A woman earns \$50,000. She gets \$5,000 personal allowance...",
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
              groupValue: _topicMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Simple Interest", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Income Tax (PAYE)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) {
                if (value != null) setState(() { _topicMode = value; _result = null; });
              },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _interestSolveMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Interest", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Principal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  3: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                },
                onValueChanged: (int? value) {
                  if (value != null) setState(() { _interestSolveMode = value; _result = null; });
                },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Loan Details:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),

            if (_interestSolveMode == 0) ...[
              // Find Interest
              Row(
                children: [
                  Expanded(child: _buildSmallField(_principalController, "Principal (e.g. ₦40k)")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_rateController, "Rate (%)")),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildSmallField(_timeController, "Time")),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _timeUnit,
                            isExpanded: true,
                            items: ['Years', 'Months', 'Weeks'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? val) { if (val != null) setState(() => _timeUnit = val); },
                          ),
                        ),
                      )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSmallField(_instalmentsController, "Number of Instalments (Optional)"),
            ] else if (_interestSolveMode == 1) ...[
              // Find Rate
              Row(
                children: [
                  Expanded(child: _buildSmallField(_principalController, "Principal")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_interestAmtController, "Interest Paid")),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildSmallField(_timeController, "Time")),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _timeUnit,
                            isExpanded: true,
                            items: ['Years', 'Months', 'Weeks'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? val) { if (val != null) setState(() => _timeUnit = val); },
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ] else if (_interestSolveMode == 2) ...[
              // Find Principal
              Row(
                children: [
                  Expanded(child: _buildSmallField(_rateController, "Rate (%)")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_interestAmtController, "Interest Paid")),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildSmallField(_timeController, "Time")),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _timeUnit,
                            isExpanded: true,
                            items: ['Years', 'Months', 'Weeks'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? val) { if (val != null) setState(() => _timeUnit = val); },
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ] else if (_interestSolveMode == 3) ...[
              // Find Time
              Row(
                children: [
                  Expanded(child: _buildSmallField(_principalController, "Principal")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_interestAmtController, "Interest Paid")),
                ],
              ),
              const SizedBox(height: 12),
              _buildSmallField(_rateController, "Rate (%)"),
            ],

          ] else ...[
            const Text("1. Income & Basic Facts:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            _buildSmallField(_incomeController, "Total Monthly Income (e.g. \$5000)"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSmallField(_childrenController, "No. of Children")),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallField(_dependentController, "Dependent Allow.")),
              ],
            ),
            const SizedBox(height: 24),

            const Text("2. Allowances (Leave blank if none):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSmallField(_personalAllowanceController, "Personal Allowance")),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallField(_childAllowanceController, "Allowance per Child")),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("3. Progressive Tax Bands:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                TextButton.icon(
                  onPressed: _addTaxBand,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Band"),
                )
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: List.generate(_taxBandControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _taxBandControllers[index]['lower'],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: "From (₦)",
                              hintText: "e.g. 0",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _taxBandControllers[index]['upper'],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: "Up to (₦)",
                              hintText: "Blank = Over",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _taxBandControllers[index]['rate'],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: "%",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        if (_taxBandControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeTaxBand(index),
                          )
                      ],
                    ),
                  );
                }),
              ),
            )
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: const Text("Calculate & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      keyboardType: TextInputType.text, // Allow currency symbols!
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
        const Text("Final Answers:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _result!.finalAnswers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${entry.key}:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      Text(entry.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
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
                  if (_result!.workingsLaTeX[i].isEmpty)
                    const SizedBox(height: 50)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
      appBar: AppBar(title: const Text('Personal Arithmetic')),
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