import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'scale_drawings_logic.dart';
import 'scale_drawings_models.dart';

class _ScaleDrawingPresetItem {
  final String label;
  final int mode;
  final int subMode;
  final double realDistOrHeight;
  final double angleDeg;
  final double observerEyeHeight;
  final double secondAngleDeg;
  final double baselineSeparation;
  final String scaleStr;
  final String roundRule;

  const _ScaleDrawingPresetItem({
    required this.label,
    required this.mode,
    this.subMode = 0,
    required this.realDistOrHeight,
    required this.angleDeg,
    this.observerEyeHeight = 0.0,
    this.secondAngleDeg = 0.0,
    this.baselineSeparation = 0.0,
    this.scaleStr = '1 cm to 2 m',
    this.roundRule = 'metre',
  });
}

class ScaleDrawingsScreen extends StatefulWidget {
  const ScaleDrawingsScreen({super.key});

  @override
  State<ScaleDrawingsScreen> createState() => _ScaleDrawingsScreenState();
}

class _ScaleDrawingsScreenState extends State<ScaleDrawingsScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _mode = 0; // 0: Elevation, 1: Depression, 2: Two-Point, 3: Reverse Angle
  int _subMode = 0; // 0A, 0B, 1A, 1B

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Primary Dimension Controllers
  final TextEditingController _realValCtrl = TextEditingController(text: '12');
  final TextEditingController _angleCtrl = TextEditingController(text: '28');
  final TextEditingController _eyeHCtrl = TextEditingController(text: '1.6');
  final TextEditingController _secAngleCtrl = TextEditingController(text: '63');
  final TextEditingController _baselineCtrl = TextEditingController(text: '1100');
  final TextEditingController _customScaleCtrl =
  TextEditingController(text: '1 cm to 2 m');

  bool _autoSmartScale = true;
  String _roundRule = 'metre';

  static const List<String> _roundingRules = [
    'metre',
    'half_metre',
    '10_cm',
    '5_metre',
    '100_metre',
  ];

  static const Map<String, String> _roundRuleLabels = {
    'metre': 'Nearest Metre (m)',
    'half_metre': 'Nearest ½ m (0.5 m)',
    '10_cm': 'Nearest 10 cm',
    '5_metre': 'Nearest 5 m',
    '100_metre': 'Nearest 100 m',
  };

  ScaleDrawingResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<_ScaleDrawingPresetItem> _presets = [
    _ScaleDrawingPresetItem(
      label: "Ex 1 (Fig 20.14): Tree & Clinometer (28°, 12 m, eye 1.6 m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 12.0,
      angleDeg: 28.0,
      observerEyeHeight: 1.6,
      scaleStr: '1 cm to 2 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #1 (Fig 20.15): Flagpole (40°, 10 m, nearest ½ m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 10.0,
      angleDeg: 40.0,
      observerEyeHeight: 0.0,
      scaleStr: '1 cm to 2 m',
      roundRule: 'half_metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #2 (Fig 20.16): Control Tower (25° depression, 60 m)",
      mode: 1,
      subMode: 0,
      realDistOrHeight: 60.0,
      angleDeg: 25.0,
      scaleStr: '1 cm to 10 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #3 (Fig 20.17): Water Tower (37°, 8 m, eye 1.5 m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 8.0,
      angleDeg: 37.0,
      observerEyeHeight: 1.5,
      scaleStr: '1 cm to 2 m',
      roundRule: 'half_metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #4 (Fig 20.18): River Width (15° depression, eye 1.6 m)",
      mode: 1,
      subMode: 1,
      realDistOrHeight: 1.6,
      angleDeg: 15.0,
      scaleStr: '1 cm to 1 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #5 (Fig 20.19): Tree & Sun (35°, shadow 12.8 m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 12.8,
      angleDeg: 35.0,
      scaleStr: '1 cm to 2 m',
      roundRule: 'half_metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #6 (Fig 20.20): Building (54° depression, 60 m)",
      mode: 1,
      subMode: 0,
      realDistOrHeight: 60.0,
      angleDeg: 54.0,
      scaleStr: '1 cm to 10 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #7: Tower Elevation (36°, 42 m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 42.0,
      angleDeg: 36.0,
      scaleStr: '1 cm to 5 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Ex 20d #8: Car Depression from 50 m Building (55°)",
      mode: 1,
      subMode: 1,
      realDistOrHeight: 50.0,
      angleDeg: 55.0,
      scaleStr: '1 cm to 10 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Rev Test 20 #7: Sun at 45° & 12 m Tree Shadow",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 12.0,
      angleDeg: 45.0,
      scaleStr: '1 cm to 2 m',
      roundRule: 'metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Rev Test 20 #8: Man 180 cm & Sun 27° Shadow (nearest 10 cm)",
      mode: 0,
      subMode: 1,
      realDistOrHeight: 1.8,
      angleDeg: 27.0,
      scaleStr: '1 cm to 0.5 m',
      roundRule: '10_cm',
    ),
    _ScaleDrawingPresetItem(
      label: "Rev Test 20 #9: Radio Mast (61°, 53 m, nearest 5 m)",
      mode: 0,
      subMode: 0,
      realDistOrHeight: 53.0,
      angleDeg: 61.0,
      scaleStr: '1 cm to 10 m',
      roundRule: '5_metre',
    ),
    _ScaleDrawingPresetItem(
      label: "Rev Test 20 #10 (Fig 20.23): Aircraft 2-Point (46° & 63°, 1100 m)",
      mode: 2,
      subMode: 0,
      realDistOrHeight: 0,
      angleDeg: 46.0,
      secondAngleDeg: 63.0,
      baselineSeparation: 1100.0,
      scaleStr: '1 cm to 200 m',
      roundRule: '100_metre',
    ),
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _realValCtrl.dispose();
    _angleCtrl.dispose();
    _eyeHCtrl.dispose();
    _secAngleCtrl.dispose();
    _baselineCtrl.dispose();
    _customScaleCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(_ScaleDrawingPresetItem p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _realValCtrl.text = p.realDistOrHeight.toString();
      _angleCtrl.text = p.angleDeg.toString();
      _eyeHCtrl.text = p.observerEyeHeight.toString();
      _secAngleCtrl.text =
      p.secondAngleDeg > 0 ? p.secondAngleDeg.toString() : '63';
      _baselineCtrl.text =
      p.baselineSeparation > 0 ? p.baselineSeparation.toString() : '1100';
      _customScaleCtrl.text = p.scaleStr;
      _autoSmartScale = false;
      _roundRule = p.roundRule;
    });
    _solveManual();
  }

  String _autoPickScale() {
    final double v = double.tryParse(_realValCtrl.text.trim()) ?? 12.0;
    if (_mode == 2) {
      final double sep = double.tryParse(_baselineCtrl.text.trim()) ?? 1100.0;
      if (sep > 2000) return '1 cm to 500 m';
      if (sep > 500) return '1 cm to 200 m';
      return '1 cm to 50 m';
    }
    if (v > 50) return '1 cm to 10 m';
    if (v > 20) return '1 cm to 5 m';
    if (v > 5) return '1 cm to 2 m';
    return '1 cm to 0.5 m';
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
      You are a strict JSON data extractor for JSS2 Section 20-3: Scale Drawings (Angles of Elevation & Depression).
      Classify the word problem or textbook diagram into one of 4 modes:
      - "mode":
        0 for Angle of Elevation (subMode 0: Given Horizontal Distance & Angle -> Find Height; subMode 1: Given Height & Angle -> Find Shadow/Horizontal Distance).
        1 for Angle of Depression (subMode 0: Given Horizontal Distance & Angle -> Find Height; subMode 1: Given Height & Angle -> Find Horizontal Distance/River Width).
        2 for Two-Point Elevation Sighting (e.g. Aircraft observed at two angles theta1 and theta2 from points separated by baselineSeparation).
        3 for Reverse Scale Drawing (Given Vertical Height and Horizontal Distance -> Find unknown Angle of Elevation/Depression).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "realDistOrHeight": 12.0,
        "angleDeg": 28.0,
        "observerEyeHeight": 1.6,
        "secondAngleDeg": 63.0,
        "baselineSeparation": 1100.0,
        "scaleStr": "1 cm to 2 m",
        "roundRule": "metre"
      }
      Note on "roundRule": one of "metre", "half_metre", "10_cm", "5_metre", "100_metre".
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
        _realValCtrl.text = jsonMap['realDistOrHeight']?.toString() ?? '12';
        _angleCtrl.text = jsonMap['angleDeg']?.toString() ?? '28';
        _eyeHCtrl.text = jsonMap['observerEyeHeight']?.toString() ?? '0';
        _secAngleCtrl.text = jsonMap['secondAngleDeg']?.toString() ?? '63';
        _baselineCtrl.text =
            jsonMap['baselineSeparation']?.toString() ?? '1100';
        if (jsonMap['scaleStr'] != null &&
            jsonMap['scaleStr'].toString().isNotEmpty) {
          _customScaleCtrl.text = jsonMap['scaleStr'].toString();
          _autoSmartScale = false;
        }
        final String rr = jsonMap['roundRule']?.toString() ?? 'metre';
        if (_roundingRules.contains(rr)) _roundRule = rr;
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
    final double realVal = double.tryParse(_realValCtrl.text.trim()) ?? 12.0;
    final double angle = double.tryParse(_angleCtrl.text.trim()) ?? 28.0;
    final double eyeH = double.tryParse(_eyeHCtrl.text.trim()) ?? 0.0;
    final double secAngle = double.tryParse(_secAngleCtrl.text.trim()) ?? 63.0;
    final double baseline =
        double.tryParse(_baselineCtrl.text.trim()) ?? 1100.0;
    final String scaleStr =
    _autoSmartScale ? _autoPickScale() : _customScaleCtrl.text.trim();

    setState(() {
      _result = ScaleDrawingsLogic.solveScaleDrawing(
        mode: _mode,
        subMode: _subMode,
        realDistOrHeight: realVal,
        angleDeg: angle,
        observerEyeHeight: eyeH,
        secondAngleDeg: secAngle,
        baselineSeparation: baseline,
        scaleStr: scaleStr,
        roundRule: _roundRule,
      );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick-Load Textbook Examples & Exercises:"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.auto_stories,
                      size: 15, color: Colors.deepPurple),
                  label: Text(
                    p.label,
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
      {'idx': 0, 'label': 'Angle of Elevation', 'icon': Icons.trending_up},
      {'idx': 1, 'label': 'Angle of Depression', 'icon': Icons.trending_down},
      {'idx': 2, 'label': 'Two-Point Sighting', 'icon': Icons.radar},
      {'idx': 3, 'label': 'Find Unknown Angle', 'icon': Icons.architecture},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Scale Drawing Problem Archetype:"),
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

  Widget _buildEditorForm() {
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
                      "0A: Given Dist → Find Height",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "0B: Given Height → Find Shadow",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _subMode == 1 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (v) {
                  if (v != null) setState(() => _subMode = v);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _realValCtrl,
                    _subMode == 0
                        ? "Horizontal Distance / Shadow (m)"
                        : "Vertical Height / Object (m)",
                    hint: "e.g. 12 or 10",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _angleCtrl,
                    "Angle of Elevation (°)",
                    hint: "e.g. 28",
                  ),
                ),
              ],
            ),
            if (_subMode == 0) ...[
              const SizedBox(height: 12),
              _buildTextField(
                _eyeHCtrl,
                "Observer's Eye Height above Ground (m) (0 if ground level)",
                hint: "e.g. 1.6 or 0",
              ),
            ],
          ] else if (_mode == 1) ...[
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
                      "1A: Given Dist → Find Height",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "1B: Given Height → Find Width/Dist",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _subMode == 1 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (v) {
                  if (v != null) setState(() => _subMode = v);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _realValCtrl,
                    _subMode == 0
                        ? "Horizontal Distance from Base (m)"
                        : "Observer / Building Height (m)",
                    hint: "e.g. 60 or 1.6",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _angleCtrl,
                    "Angle of Depression (°)",
                    hint: "e.g. 25 or 15",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            const Text(
              "Two-Point Sighting (Rev Test 20 #10 / Fig 20.23):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _angleCtrl,
                    "Farther Angle θ₁ (°)",
                    hint: "e.g. 46",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _secAngleCtrl,
                    "Closer Angle θ₂ (°)",
                    hint: "e.g. 63",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _baselineCtrl,
              "Baseline Separation Distance AB (m)",
              hint: "e.g. 1100",
            ),
          ] else ...[
            const Text(
              "Reverse Scale Drawing — Find Unknown Angle (Rev Test 20 #5 & #6):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _realValCtrl,
                    "Vertical Height (m)",
                    hint: "e.g. 30",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _eyeHCtrl,
                    "Horizontal Distance (m)",
                    hint: "e.g. 40",
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.deepPurple.shade100),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Auto-Pick Suitable Textbook Scale",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 13,
                ),
              ),
              CupertinoSwitch(
                value: _autoSmartScale,
                activeColor: Colors.deepPurple,
                onChanged: (v) => setState(() => _autoSmartScale = v),
              ),
            ],
          ),
          if (!_autoSmartScale) ...[
            const SizedBox(height: 10),
            _buildTextField(
              _customScaleCtrl,
              "Custom Scale Format",
              hint: "e.g. 1 cm to 2 m",
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            "Required Accuracy / Rounding Rule:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _roundRule,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,
                    color: Colors.deepPurple),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                items: _roundingRules.map((rule) {
                  return DropdownMenuItem<String>(
                    value: rule,
                    child: Text(_roundRuleLabels[rule] ?? rule),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _roundRule = v);
                },
              ),
            ),
          ),
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
                    "Snap a photo of any Angle of Elevation or Depression problem from Section 20-3, and the AI will set up the exact scale drawing!",
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
              labelText: "Word Problem or Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. The angle of elevation of the top of a tower from a point 42 m away from its base on level ground is 36 degrees. Find the height...",
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
                "Extract & Construct Scale Drawing",
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
          _buildEditorForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.architecture, color: Colors.white),
            label: const Text(
              "Construct Scale Drawing & Explain",
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
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 360.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Millimetre Graph Paper Scale Drawing:",
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
          height: 360,
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
                  painter: ScaleDrawingPainter(result: _result!),
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
          '20-3 Scale Drawings',
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

class ScaleDrawingPainter extends CustomPainter {
  final ScaleDrawingResult result;

  ScaleDrawingPainter({required this.result});

  String _fmt(double v, {int maxDecimals = 1}) =>
      ScaleDrawingsLogic.fmt(v, maxDecimals: maxDecimals);

  @override
  void paint(Canvas canvas, Size size) {
    // Millimetre Graph Paper Background
    final Paint minorGrid = Paint()
      ..color = Colors.red.shade50
      ..strokeWidth = 0.6;
    final Paint majorGrid = Paint()
      ..color = Colors.red.withOpacity(0.22)
      ..strokeWidth = 1.1;
    const double gridStep = 24.0; // pixels per visual grid square

    for (double x = 0; x <= size.width; x += gridStep / 5) {
      final bool isMajor = (x % gridStep).abs() < 0.5;
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height), isMajor ? majorGrid : minorGrid);
    }
    for (double y = 0; y <= size.height; y += gridStep / 5) {
      final bool isMajor = (y % gridStep).abs() < 0.5;
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), isMajor ? majorGrid : minorGrid);
    }

    _drawText(
      canvas,
      "Scale Drawing on Graph Paper — Scale: ${result.scaleText}",
      size.width / 2,
      22,
      fontSize: 14.0,
      isBold: true,
      color: Colors.deepPurple,
    );

    if (result.mode == 2) {
      _paintTwoPointDrawing(canvas, size);
    } else {
      _paintRightAngledTriangleDrawing(canvas, size);
    }
  }

  void _paintRightAngledTriangleDrawing(Canvas canvas, Size size) {
    const double startX = 115.0;
    const double groundY = 290.0;

    final double basePaperCm =
        result.realHorizontal * result.scaleFactorCmPerUnit;
    final double totalVertPaperCm =
        result.realVertical * result.scaleFactorCmPerUnit;

    // Auto-scale pixel multiplier so any triangle fits cleanly inside the 680x360 canvas
    final double maxPaperX = math.max(basePaperCm, 1.0);
    final double maxPaperY = math.max(totalVertPaperCm, 1.0);
    final double pxPerPaperCm =
    math.min(260.0 / maxPaperX, 200.0 / maxPaperY).clamp(14.0, 48.0);

    final double basePx = basePaperCm * pxPerPaperCm;
    final Offset gH = const Offset(startX, groundY);
    final Offset baseH = Offset(startX + basePx, groundY);

    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    // Ground line GH
    canvas.drawLine(gH, baseH, stroke);
    _drawText(canvas, "G", gH.dx - 14, gH.dy + 12, fontSize: 13, isBold: true);
    _drawText(
        canvas, "H", baseH.dx + 14, baseH.dy + 12, fontSize: 13, isBold: true);
    _drawText(
      canvas,
      "GH = ${_fmt(basePaperCm, maxDecimals: 2)} cm (${_fmt(result.realHorizontal)} m)",
      (gH.dx + baseH.dx) / 2,
      groundY + 26,
      fontSize: 12,
      isBold: true,
      color: Colors.deepPurple,
    );

    if (result.realEyeHeight > 0) {
      // Clinometer Trapezial Figure (Figure 20.14)
      final double eyePaperCm =
          result.realEyeHeight * result.scaleFactorCmPerUnit;
      final double eyeHPx =
      math.max(eyePaperCm * pxPerPaperCm, 26.0); // Minimum visual height for legibility
      final Offset eyeE = Offset(startX, groundY - eyeHPx);

      canvas.drawLine(gH, eyeE, stroke);
      _drawText(canvas, "E", eyeE.dx - 14, eyeE.dy,
          fontSize: 13, isBold: true, color: Colors.green.shade900);
      _drawText(
        canvas,
        "EG = ${_fmt(eyePaperCm, maxDecimals: 2)} cm\n(${_fmt(result.realEyeHeight)} m)",
        startX - 52,
        (gH.dy + eyeE.dy) / 2,
        fontSize: 11,
        isBold: true,
        color: Colors.green.shade900,
      );

      final Offset eyeB = Offset(baseH.dx, eyeE.dy);
      canvas.drawLine(
        eyeE,
        eyeB,
        Paint()
          ..color = Colors.grey.shade700
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );

      final double vertAboveEyeM = result.realVertical - result.realEyeHeight;
      final double vertAboveEyeCm =
          vertAboveEyeM * result.scaleFactorCmPerUnit;
      final double vertFromEyePx = vertAboveEyeCm * pxPerPaperCm;
      final Offset treeT = Offset(baseH.dx, eyeE.dy - vertFromEyePx);

      canvas.drawLine(eyeE, treeT, stroke);
      canvas.drawLine(treeT, baseH, stroke);

      // Right-angle square at B
      const double sq = 9.0;
      canvas.drawPath(
        Path()
          ..moveTo(eyeB.dx, eyeB.dy - sq)
          ..lineTo(eyeB.dx - sq, eyeB.dy - sq)
          ..lineTo(eyeB.dx - sq, eyeB.dy),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, "B", eyeB.dx + 14, eyeB.dy, fontSize: 13, isBold: true);
      _drawText(
          canvas, "T", treeT.dx + 14, treeT.dy - 8, fontSize: 13, isBold: true);

      final double drawAngleRad =
      math.atan2(vertFromEyePx, basePx).clamp(0.1, 1.45);
      canvas.drawArc(
        Rect.fromCircle(center: eyeE, radius: 32),
        0,
        -drawAngleRad,
        false,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "e° = ${_fmt(result.angleDeg)}°",
        eyeE.dx + 52,
        eyeE.dy - 16,
        fontSize: 11.5,
        isBold: true,
        color: Colors.deepPurple,
      );

      _drawText(
        canvas,
        "HT = ${_fmt(totalVertPaperCm, maxDecimals: 2)} cm\n(${_fmt(result.realVertical)} m)",
        treeT.dx + 85,
        (baseH.dy + treeT.dy) / 2,
        fontSize: 11.5,
        isBold: true,
        color: Colors.green.shade900,
      );
    } else {
      // Ground-level right-angled triangle (Elevation or Depression)
      final double vertPx = totalVertPaperCm * pxPerPaperCm;
      final Offset treeT = Offset(baseH.dx, groundY - vertPx);

      canvas.drawLine(gH, treeT, stroke);
      canvas.drawLine(treeT, baseH, stroke);
      _drawText(
          canvas, "T", treeT.dx + 14, treeT.dy - 8, fontSize: 13, isBold: true);

      // Right-angle square at H
      const double sq = 9.0;
      canvas.drawPath(
        Path()
          ..moveTo(baseH.dx, baseH.dy - sq)
          ..lineTo(baseH.dx - sq, baseH.dy - sq)
          ..lineTo(baseH.dx - sq, baseH.dy),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );

      final double drawAngleRad = math.atan2(vertPx, basePx).clamp(0.1, 1.45);
      canvas.drawArc(
        Rect.fromCircle(center: gH, radius: 34),
        0,
        -drawAngleRad,
        false,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "${_fmt(result.angleDeg)}°",
        gH.dx + 46,
        gH.dy - 16,
        fontSize: 11.5,
        isBold: true,
        color: Colors.deepPurple,
      );

      // If Mode 1 (Depression), also draw the top horizontal sight-line and depression arc at T!
      if (result.mode == 1) {
        final Offset topHorizLeft = Offset(gH.dx, treeT.dy);
        canvas.drawLine(
          topHorizLeft,
          treeT,
          Paint()
            ..color = Colors.teal.shade700
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke,
        );
        canvas.drawArc(
          Rect.fromCircle(center: treeT, radius: 36),
          math.pi,
          -drawAngleRad,
          false,
          Paint()
            ..color = Colors.teal.shade800
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
        _drawText(
          canvas,
          "d° = ${_fmt(result.angleDeg)}°",
          treeT.dx - 64,
          treeT.dy + 18,
          fontSize: 11.5,
          isBold: true,
          color: Colors.teal.shade900,
        );
      }

      _drawText(
        canvas,
        "HT = ${_fmt(totalVertPaperCm, maxDecimals: 2)} cm\n(${_fmt(result.realVertical)} m)",
        treeT.dx + 85,
        (groundY + treeT.dy) / 2,
        fontSize: 11.5,
        isBold: true,
        color: Colors.green.shade900,
      );
    }
  }

  void _paintTwoPointDrawing(Canvas canvas, Size size) {
    const double startX = 95.0;
    const double groundY = 290.0;

    final double sepMeters = result.baselineSeparation ?? 1100.0;
    final double paperSepCm = sepMeters * result.scaleFactorCmPerUnit;

    final double theta1 = result.angleDeg;
    final double theta2 = result.secondAngleDeg ?? 63.0;
    final double rad1 = theta1 * math.pi / 180.0;
    final double rad2 = theta2 * math.pi / 180.0;

    final double drawX_Cm =
        (paperSepCm * math.tan(rad2)) / (math.tan(rad2) - math.tan(rad1));
    final double drawHeightCm = drawX_Cm * math.tan(rad1);

    final double pxPerPaperCm = math
        .min(310.0 / math.max(drawX_Cm, 1.0), 205.0 / math.max(drawHeightCm, 1.0))
        .clamp(12.0, 38.0);

    final double basePx = paperSepCm * pxPerPaperCm;
    final double pxX = drawX_Cm * pxPerPaperCm;
    final double pxH = drawHeightCm * pxPerPaperCm;

    const Offset ptA = Offset(startX, groundY);
    final Offset ptB = Offset(startX + basePx, groundY);
    final Offset ptN = Offset(startX + pxX, groundY);
    final Offset ptP = Offset(ptN.dx, ptN.dy - pxH);

    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(ptA, Offset(ptN.dx + 25, groundY), stroke);
    _drawText(canvas, "A", ptA.dx - 12, ptA.dy + 14, fontSize: 13, isBold: true);
    _drawText(canvas, "B", ptB.dx, ptB.dy + 14, fontSize: 13, isBold: true);
    _drawText(canvas, "N", ptN.dx + 12, ptN.dy + 14, fontSize: 13, isBold: true);
    _drawText(
      canvas,
      "AB = ${_fmt(paperSepCm, maxDecimals: 2)} cm (${_fmt(sepMeters)} m)",
      (ptA.dx + ptB.dx) / 2,
      groundY + 30,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Sight lines from A and B to aircraft P
    canvas.drawLine(ptA, ptP, stroke);
    canvas.drawLine(ptB, ptP, stroke);

    // Perpendicular drop line PN
    canvas.drawLine(
      ptP,
      ptN,
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      "Aircraft P",
      ptP.dx,
      ptP.dy - 14,
      fontSize: 13,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Right-angle square at N
    const double sq = 9.0;
    canvas.drawPath(
      Path()
        ..moveTo(ptN.dx, ptN.dy - sq)
        ..lineTo(ptN.dx - sq, ptN.dy - sq)
        ..lineTo(ptN.dx - sq, ptN.dy),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: ptA, radius: 28),
      0,
      -rad1,
      false,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      "${_fmt(theta1)}°",
      ptA.dx + 38,
      ptA.dy - 14,
      fontSize: 11,
      isBold: true,
      color: Colors.deepPurple,
    );

    canvas.drawArc(
      Rect.fromCircle(center: ptB, radius: 26),
      0,
      -rad2,
      false,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      "${_fmt(theta2)}°",
      ptB.dx + 34,
      ptB.dy - 15,
      fontSize: 11,
      isBold: true,
      color: Colors.deepPurple,
    );

    _drawText(
      canvas,
      "PN = ${_fmt(drawHeightCm, maxDecimals: 2)} cm\n(${_fmt(result.realVertical)} m)",
      ptP.dx + 82,
      ptP.dy + pxH / 2,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade900,
    );
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
  bool shouldRepaint(covariant ScaleDrawingPainter oldDelegate) =>
      oldDelegate.result != result;
}