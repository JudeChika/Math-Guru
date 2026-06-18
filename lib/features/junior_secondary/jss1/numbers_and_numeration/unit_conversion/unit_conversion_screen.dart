import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'unit_conversion_solver.dart';
import 'unit_conversion_models.dart';

class UnitConversionScreen extends StatefulWidget {
  const UnitConversionScreen({super.key});

  @override
  State<UnitConversionScreen> createState() => _UnitConversionScreenState();
}

class _UnitConversionScreenState extends State<UnitConversionScreen> {
  final TextEditingController _valueController = TextEditingController();
  ConversionResult? _result;

  String _selectedCategory = 'Length';
  late String _fromUnit;
  late String _toUnit;

  // Retrieve the dynamically grouped keys directly from our solver map
  final List<String> _categories = UnitConversionSolver.unitData.keys.toList();

  @override
  void initState() {
    super.initState();
    _resetUnitsForCategory();
  }

  void _resetUnitsForCategory() {
    List<String> units = UnitConversionSolver.unitData[_selectedCategory]!.keys.toList();
    _fromUnit = units[0];
    _toUnit = units.length > 1 ? units[1] : units[0];
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
        _resetUnitsForCategory();
        _result = null;
      });
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    final text = _valueController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value.')));
      return;
    }

    double? val = double.tryParse(text);
    if (val == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid number.')));
      return;
    }

    setState(() {
      _result = UnitConversionSolver.solve(_selectedCategory, val, _fromUnit, _toUnit);
    });

    if (_result != null && !_result!.valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_result!.errorMessage!)));
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<String> currentUnits = UnitConversionSolver.unitData[_selectedCategory]!.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Unit Conversion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selector
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Measurement Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((String cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              onChanged: _onCategoryChanged,
            ),
            const SizedBox(height: 24),

            // Value and Units Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Value",
                      hintText: "e.g. 5.5",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _fromUnit,
                    decoration: InputDecoration(labelText: 'From', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setState(() { _fromUnit = val!; _result = null; }),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _toUnit,
                    decoration: InputDecoration(labelText: 'To', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setState(() { _toUnit = val!; _result = null; }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _solve,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Convert", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Math.tex(
                  _result!.finalAnswerLaTeX,
                  textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _result!.steps.map((s) => Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900))
                  )
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Math.tex(step.workingLaTeX),
              ),
            ),
          );
        }),
      ],
    );
  }
}