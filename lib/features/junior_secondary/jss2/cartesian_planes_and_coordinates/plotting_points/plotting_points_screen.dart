import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'plotting_points_logic.dart';
import 'plotting_points_models.dart';

class PlottingPointsScreen extends StatefulWidget {
  const PlottingPointsScreen({super.key});

  @override
  State<PlottingPointsScreen> createState() => _PlottingPointsScreenState();
}

class _PlottingPointsScreenState extends State<PlottingPointsScreen> {
  List<Map<String, TextEditingController>> _pointControllers = [];
  PlottingResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _addPoint('A'); // Start with one point
    _addPoint('B'); // Add a second point to match example
  }

  void _addPoint([String? defaultName]) {
    setState(() {
      _pointControllers.add({
        'name': TextEditingController(text: defaultName ?? String.fromCharCode(65 + _pointControllers.length)),
        'x': TextEditingController(),
        'y': TextEditingController(),
      });
    });
  }

  void _removePoint(int index) {
    setState(() {
      _pointControllers[index]['name']!.dispose();
      _pointControllers[index]['x']!.dispose();
      _pointControllers[index]['y']!.dispose();
      _pointControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var map in _pointControllers) {
      map['name']!.dispose();
      map['x']!.dispose();
      map['y']!.dispose();
    }
    _graphTransformController.dispose();
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
      _result = PlottingPointsLogic.plotPoints(rawData);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        // Auto-center the 800x800 canvas
        final screenWidth = MediaQuery.of(context).size.width - 32;
        double dx = (800 - screenWidth) / 2;
        double dy = (800 - 350) / 2;
        _graphTransformController.value = Matrix4.identity()..translate(-dx, -dy);
      }
    });
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
          child: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text("The easiest way to plot a point is to start at the origin, move along the x-axis, then move parallel to the y-axis!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text("Points to Plot:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
            TextButton.icon(onPressed: _addPoint, icon: const Icon(Icons.add, size: 18), label: const Text("Add Point"))
          ],
        ),
        const SizedBox(height: 8),

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
                        decoration: InputDecoration(hintText: "Name", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _pointControllers[index]['x'],
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        decoration: InputDecoration(hintText: "x-coord", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _pointControllers[index]['y'],
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        decoration: InputDecoration(hintText: "y-coord", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    if (_pointControllers.length > 1)
                      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removePoint(index))
                    else
                      const SizedBox(width: 48), // Padding equivalent to icon button
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: Text("1. Plotting Graph (Visual Path):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18))),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text("💡 Drag to Pan, Pinch to Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Virtual Graph Paper
        Container(
          height: 350,
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
              constrained: false,
              boundaryMargin: const EdgeInsets.all(200),
              minScale: 0.2,
              maxScale: 4.0,
              child: Container(
                width: 800,
                height: 800,
                color: Colors.white,
                child: CustomPaint(
                  painter: PlottingPathPainter(points: _result!.points),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. Step-by-Step Instructions:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade900, fontSize: 15, height: 1.5)),
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
      appBar: AppBar(title: const Text('12-4 Plotting Points')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.edit_location_alt, color: Colors.white),
              label: const Text("Plot Points on Graph", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class PlottingPathPainter extends CustomPainter {
  final List<PlotPoint> points;

  PlottingPathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2;

    // Exact textbook styles
    final crossPaint = Paint()..color = Colors.red.shade700..strokeWidth = 3..style = PaintingStyle.stroke;
    final pathPaint = Paint()..color = Colors.blue.withOpacity(0.5)..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final pathArrowPaint = Paint()..color = Colors.blue.withOpacity(0.8)..style = PaintingStyle.fill;

    // Auto-scale logic
    double maxBound = 5;
    for (var p in points) {
      if (p.x.abs() > maxBound) maxBound = p.x.abs().ceilToDouble();
      if (p.y.abs() > maxBound) maxBound = p.y.abs().ceilToDouble();
    }
    maxBound += 2; // Add padding

    double cx = size.width / 2;
    double cy = size.height / 2;
    double unitSize = (size.width / 2) / maxBound;

    // Draw Grid
    for (int i = -maxBound.toInt(); i <= maxBound.toInt(); i++) {
      double px = cx + (i * unitSize);
      double py = cy - (i * unitSize);

      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint); // Vertical
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint); // Horizontal

      if (i != 0) {
        if (maxBound > 15 && i % 2 != 0) continue;
        _drawText(canvas, i.toString(), px, cy + 12);
        _drawText(canvas, i.toString(), cx - 14, py);
      }
    }

    // Draw Bold Axes
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint); // Y
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint); // X
    _drawText(canvas, '0', cx - 12, cy + 12, isBold: true); // Origin
    _drawText(canvas, 'x', size.width - 15, cy - 15, isBold: true, fontSize: 16);
    _drawText(canvas, 'y', cx + 15, 15, isBold: true, fontSize: 16);

    // Draw Paths and Plot Points
    for (var p in points) {
      double targetX = cx + (p.x * unitSize);
      double targetY = cy - (p.y * unitSize);
      Offset origin = Offset(cx, cy);
      Offset midPoint = Offset(targetX, cy); // Moving along X axis first

      // Draw Path 1: Origin to X-coordinate
      if (p.x != 0) {
        canvas.drawLine(origin, midPoint, pathPaint);
        _drawArrow(canvas, origin, midPoint, pathArrowPaint);
      }

      // Draw Path 2: X-coordinate up/down to Y-coordinate
      if (p.y != 0) {
        canvas.drawLine(midPoint, Offset(targetX, targetY), pathPaint);
        _drawArrow(canvas, midPoint, Offset(targetX, targetY), pathArrowPaint);
      }

      // Draw Small Vertical Cross (+)
      double crossSize = 5;
      canvas.drawLine(Offset(targetX - crossSize, targetY), Offset(targetX + crossSize, targetY), crossPaint);
      canvas.drawLine(Offset(targetX, targetY - crossSize), Offset(targetX, targetY + crossSize), crossPaint);

      // Draw Label
      _drawText(canvas, "${p.name}(${_fmt(p.x)}, ${_fmt(p.y)})", targetX + 18, targetY - 18, isBold: true, color: Colors.deepPurple, fontSize: 14);
    }
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    if (p1 == p2) return;
    double dX = p2.dx - p1.dx;
    double dY = p2.dy - p1.dy;
    double angle = math.atan2(dY, dX);
    double arrowLength = 8;
    double arrowAngle = math.pi / 6; // 30 degrees

    Path path = Path();
    // Move slightly back from the actual point so the arrow doesn't cover the cross
    Offset arrowTip = Offset(p2.dx - math.cos(angle)*5, p2.dy - math.sin(angle)*5);

    path.moveTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(
        arrowTip.dx - arrowLength * math.cos(angle - arrowAngle),
        arrowTip.dy - arrowLength * math.sin(angle - arrowAngle));
    path.lineTo(
        arrowTip.dx - arrowLength * math.cos(angle + arrowAngle),
        arrowTip.dy - arrowLength * math.sin(angle + arrowAngle));
    path.close();

    canvas.drawPath(path, paint);
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87, double fontSize = 12}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}