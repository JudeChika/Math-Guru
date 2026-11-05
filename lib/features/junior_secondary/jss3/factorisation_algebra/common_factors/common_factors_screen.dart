import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'common_factors_logic.dart';
import 'common_factors_models.dart';

class CommonFactorsScreen extends StatefulWidget {
  const CommonFactorsScreen({super.key});

  @override
  State<CommonFactorsScreen> createState() => _CommonFactorsScreenState();
}

class _CommonFactorsScreenState extends State<CommonFactorsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Factorise 2-Term & 3-Term Expressions Completely (Example 3a–c, Example 4a–c, Ex 7.3 #1–20 & Rev Ex 7 Part C)
  // 1: Complete Partially Factorised Expressions E = F(   ) (Revision Exercise 7 Part B #1–10)
  // 2: Quantitative Reasoning Factorisation Box Puzzles (Page 70 #1–9)
  // 3: Reverse Expansion Verification Check

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _input4Ctrl = TextEditingController();
  final TextEditingController _input5Ctrl = TextEditingController();

  CommonFactorsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _input5Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(CommonFactorsPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _input5Ctrl.text = p.input5;
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
              'Please enter a factorisation question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 7 Subtopic 3: Factorisation by Taking Out Common Factors (Pages 67–68 & 70–71, Examples 3 & 4, Exercise 7.3 #1–20, Quantitative Reasoning #1–9, and Revision Exercise 7 Parts B & C).
      Classify the question or image into one of 3 modes:
      - "mode":
        0 for Factorising a 2-term or 3-term algebraic expression completely (Examples 3 & 4, Ex 7.3 #1-20, Rev Ex 7 Part C: put the polynomial in "input1", e.g. "12x^3 - 15x^2 + 9x").
        1 for Completing a partially factorised expression like "24y - 36 = 12(   )" (Rev Ex 7 Part B #1-10: put the polynomial in "input1" and the given outside factor in "input2").
        2 for Quantitative Reasoning Factorisation Box Puzzles (Page 70 #1-9: put Outside Factor in "input1", Top-1 in "input2", Top-2 in "input3", Inside-1 in "input4", Inside-2 in "input5", leaving unknown boxes empty "").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "12x^3 - 15x^2 + 9x",
        "input2": "",
        "input3": "",
        "input4": "",
        "input5": ""
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
        if (jsonMap['input3'] != null) {
          _input3Ctrl.text = jsonMap['input3'].toString();
        }
        if (jsonMap['input4'] != null) {
          _input4Ctrl.text = jsonMap['input4'].toString();
        }
        if (jsonMap['input5'] != null) {
          _input5Ctrl.text = jsonMap['input5'].toString();
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
      if (_mode == 2) {
        _result = CommonFactorsLogic.solveQuantitativeFactorBox(
          outsideFactorStr: _input1Ctrl.text,
          topQ1Str: _input2Ctrl.text,
          topQ2Str: _input3Ctrl.text,
          insideT1Str: _input4Ctrl.text,
          insideT2Str: _input5Ctrl.text,
        );
      } else {
        _result = CommonFactorsLogic.solveFactorisationByCommonFactors(
          mode: _mode,
          expressionStr: _input1Ctrl.text,
          givenOutsideFactorStr: _input2Ctrl.text,
        );
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
    const presets = CommonFactorsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Examples 3–4, Ex 7.3, QR #1–9 & Rev Ex 7 Parts B & C):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.close_fullscreen,
                      size: 15,
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
        'label': 'Factorise Completely: Box & Quotient Methods (Ex 3, 4 & Ex 7.3)',
        'icon': Icons.close_fullscreen,
      },
      {
        'idx': 1,
        'label': 'Complete Bracket: E = F(   ) (Rev Ex 7 Part B #1–10)',
        'icon': Icons.code,
      },
      {
        'idx': 2,
        'label': 'Quantitative Reasoning Factorisation Boxes (Page 70 #1–9)',
        'icon': Icons.grid_view_outlined,
      },
      {
        'idx': 3,
        'label': 'Factorise & Verify by Reverse Expansion',
        'icon': Icons.verified_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Factorisation by Common Factors Mode:"),
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
          if (_mode == 0 || _mode == 3) ...[
            _buildSectionTitle(
                "2. Enter 2-Term or 3-Term Algebraic Expression to Factorise (Examples 3 & 4, Exercise 7.3 #1–20):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Algebraic Expression",
              hint:
              "e.g. 2ab + 5a, 6x^2 + 15x, 12x^3 - 9xy^2, 16xy + 14y^2, or 12x^3 - 15x^2 + 9x",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Complete Partially Factorised Expression (Revision Exercise 7 Part B #1–10, Page 71):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTextField(
                    _input1Ctrl,
                    "Given Expression (LHS)",
                    hint: "e.g. 24y - 36  or  4ab^2 + 8ab - 12a^2b",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "=",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _input2Ctrl,
                    "Outside Factor",
                    hint: "e.g. 12 or 4ab",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "(   )",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Quantitative Reasoning Factorisation Box Puzzles (Page 70 #1–9):"),
            const SizedBox(height: 6),
            const Text(
              "Enter the Known Boxes and Leave the Missing Boxes Blank (or '?'):",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 96),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Top Quotient 1 (Above Box 1)",
                    hint: "e.g. 5b, 2x, a^2, -x, or ?",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Top Quotient 2 (Above Box 2)",
                    hint: "e.g. -3c, 3b, 3a, or ?",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 88,
                  child: _buildTextField(
                    _input1Ctrl,
                    "Outside (F)",
                    hint: "e.g. -4x",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "Inside Box 1 (F × Top 1)",
                    hint: "e.g. 15b^2, 2ax^2z, or ?",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "Inside Box 2 (F × Top 2)",
                    hint: "e.g. -9bc, 12xy, or ?",
                  ),
                ),
              ],
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
                    "Snap a photo of any Factorisation by Common Factors or Quantitative Reasoning Box question from JSS 3 Chapter 7 (Pages 67–68 & 70–71)!",
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
              labelText: "Factorisation by Common Factors Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Factorise 12x^3 - 15x^2 + 9x, or factorise 12mn^2 - 16m^2n + 28m^2n^2...",
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
                "Extract & Factorise Expression",
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
              "Factorise Expression Step-by-Step",
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

  /// Builds the Interactive Visualisation Area where EVERY factorisation box, fraction quotient, and exponent is rendered via Math.tex!
  Widget _buildMathForkVisualisationArea(
      CommonFactorsCanvasData cd,
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
                  cd.factorBoxLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 15.5,
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

    final CommonFactorsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 385.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Factorisation Box & Quotient Visualizer:",
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
          'Factorisation by Common Factors',
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