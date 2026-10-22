import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'graphs_of_inequalities_logic.dart';
import 'graphs_of_inequalities_models.dart';

class GraphsOfInequalitiesScreen extends StatefulWidget {
  const GraphsOfInequalitiesScreen({super.key});

  @override
  State<GraphsOfInequalitiesScreen> createState() =>
      _GraphsOfInequalitiesScreenState();
}

class _GraphsOfInequalitiesScreenState
    extends State<GraphsOfInequalitiesScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _mode = 0;
  // 0: Sketch Graph of Inequality (Fig 22.1–22.3, Ex 22d #2)
  // 1: Read Inequality from Graph (Ex 5 / Fig 22.4, Ex 22d #1 / Fig 22.5)
  // 2: Solve 1-Step / 2-Step & Sketch Graph (Ex 6 & Ex 7 / Fig 22.6)
  // 3: Linear Inequality Inspector (Page 193 Index = 1 & Variable Count)

  int _graphStyle = 0;
  // 0: Raised Ray Above Number Line (Fig 22.5 / Ex 22d #1)
  // 1: Heavy Line Directly ON Number Line (Fig 22.1, 22.2, 22.4, 22.6)
  // 2: Compare All 3 Textbook Drawing Styles (Fig 22.3)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0 & Mode 1 Controllers (Sketch Graph & Read Graph)
  final TextEditingController _varNameCtrl = TextEditingController(text: 'x');
  String _symbol = '<';
  final TextEditingController _boundaryCtrl = TextEditingController(text: '2');
  bool _isReversedInput = false;
  bool _isShadedCircle = false;
  bool _pointsRight = false;

  // Mode 2 & Mode 3 Controllers (Solve & Sketch / Linear Inspector)
  final TextEditingController _fullInequalityCtrl =
  TextEditingController(text: '6 <= 2x - 1');

  GraphInequalityResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _varNameCtrl.dispose();
    _boundaryCtrl.dispose();
    _fullInequalityCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(GraphInequalityPreset p) {
    setState(() {
      _mode = p.mode;
      _graphStyle = p.graphStyle;
      _varNameCtrl.text = p.varName;
      _symbol = p.symbol;
      _boundaryCtrl.text = p.boundaryStr;
      _isReversedInput = p.isReversedInput;
      _isShadedCircle = p.isShadedCircle;
      _pointsRight = p.pointsRight;
      _fullInequalityCtrl.text = p.fullInequalityExpr;
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
              'Please enter a question or upload a number line / textbook image.'),
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
      You are a strict JSON data extractor for JSS2 Section 22-2: Graphs of Inequalities.
      Classify the question or number line image into one of 4 modes:
      - "mode":
        0 for Sketching the Graph of a given inequality on a number line (e.g. x < 2, x >= -1, x <= 0, or reversed 3 1/2 <= x).
        1 for Reading & Writing the inequality shown by a number line graph (given boundary number, empty vs shaded circle, and left vs right arrow).
        2 for Solving a 1-step or 2-step linear inequality and sketching its graph (e.g. x + 4 < 6 or 6 <= 2x - 1).
        3 for Inspecting whether an inequality is a Linear Inequality in One Variable (checking index = 1 and variable count, e.g. 3x > -12 vs 2x - y <= 7).

      Return ONLY valid JSON:
      {
        "mode": 1,
        "graphStyle": 0,
        "varName": "x",
        "symbol": "<=",
        "boundaryStr": "4",
        "isReversedInput": false,
        "isShadedCircle": true,
        "pointsRight": false,
        "fullInequalityExpr": "6 <= 2x - 1"
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
        _graphStyle =
            ((jsonMap['graphStyle'] as num?)?.toInt() ?? 0).clamp(0, 2);
        if (jsonMap['varName'] != null) {
          _varNameCtrl.text = jsonMap['varName'].toString();
        }
        final String sym = jsonMap['symbol']?.toString() ?? '<';
        if (['<', '>', '<=', '>=', '!='].contains(sym)) _symbol = sym;
        if (jsonMap['boundaryStr'] != null) {
          _boundaryCtrl.text = jsonMap['boundaryStr'].toString();
        }
        _isReversedInput = jsonMap['isReversedInput'] == true;
        _isShadedCircle = jsonMap['isShadedCircle'] == true;
        _pointsRight = jsonMap['pointsRight'] == true;
        if (jsonMap['fullInequalityExpr'] != null) {
          _fullInequalityCtrl.text = jsonMap['fullInequalityExpr'].toString();
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
        _result = GraphsOfInequalitiesLogic.solveSketchGraph(
          varName: _varNameCtrl.text,
          rawSymbol: _symbol,
          boundaryStr: _boundaryCtrl.text,
          isReversedInput: _isReversedInput,
          graphStyle: _graphStyle,
        );
      } else if (_mode == 1) {
        _result = GraphsOfInequalitiesLogic.solveReadGraph(
          varName: _varNameCtrl.text,
          boundaryStr: _boundaryCtrl.text,
          isShadedCircle: _isShadedCircle,
          pointsRight: _pointsRight,
          graphStyle: _graphStyle,
        );
      } else if (_mode == 2) {
        _result = GraphsOfInequalitiesLogic.solveAndSketchLinear(
          rawInequality: _fullInequalityCtrl.text,
          graphStyle: _graphStyle,
        );
      } else {
        _result = GraphsOfInequalitiesLogic.solveLinearInspector(
          rawInequality: _fullInequalityCtrl.text,
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
    const presets = GraphsOfInequalitiesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick-Load Textbook Figures & Exercises (22d):"),
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
    final List<Map<String, dynamic>> modes = [
      {
        'idx': 0,
        'label': 'Sketch Graph (Ex 22d #2)',
        'icon': Icons.create,
      },
      const {
        'idx': 1,
        'label': 'Read Graph (Ex 5 & 22d #1)',
        'icon': Icons.visibility,
      },
      const {
        'idx': 2,
        'label': 'Solve & Sketch (Ex 6 & 7)',
        'icon': Icons.functions,
      },
      const {
        'idx': 3,
        'label': 'Linear Index Inspector (p.193)',
        'icon': Icons.fact_check_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Number Line Graph Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            return ChoiceChip(
              avatar: Icon(
                idx == 0 ? Icons.edit_road : (m['icon'] as IconData),
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

  Widget _buildGraphStyleSelector() {
    if (_mode == 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.straighten, color: Colors.deepPurple, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Textbook Number Line Drawing Style (Figure 22.3):",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _graphStyle,
              thumbColor: Colors.deepPurple,
              backgroundColor: Colors.white,
              children: {
                0: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Raised Ray\n(Fig 22.5)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color:
                      _graphStyle == 0 ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                ),
                1: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "On Number Line\n(Fig 22.1 / 22.4)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color:
                      _graphStyle == 1 ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                ),
                2: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "All 3 Styles\n(Fig 22.3)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color:
                      _graphStyle == 2 ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                ),
              },
              onValueChanged: (int? v) {
                if (v != null) {
                  setState(() => _graphStyle = v);
                  if (_result != null) _solveManual();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSpecificForm() {
    const List<Map<String, String>> syms = [
      {'val': '<', 'disp': '< (Empty ○, Left ←)'},
      {'val': '>', 'disp': '> (Empty ○, Right →)'},
      {'val': '<=', 'disp': '≤ (Shaded ●, Left ←)'},
      {'val': '>=', 'disp': '≥ (Shaded ●, Right →)'},
      {'val': '!=', 'disp': '≠ (Empty ○, Both ↔)'},
    ];

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
                "2. Enter Inequality to Sketch on the Number Line:"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varNameCtrl,
                    "Unknown Letter",
                    hint: "e.g. x",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _buildTextField(
                    _boundaryCtrl,
                    "Boundary Value (Int or Mixed Fraction)",
                    hint: "e.g. 2, -3, 0, or 3 1/2",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Select Inequality Symbol:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: syms.map((s) {
                final bool isSel = _symbol == s['val'];
                return ChoiceChip(
                  label: Text(
                    s['disp']!,
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
                  onSelected: (_) => setState(() => _symbol = s['val']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Given in Reversed Form (e.g. 3½ ≤ x → Rearrange to x ≥ 3½)",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: _isReversedInput,
                  activeColor: Colors.deepPurple,
                  onChanged: (v) => setState(() => _isReversedInput = v),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Describe the Number Line Graph (Ex 5 & Ex 22d #1):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTextField(
                    _boundaryCtrl,
                    "Number Where Circle Sits",
                    hint: "e.g. 4, 3, -2, -4, or 2 1/2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varNameCtrl,
                    "Letter",
                    hint: "e.g. x",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "1. Circle Type at Boundary:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _isShadedCircle,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  false: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "○ Empty Circle (Not Included)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: !_isShadedCircle
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                  true: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "● Shaded Circle (Included)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _isShadedCircle
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (bool? v) {
                  if (v != null) setState(() => _isShadedCircle = v);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "2. Heavy Arrowed Line Direction:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _pointsRight,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  false: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "← Points Left (Less Than)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                        !_pointsRight ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  true: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "→ Points Right (Greater Than)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                        _pointsRight ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (bool? v) {
                  if (v != null) setState(() => _pointsRight = v);
                },
              ),
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter 1-Step / 2-Step Inequality to Solve & Graph (Ex 6 & 7):"),
            const SizedBox(height: 10),
            _buildTextField(
              _fullInequalityCtrl,
              "Linear Inequality in One Variable",
              hint: "e.g. x + 4 < 6 or 6 <= 2x - 1",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Inequality to Check Index & Variable Count (Page 193):"),
            const SizedBox(height: 10),
            _buildTextField(
              _fullInequalityCtrl,
              "Algebraic Inequality Statement",
              hint: "e.g. 3x > -12, 2x - y <= 7, or x^2 < 25",
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
                    "Snap a photo of any number line graph or inequality question from Section 22-2 (Exercise 22d), and the AI will read or sketch it step-by-step!",
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
              labelText: "Inequality or Number Line Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Sketch the graph of x >= -3, or read the graph with a shaded circle at 2 1/2 pointing to the right...",
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
                "Extract & Graph Inequality",
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
          _buildGraphStyleSelector(),
          if (_mode != 3) const SizedBox(height: 16),
          _buildModeSpecificForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.linear_scale, color: Colors.white),
            label: const Text(
              "Graph on Number Line & Explain",
              style: TextStyle(
                  fontSize: 18,
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
    final double canvasWidth = math.max(screenWidth, 660.0);
    final double canvasHeight =
    _result!.visualData.graphStyle == 2 ? 380.0 : 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Number Line Graph Visualizer:",
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
              boundaryMargin: const EdgeInsets.all(120),
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: NumberLineGraphPainter(
                    visual: _result!.visualData,
                  ),
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
                      fontSize: 18,
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
                            fontSize: 17,
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
                                    fontSize: 16.5,
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
          '22-2 Graphs of Inequalities',
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

class NumberLineGraphPainter extends CustomPainter {
  final NumberLineVisualData visual;

  NumberLineGraphPainter({required this.visual});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // Header Badge
    _drawText(
      canvas,
      visual.headerBadge,
      cx,
      24,
      fontSize: 15.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    if (visual.subBadge.isNotEmpty) {
      _drawText(
        canvas,
        visual.subBadge,
        cx,
        48,
        fontSize: 12.5,
        isBold: true,
        color: Colors.green.shade800,
      );
    }

    if (visual.isInspectorMode) {
      final Rect box = Rect.fromCenter(
        center: Offset(cx, 165),
        width: size.width - 100,
        height: 110,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(14)),
        Paint()..color = Colors.deepPurple.shade50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(14)),
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        visual.inspectorDetails,
        cx,
        150,
        fontSize: 14,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        "Rule (Page 193): Linear inequalities have variables of index 1 (e.g. x = x¹).",
        cx,
        182,
        fontSize: 12.5,
        color: Colors.black87,
      );
      return;
    }

    if (visual.graphStyle == 2) {
      // Compare All 3 Textbook Styles (Figure 22.3)
      _drawSingleNumberLine(
        canvas,
        size,
        lineY: 115.0,
        styleMode: 1,
        styleTitle: "Style 1 (Figures 22.1 & 22.2): Heavy Line ON the Number Line",
      );
      _drawSingleNumberLine(
        canvas,
        size,
        lineY: 225.0,
        styleMode: 0,
        styleTitle: "Style 2 (Figure 22.3 Top & Fig 22.5): Raised Ray ABOVE Full Number Line",
      );
      _drawSingleNumberLine(
        canvas,
        size,
        lineY: 335.0,
        styleMode: 2,
        styleTitle: "Style 3 (Figure 22.3 Bottom): Simplified Single-Tick Sketch",
      );
    } else {
      _drawSingleNumberLine(
        canvas,
        size,
        lineY: 185.0,
        styleMode: visual.graphStyle,
        styleTitle: visual.graphStyle == 0
            ? "Textbook Style (Fig 22.3 & 22.5): Raised Arrowed Ray Above Number Line"
            : "Textbook Style (Fig 22.1, 22.2 & 22.4): Heavy Arrowed Line ON Number Line",
      );
    }
  }

  void _drawSingleNumberLine(
      Canvas canvas,
      Size size, {
        required double lineY,
        required int styleMode, // 0: Raised Ray, 1: On-Line, 2: Simplified Single-Tick
        required String styleTitle,
      }) {
    const double leftX = 65.0;
    final double rightX = size.width - 65.0;

    _drawText(
      canvas,
      styleTitle,
      size.width / 2,
      lineY - 48,
      fontSize: 11.5,
      isBold: true,
      color: Colors.grey.shade700,
    );

    // Base horizontal number line
    canvas.drawLine(
      Offset(leftX, lineY),
      Offset(rightX, lineY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0,
    );

    // Variable label 'x' at right end of number line (matching Figures 22.1–22.6)
    _drawText(
      canvas,
      visual.varName,
      rightX + 18,
      lineY + 14,
      fontSize: 14,
      isBold: true,
      color: Colors.black87,
    );

    final int centerInt = visual.boundaryVal.round();
    final int minInt = centerInt - 3;
    final int maxInt = centerInt + 3;
    final double span = (maxInt - minInt).toDouble() + 1.2;

    double toX(double val) {
      return leftX + ((val - (minInt - 0.6)) / span) * (rightX - leftX);
    }

    if (styleMode == 2) {
      // Simplified Single-Tick Number Line (Figure 22.3 Bottom)
      final double bx = toX(visual.boundaryVal);
      canvas.drawLine(
        Offset(bx, lineY - 7),
        Offset(bx, lineY + 7),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2.0,
      );
      _drawText(
        canvas,
        visual.boundaryDisplay,
        bx,
        lineY + 20,
        fontSize: 13,
        isBold: true,
      );
    } else {
      // Full Integer Ticks (minInt .. maxInt)
      final bool isFractionalBoundary =
          (visual.boundaryVal - visual.boundaryVal.roundToDouble()).abs() >
              1e-9;

      for (int i = minInt; i <= maxInt; i++) {
        final double tx = toX(i.toDouble());
        canvas.drawLine(
          Offset(tx, lineY - 6),
          Offset(tx, lineY + 6),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.8,
        );
        _drawText(
          canvas,
          i.toString(),
          tx,
          lineY + 20,
          fontSize: 12.5,
          isBold: !isFractionalBoundary && i == centerInt,
          color: (!isFractionalBoundary && i == centerInt)
              ? Colors.deepPurple
              : Colors.black87,
        );
      }

      // If boundary is a mixed fraction (like 2½ in Ex 22d #1h or 3½ in Fig 22.6), draw its fractional tick!
      if (isFractionalBoundary) {
        final double fx = toX(visual.boundaryVal);
        canvas.drawLine(
          Offset(fx, lineY - 8),
          Offset(fx, lineY + 8),
          Paint()
            ..color = Colors.deepPurple
            ..strokeWidth = 2.2,
        );
        _drawText(
          canvas,
          visual.boundaryDisplay,
          fx,
          lineY + 22,
          fontSize: 12.5,
          isBold: true,
          color: Colors.deepPurple,
        );
      }
    }

    // Draw the Circle & Heavy Arrowed Ray
    final double bx = toX(visual.boundaryVal);
    final double rayY = styleMode == 1 ? lineY : lineY - 22.0;
    final Color rayColor = Colors.green.shade700;

    if (visual.isNotEqual) {
      // Arrows both left and right from open circle
      _drawHeavyRayWithArrow(
        canvas,
        startX: bx,
        endX: leftX + 6,
        y: rayY,
        pointsRight: false,
        color: rayColor,
      );
      _drawHeavyRayWithArrow(
        canvas,
        startX: bx,
        endX: rightX - 6,
        y: rayY,
        pointsRight: true,
        color: rayColor,
      );
    } else {
      final double endX = visual.pointsRight ? rightX - 6 : leftX + 6;
      _drawHeavyRayWithArrow(
        canvas,
        startX: bx,
        endX: endX,
        y: rayY,
        pointsRight: visual.pointsRight,
        color: rayColor,
      );
    }

    // Draw Empty (Open ○) or Shaded (Solid ●) Circle at boundary
    canvas.drawCircle(
      Offset(bx, rayY),
      7.0,
      Paint()..color = visual.isShaded ? rayColor : Colors.white,
    );
    canvas.drawCircle(
      Offset(bx, rayY),
      7.0,
      Paint()
        ..color = rayColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawHeavyRayWithArrow(
      Canvas canvas, {
        required double startX,
        required double endX,
        required double y,
        required bool pointsRight,
        required Color color,
      }) {
    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      Paint()
        ..color = color
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round,
    );

    final double dir = pointsRight ? -1.0 : 1.0;
    final Path arrowHead = Path()
      ..moveTo(endX, y)
      ..lineTo(endX + dir * 13, y - 6.5)
      ..lineTo(endX + dir * 13, y + 6.5)
      ..close();
    canvas.drawPath(arrowHead, Paint()..color = color);
  }

  void _drawText(
      Canvas canvas,
      String text,
      double x,
      double y, {
        double fontSize = 13,
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
  bool shouldRepaint(covariant NumberLineGraphPainter oldDelegate) =>
      oldDelegate.visual != visual;
}