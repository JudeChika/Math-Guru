import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'indirect_proportion_logic.dart';
import 'indirect_proportion_models.dart';

class IndirectProportionScreen extends StatefulWidget {
  const IndirectProportionScreen({super.key});

  @override
  State<IndirectProportionScreen> createState() =>
      _IndirectProportionScreenState();
}

class _IndirectProportionScreenState extends State<IndirectProportionScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Inverse Unitary Method Word Problems x₁y₁ = x₂y₂ (Examples 4 & 5, Ex 3.2 #1, #2, #4)
  // 1: 2-Row Indirect Proportion Table & Curve Graph (Table 3.9, Fig 3.4, Ex 3.2 #6, #7, Rev Ex 3 #3)
  // 2: Compound Proportion — Workers, Work/Length & Time (Exercise 3.2 #3: 15 men dig 90 m in 3 h)
  // 3: Constant-Speed Multi-Part Journey (Exercise 3.2 #5a–d: 175 km in 3 ½ hours)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _xLabelCtrl = TextEditingController();
  final TextEditingController _yLabelCtrl = TextEditingController();
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _input4Ctrl = TextEditingController();
  final TextEditingController _input5Ctrl = TextEditingController();
  final TextEditingController _tableRow1Ctrl = TextEditingController();
  final TextEditingController _graphQueriesCtrl = TextEditingController();

  IndirectProportionResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _xLabelCtrl.dispose();
    _yLabelCtrl.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _input5Ctrl.dispose();
    _tableRow1Ctrl.dispose();
    _graphQueriesCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(IndirectProportionPreset p) {
    setState(() {
      _mode = p.mode;
      _xLabelCtrl.text = p.xLabel;
      _yLabelCtrl.text = p.yLabel;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _input5Ctrl.text = p.input5;
      _tableRow1Ctrl.text = p.tableRow1Csv;
      _graphQueriesCtrl.text = p.graphQueriesCsv;
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
              'Please enter an indirect proportion question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 3: Indirect Proportion (Pages 37–40 & 43, Tables 3.9–3.15, Figure 3.4, Examples 4 & 5, and Exercise 3.2 #1–7).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Inverse Unitary Method Word Problems x1*y1 = x2*y2 (Example 4: 18 farmers in 20 days, find for 6; Example 5: 40 students in 6 weeks, find for 16, 30, 60; Ex 3.2 #1: 15 boys in 12 days, find for 9, 12, 18, 45; #2: 48 km at 5, 60, 100 km/h; #4: 10 labourers in 15 days, find for 12). Put x1 in "input1", y1 in "input2", and comma-separated target x2 values in "input3".
        1 for Indirect Proportion Table & Curve Graph (Table 3.9 [120 km], Ex 3.2 #6 [Table 3.11: 180 km], Ex 3.2 #7 [Table 3.12: 16000], Rev Ex 3 #3 [Table 3.15: 100 km]). Put known x0 in "input1", known y0 in "input2", comma-separated row-1 values in "tableRow1Csv", and graph queries like "x=40, y=6" in "graphQueriesCsv".
        2 for Compound Proportion — Workers, Work/Length & Time (Ex 3.2 #3: 15 men dig 90 m in 3 hours, how long for 16 men to dig 48 m? -> input1="15", input2="90", input3="3", input4="16", input5="48").
        3 for Constant-Speed Multi-Part Journey (Ex 3.2 #5: 175 km in 3 1/2 hours -> input1="175", input2="3 1/2", input3="1 1/2", input4="100", input5="7 1/2").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "xLabel": "farmers",
        "yLabel": "days",
        "input1": "18",
        "input2": "20",
        "input3": "6",
        "input4": "",
        "input5": "",
        "tableRow1Csv": "",
        "graphQueriesCsv": ""
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
        if (jsonMap['xLabel'] != null) {
          _xLabelCtrl.text = jsonMap['xLabel'].toString();
        }
        if (jsonMap['yLabel'] != null) {
          _yLabelCtrl.text = jsonMap['yLabel'].toString();
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
        if (jsonMap['tableRow1Csv'] != null) {
          _tableRow1Ctrl.text = jsonMap['tableRow1Csv'].toString();
        }
        if (jsonMap['graphQueriesCsv'] != null) {
          _graphQueriesCtrl.text = jsonMap['graphQueriesCsv'].toString();
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
        _result = IndirectProportionLogic.solveInverseUnitaryProblem(
          x1Str: _input1Ctrl.text,
          y1Str: _input2Ctrl.text,
          targetX2Csv: _input3Ctrl.text,
          xUnitStr: _xLabelCtrl.text,
          yUnitStr: _yLabelCtrl.text,
        );
      } else if (_mode == 1) {
        _result = IndirectProportionLogic.solveTableAndCurveGraph(
          row1LabelStr: _xLabelCtrl.text,
          row2LabelStr: _yLabelCtrl.text,
          knownXStr: _input1Ctrl.text,
          knownYStr: _input2Ctrl.text,
          tableRow1Csv: _tableRow1Ctrl.text,
          graphQueriesCsv: _graphQueriesCtrl.text,
        );
      } else if (_mode == 2) {
        _result = IndirectProportionLogic.solveCompoundProportion(
          workers1Str: _input1Ctrl.text,
          work1Str: _input2Ctrl.text,
          time1Str: _input3Ctrl.text,
          workers2Str: _input4Ctrl.text,
          work2Str: _input5Ctrl.text,
        );
      } else {
        _result = IndirectProportionLogic.solveConstantSpeedJourney(
          dist1Str: _input1Ctrl.text,
          time1Str: _input2Ctrl.text,
          queryTimeAStr: _input3Ctrl.text,
          queryDistCStr: _input4Ctrl.text,
          queryTimeDStr: _input5Ctrl.text,
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
    const presets = IndirectProportionLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Tables 3.9–3.15, Ex 4–5 & Exercise 3.2 #1–7):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.trending_down,
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
        'label': 'Inverse Unitary Word Problems (Ex 4, 5 & Ex 3.2 #1, #2, #4)',
        'icon': Icons.people_outline,
      },
      {
        'idx': 1,
        'label': 'Indirect Proportion Table & Curve Graph (Fig 3.4 & Ex 3.2 #6, #7)',
        'icon': Icons.show_chart,
      },
      {
        'idx': 2,
        'label': 'Compound Proportion: Men, Trench & Time (Ex 3.2 #3)',
        'icon': Icons.engineering_outlined,
      },
      {
        'idx': 3,
        'label': 'Constant-Speed Multi-Part Journey (Ex 3.2 #5a–d)',
        'icon': Icons.directions_car_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Indirect Proportion Problem Mode:"),
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
                "2. Inverse Unitary Method Word Problem (Examples 4 & 5, Exercise 3.2 #1, #2, #4):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Initial Quantity 1 (x₁)",
                    hint: "e.g. 18, 40, 15, 1, or 10",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _xLabelCtrl,
                    "Unit of x (Optional)",
                    hint: "e.g. farmers, students, boys, km/h",
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
                    "Initial Time / Value 1 (y₁)",
                    hint: "e.g. 20, 6, 12, 48, or 15",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _yLabelCtrl,
                    "Unit of y (Optional)",
                    hint: "e.g. days, weeks, hours",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Target Quantity / Quantities (x₂) (Comma-Separated for a, b, c...)",
              hint: "e.g. 6   or   16, 30, 60   or   9, 12, 18, 45   or   5, 60, 100",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Indirect Proportion Table & Curve Graph (Tables 3.9, 3.11, 3.12, 3.15):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _xLabelCtrl,
                    "Row 1 Label (x-axis)",
                    hint: "e.g. Time (h) or Speed (km/h)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _yLabelCtrl,
                    "Row 2 Label (y-axis)",
                    hint: "e.g. Speed (km/h) or Time (h)",
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
                    "Known Pair: Row 1 (x₀)",
                    hint: "e.g. 1, 90, 800, or 10",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Known Pair: Row 2 (y₀)",
                    hint: "e.g. 120, 2, 20, or 10",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _tableRow1Ctrl,
              "Table Row-1 Values (Comma-Separated — Supports Mixed Fractions!)",
              hint: "e.g. 90, 45, 36, 22 1/2, 18   or   800, 1000, 1600, 3200, 4000",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _graphQueriesCtrl,
              "Follow-Up Graph Queries (Optional: x=... or y=...)",
              hint: "e.g. x=40, y=6   or   x=320, y=25   or   x=30, y=6",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Compound Proportion — Workers, Work/Length & Time (Exercise 3.2 #3):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Initial Workers (M₁)",
                    hint: "e.g. 15 (men)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Initial Trench / Work (W₁)",
                    hint: "e.g. 90 (m)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Initial Time (T₁)",
                    hint: "e.g. 3 (hours)",
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
                    "New Workers (M₂)",
                    hint: "e.g. 16 (men)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "New Trench / Work (W₂)",
                    hint: "e.g. 48 (m)",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Constant-Speed Multi-Part Journey (Exercise 3.2 #5a–d):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Given Distance (km)",
                    hint: "e.g. 175",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Given Time (hours)",
                    hint: "e.g. 3 1/2",
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
                    "a) Find Dist for Time (h)",
                    hint: "e.g. 1 1/2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "c) Find Time for Dist (km)",
                    hint: "e.g. 100",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "d) Find Dist for Time (h)",
                    hint: "e.g. 7 1/2",
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
                    "Snap a photo of any Indirect Proportion table, reciprocal graph, or word problem from JSS 3 Chapter 3 (Pages 37–40, Examples 4–5, or Exercise 3.2 #1–7)!",
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
              labelText: "Indirect Proportion Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. 18 farmers can cultivate a farmland in 20 days. How many days will it take 6 farmers? Or: 15 men can dig a trench of 90 m in 3 hours...",
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
                "Extract & Solve Indirect Proportion",
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
            icon: const Icon(Icons.trending_down, color: Colors.white),
            label: const Text(
              "Solve & Plot Indirect Proportion Graph",
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

  /// Builds the Interactive Visualisation Area where EVERY fraction expression
  /// (axis labels, equations, coordinates, and formula cards) is rendered via Math.tex!
  Widget _buildMathForkVisualisationCanvas(
      IndirectProportionCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    if (cd.visualType == 1) {
      // VisualType 1: Compound Proportion & Constant-Speed Pipeline with Math.tex Cards
      return Container(
        width: canvasWidth,
        height: canvasHeight,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header & Sub-Header rendered via Math.tex
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
            // Top 2 Cards (Initial Quantities & Unit Rate)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.deepPurple.shade300, width: 1.8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          cd.topCard1Title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.topCard1LaTeX,
                            textStyle: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward,
                      color: Colors.deepPurple, size: 24),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: Colors.orange.shade800, width: 1.8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          cd.topCard2Title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.topCard2LaTeX,
                            textStyle: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Middle Formula Bridge Card (Rendered via Math.tex!)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple, width: 1.8),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cd.middleFormulaLaTeX,
                    textStyle: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Final Result Card (Rendered via Math.tex!)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade700, width: 2.2),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cd.bottomResultLaTeX,
                    textStyle: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // VisualType 0: Dual-Mode Millimetre Graph Paper (Fig. 3.4 Curve vs Fig. 3.5 Straight Line)
    // with positioned Math.tex widgets for all fractional equations, axis titles, and coordinates!
    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        children: [
          // 1. Base CustomPaint Layer (Millimetre Grid, Axes, Tick Numbers, Curve/Line, Crosses & Dotted Lines)
          Positioned.fill(
            child: CustomPaint(
              painter: IndirectProportionPainter(
                data: cd,
              ),
            ),
          ),

          // 2. Top Header & Sub-Header Badges (Rendered via Math.tex!)
          Positioned(
            top: 6,
            left: 16,
            right: 16,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cd.headerLaTeX,
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cd.subHeaderLaTeX,
                    textStyle: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Equation Banner Badge Inside Graph Area (Rendered via Math.tex!)
          Positioned(
            top: 62,
            right: 58,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade800, width: 1.8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 3),
                ],
              ),
              child: Math.tex(
                cd.curveEquationLaTeX,
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ),
          ),

          // 4. Vertical Axis Title Badge (Rendered via Math.tex!)
          Positioned(
            top: 56,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Math.tex(
                cd.yAxisLaTeX,
                textStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
            ),
          ),

          // 5. Horizontal Axis Title Badge (Rendered via Math.tex!)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Math.tex(
                  cd.xAxisLaTeX,
                  textStyle: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
              ),
            ),
          ),

          // 6. Trace Reading Badges Inside Graph (Rendered via Math.tex!)
          if (cd.traces.isNotEmpty)
            Positioned(
              bottom: 68,
              right: 58,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Graph Reading: ",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    for (int i = 0; i < cd.traces.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Math.tex(
                        cd.traces[i].badgeLaTeX,
                        textStyle: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // 7. Bottom Summary Banner (Rendered via Math.tex!)
          Positioned(
            bottom: 4,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cd.bottomSummaryLaTeX,
                    textStyle: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
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

    final IndirectProportionCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 435.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Textbook Millimetre Graph Paper (Figure 3.4):",
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
              child: _buildMathForkVisualisationCanvas(
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
                      fontSize: 17.0,
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
          'Indirect Proportion',
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

class IndirectProportionPainter extends CustomPainter {
  final IndirectProportionCanvasData data;

  IndirectProportionPainter({
    required this.data,
  });

  String _fmt(double v, {int maxDecimals = 1}) =>
      IndirectProportionLogic.fmt(v, maxDecimals: maxDecimals);

  @override
  void paint(Canvas canvas, Size size) {
    const double gridLeft = 78.0;
    final double gridRight = size.width - 42.0;
    const double gridTop = 52.0;
    final double gridBottom = size.height - 64.0;
    final Rect plotRect =
    Rect.fromLTRB(gridLeft, gridTop, gridRight, gridBottom);

    // 1. Draw Authentic Textbook Pink/Red Millimetre Graph Paper Grid (Figure 3.4)
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

    final Paint graphLinePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final Paint dottedPaint = Paint()
      ..color = Colors.deepPurple.shade800
      ..strokeWidth = 1.9;

    double maxX = 6.0;
    double maxY = 120.0;

    final List<double> allX = [
      ...data.points.map((p) => p.x),
      ...data.traces.map((t) => t.xVal),
    ];
    final List<double> allY = [
      ...data.points.map((p) => p.y),
      ...data.traces.map((t) => t.yVal),
    ];
    final double minDataX = allX.isEmpty ? 1.0 : allX.reduce(math.min);
    if (allX.isNotEmpty) {
      maxX = math.max(allX.reduce(math.max) * 1.15, 1.0);
    }
    if (allY.isNotEmpty) {
      maxY = math.max(allY.reduce(math.max) * 1.15, 1.0);
    }

    double toPxX(double x) => plotRect.left + (x / maxX) * plotRect.width;
    double toPxY(double y) => plotRect.bottom - (y / maxY) * plotRect.height;

    // Sample smooth hyperbola y = k / x (Figure 3.4)
    final double startX =
    math.max(minDataX * 0.72, data.constantProductK / (maxY * 0.96));
    final double endX = maxX * 0.95;
    final Path curvePath = Path();
    const int samples = 80;
    for (int s = 0; s <= samples; s++) {
      final double xv = startX + (s / samples) * (endX - startX);
      final double yv = data.constantProductK / xv;
      final Offset pt = Offset(toPxX(xv), toPxY(yv));
      if (s == 0) {
        curvePath.moveTo(pt.dx, pt.dy);
      } else {
        curvePath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(curvePath, graphLinePaint);

    // Dotted Graph-Reading Trace Lines
    for (final InverseGraphTrace tr in data.traces) {
      final Offset ptOnCurve = Offset(toPxX(tr.xVal), toPxY(tr.yVal));
      final Offset ptOnX = Offset(toPxX(tr.xVal), plotRect.bottom);
      final Offset ptOnY = Offset(plotRect.left, toPxY(tr.yVal));
      _drawDashedLine(canvas, ptOnX, ptOnCurve, dottedPaint);
      _drawDashedLine(canvas, ptOnCurve, ptOnY, dottedPaint);
      canvas.drawCircle(
        ptOnCurve,
        5.5,
        Paint()..color = Colors.deepPurple.shade800,
      );
    }

    // Plot Cross Markers (×) for Every Table Point
    for (final InversePlotPoint pt in data.points) {
      final Offset pxPt = Offset(toPxX(pt.x), toPxY(pt.y));
      _drawCrossMarker(canvas, pxPt, Colors.black87, size: 5.0);
    }

    canvas.restore();

    // 2. Draw Bold Black Horizontal & Vertical Axes + Tick Numbers Outside Clip
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
      final double px = plotRect.left + (t / 5) * plotRect.width;
      canvas.drawLine(
        Offset(px, plotRect.bottom - 4),
        Offset(px, plotRect.bottom + 4),
        axisPaint,
      );
      _drawText(
        canvas,
        _fmt(xv, maxDecimals: 1),
        px,
        plotRect.bottom + 14,
        fontSize: 10.5,
        isBold: true,
      );

      final double yv = (t / 5) * maxY;
      final double py = plotRect.bottom - (t / 5) * plotRect.height;
      canvas.drawLine(
        Offset(plotRect.left - 4, py),
        Offset(plotRect.left + 4, py),
        axisPaint,
      );
      _drawText(
        canvas,
        _fmt(yv, maxDecimals: 1),
        plotRect.left - 28,
        py,
        fontSize: 10.5,
        isBold: true,
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
  bool shouldRepaint(covariant IndirectProportionPainter oldDelegate) =>
      oldDelegate.data != data;
}