import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'geometry_angles_solver.dart';
import 'geometry_angles_models.dart';

class GeometryAnglesScreen extends StatefulWidget {
  const GeometryAnglesScreen({super.key});

  @override
  State<GeometryAnglesScreen> createState() => _GeometryAnglesScreenState();
}

class _GeometryAnglesScreenState extends State<GeometryAnglesScreen> {
  final Map<String, dynamic> _theorems = {
    'Straight Line': {'type': 'sum', 'target': 180.0, 'desc': 'Angles on a straight line sum to 180°.'},
    'At a Point': {'type': 'sum', 'target': 360.0, 'desc': 'Angles around a point sum to 360°.'},
    'Complementary': {'type': 'sum', 'target': 90.0, 'desc': 'Complementary angles sum to 90°.'},
    'Supplementary': {'type': 'sum', 'target': 180.0, 'desc': 'Supplementary angles sum to 180°.'},
    'Triangle': {'type': 'sum', 'target': 180.0, 'desc': 'Sum of angles in a triangle is 180°.'},
    'Quadrilateral': {'type': 'sum', 'target': 360.0, 'desc': 'Sum of angles in a quadrilateral is 360°.'},
    'Vertically Opposite': {'type': 'equiv', 'desc': 'Vertically opposite angles are equal.'},
    'Alternate': {'type': 'equiv', 'desc': 'Alternate interior angles (Z-angles) are equal.'},
    'Corresponding': {'type': 'equiv', 'desc': 'Corresponding angles (F-angles) are equal.'},
  };

  String _selectedTheorem = 'Straight Line';

  final List<TextEditingController> _sumControllers = [TextEditingController(), TextEditingController()];
  final List<TextEditingController> _leftControllers = [TextEditingController()];
  final List<TextEditingController> _rightControllers = [TextEditingController()];

  GeometryAnglesResult? _result;

  void _addField(List<TextEditingController> list) {
    setState(() { list.add(TextEditingController()); _result = null; });
  }

  void _removeField(List<TextEditingController> list, int index) {
    if (list.length > 1) {
      setState(() {
        list[index].dispose();
        list.removeAt(index);
        _result = null;
      });
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    var rule = _theorems[_selectedTheorem];

    if (rule['type'] == 'sum') {
      List<String> inputs = _sumControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();
      if (inputs.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least two angles.')));
        return;
      }
      setState(() => _result = GeometryAnglesSolver.solveSummation(inputs, rule['target'], rule['desc']));
    } else {
      List<String> left = _leftControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();
      List<String> right = _rightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();
      if (left.isEmpty || right.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill both sides of the equation.')));
        return;
      }
      setState(() => _result = GeometryAnglesSolver.solveEquivalence(left, right, rule['desc']));
    }

    if (_result != null && !_result!.valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_result!.errorMessage ?? 'Error')));
    }
  }

  @override
  void dispose() {
    for (var c in _sumControllers) { c.dispose(); }
    for (var c in _leftControllers) { c.dispose(); }
    for (var c in _rightControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var rule = _theorems[_selectedTheorem];
    bool isSumMode = rule['type'] == 'sum';

    return Scaffold(
      appBar: AppBar(title: const Text('Geometric Angles')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTheorem,
              decoration: InputDecoration(labelText: 'Select Geometry Rule', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: _theorems.keys.map((String key) => DropdownMenuItem(value: key, child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              onChanged: (String? val) {
                if (val != null) setState(() { _selectedTheorem = val; _result = null; });
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0, color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      "💡 ${rule['desc']} Type exactly what you see in the diagram slices. You can use numbers (105), terms (4m), or mixed expressions (a + 20°).",
                      style: const TextStyle(color: Colors.blue)
                  )
              ),
            ),
            const SizedBox(height: 24),

            if (isSumMode) ...[
              Text("Angles in Diagram (Sum = ${rule['target']}°):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              ..._sumControllers.asMap().entries.map((entry) => _buildDynamicField(_sumControllers, entry.key, "Angle ${entry.key + 1}")),
              TextButton.icon(onPressed: () => _addField(_sumControllers), icon: const Icon(Icons.add), label: const Text("Add Another Angle")),
            ] else ...[
              Text("First Angle (Left Side):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              ..._leftControllers.asMap().entries.map((entry) => _buildDynamicField(_leftControllers, entry.key, "Term ${entry.key + 1}")),
              TextButton.icon(onPressed: () => _addField(_leftControllers), icon: const Icon(Icons.add), label: const Text("Add Term")),

              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: Text("EQUALS (=)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),

              Text("Second Angle (Right Side):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              ..._rightControllers.asMap().entries.map((entry) => _buildDynamicField(_rightControllers, entry.key, "Term ${entry.key + 1}")),
              TextButton.icon(onPressed: () => _addField(_rightControllers), icon: const Icon(Icons.add), label: const Text("Add Term")),
            ],

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Solve Equation"))),
            const SizedBox(height: 24),

            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(List<TextEditingController> list, int index, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: list[index],
              decoration: InputDecoration(labelText: label, hintText: "e.g. a + 20° or 4m", filled: true, fillColor: Colors.grey.shade50),
              onChanged: (v) => setState((){}),
            ),
          ),
          if (list.length > 1)
            IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeField(list, index))
        ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _result!.finalAnswerLaTeX.split(r'\\').map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Math.tex(line.trim(), textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins'))
                )).toList(),
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
          int idx = entry.key; var step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 8.0), child: Math.tex(step.workingLaTeX)),
            ),
          );
        }),
      ],
    );
  }
}