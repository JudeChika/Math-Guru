import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'fraction_word_problems_logic.dart';
import 'fraction_word_problems_models.dart';

class FractionWordProblemsScreen extends StatefulWidget {
  const FractionWordProblemsScreen({super.key});

  @override
  State<FractionWordProblemsScreen> createState() =>
      _FractionWordProblemsScreenState();
}

class _FractionWordProblemsScreenState
    extends State<FractionWordProblemsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Fractions of an Unknown Number x (Single, Sum/Diff of Two Fractions, Two-Sided)
  // 1: Algebraic Numerators / Linear Expressions Divided by a Denominator
  // 2: Unknown in the Denominator & Finding an Original Fraction (N / D)
  // 3: Real-Life Fractional Shares of a Whole & "Of the Remainder" Word Problems

  int _subMode = 0;
  // Mode 0: 0 = (p/q)x + b = c, 1 = (p1/q1)x + (p2/q2)x = c, 2 = (p1/q1)x - (p2/q2)x = c, 3 = (p1/q1)x + b = (p2/q2)x + d
  // Mode 1: 0 = (ax + b)/d = c, 1 = (x + b1)/d1 = (x + b2)/d2, 2 = (x + b1)/d1 + (x + b2)/d2 = 5
  // Mode 2: 0 = a / (x + b) = c, 1 = Original Fraction x / (x + k) modified by m gives p/q
  // Mode 3: 0 = Direct Shares from Original Whole, 1 = 2nd Share is "OF THE REMAINDER"

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

  FractionWordProblemResult? _result;
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

  void _applyPreset(FractionWordProblemPreset p) {
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
              'Please enter a fraction word problem or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Word Problems Involving Fractions (Pages 25–28, Examples 8–12 & Exercise 2.4).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Fractions of an Unknown Number x:
          - subMode 0: Single fraction of x plus/minus constant b equals c -> (p/q)x + b = c (input1=p/q, input2=b with sign, input3=c).
          - subMode 1: Sum of two fractions of x equals c -> (p1/q1)x + (p2/q2)x = c (input1=p1/q1, input2=p2/q2, input3=c).
          - subMode 2: Difference between two fractions of x equals c -> (p1/q1)x - (p2/q2)x = c (input1=p1/q1, input2=p2/q2, input3=c).
          - subMode 3: Two-sided fractional equation -> (p1/q1)x + b = (p2/q2)x + d (input1=p1/q1, input2=b, input3=p2/q2, input4=d).
        1 for Algebraic Numerators / Linear Expressions Divided by a Denominator:
          - subMode 0: (a*x + b) / d = c (input1=a, input2=b, input3=d, input4=c).
          - subMode 1: Equating two algebraic fractions (x + b1)/d1 = (x + b2)/d2 (input1=b1, input2=d1, input3=b2, input4=d2).
          - subMode 2: Sum of two algebraic fractions (x + b1)/d1 + (x + b2)/d2 = 5 (input1=b1, input2=d1, input3=b2, input4=d2).
        2 for Unknown in the Denominator or Finding an Original Fraction:
          - subMode 0: a / (x + b) = c (input1=a, input2=b, input3=c).
          - subMode 1: Denominator of a fraction is k more than numerator; adding/subtracting m to both gives p/q (input1=k, input2=m, input3=p/q).
        3 for Real-Life Fractional Shares of a Whole & "Of the Remainder" Word Problems:
          - subMode 0: Direct fractional shares from original whole (spent f1 on A and f2 on B, leaving R -> input1=f1, input2=f2, input3=R).
          - subMode 1: Successive shares where 2nd share is OF THE REMAINDER (spent f1 on A and f2 of the remainder on B, leaving R -> input1=f1, input2=f2, input3=R).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "input1": "3/4",
        "input2": "-4",
        "input3": "11",
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
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 3);
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
      if (_mode == 0) {
        _result = FractionWordProblemsLogic.solveFractionsOfUnknownNumber(
          subMode: _subMode.clamp(0, 3),
          input1Str: _input1Ctrl.text,
          input2Str: _input2Ctrl.text,
          input3Str: _input3Ctrl.text,
          input4Str: _input4Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = FractionWordProblemsLogic.solveAlgebraicNumeratorProblem(
          subMode: _subMode.clamp(0, 2),
          input1Str: _input1Ctrl.text,
          input2Str: _input2Ctrl.text,
          input3Str: _input3Ctrl.text,
          input4Str: _input4Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = FractionWordProblemsLogic.solveDenominatorOrOriginalFraction(
          subMode: _subMode.clamp(0, 1),
          input1Str: _input1Ctrl.text,
          input2Str: _input2Ctrl.text,
          input3Str: _input3Ctrl.text,
        );
      } else {
        _result = FractionWordProblemsLogic.solveRealLifeSharesAndRemainder(
          subMode: _subMode.clamp(0, 1),
          frac1Str: _input1Ctrl.text,
          frac2Str: _input2Ctrl.text,
          amountLeftStr: _input3Ctrl.text,
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
    const presets = FractionWordProblemsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook & BECE Presets (Examples 8–12 & Exercise 2.4):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.pie_chart_outline,
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
        'label': 'Fractions of an Unknown Number x: (p/q)x ± (r/s)x = c',
        'icon': Icons.functions,
      },
      {
        'idx': 1,
        'label': 'Algebraic Numerators: (ax ± b) / d = c & Two-Term Fractions',
        'icon': Icons.horizontal_split,
      },
      {
        'idx': 2,
        'label': 'Unknown in Denominator & Find Original Fraction (N / D)',
        'icon': Icons.swap_vert,
      },
      {
        'idx': 3,
        'label': 'Real-Life Shares & "Of the Remainder" Word Problems',
        'icon': Icons.pie_chart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Word Problems Involving Fractions Mode:"),
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
                "2. Fractions of an Unknown Number x (Cleared Using LCM of Denominators):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': '(p/q)x + b = c [Single Fraction ± Const]'},
                {'idx': 1, 'lbl': '(p₁/q₁)x + (p₂/q₂)x = c [Sum of 2 Fractions]'},
                {'idx': 2, 'lbl': '(p₁/q₁)x − (p₂/q₂)x = c [Diff of 2 Fractions]'},
                {'idx': 3, 'lbl': '(p₁/q₁)x + b = (p₂/q₂)x + d [Two-Sided]'},
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
            if (_subMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Fraction of x (p/q)",
                      hint: "e.g. 3/4 or 2/3",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Added / Subtracted Constant (b)",
                      hint: "e.g. -4 or 7",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Given Result (c)",
                hint: "e.g. 11 or 19",
              ),
            ] else if (_subMode == 1 || _subMode == 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "1st Fraction of x (p₁/q₁)",
                      hint: "e.g. 1/2 or 3/4",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "2nd Fraction of x (p₂/q₂)",
                      hint: "e.g. 1/3 or 2/5",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Given ${(_subMode == 1) ? 'Sum' : 'Difference'} (c)",
                hint: "e.g. 15 or 14",
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "LHS Fraction of x (p₁/q₁)",
                      hint: "e.g. 2/3",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "LHS Constant (b)",
                      hint: "e.g. -3",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input3Ctrl,
                      "RHS Fraction of x (p₂/q₂)",
                      hint: "e.g. 1/2",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      "RHS Constant (d)",
                      hint: "e.g. 2",
                    ),
                  ),
                ],
              ),
            ],
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Algebraic Numerators / Linear Expressions Divided by a Denominator:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': '(ax + b) / d = c [Single Algebraic Fraction]'},
                {
                  'idx': 1,
                  'lbl': '(x + b₁) / d₁ = (x + b₂) / d₂ [Equate Two]',
                },
                {
                  'idx': 2,
                  'lbl': '(x + b₁) / d₁ + (x + b₂) / d₂ = 5 [Sum of Two]',
                },
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
            if (_subMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Coeff of x in Numerator (a)",
                      hint: "e.g. 1 or 2",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Constant in Numerator (b)",
                      hint: "e.g. 5 or -4",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input3Ctrl,
                      "Denominator / Divisor (d)",
                      hint: "e.g. 4 or 3",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      "Given Result (c)",
                      hint: "e.g. 7 or 6",
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "1st Numerator Constant (b₁)",
                      hint: "e.g. 7 or 2",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "1st Denominator (d₁)",
                      hint: "e.g. 4 or 3",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input3Ctrl,
                      "2nd Numerator Constant (b₂)",
                      hint: "e.g. 3 or -1",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      "2nd Denominator (d₂)",
                      hint: "e.g. 3 or 4",
                    ),
                  ),
                ],
              ),
            ],
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Unknown in the Denominator & Finding an Original Fraction (N / D):"),
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
                      "Unknown in Denominator\na / (x + b) = c",
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
                      "Find Original Fraction\nx / (x + k)  ➔  (x + m)/(x + k + m) = p/q",
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
            if (_subMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Numerator (a)",
                      hint: "e.g. 24 or 15",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Added to x in Denominator (b)",
                      hint: "e.g. 0 or 2",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Given Result (c)",
                hint: "e.g. 1 1/2 or 3/5",
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Denom Exceeds Num By (k)",
                      hint: "e.g. 5 or 3",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Added/Subtracted to Both (m)",
                      hint: "e.g. 2 or -1",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Resulting Fraction (p/q)",
                hint: "e.g. 1/2",
              ),
            ],
          ] else ...[
            _buildSectionTitle(
                "2. Real-Life Fractional Shares of a Whole & 'Of the Remainder' Problems:"),
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
                      "Direct Shares of Whole\n(Spent f₁ and f₂ of total; R left)",
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
                      "2nd Share 'OF THE REMAINDER'\n(f₁ of total, then f₂ of remainder; R left)",
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
                    "1st Fractional Share (f₁)",
                    hint: "e.g. 1/4, 1/3, or 2/5",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    _subMode == 0
                        ? "2nd Fractional Share (f₂)"
                        : "2nd Share OF REMAINDER (f₂)",
                    hint: "e.g. 1/3, 2/5, or 1/2",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Remaining Amount / Pages / Distance Left (R)",
              hint: "e.g. 500, 18000, or 45",
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
                    "Snap a photo of any word problem involving fractions from JSS 3 Chapter 2 (Exercise 2.4 or BECE past questions), and the AI will solve it step-by-step!",
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
              labelText: "Word Problem Involving Fractions",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. When 4 is subtracted from three-quarters of a number, the result is 11. Or: A man spent 1/3 of his salary on rent and 2/5 of the remainder on food...",
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
                "Extract & Solve Fraction Word Problem",
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
              "Solve Fraction Word Problem Step-by-Step",
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

    final FractionWordProblemsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 335.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cd.visualType == 0
                    ? "1. Interactive LCM Denominator-Clearing Pipeline Visualizer:"
                    : "1. Interactive Proportional Whole-Bar Partition Visualizer:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
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
                  painter: FractionWordProblemsPainter(data: cd),
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
                      fontSize: 17.5,
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
          'Word Problems Involving Fractions',
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

class FractionWordProblemsPainter extends CustomPainter {
  final FractionWordProblemsCanvasData data;

  FractionWordProblemsPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Top Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      18,
      fontSize: 13.5,
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

    if (data.visualType == 0) {
      _paintLcmClearingPipeline(canvas, size);
    } else {
      _paintProportionalWholeBar(canvas, size);
    }

    // 3. Bottom Summary Banner
    if (data.bottomSummaryBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.bottomSummaryBanner,
        cx,
        size.height - 20.0,
        Colors.green.shade800,
      );
    }
  }

  void _paintLcmClearingPipeline(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double boxW = 460.0;
    const double boxH = 42.0;

    final Offset topCenter = Offset(cx, 82.0);
    final Offset midBridge = Offset(cx, 138.0);
    final Offset clearedCenter = Offset(cx, 194.0);
    final Offset finalCenter = Offset(cx, 254.0);

    // Connecting vertical arrows
    final Paint arrowPaint = Paint()
      ..color = Colors.deepPurple.shade400
      ..strokeWidth = 2.4;
    canvas.drawLine(
      Offset(cx, topCenter.dy + boxH / 2),
      Offset(cx, clearedCenter.dy - boxH / 2),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(cx, clearedCenter.dy + boxH / 2),
      Offset(cx, finalCenter.dy - 20.0),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.6,
    );

    // 1. Top Fractional Equation Box
    final Rect topRect =
    Rect.fromCenter(center: topCenter, width: boxW, height: boxH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(10)),
      Paint()..color = Colors.deepPurple.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.deepPurple.shade400
        ..strokeWidth = 1.9
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.topFractionalEqText,
      cx,
      topCenter.dy,
      fontSize: 13.0,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );

    // 2. Middle LCM Multiplier Bridge Badge
    _drawBadge(
      canvas,
      data.lcmBridgeBadgeText,
      cx,
      midBridge.dy,
      Colors.deepPurple,
    );

    // 3. Cleared Integer Equation Box
    final Rect clearedRect =
    Rect.fromCenter(center: clearedCenter, width: boxW, height: boxH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearedRect, const Radius.circular(10)),
      Paint()..color = Colors.amber.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearedRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 1.9
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.clearedIntegerEqText,
      cx,
      clearedCenter.dy,
      fontSize: 13.0,
      isBold: true,
      color: Colors.orange.shade900,
    );

    // 4. Final Solution Box
    final Rect finalRect =
    Rect.fromCenter(center: finalCenter, width: 290.0, height: 38.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(finalRect, const Radius.circular(10)),
      Paint()..color = Colors.green.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(finalRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.finalSolutionBannerText,
      cx,
      finalCenter.dy,
      fontSize: 13.5,
      isBold: true,
      color: Colors.green.shade900,
    );
  }

  void _paintProportionalWholeBar(Canvas canvas, Size size) {
    final List<WholeBarSegment> segs = data.segments;
    if (segs.isEmpty) return;

    final double cx = size.width / 2;
    const double totalBarW = 540.0;
    const double barH = 66.0;
    const double barTop = 104.0;
    final double barLeft = cx - totalBarW / 2;

    // Top Total Whole Brace & Title
    _drawBadge(
      canvas,
      data.totalWholeTitle,
      cx,
      74.0,
      Colors.deepPurple,
    );

    final List<Color> bgColors = [
      Colors.deepPurple.shade50,
      Colors.amber.shade50,
      Colors.green.shade50,
    ];
    final List<Color> borderColors = [
      Colors.deepPurple.shade500,
      Colors.orange.shade800,
      Colors.green.shade700,
    ];

    // Normalize widths with a sensible minimum width so narrow fractions remain readable
    final List<double> rawWidths = segs
        .map((s) => (s.proportion * totalBarW).clamp(115.0, totalBarW))
        .toList();
    final double sumW = rawWidths.fold(0.0, (a, b) => a + b);
    final List<double> scaledW =
    rawWidths.map((w) => (w / sumW) * totalBarW).toList();

    double currX = barLeft;
    for (int i = 0; i < segs.length; i++) {
      final WholeBarSegment s = segs[i];
      final double w = scaledW[i];
      final Rect segRect = Rect.fromLTWH(currX, barTop, w, barH);
      final Color bg = bgColors[s.colorIndex % bgColors.length];
      final Color border = borderColors[s.colorIndex % borderColors.length];

      canvas.drawRRect(
        RRect.fromRectAndRadius(segRect, const Radius.circular(6)),
        Paint()..color = bg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(segRect, const Radius.circular(6)),
        Paint()
          ..color = border
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      _drawText(
        canvas,
        s.title,
        segRect.center.dx,
        barTop + 16,
        fontSize: 11.0,
        isBold: true,
        color: border,
      );
      _drawText(
        canvas,
        s.fractionOfWholeText,
        segRect.center.dx,
        barTop + 34,
        fontSize: 12.5,
        isBold: true,
        color: Colors.black87,
      );
      _drawText(
        canvas,
        "= ${s.valueText}",
        segRect.center.dx,
        barTop + 52,
        fontSize: 12.0,
        isBold: true,
        color: border,
      );

      currX += w;
    }

    // Bottom Equation Summary
    final String sumChain = segs
        .map((s) => "${s.fractionOfWholeText} (${s.valueText})")
        .join("  +  ");
    _drawBadge(
      canvas,
      "Sum of Parts:   $sumChain  =  Whole (x)",
      cx,
      barTop + barH + 36.0,
      Colors.deepPurple.shade700,
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
  bool shouldRepaint(covariant FractionWordProblemsPainter oldDelegate) =>
      oldDelegate.data != data;
}