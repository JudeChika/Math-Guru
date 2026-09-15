import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'n_gon_angles_models.dart';
import 'n_gon_angles_solver.dart';

class NSidedPolygonScreen extends StatefulWidget {
  const NSidedPolygonScreen({super.key});

  @override
  State<NSidedPolygonScreen> createState() => _NSidedPolygonScreenState();
}

class _NSidedPolygonScreenState extends State<NSidedPolygonScreen> {
  int _selectedMode = 0; // 0 = Regular, 1 = Irregular

  // Mode 1: Regular
  String _selectedProperty = 'n';
  final List<Map<String, String>> _properties = [
    {'val': 'n', 'label': 'Number of Sides (n)'},
    {'val': 'int_sum', 'label': 'Sum of Interior Angles'},
    {'val': 'one_int', 'label': 'One Interior Angle'},
    {'val': 'one_ext', 'label': 'One Exterior Angle'},
  ];
  final TextEditingController _propertyValueController = TextEditingController();

  // Mode 2: Irregular
  final TextEditingController _nSidesController = TextEditingController(text: "4");
  final TextEditingController _irregularAnglesController = TextEditingController();

  NSidedResult? _result;

  @override
  void dispose() {
    _propertyValueController.dispose();
    _nSidesController.dispose();
    _irregularAnglesController.dispose();
    super.dispose();
  }

  void _clearResults() {
    setState(() {
      _result = null;
    });
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    _clearResults();

    if (_selectedMode == 0) {
      if (_propertyValueController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value.')));
        return;
      }
      setState(() {
        _result = NSidedPolygonSolver.solveRegular(_selectedProperty, _propertyValueController.text);
      });
    } else {
      if (_nSidesController.text.trim().isEmpty || _irregularAnglesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter n and the angles.')));
        return;
      }
      int? n = int.tryParse(_nSidesController.text.trim());
      if (n == null) {
        setState(() => _result = NSidedResult(nSides: 0, mode: '', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid number of sides."));
        return;
      }
      setState(() {
        _result = NSidedPolygonSolver.solveIrregular(n, _irregularAnglesController.text);
      });
    }
  }

  Widget _buildInputForms(ThemeData theme) {
    if (_selectedMode == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Regular Polygons have equal sides and angles. Enter ONE known property, and we'll calculate the rest!"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.deepPurple.shade200), borderRadius: BorderRadius.circular(12), color: Colors.white),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProperty,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                items: _properties.map((p) => DropdownMenuItem(value: p['val'], child: Text("I know the: ${p['label']!}", style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedProperty = val;
                      _clearResults();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _propertyValueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter the Value",
              hintText: "e.g. 5, or 540, or 108",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple),
            ),
            onSubmitted: (_) => _solve(),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperBanner("Irregular Polygons have unequal angles. Enter 'n', then list all the algebraic angles separated by commas."),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _nSidesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "Sides (n)",
                    hintText: "e.g. 4",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _irregularAnglesController,
                  decoration: InputDecoration(
                    labelText: "Comma-separated Angles",
                    hintText: "e.g. x, x+10, 90, 2x",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _solve(),
                ),
              ),
            ],
          ),
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

  Widget _buildResultView(ThemeData theme) {
    int drawnSides = _result!.nSides;
    if (drawnSides < 3) drawnSides = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("1. Polygon Visualizer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade100),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: CustomPaint(
            painter: ParametricPolygonPainter(sides: drawnSides),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. Final Solved Properties:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAngles.entries.map((entry) {
            bool isSpecial = entry.key == 'Number of Sides (n)' || entry.key == 'Name of Polygon';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: isSpecial ? Colors.deepPurple.shade50 : Colors.green.shade50,
                  border: Border.all(color: isSpecial ? Colors.deepPurple.shade200 : Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${entry.key}: ", style: TextStyle(fontWeight: FontWeight.bold, color: isSpecial ? Colors.deepPurple : Colors.black87, fontSize: 16)),
                  Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold, color: isSpecial ? Colors.deepPurple : Colors.green, fontSize: 18)),
                ],
              ),
            );
          }).toList(),
        ),

        if (_result!.workings.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text("3. Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                      const SizedBox(height: 24)
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
        Text("${_result!.workings.isNotEmpty ? '4' : '3'}. Step-by-Step Breakdown:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Polygons with n-Sides')),
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
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Regular Polygons", style: TextStyle(fontWeight: FontWeight.bold))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Irregular Polygons", style: TextStyle(fontWeight: FontWeight.bold))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _clearResults();
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),

            _buildInputForms(theme),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text("Solve Polygon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              _buildResultView(theme),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class ParametricPolygonPainter extends CustomPainter {
  final int sides;

  ParametricPolygonPainter({required this.sides});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = math.min(cx, cy) * 0.90;

    int drawSides = sides;
    bool isHuge = sides > 12;

    // If n is huge, we only draw a partial polygon to represent "many sides" conceptually
    if (isHuge) drawSides = 16;

    List<Offset> pts = [];
    double step = 2 * math.pi / drawSides;

    for (int i = 0; i < drawSides; i++) {
      double angle = -math.pi / 2 + i * step;
      pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    if (!isHuge) {
      // Draw closed normal polygon
      Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < drawSides; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      path.close();
      canvas.drawPath(path, paint);

      // Draw red side tick marks to indicate it is a Regular Polygon
      final tickPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke;
      for (int i = 0; i < drawSides; i++) {
        Offset p1 = pts[i];
        Offset p2 = pts[(i + 1) % drawSides];
        Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        double dx = p2.dx - p1.dx;
        double dy = p2.dy - p1.dy;
        double len = math.sqrt(dx*dx + dy*dy);
        double perpX = -dy / len * 6;
        double perpY = dx / len * 6;
        canvas.drawLine(Offset(mid.dx - perpX, mid.dy - perpY), Offset(mid.dx + perpX, mid.dy + perpY), tickPaint);
      }

      // Draw n-label in the middle
      _drawLabel(canvas, 'n = $sides', cx, cy, 20);
    } else {
      // Draw a partial polygon with dashed/dotted open end to imply continuing sides
      Path solidPath = Path()..moveTo(pts[0].dx, pts[0].dy);
      // Draw top half solid
      for (int i = 1; i <= 8; i++) {
        solidPath.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(solidPath, paint);

      // Draw dashed line for bottom to imply continuation
      final dashPaint = Paint()..color = Colors.grey..strokeWidth = 3..style = PaintingStyle.stroke;
      for (int i = 9; i < 15; i++) {
        if (i % 2 != 0) {
          canvas.drawLine(pts[i], pts[i+1], dashPaint);
        }
      }

      _drawLabel(canvas, 'n = $sides', cx, cy, 20);
      _drawLabel(canvas, '...', cx, cy + r * 0.7, 24); // Implies continuing sides
    }
  }

  void _drawLabel(Canvas canvas, String text, double x, double y, double fontSize) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: Colors.deepPurple, fontSize: fontSize, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant ParametricPolygonPainter oldDelegate) {
    return oldDelegate.sides != sides;
  }
}