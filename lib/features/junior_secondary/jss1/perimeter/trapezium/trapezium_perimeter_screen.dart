import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'trapezium_perimeter_solver.dart';
import 'trapezium_perimeter_models.dart';

class TrapeziumPerimeterScreen extends StatefulWidget {
  const TrapeziumPerimeterScreen({super.key});

  @override
  State<TrapeziumPerimeterScreen> createState() => _TrapeziumPerimeterScreenState();
}

class _TrapeziumPerimeterScreenState extends State<TrapeziumPerimeterScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  final TextEditingController _dController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  GeometryResult? _result;

  void _onChanged(_) => setState(() {});

  void _solve() {
    FocusScope.of(context).unfocus();
    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);
    double? c = double.tryParse(_cController.text);
    double? d = double.tryParse(_dController.text);
    double? p = double.tryParse(_pController.text);

    setState(() {
      _result = null; // Force refresh
      if (a != null && b != null && c != null && d != null) {
        _result = TrapeziumPerimeterSolver.solveForPerimeter(a, b, c, d);
      } else if (p != null && b != null && c != null && d != null) {
        _result = TrapeziumPerimeterSolver.solveForSideA(p, b, c, d);
      } else if (p != null && a != null && c != null && d != null) {
        _result = TrapeziumPerimeterSolver.solveForSideB(p, a, c, d);
      } else if (p != null && a != null && b != null && d != null) {
        _result = TrapeziumPerimeterSolver.solveForSideC(p, a, b, d);
      } else if (p != null && a != null && b != null && c != null) {
        _result = TrapeziumPerimeterSolver.solveForSideD(p, a, b, c);
      }
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _dController.dispose();
    _pController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Locking logic: enable field ONLY IF fewer than 4 fields are filled OR if this field itself is already filled.
    int filledFields = [
      _aController.text,
      _bController.text,
      _cController.text,
      _dController.text,
      _pController.text
    ].where((s) => s.isNotEmpty).length;

    bool canFill = filledFields < 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Trapezium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _aController, onChanged: _onChanged, enabled: canFill || _aController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side a")),
            const SizedBox(height: 16),
            TextField(controller: _bController, onChanged: _onChanged, enabled: canFill || _bController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side b")),
            const SizedBox(height: 16),
            TextField(controller: _cController, onChanged: _onChanged, enabled: canFill || _cController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side c")),
            const SizedBox(height: 16),
            TextField(controller: _dController, onChanged: _onChanged, enabled: canFill || _dController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side d")),
            const SizedBox(height: 16),
            TextField(controller: _pController, onChanged: _onChanged, enabled: canFill || _pController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Perimeter (P)")),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            if (_result != null) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Math.tex(_result!.finalAnswerLaTeX, textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))
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
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _result!.steps.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(s.workingLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontFamily: 'Poppins')),
                ),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('${e.key+1}')),
            title: Text(e.value.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(e.value.workingLaTeX),
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}