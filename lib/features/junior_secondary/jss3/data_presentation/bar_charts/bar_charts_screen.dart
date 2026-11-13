import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'bar_charts_logic.dart';
import 'bar_charts_models.dart';

class BarChartsScreen extends StatefulWidget {
  const BarChartsScreen({super.key});

  @override
  State<BarChartsScreen> createState() => _BarChartsScreenState();
}

class _BarChartsScreenState extends State<BarChartsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Vertical Bar Chart (Example 1, Example 2, Fig 19.2, Rev Ex 19 #2)
  // 1: Horizontal Bar Chart (Ex 19.1 #2 Table 19.4)
  // 2: Bar Line Graph (Fig 19.3 & Rev Ex 19 #1 Fig 19.16)
  // 3: Bar Chart with Fractional Subgroup Breakdown (Ex 19.1 #1 Fig 19.9)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _categoriesCtrl = TextEditingController();
  final TextEditingController _valuesCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _xAxisCtrl = TextEditingController();
  final TextEditingController _yAxisCtrl = TextEditingController();
  final TextEditingController _extraCtrl = TextEditingController();

  BarChartResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _categoriesCtrl.dispose();
    _valuesCtrl.dispose();
    _titleCtrl.dispose();
    _xAxisCtrl.dispose();
    _yAxisCtrl.dispose();
    _extraCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BarChartPreset p) {
    setState(() {
      _mode = p.mode;
      _categoriesCtrl.text = p.categoriesInput;
      _valuesCtrl.text = p.valuesInput;
      _titleCtrl.text = p.chartTitle;
      _xAxisCtrl.text = p.xAxisLabel;
      _yAxisCtrl.text = p.yAxisLabel;
      _extraCtrl.text = p.extraInput;
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
              'Please enter a Bar Chart question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 19 Subtopic 1: Data Presentation — Bar Charts & Bar Line Graphs (Pages 220–225 & Pages 233–234).
      Extract the bar chart models into JSON:
      - mode 0: Vertical Bar Chart (standard vertical bars)
      - mode 1: Horizontal Bar Chart (when the question asks for a horizontal bar graph, e.g. Table 19.4 PMS sales)
      - mode 2: Bar Line Graph (when the question asks for or shows a bar line graph, e.g. Fig 19.3 or Fig 19.16)
      - mode 3: Bar Chart with fractional subgroup statements (like Fig 19.9 favourite colours with boys/girls fractions)

      Return ONLY valid JSON:
      {
        "mode": 0,
        "categories": "Audu, Udoh, Iyabo, Nkem, Tola",
        "values": "40, 30, 25, 35, 30",
        "chartTitle": "Scores in a Mathematics Quiz",
        "xAxisLabel": "Students",
        "yAxisLabel": "Scores",
        "extraInput": "30"
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
        _categoriesCtrl.text = (jsonMap['categories'] ?? '').toString();
        _valuesCtrl.text = (jsonMap['values'] ?? '').toString();
        _titleCtrl.text = (jsonMap['chartTitle'] ?? '').toString();
        _xAxisCtrl.text = (jsonMap['xAxisLabel'] ?? '').toString();
        _yAxisCtrl.text = (jsonMap['yAxisLabel'] ?? '').toString();
        _extraCtrl.text = (jsonMap['extraInput'] ?? '').toString();
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
      _result = BarChartsLogic.solveBarChart(
        mode: _mode,
        rawCategories: _categoriesCtrl.text,
        rawValues: _valuesCtrl.text,
        chartTitle: _titleCtrl.text,
        xAxisLabel: _xAxisCtrl.text,
        yAxisLabel: _yAxisCtrl.text,
        extraInput: _extraCtrl.text,
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
    const presets = BarChartsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Chapter 19, Pages 220–225 & 233–234):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.bar_chart,
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
        'Vertical Bar Chart & Interpretation (Examples 1 & 2, Fig 19.2, Rev Ex 19 #2)',
        'icon': Icons.bar_chart,
      },
      {
        'idx': 1,
        'label':
        'Horizontal Bar Chart (Exercise 19.1 #2 Table 19.4 Daily PMS Sales)',
        'icon': Icons.align_horizontal_left,
      },
      {
        'idx': 2,
        'label':
        'Bar Line Graph (Fig 19.3 Dog Owners & Rev Ex 19 #1 Fig 19.16 Pets)',
        'icon': Icons.graphic_eq,
      },
      {
        'idx': 3,
        'label':
        'Bar Chart with Fractional Subgroups (Ex 19.1 #1 Fig 19.9 Favourite Colours)',
        'icon': Icons.pie_chart_outline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Bar Chart Type:"),
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
              "2. Enter Categories and Corresponding Bar Values / Frequencies:"),
          const SizedBox(height: 10),
          _buildTextField(
            _categoriesCtrl,
            "Categories / Labels (separated by commas)",
            hint: "e.g. Audu, Udoh, Iyabo, Nkem, Tola or Mar, Apr, May, Jun",
          ),
          const SizedBox(height: 10),
          _buildTextField(
            _valuesCtrl,
            "Values / Frequencies (separated by commas)",
            hint: "e.g. 40, 30, 25, 35, 30 or 33, 30, 26, 32",
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _xAxisCtrl,
                  "Horizontal Axis Label (Optional)",
                  hint: "e.g. Students, Months, Day",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  _yAxisCtrl,
                  "Vertical Axis Label (Optional)",
                  hint: "e.g. Scores, Temperature (°C)",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _titleCtrl,
                  "Chart Title (Optional)",
                  hint: "e.g. Scores in a Mathematics Quiz",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  _extraCtrl,
                  _mode == 3
                      ? "Subgroup Rules (Optional)"
                      : "Pass Mark / Target (Optional)",
                  hint: _mode == 3
                      ? "e.g. Blue: 1/2 boys; Pink: 2/3 girls"
                      : "e.g. 30",
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
                    "Snap a photo of any Bar Chart or Table from JSS 3 Chapter 19 (Pages 220–225 or Revision Exercise 19)!",
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
              labelText: "Bar Chart Question or Table Data",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Table 19.2 gives the average temperatures in Lagos from March to November: Mar 33, Apr 30, May 26...",
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
                "Extract & Draw Bar Chart",
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
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            label: const Text(
              "Construct & Interpret Bar Chart",
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
      BarChartCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
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
          const SizedBox(height: 4),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          // LARGE HIGH-LEGIBILITY CUSTOM BAR CHART AREA
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple, width: 1.8),
              ),
              child: CustomPaint(
                painter: _LargeBarChartPainter(data: cd),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Math.tex Fraction badges for each bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cd.bars.map((BarChartItemData b) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: b.isHighest
                        ? Colors.green.shade50
                        : Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: b.isHighest
                          ? Colors.green.shade700
                          : Colors.deepPurple.shade200,
                    ),
                  ),
                  child: Math.tex(
                    "\\text{${b.label}}: \\; ${b.valueLaTeX} \\; \\left(${b.fractionOfTotalLaTeX}\\right)",
                    textStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: b.isHighest
                          ? Colors.green.shade900
                          : Colors.deepPurple.shade900,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
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

    final BarChartCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double dynamicMinWidth =
    math.max(660.0, cd.bars.length * 85.0 + 180.0);
    final double canvasWidth = math.max(screenWidth, dynamicMinWidth);
    const double canvasHeight = 560.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Large Bar Chart Visualizer:",
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
                      fontSize: 17.0,
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
                                    fontSize: 15.5,
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
          'Data Presentation: Bar Charts',
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

/// High-legibility CustomPainter for Vertical Bar Charts, Horizontal Bar Charts, and Bar Line Graphs.
class _LargeBarChartPainter extends CustomPainter {
  final BarChartCanvasData data;

  const _LargeBarChartPainter({required this.data});

  static const List<Color> _palette = [
    Color(0xFF5E35B1), // Deep Purple
    Color(0xFFD81B60), // Textbook Magenta/Pink
    Color(0xFF1E88E5), // Blue
    Color(0xFF2E7D32), // Green
    Color(0xFFF4511E), // Deep Orange
    Color(0xFF00897B), // Teal
    Color(0xFF8E24AA), // Purple
    Color(0xFF3949AB), // Indigo
    Color(0xFFC0CA33), // Lime
  ];

  void _drawText(
      Canvas canvas,
      String text,
      Offset position, {
        double fontSize = 12,
        FontWeight fontWeight = FontWeight.w600,
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

    double dx = position.dx;
    double dy = position.dy;
    if (centerX) dx -= tp.width / 2;
    if (alignRight) dx -= tp.width;
    if (centerY) dy -= tp.height / 2;

    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.bars.isEmpty) return;

    // Draw Chart Title at Top Center
    _drawText(
      canvas,
      data.chartTitle,
      Offset(size.width / 2, 4),
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF4A148C),
      centerX: true,
    );

    if (data.mode == 1) {
      _paintHorizontalBarChart(canvas, size);
    } else {
      _paintVerticalOrBarLineChart(canvas, size, isBarLine: data.mode == 2);
    }
  }

  void _paintVerticalOrBarLineChart(
      Canvas canvas,
      Size size, {
        required bool isBarLine,
      }) {
    const double leftMargin = 68.0;
    const double rightMargin = 32.0;
    const double topMargin = 40.0;
    const double bottomMargin = 62.0;

    final double chartLeft = leftMargin;
    final double chartRight = size.width - rightMargin;
    final double chartTop = topMargin;
    final double chartBottom = size.height - bottomMargin;
    final double chartWidth = chartRight - chartLeft;
    final double chartHeight = chartBottom - chartTop;

    if (chartWidth <= 20 || chartHeight <= 20) return;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFAD1457) // Textbook magenta axis line
      ..strokeWidth = 2.2;

    // Y-axis ticks and horizontal gridlines
    final int numSteps = (data.maxScaleY / data.scaleStepY).round();
    for (int i = 0; i <= numSteps; i++) {
      final double val = i * data.scaleStepY;
      final double ratio = (val / data.maxScaleY).clamp(0.0, 1.0);
      final double y = chartBottom - ratio * chartHeight;

      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
      canvas.drawLine(
          Offset(chartLeft - 5, y), Offset(chartLeft, y), axisPaint);

      final String tickLabel = (val - val.roundToDouble()).abs() < 1e-9
          ? val.round().toString()
          : val.toStringAsFixed(1);
      _drawText(
        canvas,
        tickLabel,
        Offset(chartLeft - 9, y),
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        alignRight: true,
        centerY: true,
      );
    }

    // Draw equal-width bars or bar lines with equal gaps
    final int n = data.bars.length;
    final double slotWidth = chartWidth / n;
    final double barWidth = math.min(slotWidth * 0.56, 52.0);

    for (int i = 0; i < n; i++) {
      final BarChartItemData item = data.bars[i];
      final double centerX = chartLeft + (i + 0.5) * slotWidth;
      final double ratio = (item.value / data.maxScaleY).clamp(0.0, 1.0);
      final double barTop = chartBottom - ratio * chartHeight;
      final Color barColor = _palette[i % _palette.length];

      if (isBarLine) {
        // Bar Line Graph (Fig. 19.3 & Fig. 19.16)
        final Paint linePaint = Paint()
          ..color = barColor
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(centerX, chartBottom), Offset(centerX, barTop), linePaint);
        canvas.drawCircle(
            Offset(centerX, barTop), 5.5, Paint()..color = barColor);
      } else {
        // Standard Rectangular Bar of Equal Width
        final Rect rect = Rect.fromLTRB(
          centerX - barWidth / 2,
          barTop,
          centerX + barWidth / 2,
          chartBottom,
        );
        final Paint fillPaint = Paint()
          ..color = barColor.withValues(alpha: 0.88)
          ..style = PaintingStyle.fill;
        final Paint borderPaint = Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke;

        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
      }

      // Value badge above bar
      _drawText(
        canvas,
        "${item.valueDisplayPlain}${item.isHighest ? ' ★' : ''}",
        Offset(centerX, barTop - 15),
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: item.isHighest ? Colors.green.shade900 : Colors.deepPurple,
        centerX: true,
      );

      // Category label below X-axis
      _drawText(
        canvas,
        item.label,
        Offset(centerX, chartBottom + 8),
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        centerX: true,
      );
    }

    // Draw Mean reference line
    if (data.meanValue > 0 && data.meanValue <= data.maxScaleY) {
      final double meanY =
          chartBottom - (data.meanValue / data.maxScaleY) * chartHeight;
      final Paint meanPaint = Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 1.6;
      for (double x = chartLeft; x < chartRight; x += 10) {
        canvas.drawLine(
            Offset(x, meanY), Offset(math.min(x + 6, chartRight), meanY), meanPaint);
      }
      _drawText(
        canvas,
        "Mean = ${data.meanValue.toStringAsFixed(1)}",
        Offset(chartRight - 4, meanY - 14),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade900,
        alignRight: true,
      );
    }

    // Draw Axes with Textbook Arrowheads
    canvas.drawLine(
        Offset(chartLeft, chartBottom), Offset(chartLeft, chartTop - 10), axisPaint);
    canvas.drawLine(Offset(chartLeft, chartBottom),
        Offset(chartRight + 10, chartBottom), axisPaint);

    // Axis titles
    _drawText(
      canvas,
      data.xAxisLabel,
      Offset((chartLeft + chartRight) / 2, size.height - 20),
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFAD1457),
      centerX: true,
    );
    _drawText(
      canvas,
      data.yAxisLabel,
      Offset(8, chartTop - 22),
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFAD1457),
    );
  }

  void _paintHorizontalBarChart(Canvas canvas, Size size) {
    const double leftMargin = 78.0;
    const double rightMargin = 48.0;
    const double topMargin = 38.0;
    const double bottomMargin = 54.0;

    final double chartLeft = leftMargin;
    final double chartRight = size.width - rightMargin;
    final double chartTop = topMargin;
    final double chartBottom = size.height - bottomMargin;
    final double chartWidth = chartRight - chartLeft;
    final double chartHeight = chartBottom - chartTop;

    if (chartWidth <= 20 || chartHeight <= 20) return;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFAD1457)
      ..strokeWidth = 2.2;

    // X-axis ticks & vertical gridlines
    final int numSteps = (data.maxScaleY / data.scaleStepY).round();
    for (int i = 0; i <= numSteps; i++) {
      final double val = i * data.scaleStepY;
      final double ratio = (val / data.maxScaleY).clamp(0.0, 1.0);
      final double x = chartLeft + ratio * chartWidth;

      canvas.drawLine(Offset(x, chartTop), Offset(x, chartBottom), gridPaint);
      canvas.drawLine(
          Offset(x, chartBottom), Offset(x, chartBottom + 5), axisPaint);

      final String tickLabel = (val - val.roundToDouble()).abs() < 1e-9
          ? val.round().toString()
          : val.toStringAsFixed(1);
      _drawText(
        canvas,
        tickLabel,
        Offset(x, chartBottom + 8),
        fontSize: 11.0,
        fontWeight: FontWeight.bold,
        centerX: true,
      );
    }

    final int n = data.bars.length;
    final double slotHeight = chartHeight / n;
    final double barHeight = math.min(slotHeight * 0.62, 34.0);

    for (int i = 0; i < n; i++) {
      final BarChartItemData item = data.bars[i];
      final double centerY = chartTop + (i + 0.5) * slotHeight;
      final double ratio = (item.value / data.maxScaleY).clamp(0.0, 1.0);
      final double barRight = chartLeft + ratio * chartWidth;
      final Color barColor = _palette[i % _palette.length];

      final Rect rect = Rect.fromLTRB(
        chartLeft,
        centerY - barHeight / 2,
        barRight,
        centerY + barHeight / 2,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = barColor.withValues(alpha: 0.88)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke,
      );

      _drawText(
        canvas,
        item.label,
        Offset(chartLeft - 8, centerY),
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        alignRight: true,
        centerY: true,
      );

      _drawText(
        canvas,
        item.valueDisplayPlain,
        Offset(barRight + 6, centerY),
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
        centerY: true,
      );
    }

    canvas.drawLine(
        Offset(chartLeft, chartBottom), Offset(chartLeft, chartTop - 8), axisPaint);
    canvas.drawLine(Offset(chartLeft, chartBottom),
        Offset(chartRight + 10, chartBottom), axisPaint);

    _drawText(
      canvas,
      data.xAxisLabel,
      Offset((chartLeft + chartRight) / 2, size.height - 20),
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFAD1457),
      centerX: true,
    );
  }

  @override
  bool shouldRepaint(covariant _LargeBarChartPainter oldDelegate) => true;
}