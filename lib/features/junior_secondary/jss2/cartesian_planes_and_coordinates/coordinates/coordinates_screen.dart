import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'coordinates_logic.dart';
import 'coordinates_models.dart';

class CoordinatesScreen extends StatefulWidget {
  const CoordinatesScreen({super.key});

  @override
  State<CoordinatesScreen> createState() => _CoordinatesScreenState();
}

class _CoordinatesScreenState extends State<CoordinatesScreen> {
  List<Map<String, TextEditingController>> _pointControllers = [];
  CoordinateResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _addPoint('A'); // Start with one point
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
      _result = CoordinatesLogic.decodeCoordinates(rawData);
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
              Expanded(child: Text("Enter the x and y coordinates to decode them. The graph will draw trace lines to show how to read them!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text("Ordered Pairs (x, y):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
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
            const Expanded(child: Text("1. Coordinate Trace Graph:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18))),
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
                  painter: CoordinatesTracePainter(points: _result!.points),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. Final Decoding:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAnswers.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${entry.key}: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
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
      appBar: AppBar(title: const Text('12-3 Coordinates')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text("Decode Coordinates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class CoordinatesTracePainter extends CustomPainter {
  final List<CoordinatePoint> points;

  CoordinatesTracePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2;
    final plotPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    // Dashed line setup
    final traceXPaint = Paint()..color = Colors.blue.withOpacity(0.6)..strokeWidth = 2..style = PaintingStyle.stroke;
    final traceYPaint = Paint()..color = Colors.green.withOpacity(0.6)..strokeWidth = 2..style = PaintingStyle.stroke;

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
      double py = cy - (i * unitSize); // y is flipped in canvas

      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint); // Vertical
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint); // Horizontal

      // Draw Numbers (skip 0)
      if (i != 0) {
        if (maxBound > 15 && i % 2 != 0) continue;
        _drawText(canvas, i.toString(), px, cy + 12); // X-axis numbers
        _drawText(canvas, i.toString(), cx - 14, py); // Y-axis numbers
      }
    }

    // Draw Bold Axes
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint); // Y
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint); // X
    _drawText(canvas, '0', cx - 12, cy + 12, isBold: true); // Origin
    _drawText(canvas, 'x', size.width - 15, cy - 15, isBold: true, fontSize: 16);
    _drawText(canvas, 'y', cx + 15, 15, isBold: true, fontSize: 16);

    // Draw Traces and Plot Points
    for (var p in points) {
      double px = cx + (p.x * unitSize);
      double py = cy - (p.y * unitSize);

      // 1. Draw trace to X-axis (vertical dashed line)
      if (p.y != 0) {
        _drawDashedLine(canvas, Offset(px, py), Offset(px, cy), traceXPaint);
      }

      // 2. Draw trace to Y-axis (horizontal dashed line)
      if (p.x != 0) {
        _drawDashedLine(canvas, Offset(px, py), Offset(cx, py), traceYPaint);
      }

      // 3. Draw cross (+)
      canvas.drawLine(Offset(px - 5, py), Offset(px + 5, py), plotPaint);
      canvas.drawLine(Offset(px, py - 5), Offset(px, py + 5), plotPaint);

      // 4. Draw Label
      _drawText(canvas, "${p.name}(${_fmt(p.x)}, ${_fmt(p.y)})", px + 15, py - 15, isBold: true, color: Colors.deepPurple, fontSize: 14);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double distance = (p2 - p1).distance;
    double dashWidth = 5, dashSpace = 5;
    double startX = p1.dx, startY = p1.dy;
    int count = (distance / (dashWidth + dashSpace)).floor();
    double dx = (p2.dx - p1.dx) / count;
    double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(Offset(startX, startY), Offset(startX + dx, startY + dy), paint);
      }
      startX += dx;
      startY += dy;
    }
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