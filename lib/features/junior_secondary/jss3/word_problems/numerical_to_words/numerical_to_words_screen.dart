import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'numerical_to_words_logic.dart';
import 'numerical_to_words_models.dart';

class NumericalToWordsScreen extends StatefulWidget {
  const NumericalToWordsScreen({super.key});

  @override
  State<NumericalToWordsScreen> createState() => _NumericalToWordsScreenState();
}

class _NumericalToWordsScreenState extends State<NumericalToWordsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Universal Expression-to-Words Translator (Free-Form Input for Ex 13a–e & Exercise #1–20)
  // 1: Basic Sum, Positive/Negative Difference & Product Builder (Ex 13a–d & #1, #2, #8, #9, #14)
  // 2: Bracketed & Combined Product/Sum/Difference Builder (#5, #6, #7, #13, #15)
  // 3: Fractional Division Expressions Numerator / Denominator (Ex 13e & #3, #4, #10–12, #16–20)

  int _subMode = 0;
  // Mode 1: 0 = a + b (Sum), 1 = a − b (Positive/Negative Difference), 2 = a × b (Product), 3 = a − b + c (#2)
  // Mode 2: 0 = k(a + b) [#6], 1 = a + (b × c) [#5], 2 = a × b + c [#7], 3 = (a + b) − c [#13], 4 = k₁ × k₂(a + b) [#15]
  // Mode 3: 0 = Numerator / Denominator [Ex 13e & #4, #10–12, #16–20], 1 = Whole + (Numerator / Denominator) [#3]

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _exprCtrl = TextEditingController();
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  NumericalToWordsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _exprCtrl.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(NumericalToWordsPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _exprCtrl.text = p.exprInput;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
    });
    _solveManual();
  }

  void _insertSymbolIntoExpr(String sym) {
    final String current = _exprCtrl.text;
    final TextSelection sel = _exprCtrl.selection;
    if (sel.isValid && sel.start >= 0 && sel.end <= current.length) {
      final String updated =
      current.replaceRange(sel.start, sel.end, sym);
      _exprCtrl.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: sel.start + sym.length),
      );
    } else {
      _exprCtrl.text = "$current$sym";
    }
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
              'Please enter a numerical expression or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Changing Numerical Expressions into Words (Pages 28–29, Example 13a-e & Exercise #1-20).
      Extract the numerical expression from the user prompt or textbook image into standard one-line mathematical notation using +, -, *, /, and parentheses ( ) around any multi-term numerator or denominator of a fraction.
      Examples of standard notation:
      - "42 + 68"
      - "67 - 8"
      - "2 - 5"
      - "(53 * 79) / 22"
      - "3 + 2 / (2 + 1)"
      - "3(14.1 + 0.9)"
      - "33 - (-104)"
      - "6(18 + 8) / 16"
      - "8 * 5(12 + 10)"
      - "((18 + 11) - 6) / 5"
      - "(32 * 6) / (29 - 14)"
      - "(3 * 15 - 9) / 6"

      Return ONLY valid JSON:
      {
        "mode": 0,
        "exprInput": "(53 * 79) / 22"
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
        _mode = 0;
        if (jsonMap['exprInput'] != null) {
          _exprCtrl.text = jsonMap['exprInput'].toString();
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
        _result = NumericalToWordsLogic.solveNumericalExpressionToWords(
          mode: 0,
          rawExpression: _exprCtrl.text,
        );
      } else if (_mode == 1) {
        _result = NumericalToWordsLogic.solveStructuredMode1(
          subMode: _subMode.clamp(0, 3),
          aStr: _input1Ctrl.text,
          bStr: _input2Ctrl.text,
          cStr: _input3Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = NumericalToWordsLogic.solveStructuredMode2(
          subMode: _subMode.clamp(0, 4),
          in1Str: _input1Ctrl.text,
          in2Str: _input2Ctrl.text,
          in3Str: _input3Ctrl.text,
        );
      } else {
        _result = NumericalToWordsLogic.solveStructuredMode3(
          subMode: _subMode.clamp(0, 1),
          numeratorStr: _input1Ctrl.text,
          denominatorStr: _input2Ctrl.text,
          leadingWholeStr: _input3Ctrl.text,
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
    const presets = NumericalToWordsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Example 13a–e & All 20 Questions #1–20):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.translate,
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
        'label': 'Universal Expression-to-Words Translator (Any Expression!)',
        'icon': Icons.translate,
      },
      {
        'idx': 1,
        'label': 'Basic Sum, Pos/Neg Difference & Product (Ex 13a–d & #1, #8, #9)',
        'icon': Icons.compare_arrows,
      },
      {
        'idx': 2,
        'label': 'Bracketed & Combined Expressions (#5, #6, #7, #13, #15)',
        'icon': Icons.code,
      },
      {
        'idx': 3,
        'label': 'Fractional Division Numerator / Denominator (Ex 13e & #3–4, #10–20)',
        'icon': Icons.horizontal_split,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Numerical Expression to Words Builder Mode:"),
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
                "2. Enter Any Numerical Expression to Translate into Words (Example 13 & Exercise #1–20):"),
            const SizedBox(height: 10),
            _buildTextField(
              _exprCtrl,
              "Numerical Expression (Use +, -, *, / and Brackets)",
              hint:
              "e.g. 67 - 8, 2 - 5, 3(14.1 + 0.9), (53 * 79) / 22, or (32 * 6) / (29 - 14)",
            ),
            const SizedBox(height: 10),
            const Text(
              "Quick Symbol Pad (Tap to Insert):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                {'lbl': '+ (Sum)', 'sym': ' + '},
                {'lbl': '− (Diff)', 'sym': ' - '},
                {'lbl': '× (Product)', 'sym': ' * '},
                {'lbl': '÷ / Fraction', 'sym': ' / '},
                {'lbl': '(  Open', 'sym': '('},
                {'lbl': ')  Close', 'sym': ')'},
              ].map((btn) {
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    btn['lbl']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () =>
                      setState(() => _insertSymbolIntoExpr(btn['sym']!)),
                );
              }).toList(),
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Basic Sum, Positive/Negative Difference & Product Builder (Page 28 Rules):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'a + b  (The sum of a and b)'},
                {
                  'idx': 1,
                  'lbl': 'a − b  (Positive / Negative difference)',
                },
                {'idx': 2, 'lbl': 'a × b  (The product of a and b)'},
                {'idx': 3, 'lbl': 'a − b + c  (Three-term chain — Ex #2)'},
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
                    "First Number (a)",
                    hint: "e.g. 42, 67, 2, 33, or -12",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Second Number (b)",
                    hint: "e.g. 68, 8, 5, -104, or -5",
                  ),
                ),
              ],
            ),
            if (_subMode == 3) ...[
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Third Number Added (+ c)",
                hint: "e.g. 2 (as in Ex #2: 9 − 4 + 2)",
              ),
            ],
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Bracketed & Combined Product / Sum / Difference Builder (Exercise #5, #6, #7, #13, #15):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'k(a + b)  [Ex #6: 3(14.1 + 0.9)]'},
                {'idx': 1, 'lbl': 'a + (b × c)  [Ex #5: 9 + (3 × 2)]'},
                {'idx': 2, 'lbl': 'a × b + c  [Ex #7: 49 × 21 + 21]'},
                {'idx': 3, 'lbl': '(a + b) − c  [Ex #13: (15 + 11) − 10]'},
                {'idx': 4, 'lbl': '8 × k(a + b)  [Ex #15: 8 × 5(12 + 10)]'},
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
                    _subMode == 0 || _subMode == 4
                        ? "Outside Multiplier(s)"
                        : "First Number (a)",
                    hint: _subMode == 0
                        ? "e.g. 3"
                        : (_subMode == 4 ? "e.g. 8 * 5" : "e.g. 9, 49, or 15"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Second Number (b)",
                    hint: "e.g. 14.1, 3, 21, 11, or 12",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Third Number (c)",
              hint: "e.g. 0.9, 2, 21, 10, or 10",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Fractional Division Expressions (Numerator ÷ Denominator — Ex 13e & #3, #4, #10–12, #16–20):"),
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
                      "Single Fraction Bar\nNumerator / Denominator",
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
                      "Whole + Fraction (Ex #3)\nWhole + (Numerator / Denominator)",
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
            if (_subMode == 1) ...[
              _buildTextField(
                _input3Ctrl,
                "Leading Whole Number Added Before the Fraction",
                hint: "e.g. 3  (as in Ex #3: 3 + 2 / (2 + 1))",
              ),
              const SizedBox(height: 10),
            ],
            _buildTextField(
              _input1Ctrl,
              "Top Expression (Numerator)",
              hint:
              "e.g. 53 * 79, 9, -15 * 7, 6(18 + 8), (18 + 11) - 6, 32 * 6, or 3 * 15 - 9",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input2Ctrl,
              "Bottom Expression (Denominator)",
              hint:
              "e.g. 22, 4 * 2, 20, 3 * -4, 16, 5 * 8, 5, 29 - 14, 14 * 12, or 6",
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
                    "Snap a photo of any numerical expression from JSS 3 Chapter 2 (Example 13 or Exercise #1–20 on Pages 28–29), and the AI will translate it into words and evaluate it step-by-step!",
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
              labelText: "Numerical Expression to Translate into Words",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Translate (53 × 79) / 22 into words, or write 6(18 + 8) / 16 in words...",
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
                "Extract & Translate Expression into Words",
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
            icon: const Icon(Icons.translate, color: Colors.white),
            label: const Text(
              "Translate into Words & Evaluate Step-by-Step",
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

    final NumericalToWordsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 700.0);
    const double canvasHeight = 355.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Expression-to-Words Syntax Tree Visualizer:",
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
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: NumericalToWordsPainter(data: cd),
                ),
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
          children: _result!.finalAnswers.entries.map((entry) {
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
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text(
          "3. Mathematical & Word-Translation Workings (Line-by-Line):",
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
          'Numerical Expressions into Words',
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

class NumericalToWordsPainter extends CustomPainter {
  final NumericalToWordsCanvasData data;

  NumericalToWordsPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Top Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      18,
      fontSize: 13.0,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.subBadge,
      cx,
      36,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );

    const double topY = 66.0;
    const double cardW = 278.0;
    const double cardH = 68.0;
    const double gapX = 48.0;

    final Rect leftCard =
    Rect.fromLTWH(cx - cardW - gapX / 2, topY, cardW, cardH);
    final Rect rightCard = Rect.fromLTWH(cx + gapX / 2, topY, cardW, cardH);

    final Offset opHub = Offset(cx, 178.0);
    final Offset primaryBannerCenter = Offset(cx, 240.0);
    final Offset altBannerCenter = Offset(cx, 286.0);

    // Connecting lines from Left & Right sub-expression cards to Operation Hub
    final Paint linePaint = Paint()
      ..color = Colors.deepPurple.shade300
      ..strokeWidth = 2.4;
    canvas.drawLine(
      Offset(leftCard.center.dx, leftCard.bottom),
      Offset(opHub.dx - 16, opHub.dy - 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(rightCard.center.dx, rightCard.bottom),
      Offset(opHub.dx + 16, opHub.dy - 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(opHub.dx, opHub.dy + 18),
      Offset(primaryBannerCenter.dx, primaryBannerCenter.dy - 20),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.6,
    );

    // Draw Left Sub-Expression Node Card
    _drawNodeCard(
      canvas,
      rect: leftCard,
      title: data.leftNodeTitle,
      mathStr: data.leftNodeMath,
      wordsStr: "\"${data.leftNodeWords}\"",
      bgColor: Colors.deepPurple.shade50,
      borderColor: Colors.deepPurple.shade400,
    );

    // Draw Right Sub-Expression Node Card
    _drawNodeCard(
      canvas,
      rect: rightCard,
      title: data.rightNodeTitle,
      mathStr: data.rightNodeMath,
      wordsStr: "\"${data.rightNodeWords}\"",
      bgColor: Colors.amber.shade50,
      borderColor: Colors.orange.shade800,
    );

    // Draw Connecting Operation Hub Circle
    canvas.drawCircle(
      opHub,
      20.0,
      Paint()..color = Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.bridgeSymbol,
      opHub.dx,
      opHub.dy,
      fontSize: 18.0,
      isBold: true,
      color: Colors.white,
    );

    // Draw Primary Textbook Word Translation Box
    final Rect primaryRect = Rect.fromCenter(
      center: primaryBannerCenter,
      width: 604.0,
      height: 38.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(primaryRect, const Radius.circular(9)),
      Paint()..color = Colors.green.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(primaryRect, const Radius.circular(9)),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.primaryWordsBanner,
      cx,
      primaryBannerCenter.dy,
      fontSize: 12.0,
      isBold: true,
      color: Colors.green.shade900,
    );

    // Draw Alternative Accepted Phrasing Box
    final Rect altRect = Rect.fromCenter(
      center: altBannerCenter,
      width: 604.0,
      height: 32.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(altRect, const Radius.circular(8)),
      Paint()..color = Colors.deepPurple.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(altRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.deepPurple.shade300
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.altWordsBanner,
      cx,
      altBannerCenter.dy,
      fontSize: 11.0,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );

    // Bottom Evaluated Numerical Value Banner
    if (data.evaluatedValueBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.evaluatedValueBanner,
        cx,
        size.height - 20.0,
        Colors.green.shade800,
      );
    }
  }

  void _drawNodeCard(
      Canvas canvas, {
        required Rect rect,
        required String title,
        required String mathStr,
        required String wordsStr,
        required Color bgColor,
        required Color borderColor,
      }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = bgColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = borderColor
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      title,
      rect.center.dx,
      rect.top + 14,
      fontSize: 11.0,
      isBold: true,
      color: borderColor,
    );
    _drawText(
      canvas,
      mathStr,
      rect.center.dx,
      rect.top + 33,
      fontSize: 13.0,
      isBold: true,
      color: Colors.black87,
    );
    _drawText(
      canvas,
      wordsStr.length > 42 ? "${wordsStr.substring(0, 40)}...\"" : wordsStr,
      rect.center.dx,
      rect.top + 52,
      fontSize: 10.5,
      isBold: true,
      color: Colors.grey.shade800,
    );
  }

  void _drawBadge(
      Canvas canvas, String text, double x, double y, Color bgColor) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + 14,
      height: tp.height + 7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()..color = bgColor,
    );
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawText(
      Canvas canvas,
      String text,
      double x,
      double y, {
        double fontSize = 12,
        bool isBold = false,
        Color color = Colors.black87,
      }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant NumericalToWordsPainter oldDelegate) =>
      oldDelegate.data != data;
}