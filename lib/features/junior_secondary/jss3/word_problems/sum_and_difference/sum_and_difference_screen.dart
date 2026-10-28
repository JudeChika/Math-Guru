import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'sum_and_difference_logic.dart';
import 'sum_and_difference_models.dart';

class SumAndDifferenceScreen extends StatefulWidget {
  const SumAndDifferenceScreen({super.key});

  @override
  State<SumAndDifferenceScreen> createState() => _SumAndDifferenceScreenState();
}

class _SumAndDifferenceScreenState extends State<SumAndDifferenceScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Direct Sum, Positive Difference & Negative Difference (Ex 2.1 #1–14, #19)
  // 1: Find Unknown Number(s) Given Sum or Difference (Ex 2.1 #17, #18, #20–23)
  // 2: Sum of Consecutive Numbers Solver (Ex 2.1 #15, #16, #24, #25)
  // 3: Simultaneous Sum & Difference / Combined Pairs (Teacher's Guide Page 22)

  int _subMode = 0;
  // Mode 0: 0 = Positive Diff, 1 = Negative Diff, 2 = Sum, 3 = Compare All 3
  // Mode 1: 0 = Given Sum (x + a = S), 1 = Given Difference (Two Possible Values)
  // Mode 3: 0 = Simultaneous Sum & Diff, 1 = Combined Pairs (Sum of A,B & Diff of C,D)

  int _consecutiveCount = 3; // 2, 3, 4, or 5
  int _consecutiveType = 2;
  // 0: Consecutive Integers (x, x+1, x+2...) — Ex 2.1 #25
  // 1: Centered Integers ((x-1), x, (x+1)) — Ex 2.1 #24
  // 2: Consecutive Odd Numbers (x, x+2, x+4...) — Ex 2.1 #15
  // 3: Consecutive Even Numbers (x, x+2, x+4...) — Ex 2.1 #16

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

  SumAndDifferenceResult? _result;
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

  void _applyPreset(SumAndDifferencePreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _consecutiveCount = p.consecutiveCount;
      _consecutiveType = p.consecutiveType;
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
              'Please enter a sum and difference word problem or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Word Problems — Sum and Difference (Pages 19–22, Exercise 2.1 #1–25).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Direct Positive Difference (subMode 0, e.g. Ex 2.1 #13: -16 and -69; #14: 114 and -14; #19: -11.9 and 2.8), Negative Difference (subMode 1), Sum (subMode 2), or Compare All Three (subMode 3). Put first number in "input1" and second number in "input2".
        1 for Finding an unknown number given the Sum (subMode 0, e.g. Ex 2.1 #20: sum of x and 7 3/4 is -2 1/2; #21: sum is -4.36, one number is 7.23; #23: sum of x and 15 is 24) OR given the Difference with two possible values (subMode 1, e.g. Ex 2.1 #17: difference is 9, one number is 18.5; #18: difference between 28.2 and x is 21.2; #22: -10 is difference between 7 and x). Put the known number in "input1" and the target sum/difference in "input2".
        2 for Sum of Consecutive Numbers (Ex 2.1 #15, #16, #24, #25):
          - "consecutiveCount": 2, 3, 4, or 5.
          - "consecutiveType": 0 for consecutive integers (x, x+1, ... as in #25), 1 for centered integers (x-1), x, (x+1) as in #24, 2 for consecutive odd numbers (#15), 3 for consecutive even numbers (#16).
          - Put the given total sum in "input1".
        3 for Simultaneous Sum & Difference of two numbers (subMode 0: input1 = Sum, input2 = Difference) OR Combined Sum of (A,B) and Positive Difference of (C,D) (subMode 1: input1=A, input2=B, input3=C, input4=D).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "consecutiveCount": 3,
        "consecutiveType": 2,
        "input1": "-16",
        "input2": "-69",
        "input3": "",
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
        _consecutiveCount =
            ((jsonMap['consecutiveCount'] as num?)?.toInt() ?? 3).clamp(2, 5);
        _consecutiveType =
            ((jsonMap['consecutiveType'] as num?)?.toInt() ?? 0).clamp(0, 3);
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
        _result = SumAndDifferenceLogic.solveDirectSumAndDifference(
          numAStr: _input1Ctrl.text,
          numBStr: _input2Ctrl.text,
          operationType: _subMode.clamp(0, 3),
        );
      } else if (_mode == 1) {
        _result = SumAndDifferenceLogic.solveUnknownFromSumOrDifference(
          subMode: _subMode.clamp(0, 1),
          knownNumberStr: _input1Ctrl.text,
          targetSumOrDiffStr: _input2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SumAndDifferenceLogic.solveConsecutiveNumbersSum(
          countN: _consecutiveCount,
          consecutiveType: _consecutiveType,
          totalSumStr: _input1Ctrl.text,
        );
      } else {
        _result = SumAndDifferenceLogic.solveSimultaneousOrCombined(
          subMode: _subMode.clamp(0, 1),
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
    const presets = SumAndDifferenceLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Exercise 2.1 #13–25):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.calculate_outlined,
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
        'label': 'Positive / Negative Diff & Sum (Ex 2.1 #13, #14, #19)',
        'icon': Icons.compare_arrows,
      },
      {
        'idx': 1,
        'label': 'Find Unknown Number(s) (Ex 2.1 #17–18, #20–23)',
        'icon': Icons.find_replace,
      },
      {
        'idx': 2,
        'label': 'Sum of Consecutive Numbers (Ex 2.1 #15–16, #24–25)',
        'icon': Icons.stacked_bar_chart,
      },
      {
        'idx': 3,
        'label': 'Simultaneous Sum & Diff / Combined Pairs',
        'icon': Icons.functions,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Sum & Difference Word Problem Mode:"),
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
                "2. Direct Positive Difference, Negative Difference & Sum (Ex 2.1 #13, #14, #19):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'Positive Diff (Larger − Smaller)'},
                {'idx': 1, 'lbl': 'Negative Diff (Smaller − Larger)'},
                {'idx': 2, 'lbl': 'Sum (A + B)'},
                {'idx': 3, 'lbl': 'Compare All Three'},
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
                    "First Number (A)",
                    hint: "e.g. -16, 114, -11.9, or 7 3/4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Second Number (B)",
                    hint: "e.g. -69, -14, 2.8, or -2 1/2",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Find Unknown Number(s) Given the Sum or Difference (Ex 2.1 #17–18, #20–23):"),
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
                      "Given the SUM (x + a = S)\n(Ex 2.1 #20, #21, #23)",
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
                      "Given the DIFFERENCE (2 Values!)\n(Ex 2.1 #17, #18, #22)",
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
                    "Known Number (a)",
                    hint: _subMode == 0
                        ? "e.g. 7 3/4, 7.23, or 15"
                        : "e.g. 18.5, 28.2, or 7",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    _subMode == 0 ? "Given Sum (S)" : "Given Difference (d)",
                    hint: _subMode == 0
                        ? "e.g. -2 1/2, -4.36, or 24"
                        : "e.g. 9, 21.2, or -10",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Sum of Consecutive Numbers Solver (Ex 2.1 #15, #16, #24, #25):"),
            const SizedBox(height: 10),
            const Text(
              "How Many Consecutive Numbers?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [2, 3, 4, 5].map((cnt) {
                final bool isSel = _consecutiveCount == cnt;
                return ChoiceChip(
                  label: Text(
                    "$cnt Numbers",
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
                  onSelected: (_) => setState(() => _consecutiveCount = cnt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              "Type of Consecutive Numbers:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'Consecutive Integers: x, x+1, x+2... (#25)'},
                {
                  'idx': 1,
                  'lbl': 'Centered Integers: (x−1), x, (x+1) (#24)',
                },
                {'idx': 2, 'lbl': 'Consecutive ODD: x, x+2, x+4... (#15)'},
                {'idx': 3, 'lbl': 'Consecutive EVEN: x, x+2, x+4... (#16)'},
              ].map((t) {
                final int idx = t['idx'] as int;
                final bool isSel = _consecutiveType == idx;
                return ChoiceChip(
                  label: Text(
                    t['lbl'] as String,
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
                  onSelected: (_) => setState(() {
                    _consecutiveType = idx;
                    if (idx == 1) _consecutiveCount = 3;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _input1Ctrl,
              "Given Total Sum of the $_consecutiveCount Numbers",
              hint: "e.g. 177, 258, 105, or -258",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Simultaneous Sum & Difference / Combined Pairs (Page 22):"),
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
                      "Given Both Sum & Diff\n(x + y = S, x − y = D)",
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
                      "Combined Pairs\nSum(A,B) ± Diff(C,D)",
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Sum of Two Numbers (S)",
                      hint: "e.g. 42",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Difference of Two Numbers (D)",
                      hint: "e.g. 10",
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "1st Pair: Number A",
                      hint: "e.g. 18",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "1st Pair: Number B",
                      hint: "e.g. -5",
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
                      "2nd Pair: Number C",
                      hint: "e.g. 24",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input4Ctrl,
                      "2nd Pair: Number D",
                      hint: "e.g. -9",
                    ),
                  ),
                ],
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
                    "Snap a photo of any Sum and Difference word problem from JSS 3 Chapter 2 (Exercise 2.1 #1–25), and the AI will solve it step-by-step!",
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
              labelText: "Sum and Difference Word Problem",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. The sum of three consecutive odd numbers is 177. Find the numbers. Or: The sum of a number and 7 3/4 is -2 1/2...",
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
                "Extract & Solve Word Problem",
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
              "Solve Word Problem Step-by-Step",
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

    final SumAndDifferenceCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    final double canvasHeight =
    cd.visualType == 1 ? math.max(340.0, 150.0 + cd.bars.length * 54.0) : 320.0;

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
                    ? "1. Interactive Directed Number Line & Distance Visualizer:"
                    : "1. Interactive Algebraic Bar-Model & Sum Visualizer:",
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
          height: canvasHeight.clamp(320.0, 410.0),
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
                  painter: SumAndDifferencePainter(data: cd),
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
          'Sum & Difference Word Problems',
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

class SumAndDifferencePainter extends CustomPainter {
  final SumAndDifferenceCanvasData data;

  SumAndDifferencePainter({required this.data});

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
      _paintDirectedNumberLine(canvas, size);
    } else {
      _paintAlgebraicBarModel(canvas, size);
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

  void _paintDirectedNumberLine(Canvas canvas, Size size) {
    const double lineY = 185.0;
    const double leftPad = 76.0;
    final double rightPad = size.width - 76.0;

    // Horizontal Directed Number Line with arrowheads at both ends
    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(leftPad - 20, lineY), Offset(rightPad + 20, lineY), axisPaint);
    _drawArrowHead(canvas, Offset(rightPad + 22, lineY), 0, Colors.black87);
    _drawArrowHead(canvas, const Offset(leftPad - 22, lineY), math.pi, Colors.black87);

    final List<double> allVals = [
      0.0,
      ...data.markers.map((m) => m.value),
      ...data.arcs.expand((a) => [a.fromVal, a.toVal]),
    ];

    double minV = allVals.reduce(math.min);
    double maxV = allVals.reduce(math.max);
    final double rawSpan = math.max(maxV - minV, 4.0);
    minV -= rawSpan * 0.14;
    maxV += rawSpan * 0.14;
    final double span = maxV - minV;

    double toX(double v) => leftPad + ((v - minV) / span) * (rightPad - leftPad);

    // Draw Origin 0 tick mark
    final double zeroX = toX(0.0);
    canvas.drawLine(
      Offset(zeroX, lineY - 9),
      Offset(zeroX, lineY + 9),
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 2.0,
    );
    _drawText(
      canvas,
      "0",
      zeroX,
      lineY + 22,
      fontSize: 12.0,
      isBold: true,
      color: Colors.grey.shade800,
    );

    // Draw Jump Arcs (showing distance / difference between numbers)
    for (int i = 0; i < data.arcs.length; i++) {
      final NumberLineArc arc = data.arcs[i];
      final double x1 = toX(arc.fromVal);
      final double x2 = toX(arc.toVal);
      final double midX = (x1 + x2) / 2;
      final double arcHeight = 52.0 + (i * 18.0);
      final Color arcColor =
      arc.isPositiveJump ? Colors.green.shade800 : Colors.orange.shade900;

      final Path jumpPath = Path()
        ..moveTo(x1, lineY - 8)
        ..quadraticBezierTo(midX, lineY - arcHeight * 1.45, x2, lineY - 8);
      canvas.drawPath(
        jumpPath,
        Paint()
          ..color = arcColor
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );

      final double angleToEnd = x2 >= x1 ? 0.55 : (math.pi - 0.55);
      _drawArrowHead(canvas, Offset(x2, lineY - 8), angleToEnd, arcColor);

      _drawBadge(
        canvas,
        arc.label,
        midX,
        lineY - arcHeight - 8,
        arcColor,
      );
    }

    // Draw Plotted Markers
    for (int i = 0; i < data.markers.length; i++) {
      final NumberLineMarker m = data.markers[i];
      final double mx = toX(m.value);
      final Color dotColor =
      m.isPrimaryHighlight ? Colors.green.shade700 : Colors.deepPurple;

      canvas.drawLine(
        Offset(mx, lineY - 10),
        Offset(mx, lineY + 10),
        Paint()
          ..color = dotColor
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(Offset(mx, lineY), 6.5, Paint()..color = dotColor);
      canvas.drawCircle(Offset(mx, lineY), 2.5, Paint()..color = Colors.white);

      _drawText(
        canvas,
        m.bottomValueLabel,
        mx,
        lineY + 26,
        fontSize: 12.5,
        isBold: true,
        color: dotColor,
      );
      _drawBadge(
        canvas,
        m.topLabel,
        mx.clamp(90.0, size.width - 90.0),
        lineY + 50 + (i.isOdd ? 22.0 : 0.0),
        dotColor,
      );
    }
  }

  void _paintAlgebraicBarModel(Canvas canvas, Size size) {
    final List<AlgebraicBarItem> bars = data.bars;
    if (bars.isEmpty) return;

    const double startY = 66.0;
    const double rowH = 34.0;
    const double gapY = 14.0;
    const double leftLabelW = 165.0;
    const double baseBarW = 210.0;

    final int maxOffsetAbs = bars
        .map((b) => b.offsetConst.abs())
        .fold(0, (a, b) => math.max(a, b));

    const double totalContentW = leftLabelW + baseBarW + 220.0;
    double originX = (size.width - totalContentW) / 2;
    if (originX < 16.0) originX = 16.0;

    final double barStartX = originX + leftLabelW;
    double maxRightX = barStartX + baseBarW;

    for (int i = 0; i < bars.length; i++) {
      final AlgebraicBarItem item = bars[i];
      final double topY = startY + i * (rowH + gapY);
      final double cy = topY + rowH / 2;

      // Left Term Label (e.g., "Term 1 (x)" or "Term 2 (x + 2)")
      _drawText(
        canvas,
        item.termLabel,
        originX + leftLabelW / 2 - 8,
        cy,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );

      // Base 'x' Block
      final Rect baseRect = Rect.fromLTWH(barStartX, topY, baseBarW, rowH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(baseRect, const Radius.circular(7)),
        Paint()..color = Colors.deepPurple.shade50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(baseRect, const Radius.circular(7)),
        Paint()
          ..color = Colors.deepPurple.shade400
          ..strokeWidth = 1.7
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        item.baseBlockLabel,
        baseRect.center.dx,
        cy,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );

      double endOfRowX = baseRect.right;

      // Offset Block (+1, +2, +4, or -1)
      if (item.offsetConst != 0) {
        final double ratio =
        maxOffsetAbs > 0 ? (item.offsetConst.abs() / maxOffsetAbs) : 0.5;
        final double offW = (32.0 + ratio * 46.0).clamp(34.0, 82.0);
        final Rect offRect =
        Rect.fromLTWH(baseRect.right + 4.0, topY, offW, rowH);
        final bool isPos = item.offsetConst > 0;

        canvas.drawRRect(
          RRect.fromRectAndRadius(offRect, const Radius.circular(7)),
          Paint()
            ..color = isPos ? Colors.green.shade50 : Colors.orange.shade50,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(offRect, const Radius.circular(7)),
          Paint()
            ..color = isPos ? Colors.green.shade600 : Colors.orange.shade700
            ..strokeWidth = 1.7
            ..style = PaintingStyle.stroke,
        );
        _drawText(
          canvas,
          isPos ? "+${item.offsetConst}" : "−${item.offsetConst.abs()}",
          offRect.center.dx,
          cy,
          fontSize: 12.0,
          isBold: true,
          color: isPos ? Colors.green.shade900 : Colors.orange.shade900,
        );
        endOfRowX = offRect.right;
      }

      // Evaluated Number on the Right of the Bar
      _drawText(
        canvas,
        item.evaluatedText,
        endOfRowX + 38.0,
        cy,
        fontSize: 12.5,
        isBold: true,
        color: Colors.green.shade900,
      );

      if (endOfRowX + 76.0 > maxRightX) {
        maxRightX = endOfRowX + 76.0;
      }
    }

    // Draw Vertical Total Sum Brace on the Far Right
    final double braceX = maxRightX + 12.0;
    const double braceTop = startY + 4.0;
    final double braceBottom =
        startY + bars.length * rowH + (bars.length - 1) * gapY - 4.0;
    final double braceMidY = (braceTop + braceBottom) / 2;

    final Paint bracePaint = Paint()
      ..color = Colors.green.shade800
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Path bracePath = Path()
      ..moveTo(braceX - 8, braceTop)
      ..lineTo(braceX, braceTop)
      ..lineTo(braceX, braceBottom)
      ..lineTo(braceX - 8, braceBottom);
    canvas.drawPath(bracePath, bracePaint);

    _drawBadge(
      canvas,
      data.totalBraceLabel,
      braceX + 58.0,
      braceMidY,
      Colors.green.shade800,
    );
  }

  void _drawArrowHead(
      Canvas canvas,
      Offset tip,
      double angleRad,
      Color color, {
        double len = 8.5,
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
  bool shouldRepaint(covariant SumAndDifferencePainter oldDelegate) =>
      oldDelegate.data != data;
}