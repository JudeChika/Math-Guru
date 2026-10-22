import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'bearings_and_distances_logic.dart';
import 'bearings_and_distances_models.dart';

class _SurveyLandmarkControllerRow {
  final TextEditingController labelCtrl;
  final TextEditingController bearingCtrl;
  final TextEditingController distanceCtrl;

  _SurveyLandmarkControllerRow({
    String label = '',
    String bearing = '',
    String distance = '',
  })  : labelCtrl = TextEditingController(text: label),
        bearingCtrl = TextEditingController(text: bearing),
        distanceCtrl = TextEditingController(text: distance);

  SurveyLandmarkInput toModel() => SurveyLandmarkInput(
    label: labelCtrl.text,
    bearingStr: bearingCtrl.text,
    distanceStr: distanceCtrl.text,
  );

  void dispose() {
    labelCtrl.dispose();
    bearingCtrl.dispose();
    distanceCtrl.dispose();
  }
}

class BearingsAndDistancesScreen extends StatefulWidget {
  const BearingsAndDistancesScreen({super.key});

  @override
  State<BearingsAndDistancesScreen> createState() =>
      _BearingsAndDistancesScreenState();
}

class _BearingsAndDistancesScreenState
    extends State<BearingsAndDistancesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Multi-Leg Journey Scale Drawing (A -> B -> C) (Example 3, Ex 24g #1-5, #10, Rev Test #9-10)
  // 1: North/South & East/West Components Triangle (Example 4, Ex 24g #6-8)
  // 2: Surveying from Central Point P (Radial Polar Survey) (Figs 24.22-24.27, Ex 24f #1,2,4,5, Ex 24g #9)
  // 3: Two-Point Bearing Intersection / River Width Triangulation (Ex 24f #3 / Fig 24.25 & Rev Test #8)

  int _subMode = 0;
  // For Mode 1: 0 = Given Direct Distance & Bearing (Example 4), 1 = Given N/S Distance & Bearing (Ex 24g #6)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Shared Unit & Scale Controls (All Text Fields Initialized EMPTY on Launch!)
  String _unit = 'km'; // 'km' or 'm'
  bool _autoScale = true;
  final TextEditingController _customScaleCtrl = TextEditingController();

  // Mode 0, 1, 3 Point Name & Distance/Bearing Controllers (All EMPTY on Launch!)
  final TextEditingController _pt1NameCtrl = TextEditingController();
  final TextEditingController _pt2NameCtrl = TextEditingController();
  final TextEditingController _pt3NameCtrl = TextEditingController();
  final TextEditingController _dist1Ctrl = TextEditingController();
  final TextEditingController _bearing1Ctrl = TextEditingController();
  final TextEditingController _dist2Ctrl = TextEditingController();
  final TextEditingController _bearing2Ctrl = TextEditingController();

  // Mode 2 Controllers (Surveying from Central Point P — All EMPTY on Launch!)
  final TextEditingController _centerPtCtrl = TextEditingController();
  final List<_SurveyLandmarkControllerRow> _landmarkRows = [
    _SurveyLandmarkControllerRow(),
    _SurveyLandmarkControllerRow(),
    _SurveyLandmarkControllerRow(),
  ];
  int _pairIdx1 = 0; // From Landmark Index
  int _pairIdx2 = 1; // To Landmark Index

  BearingsDistancesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _customScaleCtrl.dispose();
    _pt1NameCtrl.dispose();
    _pt2NameCtrl.dispose();
    _pt3NameCtrl.dispose();
    _dist1Ctrl.dispose();
    _bearing1Ctrl.dispose();
    _dist2Ctrl.dispose();
    _bearing2Ctrl.dispose();
    _centerPtCtrl.dispose();
    for (final r in _landmarkRows) {
      r.dispose();
    }
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BearingDistancePreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _unit = p.unit;
      _autoScale = false;
      _customScaleCtrl.text = p.scaleStr;

      _pt1NameCtrl.text = p.pt1Name;
      _pt2NameCtrl.text = p.pt2Name;
      _pt3NameCtrl.text = p.pt3Name;
      _dist1Ctrl.text = p.dist1Str;
      _bearing1Ctrl.text = p.bearing1Str;
      _dist2Ctrl.text = p.dist2Str;
      _bearing2Ctrl.text = p.bearing2Str;

      if (p.landmarks.isNotEmpty) {
        _centerPtCtrl.text = p.centerPointName;
        for (final r in _landmarkRows) {
          r.dispose();
        }
        _landmarkRows.clear();
        for (final lm in p.landmarks) {
          _landmarkRows.add(_SurveyLandmarkControllerRow(
            label: lm.label,
            bearing: lm.bearingStr,
            distance: lm.distanceStr,
          ));
        }
        _pairIdx1 = p.pairIdx1;
        _pairIdx2 = p.pairIdx2;
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
              'Please enter a bearing & distance question or upload a textbook survey diagram.'),
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
      You are a strict JSON data extractor for JSS2 Section 24-3: Bearings and Distances (Surveying & Scale Drawing).
      Classify the question or diagram into one of 4 modes:
      - "mode":
        0 for Multi-Leg Journey Scale Drawing (A -> B -> C, finding resultant distance and bearing of C from A — Example 3, Ex 24g #1-5, #10, Rev Test 24 #9-10).
        1 for North/South & East/West Components of a Bearing (subMode 0: Given direct distance & bearing like Ibadan 116 km on 027° from Lagos in Example 4, Ex 24g #7, #8; subMode 1: Given N/S distance & bearing like Kaduna-Enugu-Lagos in Ex 24g #6).
        2 for Surveying from a Central Point P (Radial Polar Survey of trees, classroom block, road, railway line, or two ships from a harbour — Figures 24.22-24.27, Ex 24f #1, #2, #4, #5, Ex 24g #9).
        3 for Two-Point Bearing Intersection / River Width Triangulation (e.g. AB = 100 m or 80 m, tree on 000° from A and 290° or 300° from B — Ex 24f #3 / Fig 24.25 & Rev Test 24 #8).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "unit": "km",
        "scaleStr": "1",
        "pt1Name": "A",
        "pt2Name": "B",
        "pt3Name": "C",
        "dist1Str": "3",
        "bearing1Str": "East",
        "dist2Str": "5",
        "bearing2Str": "152°",
        "centerPointName": "P",
        "landmarks": [
          {"label": "A", "bearingStr": "060°", "distanceStr": "30"},
          {"label": "B", "bearingStr": "142°", "distanceStr": "25"},
          {"label": "C", "bearingStr": "270°", "distanceStr": "32"}
        ],
        "pairIdx1": 2,
        "pairIdx2": 0
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
        final String u = jsonMap['unit']?.toString() ?? 'km';
        _unit = (u == 'm') ? 'm' : 'km';
        if (jsonMap['scaleStr'] != null &&
            jsonMap['scaleStr'].toString().isNotEmpty) {
          _customScaleCtrl.text = jsonMap['scaleStr'].toString();
          _autoScale = false;
        } else {
          _autoScale = true;
        }
        if (jsonMap['pt1Name'] != null) {
          _pt1NameCtrl.text = jsonMap['pt1Name'].toString();
        }
        if (jsonMap['pt2Name'] != null) {
          _pt2NameCtrl.text = jsonMap['pt2Name'].toString();
        }
        if (jsonMap['pt3Name'] != null) {
          _pt3NameCtrl.text = jsonMap['pt3Name'].toString();
        }
        if (jsonMap['dist1Str'] != null) {
          _dist1Ctrl.text = jsonMap['dist1Str'].toString();
        }
        if (jsonMap['bearing1Str'] != null) {
          _bearing1Ctrl.text = jsonMap['bearing1Str'].toString();
        }
        if (jsonMap['dist2Str'] != null) {
          _dist2Ctrl.text = jsonMap['dist2Str'].toString();
        }
        if (jsonMap['bearing2Str'] != null) {
          _bearing2Ctrl.text = jsonMap['bearing2Str'].toString();
        }
        if (jsonMap['centerPointName'] != null) {
          _centerPtCtrl.text = jsonMap['centerPointName'].toString();
        }
        if (jsonMap['landmarks'] is List) {
          final List lmList = jsonMap['landmarks'] as List;
          if (lmList.isNotEmpty) {
            for (final r in _landmarkRows) {
              r.dispose();
            }
            _landmarkRows.clear();
            for (final item in lmList) {
              _landmarkRows.add(_SurveyLandmarkControllerRow(
                label: item['label']?.toString() ?? '',
                bearing: item['bearingStr']?.toString() ?? '',
                distance: item['distanceStr']?.toString() ?? '',
              ));
            }
          }
        }
        _pairIdx1 = ((jsonMap['pairIdx1'] as num?)?.toInt() ?? 0)
            .clamp(0, math.max(0, _landmarkRows.length - 1));
        _pairIdx2 = ((jsonMap['pairIdx2'] as num?)?.toInt() ?? 1)
            .clamp(0, math.max(0, _landmarkRows.length - 1));
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
        _result = BearingsAndDistancesLogic.solveMultiLegJourney(
          pt1Name: _pt1NameCtrl.text,
          pt2Name: _pt2NameCtrl.text,
          pt3Name: _pt3NameCtrl.text,
          dist1Str: _dist1Ctrl.text,
          bearing1Str: _bearing1Ctrl.text,
          dist2Str: _dist2Ctrl.text,
          bearing2Str: _bearing2Ctrl.text,
          unit: _unit,
          autoScale: _autoScale,
          customScaleStr: _customScaleCtrl.text,
        );
      } else if (_mode == 1) {
        _result = BearingsAndDistancesLogic.solveComponentsTriangle(
          subMode: _subMode,
          pt1Name: _pt1NameCtrl.text,
          pt2Name: _pt2NameCtrl.text,
          pt3Name: _pt3NameCtrl.text,
          distStr: _dist1Ctrl.text,
          bearingStr: _bearing1Ctrl.text,
          unit: _unit,
          autoScale: _autoScale,
          customScaleStr: _customScaleCtrl.text,
        );
      } else if (_mode == 2) {
        _result = BearingsAndDistancesLogic.solveRadialSurvey(
          centerPointName: _centerPtCtrl.text,
          landmarkInputs: _landmarkRows.map((r) => r.toModel()).toList(),
          pairIdx1: _pairIdx1,
          pairIdx2: _pairIdx2,
          unit: _unit,
          autoScale: _autoScale,
          customScaleStr: _customScaleCtrl.text,
        );
      } else {
        _result = BearingsAndDistancesLogic.solveRiverTriangulation(
          ptAName: _pt1NameCtrl.text,
          ptBName: _pt2NameCtrl.text,
          targetName: _pt3NameCtrl.text,
          baselineABStr: _dist1Ctrl.text,
          bearingFromAStr: _bearing1Ctrl.text,
          bearingFromBStr: _bearing2Ctrl.text,
          unit: _unit,
          autoScale: _autoScale,
          customScaleStr: _customScaleCtrl.text,
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
        ValueChanged<String>? onChanged,
      }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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
    const presets = BearingsAndDistancesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 24f, 24g & Rev Test 24):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.architecture,
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
        'label': 'Multi-Leg Journey (Ex 3 & 24g)',
        'icon': Icons.timeline,
      },
      {
        'idx': 1,
        'label': 'N/S & E/W Components (Ex 4)',
        'icon': Icons.crop_square,
      },
      {
        'idx': 2,
        'label': 'Radial Survey from P (Ex 24f)',
        'icon': Icons.radar,
      },
      {
        'idx': 3,
        'label': 'River Width Triangulation (Fig 24.25)',
        'icon': Icons.water,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Bearings & Distances Archetype:"),
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

  Widget _buildUnitAndScaleControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Divider(height: 1, color: Colors.deepPurple.shade100),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              "Distance Unit:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _unit,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  'km': Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Kilometres (km)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: _unit == 'km' ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  'm': Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Metres (m)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: _unit == 'm' ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (String? v) {
                  if (v != null) setState(() => _unit = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Auto-Pick Suitable Scale (e.g. 1 cm to 5 m or 1 cm to 20 km)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                  fontSize: 12.5,
                ),
              ),
            ),
            CupertinoSwitch(
              value: _autoScale,
              activeColor: Colors.deepPurple,
              onChanged: (v) => setState(() => _autoScale = v),
            ),
          ],
        ),
        if (!_autoScale) ...[
          const SizedBox(height: 8),
          _buildTextField(
            _customScaleCtrl,
            "Custom Scale: 1 cm represents how many $_unit?",
            hint: "e.g. 1, 5, 10, 20, 50, 100, or 250",
          ),
        ],
      ],
    );
  }

  Widget _buildModeSpecificForm() {
    final List<String> liveLandmarkLabels =
    List.generate(_landmarkRows.length, (i) {
      final String t = _landmarkRows[i].labelCtrl.text.trim();
      return t.isEmpty ? "Landmark ${i + 1}" : t;
    });

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
                "2. Multi-Leg Journey Scale Drawing (A → B → C — Ex 3 & Ex 24g):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _pt1NameCtrl,
                    "Start Point (1st)",
                    hint: "e.g. A or College",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pt2NameCtrl,
                    "Middle Point (2nd)",
                    hint: "e.g. B or Ikeja",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pt3NameCtrl,
                    "End Point (3rd)",
                    hint: "e.g. C or Market",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Leg 1 (From 1st Point to 2nd Point):",
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
                    _dist1Ctrl,
                    "Distance 1 ($_unit)",
                    hint: "e.g. 3, 14, or 200",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _bearing1Ctrl,
                    "Bearing / Direction 1",
                    hint: "e.g. East, 090°, or 032°",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Leg 2 (From 2nd Point to 3rd Point):",
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
                    _dist2Ctrl,
                    "Distance 2 ($_unit)",
                    hint: "e.g. 5, 10, or 350",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _bearing2Ctrl,
                    "Bearing / Direction 2",
                    hint: "e.g. 152°, SE, or 275°",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. North/South & East/West Components Triangle (Ex 4 & Ex 24g #6–8):"),
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
                      "Given Direct Dist & Bearing\n(Ex 4: Lagos–Ibadan, Ex 24g #7–8)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color:
                        _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Given N/S Dist & Bearing\n(Ex 24g #6: Kaduna–Enugu–Lagos)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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
            if (_subMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _pt1NameCtrl,
                      "1st Place (Origin)",
                      hint: "e.g. Lagos or Accra",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _pt2NameCtrl,
                      "2nd Place (Target)",
                      hint: "e.g. Ibadan or Banjul",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _dist1Ctrl,
                      "Direct Distance ($_unit)",
                      hint: "e.g. 116, 2000, or 180",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _bearing1Ctrl,
                      "Bearing of 2nd from 1st",
                      hint: "e.g. 027°, 295°, or 121°",
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _pt1NameCtrl,
                      "1st City (e.g. Kaduna)",
                      hint: "e.g. Kaduna",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _pt2NameCtrl,
                      "2nd City Due S/N (Enugu)",
                      hint: "e.g. Enugu",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _pt3NameCtrl,
                      "3rd City Due W/E (Lagos)",
                      hint: "e.g. Lagos",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _dist1Ctrl,
                      "N/S Distance (1st to 2nd)",
                      hint: "e.g. 450",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _bearing1Ctrl,
                      "Bearing of 3rd from 1st",
                      hint: "e.g. 225°",
                    ),
                  ),
                ],
              ),
            ],
          ] else if (_mode == 2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildSectionTitle(
                      "2. Surveying from Central Point P (Figs 24.22–24.27 & Ex 24f):"),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (_landmarkRows.length < 5) {
                      setState(() =>
                          _landmarkRows.add(_SurveyLandmarkControllerRow()));
                    }
                  },
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text("Add Point"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(
              _centerPtCtrl,
              "Central Surveyor Point Name",
              hint: "e.g. P or Harbour",
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _landmarkRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        _landmarkRows[i].labelCtrl,
                        "Point ${i + 1} Name",
                        hint: String.fromCharCode(65 + i), // A, B, C...
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        _landmarkRows[i].bearingCtrl,
                        "Bearing from P",
                        hint: "e.g. 060°",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        _landmarkRows[i].distanceCtrl,
                        "Dist ($_unit)",
                        hint: "e.g. 30",
                      ),
                    ),
                    if (_landmarkRows.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 20),
                        padding: const EdgeInsets.only(left: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _landmarkRows[i].dispose();
                            _landmarkRows.removeAt(i);
                            _pairIdx1 =
                                _pairIdx1.clamp(0, _landmarkRows.length - 1);
                            _pairIdx2 =
                                _pairIdx2.clamp(0, _landmarkRows.length - 1);
                          });
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              "Select Which Two Surveyed Landmarks to Measure Between:",
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
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _pairIdx1.clamp(0, _landmarkRows.length - 1),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                        items: List.generate(_landmarkRows.length, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text(
                              "From: ${liveLandmarkLabels[i]}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                        onChanged: (v) {
                          if (v != null) setState(() => _pairIdx1 = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _pairIdx2.clamp(0, _landmarkRows.length - 1),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                        items: List.generate(_landmarkRows.length, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text(
                              "Of (To): ${liveLandmarkLabels[i]}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                        onChanged: (v) {
                          if (v != null) setState(() => _pairIdx2 = v);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. River Width Triangulation (Ex 24f #3 / Fig 24.25 & Rev Test 24 #8):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _pt1NameCtrl,
                    "1st Bank Point (A)",
                    hint: "e.g. A",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pt2NameCtrl,
                    "2nd Bank Point East (B)",
                    hint: "e.g. B",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pt3NameCtrl,
                    "Opposite Object",
                    hint: "e.g. Tree",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _dist1Ctrl,
              "Baseline Distance AB Along River Bank ($_unit)",
              hint: "e.g. 100 (Ex 24f #3) or 80 (Rev Test 24 #8)",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _bearing1Ctrl,
                    "Bearing of Object from A",
                    hint: "e.g. 000° (Due North)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _bearing2Ctrl,
                    "Bearing of Object from B",
                    hint: "e.g. 290° or 300°",
                  ),
                ),
              ],
            ),
          ],
          _buildUnitAndScaleControls(),
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
                    "Snap a photo of any surveying sketch, multi-leg journey, or scale drawing problem from Section 24-3 (Exercises 24f & 24g)!",
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
              labelText: "Bearings & Distances Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A student starts from A and walks 3 km east to B, then walks 5 km on a bearing 152° to C. Find the distance and bearing of C from A...",
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
          _buildModeSpecificForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.architecture, color: Colors.white),
            label: const Text(
              "Construct Scale Drawing & Solve",
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
    const double canvasHeight = 430.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Millimetre Graph Paper & Surveyor Scale Drawing:",
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
          height: 420,
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
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: BearingsDistancesScalePainter(
                    data: _result!.canvasData,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "2. Final Answers (Scale Measurements & True Values):",
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
          "3. Mathematical & Scale-Drawing Workings:",
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
          "4. Step-by-Step Scale Construction Breakdown:",
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
          'Bearings & Distances',
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

class BearingsDistancesScalePainter extends CustomPainter {
  final BearingsDistancesCanvasData data;

  BearingsDistancesScalePainter({required this.data});

  String _fmt(double v) => BearingsAndDistancesLogic.fmt(v, maxDecimals: 1);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Millimetre Graph Paper Background
    final Paint minorGrid = Paint()
      ..color = Colors.red.shade50
      ..strokeWidth = 0.6;
    final Paint majorGrid = Paint()
      ..color = Colors.red.withOpacity(0.20)
      ..strokeWidth = 1.0;
    const double gridStep = 24.0;

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

    // 2. Top Header & Scale Banner
    _drawText(
      canvas,
      data.headerBadge,
      size.width / 2,
      18,
      fontSize: 13.5,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.subBadge,
      size.width / 2,
      36,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );

    if (data.mode == 0) {
      _paintMultiLegJourney(canvas, size);
    } else if (data.mode == 1) {
      _paintComponentsTriangle(canvas, size);
    } else if (data.mode == 2) {
      _paintRadialSurvey(canvas, size);
    } else {
      _paintRiverTriangulation(canvas, size);
    }
  }

  void _paintMultiLegJourney(Canvas canvas, Size size) {
    final List<Offset> ptsCm = [data.pt1Cm, data.pt2Cm, data.pt3Cm];
    final _CanvasTransform tf = _computeTransform(ptsCm, size);

    final Offset p1 = tf.toPx(data.pt1Cm);
    final Offset p2 = tf.toPx(data.pt2Cm);
    final Offset p3 = tf.toPx(data.pt3Cm);

    // Draw North Arrows N at Point 1 and N¹ at Point 2 (matching Figure 24.29!)
    _drawNorthPole(canvas, p1, "N");
    _drawNorthPole(canvas, p2, "N¹");

    // Draw Leg 1 (p1 -> p2) and Leg 2 (p2 -> p3)
    final Paint legPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3.0;
    canvas.drawLine(p1, p2, legPaint);
    canvas.drawLine(p2, p3, legPaint);

    // Draw Dashed Resultant Line (p1 -> p3)
    _drawDashedLine(
      canvas,
      p1,
      p3,
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 2.6,
    );

    // Clockwise Bearing Arcs at p1 and p2
    _drawClockwiseBearingArc(
      canvas,
      p1,
      data.leg1BearingDeg,
      data.leg1BearingLabel,
      Colors.deepPurple,
      radius: 28.0,
    );
    _drawClockwiseBearingArc(
      canvas,
      p2,
      data.leg2BearingDeg,
      data.leg2BearingLabel,
      Colors.deepPurple,
      radius: 28.0,
    );

    // Side Length Badges (showing both paper cm and real units)
    _drawBadge(
      canvas,
      "${_fmt(data.leg1PaperCm)} cm (${_fmt(data.leg1RealDist)} ${data.unit})",
      (p1.dx + p2.dx) / 2,
      (p1.dy + p2.dy) / 2 - 14,
      Colors.deepPurple,
    );
    _drawBadge(
      canvas,
      "${_fmt(data.leg2PaperCm)} cm (${_fmt(data.leg2RealDist)} ${data.unit})",
      (p2.dx + p3.dx) / 2 + 24,
      (p2.dy + p3.dy) / 2,
      Colors.deepPurple,
    );
    _drawBadge(
      canvas,
      "${data.pt1Name}${data.pt3Name} ≈ ${_fmt(data.resultantPaperCm)} cm (${_fmt(data.resultantRealDist)} ${data.unit}, ${data.resultantBearingLabel})",
      (p1.dx + p3.dx) / 2 - 18,
      (p1.dy + p3.dy) / 2 + 18,
      Colors.green.shade800,
    );

    // Vertex Circles & Labels
    for (final entry in [
      MapEntry(p1, data.pt1Name),
      MapEntry(p2, data.pt2Name),
      MapEntry(p3, data.pt3Name),
    ]) {
      canvas.drawCircle(entry.key, 5.0, Paint()..color = Colors.black87);
      _drawText(
        canvas,
        entry.value,
        entry.key.dx - 16,
        entry.key.dy + 14,
        fontSize: 13.5,
        isBold: true,
        color: Colors.black87,
      );
    }
  }

  void _paintComponentsTriangle(Canvas canvas, Size size) {
    final List<Offset> ptsCm = [data.pt1Cm, data.pt2Cm, data.pt3Cm];
    final _CanvasTransform tf = _computeTransform(ptsCm, size);

    final Offset pL = tf.toPx(data.pt1Cm); // Origin (Lagos / Kaduna)
    final Offset pK = tf.toPx(data.pt2Cm); // Projection point K on N-S line
    final Offset pI = tf.toPx(data.pt3Cm); // Target (Ibadan / Lagos)

    _drawNorthPole(canvas, pL, "N");

    // Dashed N/S leg (LK) and E/W leg (KI) matching Figure 24.30
    final Paint compPaint = Paint()
      ..color = Colors.green.shade800
      ..strokeWidth = 2.2;
    _drawDashedLine(canvas, pL, pK, compPaint);
    _drawDashedLine(canvas, pK, pI, compPaint);

    // Solid Hypotenuse Bearing Line (LI)
    canvas.drawLine(
      pL,
      pI,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 3.2,
    );

    // Right-angle square marker at K
    const double sq = 10.0;
    final double sx = pI.dx >= pK.dx ? 1.0 : -1.0;
    final double sy = pL.dy >= pK.dy ? 1.0 : -1.0;
    canvas.drawPath(
      Path()
        ..moveTo(pK.dx + sx * sq, pK.dy)
        ..lineTo(pK.dx + sx * sq, pK.dy + sy * sq)
        ..lineTo(pK.dx, pK.dy + sy * sq),
      Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    _drawClockwiseBearingArc(
      canvas,
      pL,
      data.resultantBearingDeg,
      data.resultantBearingLabel,
      Colors.deepPurple,
      radius: 30.0,
    );

    // Badges on all 3 sides
    _drawBadge(
      canvas,
      "${_fmt(data.leg1PaperCm)} cm (${_fmt(data.leg1RealDist)} ${data.unit})",
      pK.dx - sx * 56,
      (pL.dy + pK.dy) / 2,
      Colors.green.shade800,
    );
    _drawBadge(
      canvas,
      "${_fmt(data.leg2PaperCm)} cm (${_fmt(data.leg2RealDist)} ${data.unit})",
      (pK.dx + pI.dx) / 2,
      pK.dy - sy * 18,
      Colors.green.shade800,
    );
    _drawBadge(
      canvas,
      "${_fmt(data.resultantPaperCm)} cm (${_fmt(data.resultantRealDist)} ${data.unit})",
      (pL.dx + pI.dx) / 2 + sx * 48,
      (pL.dy + pI.dy) / 2,
      Colors.deepPurple,
    );

    for (final entry in [
      MapEntry(pL, data.pt1Name),
      MapEntry(pK, data.pt2Name),
      MapEntry(pI, data.pt3Name),
    ]) {
      canvas.drawCircle(entry.key, 5.0, Paint()..color = Colors.black87);
      _drawText(
        canvas,
        entry.value,
        entry.key.dx + (entry.key == pK ? -sx * 16 : 16),
        entry.key.dy + 14,
        fontSize: 13,
        isBold: true,
      );
    }
  }

  void _paintRadialSurvey(Canvas canvas, Size size) {
    final List<Offset> allCm = [
      Offset.zero,
      ...data.surveyPoints.map((p) => Offset(p.xCm, p.yCm)),
      if (data.perpFootCm != null) data.perpFootCm!,
    ];
    final _CanvasTransform tf = _computeTransform(allCm, size);
    final Offset pCenter = tf.toPx(Offset.zero);

    _drawNorthPole(canvas, pCenter, "N", len: 68.0);

    // Draw dashed radial survey lines from P to each landmark (matching Figures 24.22–24.27)
    for (int i = 0; i < data.surveyPoints.length; i++) {
      final EvaluatedSurveyPoint sp = data.surveyPoints[i];
      final Offset ptPx = tf.toPx(Offset(sp.xCm, sp.yCm));

      _drawDashedLine(
        canvas,
        pCenter,
        ptPx,
        Paint()
          ..color = sp.color
          ..strokeWidth = 2.0,
      );

      _drawBadge(
        canvas,
        "${sp.label}: (${sp.bearingFormatted}, ${_fmt(sp.realDist)} ${data.unit} = ${_fmt(sp.paperDistCm)} cm)",
        ptPx.dx.clamp(95.0, size.width - 95.0),
        (ptPx.dy + (ptPx.dy >= pCenter.dy ? 18 : -18))
            .clamp(56.0, size.height - 18.0),
        sp.color,
      );
      canvas.drawCircle(ptPx, 5.5, Paint()..color = sp.color);
    }

    // Draw solid line connecting the two selected target landmarks
    if (data.surveyPoints.length >= 2) {
      final EvaluatedSurveyPoint pFrom =
      data.surveyPoints[data.targetIdx1.clamp(0, data.surveyPoints.length - 1)];
      final EvaluatedSurveyPoint pTo =
      data.surveyPoints[data.targetIdx2.clamp(0, data.surveyPoints.length - 1)];
      final Offset pxFrom = tf.toPx(Offset(pFrom.xCm, pFrom.yCm));
      final Offset pxTo = tf.toPx(Offset(pTo.xCm, pTo.yCm));

      _drawNorthPole(canvas, pxFrom, "N¹", len: 48.0);
      canvas.drawLine(
        pxFrom,
        pxTo,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 3.0,
      );
    }

    // Optional Perpendicular Drop Line from 3rd landmark to Line 1-2 (Ex 24f #1b & #5c)
    if (data.surveyPoints.length >= 3 && data.perpFootCm != null) {
      final EvaluatedSurveyPoint p3 = data.surveyPoints[2];
      final Offset px3 = tf.toPx(Offset(p3.xCm, p3.yCm));
      final Offset pxFoot = tf.toPx(data.perpFootCm!);

      _drawDashedLine(
        canvas,
        px3,
        pxFoot,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0,
      );
      canvas.drawCircle(pxFoot, 4.0, Paint()..color = Colors.red.shade700);
    }

    canvas.drawCircle(pCenter, 5.5, Paint()..color = Colors.black87);
    _drawText(
      canvas,
      data.centerPointName,
      pCenter.dx - 16,
      pCenter.dy + 14,
      fontSize: 14,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );
  }

  void _paintRiverTriangulation(Canvas canvas, Size size) {
    final List<Offset> ptsCm = [data.pt1Cm, data.pt2Cm, data.pt3Cm];
    final _CanvasTransform tf = _computeTransform(ptsCm, size);

    final Offset pA = tf.toPx(data.pt1Cm);
    final Offset pB = tf.toPx(data.pt2Cm);
    final Offset pT = tf.toPx(data.pt3Cm);

    // Draw Shaded River Band Between Parallel Banks (matching Figure 24.25!)
    final double upperBankY = math.min(pA.dy, pT.dy);
    final double lowerBankY = math.max(pA.dy, pT.dy);
    final Rect riverRect =
    Rect.fromLTRB(40.0, upperBankY, size.width - 40.0, lowerBankY);

    canvas.drawRect(
      riverRect,
      Paint()..color = Colors.teal.shade100.withOpacity(0.55),
    );
    final Paint bankPaint = Paint()
      ..color = Colors.teal.shade800
      ..strokeWidth = 2.2;
    canvas.drawLine(
        Offset(40.0, upperBankY), Offset(size.width - 40.0, upperBankY), bankPaint);
    canvas.drawLine(
        Offset(40.0, lowerBankY), Offset(size.width - 40.0, lowerBankY), bankPaint);

    _drawText(
      canvas,
      "RIVER",
      (pA.dx + pB.dx) / 2 + 30,
      (upperBankY + lowerBankY) / 2,
      fontSize: 13,
      isBold: true,
      color: Colors.teal.shade900,
    );

    _drawNorthPole(canvas, pA, "N", len: 55.0);
    _drawNorthPole(canvas, pB, "N¹", len: 55.0);

    // Baseline AB & Intersecting Sight-Lines AT and BT
    canvas.drawLine(
      pA,
      pB,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 3.2,
    );
    _drawDashedLine(
      canvas,
      pA,
      pT,
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 2.8,
    );
    _drawDashedLine(
      canvas,
      pB,
      pT,
      Paint()
        ..color = Colors.orange.shade900
        ..strokeWidth = 2.6,
    );

    _drawClockwiseBearingArc(
      canvas,
      pB,
      data.leg2BearingDeg,
      data.leg2BearingLabel,
      Colors.orange.shade900,
      radius: 26.0,
    );

    _drawBadge(
      canvas,
      "${data.pt1Name}${data.pt2Name} = ${_fmt(data.leg1PaperCm)} cm (${_fmt(data.leg1RealDist)} ${data.unit})",
      (pA.dx + pB.dx) / 2,
      lowerBankY + 22,
      Colors.deepPurple,
    );
    _drawBadge(
      canvas,
      "Width ≈ ${_fmt(data.resultantPaperCm)} cm (${_fmt(data.resultantRealDist)} ${data.unit})",
      pA.dx - 75,
      (pA.dy + pT.dy) / 2,
      Colors.green.shade800,
    );

    for (final entry in [
      MapEntry(pA, data.pt1Name),
      MapEntry(pB, data.pt2Name),
      MapEntry(pT, "🌳 ${data.pt3Name}"),
    ]) {
      canvas.drawCircle(entry.key, 5.5, Paint()..color = Colors.black87);
      _drawText(
        canvas,
        entry.value,
        entry.key.dx,
        entry.key == pT ? entry.key.dy - 16 : entry.key.dy + 16,
        fontSize: 13,
        isBold: true,
      );
    }
  }

  _CanvasTransform _computeTransform(List<Offset> ptsCm, Size size) {
    double minX = ptsCm.map((p) => p.dx).reduce(math.min);
    double maxX = ptsCm.map((p) => p.dx).reduce(math.max);
    double minY = ptsCm.map((p) => p.dy).reduce(math.min);
    double maxY = ptsCm.map((p) => p.dy).reduce(math.max);

    final double spanX = math.max(maxX - minX, 2.0);
    final double spanY = math.max(maxY - minY, 2.0);

    const double padX = 135.0;
    const double topPad = 105.0;
    const double botPad = 55.0;

    final double availW = math.max(size.width - 2 * padX, 180.0);
    final double availH = math.max(size.height - topPad - botPad, 160.0);
    final double pxPerCm = math.min(availW / spanX, availH / spanY).clamp(15.0, 58.0);

    final double midXCm = (minX + maxX) / 2;
    final double midYCm = (minY + maxY) / 2;
    final double centerX = size.width / 2;
    final double centerY = topPad + availH / 2;

    return _CanvasTransform(
      pxPerCm: pxPerCm,
      midXCm: midXCm,
      midYCm: midYCm,
      centerX: centerX,
      centerY: centerY,
    );
  }

  void _drawNorthPole(
      Canvas canvas,
      Offset pt,
      String label, {
        double len = 58.0,
      }) {
    final Offset tip = Offset(pt.dx, pt.dy - len);
    canvas.drawLine(
      pt,
      tip,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0,
    );
    _drawArrowHead(canvas, tip, -math.pi / 2, Colors.black87, len: 8.0);
    _drawText(
      canvas,
      label,
      tip.dx,
      tip.dy - 11,
      fontSize: 12.5,
      isBold: true,
      color: Colors.red.shade800,
    );
  }

  void _drawClockwiseBearingArc(
      Canvas canvas,
      Offset center,
      double bearingDeg,
      String label,
      Color color, {
        double radius = 28.0,
      }) {
    if (bearingDeg.abs() < 1.0) return;
    const double startRad = -math.pi / 2;
    final double sweepRad = bearingDeg * math.pi / 180.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepRad,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    final double midRad = startRad + sweepRad / 2;
    _drawText(
      canvas,
      label,
      center.dx + (radius + 16) * math.cos(midRad),
      center.dy + (radius + 16) * math.sin(midRad),
      fontSize: 11,
      isBold: true,
      color: color,
    );
  }

  void _drawArrowHead(
      Canvas canvas,
      Offset tip,
      double angleRad,
      Color color, {
        double len = 8.5,
      }) {
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
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 200);
    final double dx = (p2.dx - p1.dx) / count;
    final double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      canvas.drawLine(
        Offset(p1.dx + i * dx, p1.dy + i * dy),
        Offset(p1.dx + (i + 0.6) * dx, p1.dy + (i + 0.6) * dy),
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
  bool shouldRepaint(covariant BearingsDistancesScalePainter oldDelegate) =>
      oldDelegate.data != data;
}

class _CanvasTransform {
  final double pxPerCm;
  final double midXCm;
  final double midYCm;
  final double centerX;
  final double centerY;

  const _CanvasTransform({
    required this.pxPerCm,
    required this.midXCm,
    required this.midYCm,
    required this.centerX,
    required this.centerY,
  });

  Offset toPx(Offset cm) => Offset(
    centerX + (cm.dx - midXCm) * pxPerCm,
    centerY - (cm.dy - midYCm) * pxPerCm,
  );
}