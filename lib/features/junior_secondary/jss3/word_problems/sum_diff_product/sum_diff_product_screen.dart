import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'sum_diff_product_logic.dart';
import 'sum_diff_product_models.dart';

class SumDiffProductScreen extends StatefulWidget {
  const SumDiffProductScreen({super.key});

  @override
  State<SumDiffProductScreen> createState() => _SumDiffProductScreenState();
}

class _SumDiffProductScreenState extends State<SumDiffProductScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Direct Numerical Expressions Combining Product with Sum/Diff (Example 7 & Ex 2.3 Part 1)
  // 1: One-Sided Algebraic Equations ax ± b = c or b − ax = c (Ex 2.3 Part 2)
  // 2: Bracketed Algebraic Word Problems k(x ± b) = c or k(b − x) = c (Ex 2.3 Part 3)
  // 3: Two-Sided Equations & Consecutive Multiples ax ± b = cx ± d (BECE & Ex 2.3 Challenge)

  int _subMode = 0;
  // Mode 0: 0 = a*(b+c), 1 = a*|b-c|, 2 = (a+b)*|c-d|, 3 = a+(b*c), 4 = a-(b*c)
  // Mode 1: 0 = ax + b = c, 1 = ax - b = c, 2 = b - ax = c
  // Mode 2: 0 = k(x + b) = c, 1 = k(x - b) = c, 2 = k(b - x) = c
  // Mode 3: 0 = ax + b = cx + d, 1 = k1(x + a) = k2(x + b), 2 = a*x + b*(x + 1) = S

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

  SumDiffProductResult? _result;
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

  void _applyPreset(SumDiffProductPreset p) {
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
              'Please enter a word problem or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Word Problems — Sums and Differences Combined with Products (Pages 23–25, Example 7 & Exercise 2.3).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Direct Numerical Expressions Combining Product with Sum/Difference:
          - subMode 0: Product of a and sum of b and c -> a*(b + c) (Example 7: 7 and sum of 8 and 10 -> input1=7, input2=8, input3=10).
          - subMode 1: Product of a and positive difference between b and c -> a*|b - c| (input1=a, input2=b, input3=c).
          - subMode 2: Product of sum of (a,b) and positive difference of (c,d) -> (a+b)*|c-d| (input1=a, input2=b, input3=c, input4=d).
          - subMode 3: Add a to product of b and c -> a + (b*c) (input1=a, input2=b, input3=c).
          - subMode 4: Subtract product of b and c from a -> a - (b*c) (input1=a, input2=b, input3=c).
        1 for One-Sided Algebraic Word Problems (where multiplication happens to x first):
          - subMode 0: b added to a times x gives c -> ax + b = c (input1=a, input2=b, input3=c).
          - subMode 1: b subtracted from a times x gives c -> ax - b = c (input1=a, input2=b, input3=c).
          - subMode 2: a times x subtracted from b gives c -> b - ax = c (input1=a, input2=b, input3=c).
        2 for Bracketed Algebraic Word Problems (where addition/subtraction happens to x first, then multiplied by k):
          - subMode 0: Product of k and sum of x and b is c -> k(x + b) = c (input1=k, input2=b, input3=c).
          - subMode 1: Subtract b from x, multiply result by k gives c -> k(x - b) = c (input1=k, input2=b, input3=c).
          - subMode 2: Subtract x from b, multiply result by k gives c -> k(b - x) = c (input1=k, input2=b, input3=c).
        3 for Two-Sided Equations & Consecutive Multiples:
          - subMode 0: ax + b = cx + d (input1=a, input2=b, input3=c, input4=d).
          - subMode 1: k1(x + a) = k2(x + b) (input1=k1, input2=a, input3=k2, input4=b).
          - subMode 2: Sum of a times first consecutive number and b times second is S -> a*x + b*(x+1) = S (input1=a, input2=b, input3=S).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "input1": "7",
        "input2": "8",
        "input3": "10",
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
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 4);
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
        _result = SumDiffProductLogic.solveDirectCombinedExpression(
          subMode: _subMode.clamp(0, 4),
          input1Str: _input1Ctrl.text,
          input2Str: _input2Ctrl.text,
          input3Str: _input3Ctrl.text,
          input4Str: _input4Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = SumDiffProductLogic.solveOneSidedLinearWordProblem(
          subMode: _subMode.clamp(0, 2),
          coeffAStr: _input1Ctrl.text,
          constBStr: _input2Ctrl.text,
          resultCStr: _input3Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SumDiffProductLogic.solveBracketedAlgebraicWordProblem(
          subMode: _subMode.clamp(0, 2),
          multiplierKStr: _input1Ctrl.text,
          insideBStr: _input2Ctrl.text,
          resultCStr: _input3Ctrl.text,
        );
      } else {
        _result = SumDiffProductLogic.solveTwoSidedOrConsecutiveMultiples(
          subMode: _subMode.clamp(0, 2),
          input1Str: _input1Ctrl.text,
          input2Str: _input2Ctrl.text,
          input3Str: _input3Ctrl.text,
          input4Str: _input4Ctrl.text,
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
    const presets = SumDiffProductLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook & BECE Presets (Example 7 & Exercise 2.3):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.functions,
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
        'label': 'Direct BODMAS Expressions: a × (b ± c) (Example 7 & Ex 2.3)',
        'icon': Icons.account_tree_outlined,
      },
      {
        'idx': 1,
        'label': 'One-Sided Linear Equations: ax ± b = c or b − ax = c',
        'icon': Icons.linear_scale,
      },
      {
        'idx': 2,
        'label': 'Bracketed Word Problems: k(x ± b) = c or k(b − x) = c',
        'icon': Icons.code,
      },
      {
        'idx': 3,
        'label': 'Two-Sided Equations & Consecutive Multiples (ax + b = cx + d)',
        'icon': Icons.balance,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Sums, Differences & Products Word Problem Mode:"),
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
                "2. Direct Numerical Expressions Combining Product with Sum / Difference (Example 7):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'a × (b + c) [Product & Sum — Ex 7]'},
                {'idx': 1, 'lbl': 'a × |b − c| [Product & Pos. Diff]'},
                {'idx': 2, 'lbl': '(a + b) × |c − d| [Sum × Diff]'},
                {'idx': 3, 'lbl': 'a + (b × c) [Add a to Product]'},
                {'idx': 4, 'lbl': 'a − (b × c) [Subtract Product from a]'},
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
            if (_subMode == 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "1st Sum Number (a)",
                      hint: "e.g. 12",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "2nd Sum Number (b)",
                      hint: "e.g. 8",
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
                      "1st Diff Number (c)",
                      hint: "e.g. 19",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      "2nd Diff Number (d)",
                      hint: "e.g. 14",
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
                      _subMode <= 1
                          ? "Multiplier (a)"
                          : (_subMode == 3
                          ? "Number Added (a)"
                          : "Number Subtracted From (a)"),
                      hint: "e.g. 7, -4, 2 1/2, 15, or 50",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Second Number (b)",
                      hint: "e.g. 8, 15, 1 1/3, -6, or 4",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Third Number (c)",
                hint: "e.g. 10, -5, 2 2/3, 8, or 9",
              ),
            ],
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. One-Sided Algebraic Word Problems (Multiply x by a First, Then Add/Subtract b):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'ax + b = c (b added to a times x)'},
                {'idx': 1, 'lbl': 'ax − b = c (b subtracted from a times x)'},
                {'idx': 2, 'lbl': 'b − ax = c (a times x subtracted from b)'},
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
                    "Multiplier of x (a)",
                    hint: "e.g. 5, 4, 3, or 3/4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Added / Subtracted Number (b)",
                    hint: "e.g. 8, 9, 40, or 2 1/2",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Given Result (c)",
              hint: "e.g. 43, 27, 16, or 8 1/2",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Bracketed Algebraic Word Problems (Add/Subtract First, Then Multiply by k):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {
                  'idx': 0,
                  'lbl': 'k(x + b) = c [Product of k and sum of x & b]',
                },
                {
                  'idx': 1,
                  'lbl': 'k(x − b) = c [Subtract b from x, multiply by k]',
                },
                {
                  'idx': 2,
                  'lbl': 'k(b − x) = c [Subtract x from b, multiply by k]',
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
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Outside Multiplier (k)",
                    hint: "e.g. 6, 8, or 3",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Number Inside Bracket (b)",
                    hint: "e.g. 4, 5, or 20",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Given Result (c)",
              hint: "e.g. 54, 56, or 42",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Two-Sided Equations & Combined Multiples of Consecutive Numbers:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'Two-Sided Linear: ax + b = cx + d'},
                {
                  'idx': 1,
                  'lbl': 'Two-Sided Bracketed: k₁(x + a) = k₂(x + b)',
                },
                {
                  'idx': 2,
                  'lbl': 'Consecutive Multiples: ax + b(x + 1) = S',
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
            if (_subMode == 0 || _subMode == 1) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      _subMode == 0 ? "LHS Multiplier (a)" : "LHS Multiplier (k₁)",
                      hint: "e.g. 2 or 5",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      _subMode == 0 ? "LHS Constant (b)" : "LHS Inside Bracket (a)",
                      hint: "e.g. 11 or 2",
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
                      _subMode == 0 ? "RHS Multiplier (c)" : "RHS Multiplier (k₂)",
                      hint: "e.g. 5 or 7",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      _subMode == 0 ? "RHS Constant (d)" : "RHS Inside Bracket (b)",
                      hint: "e.g. -7 or -4",
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
                      "1st Number Multiplier (a)",
                      hint: "e.g. 2",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "2nd Number Multiplier (b)",
                      hint: "e.g. 3",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "Given Total Sum (S)",
                hint: "e.g. 43",
              ),
            ],
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
                    "Snap a photo of any word problem combining sums, differences, and products from JSS 3 Chapter 2 (Example 7 or Exercise 2.3), and the AI will solve it step-by-step!",
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
              labelText: "Sums & Differences Combined with Products Problem",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Find the product of 7 and the sum of 8 and 10. Or: The product of 6 and the sum of a certain number and 4 is 54. Find the number...",
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
                "Extract & Solve Combined Problem",
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
              "Solve Combined Word Problem Step-by-Step",
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

    final SumDiffProductCanvasData cd = _result!.canvasData;
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
                    ? "1. Interactive BODMAS Two-Stage Expression-Tree Visualizer:"
                    : "1. Interactive Algebraic Balance-Scale & Inverse Operation Chain:",
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
                  painter: SumDiffProductPainter(data: cd),
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
          'Sums, Differences & Products',
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

class SumDiffProductPainter extends CustomPainter {
  final SumDiffProductCanvasData data;

  SumDiffProductPainter({required this.data});

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
      _paintBodmasExpressionTree(canvas, size);
    } else {
      _paintAlgebraicBalanceScale(canvas, size);
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

  void _paintBodmasExpressionTree(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double topY = 74.0;
    const double cardW = 216.0;
    const double cardH = 58.0;
    const double gapX = 56.0;

    final Rect boxARect =
    Rect.fromLTWH(cx - cardW - gapX / 2, topY, cardW, cardH);
    final Rect boxBRect = Rect.fromLTWH(cx + gapX / 2, topY, cardW, cardH);

    final Offset opHubCenter = Offset(cx, 178.0);
    final Offset finalCenter = Offset(cx, 250.0);

    // Draw lines from Box A and Box B to Operation Hub
    final Paint linePaint = Paint()
      ..color = Colors.deepPurple.shade300
      ..strokeWidth = 2.3;
    canvas.drawLine(
      Offset(boxARect.center.dx, boxARect.bottom),
      Offset(opHubCenter.dx - 16, opHubCenter.dy - 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(boxBRect.center.dx, boxBRect.bottom),
      Offset(opHubCenter.dx + 16, opHubCenter.dy - 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(opHubCenter.dx, opHubCenter.dy + 18),
      Offset(finalCenter.dx, finalCenter.dy - 22),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.6,
    );

    // Draw Box A (Multiplier / 1st Bracket)
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxARect, const Radius.circular(10)),
      Paint()..color = Colors.deepPurple.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxARect, const Radius.circular(10)),
      Paint()
        ..color = Colors.deepPurple.shade400
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.stage1BoxATitle,
      boxARect.center.dx,
      boxARect.top + 16,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );
    _drawText(
      canvas,
      data.stage1BoxAValue,
      boxARect.center.dx,
      boxARect.top + 38,
      fontSize: 13.5,
      isBold: true,
      color: Colors.black87,
    );

    // Draw Box B (Evaluated Bracket Result)
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxBRect, const Radius.circular(10)),
      Paint()..color = Colors.amber.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxBRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.stage1BoxBTitle,
      boxBRect.center.dx,
      boxBRect.top + 16,
      fontSize: 11.5,
      isBold: true,
      color: Colors.orange.shade900,
    );
    _drawText(
      canvas,
      data.stage1BoxBValue,
      boxBRect.center.dx,
      boxBRect.top + 38,
      fontSize: 13.5,
      isBold: true,
      color: Colors.black87,
    );

    // Draw Bridge Operator Circle
    canvas.drawCircle(
      opHubCenter,
      19.0,
      Paint()..color = Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.bridgeOperatorSymbol,
      opHubCenter.dx,
      opHubCenter.dy,
      fontSize: 17.5,
      isBold: true,
      color: Colors.white,
    );

    // Draw Final Result Box
    final Rect finalRect = Rect.fromCenter(
      center: finalCenter,
      width: 280.0,
      height: 44.0,
    );
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
      "${data.finalResultTitle}:  ${data.finalResultValue}",
      finalCenter.dx,
      finalCenter.dy,
      fontSize: 13.5,
      isBold: true,
      color: Colors.green.shade900,
    );
  }

  void _paintAlgebraicBalanceScale(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double beamY = 128.0;
    const double beamHalfSpan = 150.0;

    // Fulcrum Triangle & Base Pillar
    final Path fulcrum = Path()
      ..moveTo(cx, beamY)
      ..lineTo(cx - 20, beamY + 34)
      ..lineTo(cx + 20, beamY + 34)
      ..close();
    canvas.drawPath(fulcrum, Paint()..color = Colors.deepPurple.shade700);

    // Horizontal Balance Beam
    canvas.drawLine(
      Offset(cx - beamHalfSpan, beamY),
      Offset(cx + beamHalfSpan, beamY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 3.2,
    );
    _drawBadge(canvas, "=", cx, beamY - 14, Colors.deepPurple);

    // Left Pan (LHS) and Right Pan (RHS)
    final Rect lhsRect = Rect.fromCenter(
      center: Offset(cx - beamHalfSpan, beamY - 28),
      width: 195.0,
      height: 48.0,
    );
    final Rect rhsRect = Rect.fromCenter(
      center: Offset(cx + beamHalfSpan, beamY - 28),
      width: 195.0,
      height: 48.0,
    );

    for (final entry in [
      {'rect': lhsRect, 'title': data.lhsPanTitle, 'expr': data.lhsPanExpr, 'isLhs': true},
      {'rect': rhsRect, 'title': data.rhsPanTitle, 'expr': data.rhsPanExpr, 'isLhs': false},
    ]) {
      final Rect r = entry['rect'] as Rect;
      final bool isLhs = entry['isLhs'] as bool;
      final Color bg = isLhs ? Colors.deepPurple.shade50 : Colors.green.shade50;
      final Color border =
      isLhs ? Colors.deepPurple.shade400 : Colors.green.shade700;

      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(10)),
        Paint()..color = bg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(10)),
        Paint()
          ..color = border
          ..strokeWidth = 1.9
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        entry['title'] as String,
        r.center.dx,
        r.top + 14,
        fontSize: 10.5,
        isBold: true,
        color: border,
      );
      _drawText(
        canvas,
        entry['expr'] as String,
        r.center.dx,
        r.top + 33,
        fontSize: 13.5,
        isBold: true,
        color: Colors.black87,
      );
    }

    // Forward & Inverse Operation Flow Banners Below the Scale
    if (data.forwardChainText.isNotEmpty) {
      _drawBadge(
        canvas,
        data.forwardChainText,
        cx,
        202.0,
        Colors.deepPurple.shade700,
      );
    }
    if (data.reverseChainText.isNotEmpty) {
      _drawBadge(
        canvas,
        data.reverseChainText,
        cx,
        244.0,
        Colors.green.shade800,
      );
    }
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
  bool shouldRepaint(covariant SumDiffProductPainter oldDelegate) =>
      oldDelegate.data != data;
}