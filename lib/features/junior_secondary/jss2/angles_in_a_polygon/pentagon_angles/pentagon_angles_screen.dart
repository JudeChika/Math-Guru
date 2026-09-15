import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/pentagon_angles/pentagon_angles_model.dart';
import 'dart:math' as math;
import 'pentagon_angles_solver.dart';

class PentagonAnglesScreen extends StatefulWidget {
  const PentagonAnglesScreen({super.key});

  @override
  State<PentagonAnglesScreen> createState() => _PentagonAnglesScreenState();
}

class _PentagonAnglesScreenState extends State<PentagonAnglesScreen> {
  int _selectedDiagram = 0;

  // Shared map for all possible pentagon variables (a through j)
  final Map<String, TextEditingController> _controllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(), 'f': TextEditingController(),
    'g': TextEditingController(), 'h': TextEditingController(), 'i': TextEditingController(),
    'j': TextEditingController(),
  };

  PentagonAnglesResult? _result;

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
      _result = PentagonAnglesSolver.solvePentagonDiagram(inputs, _selectedDiagram);
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
          _buildListCard(0, "Basic Pentagon", BasicPentagonPainter()),
          _buildListCard(1, "Pentagon Split (3 Triangles)", SplitPentagonPainter()),
          _buildListCard(2, "Regular Pentagon", RegularPentagonPainter()),
          _buildListCard(3, "Pentagon with Exterior Angles", ExteriorPentagonPainter()),
          _buildListCard(4, "Composite 'House' Shape", HousePentagonPainter()),
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
        _buildHelperBanner("Enter the known angles or variables (e.g. 100, x, 2x+10). Leave unknowns blank."),
        const SizedBox(height: 16),

        if (_selectedDiagram == 0 || _selectedDiagram == 1 || _selectedDiagram == 2 || _selectedDiagram == 4) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')), const Spacer() ]),
        ] else if (_selectedDiagram == 3) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')), const Spacer() ]),
          const SizedBox(height: 16),
          const Text("Exterior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('f')), const SizedBox(width: 8), Expanded(child: _buildGridField('g')), const SizedBox(width: 8), Expanded(child: _buildGridField('h')) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildGridField('i')), const SizedBox(width: 8), Expanded(child: _buildGridField('j')), const Spacer() ]),
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
      appBar: AppBar(title: const Text('Angles in a Pentagon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select a Pentagon Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              label: const Text("Solve Pentagon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class BasicPentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1) // Top
      ..lineTo(size.width * 0.9, size.height * 0.4) // Right
      ..lineTo(size.width * 0.75, size.height * 0.9) // Bottom Right
      ..lineTo(size.width * 0.25, size.height * 0.9) // Bottom Left
      ..lineTo(size.width * 0.1, size.height * 0.4) // Left
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.25);
    _drawLabel(canvas, 'b', size.width * 0.75, size.height * 0.45);
    _drawLabel(canvas, 'c', size.width * 0.65, size.height * 0.78);
    _drawLabel(canvas, 'd', size.width * 0.35, size.height * 0.78);
    _drawLabel(canvas, 'e', size.width * 0.25, size.height * 0.45);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplitPentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final splitPaint = Paint()..color = Colors.deepPurple..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset top = Offset(size.width * 0.5, size.height * 0.1);
    Offset right = Offset(size.width * 0.9, size.height * 0.4);
    Offset botRight = Offset(size.width * 0.75, size.height * 0.9);
    Offset botLeft = Offset(size.width * 0.25, size.height * 0.9);
    Offset left = Offset(size.width * 0.1, size.height * 0.4);

    Path path = Path()..moveTo(top.dx, top.dy)..lineTo(right.dx, right.dy)..lineTo(botRight.dx, botRight.dy)..lineTo(botLeft.dx, botLeft.dy)..lineTo(left.dx, left.dy)..close();
    canvas.drawPath(path, paint);

    // Draw Diagonals to split into 3 triangles
    canvas.drawLine(top, botRight, splitPaint);
    canvas.drawLine(top, botLeft, splitPaint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.28);
    _drawLabel(canvas, 'b', size.width * 0.78, size.height * 0.45);
    _drawLabel(canvas, 'c', size.width * 0.65, size.height * 0.78);
    _drawLabel(canvas, 'd', size.width * 0.35, size.height * 0.78);
    _drawLabel(canvas, 'e', size.width * 0.22, size.height * 0.45);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegularPentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    Offset top = Offset(size.width * 0.5, size.height * 0.1);
    Offset right = Offset(size.width * 0.95, size.height * 0.42);
    Offset botRight = Offset(size.width * 0.78, size.height * 0.9);
    Offset botLeft = Offset(size.width * 0.22, size.height * 0.9);
    Offset left = Offset(size.width * 0.05, size.height * 0.42);

    Path path = Path()..moveTo(top.dx, top.dy)..lineTo(right.dx, right.dy)..lineTo(botRight.dx, botRight.dy)..lineTo(botLeft.dx, botLeft.dy)..lineTo(left.dx, left.dy)..close();
    canvas.drawPath(path, paint);

    // Ticks to denote regular pentagon (all sides equal)
    _drawTick(canvas, top, right, tickPaint);
    _drawTick(canvas, right, botRight, tickPaint);
    _drawTick(canvas, botRight, botLeft, tickPaint);
    _drawTick(canvas, botLeft, left, tickPaint);
    _drawTick(canvas, left, top, tickPaint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.25);
    _drawLabel(canvas, 'b', size.width * 0.80, size.height * 0.45);
    _drawLabel(canvas, 'c', size.width * 0.68, size.height * 0.78);
    _drawLabel(canvas, 'd', size.width * 0.32, size.height * 0.78);
    _drawLabel(canvas, 'e', size.width * 0.20, size.height * 0.45);
  }

  void _drawTick(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    // Find perpendicular vector
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double len = math.sqrt(dx*dx + dy*dy);
    double perpX = -dy / len * 6;
    double perpY = dx / len * 6;
    canvas.drawLine(Offset(mid.dx - perpX, mid.dy - perpY), Offset(mid.dx + perpX, mid.dy + perpY), paint);
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExteriorPentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Offset top = Offset(size.width * 0.5, size.height * 0.2);
    Offset right = Offset(size.width * 0.8, size.height * 0.4);
    Offset botRight = Offset(size.width * 0.7, size.height * 0.8);
    Offset botLeft = Offset(size.width * 0.3, size.height * 0.8);
    Offset left = Offset(size.width * 0.2, size.height * 0.4);

    // Draw Extended Lines (Pinwheel)
    _drawExtendedLine(canvas, left, top, paint);
    _drawExtendedLine(canvas, top, right, paint);
    _drawExtendedLine(canvas, right, botRight, paint);
    _drawExtendedLine(canvas, botRight, botLeft, paint);
    _drawExtendedLine(canvas, botLeft, left, paint);

    // Interior Labels
    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.35); // top
    _drawLabel(canvas, 'b', size.width * 0.68, size.height * 0.45); // right
    _drawLabel(canvas, 'c', size.width * 0.60, size.height * 0.70); // botRight
    _drawLabel(canvas, 'd', size.width * 0.40, size.height * 0.70); // botLeft
    _drawLabel(canvas, 'e', size.width * 0.32, size.height * 0.45); // left

    // Exterior Labels
    _drawLabel(canvas, 'f', size.width * 0.58, size.height * 0.15); // ext top
    _drawLabel(canvas, 'g', size.width * 0.88, size.height * 0.52); // ext right
    _drawLabel(canvas, 'h', size.width * 0.55, size.height * 0.88); // ext botRight
    _drawLabel(canvas, 'i', size.width * 0.15, size.height * 0.75); // ext botLeft
    _drawLabel(canvas, 'j', size.width * 0.25, size.height * 0.25); // ext left
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

class HousePentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset apex = Offset(size.width * 0.5, size.height * 0.1);
    Offset tr = Offset(size.width * 0.85, size.height * 0.4);
    Offset br = Offset(size.width * 0.85, size.height * 0.9);
    Offset bl = Offset(size.width * 0.15, size.height * 0.9);
    Offset tl = Offset(size.width * 0.15, size.height * 0.4);

    Path path = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..lineTo(tl.dx, tl.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Draw side ticks to denote symmetry
    _drawSideTick(canvas, apex, tl, 1, paint);
    _drawSideTick(canvas, apex, tr, 1, paint);
    _drawSideTick(canvas, tl, bl, 2, paint);
    _drawSideTick(canvas, tr, br, 2, paint);

    // Angle arcs for symmetrical angles (b & e) and (c & d)
    // tr is b, tl is e
    canvas.drawArc(Rect.fromCircle(center: tr, radius: 20), math.pi * 0.6, math.pi * 0.7, false, paint);
    _drawAngleArrow(canvas, tr, 20, math.pi * 0.95, tickPaint..style=PaintingStyle.fill);

    canvas.drawArc(Rect.fromCircle(center: tl, radius: 20), -math.pi * 0.3, math.pi * 0.7, false, paint);
    _drawAngleArrow(canvas, tl, 20, math.pi * 0.05, tickPaint..style=PaintingStyle.fill);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.25); // Apex
    _drawLabel(canvas, 'b', size.width * 0.72, size.height * 0.45); // Top Right
    _drawLabel(canvas, 'c', size.width * 0.75, size.height * 0.80); // Bot Right
    _drawLabel(canvas, 'd', size.width * 0.25, size.height * 0.80); // Bot Left
    _drawLabel(canvas, 'e', size.width * 0.28, size.height * 0.45); // Top Left
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