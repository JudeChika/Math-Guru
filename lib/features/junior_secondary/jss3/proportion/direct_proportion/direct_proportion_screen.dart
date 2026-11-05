import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'direct_proportion_logic.dart';
import 'direct_proportion_models.dart';

class DirectProportionScreen extends StatefulWidget {
  const DirectProportionScreen({super.key});

  @override
  State<DirectProportionScreen> createState() => _DirectProportionScreenState();
}

class _DirectProportionScreenState extends State<DirectProportionScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Unitary Method & Ratio Method Word Problems (Activity 3.1, Example 1 & Ex 3.1 #5–9, #11)
  // 1: Direct Proportion Table Builder, Ratio Verifier & Graph Reader (Example 2 & Ex 3.1 #1–4, #10)
  // 2: Non-Linear Power Direct Variation Y ∝ Xⁿ / √X (Example 3: R ∝ S²)
  // 3: Custom Table Proportionality Inspector (Test if a Table of Values is in Direct Proportion)

  int _subMode = 0;
  // Mode 0: 0 = Standard Unitary/Ratio, 1 = With g <-> kg Conversion (Ex 3.1 #8)
  // Mode 2: 0 = Y ∝ X² (Find X given Y — Example 3), 1 = Y ∝ X² (Find Y given X), 2 = Y ∝ X³, 3 = Y ∝ √X

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _xLabelCtrl = TextEditingController();
  final TextEditingController _yLabelCtrl = TextEditingController();
  final TextEditingController _varXCtrl = TextEditingController();
  final TextEditingController _varYCtrl = TextEditingController();
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _tableXValuesCtrl = TextEditingController();
  final TextEditingController _extraQueriesCtrl = TextEditingController();

  DirectProportionResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _xLabelCtrl.dispose();
    _yLabelCtrl.dispose();
    _varXCtrl.dispose();
    _varYCtrl.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _tableXValuesCtrl.dispose();
    _extraQueriesCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(DirectProportionPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _xLabelCtrl.text = p.xLabel;
      _yLabelCtrl.text = p.yLabel;
      _varXCtrl.text = p.varX;
      _varYCtrl.text = p.varY;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _tableXValuesCtrl.text = p.tableXValuesCsv;
      _extraQueriesCtrl.text = p.extraQueriesCsv;
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
              'Please enter a direct proportion question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 3: Direct Proportion (Pages 31–37, Activity 3.1, Examples 1–3 & Exercise 3.1 #1–11).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Unitary Method & Ratio Word Problems (Example 1: 4 people use 20 g, find for 7; Ex 3.1 #5: 12 nights cost 6720, find 7 nights; #6: 5 pies cost 730, find 9; #7: 6 chairs cost 16560, find 11; #8: 450 g cost 697.50, find 1 kg = 1000 g [set subMode=1]; #9: 11 pens cost 5197.50, find 6; #11: 5 miles = 8 km, find for 21 miles or 18 1/2 km). Put known x1 in "input1", known y1 in "input2", target x2 in "input3".
        1 for Direct Proportion Table Builder, Ratio Verifier & Graph Reader (Activity 3.1, Example 2 [Table 3.3], Ex 3.1 #1 [Table 3.4], #2 [Table 3.5], #3 [Table 3.6], #4 [Table 3.7], #10 [Table 3.8]). Put known x0 in "input1", known y0 in "input2", comma-separated x-values in "tableXValuesCsv", and follow-up queries like "x=8" or "y=88, y=130" in "extraQueriesCsv".
        2 for Non-Linear Power Direct Variation Y ∝ X^2 (Example 3: R varies directly as S^2; R=25 when S=4, find S when R=36 -> subMode 0, varY="R", varX="S", input1="25", input2="4", input3="36").
        3 for Custom Table Proportionality Inspector (Put x-row in "input1" and y-row in "input2").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "xLabel": "people",
        "yLabel": "g",
        "varX": "p",
        "varY": "b",
        "input1": "4",
        "input2": "20",
        "input3": "7",
        "tableXValuesCsv": "1, 2, 3, 4, 5, 6, 7, 8",
        "extraQueriesCsv": ""
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
        if (jsonMap['xLabel'] != null) {
          _xLabelCtrl.text = jsonMap['xLabel'].toString();
        }
        if (jsonMap['yLabel'] != null) {
          _yLabelCtrl.text = jsonMap['yLabel'].toString();
        }
        if (jsonMap['varX'] != null) {
          _varXCtrl.text = jsonMap['varX'].toString();
        }
        if (jsonMap['varY'] != null) {
          _varYCtrl.text = jsonMap['varY'].toString();
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
        if (jsonMap['tableXValuesCsv'] != null) {
          _tableXValuesCtrl.text = jsonMap['tableXValuesCsv'].toString();
        }
        if (jsonMap['extraQueriesCsv'] != null) {
          _extraQueriesCtrl.text = jsonMap['extraQueriesCsv'].toString();
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
        _result = DirectProportionLogic.solveUnitaryAndRatioProblem(
          subMode: _subMode.clamp(0, 1),
          x1Str: _input1Ctrl.text,
          y1Str: _input2Ctrl.text,
          x2Str: _input3Ctrl.text,
          xUnitStr: _xLabelCtrl.text,
          yUnitStr: _yLabelCtrl.text,
          varXStr: _varXCtrl.text,
          varYStr: _varYCtrl.text,
        );
      } else if (_mode == 1) {
        _result = DirectProportionLogic.solveTableRatioAndGraph(
          xLabelStr: _xLabelCtrl.text,
          yLabelStr: _yLabelCtrl.text,
          varXStr: _varXCtrl.text,
          varYStr: _varYCtrl.text,
          knownXStr: _input1Ctrl.text,
          knownYStr: _input2Ctrl.text,
          tableXValuesCsv: _tableXValuesCtrl.text,
          extraQueriesCsv: _extraQueriesCtrl.text,
        );
      } else if (_mode == 2) {
        _result = DirectProportionLogic.solvePowerDirectVariation(
          subMode: _subMode.clamp(0, 3),
          varYStr: _varYCtrl.text,
          varXStr: _varXCtrl.text,
          givenY1Str: _input1Ctrl.text,
          givenX1Str: _input2Ctrl.text,
          targetInputStr: _input3Ctrl.text,
        );
      } else {
        _result = DirectProportionLogic.solveCustomTableInspector(
          xRowCsv: _input1Ctrl.text,
          yRowCsv: _input2Ctrl.text,
          varXStr: _varXCtrl.text,
          varYStr: _varYCtrl.text,
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
    const presets = DirectProportionLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Activity 3.1, Examples 1–3 & Exercise 3.1 #1–11):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.trending_up,
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
        'label': 'Unitary & Ratio Word Problems (Ex 1 & Ex 3.1 #5–9, #11)',
        'icon': Icons.calculate_outlined,
      },
      {
        'idx': 1,
        'label': 'Tables, Ratios, y = kx & Graphs (Ex 2 & Ex 3.1 #1–4, #10)',
        'icon': Icons.show_chart,
      },
      {
        'idx': 2,
        'label': 'Square & Power Variation: R ∝ S² (Example 3)',
        'icon': Icons.functions,
      },
      {
        'idx': 3,
        'label': 'Custom Table Proportionality Inspector (Test y/x = k)',
        'icon': Icons.table_chart_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Direct Proportion Problem Mode:"),
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
                "2. Unitary Method & Direct Proportion Word Problem (Example 1 & Ex 3.1 #5–9, #11):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Given Quantity 1 (x₁)",
                    hint: "e.g. 4, 12, 5, 6, 450, 11, or 5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _xLabelCtrl,
                    "Unit of x (Optional)",
                    hint: "e.g. people, nights, g, miles",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Corresponding Value 1 (y₁)",
                    hint: "e.g. 20, 6720, 730, 697.50, or 8",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _yLabelCtrl,
                    "Unit of y (Optional)",
                    hint: "e.g. g, ₦, or km",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Target Quantity 2 to Find For (x₂)",
              hint: "e.g. 7, 9, 11, 1000 (for 1 kg), 6, 21, or 18 1/2",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Direct Proportion Table, Ratio Proof, Equation & Graph (Ex 2 & Ex 3.1 #1–4, #10):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _xLabelCtrl,
                    "1st Row Label (x-axis)",
                    hint: "e.g. Blue paint (l) or Mile",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varXCtrl,
                    "Symbol (x)",
                    hint: "e.g. b, l, t, n, x",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _yLabelCtrl,
                    "2nd Row Label (y-axis)",
                    hint: "e.g. Red paint (l) or Cost (N)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varYCtrl,
                    "Symbol (y)",
                    hint: "e.g. r, d, C, y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Known Pair: x₀",
                    hint: "e.g. 5, 2, 4, 1",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Known Pair: y₀",
                    hint: "e.g. 2, 50, 5, 4, 65, 8",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _tableXValuesCtrl,
              "Table x-Values (Comma-Separated)",
              hint: "e.g. 5, 10, 15, 20, 25, 30  or  1, 2, 3, 4, 5, 6, 7, 8",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _extraQueriesCtrl,
              "Follow-Up Queries from Graph / Formula (Optional)",
              hint: "e.g. x=8  or  y=88, y=130, y=60, y=195  or  x=45, x=115",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Non-Linear Power Direct Variation (Example 3, Page 35: R ∝ S²):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'idx': 0, 'lbl': 'Y ∝ X²  (Given Y₂, Find X₂ — Example 3)'},
                {'idx': 1, 'lbl': 'Y ∝ X²  (Given X₂, Find Y₂)'},
                {'idx': 2, 'lbl': 'Y ∝ X³  (Varies as Cube of X)'},
                {'idx': 3, 'lbl': 'Y ∝ √X  (Varies as Square Root of X)'},
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
                    _varYCtrl,
                    "Dependent Symbol (Y)",
                    hint: "e.g. R",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _varXCtrl,
                    "Independent Symbol (X)",
                    hint: "e.g. S",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Initial Known Y₁",
                    hint: "e.g. 25",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Initial Known X₁",
                    hint: "e.g. 4",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              _subMode == 0
                  ? "Target Value of Y₂ (to Find X₂)"
                  : "Target Value of X₂ (to Find Y₂)",
              hint: "e.g. 36 (as in Example 3b: find S given that R = 36)",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Custom Table Proportionality Inspector (Test If y/x = Constant k):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "1st Row Values (x-values, Comma-Separated)",
              hint: "e.g. 5, 10, 15, 20, 25, 30",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input2Ctrl,
              "2nd Row Values (y-values, Comma-Separated)",
              hint: "e.g. 2, 4, 6, 8, 10, 12",
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
                    "Snap a photo of any Direct Proportion table, graph, or word problem from JSS 3 Chapter 3 (Pages 31–37, Examples 1–3, or Exercise 3.1 #1–11)!",
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
              labelText: "Direct Proportion Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A recipe for 4 people uses 20 g of baking powder. Find the mass for 7 people. Or: R varies directly as the square of S...",
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
                "Extract & Solve Direct Proportion",
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
            icon: const Icon(Icons.trending_up, color: Colors.white),
            label: const Text(
              "Solve & Plot Direct Proportion Graph",
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

    final DirectProportionCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 420.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Textbook Millimetre Graph Paper (Figures 3.1–3.3):",
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
                  painter: DirectProportionPainter(data: cd),
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
          'Direct Proportion',
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

class DirectProportionPainter extends CustomPainter {
  final DirectProportionCanvasData data;

  DirectProportionPainter({required this.data});

  String _fmt(double v) => DirectProportionLogic.fmt(v, maxDecimals: 2);

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
      fontSize: 11.0,
      isBold: true,
      color: Colors.green.shade800,
    );

    const double gridLeft = 82.0;
    final double gridRight = size.width - 48.0;
    const double gridTop = 54.0;
    final double gridBottom = size.height - 54.0;
    final Rect plotRect =
    Rect.fromLTRB(gridLeft, gridTop, gridRight, gridBottom);

    // 2. Draw Authentic Textbook Pink/Red Millimetre Graph Paper Grid (Figures 3.1, 3.2 & 3.3!)
    canvas.save();
    canvas.clipRect(plotRect);

    final Paint minorGrid = Paint()
      ..color = Colors.pink.shade50
      ..strokeWidth = 0.7;
    final Paint majorGrid = Paint()
      ..color = Colors.pink.shade200.withOpacity(0.75)
      ..strokeWidth = 1.2;

    const double majorBlockPx = 44.0;
    final int numMinorCols =
    ((plotRect.width / (majorBlockPx / 5)).ceil()).clamp(10, 400);
    for (int i = 0; i <= numMinorCols; i++) {
      final double x = plotRect.left + i * (majorBlockPx / 5);
      final bool isMajor = i % 5 == 0;
      canvas.drawLine(
        Offset(x, plotRect.top),
        Offset(x, plotRect.bottom),
        isMajor ? majorGrid : minorGrid,
      );
    }

    final int numMinorRows =
    ((plotRect.height / (majorBlockPx / 5)).ceil()).clamp(10, 400);
    for (int j = 0; j <= numMinorRows; j++) {
      final double y = plotRect.bottom - j * (majorBlockPx / 5);
      final bool isMajor = j % 5 == 0;
      canvas.drawLine(
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        isMajor ? majorGrid : minorGrid,
      );
    }

    // 3. Determine Max X and Max Y from Points & Traces
    double maxX = 6.0;
    double maxY = 60.0;
    final List<double> allX = [
      ...data.points.map((p) => p.x),
      ...data.traces.map((t) => t.xVal),
    ];
    final List<double> allY = [
      ...data.points.map((p) => p.y),
      ...data.traces.map((t) => t.yVal),
    ];
    if (allX.isNotEmpty) {
      maxX = math.max(allX.reduce(math.max) * 1.15, 1.0);
    }
    if (allY.isNotEmpty) {
      maxY = math.max(allY.reduce(math.max) * 1.15, 1.0);
    }

    double toPxX(double x) =>
        plotRect.left + (x / maxX) * plotRect.width;
    double toPxY(double y) =>
        plotRect.bottom - (y / maxY) * plotRect.height;

    // 4. Draw Straight Line Through Origin (0, 0) (or Power Curve y = k*x^n in Mode 2)
    final Paint linePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    if (data.visualType == 0 || data.powerN == 1) {
      final double endX = maxX;
      final double endY = data.slopeK * endX;
      canvas.drawLine(
        Offset(toPxX(0), toPxY(0)),
        Offset(toPxX(endX), toPxY(endY)),
        linePaint,
      );
    } else {
      final Path curvePath = Path()..moveTo(toPxX(0), toPxY(0));
      const int samples = 60;
      for (int s = 1; s <= samples; s++) {
        final double xv = (s / samples) * maxX;
        final double yv = data.slopeK * math.pow(xv, data.powerN);
        curvePath.lineTo(toPxX(xv), toPxY(yv));
      }
      canvas.drawPath(curvePath, linePaint);
    }

    // 5. Draw Dotted Graph-Reading Interpolation Lines (Matching Figure 3.3!)
    final Paint dottedPaint = Paint()
      ..color = Colors.deepPurple.shade800
      ..strokeWidth = 1.9;

    for (final ProportionGraphTrace tr in data.traces) {
      final Offset ptOnLine = Offset(toPxX(tr.xVal), toPxY(tr.yVal));
      final Offset ptOnXAxis = Offset(toPxX(tr.xVal), plotRect.bottom);
      final Offset ptOnYAxis = Offset(plotRect.left, toPxY(tr.yVal));

      _drawDashedLine(canvas, ptOnXAxis, ptOnLine, dottedPaint);
      _drawDashedLine(canvas, ptOnLine, ptOnYAxis, dottedPaint);
      canvas.drawCircle(
        ptOnLine,
        5.5,
        Paint()..color = Colors.deepPurple.shade800,
      );
      _drawBadge(
        canvas,
        tr.badgeLabel,
        (ptOnLine.dx + 46).clamp(plotRect.left + 55, plotRect.right - 55),
        (ptOnLine.dy + 18).clamp(plotRect.top + 18, plotRect.bottom - 18),
        Colors.deepPurple.shade800,
      );
    }

    // 6. Plot Cross Markers (×) for Every Table Point (Matching Figures 3.1, 3.2 & 3.3!)
    for (final ProportionPlotPoint pt in data.points) {
      if (pt.x == 0 && pt.y == 0) continue;
      final Offset pxPt = Offset(toPxX(pt.x), toPxY(pt.y));
      _drawCrossMarker(canvas, pxPt, Colors.black87, size: 5.0);
    }

    // Equation Badge inside the Graph Area
    _drawBadge(
      canvas,
      "Equation:  ${data.equationBanner}",
      plotRect.left + 115.0,
      plotRect.top + 22.0,
      Colors.red.shade900,
    );

    canvas.restore();

    // 7. Draw Bold Black Horizontal & Vertical Axes + Tick Numbers Outside Clip
    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(plotRect.left, plotRect.bottom),
      Offset(plotRect.right, plotRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(plotRect.left, plotRect.bottom),
      Offset(plotRect.left, plotRect.top),
      axisPaint,
    );

    // Origin (0) & 5 Tick Marks along both axes
    _drawText(
      canvas,
      "0",
      plotRect.left - 12,
      plotRect.bottom + 12,
      fontSize: 11.5,
      isBold: true,
    );

    for (int t = 1; t <= 5; t++) {
      final double xv = (t / 5) * maxX;
      final double px = toPxX(xv);
      canvas.drawLine(
        Offset(px, plotRect.bottom - 4),
        Offset(px, plotRect.bottom + 4),
        axisPaint,
      );
      _drawText(
        canvas,
        _fmt(xv),
        px,
        plotRect.bottom + 14,
        fontSize: 10.5,
        isBold: true,
      );

      final double yv = (t / 5) * maxY;
      final double py = toPxY(yv);
      canvas.drawLine(
        Offset(plotRect.left - 4, py),
        Offset(plotRect.left + 4, py),
        axisPaint,
      );
      _drawText(
        canvas,
        _fmt(yv),
        plotRect.left - 28,
        py,
        fontSize: 10.5,
        isBold: true,
      );
    }

    // Axis Titles
    _drawText(
      canvas,
      data.xAxisLabel,
      (plotRect.left + plotRect.right) / 2,
      plotRect.bottom + 31,
      fontSize: 12.0,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );
    _drawText(
      canvas,
      data.yAxisLabel,
      plotRect.left - 38,
      plotRect.top - 10,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );

    // 8. Bottom Summary Banner
    if (data.bottomSummaryBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.bottomSummaryBanner,
        cx,
        size.height - 14.0,
        Colors.green.shade800,
      );
    }
  }

  void _drawCrossMarker(
      Canvas canvas,
      Offset center,
      Color color, {
        double size = 5.0,
      }) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.1;
    canvas.drawLine(
      Offset(center.dx - size, center.dy - size),
      Offset(center.dx + size, center.dy + size),
      p,
    );
    canvas.drawLine(
      Offset(center.dx - size, center.dy + size),
      Offset(center.dx + size, center.dy - size),
      p,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double dist = (p2 - p1).distance;
    if (dist < 2) return;
    const double dashW = 5.0;
    const double gapW = 4.0;
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 200);
    final double dx = (p2.dx - p1.dx) / count;
    final double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      canvas.drawLine(
        Offset(p1.dx + i * dx, p1.dy + i * dy),
        Offset(p1.dx + (i + 0.55) * dx, p1.dy + (i + 0.55) * dy),
        paint,
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
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + 14,
      height: tp.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
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
  bool shouldRepaint(covariant DirectProportionPainter oldDelegate) =>
      oldDelegate.data != data;
}