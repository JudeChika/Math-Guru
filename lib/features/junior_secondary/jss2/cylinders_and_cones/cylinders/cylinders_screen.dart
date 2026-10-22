import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'cylinders_logic.dart';
import 'cylinders_models.dart';

class _CylinderPreset {
  final String label;
  final int topicMode;
  final int piIndex;
  final int saSubMode;
  final int netSubMode;
  final int revSubMode;
  final int transSubMode;
  final bool isRadius;
  final String dimVal;
  final String dimUnit;
  final String hVal;
  final String hUnit;
  final String targetUnit;
  final String costVal;
  final String stripL;
  final String stripW;
  final String nTurns;
  final String qtyVal;
  final String densityVal;
  final String volVal;
  final bool isLitres;
  final bool isRadius2;
  final String dim2Val;
  final String dropVal;
  final String rateVal;

  const _CylinderPreset({
    required this.label,
    required this.topicMode,
    this.piIndex = 0,
    this.saSubMode = 2,
    this.netSubMode = 0,
    this.revSubMode = 0,
    this.transSubMode = 0,
    this.isRadius = true,
    this.dimVal = '7',
    this.dimUnit = 'cm',
    this.hVal = '10',
    this.hUnit = 'cm',
    this.targetUnit = 'cm',
    this.costVal = '',
    this.stripL = '22',
    this.stripW = '5',
    this.nTurns = '8',
    this.qtyVal = '1',
    this.densityVal = '',
    this.volVal = '88',
    this.isLitres = true,
    this.isRadius2 = false,
    this.dim2Val = '20',
    this.dropVal = '20',
    this.rateVal = '10',
  });
}

class CylindersScreen extends StatefulWidget {
  const CylindersScreen({super.key});

  @override
  State<CylindersScreen> createState() => _CylindersScreenState();
}

class _CylindersScreenState extends State<CylindersScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _topicMode = 0; // 0: SA & Cost, 1: Nets & Winding, 2: Volume & Mass, 3: Reverse, 4: Transfer

  // Global Pi Selector (0: 22/7, 1: 3.14, 2: 3.1, 3: 3)
  int _piIndex = 0;
  static final List<PiConfig> _piConfigs = [
    PiConfig(text: '22/7', latex: '\\frac{22}{7}', value: 22.0 / 7.0),
    PiConfig(text: '3.14', latex: '3.14', value: 3.14),
    PiConfig(text: '3.1', latex: '3.1', value: 3.1),
    PiConfig(text: '3', latex: '3', value: 3.0),
  ];

  static const List<String> _units = ['mm', 'cm', 'm'];

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Shared Primary Dimension Controllers
  bool _isRadius = true;
  final TextEditingController _dimCtrl = TextEditingController(text: '7');
  String _dimUnit = 'cm';
  final TextEditingController _hCtrl = TextEditingController(text: '10');
  String _hUnit = 'cm';
  String _targetUnit = 'cm';

  // Mode 0: Surface Area & Cost
  int _saSubMode = 2; // 0: CSA, 1: Open 1 End, 2: Closed, 3: All
  final TextEditingController _costCtrl = TextEditingController();

  // Mode 1: Net & Winding
  int _netSubMode = 0; // 0: Net from Cylinder, 1: Roll Strip, 2: Winding Turns
  final TextEditingController _stripLCtrl = TextEditingController(text: '22');
  final TextEditingController _stripWCtrl = TextEditingController(text: '5');
  final TextEditingController _nTurnsCtrl = TextEditingController(text: '8');

  // Mode 2: Volume, Capacity & Mass
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  final TextEditingController _densityCtrl = TextEditingController();

  // Mode 3: Reverse Mensuration
  int _revSubMode = 0; // 0: Find Height/Depth (h), 1: Find Radius (r)
  final TextEditingController _volCtrl = TextEditingController(text: '88');
  bool _isLitres = true;

  // Mode 4: Pouring & Leaking Tank
  int _transSubMode = 0; // 0: Pouring (Cyl 1 -> Cyl 2), 1: Leaking Tank
  bool _isRadius2 = false;
  final TextEditingController _dim2Ctrl = TextEditingController(text: '20');
  final TextEditingController _dropCtrl = TextEditingController(text: '20');
  final TextEditingController _rateCtrl = TextEditingController(text: '10');

  CylinderResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<_CylinderPreset> _presets = [
    _CylinderPreset(
      label: "Ex 1: Cup CSA & Base",
      topicMode: 0,
      piIndex: 0,
      saSubMode: 3,
      isRadius: true,
      dimVal: '7',
      hVal: '10',
    ),
    _CylinderPreset(
      label: "Ex 2: Cardboard (Closed/Open)",
      topicMode: 0,
      piIndex: 2,
      saSubMode: 3,
      isRadius: true,
      dimVal: '5',
      hVal: '12',
    ),
    _CylinderPreset(
      label: "Ex 19b #5: Tin Cost (₦)",
      topicMode: 0,
      piIndex: 1,
      saSubMode: 2,
      isRadius: false,
      dimVal: '10',
      hVal: '15',
      costVal: '4500',
    ),
    _CylinderPreset(
      label: "Ex 19b #2: Wind Paper 8×",
      topicMode: 1,
      piIndex: 0,
      netSubMode: 2,
      isRadius: false,
      dimVal: '7',
      nTurns: '8',
    ),
    _CylinderPreset(
      label: "Ex 3: Can Capacity (ℓ)",
      topicMode: 2,
      piIndex: 0,
      isRadius: false,
      dimVal: '14',
      hVal: '20',
      targetUnit: 'cm',
    ),
    _CylinderPreset(
      label: "Ex 19c #7: Brass Bar Mass",
      topicMode: 2,
      piIndex: 0,
      isRadius: true,
      dimVal: '14',
      dimUnit: 'mm',
      hVal: '5',
      hUnit: 'm',
      targetUnit: 'cm',
      densityVal: '8',
    ),
    _CylinderPreset(
      label: "Ex 4: 88 ℓ Oil Drum Depth",
      topicMode: 3,
      piIndex: 0,
      revSubMode: 0,
      isRadius: false,
      dimVal: '40',
      volVal: '88',
      isLitres: true,
    ),
    _CylinderPreset(
      label: "Ex 19c #9: Pouring Cylinders",
      topicMode: 4,
      piIndex: 0,
      transSubMode: 0,
      isRadius: false,
      dimVal: '14',
      hVal: '20',
      isRadius2: false,
      dim2Val: '20',
    ),
    _CylinderPreset(
      label: "Ex 19c #10: Leaking Tank",
      topicMode: 4,
      piIndex: 0,
      transSubMode: 1,
      isRadius: false,
      dimVal: '70',
      dropVal: '20',
      rateVal: '10',
    ),
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _dimCtrl.dispose();
    _hCtrl.dispose();
    _costCtrl.dispose();
    _stripLCtrl.dispose();
    _stripWCtrl.dispose();
    _nTurnsCtrl.dispose();
    _qtyCtrl.dispose();
    _densityCtrl.dispose();
    _volCtrl.dispose();
    _dim2Ctrl.dispose();
    _dropCtrl.dispose();
    _rateCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(_CylinderPreset p) {
    setState(() {
      _topicMode = p.topicMode;
      _piIndex = p.piIndex;
      _saSubMode = p.saSubMode;
      _netSubMode = p.netSubMode;
      _revSubMode = p.revSubMode;
      _transSubMode = p.transSubMode;
      _isRadius = p.isRadius;
      _dimCtrl.text = p.dimVal;
      _dimUnit = p.dimUnit;
      _hCtrl.text = p.hVal;
      _hUnit = p.hUnit;
      _targetUnit = p.targetUnit;
      _costCtrl.text = p.costVal;
      _stripLCtrl.text = p.stripL;
      _stripWCtrl.text = p.stripW;
      _nTurnsCtrl.text = p.nTurns;
      _qtyCtrl.text = p.qtyVal;
      _densityCtrl.text = p.densityVal;
      _volCtrl.text = p.volVal;
      _isLitres = p.isLitres;
      _isRadius2 = p.isRadius2;
      _dim2Ctrl.text = p.dim2Val;
      _dropCtrl.text = p.dropVal;
      _rateCtrl.text = p.rateVal;
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
      You are a strict JSON data extractor for JSS2 Section 19-1: Cylinders.
      Classify the word problem or image into one of 5 modes:
      - "topicMode":
        0 for Surface Area (Curved, Open at 1 end, Closed) & Material Cost.
        1 for Net of a Cylinder, Rolling a rectangular strip, or Winding paper/string N times.
        2 for Volume, Capacity in Litres/Kilolitres, Multi-item pillars, or Mass/Density.
        3 for Reverse Mensuration (Given Volume/Litres, find unknown depth/height h or radius r).
        4 for Pouring liquid from Cylinder 1 into Cylinder 2, or Leaking Tank time.

      Return ONLY valid JSON:
      {
        "topicMode": 0,
        "piIndex": 0,
        "saSubMode": 2,
        "netSubMode": 0,
        "revSubMode": 0,
        "transSubMode": 0,
        "isRadius": true,
        "dimVal": "7",
        "dimUnit": "cm",
        "hVal": "10",
        "hUnit": "cm",
        "targetUnit": "cm",
        "costVal": "",
        "stripL": "22",
        "stripW": "5",
        "nTurns": "8",
        "qtyVal": "1",
        "densityVal": "",
        "volVal": "88",
        "isLitres": true,
        "isRadius2": false,
        "dim2Val": "20",
        "dropVal": "20",
        "rateVal": "10"
      }
      Note on "piIndex": 0 for 22/7, 1 for 3.14, 2 for 3.1, 3 for 3.
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
        _piIndex = ((jsonMap['piIndex'] as num?)?.toInt() ?? 0).clamp(0, 3);
        _saSubMode = ((jsonMap['saSubMode'] as num?)?.toInt() ?? 2).clamp(0, 3);
        _netSubMode =
            ((jsonMap['netSubMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _revSubMode =
            ((jsonMap['revSubMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
        _transSubMode =
            ((jsonMap['transSubMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
        _isRadius = jsonMap['isRadius'] != false;
        _dimCtrl.text = jsonMap['dimVal']?.toString() ?? '7';
        final String dU = jsonMap['dimUnit']?.toString() ?? 'cm';
        _dimUnit = _units.contains(dU) ? dU : 'cm';
        _hCtrl.text = jsonMap['hVal']?.toString() ?? '10';
        final String hU = jsonMap['hUnit']?.toString() ?? 'cm';
        _hUnit = _units.contains(hU) ? hU : 'cm';
        final String tU = jsonMap['targetUnit']?.toString() ?? 'cm';
        _targetUnit = _units.contains(tU) ? tU : 'cm';
        _costCtrl.text = jsonMap['costVal']?.toString() ?? '';
        _stripLCtrl.text = jsonMap['stripL']?.toString() ?? '22';
        _stripWCtrl.text = jsonMap['stripW']?.toString() ?? '5';
        _nTurnsCtrl.text = jsonMap['nTurns']?.toString() ?? '8';
        _qtyCtrl.text = jsonMap['qtyVal']?.toString() ?? '1';
        _densityCtrl.text = jsonMap['densityVal']?.toString() ?? '';
        _volCtrl.text = jsonMap['volVal']?.toString() ?? '88';
        _isLitres = jsonMap['isLitres'] != false;
        _isRadius2 = jsonMap['isRadius2'] == true;
        _dim2Ctrl.text = jsonMap['dim2Val']?.toString() ?? '20';
        _dropCtrl.text = jsonMap['dropVal']?.toString() ?? '20';
        _rateCtrl.text = jsonMap['rateVal']?.toString() ?? '10';
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
    final PiConfig pi = _piConfigs[_piIndex];

    setState(() {
      if (_topicMode == 0) {
        _result = CylindersLogic.solveSurfaceArea(
          pi: pi,
          saMode: _saSubMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          dimUnit: _dimUnit,
          hStr: _hCtrl.text,
          hUnit: _hUnit,
          targetUnit: _targetUnit,
          costStr: _costCtrl.text,
        );
      } else if (_topicMode == 1) {
        _result = CylindersLogic.solveNetAndWinding(
          pi: pi,
          subMode: _netSubMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          hStr: _hCtrl.text,
          stripLCtrl: _stripLCtrl.text,
          stripWCtrl: _stripWCtrl.text,
          nTurnsCtrl: _nTurnsCtrl.text,
        );
      } else if (_topicMode == 2) {
        _result = CylindersLogic.solveVolume(
          pi: pi,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          dimUnit: _dimUnit,
          hStr: _hCtrl.text,
          hUnit: _hUnit,
          targetUnit: _targetUnit,
          qtyStr: _qtyCtrl.text,
          densityStr: _densityCtrl.text,
        );
      } else if (_topicMode == 3) {
        _result = CylindersLogic.solveReverse(
          pi: pi,
          subMode: _revSubMode,
          isRadius: _isRadius,
          dimStr: _dimCtrl.text,
          hStr: _hCtrl.text,
          volStr: _volCtrl.text,
          isLitres: _isLitres,
        );
      } else {
        _result = CylindersLogic.solveTransferAndLeak(
          pi: pi,
          subMode: _transSubMode,
          isRadius1: _isRadius,
          dim1Str: _dimCtrl.text,
          h1Str: _hCtrl.text,
          isRadius2: _isRadius2,
          dim2Str: _dim2Ctrl.text,
          dropStr: _dropCtrl.text,
          rateStr: _rateCtrl.text,
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

  /// Replaces the cramped 5-tab bar with a clean, spacious, wrap-around purple chip selector.
  Widget _buildTopicModeSelector() {
    const List<Map<String, dynamic>> modes = [
      {'idx': 0, 'label': 'Surface Area & Cost', 'icon': Icons.layers},
      {'idx': 1, 'label': 'Nets & Winding', 'icon': Icons.content_cut},
      {'idx': 2, 'label': 'Volume, Litres & Mass', 'icon': Icons.water_drop},
      {'idx': 3, 'label': 'Find Unknown (h / r)', 'icon': Icons.find_replace},
      {'idx': 4, 'label': 'Pouring & Leaks', 'icon': Icons.compare_arrows},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Cylinder Problem Type:"),
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

  /// Clean, purple-accented Pi selector card.
  Widget _buildPiSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.functions, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 6),
          const Text(
            "Value of π:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _piIndex,
              thumbColor: Colors.deepPurple,
              backgroundColor: Colors.white,
              children: {
                for (int i = 0; i < _piConfigs.length; i++)
                  i: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      _piConfigs[i].text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _piIndex == i ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
              },
              onValueChanged: (int? v) {
                if (v != null) setState(() => _piIndex = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Gives the Radius (r) vs Diameter (d) toggle its own full-width row so it never wraps or clips!
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
                  "Radius (r)",
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
                  "Diameter (d = 2r)",
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

  Widget _buildStandardDimensionCard({bool showUnits = true}) {
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
                  _isRadius ? "Radius (r)" : "Diameter (d)",
                  hint: "e.g. 7 or 3 1/2",
                ),
              ),
              if (showUnits) ...[
                const SizedBox(width: 8),
                _buildUnitDropdown(
                  value: _dimUnit,
                  onChanged: (u) => setState(() => _dimUnit = u),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _hCtrl,
                  "Height / Length (h)",
                  hint: "e.g. 10 or 3 1/2",
                ),
              ),
              if (showUnits) ...[
                const SizedBox(width: 8),
                _buildUnitDropdown(
                  value: _hUnit,
                  onChanged: (u) => setState(() => _hUnit = u),
                ),
              ],
            ],
          ),
          if (showUnits) ...[
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
        ],
      ),
    );
  }

  Widget _buildSurfaceAreaEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Cylinder Surface Type:"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _saSubMode,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Curved\nOnly",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _saSubMode == 0 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Open\n(1 End)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _saSubMode == 1 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              2: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Closed\n(2 Ends)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _saSubMode == 2 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              3: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Compare\nAll",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _saSubMode == 3 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _saSubMode = v);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("3. Cylinder Dimensions:"),
        const SizedBox(height: 8),
        _buildStandardDimensionCard(showUnits: true),
        const SizedBox(height: 12),
        _buildTextField(
          _costCtrl,
          "Material Cost per m² in ₦ (Optional, e.g. 4500)",
          hint: "Leave blank if not asked",
        ),
      ],
    );
  }

  Widget _buildNetAndWindingEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Net or Winding Activity:"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _netSubMode,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Net Dimensions\n(Fig 19.5)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _netSubMode == 0 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Roll a Strip\n(Fig 19.3)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _netSubMode == 1 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              2: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Wind String\nN Times",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: _netSubMode == 2 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _netSubMode = v);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_netSubMode == 0)
          _buildStandardDimensionCard(showUnits: false)
        else if (_netSubMode == 1)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: Column(
              children: [
                _buildTextField(
                  _stripLCtrl,
                  "Paper Strip Length (Becomes Circumference)",
                  hint: "e.g. 22",
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _stripWCtrl,
                  "Paper Strip Width (Becomes Height)",
                  hint: "e.g. 5",
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: Column(
              children: [
                _buildRadiusDiameterToggle(
                  isRadiusValue: _isRadius,
                  onChanged: (v) => setState(() => _isRadius = v),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _dimCtrl,
                  _isRadius ? "Radius (r)" : "Diameter (d)",
                  hint: "e.g. 7 or 4",
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _nTurnsCtrl,
                  "Number of Turns / Winds (N)",
                  hint: "e.g. 8 or 2 1/2",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVolumeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Cylinder Dimensions & Units:"),
        const SizedBox(height: 8),
        _buildStandardDimensionCard(showUnits: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _qtyCtrl,
                "Number of Cylinders (Qty)",
                hint: "e.g. 1 or 4 pillars",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                _densityCtrl,
                "Density (g/cm³ or tons/m³)",
                hint: "Optional, e.g. 8",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReverseEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. What Dimension is Unknown?"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _revSubMode,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Find Depth / Height (h)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _revSubMode == 0 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Find Radius (r) & Diameter",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _revSubMode == 1 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _revSubMode = v);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      _volCtrl,
                      _isLitres
                          ? "Known Capacity (Litres)"
                          : "Known Volume (cm³)",
                      hint: "e.g. 88 or 99",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CupertinoSlidingSegmentedControl<bool>(
                      groupValue: _isLitres,
                      thumbColor: Colors.deepPurple,
                      backgroundColor: Colors.deepPurple.shade50,
                      children: {
                        true: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Litres (ℓ)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color:
                              _isLitres ? Colors.white : Colors.deepPurple,
                            ),
                          ),
                        ),
                        false: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "cm³",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color:
                              !_isLitres ? Colors.white : Colors.deepPurple,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (bool? v) {
                        if (v != null) setState(() => _isLitres = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_revSubMode == 0) ...[
                _buildRadiusDiameterToggle(
                  isRadiusValue: _isRadius,
                  onChanged: (v) => setState(() => _isRadius = v),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _dimCtrl,
                  _isRadius ? "Known Radius (cm)" : "Known Diameter (cm)",
                  hint: "e.g. 40 or 60",
                ),
              ] else
                _buildTextField(
                  _hCtrl,
                  "Known Height / Depth (cm)",
                  hint: "e.g. 70",
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferAndLeakEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("2. Select Real-Life Scenario:"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _transSubMode,
            thumbColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Pouring (Cyl 1 → Cyl 2)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color:
                    _transSubMode == 0 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  "Leaking Tank Rate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color:
                    _transSubMode == 1 ? Colors.white : Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _transSubMode = v);
            },
          ),
        ),
        const SizedBox(height: 14),
        if (_transSubMode == 0) ...[
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
                _buildSectionTitle("First Cylinder (Full of Water):"),
                const SizedBox(height: 8),
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
                        _isRadius ? "Radius 1 (cm)" : "Diameter 1 (cm)",
                        hint: "e.g. 14",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        _hCtrl,
                        "Height 1 (cm)",
                        hint: "e.g. 20",
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildSectionTitle("Second Cylinder (Poured Into):"),
                const SizedBox(height: 8),
                _buildRadiusDiameterToggle(
                  isRadiusValue: _isRadius2,
                  onChanged: (v) => setState(() => _isRadius2 = v),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _dim2Ctrl,
                  _isRadius2 ? "Radius 2 (cm)" : "Diameter 2 (cm)",
                  hint: "e.g. 20",
                ),
              ],
            ),
          ),
        ] else ...[
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
                  _isRadius ? "Tank Radius (cm)" : "Tank Diameter (cm)",
                  hint: "e.g. 70",
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _dropCtrl,
                        "Water Level Drop (cm)",
                        hint: "e.g. 20",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        _rateCtrl,
                        "Leak Rate (Litres/hr)",
                        hint: "e.g. 10",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                    "Snap a photo of any cylinder diagram or word problem from Chapter 19, and the AI will set up the exact formula and steps!",
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
              "e.g. A drum 40 cm in diameter contains 88 litres of oil. Use 22/7 for pi to calculate the depth of the oil...",
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
            _buildSurfaceAreaEditor()
          else if (_topicMode == 1)
            _buildNetAndWindingEditor()
          else if (_topicMode == 2)
              _buildVolumeEditor()
            else if (_topicMode == 3)
                _buildReverseEditor()
              else
                _buildTransferAndLeakEditor(),
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
    final double canvasWidth = math.max(screenWidth, 640.0);
    const double canvasHeight = 340.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Interactive 3D Cylinder & Net Visualizer:",
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
          height: 340,
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
                  painter: CylinderVisualizerPainter(result: _result!),
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
                for (final line in _result!.workingsLaTeX)
                  if (line.isEmpty)
                    const SizedBox(height: 14)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          line,
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
                  if (e.value.mathLaTeX.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          e.value.mathLaTeX,
                          textStyle: const TextStyle(
                              fontSize: 16.5,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        ),
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
          'Cylinders',
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

class CylinderVisualizerPainter extends CustomPainter {
  final CylinderResult result;

  CylinderVisualizerPainter({required this.result});

  String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (result.mode == 4 && result.subMode == 0 && result.r2 != null) {
      _paintTransferVisual(canvas, size);
    } else if (result.mode <= 1) {
      _paintCylinderAndNet(canvas, size);
    } else {
      _paintLiquidDrum(canvas, size);
    }
  }

  void _paintCylinderAndNet(Canvas canvas, Size size) {
    _drawText(
      canvas,
      "3D Cylinder & Unfolded Plane Net (2 Circles + 1 Rectangle)",
      size.width / 2,
      22,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Left: 3D Cylinder
    const double cylCx = 145.0;
    const double cylCy = 180.0;
    const double rx = 58.0;
    const double ry = 20.0;
    const double cylH = 125.0;

    final Rect topOval = Rect.fromCenter(
        center: const Offset(cylCx, cylCy - cylH / 2),
        width: rx * 2,
        height: ry * 2);
    final Rect botOval = Rect.fromCenter(
        center: const Offset(cylCx, cylCy + cylH / 2),
        width: rx * 2,
        height: ry * 2);

    final Paint bodyFill = Paint()
      ..color = Colors.deepPurple.shade50
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      const Rect.fromLTWH(cylCx - rx, cylCy - cylH / 2, rx * 2, cylH),
      bodyFill,
    );
    canvas.drawOval(
        botOval, Paint()..color = Colors.deepPurple.shade100);
    canvas.drawOval(botOval, strokePaint);
    canvas.drawOval(
        topOval, Paint()..color = Colors.deepPurple.shade100);
    canvas.drawOval(topOval, strokePaint);

    canvas.drawLine(const Offset(cylCx - rx, cylCy - cylH / 2),
        const Offset(cylCx - rx, cylCy + cylH / 2), strokePaint);
    canvas.drawLine(const Offset(cylCx + rx, cylCy - cylH / 2),
        const Offset(cylCx + rx, cylCy + cylH / 2), strokePaint);

    // Radius line on top face
    canvas.drawLine(
      const Offset(cylCx, cylCy - cylH / 2),
      const Offset(cylCx + rx, cylCy - cylH / 2),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.5,
    );
    _drawText(
      canvas,
      "r = ${_fmt(result.r)} ${result.displayUnit}",
      cylCx + rx / 2,
      cylCy - cylH / 2 - 12,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );
    _drawText(
      canvas,
      "h = ${_fmt(result.h)} ${result.displayUnit}",
      cylCx - rx - 34,
      cylCy,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    // Right: Unfolded Net (Rectangle + 2 Circles)
    const double netCx = 435.0;
    const double netCy = 180.0;
    const double rectW = 190.0;
    const double rectH = 85.0;
    const double circleR = 32.0;

    final Rect netRect =
    Rect.fromCenter(center: const Offset(netCx, netCy), width: rectW, height: rectH);
    canvas.drawRect(netRect, Paint()..color = Colors.green.shade50);
    canvas.drawRect(
      netRect,
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    const Offset topCircleCenter =
    Offset(netCx, netCy - rectH / 2 - circleR);
    const Offset botCircleCenter =
    Offset(netCx, netCy + rectH / 2 + circleR);

    for (final c in [topCircleCenter, botCircleCenter]) {
      canvas.drawCircle(c, circleR, Paint()..color = Colors.deepPurple.shade50);
      canvas.drawCircle(c, circleR, strokePaint);
    }

    _drawText(
      canvas,
      "Length = 2πr = ${_fmt(2 * 3.14159 * result.r)} ${result.displayUnit}",
      netCx,
      netCy,
      fontSize: 12,
      isBold: true,
      color: Colors.green.shade900,
    );
    _drawText(
      canvas,
      "h = ${_fmt(result.h)}",
      netCx + rectW / 2 + 28,
      netCy,
      fontSize: 11.5,
      isBold: true,
      color: Colors.deepPurple,
    );
  }

  void _paintLiquidDrum(Canvas canvas, Size size) {
    _drawText(
      canvas,
      "Cylindrical Drum Volume & Capacity Visualizer",
      size.width / 2,
      22,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    final double cx = size.width / 2;
    const double cy = 185.0;
    const double rx = 78.0;
    const double ry = 24.0;
    const double drumH = 145.0;
    const double liquidH = 95.0;

    const double topY = cy - drumH / 2;
    const double botY = cy + drumH / 2;
    const double liqTopY = botY - liquidH;

    // Liquid Fill
    canvas.drawRect(
      Rect.fromLTWH(cx - rx, liqTopY, rx * 2, liquidH),
      Paint()..color = Colors.green.shade100,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, botY), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.green.shade200,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, liqTopY), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.green.shade300,
    );

    // Drum Wireframe
    final Paint strokePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      strokePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, liqTopY), width: rx * 2, height: ry * 2),
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, botY), width: rx * 2, height: ry * 2),
      strokePaint,
    );
    canvas.drawLine(Offset(cx - rx, topY), Offset(cx - rx, botY), strokePaint);
    canvas.drawLine(Offset(cx + rx, topY), Offset(cx + rx, botY), strokePaint);

    _drawText(
      canvas,
      "r = ${_fmt(result.r)} ${result.displayUnit} (d = ${_fmt(result.r * 2)} ${result.displayUnit})",
      cx,
      topY - 32,
      fontSize: 12.5,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      "Depth / Height = ${_fmt(result.h)} ${result.displayUnit}",
      cx + rx + 85,
      liqTopY + liquidH / 2,
      fontSize: 12.5,
      isBold: true,
      color: Colors.green.shade800,
    );
  }

  void _paintTransferVisual(Canvas canvas, Size size) {
    _drawText(
      canvas,
      "Conservation of Volume: Cylinder 1 → Cylinder 2 (V₁ = V₂)",
      size.width / 2,
      22,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    _drawSingleMiniDrum(
      canvas,
      cx: 175,
      cy: 190,
      rx: 52,
      h: 125,
      fillRatio: 1.0,
      label: "Cylinder 1 (Full)\nr₁ = ${_fmt(result.r)} cm, h₁ = ${_fmt(result.h)} cm",
    );

    _drawText(canvas, "➔", size.width / 2, 185,
        fontSize: 28, isBold: true, color: Colors.deepPurple);

    final double ratio =
    ((result.h2 ?? 10) / math.max(1.0, result.h)).clamp(0.25, 0.95);
    _drawSingleMiniDrum(
      canvas,
      cx: 455,
      cy: 190,
      rx: 68,
      h: 125,
      fillRatio: ratio,
      label:
      "Cylinder 2\nr₂ = ${_fmt(result.r2!)} cm, New h₂ = ${_fmt(result.h2!)} cm",
    );
  }

  void _drawSingleMiniDrum(
      Canvas canvas, {
        required double cx,
        required double cy,
        required double rx,
        required double h,
        required double fillRatio,
        required String label,
      }) {
    const double ry = 16.0;
    final double topY = cy - h / 2;
    final double botY = cy + h / 2;
    final double liqH = h * fillRatio;
    final double liqTopY = botY - liqH;

    canvas.drawRect(
      Rect.fromLTWH(cx - rx, liqTopY, rx * 2, liqH),
      Paint()..color = Colors.green.shade100,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, botY), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.green.shade200,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, liqTopY), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.green.shade300,
    );

    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, botY), width: rx * 2, height: ry * 2),
      stroke,
    );
    canvas.drawLine(Offset(cx - rx, topY), Offset(cx - rx, botY), stroke);
    canvas.drawLine(Offset(cx + rx, topY), Offset(cx + rx, botY), stroke);

    _drawText(canvas, label, cx, botY + 38,
        fontSize: 11.5, isBold: true, color: Colors.deepPurple);
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
  bool shouldRepaint(covariant CylinderVisualizerPainter oldDelegate) =>
      oldDelegate.result != result;
}