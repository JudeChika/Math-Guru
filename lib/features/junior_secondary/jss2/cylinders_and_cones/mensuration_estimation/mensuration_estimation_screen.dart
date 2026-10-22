import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'mensuration_estimation_logic.dart';
import 'mensuration_estimation_models.dart';

class MensurationEstimationScreen extends StatefulWidget {
  const MensurationEstimationScreen({super.key});

  @override
  State<MensurationEstimationScreen> createState() =>
      _MensurationEstimationScreenState();
}

class _MensurationEstimationScreenState
    extends State<MensurationEstimationScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _topicMode = 0; // 0: 1 s.f. Estimation, 1: Rounding Master, 2: Mensuration Estimation

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0: 1 s.f. Estimation Expression
  final TextEditingController _exprCtrl =
  TextEditingController(text: '3.1 * 4.8 * 9.2');

  // Mode 1: Rounding Master (s.f. & d.p.)
  final TextEditingController _roundNumCtrl =
  TextEditingController(text: '384.62');
  final TextEditingController _roundUnitCtrl =
  TextEditingController(text: 'cm³');

  // Mode 2: Mensuration & Estimation Comparison (Cylinder, Cone, Composite Basin)
  String _shapeType = 'composite'; // 'cylinder', 'cone', 'composite'
  final TextEditingController _dim1Ctrl = TextEditingController(text: '15');
  final TextEditingController _dim2Ctrl = TextEditingController(text: '8');
  final TextEditingController _dim3Ctrl = TextEditingController(text: '6');
  String _unit = 'cm';

  static const List<String> _units = ['mm', 'cm', 'm'];

  MensurationEstResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _exprCtrl.dispose();
    _roundNumCtrl.dispose();
    _roundUnitCtrl.dispose();
    _dim1Ctrl.dispose();
    _dim2Ctrl.dispose();
    _dim3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(MensurationEstPreset p) {
    setState(() {
      _topicMode = p.topicMode;
      if (p.topicMode == 0) {
        _exprCtrl.text = p.expression;
      } else if (p.topicMode == 1) {
        _roundNumCtrl.text = p.expression;
      } else {
        _shapeType = p.shapeType;
        _dim1Ctrl.text = p.dim1;
        _dim2Ctrl.text = p.dim2;
        if (p.dim3.isNotEmpty) _dim3Ctrl.text = p.dim3;
        _unit = p.unit;
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
            content: Text('Please enter a word problem or upload an image.')),
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
      You are a strict JSON data extractor for JSS2 Section 19-3: Mensuration and Estimation.
      Classify the word problem or textbook image into one of 3 modes:
      - "topicMode":
        0 for Estimating a numeric product/quotient by rounding each number to 1 significant figure (e.g., 3.1 * 4.8 * 9.2).
        1 for Rounding a measurement to 1 s.f., 2 s.f., 3 s.f., nearest whole number, 1 d.p., and 2 d.p.
        2 for Mensuration & Estimation of a Cylinder, Cone, or Composite Solid (e.g., Example 8 Basin of Rice with cylinder + cone mound).

      Return ONLY valid JSON:
      {
        "topicMode": 2,
        "expression": "3.1 * 4.8 * 9.2",
        "roundNum": "384.62",
        "roundUnit": "cm³",
        "shapeType": "composite",
        "dim1": "15",
        "dim2": "8",
        "dim3": "6",
        "unit": "cm"
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
        _topicMode = ((jsonMap['topicMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        if (jsonMap['expression'] != null) {
          _exprCtrl.text = jsonMap['expression'].toString();
        }
        if (jsonMap['roundNum'] != null) {
          _roundNumCtrl.text = jsonMap['roundNum'].toString();
        }
        if (jsonMap['roundUnit'] != null) {
          _roundUnitCtrl.text = jsonMap['roundUnit'].toString();
        }
        final String st = jsonMap['shapeType']?.toString() ?? 'composite';
        if (['cylinder', 'cone', 'composite'].contains(st)) {
          _shapeType = st;
        }
        if (jsonMap['dim1'] != null) _dim1Ctrl.text = jsonMap['dim1'].toString();
        if (jsonMap['dim2'] != null) _dim2Ctrl.text = jsonMap['dim2'].toString();
        if (jsonMap['dim3'] != null) _dim3Ctrl.text = jsonMap['dim3'].toString();
        final String u = jsonMap['unit']?.toString() ?? 'cm';
        if (_units.contains(u)) _unit = u;
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
      if (_topicMode == 0) {
        _result = MensurationEstLogic.solveOneSFEstimation(
          expressionStr: _exprCtrl.text,
        );
      } else if (_topicMode == 1) {
        _result = MensurationEstLogic.solveRoundingMaster(
          numberStr: _roundNumCtrl.text,
          unit: _roundUnitCtrl.text,
        );
      } else {
        _result = MensurationEstLogic.solveMensurationEstimation(
          shapeType: _shapeType,
          rStr: _dim1Ctrl.text,
          h1Str: _dim2Ctrl.text,
          h2Str: _dim3Ctrl.text,
          unit: _unit,
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

  Widget _buildPresetBar() {
    const presets = MensurationEstLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick-Load Textbook Examples & Exercises:"),
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

  Widget _buildTopicModeSelector() {
    const List<Map<String, dynamic>> modes = [
      {
        'idx': 0,
        'label': '1 s.f. Rough Estimation',
        'icon': Icons.bolt,
      },
      {
        'idx': 1,
        'label': 'Significant Figures & d.p.',
        'icon': Icons.tune,
      },
      {
        'idx': 2,
        'label': 'Mensuration Estimation (Ex 8)',
        'icon': Icons.view_in_ar,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Estimation or Rounding Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _topicMode == idx;
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
              onSelected: (_) => setState(() => _topicMode = idx),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Snap a photo of any estimation or mensuration rounding problem from Section 19-3, and the AI will set up the exact steps!",
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
                const Text("Image Attached",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
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
              labelText: "Word Problem or Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A basin is a cylinder of height 8 cm and diameter 30 cm, topped by a conical mound of rice of height 6 cm. Estimate the volume...",
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
              label: const Text("Extract & Solve with AI",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          _buildPresetBar(),
          const SizedBox(height: 16),
          _buildTopicModeSelector(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: _topicMode == 0
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                    "2. Enter Product / Division Expression to Estimate:"),
                const SizedBox(height: 8),
                _buildTextField(
                  _exprCtrl,
                  "Expression (Use * for multiply, / for divide)",
                  hint: "e.g. 3.1 * 4.8 * 9.2 or (3.14 * 19 * 19) / 3",
                ),
              ],
            )
                : (_topicMode == 1
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                    "2. Enter Measurement to Round (s.f. & d.p.):"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        _roundNumCtrl,
                        "Number / Measurement",
                        hint: "e.g. 384.62 or 7065",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _roundUnitCtrl,
                        "Unit (Optional)",
                        hint: "e.g. cm³",
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("2. Select Solid & Dimensions:"),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: _shapeType,
                    thumbColor: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade50,
                    children: {
                      'composite': Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Basin + Cone\n(Ex 8)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                            color: _shapeType == 'composite'
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      'cylinder': Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Cylinder\n(π ≈ 3 vs 22/7)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                            color: _shapeType == 'cylinder'
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      'cone': Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Cone\n(⅓ × 3 = 1)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                            color: _shapeType == 'cone'
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (String? val) {
                      if (val != null) {
                        setState(() => _shapeType = val);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _dim1Ctrl,
                        "Base Radius (r)",
                        hint: "e.g. 15 or 6.8",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        _dim2Ctrl,
                        _shapeType == 'composite'
                            ? "Basin Height (h₁)"
                            : "Height (h)",
                        hint: "e.g. 8 or 10.4",
                      ),
                    ),
                  ],
                ),
                if (_shapeType == 'composite') ...[
                  const SizedBox(height: 10),
                  _buildTextField(
                    _dim3Ctrl,
                    "Conical Mound Height (h₂)",
                    hint: "e.g. 6",
                  ),
                ],
              ],
            )),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text("Estimate & Explain",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
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
    final double canvasWidth = math.max(screenWidth, 620.0);
    const double canvasHeight = 290.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Estimation & Rounding Visualizer:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 18)),
            ),
            SizedBox(width: 8),
            Text("💡 Pan & Zoom",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 290,
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
                  painter: MensurationEstPainter(result: _result!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text("2. Final Answers:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
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
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text("3. Mathematical Workings:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
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
                              fontSize: 17, color: Colors.deepPurple),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text("4. Step-by-Step Breakdown:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
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
                child: Text('${e.key + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(e.value.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.deepPurple)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    e.value.description,
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.45),
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
                                      fontWeight: FontWeight.bold),
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
          '19-3 Mensuration & Estimation',
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

class MensurationEstPainter extends CustomPainter {
  final MensurationEstResult result;

  MensurationEstPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    _drawText(
      canvas,
      result.topicMode == 0
          ? "1 Significant Figure (1 s.f.) Estimation vs. Exact Calculation"
          : (result.topicMode == 1
          ? "Significant Figures (1 s.f., 2 s.f., 3 s.f.) vs. Decimal Places"
          : "Example 8: Cylindrical Basin + Conical Mound Estimation"),
      cx,
      24,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    final entries = result.finalAnswers.entries.toList();
    final int count = math.min(entries.length, 4);
    if (count == 0) return;

    final double cardW = (size.width - 60) / count;
    for (int i = 0; i < count; i++) {
      final double x = 30 + i * cardW + cardW / 2;
      const double y = 155.0;

      final Rect r =
      Rect.fromCenter(center: Offset(x, y), width: cardW - 14, height: 110);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(12)),
        Paint()
          ..color = i == 0
              ? Colors.deepPurple.shade50
              : Colors.green.shade50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(12)),
        Paint()
          ..color = i == 0 ? Colors.deepPurple : Colors.green.shade700
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      _drawText(
        canvas,
        entries[i].key,
        x,
        y - 22,
        fontSize: 12,
        isBold: true,
        color: Colors.black87,
      );
      _drawText(
        canvas,
        entries[i].value,
        x,
        y + 16,
        fontSize: 16.5,
        isBold: true,
        color: i == 0 ? Colors.deepPurple : Colors.green.shade800,
      );
    }
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
  bool shouldRepaint(covariant MensurationEstPainter oldDelegate) =>
      oldDelegate.result != result;
}