import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'linear_graphs_logic.dart';
import 'linear_graphs_models.dart';

class LinearGraphsScreen extends StatefulWidget {
  const LinearGraphsScreen({super.key});

  @override
  State<LinearGraphsScreen> createState() => _LinearGraphsScreenState();
}

class _LinearGraphsScreenState extends State<LinearGraphsScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual Builder
  bool _isLoadingAI = false;
  final TextEditingController _aiController = TextEditingController();

  // Manual Builder Controllers
  final TextEditingController _xLabelCtrl = TextEditingController(text: "Time (min)");
  final TextEditingController _yLabelCtrl = TextEditingController(text: "Distance (m)");
  final TextEditingController _rateCtrl = TextEditingController(text: "120");
  bool _isContinuous = true;

  final TextEditingController _scaleXCtrl = TextEditingController(text: "1");
  final TextEditingController _scaleYCtrl = TextEditingController(text: "100");

  final List<Map<String, TextEditingController>> _questions = [];

  LinearGraphResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _addQuestion(); // Add one blank question by default
  }

  @override
  void dispose() {
    _aiController.dispose();
    _xLabelCtrl.dispose(); _yLabelCtrl.dispose(); _rateCtrl.dispose();
    _scaleXCtrl.dispose(); _scaleYCtrl.dispose();
    for (var q in _questions) { q['val']!.dispose(); }
    _graphTransformController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'type': TextEditingController(text: "findY"), // "findY" or "findX"
        'val': TextEditingController(),
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index]['val']!.dispose();
      _questions[index]['type']!.dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _aiController.text.trim();

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a word problem.')));
      return;
    }

    setState(() { _isLoadingAI = true; _result = null; });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);

      final prompt = '''
      Extract data for JSS2 Linear Graphs.
      
      RULES:
      1. Return ONLY valid JSON. No markdown.
      2. "xLabel" and "yLabel" are axis names (e.g. "Length (m)" and "Cost (N)").
      3. "rate": Number representing how much Y increases per 1 X.
      4. "isContinuous": false if items cannot be fractioned (like glasses, pills, tickets), true otherwise (like time, distance, length, fuel).
      5. "scaleX" and "scaleY": The units for 2cm. Defaults: scaleX=1, scaleY=rate if not explicitly stated.
      6. "questions": Array of objects. If asks "How far in 2.6 min?", type="findY", value="2.6". If asks "How long to walk 500m?", type="findX", value="500".
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "xLabel": "Time (min)",
         "yLabel": "Distance (m)",
         "rate": "120",
         "isContinuous": true,
         "scaleX": "1",
         "scaleY": "100",
         "questions": [
            {"type": "findY", "value": "2.6"},
            {"type": "findX", "value": "500"}
         ]
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        _xLabelCtrl.text = jsonMap['xLabel']?.toString() ?? '';
        _yLabelCtrl.text = jsonMap['yLabel']?.toString() ?? '';
        _rateCtrl.text = jsonMap['rate']?.toString() ?? '';
        _isContinuous = jsonMap['isContinuous'] ?? true;
        _scaleXCtrl.text = jsonMap['scaleX']?.toString() ?? '1';
        _scaleYCtrl.text = jsonMap['scaleY']?.toString() ?? '100';

        List qData = jsonMap['questions'] ?? [];
        _questions.clear();
        for (var q in qData) {
          _questions.add({
            'type': TextEditingController(text: q['type']?.toString() ?? 'findY'),
            'val': TextEditingController(text: q['value']?.toString() ?? ''),
          });
        }
        if (_questions.isEmpty) _addQuestion();

        _inputMode = 1; // Switch to Manual view to show mapped data
      });
      _solveManual();

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Translation failed. Please enter the values manually.")));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();

    List<GraphQuestion> qs = [];
    for (var qMap in _questions) {
      String t = qMap['type']!.text;
      String vStr = qMap['val']!.text.replaceAll(RegExp(r'[^\d\.]'), '');
      if (vStr.isNotEmpty) {
        qs.add(GraphQuestion(type: t, givenValue: double.parse(vStr)));
      }
    }

    setState(() {
      _result = LinearGraphsLogic.solve(
        xLabelStr: _xLabelCtrl.text,
        yLabelStr: _yLabelCtrl.text,
        rateStr: _rateCtrl.text,
        isContinuous: _isContinuous,
        scaleXStr: _scaleXCtrl.text,
        scaleYStr: _scaleYCtrl.text,
        questions: qs,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        // Position graph origin (bottom-left) reasonably in view
        _graphTransformController.value = Matrix4.identity()
          ..translate(0.0, -450.0); // 800h canvas, viewport 350h
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
                Expanded(child: Text("Paste a Straight-Line graph problem. The AI will set the scales, build the table, and read the graph answers for you!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. Chukwudi walks at 120m per minute. Scale: 2cm to 1 min on x-axis... How far does he walk in 2.6 min?", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Draw Graph", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          const Text("1. Data & Relationship", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildSmallField(_xLabelCtrl, "X-Axis Label (e.g. Time)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_yLabelCtrl, "Y-Axis Label (e.g. Distance)")) ]),
          const SizedBox(height: 12),
          Row(
              children: [
                const Text("1 unit of X  =  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSmallField(_rateCtrl, "e.g. 120")),
                const Text("  units of Y", style: TextStyle(fontWeight: FontWeight.bold)),
              ]
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<bool>(
              groupValue: _isContinuous,
              children: const {
                true: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Continuous (Draw Line)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                false: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Discontinuous (Points Only)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              },
              onValueChanged: (bool? val) { if (val != null) setState(() => _isContinuous = val); },
              thumbColor: Colors.deepPurple.shade100,
            ),
          ),

          const SizedBox(height: 24),
          const Text("2. Graph Scale (2cm blocks)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildSmallField(_scaleXCtrl, "X Scale (e.g. 1)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_scaleYCtrl, "Y Scale (e.g. 100)")) ]),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("3. Read from Graph (Optional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              TextButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add, size: 18), label: const Text("Add Query"))
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              children: List.generate(_questions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Container(
                            height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _questions[index]['type']!.text.isEmpty ? "findY" : _questions[index]['type']!.text,
                                isExpanded: true,
                                items: const [ DropdownMenuItem(value: "findY", child: Text("Given X, find Y")), DropdownMenuItem(value: "findX", child: Text("Given Y, find X")) ],
                                onChanged: (String? val) { if (val != null) setState(() => _questions[index]['type']!.text = val); },
                              ),
                            ),
                          )
                      ),
                      const SizedBox(width: 8),
                      Expanded(flex: 3, child: _buildSmallField(_questions[index]['val']!, "Value (e.g. 2.6)")),
                      if (_questions.length > 1) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removeQuestion(index))
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.show_chart, color: Colors.white), label: const Text("Draw Graph & Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller, textAlign: TextAlign.center, keyboardType: TextInputType.text,
      decoration: InputDecoration(hintText: hint, isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("1. Interactive Graph Paper:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
            Text("💡 Pan & Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),

        // Virtual Graph Paper
        Container(
          height: 350, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.deepPurple.shade200, width: 2), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _graphTransformController,
              constrained: false, boundaryMargin: const EdgeInsets.all(200), minScale: 0.2, maxScale: 4.0,
              child: Container(
                width: 800, height: 800, color: Colors.white,
                child: CustomPaint(painter: LinearGraphPainter(result: _result!)),
              ),
            ),
          ),
        ),

        if (_result!.finalAnswers.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text("2. Graph Readings (Answers):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _result!.finalAnswers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("${entry.key}:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87))),
                        Text(entry.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        Text("${_result!.finalAnswers.isNotEmpty ? '3' : '2'}. Mathematical Workings:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
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

        const SizedBox(height: 24),
        Text("${_result!.finalAnswers.isNotEmpty ? '4' : '3'}. Step-by-Step Breakdown:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
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
                if (e.value.mathLaTeX != null && e.value.mathLaTeX!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(e.value.mathLaTeX!, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)))
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
      appBar: AppBar(title: const Text('Linear Graphs')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(Theme.of(context)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM GRAPH PAINTER (Strictly matches textbook graph paper aesthetics)
// -----------------------------------------------------------------------------

class LinearGraphPainter extends CustomPainter {
  final LinearGraphResult result;

  LinearGraphPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    // Colors and Paints
    final minorGridPaint = Paint()..color = Colors.green.shade100..strokeWidth = 1;
    final majorGridPaint = Paint()..color = Colors.green.shade400..strokeWidth = 1.5;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2.5;
    final linePaint = Paint()..color = Colors.black87..strokeWidth = 2..style = PaintingStyle.stroke;
    final plotPaint = Paint()..color = Colors.black..strokeWidth = 2..style = PaintingStyle.stroke;
    final tracePaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    // Origin mapping (Bottom Left, leaving room for labels)
    Offset origin = Offset(80, size.height - 80);

    // 2cm block logic: Let's map 2cm to exactly 50 logical pixels.
    double pxPerBlock = 50.0;

    // Grid bounds
    int numXBlocks = ((size.width - origin.dx) / pxPerBlock).ceil();
    int numYBlocks = (origin.dy / pxPerBlock).ceil();

    // 1. Draw Grid Lines (10 subdivisions per 2cm block)
    double minorSpacing = pxPerBlock / 10;

    // Draw Verticals
    for (int i = 0; i <= numXBlocks * 10; i++) {
      double px = origin.dx + (i * minorSpacing);
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }
    // Draw Horizontals
    for (int i = 0; i <= numYBlocks * 10; i++) {
      double py = origin.dy - (i * minorSpacing);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }

    // 2. Draw Axes & Labels
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint); // Y-axis
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint); // X-axis

    // Origin 0
    _drawText(canvas, "0", origin.dx - 12, origin.dy + 12, isBold: true);

    // X-Axis Scale & Numbers
    for (int i = 1; i <= numXBlocks; i++) {
      double val = i * result.scaleX;
      double px = origin.dx + (i * pxPerBlock);
      _drawText(canvas, _fmt(val), px, origin.dy + 15);
    }
    _drawText(canvas, result.xLabel, size.width - 50, origin.dy + 30, isBold: true);

    // Y-Axis Scale & Numbers
    for (int i = 1; i <= numYBlocks; i++) {
      double val = i * result.scaleY;
      double py = origin.dy - (i * pxPerBlock);
      _drawText(canvas, _fmt(val), origin.dx - 25, py);
    }

    // Rotate Y-Axis label to mimic textbook
    canvas.save();
    canvas.translate(20, 100);
    canvas.rotate(-1.5708); // -90 degrees
    _drawText(canvas, result.yLabel, 0, 0, isBold: true);
    canvas.restore();

    // Helper to convert real values to pixel coordinates
    Offset toPx(double xVal, double yVal) {
      double px = origin.dx + ((xVal / result.scaleX) * pxPerBlock);
      double py = origin.dy - ((yVal / result.scaleY) * pxPerBlock);
      return Offset(px, py);
    }

    // 3. Plot Points from Table
    List<Offset> plottedPoints = [];
    for (var point in result.tableOfValues) {
      Offset pt = toPx(point['x']!, point['y']!);
      plottedPoints.add(pt);

      // Draw Small Cross (+)
      canvas.drawLine(Offset(pt.dx - 4, pt.dy), Offset(pt.dx + 4, pt.dy), plotPaint);
      canvas.drawLine(Offset(pt.dx, pt.dy - 4), Offset(pt.dx, pt.dy + 4), plotPaint);
    }

    // 4. Draw Continuous Line
    if (result.isContinuous && plottedPoints.length > 1) {
      Path graphPath = Path()..moveTo(plottedPoints.first.dx, plottedPoints.first.dy);
      // Draw line straight through to the edge of the graph
      double farX = (size.width - origin.dx) / pxPerBlock * result.scaleX;
      double farY = farX * result.rate;
      Offset endPt = toPx(farX, farY);
      graphPath.lineTo(endPt.dx, endPt.dy);
      canvas.drawPath(graphPath, linePaint);
    }

    // 5. Draw Trace Lines for Questions (Dashed)
    for (int i = 0; i < result.questions.length; i++) {
      var q = result.questions[i];
      double qx = 0; double qy = 0;
      if (q.type == 'findY') {
        qx = q.givenValue;
        qy = qx * result.rate;
      } else {
        qy = q.givenValue;
        qx = qy / result.rate;
      }

      Offset ptOnGraph = toPx(qx, qy);
      Offset ptOnX = toPx(qx, 0);
      Offset ptOnY = toPx(0, qy);

      // Dash to X-axis
      _drawDashedLine(canvas, ptOnGraph, ptOnX, tracePaint);
      // Dash to Y-axis
      _drawDashedLine(canvas, ptOnGraph, ptOnY, tracePaint);

      // Label the trace (e.g. (i) or (a))
      String mark = "(${String.fromCharCode(97 + i)})"; // (a), (b)...
      _drawText(canvas, mark, ptOnGraph.dx + 15, ptOnGraph.dy - 15, color: Colors.red, isBold: true);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double distance = (p2 - p1).distance;
    double dashWidth = 5, dashSpace = 4;
    double startX = p1.dx, startY = p1.dy;
    int count = (distance / (dashWidth + dashSpace)).floor();
    double dx = (p2.dx - p1.dx) / count;
    double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) canvas.drawLine(Offset(startX, startY), Offset(startX + dx, startY + dy), paint);
      startX += dx;
      startY += dy;
    }

    // Draw Arrowhead pointing to the axis being read
    if (p1.dy == p2.dy) { // Moving horizontal
      double dir = p2.dx > p1.dx ? -1 : 1; // Left or Right
      Path arrow = Path()
        ..moveTo(p2.dx + (dir * 8), p2.dy - 4)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p2.dx + (dir * 8), p2.dy + 4);
      canvas.drawPath(arrow, paint);
    } else if (p1.dx == p2.dx) { // Moving vertical
      double dir = p2.dy > p1.dy ? -1 : 1; // Up or Down
      Path arrow = Path()
        ..moveTo(p2.dx - 4, p2.dy + (dir * 8))
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p2.dx + 4, p2.dy + (dir * 8));
      canvas.drawPath(arrow, paint);
    }
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}