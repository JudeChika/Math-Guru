import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ordering_fractions_models.dart';
import 'ordering_fractions_logic.dart';
import 'ordering_fractions_workings.dart';
import 'fraction_display.dart';

enum OrderType { ascending, descending }

class OrderingFractionsScreen extends StatefulWidget {
  const OrderingFractionsScreen({super.key});

  @override
  State<OrderingFractionsScreen> createState() => _OrderingFractionsScreenState();
}

class _OrderingFractionsScreenState extends State<OrderingFractionsScreen> {
  List<FractionInput> _fractions = [
    FractionInput(),
    FractionInput(),
  ];
  OrderType? _orderType;
  List<WorkingStep>? _workingSteps;
  List<FractionWithValue>? _orderedFractions;
  int? _lcm;
  bool _submitted = false;
  String? _errorMsg;

  final _formKey = GlobalKey<FormState>();

  void _addFraction() {
    setState(() {
      _fractions.add(FractionInput());
    });
  }

  void _removeFraction(int idx) {
    setState(() {
      if (_fractions.length > 2) {
        _fractions.removeAt(idx);
      }
    });
  }

  void _submit(OrderType type) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMsg = "Please enter valid numerators and denominators (denominator ≠ 0).";
        _submitted = true;
      });
      return;
    }
    setState(() {
      _errorMsg = null;
      _formKey.currentState!.save();
      _orderType = type;
    });

    final numerators = _fractions.map((f) => f.numerator!).toList();
    final denominators = _fractions.map((f) => f.denominator!).toList();
    final lcm = OrderingFractionsLogic.findLcmList(denominators);
    final steps = OrderingFractionsLogic.calculateWorkingSteps(_fractions);
    final ordered = OrderingFractionsLogic.orderFractions(steps, ascending: (type == OrderType.ascending));
    setState(() {
      _lcm = lcm;
      _workingSteps = steps;
      _orderedFractions = ordered;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final poppins16 = GoogleFonts.poppins(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ordering of Fractions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Fractions (at least two):",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  for (int i = 0; i < _fractions.length; i++)
                    Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            initialValue: _fractions[i].numerator?.toString(),
                            decoration: InputDecoration(
                              labelText: "Numerator",
                              labelStyle: GoogleFonts.poppins(),
                            ),
                            style: poppins16,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              final n = int.tryParse(val ?? "");
                              if (n == null) return "";
                              return null;
                            },
                            onSaved: (val) =>
                            _fractions[i].numerator = int.tryParse(val ?? ""),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            initialValue: _fractions[i].denominator?.toString(),
                            decoration: InputDecoration(
                              labelText: "Denominator",
                              labelStyle: GoogleFonts.poppins(),
                            ),
                            style: poppins16,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              final d = int.tryParse(val ?? "");
                              if (d == null || d == 0) return "";
                              return null;
                            },
                            onSaved: (val) =>
                            _fractions[i].denominator = int.tryParse(val ?? ""),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (_fractions.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeFraction(i),
                          ),
                      ],
                    ),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.add, color: Colors.deepPurple),
                        label: Text(
                          "Add Fraction",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        onPressed: _addFraction,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Select Order:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  label: Text("Ascending", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                  onPressed: () => _submit(OrderType.ascending),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_downward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  label: Text("Descending", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                  onPressed: () => _submit(OrderType.descending),
                ),
              ],
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMsg!,
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            if (_submitted && _orderedFractions != null) ...[
              Card(
                color: Colors.green.shade50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Answer
                      Center(
                        child: Wrap(
                          spacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final f in _orderedFractions!) ...[
                              FractionDisplay(
                                numerator: f.numerator,
                                denominator: f.denominator,
                                fontSize: 32,
                                color: Colors.deepPurple,
                                fontFamily: 'Poppins',
                              ),
                              if (f != _orderedFractions!.last)
                                _orderType == OrderType.ascending
                                    ? const Icon(Icons.arrow_forward, color: Colors.purple, size: 26)
                                    : const Icon(Icons.arrow_back, color: Colors.purple, size: 26),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Workings section
                      if (_lcm != null && _workingSteps != null)
                        OrderingFractionsWorkings(
                          lcm: _lcm!,
                          steps: _workingSteps!,
                        ),
                      const SizedBox(height: 20),
                      // Step-by-step Solution section
                      Text(
                        "Step-by-step Solution:",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _stepsCard(_stepWidgets(context), Theme.of(context)),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  List<Widget> _stepWidgets(BuildContext context) {
    final poppins = GoogleFonts.poppins(fontSize: 14, color: Colors.black87);
    final fractions = _fractions;
    final lcm = _lcm!;
    final orderType = _orderType!;
    final stepWidgets = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 1: Display the fractions entered: ', style: poppins.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
            ...[
              for (int i = 0; i < fractions.length; i++) ...[
                FractionDisplay(
                  numerator: fractions[i].numerator!,
                  denominator: fractions[i].denominator!,
                  fontSize: 18, fontFamily: 'Poppins',
                ),
                if (i != fractions.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(",", style: poppins),
                  ),
              ]
            ]
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 2: Find the LCM of the denominators: ', style: poppins.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    "(${fractions.map((f) => f.denominator).join(", ")}) = ",
                    style: poppins.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Text("$lcm", style: poppins.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ],
              ),
            ),
          ],
        ),
      ),
      for (final s in _workingSteps!) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Step 3: Multiply ', style: poppins),
              FractionDisplay(
                numerator: s.numerator,
                denominator: s.denominator,
                fontSize: 16, fontFamily: 'Poppins',
              ),
              Text(' by ', style: poppins),
              FractionDisplay(
                numerator: s.lcm,
                denominator: 1,
                fontSize: 16,
                color: Colors.deepPurple, fontFamily: 'Poppins',
              ),
              Text(' = ', style: poppins),
              Text('${s.numerator} × ${s.factor} = ', style: poppins),
              Text('${s.value}', style: poppins.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 4: Arrange the fractions according to their values: ', style: poppins.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
            ...[
              for (int i = 0; i < _orderedFractions!.length; i++) ...[
                FractionDisplay(
                  numerator: _orderedFractions![i].numerator,
                  denominator: _orderedFractions![i].denominator,
                  fontSize: 18,
                  color: Colors.purple, fontFamily: 'Poppins',
                ),
                if (i != _orderedFractions!.length - 1)
                  orderType == OrderType.ascending
                      ? const Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 18)
                      : const Icon(Icons.arrow_back, color: Colors.deepPurple, size: 18),
              ]
            ],
            const SizedBox(width: 8),
            Text(
              orderType == OrderType.ascending ? "(Ascending order)" : "(Descending order)",
              style: poppins.copyWith(color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ];
    return stepWidgets;
  }

  Widget _stepsCard(List<Widget> steps, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: theme.cardColor.withOpacity(0.98),
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade50,
            child: Text('${idx + 1}',
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                )),
          ),
          title: steps[idx],
        ),
      ),
    );
  }
}