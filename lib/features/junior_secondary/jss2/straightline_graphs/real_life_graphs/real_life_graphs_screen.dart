import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'real_life_graphs_logic.dart';
import 'real_life_graphs_models.dart';

class RealLifeGraphsScreen extends StatefulWidget {
  const RealLifeGraphsScreen({super.key});

  @override
  State<RealLifeGraphsScreen> createState() => _RealLifeGraphsScreenState();
}

class _RealLifeGraphsScreenState extends State<RealLifeGraphsScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual Builder
  int _topicMode = 0; // 0: Standing Charge, 1: Conversion, 2: Two-Point

  bool _isLoadingAI = false;
  final TextEditingController _aiController = TextEditingController();

  // General Controllers
  final TextEditingController _xLabelCtrl = TextEditingController(text: "Time (h)");
  final TextEditingController _yLabelCtrl = TextEditingController(text: "Cost (₦)");
  final TextEditingController _scaleXCtrl = TextEditingController(text: "1");
  final TextEditingController _scaleYCtrl = TextEditingController(text: "1000");

  // Mode 0 Controllers (Fixed + Variable)
  final TextEditingController _fixedChargeCtrl = TextEditingController(text: "1000");
  final TextEditingController _rateCtrl = TextEditingController(text: "400");

  // Mode 1 Controllers (Direct Conversion)
  final TextEditingController _conversionRateCtrl = TextEditingController(text: "1.25");

  // Mode 2 Controllers (Two Point)
  final TextEditingController _x1Ctrl = TextEditingController(text: "0");
  final TextEditingController _y1Ctrl = TextEditingController(text: "32");
  final TextEditingController _x2Ctrl = TextEditingController(text: "100");
  final TextEditingController _y2Ctrl = TextEditingController(text: "212");

  final List<Map<String, TextEditingController>> _questions = [];

  RealLifeGraphResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _addQuestion(); // Add one blank question by default
  }

  @override
  void dispose() {
    _aiController.dispose();
    _xLabelCtrl.dispose(); _yLabelCtrl.dispose();
    _scaleXCtrl.dispose(); _scaleYCtrl.dispose();
    _fixedChargeCtrl.dispose(); _rateCtrl.dispose();
    _conversionRateCtrl.dispose();
    _x1Ctrl.dispose(); _y1Ctrl.dispose(); _x2Ctrl.dispose(); _y2Ctrl.dispose();
    for (var q in _questions) { q['val']!.dispose(); q['type']!.dispose(); }
    _graphTransformController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'type': TextEditingController(text: "findY"),
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
      Extract data for Real-Life Linear Graphs.
      
      RULES:
      1. Return ONLY valid JSON.
      2. "mode": 0 (Standing charge/Utility bill), 1 (Currency/Direct Conversion), 2 (Temperature like Fahrenheit to Celsius).
      3. Extract axis labels into "xLabel" and "yLabel".
      4. "scaleX" and "scaleY" are units for 2cm. Extract them if given.
      5. For mode 0: extract "fixedCharge" and "rate".
      6. For mode 1: extract "conversionRate" (e.g. 1 unit of X = k units of Y).
      7. For mode 2: extract two points as "x1", "y1", "x2", "y2".
      
      JSON FORMAT:
      {
         "mode": 0,
         "xLabel": "Time (h)",
         "yLabel": "Labour Charge (N)",
         "scaleX": "1",
         "scaleY": "1000",
         "fixedCharge": "1000",
         "rate": "400",
         "conversionRate": "",
         "x1": "", "y1": "", "x2": "", "y2": "",
         "questions": [{"type": "findY", "value": "2.5"}]
      }
      
      Word Problem: "$inputText"
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      setState(() {
        _topicMode = jsonMap['mode'] ?? 0;
        _xLabelCtrl.text = jsonMap['xLabel']?.toString() ?? '';
        _yLabelCtrl.text = jsonMap['yLabel']?.toString() ?? '';
        _scaleXCtrl.text = jsonMap['scaleX']?.toString() ?? '1';
        _scaleYCtrl.text = jsonMap['scaleY']?.toString() ?? '10';

        _fixedChargeCtrl.text = jsonMap['fixedCharge']?.toString() ?? '';
        _rateCtrl.text = jsonMap['rate']?.toString() ?? '';
        _conversionRateCtrl.text = jsonMap['conversionRate']?.toString() ?? '';
        _x1Ctrl.text = jsonMap['x1']?.toString() ?? '';
        _y1Ctrl.text = jsonMap['y1']?.toString() ?? '';
        _x2Ctrl.text = jsonMap['x2']?.toString() ?? '';
        _y2Ctrl.text = jsonMap['y2']?.toString() ?? '';

        List qData = jsonMap['questions'] ?? [];
        _questions.clear();
        for (var q in qData) {
          _questions.add({
            'type': TextEditingController(text: q['type']?.toString() ?? 'findY'),
            'val': TextEditingController(text: q['value']?.toString() ?? ''),
          });
        }
        if (_questions.isEmpty) _addQuestion();

        _inputMode = 1; // Switch to Manual view
      });
      _solveManual();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Translation failed. Please enter the values manually.")));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();

    List<RealLifeGraphQuestion> qs = [];
    for (var qMap in _questions) {
      String t = qMap['type']!.text;
      String vStr = qMap['val']!.text.replaceAll(RegExp(r'[^\d\.\-]'), '');
      if (vStr.isNotEmpty) {
        qs.add(RealLifeGraphQuestion(type: t, givenValue: double.parse(vStr)));
      }
    }

    setState(() {
      _result = RealLifeGraphsLogic.solve(
        mode: _topicMode,
        xLabelStr: _xLabelCtrl.text,
        yLabelStr: _yLabelCtrl.text,
        scaleXStr: _scaleXCtrl.text,
        scaleYStr: _scaleYCtrl.text,
        fixedChargeStr: _fixedChargeCtrl.text,
        rateStr: _rateCtrl.text,
        conversionRateStr: _conversionRateCtrl.text,
        x1Str: _x1Ctrl.text, y1Str: _y1Ctrl.text,
        x2Str: _x2Ctrl.text, y2Str: _y2Ctrl.text,
        questions: qs,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        // Auto-center based on origin.
        // We calculate origin offset in the Painter, but for the viewport:
        // We know the canvas is 800x800. We want the origin to be visible.
        _graphTransformController.value = Matrix4.identity()..translate(-150.0, -250.0);
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
                Expanded(child: Text("Paste a Real-Life Graph problem. The AI handles standing charges, exchange rates, and complex scales!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 4,
            decoration: InputDecoration(labelText: "Word Problem", hintText: "e.g. A plumber charges a standing fee of ₦1000 plus ₦400 per hour...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Translate & Draw Graph", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Standing Charge", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Conversion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("2-Point Formula", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              },
              onValueChanged: (int? value) { if (value != null) setState(() { _topicMode = value; _result = null; }); },
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          const Text("1. Data & Relationship", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildSmallField(_xLabelCtrl, "X-Axis Label (e.g. Time)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_yLabelCtrl, "Y-Axis Label (e.g. Cost)")) ]),
          const SizedBox(height: 12),

          if (_topicMode == 0) ...[
            Row(children: [ Expanded(child: _buildSmallField(_fixedChargeCtrl, "Standing Charge (e.g. 1000)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_rateCtrl, "Rate per X (e.g. 400)")) ]),
          ] else if (_topicMode == 1) ...[
            Row(children: [ const Text("1 unit of X = ", style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: _buildSmallField(_conversionRateCtrl, "e.g. 1.25")), const Text(" units of Y", style: TextStyle(fontWeight: FontWeight.bold)) ]),
          ] else ...[
            Row(children: [ const Text("Pt 1:", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Expanded(child: _buildSmallField(_x1Ctrl, "X1")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_y1Ctrl, "Y1")) ]),
            const SizedBox(height: 8),
            Row(children: [ const Text("Pt 2:", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Expanded(child: _buildSmallField(_x2Ctrl, "X2")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_y2Ctrl, "Y2")) ]),
          ],

          const SizedBox(height: 24),
          const Text("2. Graph Scale (2cm blocks)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildSmallField(_scaleXCtrl, "X Scale (e.g. 1)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_scaleYCtrl, "Y Scale (e.g. 1000)")) ]),

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
                      Expanded(flex: 3, child: _buildSmallField(_questions[index]['val']!, "Value (e.g. 2.5)")),
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
      controller: controller, textAlign: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
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
            Text("1. Real-Life Graph:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
            Text("💡 Pan & Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),

        // Virtual Graph Paper (Handles floating origins!)
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
                child: CustomPaint(painter: RealLifeGraphPainter(result: _result!)),
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
      appBar: AppBar(title: const Text('Graphs of Real-Life Situations')),
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

class RealLifeGraphPainter extends CustomPainter {
  final RealLifeGraphResult result;

  RealLifeGraphPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final minorGridPaint = Paint()..color = Colors.green.shade50..strokeWidth = 1;
    final majorGridPaint = Paint()..color = Colors.green.shade200..strokeWidth = 1.5;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2.5;
    final linePaint = Paint()..color = Colors.black87..strokeWidth = 2..style = PaintingStyle.stroke;
    final plotPaint = Paint()..color = Colors.black..strokeWidth = 2..style = PaintingStyle.stroke;
    final tracePaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    // 1. Dynamic Origin Calculation
    // We must find the minimum x and y values in the table and queries to see if we need negative axes.
    double minX = 0; double maxX = 5 * result.scaleX;
    double minY = 0; double maxY = 5 * result.scaleY;

    for (var pt in result.tableOfValues) {
      if (pt['x']! < minX) minX = pt['x']!;
      if (pt['x']! > maxX) maxX = pt['x']!;
      if (pt['y']! < minY) minY = pt['y']!;
      if (pt['y']! > maxY) maxY = pt['y']!;
    }
    for (var q in result.questions) {
      if (q.type == 'findY') {
        if (q.givenValue < minX) minX = q.givenValue;
        if (q.givenValue > maxX) maxX = q.givenValue;
        double yAns = (result.m * q.givenValue) + result.c;
        if (yAns < minY) minY = yAns;
        if (yAns > maxY) maxY = yAns;
      } else {
        if (q.givenValue < minY) minY = q.givenValue;
        if (q.givenValue > maxY) maxY = q.givenValue;
        double xAns = (q.givenValue - result.c) / result.m;
        if (xAns < minX) minX = xAns;
        if (xAns > maxX) maxX = xAns;
      }
    }

    // Map 2cm strictly to 50 pixels
    double pxPerBlock = 50.0;

    // Calculate how many blocks we need in the negative direction to shift the origin
    double negXBlocks = minX < 0 ? (minX.abs() / result.scaleX).ceilToDouble() + 1 : 1;
    double negYBlocks = minY < 0 ? (minY.abs() / result.scaleY).ceilToDouble() + 1 : 1;

    // Set Origin (cx, cy)
    double cx = negXBlocks * pxPerBlock;
    double cy = size.height - (negYBlocks * pxPerBlock);

    // Grid bounds
    int numXBlocksRight = ((size.width - cx) / pxPerBlock).ceil();
    int numYBlocksUp = (cy / pxPerBlock).ceil();

    int numXBlocksLeft = (cx / pxPerBlock).ceil();
    int numYBlocksDown = ((size.height - cy) / pxPerBlock).ceil();

    // Draw Grid Lines (10 subdivisions per 2cm block)
    double minorSpacing = pxPerBlock / 10;

    // Verticals
    for (int i = -numXBlocksLeft * 10; i <= numXBlocksRight * 10; i++) {
      double px = cx + (i * minorSpacing);
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }
    // Horizontals
    for (int i = -numYBlocksDown * 10; i <= numYBlocksUp * 10; i++) {
      double py = cy - (i * minorSpacing);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }

    // Draw Axes & Labels
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint); // Y-axis
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint); // X-axis
    _drawText(canvas, "0", cx - 12, cy + 12, isBold: true); // Origin

    // X-Axis Scale & Numbers
    for (int i = -numXBlocksLeft; i <= numXBlocksRight; i++) {
      if (i == 0) continue;
      double val = i * result.scaleX;
      double px = cx + (i * pxPerBlock);
      _drawText(canvas, _fmt(val), px, cy + 15);
    }
    _drawText(canvas, result.xLabel, size.width - 50, cy - 15, isBold: true);

    // Y-Axis Scale & Numbers
    for (int i = -numYBlocksDown; i <= numYBlocksUp; i++) {
      if (i == 0) continue;
      double val = i * result.scaleY;
      double py = cy - (i * pxPerBlock);
      _drawText(canvas, _fmt(val), cx - 25, py);
    }

    // Y-Axis label rotation
    canvas.save();
    canvas.translate(cx - 50, 100);
    canvas.rotate(-1.5708);
    _drawText(canvas, result.yLabel, 0, 0, isBold: true);
    canvas.restore();

    // Helper to convert real values to pixel coordinates
    Offset toPx(double xVal, double yVal) {
      double px = cx + ((xVal / result.scaleX) * pxPerBlock);
      double py = cy - ((yVal / result.scaleY) * pxPerBlock);
      return Offset(px, py);
    }

    // Plot Points from Table
    List<Offset> plottedPoints = [];
    for (var point in result.tableOfValues) {
      Offset pt = toPx(point['x']!, point['y']!);
      plottedPoints.add(pt);

      canvas.drawLine(Offset(pt.dx - 4, pt.dy), Offset(pt.dx + 4, pt.dy), plotPaint);
      canvas.drawLine(Offset(pt.dx, pt.dy - 4), Offset(pt.dx, pt.dy + 4), plotPaint);
    }

    // Draw Continuous Line through points (extended to edges)
    if (plottedPoints.length > 1) {
      double minEdgeX = -numXBlocksLeft * result.scaleX;
      double maxEdgeX = numXBlocksRight * result.scaleX;

      Offset startLine = toPx(minEdgeX, (result.m * minEdgeX) + result.c);
      Offset endLine = toPx(maxEdgeX, (result.m * maxEdgeX) + result.c);

      canvas.drawLine(startLine, endLine, linePaint);
    }

    // Draw Trace Lines for Questions (Dashed)
    for (int i = 0; i < result.questions.length; i++) {
      var q = result.questions[i];
      double qx = 0; double qy = 0;
      if (q.type == 'findY') {
        qx = q.givenValue;
        qy = (result.m * qx) + result.c;
      } else {
        qy = q.givenValue;
        qx = (qy - result.c) / result.m;
      }

      Offset ptOnGraph = toPx(qx, qy);
      Offset ptOnX = toPx(qx, 0);
      Offset ptOnY = toPx(0, qy);

      _drawDashedLine(canvas, ptOnGraph, ptOnX, tracePaint);
      _drawDashedLine(canvas, ptOnGraph, ptOnY, tracePaint);

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

    // Draw Arrowhead pointing to the axis
    if (p1.dy == p2.dy) {
      double dir = p2.dx > p1.dx ? -1 : 1;
      Path arrow = Path()..moveTo(p2.dx + (dir * 8), p2.dy - 4)..lineTo(p2.dx, p2.dy)..lineTo(p2.dx + (dir * 8), p2.dy + 4);
      canvas.drawPath(arrow, paint);
    } else if (p1.dx == p2.dx) {
      double dir = p2.dy > p1.dy ? -1 : 1;
      Path arrow = Path()..moveTo(p2.dx - 4, p2.dy + (dir * 8))..lineTo(p2.dx, p2.dy)..lineTo(p2.dx + 4, p2.dy + (dir * 8));
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