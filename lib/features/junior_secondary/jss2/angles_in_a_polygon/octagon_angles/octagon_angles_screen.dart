import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'octagon_angles_models.dart';
import 'octagon_angles_solver.dart';

class OctagonAnglesScreen extends StatefulWidget {
  const OctagonAnglesScreen({super.key});

  @override
  State<OctagonAnglesScreen> createState() => _OctagonAnglesScreenState();
}

class _OctagonAnglesScreenState extends State<OctagonAnglesScreen> {
  int _selectedDiagram = 0;

  final Map<String, TextEditingController> _controllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(), 'f': TextEditingController(),
    'g': TextEditingController(), 'h': TextEditingController(), 'i': TextEditingController(),
    'j': TextEditingController(), 'k': TextEditingController(), 'l': TextEditingController(),
    'm': TextEditingController(), 'n': TextEditingController(), 'o': TextEditingController(),
    'p': TextEditingController(),
  };

  OctagonAnglesResult? _result;

  @override
  void dispose() {
    for (var c in _controllers.values) { c.dispose(); }
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    Map<String, String> inputs = {};
    _controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) inputs[key] = controller.text;
    });

    setState(() {
      _result = OctagonAnglesSolver.solveOctagonDiagram(inputs, _selectedDiagram);
    });
  }

  Widget _buildVerticalDiagramList() {
    return Container(
      height: 380, // Taller to fit all diagrams
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildListCard(0, "Basic Octagon", BasicOctagonPainter()),
          _buildListCard(1, "Octagon Split (6 Triangles)", SplitOctagonPainter()),
          _buildListCard(2, "Regular Octagon", RegularOctagonPainter()),
          _buildListCard(3, "Octagon with Exterior Angles", ExteriorOctagonPainter()),
          _buildListCard(4, "Composite 'T' Shape", TShapeOctagonPainter()),
        ],
      ),
    );
  }

  Widget _buildListCard(int index, String title, CustomPainter painter) {
    bool isSelected = _selectedDiagram == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDiagram = index;
          _result = null;
          for (var c in _controllers.values) { c.clear(); } // Clear inputs on switch
        });
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomPaint(painter: painter, size: const Size(double.infinity, double.infinity)),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade200),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? Colors.deepPurple : Colors.black87))),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.deepPurple),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelperBanner("Enter the known angles or variables (e.g. 135, x, 2x+10). Leave unknowns blank."),
        const SizedBox(height: 16),

        if (_selectedDiagram == 0 || _selectedDiagram == 1 || _selectedDiagram == 2 || _selectedDiagram == 4) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')), const SizedBox(width: 8), Expanded(child: _buildGridField('d')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')), const SizedBox(width: 8), Expanded(child: _buildGridField('g')), const SizedBox(width: 8), Expanded(child: _buildGridField('h')) ]),
        ] else if (_selectedDiagram == 3) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')), const SizedBox(width: 8), Expanded(child: _buildGridField('d')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')), const SizedBox(width: 8), Expanded(child: _buildGridField('g')), const SizedBox(width: 8), Expanded(child: _buildGridField('h')) ]),
          const SizedBox(height: 16),
          const Text("Exterior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('i')), const SizedBox(width: 8), Expanded(child: _buildGridField('j')), const SizedBox(width: 8), Expanded(child: _buildGridField('k')), const SizedBox(width: 8), Expanded(child: _buildGridField('l')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('m')), const SizedBox(width: 8), Expanded(child: _buildGridField('n')), const SizedBox(width: 8), Expanded(child: _buildGridField('o')), const SizedBox(width: 8), Expanded(child: _buildGridField('p')) ]),
        ]
      ],
    );
  }

  Widget _buildHelperBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildGridField(String label) {
    return TextField(
      controller: _controllers[label],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("1. Final Solved Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAngles.entries.map((entry) {
            bool isVariable = !entry.key.startsWith('Angle');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: isVariable ? Colors.deepPurple.shade50 : Colors.green.shade50,
                  border: Border.all(color: isVariable ? Colors.deepPurple.shade200 : Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${entry.key}: ", style: TextStyle(fontWeight: FontWeight.bold, color: isVariable ? Colors.deepPurple : Colors.black87, fontSize: 16)),
                  Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold, color: isVariable ? Colors.deepPurple : Colors.green, fontSize: 18)),
                ],
              ),
            );
          }).toList(),
        ),

        if (_result!.workings.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text("2. Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
          const SizedBox(height: 12),
          Card(
            color: Colors.deepPurple.shade50,
            elevation: 0.5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _result!.workings.length; i++)
                    if (_result!.workings[i].isEmpty)
                      const SizedBox(height: 24) // Render visual spacing for empty lines
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                              _result!.workings[i],
                              textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple)
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        Text("${_result!.workings.isNotEmpty ? '3' : '2'}. Step-by-Step Breakdown:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: const Text('Angles in an Octagon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select an Octagon Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildVerticalDiagramList(),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            _buildInputSection(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text("Solve Octagon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Error',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            if (_result != null && _result!.valid)
              _buildResultView(Theme.of(context)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM PAINTERS FOR DIAGRAMS
// -----------------------------------------------------------------------------

void _drawLabel(Canvas canvas, String text, double x, double y) {
  TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr
  );
  tp.layout();
  tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
}

/// Helper function to generate points for a polygon around a center
List<Offset> _generatePolygonPoints(double cx, double cy, double radius, int sides) {
  List<Offset> points = [];
  // Offset by pi/8 to make top and bottom edges flat for an octagon
  double offset = math.pi / sides;
  double step = 2 * math.pi / sides;
  for (int i = 0; i < sides; i++) {
    double angle = -math.pi / 2 + offset + i * step;
    points.add(Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle)));
  }
  return points;
}

class BasicOctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = math.min(cx, cy) * 0.85;

    List<Offset> pts = _generatePolygonPoints(cx, cy, r, 8);

    // Draw Polygon
    Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < 8; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
    path.close();
    canvas.drawPath(path, paint);

    // Draw Labels slightly inside
    List<String> labels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int i = 0; i < 8; i++) {
      double angle = -math.pi / 2 + (math.pi / 8) + i * (2 * math.pi / 8);
      _drawLabel(canvas, labels[i], cx + (r * 0.70) * math.cos(angle), cy + (r * 0.70) * math.sin(angle));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplitOctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final splitPaint = Paint()..color = Colors.deepPurple..strokeWidth = 2..style = PaintingStyle.stroke;

    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = math.min(cx, cy) * 0.85;

    List<Offset> pts = _generatePolygonPoints(cx, cy, r, 8);

    Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < 8; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
    path.close();
    canvas.drawPath(path, paint);

    // Draw Diagonals from top-left vertex (pts[0]) to split into 6 triangles
    for (int i = 2; i < 7; i++) {
      canvas.drawLine(pts[0], pts[i], splitPaint);
    }

    List<String> labels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int i = 0; i < 8; i++) {
      double angle = -math.pi / 2 + (math.pi / 8) + i * (2 * math.pi / 8);
      _drawLabel(canvas, labels[i], cx + (r * 0.75) * math.cos(angle), cy + (r * 0.75) * math.sin(angle));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegularOctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = math.min(cx, cy) * 0.85;

    List<Offset> pts = _generatePolygonPoints(cx, cy, r, 8);

    Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < 8; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
    path.close();
    canvas.drawPath(path, paint);

    // Ticks to denote regular octagon
    for (int i = 0; i < 8; i++) {
      Offset p1 = pts[i];
      Offset p2 = pts[(i + 1) % 8];
      _drawTick(canvas, p1, p2, tickPaint);
    }

    List<String> labels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int i = 0; i < 8; i++) {
      double angle = -math.pi / 2 + (math.pi / 8) + i * (2 * math.pi / 8);
      _drawLabel(canvas, labels[i], cx + (r * 0.70) * math.cos(angle), cy + (r * 0.70) * math.sin(angle));
    }
  }

  void _drawTick(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double len = math.sqrt(dx*dx + dy*dy);
    double perpX = -dy / len * 6;
    double perpY = dx / len * 6;
    canvas.drawLine(Offset(mid.dx - perpX, mid.dy - perpY), Offset(mid.dx + perpX, mid.dy + perpY), paint);
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExteriorOctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    double cx = size.width / 2;
    double cy = size.height / 2;
    // Smaller radius to leave room for extended lines
    double r = math.min(cx, cy) * 0.55;

    List<Offset> pts = _generatePolygonPoints(cx, cy, r, 8);

    // Draw Extended Lines (Pinwheel)
    for (int i = 0; i < 8; i++) {
      Offset p1 = pts[(i - 1 + 8) % 8]; // Previous point
      Offset p2 = pts[i]; // Current point

      double dx = p2.dx - p1.dx;
      double dy = p2.dy - p1.dy;

      // Extend past p2
      Offset p3 = Offset(p2.dx + dx * 0.6, p2.dy + dy * 0.6);
      canvas.drawLine(p1, p3, paint);
    }

    // Interior Labels (a-h)
    List<String> inLabels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int i = 0; i < 8; i++) {
      double angle = -math.pi / 2 + (math.pi / 8) + i * (2 * math.pi / 8);
      _drawLabel(canvas, inLabels[i], cx + (r * 0.65) * math.cos(angle), cy + (r * 0.65) * math.sin(angle));
    }

    // Exterior Labels (i-p)
    List<String> extLabels = ['i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'];
    for (int i = 0; i < 8; i++) {
      // Offset the exterior label angle slightly to match the pinwheel wedge
      double angle = -math.pi / 2 + (math.pi / 8) + i * (2 * math.pi / 8) + 0.45;
      _drawLabel(canvas, extLabels[i], cx + (r * 1.55) * math.cos(angle), cy + (r * 1.55) * math.sin(angle));
    }
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TShapeOctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    // Irregular 8-sided "T" Shape
    Offset p1 = Offset(size.width * 0.2, size.height * 0.2); // 1. Top Left
    Offset p2 = Offset(size.width * 0.8, size.height * 0.2); // 2. Top Right
    Offset p3 = Offset(size.width * 0.8, size.height * 0.45); // 3. Bot Right of Top Bar
    Offset p4 = Offset(size.width * 0.6, size.height * 0.45); // 4. Top Right of Stem
    Offset p5 = Offset(size.width * 0.6, size.height * 0.9);  // 5. Bot Right of Stem
    Offset p6 = Offset(size.width * 0.4, size.height * 0.9);  // 6. Bot Left of Stem
    Offset p7 = Offset(size.width * 0.4, size.height * 0.45); // 7. Top Left of Stem
    Offset p8 = Offset(size.width * 0.2, size.height * 0.45); // 8. Bot Left of Top Bar

    Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy)
      ..lineTo(p6.dx, p6.dy)
      ..lineTo(p7.dx, p7.dy)
      ..lineTo(p8.dx, p8.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Side Ticks to indicate symmetry
    _drawSideTick(canvas, p1, p8, 1, paint); // Left arm outer
    _drawSideTick(canvas, p2, p3, 1, paint); // Right arm outer
    _drawSideTick(canvas, p4, p5, 2, paint); // Right stem
    _drawSideTick(canvas, p7, p6, 2, paint); // Left stem

    // Angle arcs for the top corners to show equality
    canvas.drawArc(Rect.fromCircle(center: p1, radius: 20), 0, math.pi * 0.5, false, paint);
    _drawAngleArrow(canvas, p1, 20, math.pi * 0.25, tickPaint..style=PaintingStyle.fill);

    canvas.drawArc(Rect.fromCircle(center: p2, radius: 20), math.pi * 0.5, math.pi * 0.5, false, paint);
    _drawAngleArrow(canvas, p2, 20, math.pi * 0.75, tickPaint..style=PaintingStyle.fill);

    _drawLabel(canvas, 'a', size.width * 0.25, size.height * 0.28); // Top Left Inner
    _drawLabel(canvas, 'b', size.width * 0.75, size.height * 0.28); // Top Right Inner
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.38); // Bot Right Bar
    _drawLabel(canvas, 'd', size.width * 0.65, size.height * 0.53); // Reflex Right Inner
    _drawLabel(canvas, 'e', size.width * 0.55, size.height * 0.82); // Bot Right Stem
    _drawLabel(canvas, 'f', size.width * 0.45, size.height * 0.82); // Bot Left Stem
    _drawLabel(canvas, 'g', size.width * 0.35, size.height * 0.53); // Reflex Left Inner
    _drawLabel(canvas, 'h', size.width * 0.25, size.height * 0.38); // Bot Left Bar
  }

  void _drawSideTick(Canvas canvas, Offset p1, Offset p2, int count, Paint paint) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double len = math.sqrt(dx*dx + dy*dy);
    double px = -dy / len * 5;
    double py = dx / len * 5;

    if (count == 1) {
      canvas.drawLine(Offset(mid.dx - px, mid.dy - py), Offset(mid.dx + px, mid.dy + py), paint);
    } else {
      canvas.drawLine(Offset(mid.dx - px - dx/len*3, mid.dy - py - dy/len*3), Offset(mid.dx + px - dx/len*3, mid.dy + py - dy/len*3), paint);
      canvas.drawLine(Offset(mid.dx - px + dx/len*3, mid.dy - py + dy/len*3), Offset(mid.dx + px + dx/len*3, mid.dy + py + dy/len*3), paint);
    }
  }

  void _drawAngleArrow(Canvas canvas, Offset center, double radius, double angle, Paint paint) {
    double px = center.dx + radius * math.cos(angle);
    double py = center.dy + radius * math.sin(angle);
    double tx = -math.sin(angle);
    double ty = math.cos(angle);
    double nx = math.cos(angle);
    double ny = math.sin(angle);

    Path arrow = Path();
    arrow.moveTo(px + tx * 5, py + ty * 5);
    arrow.lineTo(px - tx * 6 - nx * 5, py - ty * 6 - ny * 5);
    arrow.lineTo(px - tx * 6 + nx * 5, py - ty * 6 + ny * 5);
    arrow.close();
    canvas.drawPath(arrow, paint);
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}