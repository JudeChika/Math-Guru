import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'hexagon_angles_model.dart';
import 'hexagon_angles_solver.dart';

class HexagonAnglesScreen extends StatefulWidget {
  const HexagonAnglesScreen({super.key});

  @override
  State<HexagonAnglesScreen> createState() => _HexagonAnglesScreenState();
}

class _HexagonAnglesScreenState extends State<HexagonAnglesScreen> {
  int _selectedDiagram = 0;

  // Shared map for all possible hexagon variables (a through l)
  final Map<String, TextEditingController> _controllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(), 'f': TextEditingController(),
    'g': TextEditingController(), 'h': TextEditingController(), 'i': TextEditingController(),
    'j': TextEditingController(), 'k': TextEditingController(), 'l': TextEditingController(),
  };

  HexagonAnglesResult? _result;

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
      _result = HexagonAnglesSolver.solveHexagonDiagram(inputs, _selectedDiagram);
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
          _buildListCard(0, "Basic Hexagon", BasicHexagonPainter()),
          _buildListCard(1, "Hexagon Split (4 Triangles)", SplitHexagonPainter()),
          _buildListCard(2, "Regular Hexagon", RegularHexagonPainter()),
          _buildListCard(3, "Hexagon with Exterior Angles", ExteriorHexagonPainter()),
          _buildListCard(4, "Irregular 'Boat' Shape", BoatHexagonPainter()),
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

        if (_selectedDiagram == 0 || _selectedDiagram == 1 || _selectedDiagram == 2 || _selectedDiagram == 4) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')) ]),
        ] else if (_selectedDiagram == 3) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')) ]),
          const SizedBox(height: 16),
          const Text("Exterior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('g')), const SizedBox(width: 8), Expanded(child: _buildGridField('h')), const SizedBox(width: 8), Expanded(child: _buildGridField('i')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('j')), const SizedBox(width: 8), Expanded(child: _buildGridField('k')), const SizedBox(width: 8), Expanded(child: _buildGridField('l')) ]),
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
      appBar: AppBar(title: const Text('Angles in a Hexagon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select a Hexagon Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              label: const Text("Solve Hexagon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class BasicHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.1) // Top Left
      ..lineTo(size.width * 0.7, size.height * 0.2) // Top Right
      ..lineTo(size.width * 0.9, size.height * 0.5) // Right
      ..lineTo(size.width * 0.6, size.height * 0.9) // Bottom Right
      ..lineTo(size.width * 0.2, size.height * 0.8) // Bottom Left
      ..lineTo(size.width * 0.1, size.height * 0.4) // Left
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.22);
    _drawLabel(canvas, 'b', size.width * 0.65, size.height * 0.30);
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.52);
    _drawLabel(canvas, 'd', size.width * 0.55, size.height * 0.78);
    _drawLabel(canvas, 'e', size.width * 0.28, size.height * 0.70);
    _drawLabel(canvas, 'f', size.width * 0.22, size.height * 0.45);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplitHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final splitPaint = Paint()..color = Colors.deepPurple..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset p1 = Offset(size.width * 0.3, size.height * 0.1);
    Offset p2 = Offset(size.width * 0.7, size.height * 0.2);
    Offset p3 = Offset(size.width * 0.9, size.height * 0.5);
    Offset p4 = Offset(size.width * 0.6, size.height * 0.9);
    Offset p5 = Offset(size.width * 0.2, size.height * 0.8);
    Offset p6 = Offset(size.width * 0.1, size.height * 0.4);

    Path path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..lineTo(p5.dx, p5.dy)..lineTo(p6.dx, p6.dy)..close();
    canvas.drawPath(path, paint);

    // Draw Diagonals from p1 to split into 4 triangles
    canvas.drawLine(p1, p3, splitPaint);
    canvas.drawLine(p1, p4, splitPaint);
    canvas.drawLine(p1, p5, splitPaint);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.25);
    _drawLabel(canvas, 'b', size.width * 0.65, size.height * 0.30);
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.52);
    _drawLabel(canvas, 'd', size.width * 0.55, size.height * 0.78);
    _drawLabel(canvas, 'e', size.width * 0.28, size.height * 0.70);
    _drawLabel(canvas, 'f', size.width * 0.22, size.height * 0.45);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegularHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    Offset p1 = Offset(size.width * 0.3, size.height * 0.15);
    Offset p2 = Offset(size.width * 0.7, size.height * 0.15);
    Offset p3 = Offset(size.width * 0.9, size.height * 0.5);
    Offset p4 = Offset(size.width * 0.7, size.height * 0.85);
    Offset p5 = Offset(size.width * 0.3, size.height * 0.85);
    Offset p6 = Offset(size.width * 0.1, size.height * 0.5);

    Path path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..lineTo(p5.dx, p5.dy)..lineTo(p6.dx, p6.dy)..close();
    canvas.drawPath(path, paint);

    // Ticks to denote regular hexagon
    _drawTick(canvas, p1, p2, tickPaint);
    _drawTick(canvas, p2, p3, tickPaint);
    _drawTick(canvas, p3, p4, tickPaint);
    _drawTick(canvas, p4, p5, tickPaint);
    _drawTick(canvas, p5, p6, tickPaint);
    _drawTick(canvas, p6, p1, tickPaint);

    _drawLabel(canvas, 'a', size.width * 0.35, size.height * 0.28);
    _drawLabel(canvas, 'b', size.width * 0.65, size.height * 0.28);
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.50);
    _drawLabel(canvas, 'd', size.width * 0.65, size.height * 0.72);
    _drawLabel(canvas, 'e', size.width * 0.35, size.height * 0.72);
    _drawLabel(canvas, 'f', size.width * 0.25, size.height * 0.50);
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

class ExteriorHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Offset p1 = Offset(size.width * 0.35, size.height * 0.25);
    Offset p2 = Offset(size.width * 0.65, size.height * 0.25);
    Offset p3 = Offset(size.width * 0.8, size.height * 0.5);
    Offset p4 = Offset(size.width * 0.65, size.height * 0.75);
    Offset p5 = Offset(size.width * 0.35, size.height * 0.75);
    Offset p6 = Offset(size.width * 0.2, size.height * 0.5);

    // Draw Extended Lines (Pinwheel)
    _drawExtendedLine(canvas, p6, p1, paint);
    _drawExtendedLine(canvas, p1, p2, paint);
    _drawExtendedLine(canvas, p2, p3, paint);
    _drawExtendedLine(canvas, p3, p4, paint);
    _drawExtendedLine(canvas, p4, p5, paint);
    _drawExtendedLine(canvas, p5, p6, paint);

    // Interior Labels
    _drawLabel(canvas, 'a', size.width * 0.40, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.60, size.height * 0.35);
    _drawLabel(canvas, 'c', size.width * 0.68, size.height * 0.50);
    _drawLabel(canvas, 'd', size.width * 0.60, size.height * 0.65);
    _drawLabel(canvas, 'e', size.width * 0.40, size.height * 0.65);
    _drawLabel(canvas, 'f', size.width * 0.32, size.height * 0.50);

    // Exterior Labels
    _drawLabel(canvas, 'g', size.width * 0.45, size.height * 0.15); // ext top-left
    _drawLabel(canvas, 'h', size.width * 0.80, size.height * 0.25); // ext top-right
    _drawLabel(canvas, 'i', size.width * 0.85, size.height * 0.65); // ext right
    _drawLabel(canvas, 'j', size.width * 0.55, size.height * 0.85); // ext bot-right
    _drawLabel(canvas, 'k', size.width * 0.20, size.height * 0.75); // ext bot-left
    _drawLabel(canvas, 'l', size.width * 0.15, size.height * 0.35); // ext left
  }

  void _drawExtendedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    // Extend past p2
    Offset p3 = Offset(p2.dx + dx * 0.5, p2.dy + dy * 0.5);
    canvas.drawLine(p1, p3, paint);
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoatHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset tl = Offset(size.width * 0.1, size.height * 0.4);
    Offset tr = Offset(size.width * 0.9, size.height * 0.4);
    Offset rCurve = Offset(size.width * 0.8, size.height * 0.8);
    Offset br = Offset(size.width * 0.6, size.height * 0.9);
    Offset bl = Offset(size.width * 0.4, size.height * 0.9);
    Offset lCurve = Offset(size.width * 0.2, size.height * 0.8);

    Path path = Path()
      ..moveTo(tl.dx, tl.dy) // Top Left Edge
      ..lineTo(tr.dx, tr.dy) // Top Right Edge
      ..lineTo(rCurve.dx, rCurve.dy) // Right Curve
      ..lineTo(br.dx, br.dy) // Bottom Right
      ..lineTo(bl.dx, bl.dy) // Bottom Left
      ..lineTo(lCurve.dx, lCurve.dy) // Left Curve
      ..close();
    canvas.drawPath(path, paint);

    // Angle arcs with arrows to show symmetry (Top angles a & b)
    canvas.drawArc(Rect.fromCircle(center: tl, radius: 25), -math.pi * 0.4, math.pi * 0.4, false, paint);
    _drawAngleArrow(canvas, tl, 25, -math.pi * 0.2, tickPaint..style=PaintingStyle.fill);

    canvas.drawArc(Rect.fromCircle(center: tr, radius: 25), math.pi, math.pi * 0.4, false, paint);
    _drawAngleArrow(canvas, tr, 25, math.pi * 1.2, tickPaint..style=PaintingStyle.fill);

    // Side ticks to show side symmetry on the curved edges
    _drawSideTick(canvas, tl, lCurve, 1, paint);
    _drawSideTick(canvas, tr, rCurve, 1, paint);

    _drawLabel(canvas, 'a', size.width * 0.25, size.height * 0.50); // Top Left Edge
    _drawLabel(canvas, 'b', size.width * 0.75, size.height * 0.50); // Top Right Edge
    _drawLabel(canvas, 'c', size.width * 0.70, size.height * 0.72); // Right Curve
    _drawLabel(canvas, 'd', size.width * 0.55, size.height * 0.80); // Bottom Right
    _drawLabel(canvas, 'e', size.width * 0.45, size.height * 0.80); // Bottom Left
    _drawLabel(canvas, 'f', size.width * 0.30, size.height * 0.72); // Left Curve
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