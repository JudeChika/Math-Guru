import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'construct_triangles_logic.dart';
import 'construct_triangles_models.dart';

class ConstructTrianglesScreen extends StatefulWidget {
  const ConstructTrianglesScreen({super.key});

  @override
  State<ConstructTrianglesScreen> createState() => _ConstructTrianglesScreenState();
}

class _ConstructTrianglesScreenState extends State<ConstructTrianglesScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: SAS, 1: ASA, 2: SSS

  // AI Controller
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;

  // Base Controllers (Used by all)
  final TextEditingController _baseNameCtrl = TextEditingController();
  final TextEditingController _baseLenCtrl = TextEditingController();

  // SAS Specific
  final TextEditingController _sasAngleAtCtrl = TextEditingController();
  final TextEditingController _sasAngleDegCtrl = TextEditingController();
  final TextEditingController _sasSide2NameCtrl = TextEditingController();
  final TextEditingController _sasSide2LenCtrl = TextEditingController();

  // ASA Specific
  final TextEditingController _asaAngle1DegCtrl = TextEditingController();
  final TextEditingController _asaAngle2DegCtrl = TextEditingController();
  final TextEditingController _asaTopNameCtrl = TextEditingController();

  // SSS Specific
  final TextEditingController _sssSide1NameCtrl = TextEditingController();
  final TextEditingController _sssSide1LenCtrl = TextEditingController();
  final TextEditingController _sssSide2NameCtrl = TextEditingController();
  final TextEditingController _sssSide2LenCtrl = TextEditingController();

  TriangleConstructionResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _aiController.dispose();
    _baseNameCtrl.dispose(); _baseLenCtrl.dispose();
    _sasAngleAtCtrl.dispose(); _sasAngleDegCtrl.dispose(); _sasSide2NameCtrl.dispose(); _sasSide2LenCtrl.dispose();
    _asaAngle1DegCtrl.dispose(); _asaAngle2DegCtrl.dispose(); _asaTopNameCtrl.dispose();
    _sssSide1NameCtrl.dispose(); _sssSide1LenCtrl.dispose(); _sssSide2NameCtrl.dispose(); _sssSide2LenCtrl.dispose();
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
      You are a strict data extractor for JSS2 Geometry Constructions.
      Read the word problem and extract the triangle construction parameters.
      
      RULES:
      1. ONLY return a valid JSON object. No markdown, no explanations.
      2. "topicMode" must be: 0 for SAS (Two sides and an included angle), 1 for ASA (Two angles and a common side), or 2 for SSS (Three sides).
      3. Always identify one side as the "base".
      4. "sasAngleAt" must be a single letter representing the vertex.
      5. Lengths and angles should be purely numbers (e.g. "6", "62").
      
      JSON FORMAT (leave unused fields as empty strings):
      {
         "topicMode": 0,
         "baseName": "BC", "baseLen": "6",
         "sasAngleAt": "B", "sasAngleDeg": "62", "sasSide2Name": "BA", "sasSide2Len": "4",
         "asaAngle1Deg": "33", "asaAngle2Deg": "105", "asaTopName": "P",
         "sssSide1Name": "KL", "sssSide1Len": "6", "sssSide2Name": "KM", "sssSide2Len": "5"
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      if (!mounted) return;

      setState(() {
        _topicMode = jsonMap['topicMode'] ?? 0;

        // Clear all first to prevent crossover
        _baseNameCtrl.clear(); _baseLenCtrl.clear();
        _sasAngleAtCtrl.clear(); _sasAngleDegCtrl.clear(); _sasSide2NameCtrl.clear(); _sasSide2LenCtrl.clear();
        _asaAngle1DegCtrl.clear(); _asaAngle2DegCtrl.clear(); _asaTopNameCtrl.clear();
        _sssSide1NameCtrl.clear(); _sssSide1LenCtrl.clear(); _sssSide2NameCtrl.clear(); _sssSide2LenCtrl.clear();

        _baseNameCtrl.text = jsonMap['baseName']?.toString() ?? '';
        _baseLenCtrl.text = jsonMap['baseLen']?.toString() ?? '';

        if (_topicMode == 0) {
          _sasAngleAtCtrl.text = jsonMap['sasAngleAt']?.toString() ?? '';
          _sasAngleDegCtrl.text = jsonMap['sasAngleDeg']?.toString() ?? '';
          _sasSide2NameCtrl.text = jsonMap['sasSide2Name']?.toString() ?? '';
          _sasSide2LenCtrl.text = jsonMap['sasSide2Len']?.toString() ?? '';
        } else if (_topicMode == 1) {
          _asaAngle1DegCtrl.text = jsonMap['asaAngle1Deg']?.toString() ?? '';
          _asaAngle2DegCtrl.text = jsonMap['asaAngle2Deg']?.toString() ?? '';
          _asaTopNameCtrl.text = jsonMap['asaTopName']?.toString() ?? '';
        } else if (_topicMode == 2) {
          _sssSide1NameCtrl.text = jsonMap['sssSide1Name']?.toString() ?? '';
          _sssSide1LenCtrl.text = jsonMap['sssSide1Len']?.toString() ?? '';
          _sssSide2NameCtrl.text = jsonMap['sssSide2Name']?.toString() ?? '';
          _sssSide2LenCtrl.text = jsonMap['sssSide2Len']?.toString() ?? '';
        }

        _inputMode = 1; // Switch to Manual view to show mapped data
      });

      _solve();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Translation failed. Please manually enter values.')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAI = false);
      }
    }
  }

  void _onModeChanged(int? value) {
    if (value == null) return;
    setState(() {
      _topicMode = value;
      _result = null;

      // Clear fields when switching modes
      _baseNameCtrl.clear(); _baseLenCtrl.clear();
      _sasAngleAtCtrl.clear(); _sasAngleDegCtrl.clear(); _sasSide2NameCtrl.clear(); _sasSide2LenCtrl.clear();
      _asaAngle1DegCtrl.clear(); _asaAngle2DegCtrl.clear(); _asaTopNameCtrl.clear();
      _sssSide1NameCtrl.clear(); _sssSide1LenCtrl.clear(); _sssSide2NameCtrl.clear(); _sssSide2LenCtrl.clear();
    });
  }

  void _solve() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      double baseLen = double.tryParse(_baseLenCtrl.text) ?? 0;

      if (_topicMode == 0) {
        _result = ConstructTrianglesLogic.solveSAS(
          baseName: _baseNameCtrl.text, baseLen: baseLen,
          angleVertex: _sasAngleAtCtrl.text, angleDeg: double.tryParse(_sasAngleDegCtrl.text) ?? 0,
          side2Name: _sasSide2NameCtrl.text, side2Len: double.tryParse(_sasSide2LenCtrl.text) ?? 0,
        );
      } else if (_topicMode == 1) {
        _result = ConstructTrianglesLogic.solveASA(
          baseName: _baseNameCtrl.text, baseLen: baseLen,
          angle1Deg: double.tryParse(_asaAngle1DegCtrl.text) ?? 0, angle2Deg: double.tryParse(_asaAngle2DegCtrl.text) ?? 0,
          topVertexName: _asaTopNameCtrl.text,
        );
      } else if (_topicMode == 2) {
        _result = ConstructTrianglesLogic.solveSSS(
          baseName: _baseNameCtrl.text, baseLen: baseLen,
          side1Name: _sssSide1NameCtrl.text, side1Len: double.tryParse(_sssSide1LenCtrl.text) ?? 0,
          side2Name: _sssSide2NameCtrl.text, side2Len: double.tryParse(_sssSide2LenCtrl.text) ?? 0,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        // Auto center the drawing
        final screenWidth = MediaQuery.of(context).size.width - 32;
        double dx = (800 - screenWidth) / 2;
        double dy = (800 - 350) / 2 + 50; // Shift down slightly for top vertex room
        _graphTransformController.value = Matrix4.identity()..translate(-dx, -dy);
      }
    });
  }

  Widget _buildSmallField(TextEditingController controller, String hint, {bool isText = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: isText ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint, isDense: true, filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
                Expanded(child: Text("Paste a construction word problem. The AI will extract the dimensions and automatically determine if it's SAS, ASA, or SSS!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. Construct triangle KLM given KL = 6cm, LM = 7cm and KM = 5cm.", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Construct", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("SAS (Side-Angle-Side)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("ASA (Angle-Side-Angle)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("SSS (Three Sides)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              },
              onValueChanged: _onModeChanged,
              thumbColor: Colors.deepPurple.shade100,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),

          const Text("1. Base of Triangle:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Line  ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(flex: 2, child: _buildSmallField(_baseNameCtrl, "e.g. BC", isText: true)),
              const Text("  Length:  ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(flex: 3, child: _buildSmallField(_baseLenCtrl, "cm")),
            ],
          ),
          const SizedBox(height: 24),

          if (_topicMode == 0) ...[
            const Text("2. Included Angle:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("At Vertex  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sasAngleAtCtrl, "e.g. B", isText: true)),
                const Text("  Angle:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sasAngleDegCtrl, "° (Degrees)")),
              ],
            ),
            const SizedBox(height: 16),
            const Text("3. Second Side:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Line  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sasSide2NameCtrl, "e.g. BA", isText: true)),
                const Text("  Length:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sasSide2LenCtrl, "cm")),
              ],
            ),
          ] else if (_topicMode == 1) ...[
            const Text("2. Two Angles on Base:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Left Angle:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_asaAngle1DegCtrl, "°")),
                const Text("  Right Angle:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_asaAngle2DegCtrl, "°")),
              ],
            ),
            const SizedBox(height: 16),
            const Text("3. Top Vertex Name (Optional):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            _buildSmallField(_asaTopNameCtrl, "e.g. P", isText: true),
          ] else if (_topicMode == 2) ...[
            const Text("2. Left Side:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Line  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sssSide1NameCtrl, "e.g. LK", isText: true)),
                const Text("  Length:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sssSide1LenCtrl, "cm")),
              ],
            ),
            const SizedBox(height: 16),
            const Text("3. Right Side:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Line  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sssSide2NameCtrl, "e.g. MK", isText: true)),
                const Text("  Length:  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_sssSide2LenCtrl, "cm")),
              ],
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solve, icon: const Icon(Icons.architecture, color: Colors.white), label: const Text("Construct Triangle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                child: CustomPaint(painter: ConstructionPainter(result: _result!)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("2. By Measurement:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: _result!.measurements.entries.map((entry) {
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

        if (_result!.workingsLaTeX.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text("3. Mathematical Workings (Verification):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
          const SizedBox(height: 12),
          Card(
            color: Colors.deepPurple.shade50, elevation: 0.5, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                    if (_result!.workingsLaTeX[i].isEmpty) const SizedBox(height: 16)
                    else Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(_result!.workingsLaTeX[i], textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple))),
                    ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        Text("${_result!.workingsLaTeX.isNotEmpty ? '4' : '3'}. Step-by-Step Construction:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
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
      appBar: AppBar(title: const Text('15-1 Construction of Triangles')),
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
// CUSTOM CONSTRUCTION PAINTER (Ruler, Compass, Protractor Simulation)
// -----------------------------------------------------------------------------
class ConstructionPainter extends CustomPainter {
  final TriangleConstructionResult result;

  ConstructionPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final extensionPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 2..style = PaintingStyle.stroke;
    final arcPaint = Paint()..color = Colors.red.shade700..strokeWidth = 2..style = PaintingStyle.stroke;
    final pointPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;

    // Viewport Center Origin
    double cx = size.width / 2;
    double cy = size.height / 2;

    // Scale Logic: Determine max length to fit comfortably
    double maxDist = 0;
    for (var p in result.vertices) {
      if (p.x.abs() > maxDist) maxDist = p.x.abs();
      if (p.y.abs() > maxDist) maxDist = p.y.abs();
    }
    double pxPerCm = (size.width / 2) / (maxDist + 2); // Map 1 cm to screen pixels

    Offset toPx(TrianglePoint p) {
      // Offset from center. y is inverted because canvas y grows downwards
      return Offset(cx + p.x * pxPerCm, cy - p.y * pxPerCm);
    }

    Offset p1 = toPx(result.vertices[0]);
    Offset p2 = toPx(result.vertices[1]);
    Offset p3 = toPx(result.vertices[2]);

    // 1. Draw Base Line Extended (Ruler line) & Base
    canvas.drawLine(Offset(cx - 2 * pxPerCm, cy), Offset(cx + (result.vertices[1].x + 2) * pxPerCm, cy), extensionPaint);
    canvas.drawLine(p1, p2, linePaint);

    // Base Ruler Ticks
    canvas.drawLine(Offset(p1.dx, p1.dy - 6), Offset(p1.dx, p1.dy + 6), linePaint);
    canvas.drawLine(Offset(p2.dx, p2.dy - 6), Offset(p2.dx, p2.dy + 6), linePaint);

    // 2. Draw SSS Compass Arcs
    for (var arc in result.arcs) {
      Rect rect = Rect.fromCircle(center: Offset(cx + arc.centerX * pxPerCm, cy - arc.centerY * pxPerCm), radius: arc.radius * pxPerCm);
      // Canvas sweeps clockwise. Negate angles because Y is inverted.
      canvas.drawArc(rect, -arc.startAngle - arc.sweepAngle, arc.sweepAngle, false, arcPaint);

      // Draw dashed line from center to arc to show radius
      _drawDashedLine(canvas, Offset(cx + arc.centerX * pxPerCm, cy - arc.centerY * pxPerCm), p3, Paint()..color = Colors.grey..strokeWidth=1.5);
    }

    // 3. Extension Lines for Construction Aesthetics (ASA & SAS)
    if (result.mode == 'ASA' || result.mode == 'SAS') {
      if (result.mode == 'ASA') {
        Offset ext1 = Offset(p1.dx + (p3.dx - p1.dx) * 1.3, p1.dy + (p3.dy - p1.dy) * 1.3);
        Offset ext2 = Offset(p2.dx + (p3.dx - p2.dx) * 1.3, p2.dy + (p3.dy - p2.dy) * 1.3);
        canvas.drawLine(p1, ext1, extensionPaint);
        canvas.drawLine(p2, ext2, extensionPaint);
        _drawArrow(canvas, p1, ext1, Colors.grey);
        _drawArrow(canvas, p2, ext2, Colors.grey);
      } else if (result.mode == 'SAS') {
        String missingKey = result.measurements.keys.firstWhere((k) => k.startsWith("Missing Side"), orElse: () => "");
        String missingVerts = missingKey.replaceAll("Missing Side (", "").replaceAll(")", "");

        if (!missingVerts.contains(result.vertices[0].name)) {
          Offset ext1 = Offset(p1.dx + (p3.dx - p1.dx) * 1.3, p1.dy + (p3.dy - p1.dy) * 1.3);
          canvas.drawLine(p1, ext1, extensionPaint);
          _drawArrow(canvas, p1, ext1, Colors.grey);
          canvas.drawCircle(p3, 4, Paint()..color = Colors.blue); // Protractor dot
        } else {
          Offset ext2 = Offset(p2.dx + (p3.dx - p2.dx) * 1.3, p2.dy + (p3.dy - p2.dy) * 1.3);
          canvas.drawLine(p2, ext2, extensionPaint);
          _drawArrow(canvas, p2, ext2, Colors.grey);
          canvas.drawCircle(p3, 4, Paint()..color = Colors.blue); // Protractor dot
        }
      }
    }

    // 4. Draw Main Triangle Lines
    canvas.drawLine(p1, p3, linePaint);
    canvas.drawLine(p2, p3, linePaint);

    // 5. Centroid-Based Labeling Algorithm (STRICTLY BY MODE)
    Offset centroid = Offset((p1.dx + p2.dx + p3.dx) / 3, (p1.dy + p2.dy + p3.dy) / 3);

    // Helper to push text outward from the triangle's center
    void drawOutwardText(String text, Offset targetPoint, Color color, double pushAmount) {
      double dx = targetPoint.dx - centroid.dx;
      double dy = targetPoint.dy - centroid.dy;
      double len = math.sqrt(dx * dx + dy * dy);
      if (len == 0) len = 1;
      Offset pos = Offset(targetPoint.dx + (dx / len) * pushAmount, targetPoint.dy + (dy / len) * pushAmount);
      _drawText(canvas, text, pos.dx, pos.dy, isBold: true, color: color);
    }

    // Helper to draw perfectly nested interior angles
    void drawInteriorAngle(Offset vPx, TrianglePoint v, TrianglePoint adj1, TrianglePoint adj2) {
      double angleDeg = _calcAngle(v, adj1, adj2);
      Offset pAdj1 = toPx(adj1);
      Offset pAdj2 = toPx(adj2);

      double a1 = math.atan2(pAdj1.dy - vPx.dy, pAdj1.dx - vPx.dx);
      double a2 = math.atan2(pAdj2.dy - vPx.dy, pAdj2.dx - vPx.dx);

      double sweep = a2 - a1;
      if (sweep > math.pi) sweep -= 2 * math.pi;
      if (sweep < -math.pi) sweep += 2 * math.pi;

      canvas.drawArc(Rect.fromCircle(center: vPx, radius: pxPerCm * 1.2), a1, sweep, false, Paint()..color = Colors.deepPurple..strokeWidth = 1.5..style = PaintingStyle.stroke);

      double midAngle = a1 + sweep / 2;
      double push = pxPerCm * 1.8;
      _drawText(canvas, "${_fmt(angleDeg)}°", vPx.dx + math.cos(midAngle) * push, vPx.dy + math.sin(midAngle) * push, isBold: true, color: Colors.deepPurple);
    }

    // ALWAYS draw the Base length
    drawOutwardText("${_fmt(_dist(result.vertices[0], result.vertices[1]))} cm", Offset((p1.dx + p2.dx)/2, (p1.dy + p2.dy)/2), Colors.green.shade700, 20);

    // STRICT MODE FILTERING
    if (result.mode == 'SSS') {
      // SSS: Draw all 3 sides, NO angles
      drawOutwardText("${_fmt(_dist(result.vertices[0], result.vertices[2]))} cm", Offset((p1.dx + p3.dx)/2, (p1.dy + p3.dy)/2), Colors.green.shade700, 20);
      drawOutwardText("${_fmt(_dist(result.vertices[1], result.vertices[2]))} cm", Offset((p2.dx + p3.dx)/2, (p2.dy + p3.dy)/2), Colors.green.shade700, 20);
    } else if (result.mode == 'ASA') {
      // ASA: Base is drawn. Draw only the two base angles, NO other sides
      drawInteriorAngle(p1, result.vertices[0], result.vertices[1], result.vertices[2]);
      drawInteriorAngle(p2, result.vertices[1], result.vertices[0], result.vertices[2]);
    } else if (result.mode == 'SAS') {
      // SAS: Base is drawn. Find out which specific angle and side was given
      String missingKey = result.measurements.keys.firstWhere((k) => k.startsWith("Missing Side"), orElse: () => "");
      String missingVerts = missingKey.replaceAll("Missing Side (", "").replaceAll(")", "");

      if (!missingVerts.contains(result.vertices[0].name)) {
        // The side connected to v0 was given, and the angle at v0 was given
        drawOutwardText("${_fmt(_dist(result.vertices[0], result.vertices[2]))} cm", Offset((p1.dx + p3.dx)/2, (p1.dy + p3.dy)/2), Colors.green.shade700, 20);
        drawInteriorAngle(p1, result.vertices[0], result.vertices[1], result.vertices[2]);
      } else {
        // The side connected to v1 was given, and the angle at v1 was given
        drawOutwardText("${_fmt(_dist(result.vertices[1], result.vertices[2]))} cm", Offset((p2.dx + p3.dx)/2, (p2.dy + p3.dy)/2), Colors.green.shade700, 20);
        drawInteriorAngle(p2, result.vertices[1], result.vertices[0], result.vertices[2]);
      }
    }

    // Draw Vertices
    for (var p in result.vertices) {
      canvas.drawCircle(toPx(p), 4, pointPaint);
    }

    // Label Vertices
    drawOutwardText(result.vertices[0].name, p1, Colors.black87, 20);
    drawOutwardText(result.vertices[1].name, p2, Colors.black87, 20);
    drawOutwardText(result.vertices[2].name, p3, Colors.black87, 20);
  }

  double _dist(TrianglePoint p1, TrianglePoint p2) => math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2));

  double _calcAngle(TrianglePoint v, TrianglePoint adj1, TrianglePoint adj2) {
    double a = _dist(v, adj1);
    double b = _dist(v, adj2);
    double opp = _dist(adj1, adj2);
    if (a == 0 || b == 0) return 0;
    return math.acos((a*a + b*b - opp*opp) / (2 * a * b)) * 180 / math.pi;
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double distance = (p2 - p1).distance;
    double dashWidth = 6, dashSpace = 4;
    double startX = p1.dx, startY = p1.dy;
    int count = (distance / (dashWidth + dashSpace)).floor();
    double dx = (p2.dx - p1.dx) / count;
    double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) canvas.drawLine(Offset(startX, startY), Offset(startX + dx, startY + dy), paint);
      startX += dx;
      startY += dy;
    }
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