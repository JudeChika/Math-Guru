import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'pie_charts_logic.dart';
import 'pie_charts_models.dart';

class PieChartsScreen extends StatefulWidget {
  const PieChartsScreen({super.key});

  @override
  State<PieChartsScreen> createState() => _PieChartsScreenState();
}

class _PieChartsScreenState extends State<PieChartsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Frequencies / Quantities -> Sectorial Angles (Example 5, Ex 19.2 #1–#4, Rev Ex 19 #4)
  // 1: Percentages (including mixed fractions like 30 5/9%) -> Angles & Quantities (Example 6, Rev Ex 19 #7)
  // 2: Interpret Pie Chart Angles / Find Unknown Angle x or a & Quantities (Ex 19.2 #5–#7, Rev Ex 19 #5, #8)
  // 3: Ratios (including fractional ratios like 1 : 3/2 : 2) -> Sectorial Angles (Rev Ex 19 #6)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _categoriesCtrl = TextEditingController();
  final TextEditingController _valuesCtrl = TextEditingController();
  final TextEditingController _totalOrKnownCtrl = TextEditingController();
  final TextEditingController _chartTitleCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();

  PieChartResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _categoriesCtrl.dispose();
    _valuesCtrl.dispose();
    _totalOrKnownCtrl.dispose();
    _chartTitleCtrl.dispose();
    _unitCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(PieChartPreset p) {
    setState(() {
      _mode = p.mode;
      _categoriesCtrl.text = p.categoriesInput;
      _valuesCtrl.text = p.valuesInput;
      _totalOrKnownCtrl.text = p.totalOrKnownInput;
      _chartTitleCtrl.text = p.chartTitle;
      _unitCtrl.text = p.unit;
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
              'Please enter a Pie Chart question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 19 Subtopic 3: Pie Charts (Pages 228–233 & Pages 236–237).
      Classify the user's question or image into one of these 4 modes:
      - mode 0: Construct Pie Chart from Frequencies / Quantities (e.g. Example 5: Producers 4, Mimers 6, Choreographers 15, Costumiers 5)
      - mode 1: Construct Pie Chart from Percentages (e.g. Example 6: 30 5/9, 27 7/9, 11 1/9, 16 2/3, 13 8/9 with totalOrKnownInput: "72000")
      - mode 2: Interpret Pie Chart from Sectorial Angles (or mixed angles & percentages like "165, 90 + x, 16 2/3%" or "54, 135, a" with totalOrKnownInput: "Unprotected sex = 11000" or "3840000")
      - mode 3: Pie Chart Angles from Ratios (e.g. Rev Ex 19 #6: "1, 3/2, 2")

      Return ONLY valid JSON:
      {
        "mode": 0,
        "categoriesInput": "Producers, Mimers, Choreographers, Costumiers",
        "valuesInput": "4, 6, 15, 5",
        "totalOrKnownInput": "",
        "chartTitle": "Reality Show Roles",
        "unit": "students"
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 3);
        _categoriesCtrl.text = (jsonMap['categoriesInput'] ?? '').toString();
        _valuesCtrl.text = (jsonMap['valuesInput'] ?? '').toString();
        _totalOrKnownCtrl.text =
            (jsonMap['totalOrKnownInput'] ?? '').toString();
        _chartTitleCtrl.text = (jsonMap['chartTitle'] ?? '').toString();
        _unitCtrl.text = (jsonMap['unit'] ?? '').toString();
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
      _result = PieChartsLogic.solvePieChart(
        mode: _mode,
        rawCategoriesInput: _categoriesCtrl.text,
        rawValuesInput: _valuesCtrl.text,
        rawTotalOrKnownInput: _totalOrKnownCtrl.text,
        chartTitle: _chartTitleCtrl.text,
        unit: _unitCtrl.text,
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
        spans.add(
            TextSpan(text: text.substring(lastEnd, m.start), style: style));
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
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
    const presets = PieChartsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 228–233 & 236–237):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.pie_chart,
                      size: 16, color: Colors.deepPurple),
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

  Widget _buildModeSelector() {
    const List<Map<String, dynamic>> modes = [
      {
        'idx': 0,
        'label':
        'Quantities / Frequencies -> Sectorial Angles (Example 5, Ex 19.2 #1–#4)',
        'icon': Icons.pie_chart,
      },
      {
        'idx': 1,
        'label':
        'Percentages (Incl. Mixed Fractions like 30 5/9%) -> Angles & Counts (Example 6)',
        'icon': Icons.percent,
      },
      {
        'idx': 2,
        'label':
        'Interpret Pie Chart: Find Missing Angle (x or a) & Quantities (Ex 19.2 #5–#7, Rev Ex #5, #8)',
        'icon': Icons.explore_outlined,
      },
      {
        'idx': 3,
        'label':
        'Ratios (Incl. Fractional Ratios like 1 : 3/2 : 2) -> Pie Chart Angles (Rev Ex 19 #6)',
        'icon': Icons.balance,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Pie Chart Calculation Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            return ChoiceChip(
              avatar: Icon(
                m['icon'] as IconData,
                size: 17,
                color: isSelected ? Colors.white : Colors.deepPurple,
              ),
              label: Text(
                m['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSelected ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color:
                isSelected ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _mode = idx),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeSpecificForm() {
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
            _mode == 0
                ? "2. Enter Sector Categories and Quantities (Example 5 & Ex 19.2 #1–#4):"
                : (_mode == 1
                ? "2. Enter Sector Categories and Percentages (Supports Mixed Fractions like 30 5/9):"
                : (_mode == 2
                ? "2. Enter Sector Categories and Given Angles/Percentages (Use x or a for Unknown Angle):"
                : "2. Enter Categories and Ratio Parts (Supports Fractional Ratios like 1, 3/2, 2):")),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _categoriesCtrl,
            "Sector Names / Categories (comma-separated)",
            hint: "e.g. Producers, Mimers, Choreographers, Costumiers",
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _valuesCtrl,
            _mode == 0
                ? "Quantities / Frequencies (comma-separated)"
                : (_mode == 1
                ? "Percentages (e.g. 30 5/9, 27 7/9, 11 1/9, 16 2/3, 13 8/9)"
                : (_mode == 2
                ? "Sector Angles or % (e.g. 165, 90 + x, 16 2/3% or 54, 135, a)"
                : "Ratio Parts (e.g. 1, 3/2, 2)")),
            hint: _mode == 0
                ? "e.g. 4, 6, 15, 5"
                : (_mode == 1
                ? "e.g. 30 5/9, 27 7/9, 11 1/9, 16 2/3, 13 8/9"
                : (_mode == 2
                ? "e.g. 192, 60, 60, 48 or 54, 135, a"
                : "e.g. 1, 3/2, 2")),
          ),
          if (_mode == 1 || _mode == 2) ...[
            const SizedBox(height: 10),
            _buildTextField(
              _totalOrKnownCtrl,
              _mode == 1
                  ? "Total Population / Quantity (Optional, e.g. 72000)"
                  : "Total Quantity OR One Known Sector (e.g. 3840000 or Party X = 1260000)",
              hint: _mode == 1
                  ? "e.g. 72000"
                  : "e.g. 15000000 or Unprotected sex = 11000",
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _chartTitleCtrl,
                  "Pie Chart Title (Optional)",
                  hint: "e.g. Students' Roles in Reality Show",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  _unitCtrl,
                  "Unit or Currency (Optional)",
                  hint: "e.g. students, ₦, g, hours",
                ),
              ),
            ],
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
                    "Snap a photo of any Pie Chart or Sectorial Table question from JSS 3 Chapter 19 (Pages 228–233 or 236–237)!",
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
              labelText: "Pie Chart Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A class of 30 students organised their own reality show: 4 producers, 6 mimers, 15 choreographers, 5 costumiers. Represent this on a pie chart...",
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
                "Extract & Construct Pie Chart",
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
          _buildModeSelector(),
          const SizedBox(height: 16),
          _buildModeSpecificForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.pie_chart, color: Colors.white),
            label: const Text(
              "Construct & Solve Pie Chart Step-by-Step",
              style: TextStyle(
                  fontSize: 17.0,
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

  Widget _buildMathForkVisualisationArea(
      PieChartCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.subHeaderLaTeX,
              textStyle: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMathCard(
                  title: cd.card1Title,
                  latex: cd.card1LaTeX,
                  bgColor: Colors.deepPurple.shade50,
                  borderColor: Colors.deepPurple.shade300,
                  titleColor: Colors.deepPurple.shade900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMathCard(
                  title: cd.card2Title,
                  latex: cd.card2LaTeX,
                  bgColor: Colors.amber.shade50,
                  borderColor: Colors.orange.shade800,
                  titleColor: Colors.orange.shade900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMathCard(
                  title: cd.card3Title,
                  latex: cd.card3LaTeX,
                  bgColor: Colors.green.shade50,
                  borderColor: Colors.green.shade700,
                  titleColor: Colors.green.shade900,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
            ),
            child: CustomPaint(
              size: Size(canvasWidth - 40, 350),
              painter: _PieChartCanvasPainter(cd),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple, width: 1.5),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.sectorTableLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
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
                    fontSize: 14.0,
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

  Widget _buildMathCard({
    required String title,
    required String latex,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.8),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex,
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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

    final PieChartCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 820.0);
    const double canvasHeight = 680.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Pie Chart & Sectorial Table Visualizer:",
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
              minScale: 0.35,
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      entry.value,
                      textStyle: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
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
                            fontSize: 15.5,
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
              .map((String l) => l.trim())
              .where((String l) => l.isNotEmpty)
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
                          for (final String mLine in mathLines)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 5.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  mLine,
                                  textStyle: const TextStyle(
                                    fontSize: 15.0,
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
          'Data Presentation: Pie Charts',
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

/// High-legibility CustomPainter for Pie Charts (Fig. 19.11–19.20 Standard) with Central Angle Arcs & Legend Box.
class _PieChartCanvasPainter extends CustomPainter {
  final PieChartCanvasData data;

  const _PieChartCanvasPainter(this.data);

  static const List<Color> _sectorColors = [
    Color(0xFF5E35B1), // Deep Purple
    Color(0xFFD81B60), // Vivid Rose
    Color(0xFF2E7D32), // Forest Green
    Color(0xFFEF6C00), // Deep Orange
    Color(0xFF0277BD), // Ocean Blue
    Color(0xFF6A1B9A), // Royal Plum
    Color(0xFF00838F), // Teal Cyan
  ];

  void _drawText(
      Canvas canvas,
      String text,
      Offset pos, {
        double fontSize = 11.5,
        FontWeight fontWeight = FontWeight.bold,
        Color color = Colors.black87,
        bool centerX = false,
        bool centerY = false,
      }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = pos.dx;
    double dy = pos.dy;
    if (centerX) dx -= tp.width / 2;
    if (centerY) dy -= tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.sectors.isEmpty) return;

    _drawText(
      canvas,
      data.chartTitle,
      Offset(size.width / 2, 10),
      fontSize: 14,
      color: Colors.deepPurple.shade900,
      centerX: true,
    );

    final Offset center = Offset(size.width * 0.34, size.height * 0.54);
    final double radius = math.min(size.width * 0.25, size.height * 0.38);
    final Rect circleRect = Rect.fromCircle(center: center, radius: radius);

    double startRad = -math.pi / 2;

    for (int i = 0; i < data.sectors.length; i++) {
      final PieChartSectorData sec = data.sectors[i];
      final double sweepRad = (sec.angleDegrees / 360.0) * 2 * math.pi;
      final Color fillColor = _sectorColors[i % _sectorColors.length];

      canvas.drawArc(
        circleRect,
        startRad,
        sweepRad,
        true,
        Paint()
          ..color = fillColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill,
      );

      canvas.drawArc(
        circleRect,
        startRad,
        sweepRad,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      final double midRad = startRad + sweepRad / 2;
      if (sec.angleDegrees >= 18) {
        final double labelR = radius * 0.63;
        final Offset labelPos = Offset(
          center.dx + labelR * math.cos(midRad),
          center.dy + labelR * math.sin(midRad),
        );
        _drawText(
          canvas,
          sec.anglePlain,
          labelPos,
          fontSize: 11.5,
          color: Colors.white,
          centerX: true,
          centerY: true,
        );
      }

      final Rect innerArcRect =
      Rect.fromCircle(center: center, radius: radius * 0.22);
      canvas.drawArc(
        innerArcRect,
        startRad,
        sweepRad,
        false,
        Paint()
          ..color = Colors.white70
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );

      startRad += sweepRad;
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.deepPurple.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    final double legendLeft = size.width * 0.62;
    final double legendWidth = size.width - legendLeft - 16;
    const double rowH = 36.0;
    final double legendHeight =
    math.min(size.height - 46, 34.0 + data.sectors.length * rowH);
    final Rect legendRect = Rect.fromLTWH(
      legendLeft,
      36,
      legendWidth,
      legendHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(legendRect, const Radius.circular(10)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(legendRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.deepPurple.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawText(
      canvas,
      "SECTOR KEY (360° TOTAL)",
      Offset(legendRect.center.dx, legendRect.top + 8),
      fontSize: 11.5,
      color: Colors.deepPurple.shade900,
      centerX: true,
    );

    for (int i = 0; i < data.sectors.length; i++) {
      final PieChartSectorData s = data.sectors[i];
      final Color c = _sectorColors[i % _sectorColors.length];
      final double ry = legendRect.top + 30 + i * rowH;
      if (ry + 24 > legendRect.bottom) break;

      final Rect swatch = Rect.fromLTWH(legendRect.left + 12, ry + 2, 16, 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(swatch, const Radius.circular(4)),
        Paint()..color = c,
      );

      final String qtyPart =
      s.quantityPlain != '-' ? " | Qty: ${s.quantityPlain}" : "";
      _drawText(
        canvas,
        "${s.label} (${s.anglePlain})",
        Offset(legendRect.left + 36, ry + 1),
        fontSize: 11.5,
        color: Colors.black87,
      );
      _drawText(
        canvas,
        "Share: ${s.percentagePlain}$qtyPart",
        Offset(legendRect.left + 36, ry + 16),
        fontSize: 10.0,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartCanvasPainter oldDelegate) =>
      oldDelegate.data != data;
}