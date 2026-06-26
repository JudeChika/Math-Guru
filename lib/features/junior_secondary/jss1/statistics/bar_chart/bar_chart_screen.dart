// lib/features/junior_secondary/jss1/statistics/bar_chart/bar_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'bar_chart_solver.dart';
import 'bar_chart_models.dart';

class BarChartScreen extends StatefulWidget {
  const BarChartScreen({super.key});

  @override
  State<BarChartScreen> createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  bool _isRawMode = true;

  final TextEditingController _rawController = TextEditingController();
  final TextEditingController _xHeadController = TextEditingController(text: "Category");
  final TextEditingController _yHeadController = TextEditingController(text: "Frequency");

  List<Map<String, TextEditingController>> _tableRows = [];
  BarChartResult? _result;

  @override
  void initState() {
    super.initState();
    _addRow(); _addRow(); _addRow();
  }

  void _addRow() {
    setState(() {
      _tableRows.add({'cat': TextEditingController(), 'freq': TextEditingController()});
      _result = null;
    });
  }

  void _removeRow(int index) {
    if (_tableRows.length > 1) {
      setState(() {
        _tableRows[index]['cat']!.dispose();
        _tableRows[index]['freq']!.dispose();
        _tableRows.removeAt(index);
        _result = null;
      });
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<CategoryData> parsedData = [];

    if (_isRawMode) {
      String rawText = _rawController.text.trim();
      if (rawText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter raw data.')));
        return;
      }
      var res = BarChartSolver.parseRawData(rawText);
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid data. Ensure items are separated by commas.')));
        return;
      }
      parsedData = res;
    } else {
      for (var row in _tableRows) {
        String catTxt = row['cat']!.text.trim();
        String freqTxt = row['freq']!.text.trim();
        if (catTxt.isNotEmpty && freqTxt.isNotEmpty) {
          int? fVal = int.tryParse(freqTxt);
          if (fVal != null && fVal >= 0) {
            parsedData.add(CategoryData(category: catTxt, frequency: fVal));
          }
        }
      }
      if (parsedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in at least one valid row.')));
        return;
      }
    }

    String xH = _isRawMode ? "Categories" : _xHeadController.text.trim().isEmpty ? "Categories" : _xHeadController.text.trim();
    String yH = _isRawMode ? "Frequency" : _yHeadController.text.trim().isEmpty ? "Frequency" : _yHeadController.text.trim();

    setState(() => _result = BarChartSolver.solve(parsedData, xH, yH, isRawMode: _isRawMode));
  }

  @override
  void dispose() {
    _rawController.dispose();
    _xHeadController.dispose(); _yHeadController.dispose();
    for (var row in _tableRows) { row['cat']!.dispose(); row['freq']!.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bar Chart Plotter', style: TextStyle(fontSize: 18))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.shade200)),
              child: SwitchListTile(
                title: Text("Use Pre-Organized Table", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontFamily: 'Poppins')),
                subtitle: const Text("Turn ON if you have categories and frequencies. Leave OFF to type a messy list of words.", style: TextStyle(fontSize: 12)),
                value: !_isRawMode, activeColor: Colors.deepPurple,
                onChanged: (bool val) => setState(() { _isRawMode = !val; _result = null; }),
              ),
            ),
            const SizedBox(height: 24),

            if (_isRawMode) ...[
              Text("Raw Unorganized Data:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              TextField(
                controller: _rawController, maxLines: 4,
                decoration: InputDecoration(hintText: "e.g. Red, Blue, Green, Red, Yellow, Blue, Red", filled: true, fillColor: Colors.grey.shade50, border: const OutlineInputBorder()),
                onChanged: (v) => setState((){ _result = null; }),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: _xHeadController, decoration: const InputDecoration(labelText: "X-Axis (Category)", hintText: "e.g. Colors"), onChanged: (v) => setState((){}))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _yHeadController, decoration: const InputDecoration(labelText: "Y-Axis (Frequency)", hintText: "e.g. No. of Cars"), onChanged: (v) => setState((){}))),
                ],
              ),
              const SizedBox(height: 16),
              ..._tableRows.asMap().entries.map((entry) {
                int idx = entry.key; var row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: row['cat'], decoration: const InputDecoration(hintText: "Category (e.g. Red)", filled: true))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: row['freq'], keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Frequency", filled: true))),
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeRow(idx))
                    ],
                  ),
                );
              }),
              TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text("Add Row")),
            ],

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Plot Bar Chart"))),
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
        // 1. GENERATED SCROLLABLE NATIVE BAR CHART
        Text("Final Bar Chart:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        _buildNativeChart(),
        const SizedBox(height: 24),

        // 2. WORKINGS
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50, margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _result!.steps.where((s) => s.showInWorkings).map((s) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: s.workingLaTeX.split(r'\\').map((line) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Math.tex(line.trim(), textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900)),
                      )).toList(),
                    ),
                  )
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. STEP-BY-STEP BREAKDOWN
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((entry) {
          int idx = entry.key; var step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: step.workingLaTeX.split(r'\\').map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Math.tex(line.trim()),
                  )).toList(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- THE SCROLLABLE NATIVE CHART RENDERER ---
  Widget _buildNativeChart() {
    int yMax = _result!.maxFrequency;
    int step = _result!.yAxisStep;
    List<CategoryData> data = _result!.chartData!;

    // Generate Y-Axis Labels (Top to Bottom)
    List<Widget> yLabels = [];
    for (int i = yMax; i >= 0; i -= step) {
      yLabels.add(
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Text(i.toString(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
          )
      );
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Y-Axis Title
            Text(_result!.yAxisLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
            const SizedBox(height: 16),

            // Layout Split: Fixed Y-Axis vs Scrollable Plot Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FIXED Y-AXIS LABELS
                SizedBox(
                  width: 30,
                  height: 250, // Matches plot height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yLabels,
                  ),
                ),
                const SizedBox(width: 8),

                // 2. SCROLLABLE PLOT AND X-AXIS LABELS
                Expanded(
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Minimum 60px width per bar guarantees it never chokes!
                        double requiredWidth = data.length * 60.0;
                        double chartWidth = math.max(constraints.maxWidth, requiredWidth);

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: chartWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // --- PLOT AREA ---
                                SizedBox(
                                  height: 250,
                                  child: Stack(
                                    children: [
                                      // Grid Lines
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate((yMax ~/ step) + 1, (index) => const Divider(color: Colors.black12, height: 1)),
                                      ),
                                      // Bars
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: data.map((d) {
                                          double heightRatio = d.frequency / yMax;
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6.0), // The Gap
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(d.frequency.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                                  const SizedBox(height: 4),
                                                  Flexible(
                                                    child: LayoutBuilder(
                                                        builder: (ctx, barConstraints) {
                                                          return Container(
                                                            height: barConstraints.maxHeight * heightRatio,
                                                            decoration: BoxDecoration(
                                                              color: Colors.green.shade400,
                                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                                            ),
                                                          );
                                                        }
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),

                                // --- BASELINE ---
                                Container(height: 2, color: Colors.black),
                                const SizedBox(height: 8),

                                // --- X-AXIS LABELS ---
                                Row(
                                  children: data.map((d) {
                                    return Expanded(
                                        child: Text(
                                          d.category,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // X-Axis Title
            Text(_result!.xAxisLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
          ],
        ),
      ),
    );
  }
}