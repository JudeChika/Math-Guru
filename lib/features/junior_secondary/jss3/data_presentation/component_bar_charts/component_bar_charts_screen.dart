import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'component_bar_charts_logic.dart';
import 'component_bar_charts_models.dart';

class ComponentBarChartsScreen extends StatefulWidget {
  const ComponentBarChartsScreen({super.key});

  @override
  State<ComponentBarChartsScreen> createState() =>
      _ComponentBarChartsScreenState();
}

class _ComponentBarChartsScreenState extends State<ComponentBarChartsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Method I — Side-by-Side Component Bar Chart (Fig. 19.7, Table 19.5, 19.6, 19.10)
  // 1: Method II — Stacked (Placed on Top) Component Bar Chart (Fig. 19.8, Table 19.7, 19.9, 19.20)
  // 2: Horizontal Compound Bar Chart (Table 19.8 Air Emissions)
  // 3: Component Bar Graph Interpretation & Midpoint Estimation (Example 4 & Ex 19.1 #4)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _categoriesCtrl = TextEditingController();
  final TextEditingController _componentsRowsCtrl = TextEditingController();
  final TextEditingController _chartTitleCtrl = TextEditingController();
  final TextEditingController _xAxisCtrl = TextEditingController();
  final TextEditingController _yAxisCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();

  ComponentBarChartResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _categoriesCtrl.dispose();
    _componentsRowsCtrl.dispose();
    _chartTitleCtrl.dispose();
    _xAxisCtrl.dispose();
    _yAxisCtrl.dispose();
    _unitCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(ComponentBarChartPreset p) {
    setState(() {
      _mode = p.mode;
      _categoriesCtrl.text = p.categoriesInput;
      _componentsRowsCtrl.text = p.componentsRowsInput;
      _chartTitleCtrl.text = p.chartTitle;
      _xAxisCtrl.text = p.xAxisLabel;
      _yAxisCtrl.text = p.yAxisLabel;
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
              'Please enter a Component Bar Chart question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 19 Subtopic 2: Component (Compound) Bar Charts (Pages 222–227 & Pages 234–235).
      Extract the category labels and each component row from the user's question or image:
      - mode 0: Side-by-side component bar chart (Method I, Fig. 19.7, Table 19.5, 19.6, 19.10, 19.19)
      - mode 1: Stacked component bar chart (Method II, Fig. 19.8, Table 19.7, 19.9, Fig. 19.18 / Table 19.20)
      - mode 2: Horizontal compound bar chart (Table 19.8 Air emissions)
      - mode 3: Interpretation questions on a component bar chart (Example 4)
      - Write mixed fractions as "whole num/den" (e.g. "1 1/2", "2 1/2", "7 1/2"). Do NOT include a "Total" row in componentsRowsInput (our solver computes the Total row automatically).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "categoriesInput": "Mon, Tue, Wed, Thur, Fri, Sat, Sun",
        "componentsRowsInput": "NTA: 500, 1500, 1000, 2000, 3000, 2500, 3000\\nAIT: 1000, 500, 1000, 1500, 1500, 3000, 3000",
        "chartTitle": "TV Viewers Each Night",
        "xAxisLabel": "Days",
        "yAxisLabel": "Viewers",
        "unit": "viewers"
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
        _componentsRowsCtrl.text =
            (jsonMap['componentsRowsInput'] ?? '').toString();
        _chartTitleCtrl.text = (jsonMap['chartTitle'] ?? '').toString();
        _xAxisCtrl.text = (jsonMap['xAxisLabel'] ?? '').toString();
        _yAxisCtrl.text = (jsonMap['yAxisLabel'] ?? '').toString();
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
      _result = ComponentBarChartsLogic.solveComponentBarChart(
        mode: _mode,
        rawCategoriesInput: _categoriesCtrl.text,
        rawComponentsRowsInput: _componentsRowsCtrl.text,
        chartTitle: _chartTitleCtrl.text,
        xAxisLabel: _xAxisCtrl.text,
        yAxisLabel: _yAxisCtrl.text,
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
    const presets = ComponentBarChartsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 222–227 & 233–235):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.stacked_bar_chart,
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
        'Method I: Side-by-Side Component Bar Chart (Fig. 19.7, Table 19.5, 19.6, 19.10)',
        'icon': Icons.bar_chart,
      },
      {
        'idx': 1,
        'label':
        'Method II: Stacked Component Bar Chart (Fig. 19.8, Table 19.7, 19.9, 19.20)',
        'icon': Icons.stacked_bar_chart,
      },
      {
        'idx': 2,
        'label':
        'Horizontal Compound Bar Chart (Exercise 19.1 No. 6 Table 19.8)',
        'icon': Icons.align_horizontal_left,
      },
      {
        'idx': 3,
        'label':
        'Interpret Component Bar Graph & Estimate Values (Example 4 & Ex 19.1 No. 4)',
        'icon': Icons.analytics_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Component Bar Chart Mode:"),
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
              "2. Enter Category Labels & Component Data Rows (Supports Integers, Decimals & Mixed Fractions):"),
          const SizedBox(height: 10),
          _buildTextField(
            _categoriesCtrl,
            "Category Labels (comma-separated)",
            hint: "e.g. Mon, Tue, Wed, Thur, Fri, Sat, Sun",
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _componentsRowsCtrl,
            "Component Rows (One Component per Line: Name: v1, v2, v3...)",
            hint:
            "e.g.\nNTA: 500, 1500, 1000, 2000, 3000, 2500, 3000\nAIT: 1000, 500, 1000, 1500, 1500, 3000, 3000",
            maxLines: 4,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _chartTitleCtrl,
                  "Chart Title (Optional)",
                  hint: "e.g. TV Viewers Each Night",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  _unitCtrl,
                  "Unit (Optional)",
                  hint: "e.g. viewers, h, %",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _xAxisCtrl,
                  "Horizontal Axis Label (Optional)",
                  hint: "e.g. Days or Month",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  _yAxisCtrl,
                  "Vertical Axis Label (Optional)",
                  hint: "e.g. Viewers or Hours",
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
                    "Snap a photo of any Component (Compound) Bar Chart or multi-row table from JSS 3 Chapter 19 (Pages 222–227 or 234–235)!",
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
              labelText: "Component Bar Chart Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Table 19.3 shows the number of people in Port Harcourt who watch NTA and AIT each night. Draw a component bar graph...",
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
                "Extract & Draw Component Bar Chart",
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
            icon: const Icon(Icons.stacked_bar_chart, color: Colors.white),
            label: const Text(
              "Draw & Solve Component Bar Chart",
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

  Widget _buildMathForkVisualisationArea(
      ComponentBarChartCanvasData cd,
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
              painter: _ComponentBarChartPainter(cd),
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
                  cd.summaryTableLaTeX,
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

    final ComponentBarChartCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth =
    math.max(screenWidth, math.max(820.0, cd.groups.length * 115.0));
    const double canvasHeight = 670.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Component Bar Chart & Table Visualizer:",
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
          'Data Presentation: Component Bar Charts',
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

/// High-legibility CustomPainter for Method I (Side-by-Side), Method II (Stacked), and Horizontal Compound Bar Charts.
class _ComponentBarChartPainter extends CustomPainter {
  final ComponentBarChartCanvasData data;

  const _ComponentBarChartPainter(this.data);

  static const List<Color> _componentColors = [
    Color(0xFFC2185B), // Deep Rose/Magenta (Textbook NTA / Abuja shade)
    Color(0xFF4A148C), // Deep Purple (Textbook AIT / 2nd component shade)
    Color(0xFF2E7D32), // Forest Green (3rd component)
    Color(0xFFE65100), // Deep Orange (4th component)
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
        bool alignRight = false,
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
    if (alignRight) dx -= tp.width;
    if (centerY) dy -= tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.groups.isEmpty || data.componentNames.isEmpty) return;

    _drawText(
      canvas,
      data.chartTitle,
      Offset(size.width / 2, 10),
      fontSize: 14,
      color: Colors.deepPurple.shade900,
      centerX: true,
    );

    const double legendWidth = 135.0;
    const double legendRowHeight = 20.0;
    final double legendHeight =
        26.0 + data.componentNames.length * legendRowHeight;
    final Rect legendRect = Rect.fromLTWH(
      size.width - legendWidth - 14,
      32,
      legendWidth,
      legendHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(legendRect, const Radius.circular(8)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(legendRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.deepPurple.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    _drawText(
      canvas,
      "KEY",
      Offset(legendRect.center.dx, legendRect.top + 5),
      fontSize: 11.5,
      color: Colors.deepPurple.shade900,
      centerX: true,
    );

    for (int r = 0; r < data.componentNames.length; r++) {
      final Color c = _componentColors[r % _componentColors.length];
      final double ry = legendRect.top + 24 + r * legendRowHeight;
      final Rect box = Rect.fromLTWH(legendRect.left + 10, ry, 13, 13);
      canvas.drawRect(box, Paint()..color = c);
      canvas.drawRect(
        box,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final String label = data.componentNames[r].length > 13
          ? "${data.componentNames[r].substring(0, 12)}."
          : data.componentNames[r];
      _drawText(
        canvas,
        label,
        Offset(legendRect.left + 29, ry + 6.5),
        fontSize: 11,
        centerY: true,
      );
    }

    if (data.chartStyle == 2) {
      _paintHorizontalCompoundChart(canvas, size, legendWidth);
    } else {
      _paintVerticalComponentChart(canvas, size, legendWidth);
    }
  }

  void _paintVerticalComponentChart(
      Canvas canvas, Size size, double legendWidth) {
    const double leftPad = 68.0;
    final double rightPad = legendWidth + 28.0;
    const double topPad = 38.0;
    const double bottomPad = 52.0;

    final double plotWidth = size.width - leftPad - rightPad;
    final double plotHeight = size.height - topPad - bottomPad;
    const double originX = leftPad;
    final double originY = topPad + plotHeight;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    final int numTicks = (data.yAxisMax / data.yAxisStep).round();
    for (int i = 0; i <= numTicks; i++) {
      final double val = i * data.yAxisStep;
      final double ratio = (val / data.yAxisMax).clamp(0.0, 1.0);
      final double y = originY - ratio * plotHeight;

      canvas.drawLine(
          Offset(originX, y), Offset(originX + plotWidth, y), gridPaint);
      canvas.drawLine(Offset(originX - 5, y), Offset(originX, y), axisPaint);

      final String tickStr = (val - val.roundToDouble()).abs() < 1e-9
          ? val.round().toString()
          : val.toStringAsFixed(1);
      _drawText(
        canvas,
        tickStr,
        Offset(originX - 8, y),
        fontSize: 11,
        alignRight: true,
        centerY: true,
      );
    }

    canvas.drawLine(
        const Offset(originX, topPad - 8), Offset(originX, originY), axisPaint);
    canvas.drawLine(Offset(originX, originY),
        Offset(originX + plotWidth + 10, originY), axisPaint);

    final int nGroups = data.groups.length;
    final int nComps = data.componentNames.length;
    final double slotWidth = plotWidth / nGroups;

    for (int g = 0; g < nGroups; g++) {
      final ComponentBarCategoryGroup group = data.groups[g];
      final double slotLeft = originX + g * slotWidth;
      final double centerX = slotLeft + slotWidth / 2;

      if (data.chartStyle == 1) {
        final double barWidth = (slotWidth * 0.56).clamp(18.0, 56.0);
        double currentTopY = originY;

        for (int r = 0; r < nComps; r++) {
          final double val = group.componentValues[r];
          final double segHeight =
              (val / data.yAxisMax).clamp(0.0, 1.0) * plotHeight;
          final Rect segRect = Rect.fromLTWH(
            centerX - barWidth / 2,
            currentTopY - segHeight,
            barWidth,
            segHeight,
          );

          final Color fillColor =
          _componentColors[r % _componentColors.length];
          canvas.drawRect(segRect, Paint()..color = fillColor);
          canvas.drawRect(
            segRect,
            Paint()
              ..color = Colors.black87
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2,
          );

          if (segHeight >= 18) {
            _drawText(
              canvas,
              group.componentPlain[r],
              segRect.center,
              fontSize: 10.0,
              color: Colors.white,
              centerX: true,
              centerY: true,
            );
          }
          currentTopY -= segHeight;
        }

        _drawText(
          canvas,
          group.totalPlain,
          Offset(centerX, currentTopY - 10),
          fontSize: 10.5,
          color: Colors.deepPurple.shade900,
          centerX: true,
          centerY: true,
        );
      } else {
        final double clusterWidth = (slotWidth * 0.76).clamp(24.0, 84.0);
        final double subBarWidth = clusterWidth / nComps;
        final double startX = centerX - clusterWidth / 2;

        for (int r = 0; r < nComps; r++) {
          final double val = group.componentValues[r];
          final double barHeight =
              (val / data.yAxisMax).clamp(0.0, 1.0) * plotHeight;
          final double bx = startX + r * subBarWidth;
          final Rect barRect = Rect.fromLTWH(
            bx,
            originY - barHeight,
            subBarWidth,
            barHeight,
          );

          final Color fillColor =
          _componentColors[r % _componentColors.length];
          canvas.drawRect(barRect, Paint()..color = fillColor);
          canvas.drawRect(
            barRect,
            Paint()
              ..color = Colors.black87
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.1,
          );

          _drawText(
            canvas,
            group.componentPlain[r],
            Offset(bx + subBarWidth / 2, originY - barHeight - 9),
            fontSize: 9.5,
            color: fillColor,
            centerX: true,
            centerY: true,
          );
        }
      }

      _drawText(
        canvas,
        group.categoryLabel,
        Offset(centerX, originY + 14),
        fontSize: 11,
        centerX: true,
        centerY: true,
      );
    }

    _drawText(
      canvas,
      data.xAxisLabel,
      Offset(originX + plotWidth / 2, size.height - 12),
      fontSize: 12,
      color: Colors.deepPurple.shade900,
      centerX: true,
      centerY: true,
    );
  }

  void _paintHorizontalCompoundChart(
      Canvas canvas, Size size, double legendWidth) {
    const double leftPad = 78.0;
    final double rightPad = legendWidth + 28.0;
    const double topPad = 38.0;
    const double bottomPad = 48.0;

    final double plotWidth = size.width - leftPad - rightPad;
    final double plotHeight = size.height - topPad - bottomPad;
    const double originX = leftPad;
    final double originY = topPad + plotHeight;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    final int numTicks = (data.yAxisMax / data.yAxisStep).round();
    for (int i = 0; i <= numTicks; i++) {
      final double val = i * data.yAxisStep;
      final double ratio = (val / data.yAxisMax).clamp(0.0, 1.0);
      final double x = originX + ratio * plotWidth;

      canvas.drawLine(Offset(x, topPad), Offset(x, originY), gridPaint);
      canvas.drawLine(Offset(x, originY), Offset(x, originY + 5), axisPaint);

      final String tickStr = (val - val.roundToDouble()).abs() < 1e-9
          ? val.round().toString()
          : val.toStringAsFixed(1);
      _drawText(
        canvas,
        tickStr,
        Offset(x, originY + 14),
        fontSize: 10.5,
        centerX: true,
        centerY: true,
      );
    }

    canvas.drawLine(
        const Offset(originX, topPad - 6), Offset(originX, originY), axisPaint);
    canvas.drawLine(Offset(originX, originY),
        Offset(originX + plotWidth + 10, originY), axisPaint);

    final int nGroups = data.groups.length;
    final int nComps = data.componentNames.length;
    final double slotHeight = plotHeight / nGroups;

    for (int g = 0; g < nGroups; g++) {
      final ComponentBarCategoryGroup group = data.groups[g];
      final double slotTop = topPad + g * slotHeight;
      final double centerY = slotTop + slotHeight / 2;
      final double clusterHeight = (slotHeight * 0.75).clamp(18.0, 52.0);
      final double subBarHeight = clusterHeight / nComps;
      final double startY = centerY - clusterHeight / 2;

      for (int r = 0; r < nComps; r++) {
        final double val = group.componentValues[r];
        final double barW =
            (val / data.yAxisMax).clamp(0.0, 1.0) * plotWidth;
        final double by = startY + r * subBarHeight;
        final Rect barRect = Rect.fromLTWH(originX, by, barW, subBarHeight);

        final Color fillColor = _componentColors[r % _componentColors.length];
        canvas.drawRect(barRect, Paint()..color = fillColor);
        canvas.drawRect(
          barRect,
          Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        _drawText(
          canvas,
          group.componentPlain[r],
          Offset(originX + barW + 5, by + subBarHeight / 2),
          fontSize: 9.5,
          color: fillColor,
          centerY: true,
        );
      }

      _drawText(
        canvas,
        group.categoryLabel,
        Offset(originX - 8, centerY),
        fontSize: 11,
        alignRight: true,
        centerY: true,
      );
    }

    _drawText(
      canvas,
      data.xAxisLabel,
      Offset(originX + plotWidth / 2, size.height - 12),
      fontSize: 12,
      color: Colors.deepPurple.shade900,
      centerX: true,
      centerY: true,
    );
  }

  @override
  bool shouldRepaint(covariant _ComponentBarChartPainter oldDelegate) =>
      oldDelegate.data != data;
}