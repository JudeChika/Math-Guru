import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'properties_of_linear_graphs_logic.dart';
import 'properties_of_linear_graphs_models.dart';

class PropertiesOfLinearGraphsScreen extends StatefulWidget {
  const PropertiesOfLinearGraphsScreen({super.key});

  @override
  State<PropertiesOfLinearGraphsScreen> createState() =>
      _PropertiesOfLinearGraphsScreenState();
}

class _PropertiesOfLinearGraphsScreenState
    extends State<PropertiesOfLinearGraphsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Coefficient of x, x- & y-Intercepts & Parallel Through Origin (Table 23.7, Ex 4, Ex 23c #1, #5, #7, #9)
  // 1: Parallel vs. Non-Parallel Line Generator (Ex 23c #2, #3, #4)
  // 2: Multi-Line Parallel Detector & Family Relationship (Fig 23.5, Ex 3, Ex 23c #6, #8)
  // 3: Reverse Graph Reader — Find Equation from 2 Points / Intercepts (Ex 23c #10 / Fig 23.6)

  int _subMode = 0;
  // Mode 1: 0 = Write 3 Parallel Lines, 1 = Write 3 Non-Parallel Lines
  // Mode 3: 0 = Single Line from 2 Points, 1 = Two Lines (Line M & Line N — Fig 23.6)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0 & Mode 1 Controllers
  final TextEditingController _equationCtrl =
  TextEditingController(text: 'y = 4x - 9');
  final TextEditingController _xValuesCtrl =
  TextEditingController(text: '-1, 0, 1, 2, 3');
  bool _drawParallelOrigin = false;
  final TextEditingController _scaleXCtrl = TextEditingController(text: '1');
  final TextEditingController _scaleYCtrl = TextEditingController(text: '5');

  // Mode 2 Controllers (Up to 4 Equations to Compare)
  final List<TextEditingController> _multiEqCtrls = [
    TextEditingController(text: 'y = 4x - 9'),
    TextEditingController(text: '5 + 4x = y'),
    TextEditingController(text: 'y + 4x = 3'),
    TextEditingController(text: '4x = y'),
  ];

  // Mode 3 Controllers (Reverse Graph Reader — Line M & Line N in Fig 23.6)
  final TextEditingController _line1NameCtrl =
  TextEditingController(text: 'Line M');
  final TextEditingController _line1Pt1Ctrl =
  TextEditingController(text: '0;0');
  final TextEditingController _line1Pt2Ctrl =
  TextEditingController(text: '2;2');
  final TextEditingController _line2NameCtrl =
  TextEditingController(text: 'Line N');
  final TextEditingController _line2Pt1Ctrl =
  TextEditingController(text: '0;3');
  final TextEditingController _line2Pt2Ctrl =
  TextEditingController(text: '2;0');

  LinearGraphPropResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _equationCtrl.dispose();
    _xValuesCtrl.dispose();
    _scaleXCtrl.dispose();
    _scaleYCtrl.dispose();
    for (final c in _multiEqCtrls) {
      c.dispose();
    }
    _line1NameCtrl.dispose();
    _line1Pt1Ctrl.dispose();
    _line1Pt2Ctrl.dispose();
    _line2NameCtrl.dispose();
    _line2Pt1Ctrl.dispose();
    _line2Pt2Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(LinearGraphPropPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _equationCtrl.text = p.equationStr;
      _xValuesCtrl.text = p.xValuesCsv;
      _drawParallelOrigin = p.drawParallelOrigin;
      _scaleXCtrl.text = p.scaleXStr;
      _scaleYCtrl.text = p.scaleYStr;

      if (p.multiEquations.isNotEmpty) {
        for (int i = 0; i < _multiEqCtrls.length; i++) {
          _multiEqCtrls[i].text =
          i < p.multiEquations.length ? p.multiEquations[i] : '';
        }
      }

      _line1NameCtrl.text = p.line1Name;
      _line1Pt1Ctrl.text = p.line1Pt1;
      _line1Pt2Ctrl.text = p.line1Pt2;
      _line2NameCtrl.text = p.line2Name;
      _line2Pt1Ctrl.text = p.line2Pt1;
      _line2Pt2Ctrl.text = p.line2Pt2;
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
              'Please enter a linear graph question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS2 Section 23-2: Properties of Linear Graphs.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Finding the Coefficient of x, x-intercept, y-intercept, and optionally a parallel line through the origin (Table 23.7, Example 4, Exercise 23c #1, #5, #7, #9).
        1 for Writing equations of lines PARALLEL (subMode 0) or NOT PARALLEL (subMode 1) to a given line (Exercise 23c #2, #3, #4).
        2 for Comparing 2 to 4 equations to determine which lines are parallel and finding their intercepts (Figure 23.5, Example 3, Exercise 23c #6, #8).
        3 for Finding the equation(s) of straight line(s) from 2 points read off a graph (subMode 0 for 1 line, subMode 1 for 2 lines like Line M and Line N in Figure 23.6 / Exercise 23c #10).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "equationStr": "y = 4x - 9",
        "xValuesCsv": "-1, 0, 1, 2, 3",
        "drawParallelOrigin": false,
        "scaleXStr": "1",
        "scaleYStr": "5",
        "multiEquations": ["y = 4x - 9", "5 + 4x = y", "y + 4x = 3", "4x = y"],
        "line1Name": "Line M",
        "line1Pt1": "0;0",
        "line1Pt2": "2;2",
        "line2Name": "Line N",
        "line2Pt1": "0;3",
        "line2Pt2": "2;0"
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
        if (jsonMap['equationStr'] != null) {
          _equationCtrl.text = jsonMap['equationStr'].toString();
        }
        if (jsonMap['xValuesCsv'] != null) {
          _xValuesCtrl.text = jsonMap['xValuesCsv'].toString();
        }
        _drawParallelOrigin = jsonMap['drawParallelOrigin'] == true;
        if (jsonMap['scaleXStr'] != null) {
          _scaleXCtrl.text = jsonMap['scaleXStr'].toString();
        }
        if (jsonMap['scaleYStr'] != null) {
          _scaleYCtrl.text = jsonMap['scaleYStr'].toString();
        }
        if (jsonMap['multiEquations'] is List) {
          final List eqs = jsonMap['multiEquations'] as List;
          for (int i = 0; i < _multiEqCtrls.length; i++) {
            _multiEqCtrls[i].text = i < eqs.length ? eqs[i].toString() : '';
          }
        }
        if (jsonMap['line1Name'] != null) {
          _line1NameCtrl.text = jsonMap['line1Name'].toString();
        }
        if (jsonMap['line1Pt1'] != null) {
          _line1Pt1Ctrl.text = jsonMap['line1Pt1'].toString();
        }
        if (jsonMap['line1Pt2'] != null) {
          _line1Pt2Ctrl.text = jsonMap['line1Pt2'].toString();
        }
        if (jsonMap['line2Name'] != null) {
          _line2NameCtrl.text = jsonMap['line2Name'].toString();
        }
        if (jsonMap['line2Pt1'] != null) {
          _line2Pt1Ctrl.text = jsonMap['line2Pt1'].toString();
        }
        if (jsonMap['line2Pt2'] != null) {
          _line2Pt2Ctrl.text = jsonMap['line2Pt2'].toString();
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
        _result = PropertiesOfLinearGraphsLogic.solvePropertiesAndIntercepts(
          equationStr: _equationCtrl.text,
          xValuesCsv: _xValuesCtrl.text,
          drawParallelOrigin: _drawParallelOrigin,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else if (_mode == 1) {
        _result = PropertiesOfLinearGraphsLogic.solveParallelGenerator(
          subMode: _subMode,
          equationStr: _equationCtrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else if (_mode == 2) {
        _result = PropertiesOfLinearGraphsLogic.solveMultiLineInspector(
          equationStrings: _multiEqCtrls.map((c) => c.text).toList(),
          xValuesCsv: _xValuesCtrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else {
        _result = PropertiesOfLinearGraphsLogic.solveEquationFromGraphPoints(
          subMode: _subMode,
          line1Name: _line1NameCtrl.text,
          line1Pt1Str: _line1Pt1Ctrl.text,
          line1Pt2Str: _line1Pt2Ctrl.text,
          line2Name: _line2NameCtrl.text,
          line2Pt1Str: _line2Pt1Ctrl.text,
          line2Pt2Str: _line2Pt2Ctrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
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
    const presets = PropertiesOfLinearGraphsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Quick-Load Textbook Examples & Exercise 23c (#1–10):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.auto_stories,
                      size: 15, color: Colors.deepPurple),
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
        'label': 'Coeff of x & Intercepts',
        'icon': Icons.functions,
      },
      {
        'idx': 1,
        'label': 'Write Parallel / Non-Parallel',
        'icon': Icons.alt_route,
      },
      {
        'idx': 2,
        'label': 'Compare Parallel Lines',
        'icon': Icons.stacked_line_chart,
      },
      {
        'idx': 3,
        'label': 'Find Equation from Graph (Fig 23.6)',
        'icon': Icons.timeline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Linear Graph Property Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            final IconData iconData =
            idx == 0 ? Icons.functions : (m['icon'] as IconData);
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

  Widget _buildScaleRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Cartesian Graph Scale (Units per 2 cm Major Block):",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _scaleXCtrl,
                "x-Axis: 2 cm to ___ unit(s)",
                hint: "e.g. 1",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                _scaleYCtrl,
                "y-Axis: 2 cm to ___ unit(s)",
                hint: "e.g. 5 or 1",
              ),
            ),
          ],
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
                "2. Enter Linear Equation (Table 23.7, Example 4 & Ex 23c #1, #5, #7, #9):"),
            const SizedBox(height: 10),
            _buildTextField(
              _equationCtrl,
              "Linear Equation (Any Form, Including Brackets)",
              hint: "e.g. y = 4x - 9, 10x + y = 3, y = 2 - x, or y = 1/2(x + 4)",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _xValuesCtrl,
              "Values of x for Table of Values",
              hint: "e.g. -2, -1, 0, 1, 2, 3, 4",
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Also Draw Parallel Line Through the Origin (0;0) (Ex 23c #7b)",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: _drawParallelOrigin,
                  activeColor: Colors.deepPurple,
                  onChanged: (v) => setState(() => _drawParallelOrigin = v),
                ),
              ],
            ),
            _buildScaleRow(),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Write Parallel or Non-Parallel Lines (Ex 23c #2, #3, #4):"),
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
                      "Write 3 PARALLEL Lines\n(Same m — Ex 23c #2 & #4)",
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
                      "Write 3 NON-PARALLEL Lines\n(Different m — Ex 23c #3)",
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
            _buildTextField(
              _equationCtrl,
              "Given Reference Equation",
              hint: "e.g. y = 2x - 5, y = 4x - 7, or 5x + 2y - 6 = 0",
            ),
            _buildScaleRow(),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter 2 to 4 Equations to Check Parallelism & Intercepts (Ex 3 & Ex 23c #6, #8):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[0],
                    "Equation (a) (Purple)",
                    hint: "e.g. y = 4x - 9",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[1],
                    "Equation (b) (Green)",
                    hint: "e.g. 5 + 4x = y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[2],
                    "Equation (c) (Orange, Optional)",
                    hint: "e.g. y + 4x = 3",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[3],
                    "Equation (d) (Blue, Optional)",
                    hint: "e.g. 4x = y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _xValuesCtrl,
              "Values of x for Plotting",
              hint: "e.g. -3, -2, -1, 0, 1, 2, 3",
            ),
            _buildScaleRow(),
          ] else ...[
            _buildSectionTitle(
                "2. Find Equation(s) of Line(s) from 2 Graph Points (Ex 23c #10 / Fig 23.6):"),
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
                      "Single Line from 2 Points",
                      textAlign: TextAlign.center,
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
                      "Two Lines (Line M & Line N)\n(Figure 23.6 Challenge)",
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
                  flex: 2,
                  child: _buildTextField(
                    _line1NameCtrl,
                    "Line 1 Name",
                    hint: "Line M",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _line1Pt1Ctrl,
                    "Point 1 (x;y)",
                    hint: "0;0",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _line1Pt2Ctrl,
                    "Point 2 (x;y)",
                    hint: "2;2",
                  ),
                ),
              ],
            ),
            if (_subMode == 1) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      _line2NameCtrl,
                      "Line 2 Name",
                      hint: "Line N",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      _line2Pt1Ctrl,
                      "Point 1 (x;y)",
                      hint: "0;3",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      _line2Pt2Ctrl,
                      "Point 2 (x;y)",
                      hint: "2;0",
                    ),
                  ),
                ],
              ),
            ],
            _buildScaleRow(),
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
                    "Snap a photo of any parallel-line, x/y-intercept, or graph equation question from Exercise 23c, and the AI will solve and plot it step-by-step!",
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
              labelText: "Linear Graph Property Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Find the x- and y-intercepts of y = 4x - 9, or find which of y = 4x - 9, 5 + 4x = y, y + 4x = 3, 4x = y are parallel...",
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
                "Extract & Analyze Linear Graph",
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
            icon: const Icon(Icons.grid_on, color: Colors.white),
            label: const Text(
              "Analyze Properties & Plot Graph",
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

    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 460.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive 4-Quadrant Cartesian Graph Paper:",
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
          height: 440,
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
              boundaryMargin: const EdgeInsets.all(160),
              minScale: 0.35,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: PropertiesCartesianPainter(
                    data: _result!.canvasData,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "2. Final Answers (Coefficient of x, Intercepts & Equations):",
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
          "3. Mathematical Workings:",
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
          'Properties of Linear Graphs',
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

class PropertiesCartesianPainter extends CustomPainter {
  final PropCartesianCanvasData data;

  PropertiesCartesianPainter({required this.data});

  String _fmt(double v) =>
      PropertiesOfLinearGraphsLogic.fmt(v, maxDecimals: 2);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Header Banner & Scale Note
    _drawText(
      canvas,
      data.headerBadge,
      size.width / 2,
      18,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.scaleBannerText,
      size.width / 2,
      36,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );

    const double gridLeft = 45.0;
    final double gridRight = size.width - 45.0;
    const double gridTop = 52.0;
    final double gridBottom = size.height - 24.0;
    final Rect plotRect =
    Rect.fromLTRB(gridLeft, gridTop, gridRight, gridBottom);

    // 2. Determine Data Bounds Across Plotted Points & Intercepts
    double minX = -3.0;
    double maxX = 4.0;
    double minY = -10.0;
    double maxY = 10.0;

    final List<Offset> allCoords = [const Offset(0, 0)];
    for (final series in data.lines) {
      for (final pt in series.points) {
        allCoords.add(Offset(pt.x, pt.y));
      }
      if (!series.isVertical) {
        allCoords.add(Offset(0, series.evaluateY(0)));
        allCoords.add(Offset(-2, series.evaluateY(-2)));
        allCoords.add(Offset(2, series.evaluateY(2)));
      }
      if (!series.isHorizontal) {
        final double xInt = series.evaluateX(0);
        if (xInt.abs() <= 20) {
          allCoords.add(Offset(xInt, 0));
        }
      }
    }
    for (final ic in data.highlightIntercepts) {
      allCoords.add(Offset(ic.x, ic.y));
    }

    if (allCoords.length > 1) {
      minX = allCoords.map((p) => p.dx).reduce(math.min);
      maxX = allCoords.map((p) => p.dx).reduce(math.max);
      minY = allCoords.map((p) => p.dy).reduce(math.min);
      maxY = allCoords.map((p) => p.dy).reduce(math.max);
    }

    final double sx = math.max(data.scaleXUnitsPer2Cm, 0.5);
    final double sy = math.max(data.scaleYUnitsPer2Cm, 0.5);

    minX = ((minX / sx).floor() - 1) * sx;
    maxX = ((maxX / sx).ceil() + 1) * sx;
    minY = ((minY / sy).floor() - 1) * sy;
    maxY = ((maxY / sy).ceil() + 1) * sy;

    if (minX > -sx) minX = -sx;
    if (maxX < sx) maxX = sx;
    if (minY > -sy) minY = -sy;
    if (maxY < sy) maxY = sy;

    final double xBlocks = (maxX - minX) / sx;
    final double yBlocks = (maxY - minY) / sy;

    double toPxX(double x) =>
        plotRect.left + ((x - minX) / (maxX - minX)) * plotRect.width;
    double toPxY(double y) =>
        plotRect.bottom - ((y - minY) / (maxY - minY)) * plotRect.height;

    canvas.save();
    canvas.clipRect(plotRect);

    final Paint minorGridPaint = Paint()
      ..color = Colors.green.shade100.withOpacity(0.65)
      ..strokeWidth = 0.8;
    final Paint majorGridPaint = Paint()
      ..color = Colors.green.shade400.withOpacity(0.75)
      ..strokeWidth = 1.3;

    final int totalMinorX = (xBlocks * 10).round().clamp(10, 400);
    for (int i = 0; i <= totalMinorX; i++) {
      final double xVal = minX + (i / 10.0) * sx;
      final double px = toPxX(xVal);
      final bool isMajor = i % 10 == 0;
      canvas.drawLine(
        Offset(px, plotRect.top),
        Offset(px, plotRect.bottom),
        isMajor ? majorGridPaint : minorGridPaint,
      );
    }

    final int totalMinorY = (yBlocks * 10).round().clamp(10, 400);
    for (int j = 0; j <= totalMinorY; j++) {
      final double yVal = minY + (j / 10.0) * sy;
      final double py = toPxY(yVal);
      final bool isMajor = j % 10 == 0;
      canvas.drawLine(
        Offset(plotRect.left, py),
        Offset(plotRect.right, py),
        isMajor ? majorGridPaint : minorGridPaint,
      );
    }

    final double originX = toPxX(0.0);
    final double originY = toPxY(0.0);

    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.2;

    canvas.drawLine(
      Offset(plotRect.left, originY),
      Offset(plotRect.right, originY),
      axisPaint,
    );
    canvas.drawLine(
      Offset(originX, plotRect.top),
      Offset(originX, plotRect.bottom),
      axisPaint,
    );

    _drawArrowHead(
        canvas, Offset(plotRect.right - 2, originY), 0, Colors.black87);
    _drawArrowHead(
        canvas, Offset(plotRect.left + 2, originY), math.pi, Colors.black87);
    _drawArrowHead(
        canvas, Offset(originX, plotRect.top + 2), -math.pi / 2, Colors.black87);
    _drawArrowHead(
        canvas, Offset(originX, plotRect.bottom - 2), math.pi / 2, Colors.black87);

    _drawText(canvas, "0", originX - 10, originY + 12,
        fontSize: 12, isBold: true);
    _drawText(canvas, "x", plotRect.right - 12, originY + 15,
        fontSize: 13.5, isBold: true);
    _drawText(canvas, "y", originX - 14, plotRect.top + 12,
        fontSize: 13.5, isBold: true);

    final int startBlockX = (minX / sx).round();
    final int endBlockX = (maxX / sx).round();
    for (int k = startBlockX + 1; k < endBlockX; k++) {
      if (k == 0) continue;
      final double xVal = k * sx;
      final double px = toPxX(xVal);
      canvas.drawLine(
          Offset(px, originY - 4), Offset(px, originY + 4), axisPaint);
      _drawText(canvas, _fmt(xVal), px, originY + 14,
          fontSize: 11, isBold: true);
    }

    final int startBlockY = (minY / sy).round();
    final int endBlockY = (maxY / sy).round();
    for (int k = startBlockY + 1; k < endBlockY; k++) {
      if (k == 0) continue;
      final double yVal = k * sy;
      final double py = toPxY(yVal);
      canvas.drawLine(
          Offset(originX - 4, py), Offset(originX + 4, py), axisPaint);
      _drawText(canvas, _fmt(yVal), originX - 18, py,
          fontSize: 11, isBold: true);
    }

    for (int sIdx = 0; sIdx < data.lines.length; sIdx++) {
      final PropLineSeries series = data.lines[sIdx];
      final Paint linePaint = Paint()
        ..color = series.color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;

      Offset pStart;
      Offset pEnd;
      if (series.isVertical) {
        final double xConst = -series.c / series.a;
        pStart = Offset(toPxX(xConst), plotRect.top);
        pEnd = Offset(toPxX(xConst), plotRect.bottom);
      } else {
        final double yAtMinX = series.evaluateY(minX);
        final double yAtMaxX = series.evaluateY(maxX);
        pStart = Offset(toPxX(minX), toPxY(yAtMinX));
        pEnd = Offset(toPxX(maxX), toPxY(yAtMaxX));
      }

      if (series.isDashed) {
        _drawDashedLine(canvas, pStart, pEnd, linePaint);
      } else {
        canvas.drawLine(pStart, pEnd, linePaint);
      }

      final double tLabel = 0.24 + (sIdx * 0.17).clamp(0.0, 0.55);
      final double lx = pStart.dx + (pEnd.dx - pStart.dx) * tLabel;
      final double ly = pStart.dy + (pEnd.dy - pStart.dy) * tLabel;
      _drawBadge(
        canvas,
        series.equationLabel,
        lx.clamp(plotRect.left + 65, plotRect.right - 65),
        (ly - 14).clamp(plotRect.top + 18, plotRect.bottom - 18),
        series.color,
      );

      for (final PropPlottedPoint pt in series.points) {
        final Offset pxPt = Offset(toPxX(pt.x), toPxY(pt.y));
        _drawCrossMarker(canvas, pxPt, Colors.black87, size: 5.5);
        if (data.lines.length <= 2) {
          _drawText(
            canvas,
            pt.label,
            (pxPt.dx + 32).clamp(plotRect.left + 35, plotRect.right - 35),
            (pxPt.dy - 10).clamp(plotRect.top + 14, plotRect.bottom - 14),
            fontSize: 10.5,
            isBold: true,
            color: series.color,
          );
        }
      }
    }

    // Highlight x- and y-intercepts with bold orange markers
    for (int i = 0; i < data.highlightIntercepts.length; i++) {
      final PropPlottedPoint ic = data.highlightIntercepts[i];
      final Offset pxIc = Offset(toPxX(ic.x), toPxY(ic.y));
      canvas.drawCircle(pxIc, 6.0, Paint()..color = Colors.orange.shade800);
      canvas.drawCircle(
        pxIc,
        6.0,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );
      if (data.lines.length == 1) {
        _drawBadge(
          canvas,
          ic.label,
          (pxIc.dx + 52).clamp(plotRect.left + 55, plotRect.right - 55),
          (pxIc.dy + (i.isEven ? 16 : -16))
              .clamp(plotRect.top + 16, plotRect.bottom - 16),
          Colors.orange.shade900,
        );
      }
    }

    canvas.restore();
  }

  void _drawCrossMarker(
      Canvas canvas,
      Offset center,
      Color color, {
        double size = 5.0,
      }) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.2;
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

  void _drawArrowHead(
      Canvas canvas, Offset tip, double angleRad, Color color) {
    const double len = 9.0;
    const double wing = 0.45;
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

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double dist = (p2 - p1).distance;
    if (dist < 2) return;
    const double dashW = 6.0;
    const double gapW = 4.0;
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 300);
    final double dx = (p2.dx - p1.dx) / count;
    final double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      final double sx = p1.dx + i * dx;
      final double sy = p1.dy + i * dy;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + dx * 0.6, sy + dy * 0.6),
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
      width: tp.width + 12,
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
  bool shouldRepaint(covariant PropertiesCartesianPainter oldDelegate) =>
      oldDelegate.data != data;
}