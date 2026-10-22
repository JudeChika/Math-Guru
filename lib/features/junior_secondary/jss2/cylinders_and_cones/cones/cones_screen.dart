import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'cones_logic.dart';
import 'cones_models.dart';

class _ConePreset {
  final String label;
  final int topicMode;
  final int piIndex;
  final int givenPairMode;
  final int sectorSubMode;
  final int compSubMode;
  final int revSubMode;
  final bool isRadius;
  final String dimVal;
  final String dimUnit;
  final String secondVal;
  final String secondUnit;
  final String thirdVal;
  final String thirdUnit;
  final String targetUnit;
  final String sectorRadius;
  final String sectorAngle;
  final bool isVerticalHeight;
  final String densityVal;
  final String volVal;

  const _ConePreset({
    required this.label,
    required this.topicMode,
    this.piIndex = 0,
    this.givenPairMode = 0,
    this.sectorSubMode = 0,
    this.compSubMode = 0,
    this.revSubMode = 0,
    this.isRadius = true,
    this.dimVal = '5',
    this.dimUnit = 'cm',
    this.secondVal = '12',
    this.secondUnit = 'cm',
    this.thirdVal = '24',
    this.thirdUnit = 'cm',
    this.targetUnit = 'cm',
    this.sectorRadius = '10',
    this.sectorAngle = '216',
    this.isVerticalHeight = true,
    this.densityVal = '',
    this.volVal = '308',
  });
}

class ConesScreen extends StatefulWidget {
  const ConesScreen({super.key});

  @override
  State<ConesScreen> createState() => _ConesScreenState();
}

class _ConesScreenState extends State<ConesScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _topicMode = 0; // 0: SA & Pythagoras, 1: Sector Net, 2: Volume & Mass, 3: Composite, 4: Comparison & Reverse

  // Global Pi Selector (0: In terms of π, 1: 22/7, 2: 3.14, 3: 3, 4: 3.1)
  int _piIndex = 0;
  static const List<ConePiConfig> _piConfigs = [
    ConePiConfig(
      text: 'In terms of π',
      latex: '\\pi',
      value: math.pi,
      isSymbolic: true,
    ),
    ConePiConfig(text: '22/7', latex: '\\frac{22}{7}', value: 22.0 / 7.0),
    ConePiConfig(text: '3.14', latex: '3.14', value: 3.14),
    ConePiConfig(text: '3', latex: '3', value: 3.0),
    ConePiConfig(text: '3.1', latex: '3.1', value: 3.1),
  ];

  static const List<String> _units = ['mm', 'cm', 'm'];

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Shared Primary Dimension Controllers
  bool _isRadius = true;
  final TextEditingController _dimCtrl = TextEditingController(text: '5');
  String _dimUnit = 'cm';
  final TextEditingController _secondCtrl = TextEditingController(text: '12');
  String _secondUnit = 'cm';
  final TextEditingController _thirdCtrl = TextEditingController(text: '24');
  String _thirdUnit = 'cm';
  String _targetUnit = 'cm';

  // Mode 0: Surface Area & Pythagoras (r, h, l)
  int _givenPairMode = 0; // 0: Given r/d & h, 1: Given r/d & l, 2: Given l & h

  // Mode 1: Sector Net <-> Cone Converter
  int _sectorSubMode = 0; // 0: Bend Sector into Cone, 1: Unfold Cone into Net
  final TextEditingController _sectorRadiusCtrl =
  TextEditingController(text: '10');
  final TextEditingController _sectorAngleCtrl =
  TextEditingController(text: '216');

  // Mode 2: Volume, Capacity & Mass
  bool _isVerticalHeight = true;
  final TextEditingController _densityCtrl = TextEditingController();

  // Mode 3: Composite Conical Solids
  int _compSubMode = 0; // 0: Double Cone, 1: Cylinder + Cone Mound, 2: Pencil (2 Cones)

  // Mode 4: Cone vs Cylinder Comparison & Reverse Volume
  int _revSubMode = 0; // 0: Equal Volume Cylinder Height, 1: Given V & r -> Find h, 2: Given V & h -> Find r
  final TextEditingController _volCtrl = TextEditingController(text: '308');

  ConeResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<_ConePreset> _presets = [
    _ConePreset(
      label: "Ex 5: Cone l & TSA (In terms of π)",
      topicMode: 0,
      piIndex: 0,
      givenPairMode: 0,
      isRadius: true,
      dimVal: '5',
      secondVal: '12',
    ),
    _ConePreset(
      label: "Ex 6: Sector 216° to Cone",
      topicMode: 1,
      piIndex: 0,
      sectorSubMode: 0,
      sectorRadius: '10',
      sectorAngle: '216',
    ),
    _ConePreset(
      label: "Ex 19e #5: Solid Cone TSA (π=3.14)",
      topicMode: 0,
      piIndex: 2,
      givenPairMode: 1,
      isRadius: false,
      dimVal: '10',
      secondVal: '10',
    ),
    _ConePreset(
      label: "Ex 19e #6: Solid Cone TSA (π=22/7)",
      topicMode: 0,
      piIndex: 1,
      givenPairMode: 0,
      isRadius: false,
      dimVal: '14',
      secondVal: '24',
    ),
    _ConePreset(
      label: "Ex 19e #7d: Given l=25 & h=24",
      topicMode: 0,
      piIndex: 2,
      givenPairMode: 2,
      secondVal: '25',
      thirdVal: '24',
    ),
    _ConePreset(
      label: "Ex 7: Double-Cone Machine Part",
      topicMode: 3,
      piIndex: 1,
      compSubMode: 0,
      isRadius: true,
      dimVal: '3',
      secondVal: '10',
      thirdVal: '4',
      densityVal: '8',
    ),
    _ConePreset(
      label: "Ex 8: Basin + Rice Mound",
      topicMode: 3,
      piIndex: 3,
      compSubMode: 1,
      isRadius: false,
      dimVal: '30',
      secondVal: '8',
      thirdVal: '6',
    ),
    _ConePreset(
      label: "Ex 19g #4: Cupful of Rice (π=3)",
      topicMode: 3,
      piIndex: 3,
      compSubMode: 1,
      isRadius: false,
      dimVal: '6',
      secondVal: '8',
      thirdVal: '2',
    ),
    _ConePreset(
      label: "Ex 19g #5: Sharpened Pencil",
      topicMode: 3,
      piIndex: 1,
      compSubMode: 2,
      isRadius: false,
      dimVal: '1',
      secondVal: '16',
      thirdVal: '1.2',
    ),
    _ConePreset(
      label: "Ex 19g #3: Equal Volume Cone & Cyl",
      topicMode: 4,
      piIndex: 1,
      revSubMode: 0,
      dimVal: '5',
      secondVal: '27',
    ),
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _dimCtrl.dispose();
    _secondCtrl.dispose();
    _thirdCtrl.dispose();
    _sectorRadiusCtrl.dispose();
    _sectorAngleCtrl.dispose();
    _densityCtrl.dispose();
    _volCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(_ConePreset p) {
    setState(() {
      _topicMode = p.topicMode;
      _piIndex = p.piIndex;
      _givenPairMode = p.givenPairMode;
      _sectorSubMode = p.sectorSubMode;
      _compSubMode = p.compSubMode;
      _revSubMode = p.revSubMode;
      _isRadius = p.isRadius;
      _dimCtrl.text = p.dimVal;
      _dimUnit = p.dimUnit;
      _secondCtrl.text = p.secondVal;
      _secondUnit = p.secondUnit;
      _thirdCtrl.text = p.thirdVal;
      _thirdUnit = p.thirdUnit;
      _targetUnit = p.targetUnit;
      _sectorRadiusCtrl.text = p.sectorRadius;
      _sectorAngleCtrl.text = p.sectorAngle;
      _isVerticalHeight = p.isVerticalHeight;
      _densityCtrl.text = p.densityVal;
      _volCtrl.text = p.volVal;
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
      You are a strict JSON data extractor for JSS2 Section 19-2: Cones.
      Classify the word problem or textbook image into one of 5 modes:
      - "topicMode":
        0 for Surface Area of a Cone (Curved Surface Area, Total Surface Area) and Pythagoras' Rule (finding slant height l, vertical height h, or base radius r).
        1 for Bending a Sector of a Circle (radius R, angle theta) into a Cone, or unfolding a Cone into its Sector Net.
        2 for Volume of a Single Cone (1/3 pi r^2 h), Capacity in Litres, or Mass/Density.
        3 for Composite Conical Solids (Double cone joined at base, Cylinder + conical mound on top, or Sharpened pencil with cones at both ends).
        4 for Cone vs Cylinder Equal Volume Comparison (Ex 19g #3) or Reverse Cone Volume solver.

      Note on "piIndex":
        0 for "In terms of pi"
        1 for 22/7
        2 for 3.14
        3 for 3
        4 for 3.1

      Return ONLY valid JSON:
      {
        "topicMode": 0,
        "piIndex": 0,
        "givenPairMode": 0,
        "sectorSubMode": 0,
        "compSubMode": 0,
        "revSubMode": 0,
        "isRadius": true,
        "dimVal": "5",
        "dimUnit": "cm",
        "secondVal": "12",
        "secondUnit": "cm",
        "thirdVal": "24",
        "thirdUnit": "cm",
        "targetUnit": "cm",
        "sectorRadius": "10",
        "sectorAngle": "216",
        "isVerticalHeight": true,
        "densityVal": "",
        "volVal": "308"
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
        _topicMode = ((jsonMap['topicMode'] as num?)?.toInt() ?? 0).clamp(0, 4);
        _piIndex = ((jsonMap['piIndex'] as num?)?.toInt() ?? 0).clamp(0, 4);
        _givenPairMode =
            ((jsonMap['givenPairMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _sectorSubMode =
            ((jsonMap['sectorSubMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
        _compSubMode =
            ((jsonMap['compSubMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _revSubMode =
            ((jsonMap['revSubMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _isRadius = jsonMap['isRadius'] != false;
        _dimCtrl.text = jsonMap['dimVal']?.toString() ?? '5';
        final String dU = jsonMap['dimUnit']?.toString() ?? 'cm';
        _dimUnit = _units.contains(dU) ? dU : 'cm';
        _secondCtrl.text = jsonMap['secondVal']?.toString() ?? '12';
        final String sU = jsonMap['secondUnit']?.toString() ?? 'cm';
        _secondUnit = _units.contains(sU) ? sU : 'cm';
        _thirdCtrl.text = jsonMap['thirdVal']?.toString() ?? '24';
        final String thU = jsonMap['thirdUnit']?.toString() ?? 'cm';
        _thirdUnit = _units.contains(thU) ? thU : 'cm';
        final String tU = jsonMap['targetUnit']?.toString() ?? 'cm';
        _targetUnit = _units.contains(tU) ? tU : 'cm';
        _sectorRadiusCtrl.text = jsonMap['sectorRadius']?.toString() ?? '10';
        _sectorAngleCtrl.text = jsonMap['sectorAngle']?.toString() ?? '216';
        _isVerticalHeight = jsonMap['isVerticalHeight'] != false;
        _densityCtrl.text = jsonMap['densityVal']?.toString() ?? '';
        _volCtrl.text = jsonMap['volVal']?.toString() ?? '308';
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
    final ConePiConfig pi = _piConfigs[_piIndex];

    setState(() {
      if (_topicMode == 0) {
        _result = ConesLogic.solveSurfaceAreaAndPythagoras(
          pi: pi,
          givenPairMode: _givenPairMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          dimUnit: _dimUnit,
          secondStr: _secondCtrl.text,
          secondUnit: _secondUnit,
          thirdStr: _thirdCtrl.text,
          thirdUnit: _thirdUnit,
          targetUnit: _targetUnit,
        );
      } else if (_topicMode == 1) {
        _result = ConesLogic.solveSectorAndNet(
          pi: pi,
          subMode: _sectorSubMode,
          sectorRadiusStr: _sectorRadiusCtrl.text,
          sectorAngleStr: _sectorAngleCtrl.text,
          isRadius: _isRadius,
          coneDimStr: _dimCtrl.text,
          coneSlantStr: _secondCtrl.text,
          unit: _targetUnit,
        );
      } else if (_topicMode == 2) {
        _result = ConesLogic.solveVolumeAndMass(
          pi: pi,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          dimUnit: _dimUnit,
          isVerticalHeight: _isVerticalHeight,
          heightOrSlantStr: _secondCtrl.text,
          heightUnit: _secondUnit,
          targetUnit: _targetUnit,
          densityStr: _densityCtrl.text,
        );
      } else if (_topicMode == 3) {
        _result = ConesLogic.solveCompositeSolid(
          pi: pi,
          subMode: _compSubMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          h1Str: _secondCtrl.text,
          h2Str: _thirdCtrl.text,
          unit: _targetUnit,
          densityStr: _densityCtrl.text,
        );
      } else {
        _result = ConesLogic.solveComparisonAndReverse(
          pi: pi,
          subMode: _revSubMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          hStr: _secondCtrl.text,
          volStr: _volCtrl.text,
          unit: _targetUnit,
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

  Widget _buildUnitDropdown({
    required String value,
    required ValueChanged<String> onChanged,
    String? prefixLabel,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          style: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
          items: _units.map((u) {
            final String text = prefixLabel != null ? "$prefixLabel: $u" : u;
            return DropdownMenuItem<String>(
              value: u,
              child: Text(text),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildPresetBar() {
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

  Widget _buildTopicModeSelector() {
    const List<Map<String, dynamic>> modes = [
      {'idx': 0, 'label': 'Surface Area & Pythagoras', 'icon': Icons.change_history},
      {'idx': 1, 'label': 'Sector Net ↔ Cone', 'icon': Icons.pie_chart_outline},
      {'idx': 2, 'label': 'Volume, Litres & Mass', 'icon': Icons.water_drop},
      {'idx': 3, 'label': 'Composite Conical Solids', 'icon': Icons.category},
      {'idx': 4, 'label': 'Cylinder Ratio & Reverse', 'icon': Icons.compare_arrows},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Cone Problem Type:"),
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

  Widget _buildPiSelector() {
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
              Icon(Icons.functions, color: Colors.deepPurple, size: 19),
              SizedBox(width: 6),
              Text(
                "Representation / Value of π:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_piConfigs.length, (i) {
              final bool isSel = _piIndex == i;
              return ChoiceChip(
                label: Text(
                  _piConfigs[i].text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isSel ? Colors.white : Colors.deepPurple,
                  ),
                ),
                selected: isSel,
                selectedColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
                ),
                showCheckmark: false,
                onSelected: (_) => setState(() => _piIndex = i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusDiameterToggle({
    required bool isRadiusValue,
    required ValueChanged<bool> onChanged,
    String title = "Base Measurement Given:",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple.shade800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<bool>(
            groupValue: isRadiusValue,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              true: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Base Radius (r)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isRadiusValue ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              false: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Base Diameter (d = 2r)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: !isRadiusValue ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (bool? v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurfaceAreaAndPythagorasEditor() {
    const List<Map<String, dynamic>> pairOptions = [
      {'idx': 0, 'label': 'Given Base (r/d) & Height (h)'},
      {'idx': 1, 'label': 'Given Base (r/d) & Slant (l)'},
      {'idx': 2, 'label': 'Given Slant (l) & Height (h)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Which Two Cone Dimensions Are Given?"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pairOptions.map((opt) {
            final int idx = opt['idx'] as int;
            final bool isSel = _givenPairMode == idx;
            return ChoiceChip(
              label: Text(
                opt['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSel ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSel,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color: isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _givenPairMode = idx),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_givenPairMode != 2) ...[
                _buildRadiusDiameterToggle(
                  isRadiusValue: _isRadius,
                  onChanged: (v) => setState(() => _isRadius = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _dimCtrl,
                        _isRadius ? "Base Radius (r)" : "Base Diameter (d)",
                        hint: "e.g. 5 or 14",
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildUnitDropdown(
                      value: _dimUnit,
                      onChanged: (u) => setState(() => _dimUnit = u),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _secondCtrl,
                      _givenPairMode == 0
                          ? "Vertical Height (h)"
                          : "Slant Height (l)",
                      hint: _givenPairMode == 0 ? "e.g. 12" : "e.g. 10 or 25",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitDropdown(
                    value: _secondUnit,
                    onChanged: (u) => setState(() => _secondUnit = u),
                  ),
                ],
              ),
              if (_givenPairMode == 2) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _thirdCtrl,
                        "Vertical Height (h)",
                        hint: "e.g. 24",
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildUnitDropdown(
                      value: _thirdUnit,
                      onChanged: (u) => setState(() => _thirdUnit = u),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Target Calculation Unit:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                      fontSize: 13,
                    ),
                  ),
                  _buildUnitDropdown(
                    value: _targetUnit,
                    prefixLabel: "Solve in",
                    onChanged: (u) => setState(() => _targetUnit = u),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectorAndNetEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Choose Sector / Net Conversion Direction:"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _sectorSubMode,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Fold Sector (R, θ) → Cone",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color:
                    _sectorSubMode == 0 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Unfold Cone (r, l) → Net",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color:
                    _sectorSubMode == 1 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _sectorSubMode = v);
            },
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
          ),
          child: _sectorSubMode == 0
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _sectorRadiusCtrl,
                      "Sector Radius (R = l)",
                      hint: "e.g. 10 or 12",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _sectorAngleCtrl,
                      "Sector Angle θ (°)",
                      hint: "e.g. 216 or 180",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text("Semi-circle (180°)",
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    backgroundColor: Colors.deepPurple.shade50,
                    onPressed: () =>
                        setState(() => _sectorAngleCtrl.text = '180'),
                  ),
                  ActionChip(
                    label: const Text("Quarter-circle (90°)",
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    backgroundColor: Colors.deepPurple.shade50,
                    onPressed: () =>
                        setState(() => _sectorAngleCtrl.text = '90'),
                  ),
                  ActionChip(
                    label: const Text("Ex 6 (216°)",
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    backgroundColor: Colors.deepPurple.shade50,
                    onPressed: () =>
                        setState(() => _sectorAngleCtrl.text = '216'),
                  ),
                  ActionChip(
                    label: const Text("Ex 19e #2b (144°)",
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    backgroundColor: Colors.deepPurple.shade50,
                    onPressed: () =>
                        setState(() => _sectorAngleCtrl.text = '144'),
                  ),
                ],
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadiusDiameterToggle(
                isRadiusValue: _isRadius,
                onChanged: (v) => setState(() => _isRadius = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _dimCtrl,
                      _isRadius ? "Cone Radius (r)" : "Cone Diameter (d)",
                      hint: "e.g. 5",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _secondCtrl,
                      "Cone Slant Height (l)",
                      hint: "e.g. 13",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeAndMassEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Cone Dimensions & Optional Density:"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadiusDiameterToggle(
                isRadiusValue: _isRadius,
                onChanged: (v) => setState(() => _isRadius = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _dimCtrl,
                      _isRadius ? "Base Radius (r)" : "Base Diameter (d)",
                      hint: "e.g. 7 or 1.4",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitDropdown(
                    value: _dimUnit,
                    onChanged: (u) => setState(() => _dimUnit = u),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _isVerticalHeight,
                  thumbColor: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade50,
                  children: {
                    true: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Given Vertical Height (h)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: _isVerticalHeight
                              ? Colors.white
                              : Colors.deepPurple,
                        ),
                      ),
                    ),
                    false: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Given Slant Height (l)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: !_isVerticalHeight
                              ? Colors.white
                              : Colors.deepPurple,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (bool? v) {
                    if (v != null) setState(() => _isVerticalHeight = v);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _secondCtrl,
                      _isVerticalHeight
                          ? "Vertical Height (h)"
                          : "Slant Height (l)",
                      hint: "e.g. 6 or 1.8",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitDropdown(
                    value: _secondUnit,
                    onChanged: (u) => setState(() => _secondUnit = u),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _densityCtrl,
                      "Density in g/cm³ (Optional)",
                      hint: "e.g. 8",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitDropdown(
                    value: _targetUnit,
                    prefixLabel: "Solve in",
                    onChanged: (u) => setState(() => _targetUnit = u),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompositeEditor() {
    const List<Map<String, dynamic>> compTypes = [
      {'idx': 0, 'label': 'Double Cone (Fig 19.25)'},
      {'idx': 1, 'label': 'Cup/Basin + Cone Mound (Fig 19.26)'},
      {'idx': 2, 'label': 'Sharpened Pencil (Fig 19.27)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Select Composite Solid Shape:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: compTypes.map((c) {
            final int idx = c['idx'] as int;
            final bool isSel = _compSubMode == idx;
            return ChoiceChip(
              label: Text(
                c['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSel ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSel,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color: isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _compSubMode = idx),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadiusDiameterToggle(
                isRadiusValue: _isRadius,
                onChanged: (v) => setState(() => _isRadius = v),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _dimCtrl,
                _isRadius
                    ? "Common Base Radius (r)"
                    : "Common Base Diameter (d)",
                hint: "e.g. 3, 6, 30, or 1",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _secondCtrl,
                      _compSubMode == 0
                          ? "Cone 1 Height (h₁)"
                          : "Cylinder Height / Length",
                      hint: "e.g. 10, 8, or 16",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _thirdCtrl,
                      _compSubMode == 0
                          ? "Cone 2 Height (h₂)"
                          : (_compSubMode == 1
                          ? "Cone Mound Height"
                          : "Each Conical Tip Height"),
                      hint: "e.g. 4, 2, 6, or 1.2",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _densityCtrl,
                "Density in g/cm³ for Mass in kg (Optional, e.g. 8)",
                hint: "Leave blank if mass is not asked",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonAndReverseEditor() {
    const List<Map<String, dynamic>> revOptions = [
      {'idx': 0, 'label': 'Equal Volume Cone & Cylinder (Ex 19g #3)'},
      {'idx': 1, 'label': 'Given Volume & r → Find Height (h)'},
      {'idx': 2, 'label': 'Given Volume & h → Find Radius (r)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Choose Comparison or Reverse Problem:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: revOptions.map((opt) {
            final int idx = opt['idx'] as int;
            final bool isSel = _revSubMode == idx;
            return ChoiceChip(
              label: Text(
                opt['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSel ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSel,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color: isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _revSubMode = idx),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
          ),
          child: _revSubMode == 0
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                _secondCtrl,
                "Height of Cone (h_cone)",
                hint: "e.g. 27",
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                _volCtrl,
                "Known Volume of Cone (V)",
                hint: "e.g. 308",
              ),
              const SizedBox(height: 12),
              if (_revSubMode == 1) ...[
                _buildRadiusDiameterToggle(
                  isRadiusValue: _isRadius,
                  onChanged: (v) => setState(() => _isRadius = v),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _dimCtrl,
                  _isRadius ? "Known Radius (r)" : "Known Diameter (d)",
                  hint: "e.g. 7",
                ),
              ] else
                _buildTextField(
                  _secondCtrl,
                  "Known Vertical Height (h)",
                  hint: "e.g. 6",
                ),
            ],
          ),
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
                    "Snap a photo of any cone diagram, sector net, or composite solid from Section 19-2, and the AI will set up the exact solution!",
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
              "e.g. A sector of a circle of radius 10 cm and angle 216 degrees is bent to form a cone. Find the radius of the base and curved surface area...",
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
          _buildPiSelector(),
          const SizedBox(height: 18),
          if (_topicMode == 0)
            _buildSurfaceAreaAndPythagorasEditor()
          else if (_topicMode == 1)
            _buildSectorAndNetEditor()
          else if (_topicMode == 2)
              _buildVolumeAndMassEditor()
            else if (_topicMode == 3)
                _buildCompositeEditor()
              else
                _buildComparisonAndReverseEditor(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text("Calculate & Explain",
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
    final double canvasWidth = math.max(screenWidth, 650.0);
    const double canvasHeight = 350.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Interactive 3D Cone & Net Visualizer:",
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
          height: 350,
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
                  painter: ConeVisualizerPainter(result: _result!),
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
                      padding: EdgeInsets.only(
                        top: _result!.workingsLaTeX[i].contains('\\textbf') &&
                            i > 0 &&
                            _result!.workingsLaTeX[i - 1].isNotEmpty
                            ? 14.0
                            : 5.0,
                        bottom: 5.0,
                      ),
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
          'Cones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
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

class ConeVisualizerPainter extends CustomPainter {
  final ConeResult result;

  ConeVisualizerPainter({required this.result});

  String _fmt(double v) => ConesLogic.fmt(v, maxDecimals: 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (result.mode == 3) {
      _paintCompositeSolid(canvas, size);
    } else if (result.mode == 4 && result.subMode == 0) {
      _paintConeVsCylinderComparison(canvas, size);
    } else {
      _paintConeAndSectorNet(canvas, size);
    }
  }

  void _paintConeAndSectorNet(Canvas canvas, Size size) {
    _drawText(
      canvas,
      "3D Cone Right-Triangle (r² + h² = l²) & Unfolded Sector Net",
      size.width / 2,
      22,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Left Side: 3D Cone with internal right-angled triangle (Figure 19.19)
    const double coneCx = 155.0;
    const double baseCy = 250.0;
    const double apexY = 85.0;
    const double rx = 74.0;
    const double ry = 22.0;

    const Offset apex = Offset(coneCx, apexY);
    const Offset baseCenter = Offset(coneCx, baseCy);
    const Offset baseRight = Offset(coneCx + rx, baseCy);
    const Offset baseLeft = Offset(coneCx - rx, baseCy);

    final Path coneBody = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();
    canvas.drawPath(coneBody, Paint()..color = Colors.deepPurple.shade50);

    final Rect baseOval =
    Rect.fromCenter(center: baseCenter, width: rx * 2, height: ry * 2);
    canvas.drawOval(baseOval, Paint()..color = Colors.deepPurple.shade100);

    final Paint strokePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(baseOval, strokePaint);
    canvas.drawLine(apex, baseLeft, strokePaint);
    canvas.drawLine(apex, baseRight, strokePaint);

    // Internal Right-Angled Triangle (h, r, l)
    final Paint triPaint = Paint()
      ..color = Colors.green.shade800
      ..strokeWidth = 2.2;
    canvas.drawLine(apex, baseCenter, triPaint);
    canvas.drawLine(baseCenter, baseRight, triPaint);

    // Right-angle square marker at base center
    const double sq = 9.0;
    canvas.drawPath(
      Path()
        ..moveTo(baseCenter.dx, baseCenter.dy - sq)
        ..lineTo(baseCenter.dx + sq, baseCenter.dy - sq)
        ..lineTo(baseCenter.dx + sq, baseCenter.dy),
      Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      "h = ${_fmt(result.h)} ${result.displayUnit}",
      coneCx - 34,
      (apexY + baseCy) / 2 + 10,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade900,
    );
    _drawText(
      canvas,
      "r = ${_fmt(result.r)} ${result.displayUnit}",
      coneCx + rx / 2,
      baseCy + 14,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade900,
    );
    _drawText(
      canvas,
      "l = ${_fmt(result.l)} ${result.displayUnit}",
      coneCx + rx / 2 + 34,
      (apexY + baseCy) / 2 - 4,
      fontSize: 12,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Right Side: Unfolded Sector of a Circle + Circular Base (Figure 19.15 & 19.20)
    const double secCx = 445.0;
    const double secCy = 160.0;
    const double secR = 86.0;

    final double sweepDeg = result.thetaDeg.clamp(35.0, 330.0);
    final double sweepRad = sweepDeg * math.pi / 180.0;
    final double startRad = -math.pi / 2 - sweepRad / 2;

    final Rect secRect =
    Rect.fromCircle(center: const Offset(secCx, secCy), radius: secR);
    canvas.drawArc(
      secRect,
      startRad,
      sweepRad,
      true,
      Paint()..color = Colors.green.shade50,
    );
    canvas.drawArc(
      secRect,
      startRad,
      sweepRad,
      true,
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    // Angle arc inside sector
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(secCx, secCy), radius: 26),
      startRad,
      sweepRad,
      false,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      "θ = ${_fmt(result.thetaDeg)}°",
      secCx,
      secCy - 36,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      "Sector Radius R = l = ${_fmt(result.l)} ${result.displayUnit}",
      secCx,
      secCy + secR + 24,
      fontSize: 12,
      isBold: true,
      color: Colors.green.shade900,
    );
    _drawText(
      canvas,
      "Arc Length = Base Circumference (2πr)",
      secCx,
      secCy + secR + 44,
      fontSize: 11.5,
      color: Colors.black87,
    );
  }

  void _paintCompositeSolid(Canvas canvas, Size size) {
    final Paint fillCone = Paint()..color = Colors.green.shade100;
    final Paint fillCyl = Paint()..color = Colors.deepPurple.shade50;
    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final double cx = size.width / 2;

    if (result.subMode == 0) {
      // Double Cone Joined at Base (Figure 19.25)
      _drawText(
        canvas,
        "Composite Solid: Double-Cone Machine Part (Figure 19.25)",
        cx,
        22,
        fontSize: 14.5,
        isBold: true,
        color: Colors.deepPurple,
      );

      const double midY = 185.0;
      const double rx = 70.0;
      const double ry = 20.0;
      const double h1Px = 110.0;
      const double h2Px = 65.0;

      final Offset topApex = const Offset(0, midY - h1Px) + Offset(cx, 0);
      final Offset botApex = const Offset(0, midY + h2Px) + Offset(cx, 0);
      final Offset leftMid = Offset(cx - rx, midY);
      final Offset rightMid = Offset(cx + rx, midY);

      canvas.drawPath(
        Path()
          ..moveTo(topApex.dx, topApex.dy)
          ..lineTo(leftMid.dx, leftMid.dy)
          ..lineTo(botApex.dx, botApex.dy)
          ..lineTo(rightMid.dx, rightMid.dy)
          ..close(),
        fillCone,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, midY), width: rx * 2, height: ry * 2),
        Paint()..color = Colors.deepPurple.shade100,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, midY), width: rx * 2, height: ry * 2),
        stroke,
      );
      canvas.drawLine(topApex, leftMid, stroke);
      canvas.drawLine(topApex, rightMid, stroke);
      canvas.drawLine(botApex, leftMid, stroke);
      canvas.drawLine(botApex, rightMid, stroke);

      _drawText(
        canvas,
        "r = ${_fmt(result.r)} ${result.displayUnit}",
        cx + rx / 2,
        midY - 8,
        fontSize: 11.5,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        "h₁ = ${_fmt(result.h)} ${result.displayUnit}",
        cx - rx - 45,
        midY - h1Px / 2,
        fontSize: 12,
        isBold: true,
        color: Colors.green.shade900,
      );
      _drawText(
        canvas,
        "h₂ = ${_fmt(result.h2 ?? 4)} ${result.displayUnit}",
        cx - rx - 45,
        midY + h2Px / 2,
        fontSize: 12,
        isBold: true,
        color: Colors.green.shade900,
      );
    } else if (result.subMode == 1) {
      // Cylinder + Conical Mound on Top (Figures 19.26 & 19.28)
      _drawText(
        canvas,
        "Composite Solid: Cylindrical Container + Conical Mound (Fig 19.26)",
        cx,
        22,
        fontSize: 14.5,
        isBold: true,
        color: Colors.deepPurple,
      );

      const double rimY = 155.0;
      const double botY = 265.0;
      const double apexY = 85.0;
      const double rx = 75.0;
      const double ry = 20.0;

      // Cylinder body
      canvas.drawRect(
        Rect.fromLTWH(cx - rx, rimY, rx * 2, botY - rimY),
        fillCyl,
      );
      // Cone mound on top
      canvas.drawPath(
        Path()
          ..moveTo(cx, apexY)
          ..lineTo(cx - rx, rimY)
          ..lineTo(cx + rx, rimY)
          ..close(),
        fillCone,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, rimY), width: rx * 2, height: ry * 2),
        stroke,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, botY), width: rx * 2, height: ry * 2),
        stroke,
      );
      canvas.drawLine(Offset(cx - rx, rimY), Offset(cx - rx, botY), stroke);
      canvas.drawLine(Offset(cx + rx, rimY), Offset(cx + rx, botY), stroke);
      canvas.drawLine(Offset(cx, apexY), Offset(cx - rx, rimY), stroke);
      canvas.drawLine(Offset(cx, apexY), Offset(cx + rx, rimY), stroke);

      _drawText(
        canvas,
        "r = ${_fmt(result.r)} ${result.displayUnit}",
        cx,
        botY + 28,
        fontSize: 12,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        "Cone h = ${_fmt(result.h2 ?? 2)} ${result.displayUnit}",
        cx + rx + 62,
        (apexY + rimY) / 2,
        fontSize: 12,
        isBold: true,
        color: Colors.green.shade900,
      );
      _drawText(
        canvas,
        "Cylinder h = ${_fmt(result.h)} ${result.displayUnit}",
        cx + rx + 68,
        (rimY + botY) / 2,
        fontSize: 12,
        isBold: true,
        color: Colors.deepPurple,
      );
    } else {
      // Double-Sharpened Pencil (Cylinder + 2 Cones, Figure 19.27)
      _drawText(
        canvas,
        "Composite Solid: Pencil Sharpened at Both Ends (Figure 19.27)",
        cx,
        22,
        fontSize: 14.5,
        isBold: true,
        color: Colors.deepPurple,
      );

      const double cy = 180.0;
      const double halfCylW = 135.0;
      const double coneW = 65.0;
      const double radY = 30.0;

      final double leftCylX = cx - halfCylW;
      final double rightCylX = cx + halfCylW;
      final double leftTipX = leftCylX - coneW;
      final double rightTipX = rightCylX + coneW;

      canvas.drawRect(
        Rect.fromLTWH(leftCylX, cy - radY, halfCylW * 2, radY * 2),
        fillCyl,
      );
      canvas.drawPath(
        Path()
          ..moveTo(leftTipX, cy)
          ..lineTo(leftCylX, cy - radY)
          ..lineTo(leftCylX, cy + radY)
          ..close(),
        fillCone,
      );
      canvas.drawPath(
        Path()
          ..moveTo(rightTipX, cy)
          ..lineTo(rightCylX, cy - radY)
          ..lineTo(rightCylX, cy + radY)
          ..close(),
        fillCone,
      );

      canvas.drawRect(
        Rect.fromLTWH(leftCylX, cy - radY, halfCylW * 2, radY * 2),
        stroke,
      );
      canvas.drawLine(Offset(leftTipX, cy), Offset(leftCylX, cy - radY), stroke);
      canvas.drawLine(Offset(leftTipX, cy), Offset(leftCylX, cy + radY), stroke);
      canvas.drawLine(
          Offset(rightTipX, cy), Offset(rightCylX, cy - radY), stroke);
      canvas.drawLine(
          Offset(rightTipX, cy), Offset(rightCylX, cy + radY), stroke);

      _drawText(
        canvas,
        "Cylinder = ${_fmt(result.h)} ${result.displayUnit}",
        cx,
        cy,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        "Cone = ${_fmt(result.h2 ?? 1.2)} ${result.displayUnit}",
        leftCylX - coneW / 2,
        cy + radY + 24,
        fontSize: 11.5,
        isBold: true,
        color: Colors.green.shade900,
      );
      _drawText(
        canvas,
        "Cone = ${_fmt(result.h2 ?? 1.2)} ${result.displayUnit}",
        rightCylX + coneW / 2,
        cy + radY + 24,
        fontSize: 11.5,
        isBold: true,
        color: Colors.green.shade900,
      );
    }
  }

  void _paintConeVsCylinderComparison(Canvas canvas, Size size) {
    _drawText(
      canvas,
      "Equal Volumes & Equal Bases: h_cylinder = ⅓ × h_cone (Ex 19g #3)",
      size.width / 2,
      22,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    // Left: Tall Cone (h_cone)
    const double coneCx = 185.0;
    const double botY = 275.0;
    const double coneTopY = 75.0;
    const double rx = 58.0;
    const double ry = 17.0;

    canvas.drawPath(
      Path()
        ..moveTo(coneCx, coneTopY)
        ..lineTo(coneCx - rx, botY)
        ..lineTo(coneCx + rx, botY)
        ..close(),
      Paint()..color = Colors.green.shade100,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(coneCx, botY), width: rx * 2, height: ry * 2),
      stroke,
    );
    canvas.drawLine(
        const Offset(coneCx, coneTopY), const Offset(coneCx - rx, botY), stroke);
    canvas.drawLine(
        const Offset(coneCx, coneTopY), const Offset(coneCx + rx, botY), stroke);

    _drawText(
      canvas,
      "Cone Height = ${_fmt(result.h)} ${result.displayUnit}",
      coneCx,
      botY + 32,
      fontSize: 12,
      isBold: true,
      color: Colors.green.shade900,
    );

    _drawText(canvas, "=", size.width / 2, 195,
        fontSize: 28, isBold: true, color: Colors.deepPurple);

    // Right: Cylinder of 1/3 height (h_cyl = h_cone / 3)
    const double cylCx = 455.0;
    const double cylH = (botY - coneTopY) / 3.0;
    const double cylTopY = botY - cylH;

    canvas.drawRect(
      const Rect.fromLTWH(cylCx - rx, cylTopY, rx * 2, cylH),
      Paint()..color = Colors.deepPurple.shade100,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(cylCx, cylTopY), width: rx * 2, height: ry * 2),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(cylCx, botY), width: rx * 2, height: ry * 2),
      stroke,
    );
    canvas.drawLine(
        const Offset(cylCx - rx, cylTopY), const Offset(cylCx - rx, botY), stroke);
    canvas.drawLine(
        const Offset(cylCx + rx, cylTopY), const Offset(cylCx + rx, botY), stroke);

    _drawText(
      canvas,
      "Cylinder Height = ${_fmt(result.h2 ?? (result.h / 3))} ${result.displayUnit}",
      cylCx,
      botY + 32,
      fontSize: 12,
      isBold: true,
      color: Colors.deepPurple,
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
  bool shouldRepaint(covariant ConeVisualizerPainter oldDelegate) =>
      oldDelegate.result != result;
}