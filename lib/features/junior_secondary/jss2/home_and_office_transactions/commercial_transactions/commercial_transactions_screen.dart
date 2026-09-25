import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'commercial_transactions_logic.dart';
import 'commercial_transactions_model.dart';

class CommercialTransactionsScreen extends StatefulWidget {
  const CommercialTransactionsScreen({super.key});

  @override
  State<CommercialTransactionsScreen> createState() => _CommercialTransactionsScreenState();
}

class _CommercialTransactionsScreenState extends State<CommercialTransactionsScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: Profit/Loss, 1: Commission

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Mode 0: Profit & Loss Controllers
  final TextEditingController _cpCtrl = TextEditingController();
  final TextEditingController _spCtrl = TextEditingController();
  final TextEditingController _pctCtrl = TextEditingController();
  bool _isProfitPct = true; // Determines if the percentage field refers to Profit or Loss

  // Mode 1: Commission & Bank Draft Controllers
  final List<Map<String, TextEditingController>> _commItems = [];
  bool _isPctComm = true;
  final TextEditingController _commRateCtrl = TextEditingController(); // e.g. 14%
  final TextEditingController _commFlatAmtCtrl = TextEditingController(); // e.g. 100
  final TextEditingController _commFlatQtyCtrl = TextEditingController(text: "1"); // e.g. per 5 tickets
  bool _isBankDraft = false;
  final String _currencySymbol = '₦';

  CommercialResult? _result;

  @override
  void initState() {
    super.initState();
    _addCommItem();
  }

  @override
  void dispose() {
    _aiController.dispose();
    _cpCtrl.dispose(); _spCtrl.dispose(); _pctCtrl.dispose();
    _commRateCtrl.dispose(); _commFlatAmtCtrl.dispose(); _commFlatQtyCtrl.dispose();
    for (var item in _commItems) {
      item['name']!.dispose(); item['qty']!.dispose(); item['price']!.dispose();
    }
    super.dispose();
  }

  void _addCommItem() {
    setState(() {
      _commItems.add({
        'name': TextEditingController(),
        'qty': TextEditingController(text: "1"),
        'price': TextEditingController()
      });
    });
  }

  void _removeCommItem(int index) {
    setState(() {
      _commItems[index]['name']!.dispose();
      _commItems[index]['qty']!.dispose();
      _commItems[index]['price']!.dispose();
      _commItems.removeAt(index);
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

      // Reverted to standard initialization (no strict mimeType) to prevent server rejection
      final model = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: apiKey,
      );

      final prompt = '''
      Extract data from the word problem for JSS2 Commercial Transactions (Profit, Loss, Commission).
      
      RULES:
      1. Return ONLY a valid JSON object. No markdown, no conversational text.
      2. Keep currency symbols attached to values and USE COMMAS for large numbers (e.g., "₦15,300", "\$4,000").
      3. "topic" must be exactly "profit_loss" or "commission".
      4. For "profit_loss": 
         - Extract "cp" (Cost Price), "sp" (Selling Price), and "pct" (Percentage).
         - "isProfitPct": true if it's a profit percentage, false if it's a loss percentage.
         - Normalize tricky quantities (e.g. if buys "a dozen for 900" and sells "at 90 each", set cp="900" and sp="1080").
      5. For "commission":
         - "isBankDraft": true if it's a bank draft or service.
         - "isPctComm": true if commission is a percentage.
         - If text says "14k in the naira" or "1k in the naira", translate this to "14" or "1" in "comm_rate".
         - "comm_flatAmt" and "comm_flatQty": Use if flat rate (e.g., "₦100 for every 5 tickets" -> amt="100", qty="5").
         - Extract array of items: [{"name": "chairs", "qty": 44, "price": "₦5,300"}].
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "topic": "profit_loss",
         "cp": "₦15,300",
         "sp": "",
         "pct": "10",
         "isProfitPct": false,
         "comm_isBankDraft": false,
         "comm_isPct": true,
         "comm_rate": "",
         "comm_flatAmt": "",
         "comm_flatQty": "1",
         "comm_items": []
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';

      // Safety net: Strip out any markdown code blocks Gemini tries to add
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      print("RAW AI OUTPUT: $rawOutput");

      final jsonMap = json.decode(rawOutput);

      setState(() {
        String t = jsonMap['topic'] ?? 'profit_loss';
        if (t == 'profit_loss') {
          _topicMode = 0;
          _cpCtrl.text = jsonMap['cp']?.toString() ?? '';
          _spCtrl.text = jsonMap['sp']?.toString() ?? '';
          _pctCtrl.text = jsonMap['pct']?.toString() ?? '';
          _isProfitPct = jsonMap['isProfitPct'] ?? true;
        } else {
          _topicMode = 1;
          _isBankDraft = jsonMap['comm_isBankDraft'] ?? false;
          _isPctComm = jsonMap['comm_isPct'] ?? true;
          _commRateCtrl.text = jsonMap['comm_rate']?.toString() ?? '';
          _commFlatAmtCtrl.text = jsonMap['comm_flatAmt']?.toString() ?? '';
          _commFlatQtyCtrl.text = jsonMap['comm_flatQty']?.toString() ?? '1';

          List itemsData = jsonMap['comm_items'] ?? [];
          if (itemsData.isNotEmpty) {
            _commItems.clear();
            for (var data in itemsData) {
              _commItems.add({
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
      print("Gemini AI Error: $e");

      String errorMsg = 'AI Translation failed. Please manually enter values.';
      if (e.toString().contains('API key not valid') || e.toString().contains('authentication')) {
        errorMsg = 'AI Error: Invalid API Key or Auth Token.';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'AI Error: No internet connection.';
      } else if (e.toString().contains('FormatException')) {
        errorMsg = 'AI Error: Could not parse the extracted numbers.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red.shade800,
        duration: const Duration(seconds: 4),
      ));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = CommercialLogic.solveProfitLoss(
            cpStr: _cpCtrl.text,
            spStr: _spCtrl.text,
            pctStr: _pctCtrl.text,
            isProfitPct: _isProfitPct
        );
      } else {
        List<CommItem> items = [];
        for (var map in _commItems) {
          String n = map['name']!.text.trim();
          double q = double.tryParse(map['qty']!.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          double p = double.tryParse(map['price']!.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          if (q > 0 && p >= 0) items.add(CommItem(name: n.isEmpty ? "Item" : n, quantity: q, unitPrice: p));
        }
        _result = CommercialLogic.solveCommission(
          items: items,
          isPct: _isPctComm,
          rateStr: _commRateCtrl.text,
          flatAmtStr: _commFlatAmtCtrl.text,
          flatQtyStr: _commFlatQtyCtrl.text,
          isBankDraft: _isBankDraft,
          currencySymbol: _currencySymbol,
        );
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
                Expanded(child: Text("Paste a Profit/Loss or Commission word problem. The AI can handle reverse percentages and Nigerian slang like '14k in the naira'!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. A trader makes a loss of 10% when he sells a watch for ₦15,300. What did it cost?", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Profit & Loss", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Commission & Sales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(child: Text("Enter ANY TWO known values. The system will automatically calculate the missing pieces (even reverse percentages!).", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [ Expanded(child: _buildSmallField(_cpCtrl, "Cost Price (CP)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_spCtrl, "Selling Price (SP)")) ]),
            const SizedBox(height: 16),
            Row(
                children: [
                  Expanded(child: _buildSmallField(_pctCtrl, "% Rate")),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                        height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool>(
                            value: _isProfitPct, isExpanded: true,
                            items: const [ DropdownMenuItem(value: true, child: Text("is Profit %")), DropdownMenuItem(value: false, child: Text("is Loss %")) ],
                            onChanged: (bool? val) { if (val != null) setState(() => _isProfitPct = val); },
                          ),
                        ),
                      )
                  )
                ]
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Items Sold / Bank Drafts:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                TextButton.icon(onPressed: _addCommItem, icon: const Icon(Icons.add, size: 18), label: const Text("Add Item"))
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: List.generate(_commItems.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: _buildSmallField(_commItems[index]['name']!, "Name")), const SizedBox(width: 8),
                        Expanded(flex: 2, child: _buildSmallField(_commItems[index]['qty']!, "Qty")), const SizedBox(width: 8),
                        Expanded(flex: 3, child: _buildSmallField(_commItems[index]['price']!, "Unit Price")),
                        if (_commItems.length > 1) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removeCommItem(index))
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Commission Rules:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _isPctComm,
                children: const {
                  true: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Percentage Rate (%)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  false: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Flat Rate (Per Item)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                },
                onValueChanged: (bool? val) { if (val != null) setState(() => _isPctComm = val); },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
            const SizedBox(height: 12),
            if (_isPctComm) ...[
              _buildSmallField(_commRateCtrl, "Commission % (e.g. 14 for '14k in the naira')"),
            ] else ...[
              Row(children: [
                const Text("Gets  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_commFlatAmtCtrl, "₦100")),
                const Text("  for every  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_commFlatQtyCtrl, "5")),
                const Text("  items.", style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ],
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("This is a Bank Draft / Service", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Calculates Total Cost (Face Value + Commission)", style: TextStyle(fontSize: 12)),
              value: _isBankDraft,
              activeColor: Colors.deepPurple,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? val) { if (val != null) setState(() => _isBankDraft = val); },
            )
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
                for (int i = 0; i < _result!.workings.length; i++)
                  if (_result!.workings[i].isEmpty) const SizedBox(height: 16)
                  else Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(_result!.workings[i], textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple))),
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
      appBar: AppBar(title: const Text('Commercial Transactions')),
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