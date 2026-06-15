import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'rectangle_area_solver.dart';
import 'rectangle_area_models.dart';

class RectangleAreaScreen extends StatefulWidget {
  const RectangleAreaScreen({super.key});

  @override
  State<RectangleAreaScreen> createState() => _RectangleAreaScreenState();
}

class _RectangleAreaScreenState extends State<RectangleAreaScreen> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _breadthController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  RectangleAreaResult? _result;

  String _selectedUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  void _onInputChanged(String value) {
    // Trigger a rebuild to dynamically lock/unlock fields based on what is populated
    setState(() {});
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final lText = _lengthController.text.trim();
    final bText = _breadthController.text.trim();
    final aText = _areaController.text.trim();

    if (lText.isNotEmpty && bText.isNotEmpty) {
      setState(() => _result = RectangleAreaSolver.solveForArea(lText, bText, _selectedUnit));
    } else if (aText.isNotEmpty && bText.isNotEmpty) {
      setState(() => _result = RectangleAreaSolver.solveForLength(aText, bText, _selectedUnit));
    } else if (aText.isNotEmpty && lText.isNotEmpty) {
      setState(() => _result = RectangleAreaSolver.solveForBreadth(aText, lText, _selectedUnit));
    } else {
      // Show a snackbar if less than 2 fields are filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter any two values to solve.')),
      );
    }
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _breadthController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A field remains enabled as long as ALL THREE fields aren't competing.
    // If the *other two* fields are filled, disable this one.
    final bool isLengthEnabled = !(_areaController.text.isNotEmpty && _breadthController.text.isNotEmpty);
    final bool isBreadthEnabled = !(_areaController.text.isNotEmpty && _lengthController.text.isNotEmpty);
    final bool isAreaEnabled = !(_lengthController.text.isNotEmpty && _breadthController.text.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Area of a Rectangle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _lengthController,
                    enabled: isLengthEnabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onInputChanged,
                    decoration: InputDecoration(
                      labelText: "Enter Length (l)",
                      hintText: "e.g. 8",
                      filled: !isLengthEnabled,
                      fillColor: isLengthEnabled ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: _units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedUnit = newValue;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _breadthController,
              enabled: isBreadthEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Breadth (b)",
                hintText: "e.g. 4",
                filled: !isBreadthEnabled,
                fillColor: isBreadthEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              enabled: isAreaEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Area (A) in $_selectedUnit²",
                hintText: "e.g. 32",
                filled: !isAreaEnabled,
                fillColor: isAreaEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _solve, child: const Text("Solve")),
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
                      padding: const EdgeInsets.all(4),
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
              subtitle: Math.tex(step.workingLaTeX),
            ),
          );
        }),
      ],
    );
  }
}