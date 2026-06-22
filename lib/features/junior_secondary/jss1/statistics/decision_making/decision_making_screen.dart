// lib/features/junior_secondary/jss1/statistics/decision_making/decision_making_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'decision_making_solver.dart';
import 'decision_making_models.dart';

class DecisionMakingScreen extends StatefulWidget {
  const DecisionMakingScreen({super.key});

  @override
  State<DecisionMakingScreen> createState() => _DecisionMakingScreenState();
}

class _DecisionMakingScreenState extends State<DecisionMakingScreen> {
  bool _isRawMode = true; // True = Raw Data, False = Tabular Data

  // Raw Data Controller
  final TextEditingController _rawController = TextEditingController();

  // Tabular Data Controllers
  final TextEditingController _xHeadController = TextEditingController(text: "Score");
  final TextEditingController _fHeadController = TextEditingController(text: "Frequency");
  final List<Map<String, TextEditingController>> _tableRows = [];

  // Interpretation Dropdown
  final List<String> _interpretations = ['Mode', 'Mean', 'Median', 'Range'];
  String _selectedInterp = 'Mean';

  StatisticsResult? _result;

  @override
  void initState() {
    super.initState();
    // Initialize with 3 empty rows for Tabular Mode
    _addRow(); _addRow(); _addRow();
  }

  void _addRow() {
    setState(() {
      _tableRows.add({'x': TextEditingController(), 'f': TextEditingController()});
      _result = null;
    });
  }

  void _removeRow(int index) {
    if (_tableRows.length > 1) {
      setState(() {
        _tableRows[index]['x']!.dispose();
        _tableRows[index]['f']!.dispose();
        _tableRows.removeAt(index);
        _result = null;
      });
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<FreqRow> parsedData = [];

    if (_isRawMode) {
      String rawText = _rawController.text.trim();
      if (rawText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter raw data.')));
        return;
      }
      var res = DecisionMakingSolver.parseRawData(rawText);
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid data format. Use numbers separated by commas or spaces.')));
        return;
      }
      parsedData = res;
    } else {
      // Tabular Mode Parsing
      for (var row in _tableRows) {
        String xTxt = row['x']!.text.trim();
        String fTxt = row['f']!.text.trim();
        if (xTxt.isNotEmpty && fTxt.isNotEmpty) {
          double? xVal = double.tryParse(xTxt);
          int? fVal = int.tryParse(fTxt);
          if (xVal != null && fVal != null && fVal >= 0) {
            parsedData.add(FreqRow(x: xVal, f: fVal));
          }
        }
      }
      if (parsedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in at least one valid row.')));
        return;
      }
    }

    String xH = _isRawMode ? "Data (x)" : _xHeadController.text.trim().isEmpty ? "Data (x)" : _xHeadController.text.trim();
    String fH = _isRawMode ? "Frequency (f)" : _fHeadController.text.trim().isEmpty ? "Frequency (f)" : _fHeadController.text.trim();

    // UPDATED: Now passing isRawMode and rawText to the solver!
    setState(() => _result = DecisionMakingSolver.solve(
        parsedData,
        _selectedInterp,
        xH,
        fH,
        isRawMode: _isRawMode,
        rawText: _isRawMode ? _rawController.text.trim() : null
    ));
  }

  @override
  void dispose() {
    _rawController.dispose();
    _xHeadController.dispose(); _fHeadController.dispose();
    for (var row in _tableRows) { row['x']!.dispose(); row['f']!.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics & Decision Making', style: TextStyle(fontSize: 18))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTERPRETATION DROP-DOWN
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.blue), const SizedBox(width: 12),
                  const Expanded(child: Text("What do you want to find?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedInterp, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: _interpretations.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) { if (val != null) setState(() { _selectedInterp = val; _result = null; }); },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DUAL-MODE TOGGLE
            Container(
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.shade200)),
              child: SwitchListTile(
                title: Text("Use Pre-Organized Table", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontFamily: 'Poppins')),
                subtitle: const Text("Turn this ON if the textbook gives you a table. Leave OFF to type a messy list of raw numbers.", style: TextStyle(fontSize: 12)),
                value: !_isRawMode, activeThumbColor: Colors.deepPurple,
                onChanged: (bool val) => setState(() { _isRawMode = !val; _result = null; }),
              ),
            ),
            const SizedBox(height: 24),

            // === MODE A: RAW DATA INPUT ===
            if (_isRawMode) ...[
              Text("Raw Unorganized Data:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              TextField(
                controller: _rawController, maxLines: 4,
                decoration: InputDecoration(hintText: "e.g. 12, 14, 15, 12, 13, 14, 12", filled: true, fillColor: Colors.grey.shade50, border: const OutlineInputBorder()),
                onChanged: (v) => setState((){ _result = null; }),
              ),
            ]
            // === MODE B: TABULAR INPUT ===
            else ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: _xHeadController, decoration: const InputDecoration(labelText: "Column 1 Header", hintText: "e.g. Age"), onChanged: (v) => setState((){}))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _fHeadController, decoration: const InputDecoration(labelText: "Column 2 Header", hintText: "e.g. Frequency"), onChanged: (v) => setState((){}))),
                ],
              ),
              const SizedBox(height: 16),
              ..._tableRows.asMap().entries.map((entry) {
                int idx = entry.key; var row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: row['x'], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: "Data value", filled: true))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: row['f'], keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Frequency", filled: true))),
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeRow(idx))
                    ],
                  ),
                );
              }),
              TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text("Add Row")),
            ],

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Generate & Solve"))),
            const SizedBox(height: 24),

            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    // 1. DYNAMICALLY CALCULATE TOTALS FOR THE TABLE
    int totalF = 0;
    double totalFx = 0;
    if (_result!.tableData != null) {
      for (var row in _result!.tableData!) {
        totalF += row.f;
        totalFx += row.fx;
      }
    }

    // 2. BUILD THE STANDARD ROWS
    List<DataRow> tableRows = _result!.tableData!.map((row) {
      return DataRow(cells: [
        DataCell(Text((row.x == row.x.truncateToDouble() ? row.x.toInt() : row.x).toString())),
        DataCell(Text(DecisionMakingSolver.generateTally(row.f), style: const TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold))),
        DataCell(Text(row.f.toString())),
        if (_result!.showFxColumn) DataCell(Text((row.fx == row.fx.truncateToDouble() ? row.fx.toInt() : row.fx).toString())),
      ]);
    }).toList();

    // 3. APPEND THE TOTAL ROW (Highlighted & Bold)
    tableRows.add(
      DataRow(
        color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) => Colors.deepPurple.shade50),
        cells: [
          const DataCell(Text("Total (Σ)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
          const DataCell(Text("")), // Empty tally for total
          DataCell(Text(totalF.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
          if (_result!.showFxColumn)
            DataCell(Text((totalFx == totalFx.truncateToDouble() ? totalFx.toInt() : totalFx).toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GENERATED FREQUENCY TABLE
        Text("Generated Frequency Table:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: [
                DataColumn(label: Text(_result!.xHeader, style: const TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text("Tally", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(_result!.fHeader, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (_result!.showFxColumn) const DataColumn(label: Text("fx (Data × Freq)", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
              ],
              rows: tableRows,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // FINAL ANSWER
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _result!.finalAnswerLaTeX.split(r'\\').map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Math.tex(line.trim(), textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins'))
                )).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // WORKINGS
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50, margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // NEW: We apply the .where() filter so pure explanations don't render here!
              children: _result!.steps.where((s) => s.showInWorkings).map((s) => Center(
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900)))
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // STEP-BY-STEP BREAKDOWN
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