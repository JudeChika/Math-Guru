import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'bisect_angle_logic.dart';
import 'bisect_angle_models.dart';
import 'dart:math' as math;

class BisectAngleScreen extends StatefulWidget {
  const BisectAngleScreen({super.key});

  @override
  State<BisectAngleScreen> createState() => _BisectAngleScreenState();
}

class _BisectAngleScreenState extends State<BisectAngleScreen> {
  int _inputMode = 1; // 0: AI, 1: Manual

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Manual Controllers
  final TextEditingController _angleNameCtrl = TextEditingController(text: "ABC");
  final TextEditingController _angleSizeCtrl = TextEditingController(text: "60");
  final TextEditingController _armLengthCtrl = TextEditingController(text: "6");

  BisectAngleResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _aiController.dispose();
    _angleNameCtrl.dispose();
    _angleSizeCtrl.dispose();
    _armLengthCtrl.dispose();
    _graphTransformController.dispose();
    super.dispose();
  }

  Future<void> _solveWithAI() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final inputText = _aiController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem.')));
      return;
    }

    setState(() { _isLoadingAI = true; _result = null; });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final prompt = '''
      You are a strict data extractor for JSS2 Geometry Constructions (Angle Bisection).
      Read the word problem and extract the angle parameters.
      
      RULES:
      1. ONLY return a valid JSON object. No markdown, no explanations.
      2. "angleName" is a 3-letter string (e.g. "PQR" or "ABC"). If a single letter is given (e.g. "Angle B"), return "ABC".
      3. "angleSize" must be a pure number in degrees (e.g. "120", "65").
      4. "armLength" is optional line length (e.g. "6" or "8"). Leave as "6" if not mentioned.
      
      JSON FORMAT:
      {
         "angleName": "PQR",
         "angleSize": "120",
         "armLength": "6"
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        _angleNameCtrl.text = jsonMap['angleName']?.toString() ?? 'ABC';
        _angleSizeCtrl.text = jsonMap['angleSize']?.toString() ?? '60';
        _armLengthCtrl.text = jsonMap['armLength']?.toString() ?? '6';
        _inputMode = 1; // Switch to Manual view to show mapped data
      });

      _solve();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Translation failed. Please manually enter values.')));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solve() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _result = BisectAngleLogic.solve(
        angleNameStr: _angleNameCtrl.text,
        angleSizeStr: _angleSizeCtrl.text,
        armLengthStr: _armLengthCtrl.text,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        // Auto center the drawing
        final screenWidth = MediaQuery.of(context).size.width - 32;
        double dx = (800 - screenWidth) / 2;
        double dy = (800 - 350) / 2 + 50;
        _graphTransformController.value = Matrix4.identity()..translate(-dx, -dy);
      }
    });
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("✨ AI Word Problem", style: TextStyle(fontWeight: FontWeight.bold))),
              1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("🛠️ Manual Builder", style: TextStyle(fontWeight: FontWeight.bold))),
            },
            onValueChanged: (int? value) { if (value != null) setState(() => _inputMode = value); },
            thumbColor: Colors.deepPurple.shade100, backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),

        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text("Paste an angle bisection problem. The AI will extract the angle and draw the compass steps automatically!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. Draw an angle PQR of 112 degrees. Construct its bisector.", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Bisect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(child: Text("Define the angle you want to cut in half. The system will simulate the exact ruler and compass strokes!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _angleNameCtrl, textAlign: TextAlign.center, keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Angle Name", hintText: "e.g. ABC", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _angleSizeCtrl, textAlign: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Angle Size (°)", hintText: "e.g. 60", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _armLengthCtrl, textAlign: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: "Arm Length (cm)", hintText: "e.g. 6", isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solve, icon: const Icon(Icons.architecture, color: Colors.white), label: const Text("Bisect Angle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("1. Plain Paper Construction:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
            Text("💡 Pan & Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),

        // Virtual Plain Paper
        Container(
          height: 350, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.deepPurple.shade200, width: 2), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _graphTransformController,
              constrained: false, boundaryMargin: const EdgeInsets.all(400), minScale: 0.2, maxScale: 4.0,
              child: Container(
                width: 800, height: 800, color: Colors.white,
                child: CustomPaint(painter: BisectionPainter(result: _result!)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. Results & Measurements:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: _result!.finalAnswers.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.green.shade50, border: Border.all(color: Colors.green.shade200), borderRadius: BorderRadius.circular(12)),
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
        const Text("3. Step-by-Step Instructions:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, foregroundColor: Colors.deepPurple, child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)))
                ]
              ],
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('15-2 Bisect any Angle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM BISECTION PAINTER (Simulating Ruler & Compasses)
// -----------------------------------------------------------------------------
class BisectionPainter extends CustomPainter {
  final BisectAngleResult result;

  BisectionPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final armPaint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final bisectorPaint = Paint()..color = Colors.deepPurple..strokeWidth = 3..style = PaintingStyle.stroke;
    final arcPaint = Paint()..color = Colors.red.shade700..strokeWidth = 2..style = PaintingStyle.stroke;
    final pointPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final textPaint = Paint()..color = Colors.blue.shade900..style = PaintingStyle.fill;

    // Viewport Center Origin
    double cx = size.width / 2 - 50; // Shift left slightly to make room for the wide angle
    double cy = size.height / 2 + 50;

    // Scale Logic: Max length is the arm length
    double pxPerCm = (size.width / 2) / (result.arm2End.x + 2);

    Offset toPx(BisectPoint p) {
      // Invert Y for standard Cartesian plane rendering
      return Offset(cx + p.x * pxPerCm, cy - p.y * pxPerCm);
    }

    Offset vPt = toPx(result.vertex);
    Offset arm1 = toPx(result.arm1End);
    Offset arm2 = toPx(result.arm2End);
    Offset pR = toPx(result.pointR);
    Offset pP = toPx(result.pointP);
    Offset pQ = toPx(result.pointQ);

    // 1. Draw the Base Arcs and Intersections (To go *under* the arms)
    // Base Arc (from vertex)
    Rect baseRect = Rect.fromCircle(center: vPt, radius: result.baseArc.radius * pxPerCm);
    // Canvas sweeps clockwise. Because we inverted Y, we must negate angles.
    canvas.drawArc(baseRect, -result.baseArc.startAngle - result.baseArc.sweepAngle, result.baseArc.sweepAngle, false, arcPaint);

    // Intersecting Arcs from P and Q
    Rect rectP = Rect.fromCircle(center: pP, radius: result.intersectArcP.radius * pxPerCm);
    canvas.drawArc(rectP, -result.intersectArcP.startAngle - result.intersectArcP.sweepAngle, result.intersectArcP.sweepAngle, false, arcPaint);

    Rect rectQ = Rect.fromCircle(center: pQ, radius: result.intersectArcQ.radius * pxPerCm);
    canvas.drawArc(rectQ, -result.intersectArcQ.startAngle - result.intersectArcQ.sweepAngle, result.intersectArcQ.sweepAngle, false, arcPaint);

    // 2. Draw the Angle Arms
    canvas.drawLine(vPt, arm1, armPaint);
    canvas.drawLine(vPt, arm2, armPaint);

    // Draw Arrows at ends of arms to indicate rays
    _drawArrow(canvas, vPt, arm1, Colors.black87);
    _drawArrow(canvas, vPt, arm2, Colors.black87);

    // 3. Draw the Bisector Line
    // Extend bisector slightly past R
    double extFactor = 1.3;
    Offset extR = Offset(vPt.dx + (pR.dx - vPt.dx) * extFactor, vPt.dy + (pR.dy - vPt.dy) * extFactor);
    canvas.drawLine(vPt, extR, bisectorPaint);
    _drawArrow(canvas, vPt, extR, Colors.deepPurple);

    // 4. Mark Important Points
    canvas.drawCircle(pP, 4, textPaint);
    canvas.drawCircle(pQ, 4, textPaint);
    canvas.drawCircle(pR, 4, textPaint);
    canvas.drawCircle(vPt, 4, pointPaint);

    // 5. Labels
    _drawText(canvas, result.vertex.name, vPt.dx - 15, vPt.dy + 15, isBold: true);
    _drawText(canvas, result.arm1End.name, arm1.dx - 15, arm1.dy - 15, isBold: true);
    _drawText(canvas, result.arm2End.name, arm2.dx + 15, arm2.dy + 15, isBold: true);
    _drawText(canvas, "P", pP.dx - 15, pP.dy - 10, color: Colors.blue.shade900, isBold: true);
    _drawText(canvas, "Q", pQ.dx + 10, pQ.dy + 15, color: Colors.blue.shade900, isBold: true);
    _drawText(canvas, "R", pR.dx + 15, pR.dy - 10, color: Colors.blue.shade900, isBold: true);

    // 6. Draw Small Angle Sweeps for the Bisected Angles
    double smallRadius = pxPerCm * 1.5;
    double rads = result.totalAngle * math.pi / 180;
    double halfRads = rads / 2;
    Paint smallArcPaint = Paint()..color = Colors.deepPurple..strokeWidth=1.5..style=PaintingStyle.stroke;

    // Bottom bisected angle (0 to half)
    canvas.drawArc(Rect.fromCircle(center: vPt, radius: smallRadius), 0, -halfRads, false, smallArcPaint);
    // Top bisected angle (half to full)
    canvas.drawArc(Rect.fromCircle(center: vPt, radius: smallRadius + 4), -halfRads, -halfRads, false, smallArcPaint);

    // Angle Value Text
    String fmtAngle = _fmt(result.bisectedAngle);
    _drawText(canvas, "$fmtAngle°", vPt.dx + (smallRadius + 20) * math.cos(halfRads/2), vPt.dy - (smallRadius + 20) * math.sin(halfRads/2), color: Colors.deepPurple, isBold: true);
    _drawText(canvas, "$fmtAngle°", vPt.dx + (smallRadius + 20) * math.cos(halfRads + halfRads/2), vPt.dy - (smallRadius + 20) * math.sin(halfRads + halfRads/2), color: Colors.deepPurple, isBold: true);
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Color color) {
    if (p1 == p2) return;
    double dX = p2.dx - p1.dx;
    double dY = p2.dy - p1.dy;
    double angle = math.atan2(dY, dX);
    double arrowLength = 12;
    double arrowAngle = math.pi / 6;

    Path path = Path();
    path.moveTo(p2.dx, p2.dy);
    path.lineTo(p2.dx - arrowLength * math.cos(angle - arrowAngle), p2.dy - arrowLength * math.sin(angle - arrowAngle));
    path.lineTo(p2.dx - arrowLength * math.cos(angle + arrowAngle), p2.dy - arrowLength * math.sin(angle + arrowAngle));
    path.close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
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