import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'circle_area_solver.dart';
import 'circle_area_models.dart';

class CircleAreaScreen extends StatefulWidget {
  const CircleAreaScreen({super.key});

  @override
  State<CircleAreaScreen> createState() => _CircleAreaScreenState();
}

class _CircleAreaScreenState extends State<CircleAreaScreen> {
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  CircleAreaResult? _result;

  String _selectedUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild to dynamically handle locking/unlocking fields
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final rText = _radiusController.text.trim();
    final dText = _diameterController.text.trim();
    final areaText = _areaController.text.trim();

    if (rText.isNotEmpty) {
      setState(() => _result = CircleAreaSolver.solveForAreaWithRadius(rText, _selectedUnit));
    } else if (dText.isNotEmpty) {
      setState(() => _result = CircleAreaSolver.solveForAreaWithDiameter(dText, _selectedUnit));
    } else if (areaText.isNotEmpty) {
      setState(() => _result = CircleAreaSolver.solveForRadius(areaText, _selectedUnit));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ONE value to solve.')),
      );
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _diameterController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count how many fields have text
    int filledCount = 0;
    if (_radiusController.text.trim().isNotEmpty) filledCount++;
    if (_diameterController.text.trim().isNotEmpty) filledCount++;
    if (_areaController.text.trim().isNotEmpty) filledCount++;

    // A field is enabled if it is the ONE field that has text, OR if NO fields have text yet
    final bool isRadiusEnabled = _radiusController.text.trim().isNotEmpty || filledCount == 0;
    final bool isDiameterEnabled = _diameterController.text.trim().isNotEmpty || filledCount == 0;
    final bool isAreaEnabled = _areaController.text.trim().isNotEmpty || filledCount == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Area of a Circle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational Card
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '💡 For a circle, Area is calculated using the constant \\pi (pi) and the radius (r). If you are given the diameter (d), remember that radius is half of the diameter!',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _radiusController,
                    enabled: isRadiusEnabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onInputChanged,
                    decoration: InputDecoration(
                      labelText: "Enter Radius (r)",
                      hintText: "e.g. 5",
                      filled: !isRadiusEnabled,
                      fillColor: isRadiusEnabled ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _units.map((String unit) {
                      return DropdownMenuItem<String>(value: unit, child: Text(unit));
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

            // "OR" Divider
            Center(
              child: Text("— OR —", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _diameterController,
              enabled: isDiameterEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Diameter (d)",
                hintText: "e.g. 10",
                filled: !isDiameterEnabled,
                fillColor: isDiameterEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text("— OR —", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _areaController,
              enabled: isAreaEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Area (A) in $_selectedUnit²",
                hintText: "e.g. 78.54",
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