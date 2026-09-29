import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'algebraic_fractions_logic.dart';
import 'algebraic_fractions_models.dart';

class AlgebraicFractionsScreen extends StatefulWidget {
  const AlgebraicFractionsScreen({super.key});

  @override
  State<AlgebraicFractionsScreen> createState() => _AlgebraicFractionsScreenState();
}

class _AlgebraicFractionsScreenState extends State<AlgebraicFractionsScreen> {
  int _topicMode = 0; // 0: Equivalent, 1: Add/Subtract

  // Mode 0: Equivalent Fraction Controllers
  final TextEditingController _n1Ctrl = TextEditingController();
  final TextEditingController _d1Ctrl = TextEditingController();
  final TextEditingController _n2Ctrl = TextEditingController();
  final TextEditingController _d2Ctrl = TextEditingController();

  // Mode 1: Add/Subtract Controllers
  final List<AlgFractionItem> _fractions = [];
  final List<Map<String, TextEditingController>> _fracCtrls = [];

  AlgFractionsResult? _result;

  @override
  void initState() {
    super.initState();
    _addFractionRow(sign: "+");
    _addFractionRow(sign: "-");
  }

  @override
  void dispose() {
    _n1Ctrl.dispose(); _d1Ctrl.dispose(); _n2Ctrl.dispose(); _d2Ctrl.dispose();
    for (var f in _fracCtrls) { f['num']!.dispose(); f['den']!.dispose(); }
    super.dispose();
  }

  void _addFractionRow({String sign = "+"}) {
    setState(() {
      _fracCtrls.add({ 'num': TextEditingController(), 'den': TextEditingController() });
      _fractions.add(AlgFractionItem(sign: sign, numStr: "", denStr: ""));
    });
  }

  void _removeFractionRow(int index) {
    setState(() {
      _fracCtrls[index]['num']!.dispose();
      _fracCtrls[index]['den']!.dispose();
      _fracCtrls.removeAt(index);
      _fractions.removeAt(index);
    });
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = AlgebraicFractionsLogic.solveEquivalent(_n1Ctrl.text, _d1Ctrl.text, _n2Ctrl.text, _d2Ctrl.text);
      } else if (_topicMode == 1) {
        for (int i = 0; i < _fractions.length; i++) {
          _fractions[i].numStr = _fracCtrls[i]['num']!.text;
          _fractions[i].denStr = _fracCtrls[i]['den']!.text;
        }
        _result = AlgebraicFractionsLogic.solveAddSub(_fractions);
      }
    });
  }

  Widget _buildVerticalFraction({
    required TextEditingController numCtrl,
    required TextEditingController denCtrl,
    required String numHint,
    required String denHint,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: numCtrl, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: numHint, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.all(12))),
          Container(height: 2, color: Colors.black87, margin: const EdgeInsets.symmetric(horizontal: 8)),
          TextField(controller: denCtrl, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: denHint, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.all(12))),
        ],
      ),
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

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _topicMode,
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Equivalent Fractions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Add / Subtract", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            },
            onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 24),

        if (_topicMode == 0) ...[
          _buildHelperBanner("Enter three known values to find the multiplier, and leave exactly ONE box blank for the missing value."),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Column(children: [ const Text("Fraction 1", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 8), _buildVerticalFraction(numCtrl: _n1Ctrl, denCtrl: _d1Ctrl, numHint: "e.g. 8b", denHint: "e.g. 5") ])),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: Text("=", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              Expanded(child: Column(children: [ const Text("Fraction 2", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 8), _buildVerticalFraction(numCtrl: _n2Ctrl, denCtrl: _d2Ctrl, numHint: "blank", denHint: "e.g. 15") ])),
            ],
          )
        ] else if (_topicMode == 1) ...[
          _buildHelperBanner("If you have a whole number (like +2a), write it as a fraction over 1 (like 2a / 1)."),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Build your fractions:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              TextButton.icon(onPressed: _addFractionRow, icon: const Icon(Icons.add, size: 18), label: const Text("Add Fraction"))
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              children: List.generate(_fractions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (index > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _fractions[index].sign,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                              items: const [
                                DropdownMenuItem(value: "+", child: Text("+", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DropdownMenuItem(value: "-", child: Text("-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                              ],
                              onChanged: (String? val) { if (val != null) setState(() => _fractions[index].sign = val); },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (index == 0) const SizedBox(width: 48), // Padding equivalent to dropdown for alignment

                      Expanded(child: _buildVerticalFraction(numCtrl: _fracCtrls[index]['num']!, denCtrl: _fracCtrls[index]['den']!, numHint: "Num (e.g. 7a - 3)", denHint: "Den (e.g. 6)")),

                      if (_fractions.length > 2)
                        IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: const EdgeInsets.only(left: 8), constraints: const BoxConstraints(), onPressed: () => _removeFractionRow(index))
                      else
                        const SizedBox(width: 32),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],

        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _solveManual, icon: const Icon(Icons.bolt, color: Colors.white), label: const Text("Calculate & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
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
        const Text("1. Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _result!.finalAnswers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${entry.key}:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(entry.value, textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("2. Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(_result!.workingsLaTeX[i], textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple))),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("3. Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
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
      appBar: AppBar(title: const Text('Algebraic Fractions')),
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