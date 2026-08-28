import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'geometry_angles_models.dart';
import 'geometry_angles_solver.dart';

class AnglesRulesScreen extends StatefulWidget {
  const AnglesRulesScreen({super.key});

  @override
  State<AnglesRulesScreen> createState() => _AnglesRulesScreenState();
}

class _AnglesRulesScreenState extends State<AnglesRulesScreen> {
  int _selectedDiagram = 0;

  // Controllers for Straight Line / Point
  final List<TextEditingController> _dynamicControllers = [TextEditingController(), TextEditingController()];

  // Controllers for Intersecting Lines (X-Shape)
  final Map<String, TextEditingController> _intersectingControllers = {
    'top': TextEditingController(), 'right': TextEditingController(),
    'bottom': TextEditingController(), 'left': TextEditingController(),
  };

  // Controllers for Parallel Lines (8 inputs)
  final Map<String, TextEditingController> _parallelControllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(), 'd': TextEditingController(),
    'e': TextEditingController(), 'f': TextEditingController(), 'g': TextEditingController(), 'h': TextEditingController(),
  };

  // Controllers for Complex Triangle & Parallels (7 inputs)
  final Map<String, TextEditingController> _complexControllers = {
    'a': TextEditingController(), 'b': TextEditingController(), 'c': TextEditingController(),
    'd': TextEditingController(), 'e': TextEditingController(),
    'f': TextEditingController(), 'g': TextEditingController(),
  };

  AnglesRuleResult? _result;

  @override
  void dispose() {
    for (var c in _dynamicControllers) { c.dispose(); }
    for (var c in _intersectingControllers.values) { c.dispose(); }
    for (var c in _parallelControllers.values) { c.dispose(); }
    for (var c in _complexControllers.values) { c.dispose(); }
    super.dispose();
  }

  void _addDynamicInput() {
    setState(() => _dynamicControllers.add(TextEditingController()));
  }

  void _removeDynamicInput(int index) {
    setState(() {
      _dynamicControllers[index].dispose();
      _dynamicControllers.removeAt(index);
    });
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    if (_selectedDiagram == 0 || _selectedDiagram == 1) {
      String type = _selectedDiagram == 0 ? 'Straight Line' : 'Point';
      List<String> inputs = _dynamicControllers.map((c) => c.text).toList();
      setState(() => _result = AnglesRulesSolver.solveAlgebraicAngles(inputs, type));
    } else if (_selectedDiagram == 2) {
      Map<String, String> inputs = {};
      _intersectingControllers.forEach((key, controller) => inputs[key] = controller.text);
      setState(() => _result = AnglesRulesSolver.solveIntersectingLines(inputs));
    } else if (_selectedDiagram == 3) {
      Map<String, String> inputs = {};
      _parallelControllers.forEach((key, controller) => inputs[key] = controller.text);
      setState(() => _result = AnglesRulesSolver.solveParallelLines(inputs));
    } else {
      Map<String, String> inputs = {};
      _complexControllers.forEach((key, controller) => inputs[key] = controller.text);
      setState(() => _result = AnglesRulesSolver.solveTriangleParallels(inputs));
    }
  }

  Widget _buildVerticalDiagramList() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildListCard(0, "Angles on a Straight Line", StraightLinePainter()),
          _buildListCard(1, "Angles at a Point", PointPainter()),
          _buildListCard(2, "Intersecting Lines (X-Shape)", IntersectingLinesPainter()),
          _buildListCard(3, "Parallel Lines & Transversal", ParallelLinesPainter()),
          _buildListCard(4, "Triangle Between Parallels", TriangleParallelsPainter()),
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
        });
      },
      child: Container(
        height: 100,
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
    if (_selectedDiagram == 0 || _selectedDiagram == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Enter the angles (Use variables like x, y, p, q):", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(_dynamicControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dynamicControllers[index],
                      decoration: InputDecoration(
                        labelText: "Angle ${index + 1}",
                        hintText: "e.g. 45, x, or 2x+y",
                        prefixIcon: const Icon(Icons.architecture, color: Colors.deepPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (_dynamicControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeDynamicInput(index),
                    )
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addDynamicInput,
            icon: const Icon(Icons.add, color: Colors.deepPurple),
            label: const Text("Add Another Angle", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          )
        ],
      );
    } else if (_selectedDiagram == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter EXACTLY ONE known angle number, and use variables (x, y) for the unknowns. The system will map out the rest!"),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('top', _intersectingControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('right', _intersectingControllers)) ]),
          const SizedBox(height: 16),
          Row(children: [ Expanded(child: _buildGridField('left', _intersectingControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('bottom', _intersectingControllers)) ]),
        ],
      );
    } else if (_selectedDiagram == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter EXACTLY ONE known angle number, and put your variables (x, y) in the other boxes. The system will map out the rest!"),
          const SizedBox(height: 16),
          const Text("Top Intersection:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('b', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('c', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('d', _parallelControllers)) ]),
          const SizedBox(height: 16),
          const Text("Bottom Intersection:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('e', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('f', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('g', _parallelControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('h', _parallelControllers)) ]),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Enter at least TWO related numbers to solve the complex diagram. Mix them with variables (x, y, z) as needed."),
          const SizedBox(height: 16),
          const Text("Top Line (Straight Line):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('a', _complexControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('b', _complexControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('c', _complexControllers)) ]),
          const SizedBox(height: 16),
          const Text("Bottom Line (Intersections):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildGridField('d', _complexControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('e', _complexControllers)), const SizedBox(width: 16), Expanded(child: _buildGridField('f', _complexControllers)), const SizedBox(width: 8), Expanded(child: _buildGridField('g', _complexControllers)) ]),
        ],
      );
    }
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

  Widget _buildGridField(String label, Map<String, TextEditingController> map) {
    return TextField(
      controller: map[label],
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
      appBar: AppBar(title: const Text('Interactive Angles & Rules')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("1. Select a Diagram Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              label: const Text("Solve Geometry", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

void _drawHelperLabel(Canvas canvas, String text, double x, double y) {
  TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr
  );
  tp.layout();
  tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
}

class StraightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    double y = size.height - 20;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    Offset center = Offset(size.width / 2, y);
    canvas.drawCircle(center, 4, Paint()..color = Colors.deepPurple);
    canvas.drawLine(center, Offset(size.width * 0.7, 20), paint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: 25), math.pi, math.pi, false, Paint()..color = Colors.amber.shade700..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(center, Offset(size.width * 0.2, size.height * 0.2), paint);
    canvas.drawLine(center, Offset(size.width * 0.9, size.height * 0.3), paint);
    canvas.drawLine(center, Offset(size.width * 0.8, size.height * 0.9), paint);
    canvas.drawLine(center, Offset(size.width * 0.1, size.height * 0.8), paint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.deepPurple);
    canvas.drawCircle(center, 20, Paint()..color = Colors.amber.shade700..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IntersectingLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.2), Offset(size.width * 0.9, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.8), Offset(size.width * 0.9, size.height * 0.2), paint);

    double cx = size.width / 2;
    double cy = size.height / 2;

    _drawHelperLabel(canvas, 'top', cx, cy - 25);
    _drawHelperLabel(canvas, 'bottom', cx, cy + 25);
    _drawHelperLabel(canvas, 'left', cx - 35, cy);
    _drawHelperLabel(canvas, 'right', cx + 35, cy);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParallelLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    double y1 = size.height * 0.35;
    double y2 = size.height * 0.65;
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height), Offset(size.width * 0.7, 0), paint..color=Colors.deepPurple);

    double topX = size.width * 0.58;
    _drawHelperLabel(canvas, 'a', topX - 18, y1 - 12); _drawHelperLabel(canvas, 'b', topX + 18, y1 - 12);
    _drawHelperLabel(canvas, 'c', topX - 20, y1 + 14); _drawHelperLabel(canvas, 'd', topX + 16, y1 + 14);

    double botX = size.width * 0.42;
    _drawHelperLabel(canvas, 'e', botX - 18, y2 - 12); _drawHelperLabel(canvas, 'f', botX + 18, y2 - 12);
    _drawHelperLabel(canvas, 'g', botX - 20, y2 + 14); _drawHelperLabel(canvas, 'h', botX + 16, y2 + 14);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleParallelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke;
    final transPaint = Paint()..color = Colors.deepPurple..strokeWidth = 3..style = PaintingStyle.stroke;

    double y1 = size.height * 0.333;
    double y2 = size.height * 0.75;

    // Draw Parallels
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);

    // Draw Triangle Transversals intersecting at top line
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.1, size.height), transPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.9, size.height), transPaint);

    double apexX = size.width * 0.5;
    double botLeftX = size.width * 0.25;
    double botRightX = size.width * 0.75;

    // Top Intersection Labels
    _drawHelperLabel(canvas, 'a', apexX - 35, y1 + 12);
    _drawHelperLabel(canvas, 'b', apexX, y1 + 35);
    _drawHelperLabel(canvas, 'c', apexX + 35, y1 + 12);

    // Bottom Left Labels
    _drawHelperLabel(canvas, 'd', botLeftX - 25, y2 - 15);
    _drawHelperLabel(canvas, 'e', botLeftX + 25, y2 - 15);

    // Bottom Right Labels
    _drawHelperLabel(canvas, 'f', botRightX - 25, y2 - 15);
    _drawHelperLabel(canvas, 'g', botRightX + 25, y2 - 15);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}