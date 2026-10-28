import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'flow_chart_logic.dart';
import 'flow_chart_models.dart';

class FlowChartScreen extends StatefulWidget {
  const FlowChartScreen({super.key});

  @override
  State<FlowChartScreen> createState() => _FlowChartScreenState();
}

class _FlowChartScreenState extends State<FlowChartScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: One-Sided & Bracketed Equation Flow Chart (Ex 8 [Figs 1.1 & 1.2], Ex 1.5 #1 & #4)
  // 1: Two-Sided Comparison Flow Chart with Labeled Boxes A–F (Ex 9 [Fig 1.3] & Ex 1.5 #2)
  // 2: Fractional / Multi-Part Word Problem Flow Chart (Ex 1.5 #3: 1/2x + 2x = 25)
  // 3: Sequential Instruction & Algorithm Organizer (Ex 1.5 #5a–h: Drawing a Circle)

  int _chartStyle = 0;
  // 0: Fig 1.2 / 1.3 Algebraic Style ('Choose x', 'Find 2x', 'Add 8')
  // 1: Fig 1.1 Verbal Style ('Choose a number', 'Multiply by 2', 'Add 8')

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  FlowChartResult? _result;
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

  void _applyPreset(FlowChartPreset p) {
    setState(() {
      _mode = p.mode;
      _chartStyle = p.chartStyle;
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
              'Please enter a flow chart question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 1: Using the Computer for Simple Mathematical Calculations (Flow Charts — Example 8 [Figs 1.1–1.2], Example 9 [Fig 1.3], and Exercise 1.5 #1–5).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for One-sided linear or bracketed equations (Example 8: 2x + 8 = 12; Ex 1.5 #1: 3x + 6 = 18; Ex 1.5 #4: 7(x - 3) = 35). Put the equation in "input1".
        1 for Two-sided comparison equations with x on both sides (Example 9: 2x + 6 = 3x - 1; Ex 1.5 #2: 2x - 4 = 3x). Put the LHS in "input1" (e.g. "2x + 6") and RHS in "input2" (e.g. "3x - 1").
        2 for Fractional / multi-part word problems (Ex 1.5 #3: half of a number plus twice it equals 25). Put Part 1 in "input1" (e.g. "1/2x"), Part 2 in "input2" (e.g. "2x"), and Total in "input3" (e.g. "25").
        3 for Arranging scrambled sequential instructions into a logical flow chart / program (Ex 1.5 #5a-h: drawing a circle with a pair of compasses). Put the instructions in "input1" separated by newlines.

      Return ONLY valid JSON:
      {
        "mode": 0,
        "chartStyle": 0,
        "input1": "3x + 6 = 18",
        "input2": "",
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
        _chartStyle =
            ((jsonMap['chartStyle'] as num?)?.toInt() ?? 0).clamp(0, 1);
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
        _result = FlowChartLogic.solveOneSidedOrBracketFlowChart(
          rawInput: _input1Ctrl.text,
          chartStyle: _chartStyle,
        );
      } else if (_mode == 1) {
        _result = FlowChartLogic.solveTwoSidedComparisonFlowChart(
          lhsExprStr: _input1Ctrl.text,
          rhsExprStr: _input2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = FlowChartLogic.solveFractionalMultiPartFlowChart(
          part1Str: _input1Ctrl.text,
          part2Str: _input2Ctrl.text,
          totalStr: _input3Ctrl.text,
        );
      } else {
        _result = FlowChartLogic.solveSequentialInstructionOrganizer(
          rawInstructionsInput: _input1Ctrl.text,
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
    const presets = FlowChartLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 8–9 [Figs 1.1–1.3] & Ex 1.5 #1–5):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.account_tree_outlined,
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
        'label': 'One-Sided & Bracket Flow Chart (Ex 8 & Ex 1.5 #1, #4)',
        'icon': Icons.account_tree_outlined,
      },
      {
        'idx': 1,
        'label': 'Two-Sided Comparison Boxes A–F (Ex 9 & Ex 1.5 #2)',
        'icon': Icons.compare_arrows,
      },
      {
        'idx': 2,
        'label': 'Fractional Word Problem (Ex 1.5 #3: ½x + 2x = 25)',
        'icon': Icons.pie_chart_outline,
      },
      {
        'idx': 3,
        'label': 'Arrange Sequential Instructions (Ex 1.5 #5a–h)',
        'icon': Icons.format_list_numbered,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Computer Flow Chart Mode:"),
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
                "2. Enter Equation or Word Problem (Ex 8 [Figs 1.1–1.2] & Ex 1.5 #1, #4):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Enter Equation (ax + b = c or k(x - b) = c) or Word Sentence",
              hint:
              "e.g. 2x + 8 = 12, 3x + 6 = 18, 7(x - 3) = 35, or Thrice a certain number plus 6 equals 18",
            ),
            const SizedBox(height: 12),
            const Text(
              "Select Textbook Flow Chart Box Style:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _chartStyle,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Figure 1.2 Algebraic Style\n(Choose x → Find 2x → Add 8)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _chartStyle == 0
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Figure 1.1 Verbal Style\n(Choose a number → Multiply by 2)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _chartStyle == 1
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (int? v) {
                  if (v != null) setState(() => _chartStyle = v);
                },
              ),
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Two-Sided Comparison Flow Chart — Boxes A to F (Ex 9 [Fig 1.3] & Ex 1.5 #2):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Expression (Boxes B & C)",
                    hint: "e.g. 2x + 6  or  2x - 4",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Expression (Boxes D & E)",
                    hint: "e.g. 3x - 1  or  3x",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Fractional / Multi-Part Word Problem Flow Chart (Exercise 1.5 #3):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Part (Box B)",
                    hint: "e.g. 1/2x",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "+",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Part (Box C)",
                    hint: "e.g. 2x",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "=",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Total (Box E)",
                    hint: "e.g. 25",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Arrange Scrambled Instructions in Sequential Order (Exercise 1.5 #5a–h):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Enter Instructions (One per Line or Tap the 'Ex 1.5 #5' Preset Chip Above)",
              hint:
              "a) Put the point of the compasses on the paper.\n"
                  "b) Pick up your compasses.\n"
                  "c) Hold the compasses by the knob at the top.\n"
                  "d) Find your mathematical set...",
              maxLines: 5,
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
                    "Snap a photo of any flow chart or word problem from JSS 3 Chapter 1 (Examples 8 & 9 or Exercise 1.5 #1–5), and the AI will draw the flow chart and solve for x!",
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
              labelText: "Flow Chart or Word Problem Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Thrice a certain number plus 6 equals 18. Find the number using a flow chart...",
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
                "Extract & Build Flow Chart",
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
            icon: const Icon(Icons.account_tree, color: Colors.white),
            label: const Text(
              "Build Flow Chart & Solve Step-by-Step",
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

    final FlowChartCanvasData cd = _result!.canvasData;
    final int nodeCount = cd.mainNodes.length;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    final double canvasHeight = math.max(460.0, 140.0 + nodeCount * 68.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Textbook Flow Chart Diagram (Figures 1.1–1.3):",
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
          height: 460,
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
              boundaryMargin: const EdgeInsets.all(150),
              minScale: 0.35,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: FlowChartPainter(data: cd),
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
          "3. Mathematical & Flow-Chart Workings:",
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
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
          final List<String> mathLines = e.value.mathLaTeX
              .split('\n')
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
                              const EdgeInsets.symmetric(vertical: 4.0),
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
          'Flow Charts',
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

class FlowChartPainter extends CustomPainter {
  final FlowChartCanvasData data;

  FlowChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Top Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      18,
      fontSize: 14.0,
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

    final List<FlowChartNode> nodes = data.mainNodes;
    if (nodes.isEmpty) return;

    // Shift main column slightly left when there is a right-side 'Try again' loop
    final double colX = data.hasTryAgainLoop ? (cx - 72.0) : cx;
    const double startY = 64.0;
    const double boxH = 40.0;
    const double gapY = 26.0;
    const double stepY = boxH + gapY;

    final List<Rect> nodeRects = [];

    for (int i = 0; i < nodes.length; i++) {
      final FlowChartNode node = nodes[i];
      final double topY = startY + i * stepY;
      final double cy = topY + boxH / 2;

      double w = 236.0;
      if (node.type == FlowNodeType.startStopPill) {
        w = 108.0;
      } else if (node.type == FlowNodeType.decisionHexagon) {
        w = 278.0;
      } else if (data.mode == 3) {
        w = 430.0;
      }

      final Rect r = Rect.fromCenter(
        center: Offset(colX, cy),
        width: w,
        height: boxH,
      );
      nodeRects.add(r);

      // Draw downward connecting line and arrow to the next box
      if (i < nodes.length - 1) {
        final double nextTopY = startY + (i + 1) * stepY;
        final bool isDecisionToStop =
            node.type == FlowNodeType.decisionHexagon;
        final Color arrowColor =
        isDecisionToStop ? Colors.green.shade800 : Colors.red.shade700;

        canvas.drawLine(
          Offset(colX, r.bottom),
          Offset(colX, nextTopY),
          Paint()
            ..color = arrowColor
            ..strokeWidth = 2.0,
        );
        _drawArrowHead(
          canvas,
          Offset(colX, nextTopY - 2),
          math.pi / 2,
          arrowColor,
        );

        if (isDecisionToStop) {
          _drawText(
            canvas,
            "Yes",
            colX - 24.0,
            (r.bottom + nextTopY) / 2,
            fontSize: 12.0,
            isBold: true,
            color: Colors.green.shade800,
          );
        }
      }

      // Draw the Node Box Shape (Pill, Rectangle, or 6-Sided Decision Hexagon)
      if (node.type == FlowNodeType.startStopPill) {
        final RRect pill =
        RRect.fromRectAndRadius(r, const Radius.circular(20));
        canvas.drawRRect(
          pill,
          Paint()..color = Colors.deepPurple.shade50,
        );
        canvas.drawRRect(
          pill,
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
      } else if (node.type == FlowNodeType.decisionHexagon) {
        // Authentic 6-sided elongated decision hexagon from Figures 1.1, 1.2 & 1.3!
        const double tipInset = 22.0;
        final Path hex = Path()
          ..moveTo(r.left + tipInset, r.top)
          ..lineTo(r.right - tipInset, r.top)
          ..lineTo(r.right, cy)
          ..lineTo(r.right - tipInset, r.bottom)
          ..lineTo(r.left + tipInset, r.bottom)
          ..lineTo(r.left, cy)
          ..close();

        canvas.drawPath(hex, Paint()..color = Colors.amber.shade50);
        canvas.drawPath(
          hex,
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawRect(r, Paint()..color = Colors.white);
        canvas.drawRect(
          r,
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke,
        );
      }

      final String displayLabel = node.boxLetter.isNotEmpty
          ? "${node.boxLetter}: ${node.text}"
          : node.text;

      _drawText(
        canvas,
        displayLabel,
        colX,
        cy,
        fontSize: data.mode == 3 ? 11.5 : 12.5,
        isBold: node.type != FlowNodeType.processRect ||
            node.boxLetter.isNotEmpty,
        color: Colors.black87,
      );
    }

    // 2. Draw Right-Side 'No -> Try again' Feedback Loop (Figures 1.1, 1.2 & 1.3)
    final int decIdx =
    nodes.indexWhere((n) => n.type == FlowNodeType.decisionHexagon);
    if (data.hasTryAgainLoop && decIdx != -1 && nodeRects.length > 2) {
      final Rect decRect = nodeRects[decIdx];
      final int retIdx = data.loopReturnIndex.clamp(1, nodeRects.length - 1);
      final Rect retRect = nodeRects[retIdx];

      // Entry point on the vertical line just above 'Choose x' (matching Figs 1.1–1.3)
      final double joinY = retRect.top - gapY / 2;
      final double loopX = decRect.right + 82.0;
      final double midLoopY = (decRect.center.dy + joinY) / 2;

      final Paint loopPaint = Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 1.9
        ..style = PaintingStyle.stroke;

      final Rect tryAgainRect = Rect.fromCenter(
        center: Offset(loopX, midLoopY),
        width: 96.0,
        height: 36.0,
      );

      // Path from right tip of Decision Hexagon -> right to loopX -> up to bottom of 'Try again' box
      final Path bottomLeg = Path()
        ..moveTo(decRect.right, decRect.center.dy)
        ..lineTo(loopX, decRect.center.dy)
        ..lineTo(loopX, tryAgainRect.bottom);
      canvas.drawPath(bottomLeg, loopPaint);

      // Upward arrowhead entering 'Try again' box
      _drawArrowHead(
        canvas,
        Offset(loopX, tryAgainRect.bottom + 2),
        -math.pi / 2,
        Colors.red.shade700,
      );

      // 'No' label above the horizontal exit branch
      _drawText(
        canvas,
        "No",
        decRect.right + 28.0,
        decRect.center.dy - 12.0,
        fontSize: 12.0,
        isBold: true,
        color: Colors.red.shade800,
      );

      // Draw 'Try again' rectangular box
      canvas.drawRect(tryAgainRect, Paint()..color = Colors.red.shade50);
      canvas.drawRect(
        tryAgainRect,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "Try again",
        loopX,
        midLoopY,
        fontSize: 12.0,
        isBold: true,
        color: Colors.black87,
      );

      // Path from top of 'Try again' box -> up to joinY -> left to main flow line at colX
      final Path topLeg = Path()
        ..moveTo(loopX, tryAgainRect.top)
        ..lineTo(loopX, joinY)
        ..lineTo(colX, joinY);
      canvas.drawPath(topLeg, loopPaint);

      // Upward directional arrow along the upper vertical segment & leftward arrowhead into main line
      _drawArrowHead(
        canvas,
        Offset(loopX, (tryAgainRect.top + joinY) / 2),
        -math.pi / 2,
        Colors.red.shade700,
      );
      _drawArrowHead(
        canvas,
        Offset(colX + 4, joinY),
        math.pi,
        Colors.red.shade700,
      );
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

  void _drawArrowHead(
      Canvas canvas,
      Offset tip,
      double angleRad,
      Color color, {
        double len = 8.0,
      }) {
    const double wing = 0.48;
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
  bool shouldRepaint(covariant FlowChartPainter oldDelegate) =>
      oldDelegate.data != data;
}