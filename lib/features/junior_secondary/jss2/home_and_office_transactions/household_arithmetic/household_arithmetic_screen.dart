import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'household_arithmetic_logic.dart';
import 'household_arithmetic_models.dart';

class HouseholdArithmeticScreen extends StatefulWidget {
  const HouseholdArithmeticScreen({super.key});

  @override
  State<HouseholdArithmeticScreen> createState() => _HouseholdArithmeticScreenState();
}

class _HouseholdArithmeticScreenState extends State<HouseholdArithmeticScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: Discount, 1: Instalment (Hire Purchase)
  int _discountMode = 0; // 0: Sale Price, 1: Find %, 2: Bulk
  int _instalmentMode = 0; // 0: Find Total HP, 1: Find Instalment Amt

  // AI Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Controllers - Discount
  final TextEditingController _origPriceCtrl = TextEditingController();
  final TextEditingController _discountPctCtrl = TextEditingController();
  final TextEditingController _salePriceCtrl = TextEditingController();
  final TextEditingController _unitPriceCtrl = TextEditingController();
  final TextEditingController _bulkQtyCtrl = TextEditingController();
  final TextEditingController _bulkPriceCtrl = TextEditingController();
  final TextEditingController _targetQtyCtrl = TextEditingController();

  // Controllers - Instalments
  final TextEditingController _cashPriceCtrl = TextEditingController();
  final TextEditingController _depositCtrl = TextEditingController();
  final TextEditingController _instalmentAmtCtrl = TextEditingController();
  final TextEditingController _numInstalmentsCtrl = TextEditingController();
  final TextEditingController _totalHpPriceCtrl = TextEditingController();

  HouseholdResult? _result;

  @override
  void dispose() {
    _aiController.dispose();
    _origPriceCtrl.dispose(); _discountPctCtrl.dispose(); _salePriceCtrl.dispose();
    _unitPriceCtrl.dispose(); _bulkQtyCtrl.dispose(); _bulkPriceCtrl.dispose(); _targetQtyCtrl.dispose();
    _cashPriceCtrl.dispose(); _depositCtrl.dispose(); _instalmentAmtCtrl.dispose();
    _numInstalmentsCtrl.dispose(); _totalHpPriceCtrl.dispose();
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
      You are a math data extractor for JSS2 Household Arithmetic. Extract data from the word problem into a STRICT JSON schema.
      
      RULES:
      1. ONLY return valid JSON. No markdown, no comments.
      2. Keep currency symbols attached to values (e.g. "₦40000", "\$150").
      3. If a Nigerian problem says "12k in the naira", convert that to "12%"!
      4. "type" MUST be one of: "discount_sale", "discount_pct", "discount_bulk", "instalment_total", "instalment_find_amt".
      
      SCHEMA:
      {
         "type": "",
         "origPrice": "", "discountPct": "", "salePrice": "",
         "unitPrice": "", "bulkPrice": "", "bulkQty": "", "targetQty": "",
         "cashPrice": "", "deposit": "", "instalmentAmt": "", "numInstalments": "", "totalHpPrice": ""
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        String type = jsonMap['type'] ?? '';

        if (type.startsWith('discount')) {
          _topicMode = 0;
          if (type == 'discount_sale') { _discountMode = 0; _origPriceCtrl.text = jsonMap['origPrice'] ?? ''; _discountPctCtrl.text = jsonMap['discountPct'] ?? ''; }
          else if (type == 'discount_pct') { _discountMode = 1; _origPriceCtrl.text = jsonMap['origPrice'] ?? ''; _salePriceCtrl.text = jsonMap['salePrice'] ?? ''; }
          else if (type == 'discount_bulk') {
            _discountMode = 2; _unitPriceCtrl.text = jsonMap['unitPrice'] ?? ''; _bulkPriceCtrl.text = jsonMap['bulkPrice'] ?? '';
            _bulkQtyCtrl.text = jsonMap['bulkQty'] ?? ''; _targetQtyCtrl.text = jsonMap['targetQty'] ?? '';
          }
        } else if (type.startsWith('instalment')) {
          _topicMode = 1;
          if (type == 'instalment_total') {
            _instalmentMode = 0; _cashPriceCtrl.text = jsonMap['cashPrice'] ?? ''; _depositCtrl.text = jsonMap['deposit'] ?? '';
            _instalmentAmtCtrl.text = jsonMap['instalmentAmt'] ?? ''; _numInstalmentsCtrl.text = jsonMap['numInstalments'] ?? '';
          } else if (type == 'instalment_find_amt') {
            _instalmentMode = 1; _totalHpPriceCtrl.text = jsonMap['totalHpPrice'] ?? ''; _depositCtrl.text = jsonMap['deposit'] ?? '';
            _numInstalmentsCtrl.text = jsonMap['numInstalments'] ?? '';
          }
        }
        _inputMode = 1; // Switch to Manual view
      });
      _solveManual();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Translation failed. Please manually enter values.')));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        if (_discountMode == 0) {
          _result = HouseholdLogic.solveDiscountSale(_origPriceCtrl.text, _discountPctCtrl.text);
        } else if (_discountMode == 1) {
          _result = HouseholdLogic.solveDiscountPct(
              _origPriceCtrl.text, _salePriceCtrl.text);
        } else if (_discountMode == 2) {
          _result = HouseholdLogic.solveBulkSavings(_unitPriceCtrl.text,
              _bulkPriceCtrl.text, _bulkQtyCtrl.text, _targetQtyCtrl.text);
        }
      } else {
        if (_instalmentMode == 0) {
          _result = HouseholdLogic.solveInstalmentTotal(_cashPriceCtrl.text, _depositCtrl.text, _instalmentAmtCtrl.text, _numInstalmentsCtrl.text);
        } else if (_instalmentMode == 1) {
          _result = HouseholdLogic.solveInstalmentFindAmt(
              _totalHpPriceCtrl.text,
              _depositCtrl.text,
              _numInstalmentsCtrl.text);
        }
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
                Expanded(child: Text("Paste a Discount or Hire Purchase word problem. The AI understands complex Nigerian pricing (e.g. '12k in the naira' or bulk sales)!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. A radio costs ₦5400. A 12.5% discount is given for cash...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Discount Buying", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Instalments (Hire Purchase)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _discountMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Sale Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find %", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Bulk Savings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                },
                onValueChanged: (int? value) { if (value != null) setState(() { _discountMode = value; _result = null; }); },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
            const SizedBox(height: 16),

            if (_discountMode == 0) ...[
              Row(children: [ Expanded(child: _buildSmallField(_origPriceCtrl, "Original Price (e.g. ₦5400)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_discountPctCtrl, "Discount % (e.g. 12.5)")) ]),
            ] else if (_discountMode == 1) ...[
              Row(children: [ Expanded(child: _buildSmallField(_origPriceCtrl, "Original Price")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_salePriceCtrl, "Final Sale Price")) ]),
            ] else if (_discountMode == 2) ...[
              Row(children: [ Expanded(child: _buildSmallField(_unitPriceCtrl, "Price for 1 Unit")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_bulkPriceCtrl, "Bulk Package Price")) ]),
              const SizedBox(height: 12),
              Row(children: [ Expanded(child: _buildSmallField(_bulkQtyCtrl, "Items in Bulk Pack")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_targetQtyCtrl, "Target Qty to Buy")) ]),
            ]
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _instalmentMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Extra Cost", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Find Monthly Pmt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                },
                onValueChanged: (int? value) { if (value != null) setState(() { _instalmentMode = value; _result = null; }); },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
            const SizedBox(height: 16),

            if (_instalmentMode == 0) ...[
              Row(children: [ Expanded(child: _buildSmallField(_cashPriceCtrl, "Cash Price (e.g. ₦34000)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_depositCtrl, "Deposit (Amount or %)")) ]),
              const SizedBox(height: 12),
              Row(children: [ Expanded(child: _buildSmallField(_instalmentAmtCtrl, "Payment per period")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_numInstalmentsCtrl, "Number of payments")) ]),
            ] else if (_instalmentMode == 1) ...[
              _buildSmallField(_totalHpPriceCtrl, "Total Hire Purchase Price (e.g. ₦248400)"),
              const SizedBox(height: 12),
              Row(children: [ Expanded(child: _buildSmallField(_depositCtrl, "Deposit Paid (Amount or %)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_numInstalmentsCtrl, "Number of periods")) ]),
            ]
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

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller, textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("Final Answers:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
          color: Colors.deepPurple.shade50, elevation: 0.5, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  if (_result!.workingsLaTeX[i].isEmpty)
                    const SizedBox(height: 50)
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
      appBar: AppBar(title: const Text('Household Arithmetic')),
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