import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'linear_equations_graphs_logic.dart';
import 'linear_equations_graphs_models.dart';

class LinearEquationsGraphsScreen extends StatefulWidget {
  const LinearEquationsGraphsScreen({super.key});

  @override
  State<LinearEquationsGraphsScreen> createState() =>
      _LinearEquationsGraphsScreenState();
}

class _LinearEquationsGraphsScreenState
    extends State<LinearEquationsGraphsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Explicit Equation y = mx + c & Graph Reader (Tables 23.1–23.5, Ex 1, Ex 23a #2–4)
  // 1: General Form ax + by + c = 0 (Example 2, Table 23.6, Fig 23.4, Ex 23b #1–10)
  // 2: Point Inspector & Missing Coordinates (Ex 23a #1 / Fig 23.3 & Ex 23a #5)
  // 3: Multi-Line Comparator (Ex 23a #6 Parallel, #7 Common Intercept, #8 Intersection)

  int _subMode = 0; // For Mode 2: 0 = Spot Wrong Point (Ex 23a #1), 1 = Find a,b,c (Ex 23a #5)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Shared Equation, x-Values & Scale Controllers
  final TextEditingController _equationCtrl =
  TextEditingController(text: 'y = 4x - 7');
  final TextEditingController _xValuesCtrl =
  TextEditingController(text: '-3, -2, -1, 0, 1, 2, 3');
  final TextEditingController _queryXCtrl =
  TextEditingController(text: '2.5');
  final TextEditingController _queryYCtrl =
  TextEditingController(text: '-13');
  final TextEditingController _scaleXCtrl = TextEditingController(text: '1');
  final TextEditingController _scaleYCtrl = TextEditingController(text: '5');

  // Mode 2 Controllers (Point A, B, C Inspector)
  final TextEditingController _ptACtrl = TextEditingController(text: '-3;-5');
  final TextEditingController _ptBCtrl = TextEditingController(text: '-1;1');
  final TextEditingController _ptCCtrl = TextEditingController(text: '3;5');

  // Mode 3 Controllers (Multi-Line Comparator)
  final List<TextEditingController> _multiEqCtrls = [
    TextEditingController(text: 'y = 2x + 5'),
    TextEditingController(text: 'y = 2x - 1'),
    TextEditingController(text: 'y = 2x'),
    TextEditingController(text: 'y = 2x - 3'),
  ];

  LinearEqGraphResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _equationCtrl.dispose();
    _xValuesCtrl.dispose();
    _queryXCtrl.dispose();
    _queryYCtrl.dispose();
    _scaleXCtrl.dispose();
    _scaleYCtrl.dispose();
    _ptACtrl.dispose();
    _ptBCtrl.dispose();
    _ptCCtrl.dispose();
    for (final c in _multiEqCtrls) {
      c.dispose();
    }
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(LinearEqGraphPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _equationCtrl.text = p.equationStr;
      _xValuesCtrl.text = p.xValuesCsv;
      _queryXCtrl.text = p.queryXStr;
      _queryYCtrl.text = p.queryYStr;
      _scaleXCtrl.text = p.scaleXStr;
      _scaleYCtrl.text = p.scaleYStr;
      _ptACtrl.text = p.pointAStr;
      _ptBCtrl.text = p.pointBStr;
      _ptCCtrl.text = p.pointCStr;

      if (p.multiEquations.isNotEmpty) {
        for (int i = 0; i < _multiEqCtrls.length; i++) {
          _multiEqCtrls[i].text =
          i < p.multiEquations.length ? p.multiEquations[i] : '';
        }
      }
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
      You are a strict JSON data extractor for JSS2 Section 23-1: Linear Equations and Graphs.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Explicit Linear Equation Grapher (y = mx + c or y = c - mx, Tables 23.1–23.5, Example 1, Exercise 23a #2–4).
        1 for General Form Linear Equation Grapher (ax + by + c = 0 or ax + by = d, Example 2, Exercise 23b #1–10).
        2 for Point Inspector (subMode 0: Check plotted points A, B, C for mistakes like Exercise 23a #1 / Fig 23.3; subMode 1: Calculate unknown coordinates A(-3;a), B(0;b), C(3;c) like Exercise 23a #5).
        3 for Multi-Line Comparator (Drawing 2 to 4 equations on the same axes to check parallel lines, common y-intercept, or intersection point, like Exercise 23a #6, #7, #8).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "equationStr": "y = 4x - 7",
        "xValuesCsv": "-3, -2, -1, 0, 1, 2, 3",
        "queryXStr": "2.5",
        "queryYStr": "-13",
        "scaleXStr": "1",
        "scaleYStr": "5",
        "pointAStr": "-3;-5",
        "pointBStr": "-1;1",
        "pointCStr": "3;5",
        "multiEquations": ["y = 2x + 5", "y = 2x - 1", "y = 2x", "y = 2x - 3"]
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
        if (jsonMap['queryXStr'] != null) {
          _queryXCtrl.text = jsonMap['queryXStr'].toString();
        }
        if (jsonMap['queryYStr'] != null) {
          _queryYCtrl.text = jsonMap['queryYStr'].toString();
        }
        if (jsonMap['scaleXStr'] != null) {
          _scaleXCtrl.text = jsonMap['scaleXStr'].toString();
        }
        if (jsonMap['scaleYStr'] != null) {
          _scaleYCtrl.text = jsonMap['scaleYStr'].toString();
        }
        if (jsonMap['pointAStr'] != null) {
          _ptACtrl.text = jsonMap['pointAStr'].toString();
        }
        if (jsonMap['pointBStr'] != null) {
          _ptBCtrl.text = jsonMap['pointBStr'].toString();
        }
        if (jsonMap['pointCStr'] != null) {
          _ptCCtrl.text = jsonMap['pointCStr'].toString();
        }
        if (jsonMap['multiEquations'] is List) {
          final List eqs = jsonMap['multiEquations'] as List;
          for (int i = 0; i < _multiEqCtrls.length; i++) {
            _multiEqCtrls[i].text = i < eqs.length ? eqs[i].toString() : '';
          }
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
        _result = LinearEquationsGraphsLogic.solveExplicitEquation(
          equationStr: _equationCtrl.text,
          xValuesCsv: _xValuesCtrl.text,
          queryXStr: _queryXCtrl.text,
          queryYStr: _queryYCtrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else if (_mode == 1) {
        _result = LinearEquationsGraphsLogic.solveGeneralFormEquation(
          equationStr: _equationCtrl.text,
          xValuesCsv: _xValuesCtrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else if (_mode == 2) {
        _result = LinearEquationsGraphsLogic.solvePointInspector(
          subMode: _subMode,
          equationStr: _equationCtrl.text,
          pointAStr: _ptACtrl.text,
          pointBStr: _ptBCtrl.text,
          pointCStr: _ptCCtrl.text,
          xValuesCsv: _xValuesCtrl.text,
          scaleXStr: _scaleXCtrl.text,
          scaleYStr: _scaleYCtrl.text,
        );
      } else {
        _result = LinearEquationsGraphsLogic.solveMultiLineComparator(
          equationStrings: _multiEqCtrls.map((c) => c.text).toList(),
          xValuesCsv: _xValuesCtrl.text,
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

  // ===========================================================================
  // REUSABLE UI WIDGET HELPERS
  // ===========================================================================
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
    const presets = LinearEquationsGraphsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick-Load Textbook Tables, Figures & Exercises:"),
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
        'label': 'Explicit Graph (y = mx + c)',
        'icon': Icons.show_chart,
      },
      {
        'idx': 1,
        'label': 'General Form (ax + by + c = 0)',
        'icon': Icons.functions,
      },
      {
        'idx': 2,
        'label': 'Point Inspector (A, B, C)',
        'icon': Icons.fact_check_outlined,
      },
      {
        'idx': 3,
        'label': 'Multi-Line Family & Meet',
        'icon': Icons.stacked_line_chart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Linear Graph Problem Mode:"),
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
                if (idx == 1 && !_equationCtrl.text.contains('y')) {
                  _equationCtrl.text = '5x + 2y - 6 = 0';
                }
              }),
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
                hint: "e.g. 1 or 2",
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
                "2. Enter Linear Equation (y = mx + c) & Table x-Values:"),
            const SizedBox(height: 10),
            _buildTextField(
              _equationCtrl,
              "Linear Equation in x and y",
              hint: "e.g. y = 4x - 7, y = 2x - 5, or y = 7 - 3x",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _xValuesCtrl,
              "Values of x for Table of Values (Comma-Separated or Range)",
              hint: "e.g. -3, -2, -1, 0, 1, 2, 3 or -3, 0, 3",
            ),
            const SizedBox(height: 12),
            const Text(
              "Optional Graph Readings (Example 1a & 1b — Dotted Trace Lines):",
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
                    _queryXCtrl,
                    "a) Find y when x = ___",
                    hint: "e.g. 2.5 (or blank)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _queryYCtrl,
                    "b) Find x when y = ___",
                    hint: "e.g. -13 (or blank)",
                  ),
                ),
              ],
            ),
            _buildScaleRow(),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter General Form Equation (ax + by + c = 0 or ax + by = d):"),
            const SizedBox(height: 10),
            _buildTextField(
              _equationCtrl,
              "General Linear Equation (Example 2 & Exercise 23b)",
              hint: "e.g. 5x + 2y - 6 = 0 or 4x - 3y = 5",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _xValuesCtrl,
              "Chosen Values of x (At Least 3 Points)",
              hint: "e.g. -2, 0, 2",
            ),
            _buildScaleRow(),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Select Point Inspector Sub-Mode (Ex 23a #1 & #5):"),
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
                      "Spot Wrong Point A,B,C\n(Ex 23a #1 / Fig 23.3)",
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
                      "Find Unknowns a, b, c\n(Ex 23a #5: A, B, C)",
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
              "Equation of the Straight Line",
              hint: _subMode == 0 ? "e.g. y = x - 2" : "e.g. y = 5x - 2",
            ),
            const SizedBox(height: 10),
            if (_subMode == 0) ...[
              const Text(
                "Enter Student's Plotted Coordinates (x;y):",
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
                      _ptACtrl,
                      "Point A (x;y)",
                      hint: "-3;-5",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _ptBCtrl,
                      "Point B (x;y)",
                      hint: "-1;1",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _ptCCtrl,
                      "Point C (x;y)",
                      hint: "3;5",
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildTextField(
                _xValuesCtrl,
                "Given x-Coordinates for Points A, B, C",
                hint: "e.g. -3, 0, 3",
              ),
            ],
            _buildScaleRow(),
          ] else ...[
            _buildSectionTitle(
                "2. Enter 2 to 4 Linear Equations to Draw on the Same Axes:"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[0],
                    "Line 1 (Purple)",
                    hint: "e.g. y = 2x + 5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[1],
                    "Line 2 (Green)",
                    hint: "e.g. y = 2x - 1",
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
                    "Line 3 (Orange, Optional)",
                    hint: "e.g. y = 2x",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _multiEqCtrls[3],
                    "Line 4 (Blue, Optional)",
                    hint: "e.g. y = 2x - 3",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _xValuesCtrl,
              "Values of x (e.g. -3 to +3)",
              hint: "-3, -2, -1, 0, 1, 2, 3",
            ),
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
                    "Snap a photo of any table of values, Cartesian graph, or linear equation question from Section 23-1 (Exercises 23a & 23b)!",
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
              labelText: "Linear Equation or Graph Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Draw the graph of y = 4x - 7 for values of x from -3 to +3. Find y when x = 2.5 and x when y = -13...",
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
                "Extract & Plot Linear Graph",
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
              "Build Table of Values & Plot Graph",
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
                  painter: CartesianLinearGraphPainter(
                    data: _result!.canvasData,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "2. Final Answers & Intercepts:",
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
          "3. Mathematical Workings & Table of Values:",
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
          'Linear Equations & Graphs',
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

// =============================================================================
// CUSTOM PAINTER: 4-QUADRANT CARTESIAN MILLIMETRE GRAPH PAPER (Figs 23.1–23.5)
// =============================================================================
class CartesianLinearGraphPainter extends CustomPainter {
  final CartesianCanvasData data;

  CartesianLinearGraphPainter({required this.data});

  String _fmt(double v) => LinearEquationsGraphsLogic.fmt(v, maxDecimals: 1);

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

    // 2. Determine Data Bounds Across All Plotted Points, Traces & Intercepts
    double minX = -3.0;
    double maxX = 3.0;
    double minY = -10.0;
    double maxY = 10.0;

    final List<Offset> allCoords = [const Offset(0, 0)];
    for (final series in data.lines) {
      for (final pt in series.points) {
        allCoords.add(Offset(pt.x, pt.y));
        if (pt.correctedY != null) {
          allCoords.add(Offset(pt.x, pt.correctedY!));
        }
      }
    }
    for (final tr in data.traces) {
      allCoords.add(Offset(tr.xVal, tr.yVal));
    }
    if (data.xIntercept != null) {
      allCoords.add(Offset(data.xIntercept!.x, data.xIntercept!.y));
    }
    if (data.yIntercept != null) {
      allCoords.add(Offset(data.yIntercept!.x, data.yIntercept!.y));
    }
    if (data.intersectionPoint != null) {
      allCoords.add(
          Offset(data.intersectionPoint!.x, data.intersectionPoint!.y));
    }

    if (allCoords.length > 1) {
      minX = allCoords.map((p) => p.dx).reduce(math.min);
      maxX = allCoords.map((p) => p.dx).reduce(math.max);
      minY = allCoords.map((p) => p.dy).reduce(math.min);
      maxY = allCoords.map((p) => p.dy).reduce(math.max);
    }

    final double sx = math.max(data.scaleXUnitsPer2Cm, 0.5);
    final double sy = math.max(data.scaleYUnitsPer2Cm, 0.5);

    // Pad by 1 major block on each side and snap to major scale multiples
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

    final double blockPxX = plotRect.width / math.max(xBlocks, 2.0);
    final double blockPxY = plotRect.height / math.max(yBlocks, 2.0);

    double toPxX(double x) =>
        plotRect.left + ((x - minX) / (maxX - minX)) * plotRect.width;
    double toPxY(double y) =>
        plotRect.bottom - ((y - minY) / (maxY - minY)) * plotRect.height;

    // 3. Draw Authentic Green Millimetre/Centimetre Graph Paper Grid
    canvas.save();
    canvas.clipRect(plotRect);

    final Paint minorGridPaint = Paint()
      ..color = Colors.green.shade100.withOpacity(0.65)
      ..strokeWidth = 0.8;
    final Paint majorGridPaint = Paint()
      ..color = Colors.green.shade400.withOpacity(0.75)
      ..strokeWidth = 1.3;

    // Vertical grid lines (10 minor subdivisions per major block)
    final int totalMinorX = (xBlocks * 10).round();
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

    // Horizontal grid lines (10 minor subdivisions per major block)
    final int totalMinorY = (yBlocks * 10).round();
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

    // 4. Draw Bold Black Cartesian Axes (x-axis and y-axis with arrowheads)
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

    // Axis Arrowheads (both ends, matching Figures 23.1–23.5)
    _drawArrowHead(canvas, Offset(plotRect.right - 2, originY), 0, Colors.black87);
    _drawArrowHead(
        canvas, Offset(plotRect.left + 2, originY), math.pi, Colors.black87);
    _drawArrowHead(
        canvas, Offset(originX, plotRect.top + 2), -math.pi / 2, Colors.black87);
    _drawArrowHead(
        canvas, Offset(originX, plotRect.bottom - 2), math.pi / 2, Colors.black87);

    // Origin '0' and Axis Letters 'x' and 'y'
    _drawText(canvas, "0", originX - 10, originY + 12,
        fontSize: 12, isBold: true);
    _drawText(canvas, "x", plotRect.right - 12, originY + 15,
        fontSize: 13.5, isBold: true);
    _drawText(canvas, "y", originX - 14, plotRect.top + 12,
        fontSize: 13.5, isBold: true);

    // Axis Tick Numbers along Major Blocks
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

    // 5. Draw Extended Straight Lines & Plotted Cross Markers (+)
    for (int sIdx = 0; sIdx < data.lines.length; sIdx++) {
      final LineSeriesData series = data.lines[sIdx];
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

      canvas.drawLine(pStart, pEnd, linePaint);

      // Label the equation along the line
      final double tLabel = 0.25 + (sIdx * 0.16).clamp(0.0, 0.55);
      final double lx = pStart.dx + (pEnd.dx - pStart.dx) * tLabel;
      final double ly = pStart.dy + (pEnd.dy - pStart.dy) * tLabel;
      _drawBadge(
        canvas,
        series.equationLabel,
        lx.clamp(plotRect.left + 55, plotRect.right - 55),
        (ly - 14).clamp(plotRect.top + 16, plotRect.bottom - 16),
        series.color,
      );

      // Draw each plotted point from the Table of Values
      for (final PlottedPointData pt in series.points) {
        final Offset pxPt = Offset(toPxX(pt.x), toPxY(pt.y));

        if (pt.isErrorPoint && pt.correctedY != null) {
          // Mode 2A (Figure 23.3): Student plotted wrong point (Red) vs True point (Green)
          final Offset truePx = Offset(toPxX(pt.x), toPxY(pt.correctedY!));
          _drawDashedLine(
            canvas,
            pxPt,
            truePx,
            Paint()
              ..color = Colors.red.shade700
              ..strokeWidth = 1.8,
          );
          _drawCrossMarker(canvas, pxPt, Colors.red.shade800, size: 6.5);
          _drawText(
            canvas,
            "${pt.label} (Wrong)",
            pxPt.dx + 42,
            pxPt.dy - 10,
            fontSize: 11,
            isBold: true,
            color: Colors.red.shade900,
          );

          _drawCrossMarker(canvas, truePx, Colors.green.shade800, size: 6.5);
          _drawText(
            canvas,
            "Corrected (${_fmt(pt.x)};${_fmt(pt.correctedY!)})",
            truePx.dx + 48,
            truePx.dy + 12,
            fontSize: 11,
            isBold: true,
            color: Colors.green.shade900,
          );
        } else {
          _drawCrossMarker(canvas, pxPt, Colors.black87, size: 5.5);
          if (data.lines.length == 1) {
            _drawText(
              canvas,
              pt.label,
              pxPt.dx + 28,
              pxPt.dy - 10,
              fontSize: 10.5,
              isBold: true,
              color: series.color,
            );
          }
        }
      }
    }

    // 6. Draw Dotted Graph-Reading Trace Lines ('a' and 'b' in Figure 23.2)
    final Paint tracePaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    for (final GraphTraceQuery tr in data.traces) {
      final Offset ptOnLine = Offset(toPxX(tr.xVal), toPxY(tr.yVal));
      final Offset ptOnX = Offset(toPxX(tr.xVal), originY);
      final Offset ptOnY = Offset(originX, toPxY(tr.yVal));

      if (tr.givenX) {
        // Trace from x-axis vertically to line, then horizontally to y-axis
        _drawDashedLine(canvas, ptOnX, ptOnLine, tracePaint);
        _drawDashedLine(canvas, ptOnLine, ptOnY, tracePaint);
      } else {
        // Trace from y-axis horizontally to line, then vertically to x-axis
        _drawDashedLine(canvas, ptOnY, ptOnLine, tracePaint);
        _drawDashedLine(canvas, ptOnLine, ptOnX, tracePaint);
      }

      canvas.drawCircle(ptOnLine, 4.5, Paint()..color = Colors.red.shade700);
      _drawBadge(
        canvas,
        "${tr.markerLabel}: (${_fmt(tr.xVal)};${_fmt(tr.yVal)})",
        (ptOnLine.dx + 44).clamp(plotRect.left + 45, plotRect.right - 45),
        (ptOnLine.dy + 14).clamp(plotRect.top + 15, plotRect.bottom - 15),
        Colors.red.shade700,
      );
    }

    // 7. Highlight Axis Intercepts & Multi-Line Intersection Point
    if (data.xIntercept != null) {
      final Offset xi =
      Offset(toPxX(data.xIntercept!.x), toPxY(data.xIntercept!.y));
      canvas.drawCircle(xi, 5.5, Paint()..color = Colors.orange.shade800);
    }
    if (data.yIntercept != null) {
      final Offset yi =
      Offset(toPxX(data.yIntercept!.x), toPxY(data.yIntercept!.y));
      canvas.drawCircle(yi, 5.5, Paint()..color = Colors.orange.shade800);
    }
    if (data.intersectionPoint != null) {
      final Offset ip = Offset(
          toPxX(data.intersectionPoint!.x), toPxY(data.intersectionPoint!.y));
      canvas.drawCircle(ip, 7.0, Paint()..color = Colors.red.shade700);
      canvas.drawCircle(
        ip,
        7.0,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
      _drawBadge(
        canvas,
        "Meet ${data.intersectionPoint!.label}",
        (ip.dx + 46).clamp(plotRect.left + 50, plotRect.right - 50),
        (ip.dy - 18).clamp(plotRect.top + 18, plotRect.bottom - 18),
        Colors.red.shade800,
      );
    }

    canvas.restore();
    // Suppress unused variable warnings for blockPxX/Y
    assert(blockPxX > 0 && blockPxY > 0);
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
    const double dashW = 5.0;
    const double gapW = 4.0;
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 200);
    final double dx = (p2.dx - p1.dx) / count;
    final double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      final double sx = p1.dx + i * dx;
      final double sy = p1.dy + i * dy;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + dx * 0.55, sy + dy * 0.55),
        paint,
      );
    }

    final double angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    _drawArrowHead(
      canvas,
      Offset(p1.dx + (p2.dx - p1.dx) * 0.6, p1.dy + (p2.dy - p1.dy) * 0.6),
      angle,
      paint.color,
    );
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
  bool shouldRepaint(covariant CartesianLinearGraphPainter oldDelegate) =>
      oldDelegate.data != data;
}