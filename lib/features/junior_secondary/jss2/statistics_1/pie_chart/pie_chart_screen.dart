import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pie_chart_solver.dart';
import 'pie_chart_models.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  final TextEditingController _inputController = TextEditingController();

  // Dynamic Table Controllers
  final List<TextEditingController> _labelControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
  final List<TextEditingController> _freqControllers = [TextEditingController(), TextEditingController(), TextEditingController()];

  bool _isTableFormat = false;
  PieChartResult? _result;

  // A vibrant, kid-friendly palette for the pie slices
  final List<Color> _pieColors = [
    Colors.pink, Colors.blue, Colors.orange, Colors.teal,
    Colors.deepPurple, Colors.red, Colors.amber.shade700, Colors.indigo,
    Colors.green, Colors.cyan, Colors.purpleAccent, Colors.brown
  ];

  @override
  void dispose() {
    _inputController.dispose();
    for (var c in _labelControllers) { c.dispose(); }
    for (var c in _freqControllers) { c.dispose(); }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _labelControllers.add(TextEditingController());
      _freqControllers.add(TextEditingController());
    });
  }

  void _removeRow(int index) {
    setState(() {
      _labelControllers[index].dispose();
      _freqControllers[index].dispose();
      _labelControllers.removeAt(index);
      _freqControllers.removeAt(index);
    });
  }

  void _generateChart() {
    FocusScope.of(context).unfocus();

    String inputData = "";

    if (_isTableFormat) {
      List<String> validPairs = [];
      for (int i = 0; i < _labelControllers.length; i++) {
        String label = _labelControllers[i].text.trim();
        String freq = _freqControllers[i].text.trim();
        if (label.isNotEmpty && freq.isNotEmpty) {
          validPairs.add("$label: $freq");
        }
      }
      inputData = validPairs.join("\n");
    } else {
      inputData = _inputController.text;
    }

    if (inputData.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter some data.')));
      return;
    }

    setState(() {
      _result = PieChartSolver.processData(inputData, _isTableFormat);
    });
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<bool>(
            groupValue: _isTableFormat,
            children: const {
              false: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Raw Data", style: TextStyle(fontWeight: FontWeight.bold))),
              true: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Table Data", style: TextStyle(fontWeight: FontWeight.bold))),
            },
            onValueChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  _isTableFormat = value;
                  _result = null;
                });
              }
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),
        if (!_isTableFormat)
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.text,
            maxLines: 4,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: "Raw Data (e.g., Red, Blue, Red)",
              hintText: "Format: Items separated by commas or spaces",
              prefixIcon: const Icon(Icons.pie_chart, color: Colors.deepPurple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(child: Text("Item / Category", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                    SizedBox(width: 12),
                    Expanded(child: Text("Frequency", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                    SizedBox(width: 48), // Space for the delete button
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(_labelControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _labelControllers[index],
                            decoration: InputDecoration(
                              hintText: "e.g. Red",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _freqControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g. 5",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: _labelControllers.length > 1 ? () => _removeRow(index) : null,
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  label: const Text("Add Row", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFrequencyTable(ThemeData theme) {
    if (_result == null || !_result!.valid) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade50),
            columnSpacing: 24,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              DataColumn(label: Text('Freq', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), numeric: true),
              DataColumn(label: Text('Angle Calculation (Sector)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
            ],
            rows: [
              ..._result!.tableRows.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row.label, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(row.frequency.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  DataCell(Text(row.workingString, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87))),
                ]);
              }),
              // Total Row
              DataRow(
                  color: WidgetStateProperty.all(Colors.grey.shade100),
                  cells: [
                    const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                    DataCell(Text(_result!.totalFrequency.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple))),
                    const DataCell(Text('360°', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple))),
                  ])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _result!.tableRows.asMap().entries.map((entry) {
        int index = entry.key;
        PieChartRow row = entry.value;
        Color color = _pieColors[index % _pieColors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text('${row.label} (${_fmt(row.degree)}°)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChartArea(ThemeData theme) {
    if (_result == null || !_result!.valid || _result!.tableRows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Pie Chart Visualization:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
        const SizedBox(height: 12),

        // The Legend
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _buildLegend(theme),
        ),

        const SizedBox(height: 24),

        // The Canvas
        Container(
          width: double.infinity,
          height: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade100),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: CustomPaint(
            painter: PieChartPainter(
              rows: _result!.tableRows,
              colors: _pieColors,
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pie Chart Plotter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Visualize your data using a Pie Chart! See how each item takes up a slice of the 360° circle.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            _buildInputSection(theme),

            const SizedBox(height: 20),

            // Forced Deep Purple Button Styling
            ElevatedButton.icon(
              onPressed: _generateChart,
              icon: const Icon(Icons.pie_chart_outline, color: Colors.white),
              label: const Text("Plot Pie Chart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) ...[
              const SizedBox(height: 32),

              const Text("1. Frequency & Angle Table:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              _buildFrequencyTable(theme),

              const SizedBox(height: 32),

              const Text("2. Pie Chart:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              _buildChartArea(theme),

              const SizedBox(height: 32),

              const Text("3. Data Interpretation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _result!.interpretations.map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 22),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text("4. Step-by-Step Process:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              ..._result!.steps.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.deepPurple,
                    child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(e.value.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(e.value.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4)),
                  ),
                ),
              )),

              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }
}

/// A highly optimized custom painter to draw a professional, kid-friendly Pie Chart
class PieChartPainter extends CustomPainter {
  final List<PieChartRow> rows;
  final List<Color> colors;

  PieChartPainter({
    required this.rows,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    // Determine the center and radius of the pie chart
    final double radius = min(size.width / 2, size.height / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Start drawing from the top of the circle (-90 degrees)
    double startAngle = -pi / 2;

    for (int i = 0; i < rows.length; i++) {
      PieChartRow row = rows[i];
      Color sliceColor = colors[i % colors.length];

      // Convert degree to radians for Flutter's drawArc
      double sweepAngle = row.degree * (pi / 180);

      // Draw the colored slice
      final Paint slicePaint = Paint()
        ..color = sliceColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, slicePaint);

      // Draw a white border around each slice to make it pop
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      // Draw text label inside the slice if it's large enough (e.g., > 15 degrees)
      if (row.degree > 15) {
        double midAngle = startAngle + (sweepAngle / 2);
        // Position the text about 65% of the way to the edge
        double labelRadius = radius * 0.65;

        double x = center.dx + labelRadius * cos(midAngle);
        double y = center.dy + labelRadius * sin(midAngle);

        String displayDegree = row.degree == row.degree.toInt()
            ? row.degree.toInt().toString()
            : row.degree.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

        TextPainter tp = TextPainter(
          text: TextSpan(
              text: '$displayDegree°',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))] // Add shadow for readability
              )
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        tp.layout();
        // Paint the text centered on the calculated coordinate
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}