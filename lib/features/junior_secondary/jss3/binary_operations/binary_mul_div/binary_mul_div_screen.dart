import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'binary_mul_div_logic.dart';
import 'binary_mul_div_models.dart';

class BinaryMulDivScreen extends StatefulWidget {
  const BinaryMulDivScreen({super.key});

  @override
  State<BinaryMulDivScreen> createState() => _BinaryMulDivScreenState();
}

class _BinaryMulDivScreenState extends State<BinaryMulDivScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Binary Long Multiplication (Example 3a–c, Ex 6.2 Part A #1–12 & Rev Ex 6 #11–12)
  // 1: Binary Division — Base-10 Bridge Method & Missing Factor y (Example 4a–c, Ex 6.2 Part B #1–8, Ex 6.3 #11, #15 & Rev Ex 6 #13–15)
  // 2: Combined Order-of-Operations (BODMAS), Brackets, Powers & Square Roots in Base 2 (Exercise 6.3 #3–10, #12–14)
  // 3: Quantitative Reasoning V-Tree Multiplication & Division Puzzles (Pages 62–63 #1–5)

  int _subMode = 0;
  // Mode 1: 0 = Divide A₂ ÷ B₂ (Example 4), 1 = Find Missing Factor y in B₂ × y = A₂ (Ex 6.3 #15)
  // Mode 2: 0 = (A + B) × C (#3–#5), 1 = C × (A − B) (#6–#7), 2 = (A + B) × (A − B) (#8), 3 = A² − B² (#9), 4 = A × B − C (#12), 5 = A³ + B⁴ & Identity (#13–#14)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  BinaryMulDivResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BinaryMulDivPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
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
              'Please enter a binary multiplication/division question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 6 Subtopic 2: Multiplication and Division in Base 2 (Pages 60–64, Examples 3–4, Exercise 6.2 Parts A & B, Exercise 6.3 #1–15, Quantitative Reasoning #1–5, and Revision Exercise 6 #11–15).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Binary Long Multiplication (Example 3a-c, Ex 6.2 Part A #1-12, Rev Ex 6 #11-12). Put 1st factor in "input1" and 2nd factor in "input2".
        1 for Binary Division (Example 4a-c, Ex 6.2 Part B #1-8, Ex 6.3 #11, Rev Ex 6 #13-15 -> subMode 0: put dividend in "input1" and divisor in "input2") OR finding missing factor y in B * y = A (Ex 6.3 #15 -> subMode 1: put product A in "input1" and known factor B in "input2").
        2 for Combined Order-of-Operations (Exercise 6.3 #3–10, #12–14):
          - subMode 0: (A + B) * C (#3, #4, #5: put A in "input1", B in "input2", C in "input3").
          - subMode 1: C * (A - B) (#6, #7: put A in "input1", B in "input2", C in "input3").
          - subMode 2: (A + B) * (A - B) (#8: put A in "input1", B in "input2").
          - subMode 3: A^2 - B^2 (#9: put A in "input1", B in "input2").
          - subMode 4: A * B - C (#12: put A in "input1", B in "input2", C in "input3").
          - subMode 5: A^3 + B^4 & Identity (10_2)^4 = (100_2)^2 (#13, #14: put A in "input1", B in "input2").
        3 for Quantitative Reasoning V-Tree Multiplication/Division (#1–5: put Top-Left in "input1", Top-Right in "input2", Bottom in "input3", leaving the missing one empty "").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "input1": "1 110",
        "input2": "101",
        "input3": ""
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
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 5);
        if (jsonMap['input1'] != null) {
          _input1Ctrl.text = jsonMap['input1'].toString();
        }
        if (jsonMap['input2'] != null) {
          _input2Ctrl.text = jsonMap['input2'].toString();
        }
        if (jsonMap['input3'] != null) {
          _input3Ctrl.text = jsonMap['input3'].toString();
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
        _result = BinaryMulDivLogic.solveBinaryMultiplication(
          factor1Str: _input1Ctrl.text,
          factor2Str: _input2Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = BinaryMulDivLogic.solveBinaryDivision(
          subMode: _subMode.clamp(0, 1),
          dividendStr: _input1Ctrl.text,
          divisorStr: _input2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = BinaryMulDivLogic.solveCombinedBinaryOperations(
          subMode: _subMode.clamp(0, 5),
          in1Str: _input1Ctrl.text,
          in2Str: _input2Ctrl.text,
          in3Str: _input3Ctrl.text,
        );
      } else {
        _result = BinaryMulDivLogic.solveQuantitativeVTree(
          topLeftStr: _input1Ctrl.text,
          topRightStr: _input2Ctrl.text,
          bottomStr: _input3Ctrl.text,
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
    const presets = BinaryMulDivLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Examples 3–4, Ex 6.2, Ex 6.3, QR #1–5 & Rev Ex 6):"),
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
        'label': 'Binary Long Multiplication (Example 3 & Ex 6.2 Part A)',
        'icon': Icons.close,
      },
      {
        'idx': 1,
        'label': 'Binary Division & Missing Factor y (Example 4 & Ex 6.2 Part B)',
        'icon': Icons.horizontal_split,
      },
      {
        'idx': 2,
        'label': 'Combined Brackets, Squares & Powers in Base 2 (Ex 6.3 #3–14)',
        'icon': Icons.functions,
      },
      {
        'idx': 3,
        'label': 'Quantitative Reasoning V-Diagrams (Pages 62–63 #1–5)',
        'icon': Icons.account_tree_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Binary Multiplication & Division Mode:"),
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
              onSelected: (_) => setState(() {
                _mode = idx;
                _subMode = 0;
              }),
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
                "2. Binary Long Multiplication (Example 3a–c, Ex 6.2 Part A #1–12 & Rev Ex 6 #11–12):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Binary Number (Multiplicand)",
                    hint: "e.g. 101, 1 110, 10 101, or 1 111",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Binary Number (Multiplier)",
                    hint: "e.g. 11, 101, or 111",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Binary Division — Base-10 Bridge Method (Example 4a–c, Ex 6.2 Part B & Ex 6.3 #11, #15):"),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _subMode.clamp(0, 1),
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Binary Division (A₂ ÷ B₂)\n(Example 4 & Ex 6.2 Part B #1–8)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color:
                        _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Find Unknown Factor y (B₂ × y = A₂)\n(Exercise 6.3 #15: 100₂ × y = 1 100₂)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
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
                    _subMode == 0
                        ? "Dividend (1st Binary Number)"
                        : "Product on RHS (A₂)",
                    hint: "e.g. 111 111, 11 000, 101 010, or 1 100",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    _subMode == 0
                        ? "Divisor (2nd Binary Number)"
                        : "Known Factor on LHS (B₂)",
                    hint: "e.g. 11, 100, 101, or 111",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Combined Brackets, Squares & Higher Powers in Base 2 (Exercise 6.3 #3–14, Page 62):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': '(A + B) × C  [Ex 6.3 #3–#5]'},
                {'idx': 1, 'lbl': 'C × (A − B)  [Ex 6.3 #6–#7]'},
                {'idx': 2, 'lbl': '(A + B) × (A − B)  [Ex 6.3 #8]'},
                {'idx': 3, 'lbl': 'A² − B²  [Ex 6.3 #9]'},
                {'idx': 4, 'lbl': 'A × B − C  [Ex 6.3 #12]'},
                {'idx': 5, 'lbl': 'A³ + B⁴ & Identity  [Ex 6.3 #13–#14]'},
              ].map((op) {
                final int idx = op['idx'] as int;
                final bool isSel = _subMode == idx;
                return ChoiceChip(
                  label: Text(
                    op['lbl'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSel ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color:
                    isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _subMode = idx),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Binary Number (A)",
                    hint: "e.g. 1 001, 11 101, 111, 1 011, or 101",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Binary Number (B)",
                    hint: "e.g. 101, 1 011, or 11",
                  ),
                ),
              ],
            ),
            if (_subMode == 0 || _subMode == 1 || _subMode == 4) ...[
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                _subMode == 4
                    ? "3rd Binary Number Subtracted (− C)"
                    : "Outside Multiplier Binary Number (C)",
                hint: "e.g. 11, 101, 111, 110, or 100",
              ),
            ],
          ] else ...[
            _buildSectionTitle(
                "2. Quantitative Reasoning V-Tree Diagrams (Pages 62–63 #1–5: Top-Left × Top-Right = Bottom):"),
            const SizedBox(height: 8),
            const Text(
              "Enter the 2 Known Binary Boxes and Leave the 1 Missing Box Blank (or '?'):",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Top-Left Box",
                    hint: "e.g. 101, 111, 1 011, or ?",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Top-Right Box",
                    hint: "e.g. 110, 1 001, 101, or ?",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Bottom Box (Product of Top-Left × Top-Right)",
              hint: "e.g. 111 111, 1 100, 1 001 011, or Leave Blank (?)",
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
                    "Snap a photo of any Binary Multiplication, Division, Combined BODMAS, or Quantitative Reasoning V-Diagram question from JSS 3 Chapter 6 (Pages 60–64)!",
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
              labelText: "Binary Multiplication / Division Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Multiply 1 110_2 by 101_2, divide 111 111_2 by 11_2, or evaluate (1 011_2)^2 - (101_2)^2...",
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
                "Extract & Solve Binary Operation",
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
              "Solve Binary Multiplication / Division",
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

  /// Builds the Interactive Visualisation Area where EVERY long-multiplication array, division fraction, and remainder table is rendered via Math.tex!
  Widget _buildMathForkVisualisationArea(
      BinaryMulDivCanvasData cd,
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

    final BinaryMulDivCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 415.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Binary Multiplication & Division Visualizer:",
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
          'Multiplication & Division in Base 2',
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