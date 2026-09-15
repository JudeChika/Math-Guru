import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'quadrilateral_angles_models.dart';
import 'quadrilateral_angles_solver.dart';

class QuadrilateralAnglesScreen extends StatefulWidget {
  const QuadrilateralAnglesScreen({super.key});

  @override
  State<QuadrilateralAnglesScreen> createState() => _QuadrilateralAnglesScreenState();
}

class _QuadrilateralAnglesScreenState extends State<QuadrilateralAnglesScreen> {
  int _selectedDiagram = 0;

  // Shared map for all possible quadrilateral variables (a through h)
  final Map<String, TextEditingController> _controllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(), 'f': TextEditingController(),
    'g': TextEditingController(), 'h': TextEditingController(),
  };

  QuadrilateralAnglesResult? _result;

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
      _result = QuadrilateralAnglesSolver.solveQuadDiagram(inputs, _selectedDiagram);
    });
  }

  Widget _buildVerticalDiagramList() {
    return Container(
      height: 420, // Taller to fit the new arrow diagrams
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildListCard(0, "Basic Quadrilateral", BasicQuadPainter()),
          _buildListCard(1, "Quadrilateral with a Diagonal", DiagonalQuadPainter()),
          _buildListCard(2, "Parallelogram", ParallelogramPainter()),
          _buildListCard(3, "Trapezium", TrapeziumPainter()),
          _buildListCard(4, "Quadrilateral with Exterior Angles", ExteriorQuadPainter()),
          _buildListCard(5, "Kite (Equal Opposite Angles)", KitePainter()),
          _buildListCard(6, "Isosceles Trapezium (Equal Base Angles)", IsoscelesTrapeziumPainter()),
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
        _buildHelperBanner("Enter the known angles or variables (e.g. 120, x, 2x+10). Leave unknowns blank."),
        const SizedBox(height: 16),

        if (_selectedDiagram == 0 || _selectedDiagram == 2 || _selectedDiagram == 3 || _selectedDiagram == 5 || _selectedDiagram == 6) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')) ]),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('c')), const SizedBox(width: 8), Expanded(child: _buildGridField('d')) ]),
        ] else if (_selectedDiagram == 1) ...[
          const Text("Bottom Triangle:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          const Text("Top Triangle:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')) ]),
        ] else if (_selectedDiagram == 4) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')), const SizedBox(width: 8), Expanded(child: _buildGridField('d')) ]),
          const SizedBox(height: 16),
          const Text("Exterior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')), const SizedBox(width: 8), Expanded(child: _buildGridField('g')), const SizedBox(width: 8), Expanded(child: _buildGridField('h')) ]),
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                )
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
      appBar: AppBar(title: const Text('Angles in a Quadrilateral')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select a Quadrilateral Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              label: const Text("Solve Quadrilateral", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class BasicQuadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.9)
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.25, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.75, size.height * 0.40);
    _drawLabel(canvas, 'c', size.width * 0.80, size.height * 0.75);
    _drawLabel(canvas, 'd', size.width * 0.20, size.height * 0.80);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiagonalQuadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final diagonalPaint = Paint()..color = Colors.deepPurple..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height * 0.9)
      ..close();
    canvas.drawPath(path, paint);

    // Draw Diagonal
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.4), Offset(size.width * 0.9, size.height * 0.6), diagonalPaint);

    // Bottom Triangle Labels
    _drawLabel(canvas, 'a', size.width * 0.25, size.height * 0.50);
    _drawLabel(canvas, 'b', size.width * 0.35, size.height * 0.80);
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.63);

    // Top Triangle Labels
    _drawLabel(canvas, 'd', size.width * 0.20, size.height * 0.35);
    _drawLabel(canvas, 'e', size.width * 0.60, size.height * 0.25);
    _drawLabel(canvas, 'f', size.width * 0.80, size.height * 0.52);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParallelogramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.32);
    _drawLabel(canvas, 'b', size.width * 0.80, size.height * 0.32);
    _drawLabel(canvas, 'c', size.width * 0.65, size.height * 0.68);
    _drawLabel(canvas, 'd', size.width * 0.20, size.height * 0.68);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrapeziumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.32);
    _drawLabel(canvas, 'b', size.width * 0.65, size.height * 0.32);
    _drawLabel(canvas, 'c', size.width * 0.80, size.height * 0.72);
    _drawLabel(canvas, 'd', size.width * 0.20, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExteriorQuadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    // Draw Extended Lines (Pinwheel style for exterior angles)
    canvas.drawLine(Offset(size.width * 0.05, size.height * 0.2), Offset(size.width * 0.9, size.height * 0.2), paint); // Top
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.05), Offset(size.width * 0.8, size.height * 0.9), paint); // Right
    canvas.drawLine(Offset(size.width * 0.95, size.height * 0.8), Offset(size.width * 0.1, size.height * 0.8), paint); // Bottom
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.95), Offset(size.width * 0.2, size.height * 0.1), paint); // Left

    // Interior Labels
    _drawLabel(canvas, 'a', size.width * 0.28, size.height * 0.28);
    _drawLabel(canvas, 'b', size.width * 0.72, size.height * 0.28);
    _drawLabel(canvas, 'c', size.width * 0.72, size.height * 0.72);
    _drawLabel(canvas, 'd', size.width * 0.28, size.height * 0.72);

    // Exterior Labels
    _drawLabel(canvas, 'e', size.width * 0.12, size.height * 0.28); // Ext Left-Top
    _drawLabel(canvas, 'f', size.width * 0.72, size.height * 0.12); // Ext Top-Right
    _drawLabel(canvas, 'g', size.width * 0.88, size.height * 0.72); // Ext Right-Bottom
    _drawLabel(canvas, 'h', size.width * 0.28, size.height * 0.88); // Ext Bottom-Left
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset top = Offset(size.width * 0.5, size.height * 0.1);
    Offset right = Offset(size.width * 0.8, size.height * 0.4);
    Offset bottom = Offset(size.width * 0.5, size.height * 0.9);
    Offset left = Offset(size.width * 0.2, size.height * 0.4);

    Path path = Path()..moveTo(top.dx, top.dy)..lineTo(right.dx, right.dy)..lineTo(bottom.dx, bottom.dy)..lineTo(left.dx, left.dy)..close();
    canvas.drawPath(path, paint);

    // Draw side tick marks
    _drawSideTick(canvas, top, right, 1, paint);
    _drawSideTick(canvas, top, left, 1, paint);
    _drawSideTick(canvas, bottom, right, 2, paint);
    _drawSideTick(canvas, bottom, left, 2, paint);

    // Angle arcs with arrows for b and d
    canvas.drawArc(Rect.fromCircle(center: right, radius: 25), math.pi * 0.7, math.pi * 0.6, false, paint);
    _drawAngleArrow(canvas, right, 25, math.pi, tickPaint..style=PaintingStyle.fill);

    canvas.drawArc(Rect.fromCircle(center: left, radius: 25), -math.pi * 0.3, math.pi * 0.6, false, paint);
    _drawAngleArrow(canvas, left, 25, 0, tickPaint..style=PaintingStyle.fill);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.22);
    _drawLabel(canvas, 'b', size.width * 0.68, size.height * 0.40);
    _drawLabel(canvas, 'c', size.width * 0.5, size.height * 0.78);
    _drawLabel(canvas, 'd', size.width * 0.32, size.height * 0.40);
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

class IsoscelesTrapeziumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset tl = Offset(size.width * 0.3, size.height * 0.2);
    Offset tr = Offset(size.width * 0.7, size.height * 0.2);
    Offset br = Offset(size.width * 0.9, size.height * 0.8);
    Offset bl = Offset(size.width * 0.1, size.height * 0.8);

    Path path = Path()..moveTo(tl.dx, tl.dy)..lineTo(tr.dx, tr.dy)..lineTo(br.dx, br.dy)..lineTo(bl.dx, bl.dy)..close();
    canvas.drawPath(path, paint);

    // Parallel arrows
    _drawParallelArrow(canvas, tl, tr, paint);
    _drawParallelArrow(canvas, bl, br, paint);

    // Side ticks
    _drawSideTick(canvas, tl, bl, 1, paint);
    _drawSideTick(canvas, tr, br, 1, paint);

    // Angle arcs with arrows
    canvas.drawArc(Rect.fromCircle(center: bl, radius: 25), -math.pi * 0.25, math.pi * 0.25, false, paint);
    _drawAngleArrow(canvas, bl, 25, -math.pi * 0.125, tickPaint..style=PaintingStyle.fill);

    canvas.drawArc(Rect.fromCircle(center: br, radius: 25), math.pi, math.pi * 0.25, false, paint);
    _drawAngleArrow(canvas, br, 25, math.pi * 1.125, tickPaint..style=PaintingStyle.fill);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.32);
    _drawLabel(canvas, 'b', size.width * 0.65, size.height * 0.32);
    _drawLabel(canvas, 'c', size.width * 0.80, size.height * 0.72);
    _drawLabel(canvas, 'd', size.width * 0.20, size.height * 0.72);
  }

  void _drawParallelArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double len = math.sqrt(dx*dx + dy*dy);
    double tx = dx / len * 6;
    double ty = dy / len * 6;
    double nx = -dy / len * 6;
    double ny = dx / len * 6;

    Path arrow = Path();
    arrow.moveTo(mid.dx + tx, mid.dy + ty);
    arrow.lineTo(mid.dx - tx + nx, mid.dy - ty + ny);
    arrow.moveTo(mid.dx + tx, mid.dy + ty);
    arrow.lineTo(mid.dx - tx - nx, mid.dy - ty - ny);
    canvas.drawPath(arrow, paint);
  }

  void _drawSideTick(Canvas canvas, Offset p1, Offset p2, int count, Paint paint) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double len = math.sqrt(dx*dx + dy*dy);
    double px = -dy / len * 5;
    double py = dx / len * 5;

    canvas.drawLine(Offset(mid.dx - px, mid.dy - py), Offset(mid.dx + px, mid.dy + py), paint);
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