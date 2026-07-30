import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'standard_form_logic.dart';
import 'standard_form_models.dart';

class StandardFormScreen extends StatefulWidget {
  const StandardFormScreen({super.key});

  @override
  State<StandardFormScreen> createState() => _StandardFormScreenState();
}

class _StandardFormScreenState extends State<StandardFormScreen> {

  int _selectedMode = 0; // 0 = Ordinary to Standard, 1 = Standard to Ordinary

  final TextEditingController _ordinaryController = TextEditingController();
  final TextEditingController _coeffController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

  StandardFormResult? _result;

  @override
  void dispose() {
    _ordinaryController.dispose();
    _coeffController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    setState(() {
      _result = null;
      if (_selectedMode == 0) {
        if (_ordinaryController.text.isEmpty) {
          _showError('Please enter an ordinary number.');
          return;
        }
        _result = StandardFormSolver.convertToStandardForm(_ordinaryController.text);
      } else {
        if (_coeffController.text.isEmpty || _powerController.text.isEmpty) {
          _showError('Please enter both the coefficient and the power.');
          return;
        }
        _result = StandardFormSolver.convertToOrdinaryForm(
            _coeffController.text,
            _powerController.text
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Standard Form Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLegendCard(theme),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Ordinary \u2192 Standard", style: TextStyle(fontWeight: FontWeight.bold))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Standard \u2192 Ordinary", style: TextStyle(fontWeight: FontWeight.bold))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _result = null; // Clear previous results
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),

            const SizedBox(height: 24),
            _buildInputSection(theme),

            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _solve,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.deepPurple[50],
                    //foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                ),
                child: const Text("Convert", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Standard Form Rule",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Math.tex(
              r'A \times 10^n',
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Math.tex(
              r'1 \le A < 10',
              textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              "where 'A' is the Coefficient and 'n' is an integer.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 24),
            _buildPowersTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPowersTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(r'10^6', '1,000,000', 'Million', isHeader: true),
        _buildTableRow(r'10^3', '1,000', 'Thousand'),
        _buildTableRow(r'10^2', '100', 'Hundred'),
        _buildTableRow(r'10^1', '10', 'Ten'),
        _buildTableRow(r'10^0', '1', 'Unit'),
        _buildTableRow(r'10^{-1}', '0.1', 'Tenth'),
        _buildTableRow(r'10^{-2}', '0.01', 'Hundredth'),
        _buildTableRow(r'10^{-3}', '0.001', 'Thousandth'),
      ],
    );
  }

  TableRow _buildTableRow(String mathStr, String number, String name, {bool isHeader = false}) {
    final textColor = isHeader ? Colors.black87 : Colors.black54;
    final weight = isHeader ? FontWeight.bold : FontWeight.normal;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Math.tex(mathStr, textStyle: TextStyle(fontSize: 14, color: textColor, fontWeight: weight)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(number, style: TextStyle(fontSize: 13, color: textColor, fontWeight: weight)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(name, style: TextStyle(fontSize: 13, color: textColor, fontWeight: weight)),
        ),
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    if (_selectedMode == 0) {
      return TextField(
        controller: _ordinaryController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(
          labelText: "Ordinary Number",
          hintText: "e.g. 3600000 or 0.0045",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.numbers, color: Colors.deepPurple),
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _coeffController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: "Coefficient (A)",
                hintText: "e.g. 3.6",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Math.tex(r'\times 10', textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _powerController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                labelText: "Power (n)",
                hintText: "e.g. 7",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Math.tex(
                        _result!.finalAnswerLaTeX,
                        textStyle: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                    ),
                  )
              )
          ),
        ),

        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          i == 0 ? _result!.steps[i].workingLaTeX : '= ${_result!.steps[i].workingLaTeX}',
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple, fontFamily: 'Poppins')
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Step-by-step Explanation:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key+1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: _buildExplanationText(e.value.explanation),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Math.tex(
                    e.key == 0 ? e.value.workingLaTeX : '= ${e.value.workingLaTeX}',
                    textStyle: const TextStyle(fontSize: 16)
                ),
              ),
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildExplanationText(String text) {
    final parts = text.split('\$');
    if (parts.length <= 1) {
      return Text(text, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic));
    }

    List<Widget> children = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Math.tex(parts[i], textStyle: const TextStyle(fontSize: 14, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ));
      } else if (parts[i].isNotEmpty) {
        children.add(Text(parts[i], style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}