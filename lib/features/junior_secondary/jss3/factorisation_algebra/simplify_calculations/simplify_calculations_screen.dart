import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'simplify_calculations_logic.dart';
import 'simplify_calculations_models.dart';

class SimplifyCalculationsScreen extends StatefulWidget {
  const SimplifyCalculationsScreen({super.key});

  @override
  State<SimplifyCalculationsScreen> createState() =>
      _SimplifyCalculationsScreenState();
}

class _SimplifyCalculationsScreenState
    extends State<SimplifyCalculationsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Standard Two-Product k × a ± k × b = k(a ± b) (Example 5a–c & Ex 7.4 #1, #3–15, #17–20)
  // 1: Implicit × 1 Term: k × a ± k = k(a ± 1) (Exercise 7.4 #2: 199 × 19 + 19)
  // 2: Square Term: k × a ± k² = k(a ± k) (Exercise 7.4 #16: 39 × 139 − 39²)
  // 3: Quantitative Reasoning Roof / Triangle Puzzles (Page 70 #10–15: Peak × (Left + Right) = Bottom)

  int _subMode = 0; // 0: Addition (+), 1: Subtraction (−)

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

  SimplifyCalculationsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(SimplifyCalculationsPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
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
              'Please enter a calculation question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 7 Subtopic 4: Simplifying Calculations by Factorisation (Pages 68–70, Example 5a–c, Exercise 7.4 #1–20, and Quantitative Reasoning Roof Puzzles #10–15).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Standard two-product expressions k * a + k * b (subMode 0) or k * a - k * b (subMode 1). Put common factor k in "input1", first number a in "input2", second number b in "input3".
        1 for Implicit * 1 expressions like "199 * 19 + 19" (Ex 7.4 #2: put common factor k="19" in "input1" and a="199" in "input2").
        2 for Square-term expressions like "39 * 139 - 39^2" (Ex 7.4 #16: put common factor k="39" in "input1" and a="139" in "input2", subMode 1).
        3 for Quantitative Reasoning Roof/Triangle Puzzles (Page 70 #10–15: put Peak in "input1", Left Wing in "input2", Right Wing in "input3", Bottom Base in "input4", leaving the unknown position empty "").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 1,
        "input1": "5/6",
        "input2": "230",
        "input3": "14",
        "input4": ""
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
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
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
      if (_mode == 3) {
        _result = SimplifyCalculationsLogic.solveQuantitativeRoofPuzzle(
          peakStr: _input1Ctrl.text,
          leftWingStr: _input2Ctrl.text,
          rightWingStr: _input3Ctrl.text,
          bottomBaseStr: _input4Ctrl.text,
        );
      } else {
        _result = SimplifyCalculationsLogic.solveFactorisationShortcut(
          mode: _mode,
          subMode: _subMode,
          commonKStr: _input1Ctrl.text,
          termAStr: _input2Ctrl.text,
          termBStr: _input3Ctrl.text,
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
    const presets = SimplifyCalculationsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Example 5a–c, Ex 7.4 #1–20 & QR #10–15):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.bolt,
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
        'label': 'Two Products: k×a ± k×b = k(a ± b) (Ex 5a–c & Ex 7.4 #1–20)',
        'icon': Icons.bolt,
      },
      {
        'idx': 1,
        'label': 'Implicit × 1 Term: k×a ± k = k(a ± 1) (Ex 7.4 #2)',
        'icon': Icons.looks_one_outlined,
      },
      {
        'idx': 2,
        'label': 'Square Term: k×a ± k² = k(a ± k) (Ex 7.4 #16)',
        'icon': Icons.superscript_outlined,
      },
      {
        'idx': 3,
        'label': 'Quantitative Reasoning Roof Puzzles (Page 70 #10–15)',
        'icon': Icons.change_history,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Simplifying Calculations by Factorisation Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            final IconData iconData =
            idx == 2 ? Icons.superscript : (m['icon'] as IconData);
            return ChoiceChip(
              avatar: Icon(
                iconData,
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
          if (_mode <= 2) ...[
            _buildSectionTitle(
                "2. Select Operation Sign Between Products & Enter Numbers / Fractions:"),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _subMode,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "+ Addition (k × a + k × b)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                        _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "− Subtraction (k × a − k × b)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                        _subMode == 1 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (int? v) {
                  if (v != null) setState(() => _subMode = v);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Common Factor (k)",
                    hint: "e.g. 35, 107, 5/6, 3 1/4, 1 6/11, or 39",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "1st Multiplied Number (a)",
                    hint: "e.g. 38, 118, 230, 100, 999/17, or 139",
                  ),
                ),
              ],
            ),
            if (_mode == 0) ...[
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "2nd Multiplied Number (b)",
                hint: "e.g. 62, 18, 14, 12, or 211/17",
              ),
            ],
          ] else ...[
            _buildSectionTitle(
                "2. Quantitative Reasoning Roof / Triangle Puzzles (Page 70 #10–15: Peak × (Left + Right) = Bottom):"),
            const SizedBox(height: 6),
            const Text(
              "Enter the 3 Known Positions and Leave the 1 Missing Position Blank (or '?'):",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Left Wing",
                    hint: "e.g. 105, 149, 145, 116, or ?",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Top Peak (Multiplier)",
                    hint: "e.g. 100, 49, 25, or ?",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Right Wing",
                    hint: "e.g. 45, -49, 44, or ?",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input4Ctrl,
              "Bottom Base (Peak × (Left Wing + Right Wing))",
              hint: "e.g. 625, 520, or Leave Blank (?)",
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
                    "Snap a photo of any Simplifying Calculations by Factorisation or Quantitative Reasoning Roof question from JSS 3 Chapter 7 (Pages 68–70)!",
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
              labelText: "Simplify by Factorisation Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Simplify by factorising: 5/6 × 230 − 5/6 × 14, or 1 6/11 × 999/17 + 1 6/11 × 211/17...",
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
                "Extract & Simplify by Factorisation",
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
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: const Text(
              "Simplify by Factorisation Step-by-Step",
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

  /// Builds the Interactive Visualisation Area where EVERY fraction and Quantitative Reasoning Roof diagram is rendered via Math.tex!
  Widget _buildMathForkVisualisationArea(
      SimplifyCalculationsCanvasData cd,
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
          if (cd.visualType == 1)
          // Mode 3: Authentic Page 70 Quantitative Reasoning Roof / Triangle Diagram with Math.tex Labels!
            SizedBox(
              width: 340,
              height: 135,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _QrRoofDiagramPainter(),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, -0.82),
                    child: _buildBadgeMath(
                        "\\text{Peak: } ${cd.peakLaTeX}", Colors.deepPurple),
                  ),
                  Align(
                    alignment: const Alignment(-0.85, 0.05),
                    child: _buildBadgeMath(
                        "\\text{Left: } ${cd.leftWingLaTeX}",
                        Colors.orange.shade800),
                  ),
                  Align(
                    alignment: const Alignment(0.85, 0.05),
                    child: _buildBadgeMath(
                        "\\text{Right: } ${cd.rightWingLaTeX}",
                        Colors.orange.shade800),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.85),
                    child: _buildBadgeMath(
                        "\\text{Base: } ${cd.bottomBaseLaTeX}",
                        Colors.green.shade800),
                  ),
                ],
              ),
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
                    fontSize: 15.0,
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

  Widget _buildBadgeMath(String latex, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Math.tex(
        latex,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
        ),
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

    final SimplifyCalculationsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 365.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Factorisation Shortcut & QR Roof Visualizer:",
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
          'Simplifying Calculations by Factorisation',
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

/// CustomPainter for the Page 70 Quantitative Reasoning Roof/Triangle Diagram (#10–15)
class _QrRoofDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final Offset peak = Offset(cx, 28);
    final Offset leftCorner = Offset(cx - 88, 92);
    final Offset rightCorner = Offset(cx + 88, 92);

    final Path roofTri = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(leftCorner.dx, leftCorner.dy)
      ..lineTo(rightCorner.dx, rightCorner.dy)
      ..close();

    canvas.drawPath(roofTri, Paint()..color = Colors.deepPurple.shade50);
    canvas.drawPath(
      roofTri,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // Extended roof eaves (matching Page 70 diagram!)
    canvas.drawLine(
      peak,
      Offset(leftCorner.dx - 16, leftCorner.dy + 12),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      peak,
      Offset(rightCorner.dx + 16, rightCorner.dy + 12),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}