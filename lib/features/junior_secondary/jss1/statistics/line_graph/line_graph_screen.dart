// lib/features/junior_secondary/jss1/statistics/line_graph/line_graph_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'line_graph_solver.dart';
import 'line_graph_models.dart';

class LineGraphScreen extends StatefulWidget {
  const LineGraphScreen({super.key});

  @override
  State<LineGraphScreen> createState() => _LineGraphScreenState();
}

class _LineGraphScreenState extends State<LineGraphScreen> {
  bool _isRawMode = false; // Tabular is default for Line Graphs

  final TextEditingController _rawController = TextEditingController();
  final TextEditingController _xHeadController = TextEditingController(text: "Time (e.g., Days)");
  final TextEditingController _yHeadController = TextEditingController(text: "Temperature (°C)");

  // Added a ScrollController to explicitly show the scrollbar on the chart
  final ScrollController _chartScrollController = ScrollController();

  List<Map<String, TextEditingController>> _tableRows = [];
  LineGraphResult? _result;

  @override
  void initState() {
    super.initState();
    _addRow(); _addRow(); _addRow(); _addRow(); // Start with 4 points to show a good line
  }

  void _addRow() {
    setState(() {
      _tableRows.add({'x': TextEditingController(), 'y': TextEditingController()});
      _result = null;
    });
  }

  void _removeRow(int index) {
    if (_tableRows.length > 1) {
      setState(() {
        _tableRows[index]['x']!.dispose();
        _tableRows[index]['y']!.dispose();
        _tableRows.removeAt(index);
        _result = null;
      });
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<PointData> parsedData = [];

    if (_isRawMode) {
      String rawText = _rawController.text.trim();
      if (rawText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter raw data.')));
        return;
      }
      var res = LineGraphSolver.parseRawData(rawText);
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid data. Ensure numbers are separated by commas.')));
        return;
      }
      parsedData = res;
    } else {
      for (var row in _tableRows) {
        String xTxt = row['x']!.text.trim();
        String yTxt = row['y']!.text.trim();
        if (xTxt.isNotEmpty && yTxt.isNotEmpty) {
          double? yVal = double.tryParse(yTxt);
          if (yVal != null) {
            parsedData.add(PointData(xLabel: xTxt, yValue: yVal));
          }
        }
      }
      if (parsedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in at least one valid row.')));
        return;
      }
    }

    String xH = _isRawMode ? "Progression" : _xHeadController.text.trim().isEmpty ? "X-Axis" : _xHeadController.text.trim();
    String yH = _isRawMode ? "Value" : _yHeadController.text.trim().isEmpty ? "Y-Axis" : _yHeadController.text.trim();

    setState(() => _result = LineGraphSolver.solve(parsedData, xH, yH, isRawMode: _isRawMode));
  }

  @override
  void dispose() {
    _rawController.dispose();
    _xHeadController.dispose(); _yHeadController.dispose();
    _chartScrollController.dispose();
    for (var row in _tableRows) { row['x']!.dispose(); row['y']!.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Line Graph Plotter', style: TextStyle(fontSize: 18))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.shade200)),
              child: SwitchListTile(
                title: Text("Use Pre-Organized Table", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontFamily: 'Poppins')),
                subtitle: const Text("Turn ON if you have specific labels (like Mon, Tue). Leave OFF to paste a list of numbers.", style: TextStyle(fontSize: 12)),
                value: !_isRawMode, activeColor: Colors.deepPurple,
                onChanged: (bool val) => setState(() { _isRawMode = !val; _result = null; }),
              ),
            ),
            const SizedBox(height: 24),

            if (_isRawMode) ...[
              Text("Sequential Data Values (Y-Axis):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              const SizedBox(height: 8),
              TextField(
                controller: _rawController, maxLines: 4,
                decoration: InputDecoration(hintText: "e.g. 15.5, 18.0, 22, 19, 14", filled: true, fillColor: Colors.grey.shade50, border: const OutlineInputBorder()),
                onChanged: (v) => setState((){ _result = null; }),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: _xHeadController, decoration: const InputDecoration(labelText: "X-Axis Label", hintText: "e.g. Days"), onChanged: (v) => setState((){}))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _yHeadController, decoration: const InputDecoration(labelText: "Y-Axis Label", hintText: "e.g. Rainfall (mm)"), onChanged: (v) => setState((){}))),
                ],
              ),
              const SizedBox(height: 16),
              ..._tableRows.asMap().entries.map((entry) {
                int idx = entry.key; var row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: row['x'], decoration: const InputDecoration(hintText: "X Label (e.g. Mon)", filled: true))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: row['y'], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: "Y Value (e.g. 15)", filled: true))),
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeRow(idx))
                    ],
                  ),
                );
              }),
              TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text("Add Coordinate Pair")),
            ],

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Plot Line Graph"))),
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
        // 1. GENERATED NATIVE LINE CHART
        Text("Final Line Graph:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        _buildNativeLineChart(),
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

  // --- THE SCROLLABLE NATIVE LINE CHART RENDERER ---
  Widget _buildNativeLineChart() {
    int yMax = _result!.maxYValue.toInt();
    int step = _result!.yAxisStep;
    List<PointData> data = _result!.chartData!;

    // Generate Y-Axis Labels
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
            Text(_result!.yAxisLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-Axis Labels
                SizedBox(
                  width: 40, // Increased width slightly to prevent clipping of large numbers
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yLabels,
                  ),
                ),
                const SizedBox(width: 8),

                // Scrollable Plot Area
                Expanded(
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        // INCREASED: Minimum 80px width per data point guarantees plenty of breathing room!
                        double requiredWidth = data.length * 80.0;
                        double chartWidth = math.max(constraints.maxWidth, requiredWidth);

                        // ADDED: Explicit Scrollbar to indicate horizontally scrollable content
                        return Scrollbar(
                          controller: _chartScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _chartScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: chartWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // PLOT AREA (Grid + Lines + Dots)
                                  SizedBox(
                                    height: 250,
                                    child: CustomPaint(
                                      size: Size(chartWidth, 250),
                                      painter: _LineChartPainter(
                                        data: data,
                                        maxY: _result!.maxYValue,
                                        yStep: step,
                                      ),
                                    ),
                                  ),

                                  // X-AXIS BASELINE
                                  Container(height: 2, color: Colors.black),
                                  const SizedBox(height: 8),

                                  // X-AXIS LABELS
                                  Row(
                                    children: data.map((d) {
                                      return Expanded(
                                          child: Text(
                                            d.xLabel,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8), // Padding below the labels for the scrollbar
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_result!.xAxisLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
          ],
        ),
      ),
    );
  }
}

// ========================================================
// THE CORE ENGINE: NATIVE LINE GRAPH CUSTOM PAINTER
// ========================================================
class _LineChartPainter extends CustomPainter {
  final List<PointData> data;
  final double maxY;
  final int yStep;

  _LineChartPainter({required this.data, required this.maxY, required this.yStep});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid Lines (Horizontal)
    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1.0;

    int numSteps = (maxY / yStep).ceil();
    for (int i = 0; i <= numSteps; i++) {
      double y = size.height - (i * yStep / maxY) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    // 2. Calculate point coordinates
    double xInterval = size.width / data.length;
    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      double x = (i * xInterval) + (xInterval / 2);
      double y = size.height - ((data[i].yValue / maxY) * size.height);
      points.add(Offset(x, y));
    }

    // 3. Draw Connecting Lines
    final linePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // 4. Draw Coordinates (Dots)
    final dotOuterPaint = Paint()..color = Colors.green.shade600;
    final dotInnerPaint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6.0, dotOuterPaint);
      canvas.drawCircle(points[i], 3.0, dotInnerPaint);

      final textSpan = TextSpan(
        text: data[i].yValue.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""),
        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();

      Offset textOffset = Offset(
        points[i].dx - (textPainter.width / 2),
        points[i].dy - 20,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.maxY != maxY;
  }
}