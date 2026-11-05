import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'graphical_method_logic.dart';
import 'graphical_method_models.dart';

/// CustomPainter for the Textbook Cartesian Graph Paper (Replicating Figs. 10.1–10.5 on Pages 91–94)
class _SimultaneousGraphPainter extends CustomPainter {
  final List<GraphPoint> line1Points;
  final List<GraphPoint> line2Points;
  final GraphPoint intersection;

  _SimultaneousGraphPainter({
    required this.line1Points,
    required this.line2Points,
    required this.intersection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<GraphPoint> allPts = [
      ...line1Points,
      ...line2Points,
      intersection,
      const GraphPoint(0, 0),
    ];

    double minX = -3;
    double maxX = 5;
    double minY = -4;
    double maxY = 8;

    for (final p in allPts) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    minX = (minX - 1.5).floorToDouble();
    maxX = (maxX + 1.5).ceilToDouble();
    minY = (minY - 1.5).floorToDouble();
    maxY = (maxY + 1.5).ceilToDouble();

    const double padLeft = 36.0;
    const double padRight = 24.0;
    const double padTop = 20.0;
    const double padBottom = 30.0;

    final double plotW = size.width - padLeft - padRight;
    final double plotH = size.height - padTop - padBottom;

    double toScreenX(double x) =>
        padLeft + ((x - minX) / (maxX - minX)) * plotW;
    double toScreenY(double y) =>
        padTop + plotH - ((y - minY) / (maxY - minY)) * plotH;

    // 1. Draw minor & major graph paper grid lines
    final Paint minorGridPaint = Paint()
      ..color = Colors.pink.shade50
      ..strokeWidth = 0.8;
    final Paint majorGridPaint = Paint()
      ..color = Colors.pink.shade100
      ..strokeWidth = 1.1;

    for (double x = minX; x <= maxX; x += 0.5) {
      final double sx = toScreenX(x);
      final bool isInt = (x - x.roundToDouble()).abs() < 1e-6;
      canvas.drawLine(
        Offset(sx, padTop),
        Offset(sx, padTop + plotH),
        isInt ? majorGridPaint : minorGridPaint,
      );
    }

    for (double y = minY; y <= maxY; y += 0.5) {
      final double sy = toScreenY(y);
      final bool isInt = (y - y.roundToDouble()).abs() < 1e-6;
      canvas.drawLine(
        Offset(padLeft, sy),
        Offset(padLeft + plotW, sy),
        isInt ? majorGridPaint : minorGridPaint,
      );
    }

    // 2. Draw x-axis and y-axis
    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.8;

    final double originX = toScreenX(0).clamp(padLeft, padLeft + plotW);
    final double originY = toScreenY(0).clamp(padTop, padTop + plotH);

    canvas.drawLine(
        Offset(padLeft, originY), Offset(padLeft + plotW, originY), axisPaint);
    canvas.drawLine(
        Offset(originX, padTop), Offset(originX, padTop + plotH), axisPaint);

    // 3. Draw axis tick labels
    final int xStep = (maxX - minX) > 16 ? 2 : 1;
    for (int xi = minX.ceil(); xi <= maxX.floor(); xi += xStep) {
      if (xi == 0) continue;
      final double sx = toScreenX(xi.toDouble());
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '$xi',
          style: const TextStyle(
              fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, originY + 4));
    }

    final int yStep = (maxY - minY) > 16 ? 2 : 1;
    for (int yi = minY.ceil(); yi <= maxY.floor(); yi += yStep) {
      if (yi == 0) continue;
      final double sy = toScreenY(yi.toDouble());
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '$yi',
          style: const TextStyle(
              fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(originX - tp.width - 5, sy - tp.height / 2));
    }

    // Helper to draw an extended straight line across the plot area
    void drawExtendedLine(List<GraphPoint> pts, Color color) {
      if (pts.length < 2) return;
      final GraphPoint pA = pts.first;
      final GraphPoint pB = pts.last;
      final double dx = pB.x - pA.x;
      final double dy = pB.y - pA.y;

      final Paint linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;

      if (dx.abs() < 1e-9) {
        final double sx = toScreenX(pA.x);
        canvas.drawLine(
            Offset(sx, padTop), Offset(sx, padTop + plotH), linePaint);
      } else {
        final double m = dy / dx;
        final double c = pA.y - m * pA.x;
        final double yAtMinX = m * minX + c;
        final double yAtMaxX = m * maxX + c;
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(padLeft, padTop, plotW, plotH));
        canvas.drawLine(
          Offset(toScreenX(minX), toScreenY(yAtMinX)),
          Offset(toScreenX(maxX), toScreenY(yAtMaxX)),
          linePaint,
        );
        canvas.restore();
      }

      // Draw plotted × markers from the table of values (like Figs 10.1–10.5!)
      final Paint markerPaint = Paint()
        ..color = color
        ..strokeWidth = 2.0;
      for (final GraphPoint pt in pts) {
        final double px = toScreenX(pt.x);
        final double py = toScreenY(pt.y);
        canvas.drawLine(
            Offset(px - 4, py - 4), Offset(px + 4, py + 4), markerPaint);
        canvas.drawLine(
            Offset(px - 4, py + 4), Offset(px + 4, py - 4), markerPaint);
      }
    }

    drawExtendedLine(line1Points, Colors.deepPurple);
    drawExtendedLine(line2Points, Colors.teal.shade700);

    // 4. Highlight the Point of Intersection
    final double ix = toScreenX(intersection.x);
    final double iy = toScreenY(intersection.y);

    // Dashed projection lines to x-axis and y-axis
    final Paint dashPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(ix, iy), Offset(ix, originY), dashPaint);
    canvas.drawLine(Offset(ix, iy), Offset(originX, iy), dashPaint);

    canvas.drawCircle(
      Offset(ix, iy),
      6.5,
      Paint()..color = Colors.red.shade700,
    );
    canvas.drawCircle(
      Offset(ix, iy),
      3.0,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SimultaneousGraphPainter oldDelegate) => true;
}

class GraphicalMethodScreen extends StatefulWidget {
  const GraphicalMethodScreen({super.key});

  @override
  State<GraphicalMethodScreen> createState() => _GraphicalMethodScreenState();
}

class _GraphicalMethodScreenState extends State<GraphicalMethodScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _eq1Ctrl = TextEditingController();
  final TextEditingController _eq2Ctrl = TextEditingController();
  final TextEditingController _xValsCtrl = TextEditingController();

  GraphicalMethodResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _eq1Ctrl.dispose();
    _eq2Ctrl.dispose();
    _xValsCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(GraphicalMethodPreset p) {
    setState(() {
      _eq1Ctrl.text = p.eq1Input;
      _eq2Ctrl.text = p.eq2Input;
      _xValsCtrl.text = p.xValuesInput;
    });
    _solveManual();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final String inputText = _aiController.text.trim();

    if (inputText.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a graphical simultaneous equations question or upload a textbook image.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null;
    });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      final promptText = '''
      You are a strict JSON data extractor for JSS3 Chapter 10 Subtopic 2: Graphical Method (Pages 91–94, Examples 1 & 2, Exercise 10.1 #1–10).
      Extract the two simultaneous linear equations in x and y into "eq1Input" and "eq2Input".
      Return ONLY valid JSON:
      {
        "eq1Input": "x - 4y = -12",
        "eq2Input": "x + y = 8",
        "xValuesInput": "-4, -2, 0, 2, 4, 6"
      }
      User Prompt: "$inputText"
      ''';

      final List<Part> parts = [TextPart(promptText)];
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        parts.add(DataPart('image/jpeg', bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      final String rawOutput = (response.text ?? '')
          .trim()
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '')
          .replaceAll(RegExp(r'\n```$'), '')
          .trim();

      final Map<String, dynamic> jsonMap = json.decode(rawOutput);
      if (!mounted) return;

      setState(() {
        _eq1Ctrl.text = (jsonMap['eq1Input'] ?? '').toString();
        _eq2Ctrl.text = (jsonMap['eq2Input'] ?? '').toString();
        _xValsCtrl.text = (jsonMap['xValuesInput'] ?? '').toString();
        _inputMode = 1;
      });

      _solveManual();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'AI extraction failed. Please select a textbook preset or use the Manual Builder.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAI = false);
      }
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = GraphicalMethodLogic.solveGraphically(
        eq1Raw: _eq1Ctrl.text,
        eq2Raw: _eq2Ctrl.text,
        xValuesRaw: _xValsCtrl.text,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _canvasTransformController.value = Matrix4.identity();
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
        fontSize: 14,
      ),
    );
  }

  /// Renders text mixed with inline $...$ or \frac{...}{...} math segments using flutter_math_fork (Math.tex)
  /// so no raw LaTeX ever appears in step titles or descriptions!
  Widget _buildRichMathText(
      String text, {
        required TextStyle style,
        TextStyle? mathStyle,
      }) {
    final RegExp inlineMathReg = RegExp(
      r'\$([^$]+)\$|([a-zA-Z0-9]*\\frac\{[^{}]+\}\{[^{}]+\}[a-zA-Z0-9^{}]*)',
    );
    final Iterable<RegExpMatch> matches = inlineMathReg.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;
    for (final RegExpMatch m in matches) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, m.start), style: style));
      }
      final String latexExpr = (m.group(1) ?? m.group(2) ?? '').trim();
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Math.tex(
              latexExpr,
              textStyle: mathStyle ??
                  style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
          ),
        ),
      );
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        String? hint,
      }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontSize: 13),
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }

  Widget _buildPresetsBar() {
    const presets = GraphicalMethodLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 91–94 Examples 1 & 2, Exercise 10.1 #1–10):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.show_chart,
                      size: 15, color: Colors.deepPurple),
                  label: Text(
                    p.chipLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.deepPurple.shade50,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () => _applyPreset(p),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildManualForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
              "1. Enter the Pair of Simultaneous Linear Equations to Solve Graphically:"),
          const SizedBox(height: 10),
          _buildTextField(
            _eq1Ctrl,
            "1st Linear Equation",
            hint: "e.g. x - y = 5, 3x + y = 2, or x - 4y = -12",
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _eq2Ctrl,
            "2nd Linear Equation",
            hint: "e.g. 2x + y = 7, 2x - y = 3, or x + y = 8",
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _xValsCtrl,
            "Optional x-Values for Tables of Values (Leave blank for automatic range)",
            hint: "e.g. -2, -1, 0, 1, 2, 3, 4",
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "📷 AI Vision",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "🛠️ Manual Builder",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) setState(() => _inputMode = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snap a photo of any Graphical Simultaneous Equations question from JSS 3 Chapter 10 (Pages 91–94, Examples 1 & 2, or Exercise 10.1)!",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Image Attached",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  child:
                  const Text("Remove", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _aiController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Graphical Method Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Solve graphically x - 4y = -12 and x + y = 8...",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI)
            const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple))
          else
            ElevatedButton.icon(
              onPressed: _solveWithAI,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text(
                "Extract & Plot Graph",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          _buildPresetsBar(),
          const SizedBox(height: 16),
          _buildManualForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.show_chart, color: Colors.white),
            label: const Text(
              "Build Tables of Values & Plot Graph",
              style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }

  /// Interactive Visualisation Area combining Math.tex Tables of Values + Textbook Cartesian Graph Grid
  Widget _buildMathForkVisualisationArea(
      GraphicalMethodCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.headerLaTeX,
              textStyle: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: Colors.deepPurple.shade300, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Math.tex(
                        "\\text{Table 1: } ${cd.eq1SubjectLaTeX}",
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          cd.table1LaTeX,
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade600, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Math.tex(
                        "\\text{Table 2: } ${cd.eq2SubjectLaTeX}",
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          cd.table2LaTeX,
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pink.shade200, width: 1.8),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SimultaneousGraphPainter(
                          line1Points: cd.line1Points,
                          line2Points: cd.line2Points,
                          intersection: cd.intersection,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: Colors.red.shade700, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location,
                                size: 15, color: Colors.red.shade700),
                            const SizedBox(width: 6),
                            Math.tex(
                              "\\text{Intersection: } ${cd.intersectionLabelLaTeX}",
                              textStyle: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.bottomSummaryLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Invalid input.",
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final GraphicalMethodCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 720.0);
    const double canvasHeight = 540.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Cartesian Graph & Tables of Values:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              "💡 Pan & Zoom",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: canvasHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _canvasTransformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(140),
              minScale: 0.4,
              maxScale: 3.5,
              child: _buildMathForkVisualisationArea(
                cd,
                canvasWidth,
                canvasHeight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "2. Final Answers:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAnswersLaTeX.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Math.tex(
                    entry.value,
                    textStyle: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text(
          "3. Mathematical Workings (Line-by-Line):",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  if (_result!.workingsLaTeX[i].isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(
                        color: Colors.deepPurple.shade100,
                        thickness: 1.2,
                        height: 1,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          _result!.workingsLaTeX[i],
                          textStyle: const TextStyle(
                            fontSize: 16.5,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "4. Step-by-Step Breakdown:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) {
          final List<String> mathLines = e.value.mathLinesLaTeX
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                foregroundColor: Colors.deepPurple,
                child: Text(
                  '${e.key + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: _buildRichMathText(
                e.value.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  _buildRichMathText(
                    e.value.description,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    mathStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  if (mathLines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final mLine in mathLines)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 5.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  mLine,
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Graphical Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
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