import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'bar_chart_solver.dart';
import 'bar_chart_models.dart';

class BarChartScreen extends StatefulWidget {
  const BarChartScreen({super.key});

  @override
  State<BarChartScreen> createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isTableFormat = false;
  BarChartResult? _result;

  // A vibrant, kid-friendly palette for the bars
  final List<Color> _barColors = [
    Colors.deepPurple, Colors.pink, Colors.orange, Colors.teal,
    Colors.blue, Colors.red, Colors.amber.shade700, Colors.indigo,
    Colors.green, Colors.cyan, Colors.purpleAccent, Colors.brown
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _generateChart() {
    FocusScope.of(context).unfocus();
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter some data.')));
      return;
    }
    setState(() {
      _result = BarChartSolver.processData(_inputController.text, _isTableFormat);
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
                  _inputController.clear();
                  _result = null;
                });
              }
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _inputController,
          keyboardType: TextInputType.text,
          maxLines: 4,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: _isTableFormat ? "Data (e.g., Apple: 5, Banana: 3)" : "Raw Data (e.g., Apple, Banana, Apple)",
            hintText: _isTableFormat ? "Format: Item: Frequency (separated by commas or new lines)" : "Format: Items separated by commas or spaces",
            prefixIcon: const Icon(Icons.dataset, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade50),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Item / Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
            DataColumn(label: Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), numeric: true),
          ],
          rows: _result!.tableRows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.label, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(row.frequency.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ]);
          }).toList(),
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
        BarChartRow row = entry.value;
        Color color = _barColors[index % _barColors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 6),
            Text(row.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
        const Text("Bar Chart Visualization:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
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

        const SizedBox(height: 16),

        // The Canvas
        Container(
          width: double.infinity,
          height: 280,
          padding: const EdgeInsets.only(top: 24, right: 16, bottom: 8), // Padding around the graph
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade100),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: CustomPaint(
            painter: BarChartPainter(
              rows: _result!.tableRows,
              maxFrequency: _result!.maxFrequency,
              colors: _barColors,
            ),
          ),
        ),
        const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("Items / Categories", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bar Chart Plotter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Visualize your data using a Bar Chart! Enter your numbers or words to see them turn into colorful blocks.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            _buildInputSection(theme),

            const SizedBox(height: 20),

            // Forced Deep Purple Button Styling
            ElevatedButton.icon(
              onPressed: _generateChart,
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: const Text("Plot Bar Chart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple, // Forces Deep Purple Background
                foregroundColor: Colors.white, // Forces White Ripple and Text
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

              const Text("1. Frequency Distribution Table:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              _buildFrequencyTable(theme),

              const SizedBox(height: 32),

              const Text("2. Bar Chart:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
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

/// A highly optimized custom painter to draw a professional, kid-friendly Bar Chart
class BarChartPainter extends CustomPainter {
  final List<BarChartRow> rows;
  final int maxFrequency;
  final List<Color> colors;

  BarChartPainter({
    required this.rows,
    required this.maxFrequency,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    // Define margins to leave room for text labels
    const double leftMargin = 40.0;
    const double bottomMargin = 30.0;
    final double graphWidth = size.width - leftMargin;
    final double graphHeight = size.height - bottomMargin;

    // 1. Draw Grid Lines and Y-Axis Labels
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    // Calculate a good scale step (e.g. going up by 1s, 2s, 5s, or 10s depending on max size)
    int ySteps = 5;
    if (maxFrequency <= 5) {
      ySteps = maxFrequency;
    } else if (maxFrequency <= 10) ySteps = 5;
    else if (maxFrequency <= 20) ySteps = 4;
    else ySteps = 5;

    int maxScaleValue = ((maxFrequency / ySteps).ceil() * ySteps);
    if (maxScaleValue < maxFrequency) maxScaleValue += ySteps;
    if (maxScaleValue == 0) maxScaleValue = 1;

    for (int i = 0; i <= ySteps; i++) {
      int labelValue = (maxScaleValue * (i / ySteps)).round();
      double yPos = graphHeight - (graphHeight * (labelValue / maxScaleValue));

      // Draw horizontal grid line
      if (i > 0) {
        canvas.drawLine(Offset(leftMargin, yPos), Offset(size.width, yPos), gridPaint);
      }

      // Draw Y-Axis label
      TextPainter tp = TextPainter(
          text: TextSpan(text: '$labelValue', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, yPos - tp.height / 2));
    }

    // 2. Draw X and Y Axes
    canvas.drawLine(const Offset(leftMargin, 0), Offset(leftMargin, graphHeight), axisPaint); // Y-Axis
    canvas.drawLine(Offset(leftMargin, graphHeight), Offset(size.width, graphHeight), axisPaint); // X-Axis

    // Y-Axis Title
    canvas.save();
    canvas.translate(12, graphHeight / 2);
    canvas.rotate(-1.5708); // Rotate -90 degrees
    TextPainter yTitlePainter = TextPainter(
      text: const TextSpan(text: 'Frequency', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    yTitlePainter.layout();
    yTitlePainter.paint(canvas, Offset(-yTitlePainter.width / 2, 0));
    canvas.restore();

    // 3. Draw Bars
    double barSpacing = 16.0;
    int numBars = rows.length;
    double totalSpacing = barSpacing * (numBars + 1);
    double barWidth = (graphWidth - totalSpacing) / numBars;

    // Ensure bar width doesn't get too ridiculously thick on few items
    if (barWidth > 60.0) {
      barWidth = 60.0;
      barSpacing = (graphWidth - (barWidth * numBars)) / (numBars + 1);
    }

    double currentX = leftMargin + barSpacing;

    for (int i = 0; i < numBars; i++) {
      BarChartRow row = rows[i];
      Color barColor = colors[i % colors.length];

      double barHeight = graphHeight * (row.frequency / maxScaleValue);
      double yPos = graphHeight - barHeight;

      // Draw the bar with rounded top corners
      final RRect barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(currentX, yPos, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final Paint fillPaint = Paint()..color = barColor..style = PaintingStyle.fill;
      canvas.drawRRect(barRect, fillPaint);

      // Draw a subtle border around the bar
      final Paint strokePaint = Paint()..color = barColor.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      canvas.drawRRect(barRect, strokePaint);

      // Draw X-Axis Label (Truncate if too long)
      String displayLabel = row.label;
      if (displayLabel.length > 6) displayLabel = '${displayLabel.substring(0, 5)}..';

      TextPainter tpX = TextPainter(
        text: TextSpan(text: displayLabel, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      );
      tpX.layout(maxWidth: barWidth + barSpacing);
      tpX.paint(canvas, Offset(currentX + (barWidth / 2) - (tpX.width / 2), graphHeight + 8));

      currentX += barWidth + barSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}