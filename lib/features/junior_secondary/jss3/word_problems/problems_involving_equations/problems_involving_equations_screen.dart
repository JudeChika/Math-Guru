import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'problems_involving_equations_logic.dart';
import 'problems_involving_equations_models.dart';

class ProblemsInvolvingEquationsScreen extends StatefulWidget {
  const ProblemsInvolvingEquationsScreen({super.key});

  @override
  State<ProblemsInvolvingEquationsScreen> createState() =>
      _ProblemsInvolvingEquationsScreenState();
}

class _ProblemsInvolvingEquationsScreenState
    extends State<ProblemsInvolvingEquationsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: "I Thought of a Number..." Sequential Operation Chain (Examples 14, 16 & Ex 2.6 #1–5)
  // 1: Fractional & Two-Sided Equations Where Both Sides Depend on x (Example 15)
  // 2: Real-Life Class / Group Ratio & Partition Word Problems (Exercise 2.6 #6 onwards)
  // 3: Universal Linear Equation Solver & Textbook Palindrome Puzzle (Page 28 Top)

  int _subMode = 0;
  // Mode 2: 0 = Group Multiple / Partition (x + (kx + b) = Total) [Ex 2.6 #6], 1 = Rectangle Perimeter 2(x + kx + b) = P
  // Mode 3: 0 = Universal Free-Form Linear Equation Solver, 1 = Textbook Palindrome Puzzle (Page 28 Top)

  String _varLetter = 'x'; // 'x', 'm', or 'n'

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _opsChainCtrl = TextEditingController();
  final TextEditingController _targetResCtrl = TextEditingController();
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _input4Ctrl = TextEditingController();
  final TextEditingController _input5Ctrl = TextEditingController();

  ProblemsInvolvingEquationsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _opsChainCtrl.dispose();
    _targetResCtrl.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _input5Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(ProblemsInvolvingEquationsPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _varLetter = p.varLetter;
      _opsChainCtrl.text = p.operationsChain;
      _targetResCtrl.text = p.targetResult;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _input5Ctrl.text = p.input5;
    });
    _solveManual();
  }

  void _appendOperationChip(String opToken) {
    final String curr = _opsChainCtrl.text.trim();
    if (curr.isEmpty) {
      _opsChainCtrl.text = opToken;
    } else if (curr.endsWith(',')) {
      _opsChainCtrl.text = '$curr $opToken';
    } else {
      _opsChainCtrl.text = '$curr, $opToken';
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Problems Involving Equations (Pages 27–28, Examples 14–16, Palindrome Puzzle & Exercise 2.6 #1–6).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for "I thought of a number..." sequential operation chains (Example 14: "*5, +3" = 2; Example 16: "+3, *4, +7" = 63; Ex 2.6 #1: "*8, -1" = 15; #2: "+7, /12" = 4; #3: "*3, +6, /5" = 2; #4: "+3, *2" = 8.4; #5: "+7, *3, -3, /2, *12" = 72). Put the comma-separated operations in "operationsChain" and final result in "targetResult".
        1 for Fractional & Two-Sided Equations (a*m + b)/d = c*m + e (Example 15: (3m - 1)/5 = 1 + m -> input1=3, input2=-1, input3=5, input4=1, input5=1).
        2 for Real-Life Group / Ratio / Partition / Perimeter Word Problems:
          - subMode 0: Group sum x + (k*x + b) = Total (Ex 2.6 #6 Timi's class: 3 times as many wear glasses, 28 total -> input1="3", input2="0", input3="28", input4="Students who do not wear glasses", input5="Students who wear glasses").
          - subMode 1: Rectangle perimeter 2(x + k*x + b) = P (input1=k, input2=b, input3=P).
        3 for Universal Linear Equation Solver (subMode 0: put full equation in "input1") OR Page 28 Palindrome Multiplier Puzzle (subMode 1: put multiplier in "input2", e.g. "12").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "varLetter": "n",
        "operationsChain": "+3, *4, +7",
        "targetResult": "63",
        "input1": "",
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
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
        final String vl = jsonMap['varLetter']?.toString() ?? 'x';
        if (['x', 'm', 'n'].contains(vl)) _varLetter = vl;
        if (jsonMap['operationsChain'] != null) {
          _opsChainCtrl.text = jsonMap['operationsChain'].toString();
        }
        if (jsonMap['targetResult'] != null) {
          _targetResCtrl.text = jsonMap['targetResult'].toString();
        }
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
      if (_mode == 0) {
        _result = ProblemsInvolvingEquationsLogic.solveSequentialChainProblem(
          varLetter: _varLetter,
          operationsChainStr: _opsChainCtrl.text,
          targetResultStr: _targetResCtrl.text,
        );
      } else if (_mode == 1) {
        _result = ProblemsInvolvingEquationsLogic.solveTwoSidedFractionalProblem(
          varLetter: _varLetter,
          coeffAStr: _input1Ctrl.text,
          constBStr: _input2Ctrl.text,
          denomDStr: _input3Ctrl.text,
          rhsCoeffCStr: _input4Ctrl.text,
          rhsConstEStr: _input5Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = ProblemsInvolvingEquationsLogic.solveRealLifePartitionProblem(
          subMode: _subMode.clamp(0, 1),
          varLetter: _varLetter,
          multiplierKStr: _input1Ctrl.text,
          offsetBStr: _input2Ctrl.text,
          totalGivenStr: _input3Ctrl.text,
          group1LabelStr: _input4Ctrl.text,
          group2LabelStr: _input5Ctrl.text,
        );
      } else {
        _result =
            ProblemsInvolvingEquationsLogic.solveUniversalOrPalindromePuzzle(
              subMode: _subMode.clamp(0, 1),
              rawEquationInput: _input1Ctrl.text,
              palindromeMultiplierStr: _input2Ctrl.text,
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

  Widget _buildVariableLetterSelector() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        const Text(
          "Unknown Letter:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 12.5,
          ),
        ),
        ...['x', 'm', 'n'].map((v) {
          final bool selected = _varLetter == v;
          return ChoiceChip(
            visualDensity: VisualDensity.compact,
            label: Text(
              "Let $v be the number",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: selected ? Colors.white : Colors.deepPurple,
              ),
            ),
            selected: selected,
            selectedColor: Colors.deepPurple,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? Colors.deepPurple : Colors.deepPurple.shade200,
            ),
            showCheckmark: false,
            onSelected: (_) => setState(() => _varLetter = v),
          );
        }),
      ],
    );
  }

  Widget _buildPresetsBar() {
    const presets = ProblemsInvolvingEquationsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Examples 14–16, Puzzle & Exercise 2.6 #1–6):"),
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
        'label': '"I Thought of a Number..." Chains (Ex 14, 16 & Ex 2.6 #1–5)',
        'icon': Icons.route,
      },
      {
        'idx': 1,
        'label': 'Two-Sided Fractional Equations: (am + b)/d = cm + e (Ex 15)',
        'icon': Icons.balance,
      },
      {
        'idx': 2,
        'label': "Real-Life Group & Ratio Word Problems (Ex 2.6 #6 Timi's Class)",
        'icon': Icons.groups_outlined,
      },
      {
        'idx': 3,
        'label': 'Universal Equation Solver & Page 28 Palindrome Puzzle',
        'icon': Icons.extension_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Equation Word Problem Mode:"),
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
                "2. 'I Thought of a Number...' Sequential Operation Chain (Examples 14, 16 & Ex 2.6 #1–5):"),
            const SizedBox(height: 8),
            _buildVariableLetterSelector(),
            const SizedBox(height: 10),
            _buildTextField(
              _opsChainCtrl,
              "Sequential Operations in Order (Comma-Separated: +a, -b, *c, /d)",
              hint:
              "e.g. *5, +3  or  +3, *4, +7  or  *3, +6, /5  or  +7, *3, -3, /2, *12",
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                {'lbl': '+ Add', 'tok': '+'},
                {'lbl': '− Subtract', 'tok': '-'},
                {'lbl': '× Multiply', 'tok': '*'},
                {'lbl': '÷ Divide', 'tok': '/'},
              ].map((b) {
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    b['lbl']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () =>
                      setState(() => _appendOperationChip(b['tok']!)),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _targetResCtrl,
              "Final Result Obtained",
              hint: "e.g. 2, 63, 15, 4, 8.4, or 72",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Two-Sided Fractional Equation: (a·m + b) / d = c·m + e (Example 15):"),
            const SizedBox(height: 8),
            _buildVariableLetterSelector(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "LHS Coeff of $_varLetter (a)",
                    hint: "e.g. 3",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "LHS Constant (b)",
                    hint: "e.g. -1",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "LHS Divisor (d)",
                    hint: "e.g. 5",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "RHS Coeff of $_varLetter (c)",
                    hint: "e.g. 1",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "RHS Constant (e)",
                    hint: "e.g. 1",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Real-Life Class / Group Ratio & Partition Word Problems (Exercise 2.6 #6):"),
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
                      "Group / Class Partition\nx + (kx + b) = Total (Ex 2.6 #6)",
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
                      "Rectangle Perimeter\n2(x + kx + b) = Perimeter",
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
                    "Multiple (k times 1st)",
                    hint: "e.g. 3 (three times as many)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Extra Offset (+b, 0 if none)",
                    hint: "e.g. 0 or 5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    _subMode == 0 ? "Total in All" : "Total Perimeter",
                    hint: "e.g. 28 or 46",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "1st Group Label (Optional)",
                    hint: "e.g. Do not wear glasses",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "2nd Group Label (Optional)",
                    hint: "e.g. Wear glasses",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Universal Linear Equation Solver & Page 28 Palindrome Puzzle:"),
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
                      "Universal Equation Solver\n(e.g. 4(n + 3) + 7 = 63)",
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
                      "Page 28 Palindrome Puzzle\n(Smallest n × K = Palindrome)",
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
            if (_subMode == 0)
              _buildTextField(
                _input1Ctrl,
                "Enter Any Linear Equation (with x, m, or n)",
                hint:
                "e.g. 5x + 3 = 2, 4(n + 3) + 7 = 63, or (3m - 1) / 5 = 1 + m",
              )
            else
              _buildTextField(
                _input2Ctrl,
                "Multiplier K (Find smallest positive n such that n × K is a palindrome)",
                hint: "e.g. 12 (from the Page 28 Palindrome Puzzle)",
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
                    "Snap a photo of any word problem involving equations from JSS 3 Chapter 2 (Examples 14–16 or Exercise 2.6 on Pages 27–28), and the AI will build the equation and solve it step-by-step!",
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
              labelText: "Word Problem Involving Equations",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. I thought of a number, added 3 and then multiplied by 4. I then added 7 and the result was 63. Find the number...",
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
                "Extract & Solve Equation Word Problem",
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
              "Build Equation & Solve Step-by-Step",
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

    final ProblemsInvolvingEquationsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double neededW = cd.visualType == 0
        ? math.max(680.0, cd.pipelineNodes.length * 165.0 + 60.0)
        : 680.0;
    final double canvasWidth = math.max(screenWidth, neededW);
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
                    ? "1. Interactive 'Think of a Number' Forward & Inverse Pipeline:"
                    : (cd.visualType == 1
                    ? "1. Interactive Two-Sided Algebraic Balance Scale:"
                    : "1. Interactive Group Partition Bar-Model Visualizer:"),
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
                  painter: ProblemsInvolvingEquationsPainter(data: cd),
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
          'Problems Involving Equations',
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

class ProblemsInvolvingEquationsPainter extends CustomPainter {
  final ProblemsInvolvingEquationsCanvasData data;

  ProblemsInvolvingEquationsPainter({required this.data});

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
      _paintForwardInversePipeline(canvas, size);
    } else if (data.visualType == 1) {
      _paintTwoSidedBalanceScale(canvas, size);
    } else {
      _paintGroupPartitionBars(canvas, size);
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

  void _paintForwardInversePipeline(Canvas canvas, Size size) {
    final List<PipelineStepNode> nodes = data.pipelineNodes;
    if (nodes.isEmpty) return;

    final int n = nodes.length;
    const double cardW = 122.0;
    const double cardH = 44.0;
    const double gapX = 36.0;
    final double totalW = n * cardW + (n - 1) * gapX;
    double startX = (size.width - totalW) / 2;
    if (startX < 16.0) startX = 16.0;

    const double forwardRowY = 92.0;
    const double inverseRowY = 208.0;

    for (int i = 0; i < n; i++) {
      final PipelineStepNode nd = nodes[i];
      final double left = startX + i * (cardW + gapX);
      final Rect topCard = Rect.fromLTWH(left, forwardRowY, cardW, cardH);
      final Rect botCard = Rect.fromLTWH(left, inverseRowY, cardW, cardH);

      // Draw Forward Arrow (→) and Inverse Arrow (←) between adjacent cards
      if (i < n - 1) {
        final double arrowStartX = topCard.right + 2.0;
        final double arrowEndX = topCard.right + gapX - 2.0;
        final double midArrowX = (arrowStartX + arrowEndX) / 2;

        // Forward arrow (top row)
        canvas.drawLine(
          Offset(arrowStartX, topCard.center.dy),
          Offset(arrowEndX, topCard.center.dy),
          Paint()
            ..color = Colors.deepPurple
            ..strokeWidth = 2.2,
        );
        _drawArrowHead(
          canvas,
          Offset(arrowEndX, topCard.center.dy),
          0,
          Colors.deepPurple,
        );
        _drawBadge(
          canvas,
          nodes[i + 1].opBadge,
          midArrowX,
          topCard.top - 14.0,
          Colors.deepPurple,
        );

        // Inverse arrow (bottom row pointing left ←)
        canvas.drawLine(
          Offset(arrowEndX, botCard.center.dy),
          Offset(arrowStartX, botCard.center.dy),
          Paint()
            ..color = Colors.green.shade800
            ..strokeWidth = 2.2,
        );
        _drawArrowHead(
          canvas,
          Offset(arrowStartX, botCard.center.dy),
          math.pi,
          Colors.green.shade800,
        );
        _drawBadge(
          canvas,
          nodes[i + 1].inverseOpBadge,
          midArrowX,
          botCard.bottom + 14.0,
          Colors.green.shade800,
        );
      }

      // Draw Top Card (Forward Algebraic Expression)
      canvas.drawRRect(
        RRect.fromRectAndRadius(topCard, const Radius.circular(8)),
        Paint()..color = Colors.deepPurple.shade50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(topCard, const Radius.circular(8)),
        Paint()
          ..color = Colors.deepPurple.shade400
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        nd.exprText,
        topCard.center.dx,
        topCard.center.dy,
        fontSize: 11.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );

      // Draw Bottom Card (Inverse Unwinding Value)
      final bool isFinalSol = i == 0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(botCard, const Radius.circular(8)),
        Paint()
          ..color = isFinalSol ? Colors.green.shade100 : Colors.green.shade50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(botCard, const Radius.circular(8)),
        Paint()
          ..color = Colors.green.shade700
          ..strokeWidth = isFinalSol ? 2.4 : 1.7
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        nd.inverseValText,
        botCard.center.dx,
        botCard.center.dy,
        fontSize: isFinalSol ? 12.5 : 12.0,
        isBold: true,
        color: Colors.green.shade900,
      );
    }

    // Right-end vertical connector from final equation down to inverse start
    final double lastCenterX =
        startX + (n - 1) * (cardW + gapX) + cardW / 2;
    canvas.drawLine(
      Offset(lastCenterX, forwardRowY + cardH + 2),
      Offset(lastCenterX, inverseRowY - 4),
      Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 2.2,
    );
    _drawArrowHead(
      canvas,
      Offset(lastCenterX, inverseRowY - 2),
      math.pi / 2,
      Colors.orange.shade800,
    );
  }

  void _paintTwoSidedBalanceScale(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double beamY = 126.0;
    const double beamHalfSpan = 152.0;

    // Fulcrum Triangle
    final Path fulcrum = Path()
      ..moveTo(cx, beamY)
      ..lineTo(cx - 20, beamY + 34)
      ..lineTo(cx + 20, beamY + 34)
      ..close();
    canvas.drawPath(fulcrum, Paint()..color = Colors.deepPurple.shade700);

    canvas.drawLine(
      Offset(cx - beamHalfSpan, beamY),
      Offset(cx + beamHalfSpan, beamY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 3.2,
    );
    _drawBadge(canvas, "=", cx, beamY - 14, Colors.deepPurple);

    final Rect lhsRect = Rect.fromCenter(
      center: Offset(cx - beamHalfSpan, beamY - 28),
      width: 210.0,
      height: 48.0,
    );
    final Rect rhsRect = Rect.fromCenter(
      center: Offset(cx + beamHalfSpan, beamY - 28),
      width: 210.0,
      height: 48.0,
    );

    for (final entry in [
      {
        'rect': lhsRect,
        'title': data.lhsPanTitle,
        'expr': data.lhsPanExpr,
        'isLhs': true,
      },
      {
        'rect': rhsRect,
        'title': data.rhsPanTitle,
        'expr': data.rhsPanExpr,
        'isLhs': false,
      },
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

    if (data.middleBridgeBadge.isNotEmpty) {
      _drawBadge(
        canvas,
        data.middleBridgeBadge,
        cx,
        202.0,
        Colors.deepPurple.shade700,
      );
    }
    if (data.clearedBalanceBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.clearedBalanceBanner,
        cx,
        244.0,
        Colors.green.shade800,
      );
    }
  }

  void _paintGroupPartitionBars(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double totalBarW = 540.0;
    const double barH = 66.0;
    const double barTop = 104.0;
    final double barLeft = cx - totalBarW / 2;

    _drawBadge(
      canvas,
      data.totalGroupBanner,
      cx,
      72.0,
      Colors.deepPurple,
    );

    final double w1 = (data.group1Proportion * totalBarW).clamp(150.0, 390.0);
    final double w2 = totalBarW - w1;

    final Rect rect1 = Rect.fromLTWH(barLeft, barTop, w1, barH);
    final Rect rect2 = Rect.fromLTWH(barLeft + w1, barTop, w2, barH);

    // Group 1 Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect1, const Radius.circular(6)),
      Paint()..color = Colors.deepPurple.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect1, const Radius.circular(6)),
      Paint()
        ..color = Colors.deepPurple.shade500
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.group1Title,
      rect1.center.dx,
      barTop + 20,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );
    _drawText(
      canvas,
      data.group1Value,
      rect1.center.dx,
      barTop + 44,
      fontSize: 13.5,
      isBold: true,
      color: Colors.black87,
    );

    // Group 2 Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect2, const Radius.circular(6)),
      Paint()..color = Colors.green.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect2, const Radius.circular(6)),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      data.group2Title,
      rect2.center.dx,
      barTop + 20,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade900,
    );
    _drawText(
      canvas,
      data.group2Value,
      rect2.center.dx,
      barTop + 44,
      fontSize: 13.5,
      isBold: true,
      color: Colors.black87,
    );
  }

  void _drawArrowHead(
      Canvas canvas,
      Offset tip,
      double angleRad,
      Color color, {
        double len = 8.0,
      }) {
    const double wing = 0.46;
    final Path path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - len * math.cos(angleRad - wing),
        tip.dy - len * math.sin(angleRad - wing),
      )
      ..lineTo(
        tip.dx - len * math.cos(angleRad + wing),
        tip.dy - len * math.sin(angleRad + wing),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
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
  bool shouldRepaint(covariant ProblemsInvolvingEquationsPainter oldDelegate) =>
      oldDelegate.data != data;
}