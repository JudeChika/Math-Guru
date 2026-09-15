import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/triangle_angles/triangle_angles_model.dart';
import 'triangle_angles_solver.dart';

class TriangleAnglesScreen extends StatefulWidget {
  const TriangleAnglesScreen({super.key});

  @override
  State<TriangleAnglesScreen> createState() => _TriangleAnglesScreenState();
}

class _TriangleAnglesScreenState extends State<TriangleAnglesScreen> {
  int _selectedDiagram = 0;

  // Single shared map for all possible triangle variables (a through f)
  final Map<String, TextEditingController> _controllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(), 'f': TextEditingController(),
  };

  TriangleAnglesResult? _result;

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
      _result = AnglesRulesSolver.solveTriangleDiagram(inputs, _selectedDiagram);
    });
  }

  Widget _buildVerticalDiagramList() {
    return Container(
      height: 380, // Taller to fit all the beautiful diagrams
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildListCard(0, "Basic Triangle (Interior)", BasicTrianglePainter()),
          _buildListCard(1, "Triangle with Exterior Angles", ExteriorTrianglePainter()),
          _buildListCard(2, "Isosceles Triangle", IsoscelesTrianglePainter()),
          _buildListCard(3, "Equilateral Triangle", EquilateralTrianglePainter()),
          _buildListCard(4, "Composite Triangles (Joined)", CompositeTrianglePainter()),
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
        _buildHelperBanner("Enter the known angles or variables (e.g. 50, x, 2x). Leave unknowns blank."),
        const SizedBox(height: 16),

        if (_selectedDiagram == 0 || _selectedDiagram == 2) ...[
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
        ] else if (_selectedDiagram == 1) ...[
          const Text("Interior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          const Text("Exterior Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('d')), const SizedBox(width: 8), Expanded(child: _buildGridField('e')) ]),
        ] else if (_selectedDiagram == 3) ...[
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('d')), const Spacer(), const Spacer() ]),
        ] else if (_selectedDiagram == 4) ...[
          const Text("Apex Angles (Top):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a')), const SizedBox(width: 8), Expanded(child: _buildGridField('d')) ]),
          const SizedBox(height: 16),
          const Text("Left Base Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('b')), const SizedBox(width: 8), Expanded(child: _buildGridField('c')) ]),
          const SizedBox(height: 16),
          const Text("Right Base Angles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('e')), const SizedBox(width: 8), Expanded(child: _buildGridField('f')) ]),
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
      appBar: AppBar(title: const Text('Angles in a Triangle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select a Triangle Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              label: const Text("Solve Triangle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

class BasicTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.28, size.height * 0.72);
    _drawLabel(canvas, 'c', size.width * 0.72, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExteriorTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;

    // Draw Base Extended Line
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.8), Offset(size.width * 0.9, size.height * 0.8), paint);

    // Draw Triangle Lines
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.35, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.65, size.height * 0.8), paint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.41, size.height * 0.72);
    _drawLabel(canvas, 'c', size.width * 0.59, size.height * 0.72);

    _drawLabel(canvas, 'd', size.width * 0.25, size.height * 0.72);
    _drawLabel(canvas, 'e', size.width * 0.75, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IsoscelesTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    // Tick marks on sides
    canvas.drawLine(Offset(size.width * 0.32, size.height * 0.5), Offset(size.width * 0.38, size.height * 0.5), tickPaint);
    canvas.drawLine(Offset(size.width * 0.62, size.height * 0.5), Offset(size.width * 0.68, size.height * 0.5), tickPaint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.28, size.height * 0.72);
    _drawLabel(canvas, 'c', size.width * 0.72, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EquilateralTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;

    // Draw Extended Base
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.8), Offset(size.width * 0.95, size.height * 0.8), paint);

    // Draw Triangle
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.25, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.75, size.height * 0.8), paint);

    // Ticks on all 3 sides
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.5), Offset(size.width * 0.40, size.height * 0.5), tickPaint);
    canvas.drawLine(Offset(size.width * 0.60, size.height * 0.5), Offset(size.width * 0.65, size.height * 0.5), tickPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.76), Offset(size.width * 0.5, size.height * 0.84), tickPaint);

    _drawLabel(canvas, 'a', size.width * 0.5, size.height * 0.35);
    _drawLabel(canvas, 'b', size.width * 0.35, size.height * 0.72);
    _drawLabel(canvas, 'c', size.width * 0.65, size.height * 0.72);
    _drawLabel(canvas, 'd', size.width * 0.85, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompositeTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final splitPaint = Paint()..color = Colors.deepPurple..strokeWidth = 3..style = PaintingStyle.stroke;

    // Large Triangle Outline
    Path path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.1, size.height * 0.8)
      ..lineTo(size.width * 0.9, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    // Split Line down the middle
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.6, size.height * 0.8), splitPaint);

    // Apex Labels
    _drawLabel(canvas, 'a', size.width * 0.45, size.height * 0.32);
    _drawLabel(canvas, 'd', size.width * 0.55, size.height * 0.32);

    // Base Labels
    _drawLabel(canvas, 'b', size.width * 0.18, size.height * 0.72);
    _drawLabel(canvas, 'c', size.width * 0.53, size.height * 0.72);
    _drawLabel(canvas, 'e', size.width * 0.67, size.height * 0.72);
    _drawLabel(canvas, 'f', size.width * 0.82, size.height * 0.72);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}