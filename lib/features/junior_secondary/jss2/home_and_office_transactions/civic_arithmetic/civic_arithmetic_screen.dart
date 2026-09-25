import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'civic_arithmetic_logic.dart';
import 'civic_arithmetic_models.dart';

class CivicArithmeticScreen extends StatefulWidget {
  const CivicArithmeticScreen({super.key});

  @override
  State<CivicArithmeticScreen> createState() => _CivicArithmeticScreenState();
}

class _CivicArithmeticScreenState extends State<CivicArithmeticScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: VAT, 1: Utility, 2: Composite

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Mode 0: VAT Controllers
  bool _vatIsExtraction = false;
  final TextEditingController _vatAmountCtrl = TextEditingController();
  final TextEditingController _vatRateCtrl = TextEditingController(text: "5"); // Nigerian Standard Default

  // Mode 1: Utility Bill Controllers
  final TextEditingController _utilPrevCtrl = TextEditingController();
  final TextEditingController _utilCurrCtrl = TextEditingController();
  final TextEditingController _utilUnitsCtrl = TextEditingController();
  final TextEditingController _utilRateCtrl = TextEditingController();
  final TextEditingController _utilChargeCtrl = TextEditingController();
  final TextEditingController _utilPeriodsCtrl = TextEditingController(text: "1");
  final TextEditingController _utilVatCtrl = TextEditingController();

  // Mode 2: Composite Bill Controllers
  final List<Map<String, TextEditingController>> _compositeItems = [];
  final TextEditingController _compChargeCtrl = TextEditingController();
  final TextEditingController _compVatCtrl = TextEditingController();
  final String _compositeCurrency = '₦';

  CivicResult? _result;

  @override
  void initState() {
    super.initState();
    // Add one empty row for composite by default
    _addCompositeItem();
  }

  @override
  void dispose() {
    _aiController.dispose();
    _vatAmountCtrl.dispose(); _vatRateCtrl.dispose();
    _utilPrevCtrl.dispose(); _utilCurrCtrl.dispose(); _utilUnitsCtrl.dispose();
    _utilRateCtrl.dispose(); _utilChargeCtrl.dispose(); _utilPeriodsCtrl.dispose(); _utilVatCtrl.dispose();
    _compChargeCtrl.dispose(); _compVatCtrl.dispose();
    for (var item in _compositeItems) {
      item['name']!.dispose(); item['qty']!.dispose(); item['price']!.dispose();
    }
    super.dispose();
  }

  void _addCompositeItem() {
    setState(() {
      _compositeItems.add({
        'name': TextEditingController(),
        'qty': TextEditingController(text: "1"),
        'price': TextEditingController()
      });
    });
  }

  void _removeCompositeItem(int index) {
    setState(() {
      _compositeItems[index]['name']!.dispose();
      _compositeItems[index]['qty']!.dispose();
      _compositeItems[index]['price']!.dispose();
      _compositeItems.removeAt(index);
    });
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
      You are a strict data extractor for JSS2 Civic Arithmetic (VAT and Bills).
      Analyze the word problem and return ONLY a valid JSON object.
      
      RULES:
      1. ONLY return JSON. No markdown, no comments.
      2. Keep currency symbols attached to values (e.g., "₦15300", "\$40").
      3. "topic" must be exactly "vat", "utility", or "composite".
      4. For "vat": 
         - isExtraction: boolean (true if bill ALREADY includes VAT and we must find original, false if we are adding VAT to a price).
         - amount: string
         - vatRate: string
      5. For "utility":
         - Look for meter readings (prev, curr) or explicit units.
         - charge: standing charge (string)
         - periods: number (CRITICAL: If charge is "per month" but bill is for a "quarter", periods = 3).
         - vatRate: string (If "does not charge VAT", set to "0")
      6. For "composite":
         - Extract array of items [{"name": "", "qty": 1, "price": ""}].
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "topic": "utility",
         "vat_isExtraction": false,
         "vat_amount": "",
         "vat_rate": "5",
         "util_prev": "034293",
         "util_curr": "098057",
         "util_units": "",
         "util_rate": "₦3",
         "util_charge": "₦800",
         "util_periods": "3",
         "util_vat": "0",
         "comp_charge": "",
         "comp_vat": "",
         "comp_items": []
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        String t = jsonMap['topic'] ?? 'vat';
        if (t == 'vat') {
          _topicMode = 0;
          _vatIsExtraction = jsonMap['vat_isExtraction'] ?? false;
          _vatAmountCtrl.text = jsonMap['vat_amount']?.toString() ?? '';
          _vatRateCtrl.text = jsonMap['vat_rate']?.toString() ?? '5';
        } else if (t == 'utility') {
          _topicMode = 1;
          _utilPrevCtrl.text = jsonMap['util_prev']?.toString() ?? '';
          _utilCurrCtrl.text = jsonMap['util_curr']?.toString() ?? '';
          _utilUnitsCtrl.text = jsonMap['util_units']?.toString() ?? '';
          _utilRateCtrl.text = jsonMap['util_rate']?.toString() ?? '';
          _utilChargeCtrl.text = jsonMap['util_charge']?.toString() ?? '';
          _utilPeriodsCtrl.text = jsonMap['util_periods']?.toString() ?? '1';
          _utilVatCtrl.text = jsonMap['util_vat']?.toString() ?? '';
        } else if (t == 'composite') {
          _topicMode = 2;
          _compChargeCtrl.text = jsonMap['comp_charge']?.toString() ?? '';
          _compVatCtrl.text = jsonMap['comp_vat']?.toString() ?? '';

          List itemsData = jsonMap['comp_items'] ?? [];
          if (itemsData.isNotEmpty) {
            _compositeItems.clear();
            for (var data in itemsData) {
              _compositeItems.add({
                'name': TextEditingController(text: data['name']?.toString() ?? ''),
                'qty': TextEditingController(text: data['qty']?.toString() ?? '1'),
                'price': TextEditingController(text: data['price']?.toString() ?? ''),
              });
            }
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
        _result = CivicLogic.solveVAT(amountStr: _vatAmountCtrl.text, vatRateStr: _vatRateCtrl.text, isExtraction: _vatIsExtraction);
      } else if (_topicMode == 1) {
        _result = CivicLogic.solveUtilityBill(
            prevStr: _utilPrevCtrl.text, currStr: _utilCurrCtrl.text, unitsStr: _utilUnitsCtrl.text,
            rateStr: _utilRateCtrl.text, chargeStr: _utilChargeCtrl.text, periodsStr: _utilPeriodsCtrl.text, vatRateStr: _utilVatCtrl.text
        );
      } else if (_topicMode == 2) {
        List<BillItem> items = [];
        for (var map in _compositeItems) {
          String n = map['name']!.text.trim();
          double q = double.tryParse(map['qty']!.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          double p = double.tryParse(map['price']!.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          if (n.isNotEmpty && q > 0 && p >= 0) items.add(BillItem(name: n, quantity: q, unitPrice: p));
        }
        _result = CivicLogic.solveCompositeBill(items: items, chargeStr: _compChargeCtrl.text, vatRateStr: _compVatCtrl.text, currencySymbol: _compositeCurrency);
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
                Expanded(child: Text("Paste a VAT or Utility Bill word problem. The AI handles meter readings, quarterly billing multipliers, and reverse VAT extraction!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. A water meter rises from 034293 to 098057 in a quarter...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Direct VAT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Utility Bills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Composite", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _vatIsExtraction,
                children: const {
                  false: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Add VAT (+)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  true:  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Extract VAT (-)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                },
                onValueChanged: (bool? value) { if (value != null) setState(() { _vatIsExtraction = value; _result = null; }); },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [ Expanded(flex: 3, child: _buildSmallField(_vatAmountCtrl, _vatIsExtraction ? "Total Bill Paid" : "Original Price")), const SizedBox(width: 8), Expanded(flex: 2, child: _buildSmallField(_vatRateCtrl, "VAT %")) ]),
          ] else if (_topicMode == 1) ...[
            const Text("1. Usage & Meter Readings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(children: [ Expanded(child: _buildSmallField(_utilPrevCtrl, "Prev Reading")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_utilCurrCtrl, "Curr Reading")) ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),
            _buildSmallField(_utilUnitsCtrl, "Exact Units Used (Leave readings blank)"),

            const SizedBox(height: 24),
            const Text("2. Rates & Charges:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(children: [ Expanded(child: _buildSmallField(_utilRateCtrl, "Cost per Unit")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_utilChargeCtrl, "Standing Charge")) ]),
            const SizedBox(height: 12),
            Row(children: [ Expanded(child: _buildSmallField(_utilPeriodsCtrl, "Charge Multiplier (e.g. 3 for Quarter)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_utilVatCtrl, "VAT % (Optional)")) ]),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Line Items:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                TextButton.icon(onPressed: _addCompositeItem, icon: const Icon(Icons.add, size: 18), label: const Text("Add Item"))
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: List.generate(_compositeItems.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: _buildSmallField(_compositeItems[index]['name']!, "Item Name")), const SizedBox(width: 8),
                        Expanded(flex: 2, child: _buildSmallField(_compositeItems[index]['qty']!, "Qty")), const SizedBox(width: 8),
                        Expanded(flex: 3, child: _buildSmallField(_compositeItems[index]['price']!, "Unit Price")),
                        if (_compositeItems.length > 1) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removeCompositeItem(index))
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Final Modifiers:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(children: [ Expanded(child: _buildSmallField(_compChargeCtrl, "Standing Charge")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_compVatCtrl, "VAT %")) ]),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.bolt, color: Colors.white), label: const Text("Calculate Bill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller, textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hint, isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
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
      appBar: AppBar(title: const Text('Civic Arithmetic')),
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