import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_guru/features/junior_secondary/jss2/cartesian_planes_and_coordinates/position_of_points/position_of_points_logic.dart';
import 'package:math_guru/features/junior_secondary/jss2/cartesian_planes_and_coordinates/position_of_points/position_of_points_models.dart';
import 'dart:math' as math;

class PositionOfPointsScreen extends StatefulWidget {
  const PositionOfPointsScreen({super.key});

  @override
  State<PositionOfPointsScreen> createState() => _PositionOfPointsScreenState();
}

class _PositionOfPointsScreenState extends State<PositionOfPointsScreen> {
  int _selectedMode = 0; // 0 = 1D (Line), 1 = 2D (Plane)

  final List<Map<String, TextEditingController>> _pointControllers = [];
  PositionResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _resetPoints();
  }

  void _resetPoints() {
    for (var map in _pointControllers) {
      map['name']!.dispose(); map['x']!.dispose(); map['y']?.dispose();
    }
    _pointControllers.clear();

    // Add default points A and B
    _addPoint('A');
    _addPoint('B');
  }

  void _addPoint([String? defaultName]) {
    setState(() {
      _pointControllers.add({
        'name': TextEditingController(text: defaultName ?? ''),
        'x': TextEditingController(),
        'y': TextEditingController(),
      });
    });
  }

  void _removePoint(int index) {
    setState(() {
      _pointControllers[index]['name']!.dispose();
      _pointControllers[index]['x']!.dispose();
      _pointControllers[index]['y']?.dispose();
      _pointControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _graphTransformController.dispose();
    for (var map in _pointControllers) {
      map['name']!.dispose(); map['x']!.dispose(); map['y']?.dispose();
    }
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<Map<String, String>> rawData = _pointControllers.map((c) => {
      'name': c['name']!.text,
      'x': c['x']!.text,
      'y': c['y']!.text,
    }).toList();

    setState(() {
      if (_selectedMode == 0) {
        _result = PositionLogic.solve1D(rawData);
      } else {
        _result = PositionLogic.solve2D(rawData);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        final screenWidth = MediaQuery.of(context).size.width - 32; // Accommodate 16px padding
        if (_selectedMode == 1) {
          // Center the 800x800 2D canvas in the 350px tall viewport
          double dx = (800 - screenWidth) / 2;
          double dy = (800 - 350) / 2;
          _graphTransformController.value = Matrix4.identity()..translate(-dx, -dy);
        } else {
          // Center the 800x150 1D line horizontally
          double dx = (800 - screenWidth) / 2;
          _graphTransformController.value = Matrix4.identity()..translate(-dx, 0.0);
        }
      }
    });
  }

  Widget _buildInputSection() {
    bool is2D = _selectedMode == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(child: Text(is2D
                  ? "Enter 2D ordered pairs (x, y). If you enter exactly 4 points, the app will identify the geometric shape they form!"
                  : "Enter coordinates for points on a single horizontal number line. Fractions like '1 1/2' are allowed.",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Coordinates:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            TextButton.icon(onPressed: _addPoint, icon: const Icon(Icons.add, size: 18), label: const Text("Add Point"))
          ],
        ),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            children: List.generate(_pointControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _pointControllers[index]['name'],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: "Name (e.g. A)", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _pointControllers[index]['x'],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(hintText: is2D ? "X-Coord" : "Value", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    if (is2D) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _pointControllers[index]['y'],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(hintText: "Y-Coord", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ],
                    if (_pointControllers.length > 1)
                      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removePoint(index))
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));
    }

    bool is2D = _result!.mode == '2D';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("1. Graph Visualizer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
            Text("💡 Drag to Pan, Pinch to Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),

        // The Custom Virtual Graph Paper
        Container(
          height: is2D ? 350 : 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _graphTransformController,
              constrained: false, // Forces the child to assume the large 800px size
              boundaryMargin: const EdgeInsets.all(200), // Allows scrolling comfortably past edges
              minScale: 0.2,
              maxScale: 4.0,
              child: Container(
                width: 800,
                height: is2D ? 800 : 150,
                color: Colors.white,
                child: CustomPaint(
                  painter: is2D
                      ? CartesianPainter(points: _result!.points2D)
                      : NumberLinePainter(points: _result!.points1D),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. Final Coordinates:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAnswers.entries.map((entry) {
            bool isShape = entry.key.contains("Shape") || entry.key.contains("Intersect");
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: isShape ? Colors.deepPurple.shade50 : Colors.green.shade50,
                  border: Border.all(color: isShape ? Colors.deepPurple.shade200 : Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${entry.key}: ", style: TextStyle(fontWeight: FontWeight.bold, color: isShape ? Colors.deepPurple : Colors.black87, fontSize: 16)),
                  Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold, color: isShape ? Colors.deepPurple : Colors.green, fontSize: 18)),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),
        const Text("3. Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX != null) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(e.value.mathLaTeX!, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Position of Points')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Points on a Line", style: TextStyle(fontWeight: FontWeight.bold))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Points on a Plane", style: TextStyle(fontWeight: FontWeight.bold))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _result = null;
                      _resetPoints();
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),

            _buildInputSection(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.show_chart, color: Colors.white),
              label: const Text("Plot Points & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            _buildResultView(Theme.of(context)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class NumberLinePainter extends CustomPainter {
  final List<Point1D> points;

  NumberLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()..color = Colors.black..strokeWidth = 2;
    final tickPaint = Paint()..color = Colors.black..strokeWidth = 1.5;
    final plotPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    // Find bounds to auto-scale
    double minX = 0; double maxX = 0;
    for (var p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
    }

    // Add padding
    minX = (minX - 1).floorToDouble();
    maxX = (maxX + 1).ceilToDouble();

    // Ensure symmetric or at least proper span
    if (maxX < 4) maxX = 4;
    if (minX > -4) minX = -4;

    double range = maxX - minX;
    double centerY = size.height / 2;

    // Draw main line
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);

    // Draw Ticks & Labels
    for (int i = minX.toInt(); i <= maxX.toInt(); i++) {
      double px = (i - minX) / range * size.width;

      // Don't draw ticks right on the absolute edge
      if (px > 10 && px < size.width - 10) {
        canvas.drawLine(Offset(px, centerY - 5), Offset(px, centerY + 5), tickPaint);
        _drawText(canvas, i.toString(), px, centerY + 15, isBold: i == 0);
      }
    }

    // Plot Points (Small Cross + Label)
    for (var p in points) {
      double px = (p.x - minX) / range * size.width;

      // Draw cross
      canvas.drawLine(Offset(px - 4, centerY - 4), Offset(px + 4, centerY + 4), plotPaint);
      canvas.drawLine(Offset(px + 4, centerY - 4), Offset(px - 4, centerY + 4), plotPaint);

      // Draw Label above
      _drawText(canvas, p.name, px, centerY - 20, isBold: true, color: Colors.deepPurple);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CartesianPainter extends CustomPainter {
  final List<Point2D> points;

  CartesianPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2;
    final plotPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;
    final shapePaint = Paint()..color = Colors.blue.withOpacity(0.5)..strokeWidth = 2..style = PaintingStyle.stroke;

    // Auto-scale logic
    double maxBound = 5; // Minimum 5x5 grid
    for (var p in points) {
      if (p.x.abs() > maxBound) maxBound = p.x.abs().ceilToDouble();
      if (p.y.abs() > maxBound) maxBound = p.y.abs().ceilToDouble();
    }
    maxBound += 1; // Add padding

    double cx = size.width / 2;
    double cy = size.height / 2;
    double unitSize = (size.width / 2) / maxBound;

    // Draw Grid
    for (int i = -maxBound.toInt(); i <= maxBound.toInt(); i++) {
      double px = cx + (i * unitSize);
      double py = cy - (i * unitSize); // y is flipped in canvas

      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint); // Vertical
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint); // Horizontal

      // Draw Numbers (skip 0)
      if (i != 0 && i % 2 == 0) { // Only number evens if grid is getting crowded
        if (maxBound > 10 && i % 4 != 0) continue;

        _drawText(canvas, i.toString(), px, cy + 12); // X-axis numbers
        _drawText(canvas, i.toString(), cx - 12, py); // Y-axis numbers
      }
    }

    // Draw Bold Axes
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint); // Y
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint); // X
    _drawText(canvas, '0', cx - 10, cy + 10, isBold: true); // Origin
    _drawText(canvas, 'x', size.width - 10, cy - 15, isBold: true);
    _drawText(canvas, 'y', cx + 15, 10, isBold: true);

    // Optionally connect points if it forms a polygon (4 points)
    if (points.length >= 3) {
      Path path = Path();
      for (int i = 0; i < points.length; i++) {
        double px = cx + (points[i].x * unitSize);
        double py = cy - (points[i].y * unitSize);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, shapePaint);
    }

    // Plot Points (Small Cross + Label)
    for (var p in points) {
      double px = cx + (p.x * unitSize);
      double py = cy - (p.y * unitSize);

      // Draw cross (+)
      canvas.drawLine(Offset(px - 4, py), Offset(px + 4, py), plotPaint);
      canvas.drawLine(Offset(px, py - 4), Offset(px, py + 4), plotPaint);

      // Draw Label
      _drawText(canvas, p.name, px + 12, py - 12, isBold: true, color: Colors.deepPurple);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}