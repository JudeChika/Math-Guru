import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'non_rational_numbers_logic.dart';
import 'non_rational_numbers_models.dart';

class NonRationalNumbersScreen extends StatefulWidget {
  const NonRationalNumbersScreen({super.key});

  @override
  State<NonRationalNumbersScreen> createState() =>
      _NonRationalNumbersScreenState();
}

class _NonRationalNumbersScreenState extends State<NonRationalNumbersScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Identify Rational & Non-Rational Numbers (Exercise 5.2 #1–20 & Revision Exercise 5 #3a–f)
  // 1: The Value of Pi (π = C / D), Historical Table 5.1 & Experimental Circle Graph Table 5.2 (Activity 5.2 #1–4)
  // 2: Circle Drawn Inside a Square — Exact Values & Rationality (Revision Exercise 5 #4–8, Fig. 5.1)
  // 3: Multiplying Rational & Irrational Numbers (Revision Exercise 5 #9a–b)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();

  NonRationalNumbersResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(NonRationalNumbersPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
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
              'Please enter a non-rational numbers question or upload a textbook image.'),
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
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final promptText = '''
      You are a strict JSON models extractor for JSS3 Chapter 5 Subtopic 2: Non-Rational Numbers (Pages 54–57, Exercise 5.2 #1–20, Tables 5.1 & 5.2, Activity 5.2, and Revision Exercise 5 #3–9).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Identifying whether a number or expression is rational or non-rational (Exercise 5.2 #1–20 & Rev Ex 5 #3a–f: e.g. sqrt(20), 1/sqrt(2), 5/sqrt(25), 1/sin(29), sqrt(0.49), sqrt(1 7/9), 22/7, 1/pi, (sqrt(17))^2, 7^(-1/2), 1/3 + 3^(-2)). Put the expression in "input1".
        1 for The Value of Pi (pi = C / D), Table 5.1, and Table 5.2 / Activity 5.2 (put diameters in "input1" and C/D queries in "input2").
        2 for Circle of radius r drawn inside a square (Figure 5.1, Revision Exercise 5 #4–8: put radius r in "input1", e.g. "3").
        3 for Multiplying rational and irrational numbers (Revision Exercise 5 #9a & #9b).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "sqrt(1 7/9)",
        "input2": ""
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
        if (jsonMap['input1'] != null) {
          _input1Ctrl.text = jsonMap['input1'].toString();
        }
        if (jsonMap['input2'] != null) {
          _input2Ctrl.text = jsonMap['input2'].toString();
        }
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
      if (_mode == 0) {
        _result = NonRationalNumbersLogic.solveClassifyRationalOrNonRational(
          rawExprStr: _input1Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = NonRationalNumbersLogic.solvePiAndCircleGraphTable(
          diametersCsvStr: _input1Ctrl.text,
          queriesCsvStr: _input2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = NonRationalNumbersLogic.solveCircleInSquareFig5_1(
          radiusStr: _input1Ctrl.text,
        );
      } else {
        _result = NonRationalNumbersLogic.solveRationalIrrationalProducts();
      }
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
    const presets = NonRationalNumbersLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Exercise 5.2 #1–20, Tables 5.1–5.2 & Rev Ex 5 #3–9):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.fact_check_outlined,
                      size: 16,
                      color: Colors.deepPurple),
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
        'label': 'Identify Rational vs. Non-Rational (Ex 5.2 #1–20 & Rev #3)',
        'icon': Icons.fact_check_outlined,
      },
      {
        'idx': 1,
        'label': 'The Value of Pi (π = C/D) & Tables 5.1, 5.2 (Activity 5.2)',
        'icon': Icons.pie_chart_outline,
      },
      {
        'idx': 2,
        'label': 'Circle Inside a Square — Fig. 5.1 (Rev Ex 5 #4–8)',
        'icon': Icons.crop_square,
      },
      {
        'idx': 3,
        'label': 'Multiplying Rational & Irrational Numbers (Rev Ex 5 #9a–b)',
        'icon': Icons.close,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Non-Rational Numbers Problem Mode:"),
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
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color: isSelected
                    ? Colors.deepPurple
                    : Colors.deepPurple.shade200,
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
          if (_mode == 0) ...[
            _buildSectionTitle(
                "2. Identify Rational and Non-Rational Numbers (Exercise 5.2 #1–20 & Revision Exercise 5 #3a–f):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Enter Number or Expression (Use sqrt(...), pi, sin(29), etc.)",
              hint:
              "e.g. sqrt(20), 1/sqrt(2), 5/sqrt(25), sqrt(1 7/9), 22/7, 1/pi, (sqrt(17))^2, or 1/3 + 3^(-2)",
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                {'lbl': '√20 (#1)', 'val': 'sqrt(20)'},
                {'lbl': '1/√2 (#2)', 'val': '1/sqrt(2)'},
                {'lbl': '1/π (#7)', 'val': '1/pi'},
                {'lbl': '22/7 (#8)', 'val': '22/7'},
                {'lbl': '5/√25 (#9)', 'val': '5/sqrt(25)'},
                {'lbl': '1/sin 29° (#10)', 'val': '1/sin(29)'},
                {'lbl': '√0.49 (#14)', 'val': 'sqrt(0.49)'},
                {'lbl': '√(1 7/9) (#15)', 'val': 'sqrt(1 7/9)'},
                {'lbl': '(√17)² (Rev #3c)', 'val': '(sqrt(17))^2'},
                {'lbl': '7^(-1/2) (Rev #3e)', 'val': '7^(-1/2)'},
              ].map((chip) {
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    chip['lbl']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () {
                    setState(() => _input1Ctrl.text = chip['val']!);
                    _solveManual();
                  },
                );
              }).toList(),
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. The Value of Pi (π = C / D), Table 5.1 & Activity 5.2 Circle Measurements (Table 5.2):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Diameters in cm for Table 5.2 (Comma-Separated)",
              hint: "e.g. 8, 12, 16, 20, 24",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input2Ctrl,
              "Graph Reading Queries (Activity 5.2 #4b: C=... or D=...)",
              hint: "e.g. C=14, C=18, C=22, D=8.8",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Circle of Radius r Drawn Inside a Square (Revision Exercise 5 #4–8, Figure 5.1 on Page 57):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Radius of the Circle (r) in cm",
              hint: "e.g. 3 (as in Figure 5.1 on Page 57)",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Multiplying Rational and Irrational Numbers (Revision Exercise 5 #9a & #9b, Page 57):"),
            const SizedBox(height: 8),
            const Text(
              "Tap 'Classify & Explain Step-by-Step' below to view the complete proofs and examples for both Question 9(a) and Question 9(b)!",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                    "Snap a photo of any Non-Rational Numbers or π question from JSS 3 Chapter 5 (Pages 54–57, Exercise 5.2 #1–20, or Revision Exercise 5 #3–9)!",
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
              labelText: "Non-Rational Numbers Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Identify whether √(1 7/9), 5/√25, 1/π, and 22/7 are rational or non-rational. Or: A circle of radius 3 cm is drawn inside a square...",
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
                "Extract & Solve Non-Rational Question",
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
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Classify & Explain Step-by-Step",
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

  /// Builds the Interactive Visualisation Area where EVERY fraction, radical, and π expression
  /// (plus the Figure 5.1 Circle-Inside-a-Square diagram) is rendered using Math.tex!
  Widget _buildMathForkVisualisationArea(
      NonRationalNumbersCanvasData cd,
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
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          if (_mode == 2)
          // Mode 2: Authentic Figure 5.1 Circle Drawn Inside a Square + Math.tex Cards!
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 148,
                  height: 148,
                  child: CustomPaint(
                    painter: _Fig5_1CircleInSquarePainter(
                      radiusCm: cd.circleRadiusCm,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildMathCard(
                        title: cd.card1Title,
                        latex: cd.card1LaTeX,
                        bgColor: Colors.green.shade50,
                        borderColor: Colors.green.shade700,
                        titleColor: Colors.green.shade900,
                      ),
                      const SizedBox(height: 8),
                      _buildMathCard(
                        title: cd.card2Title,
                        latex: cd.card2LaTeX,
                        bgColor: Colors.amber.shade50,
                        borderColor: Colors.orange.shade800,
                        titleColor: Colors.orange.shade900,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple, width: 1.8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.middleBannerLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 14.5,
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
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
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
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex,
              textStyle: const TextStyle(
                fontSize: 14.5,
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

    final NonRationalNumbersCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    final double canvasHeight = _mode == 2 ? 375.0 : 350.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Non-Rational Numbers & Pi (π) Visualizer:",
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
              title: Text(
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
                  Text(
                    e.value.description,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.45,
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
          'Non-Rational Numbers',
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

/// Authentic CustomPainter for Figure 5.1 on Page 57:
/// Circle of radius r drawn inside a square with shaded corners outside the circle!
class _Fig5_1CircleInSquarePainter extends CustomPainter {
  final double radiusCm;

  _Fig5_1CircleInSquarePainter({required this.radiusCm});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height) - 12.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect sqRect = Rect.fromCenter(center: center, width: s, height: s);

    // 1. Pink/Magenta Shaded Square (matching Figure 5.1 on Page 57!)
    canvas.drawRect(sqRect, Paint()..color = Colors.pink.shade200);
    canvas.drawRect(
      sqRect,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 2. White Inscribed Circle of Radius r
    canvas.drawCircle(center, s / 2, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      s / 2,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 3. Slanted Radius Line from Center to Top-Right Edge (matching Figure 5.1!)
    const double angleRad = -math.pi / 3.2;
    final Offset edgePt = Offset(
      center.dx + (s / 2) * math.cos(angleRad),
      center.dy + (s / 2) * math.sin(angleRad),
    );
    canvas.drawLine(
      center,
      edgePt,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.8,
    );
    canvas.drawCircle(center, 2.8, Paint()..color = Colors.black87);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: "${NonRationalNumbersLogic.fmt(radiusCm)} cm",
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        (center.dx + edgePt.dx) / 2 - tp.width / 2 - 8,
        (center.dy + edgePt.dy) / 2 - tp.height / 2 - 6,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _Fig5_1CircleInSquarePainter oldDelegate) =>
      oldDelegate.radiusCm != radiusCm;
}