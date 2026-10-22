import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'bearings_logic.dart';
import 'bearings_models.dart';

class _MultiRayControllerRow {
  final TextEditingController pointCtrl;
  final TextEditingController angleCtrl;
  String refType;

  _MultiRayControllerRow({
    String point = '',
    String angle = '',
    this.refType = 'E_of_N',
  })  : pointCtrl = TextEditingController(text: point),
        angleCtrl = TextEditingController(text: angle);

  MultiRayInput toModel() => MultiRayInput(
    pointLabel: pointCtrl.text,
    givenAngleStr: angleCtrl.text,
    referenceType: refType,
  );

  void dispose() {
    pointCtrl.dispose();
    angleCtrl.dispose();
  }
}

class BearingsScreen extends StatefulWidget {
  const BearingsScreen({super.key});

  @override
  State<BearingsScreen> createState() => _BearingsScreenState();
}

class _BearingsScreenState extends State<BearingsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Acute-Angle <-> Three-Figure Bearing & Quadrant Sketch (Figs 24.8–24.10, Ex 24c, Ex 24e #4)
  // 1: Single-Ray Sketch Solver (Fig 24.18 / Ex 24e #1a–h)
  // 2: Multi-Ray Bearings from Central Point (Example 1 / Figs 24.14, 24.19, 24.20)
  // 3: Back Bearings & Parallel North Lines (Example 2 / Figs 24.16, 24.17, 24.21)

  int _subMode = 0; // For Mode 0: 0 = Direct Bearing String, 1 = Read Quadrant Sketch (Fig 24.10)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0 & Mode 1 Controllers (Initialized completely EMPTY on launch!)
  final TextEditingController _fromPtCtrl = TextEditingController();
  final TextEditingController _toPtCtrl = TextEditingController();
  final TextEditingController _bearingInputCtrl = TextEditingController();
  String _quadrantCode = 'NE'; // 'NE', 'SE', 'SW', 'NW'
  bool _measuredFromNS = true; // true: from N/S, false: from E/W (Fig 24.10 #4,6,7,8)
  String _sketchRefType = 'CW_N';
  final TextEditingController _givenAngleCtrl = TextEditingController();

  // Mode 2 Controllers (Multi-Ray Star Diagram — Initialized EMPTY on launch!)
  final TextEditingController _centerPtCtrl = TextEditingController();
  final List<_MultiRayControllerRow> _rayRows = [
    _MultiRayControllerRow(refType: 'E_of_N'),
    _MultiRayControllerRow(refType: 'E_of_S'),
    _MultiRayControllerRow(refType: 'W_of_S'),
    _MultiRayControllerRow(refType: 'W_of_N'),
  ];

  // Mode 3 Controllers (Back Bearings — Initialized EMPTY on launch!)
  final TextEditingController _pt1NameCtrl = TextEditingController();
  final TextEditingController _pt2NameCtrl = TextEditingController();
  int _backGivenType = 0;

  BearingsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<Map<String, String>> _sketchRefOptions = [
    {
      'key': 'CW_N',
      'label': 'Clockwise from North (N) (Fig 24.18a, b)',
    },
    {
      'key': 'ACW_N',
      'label': 'Anticlockwise (West) from North (N) (Fig 24.18e)',
    },
    {
      'key': 'CW_S',
      'label': 'Clockwise from South (S) Extension (Fig 24.18c)',
    },
    {
      'key': 'ACW_S',
      'label': 'Anticlockwise (East) from South (S) (Fig 24.18g)',
    },
    {
      'key': 'DUE_E',
      'label': 'Right Angle (90°) Due East of North (Fig 24.18f)',
    },
    {
      'key': 'DUE_W',
      'label': 'Right Angle (90°) Due West of North (Fig 24.18d)',
    },
    {
      'key': 'DUE_S',
      'label': 'Straight Down Due South (180°) (Fig 24.18h)',
    },
  ];

  static const List<Map<String, String>> _multiRayRefOptions = [
    {'key': 'E_of_N', 'label': 'E of N (Clockwise from N)'},
    {'key': 'E_of_S', 'label': 'E of S (180° − θ from S)'},
    {'key': 'W_of_S', 'label': 'W of S (180° + θ from S)'},
    {'key': 'W_of_N', 'label': 'W of N (360° − θ from N)'},
    {'key': 'N_of_E', 'label': 'N of E (90° − θ from E)'},
    {'key': 'S_of_E', 'label': 'S of E (90° + θ from E)'},
    {'key': 'S_of_W', 'label': 'S of W (270° − θ from W)'},
    {'key': 'N_of_W', 'label': 'N of W (270° + θ from W)'},
    {'key': 'CW_from_Prev', 'label': '+θ° Clockwise from Prev Ray'},
  ];

  static const List<Map<String, dynamic>> _backGivenOptions = [
    {
      'idx': 0,
      'label':
      'Clockwise Bearing of 1st Pt from 2nd Pt (e.g. X from Y = 247° — Ex 2 & Fig 24.21a,b)',
    },
    {
      'idx': 1,
      'label':
      'Clockwise Bearing of 2nd Pt from 1st Pt (e.g. B from A = 195° — Fig 24.21g)',
    },
    {
      'idx': 2,
      'label':
      'Acute Angle at 2nd Pt East of North (e.g. 57° — Fig 24.21c)',
    },
    {
      'idx': 3,
      'label':
      'Anticlockwise Reflex Angle at 2nd Pt from North (e.g. 319° — Fig 24.21f)',
    },
    {
      'idx': 4,
      'label':
      'Cardinal Alignment (0° Due N, 90° Due E, 180° Due S, 270° Due W — Fig 24.21d,e)',
    },
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _fromPtCtrl.dispose();
    _toPtCtrl.dispose();
    _bearingInputCtrl.dispose();
    _givenAngleCtrl.dispose();
    _centerPtCtrl.dispose();
    for (final r in _rayRows) {
      r.dispose();
    }
    _pt1NameCtrl.dispose();
    _pt2NameCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BearingPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _fromPtCtrl.text = p.fromPoint;
      _toPtCtrl.text = p.toPoint;
      _bearingInputCtrl.text = p.bearingInputStr;
      _quadrantCode = p.quadrantCode;
      _measuredFromNS = p.measuredFromNS;
      _sketchRefType = p.sketchRefType;
      _givenAngleCtrl.text = p.givenAngleStr;

      if (p.multiRays.isNotEmpty) {
        _centerPtCtrl.text = p.centerPoint;
        for (final r in _rayRows) {
          r.dispose();
        }
        _rayRows.clear();
        for (final mr in p.multiRays) {
          _rayRows.add(_MultiRayControllerRow(
            point: mr.pointLabel,
            angle: mr.givenAngleStr,
            refType: mr.referenceType,
          ));
        }
      }

      _pt1NameCtrl.text = p.point1Name;
      _pt2NameCtrl.text = p.point2Name;
      _backGivenType = p.backGivenType;
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
              'Please enter a bearing question or upload a textbook diagram.'),
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
      You are a strict JSON data extractor for JSS2 Section 24-2: Bearings.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Converting between Acute-Angle Bearings (N37°E, S66°W) and Three-Figure Bearings (037°, 246°), or reading a quadrant sketch (Figure 24.10 / Ex 24c #1-8, Ex 24e #4).
        1 for Single-Ray Three-Figure Bearing Sketch Solver (Figure 24.18 / Ex 24e #1a-h).
        2 for Multi-Ray Bearings from a Central Point X or O (Example 1 / Fig 24.14, Fig 24.19, Fig 24.20).
        3 for Reciprocal / Back Bearings between two points (X from Y and Y from X, or A from B and B from A — Example 2 / Fig 24.17 & Ex 24e #5 / Fig 24.21).

      Return ONLY valid JSON:
      {
        "mode": 3,
        "subMode": 0,
        "fromPoint": "A",
        "toPoint": "B",
        "bearingInputStr": "S66°W",
        "quadrantCode": "SW",
        "measuredFromNS": true,
        "sketchRefType": "CW_S",
        "givenAngleStr": "247",
        "centerPoint": "X",
        "multiRays": [
          {"point": "A", "angle": "63", "refType": "E_of_N"},
          {"point": "B", "angle": "35", "refType": "E_of_S"}
        ],
        "point1Name": "X",
        "point2Name": "Y",
        "backGivenType": 0
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
        if (jsonMap['fromPoint'] != null) {
          _fromPtCtrl.text = jsonMap['fromPoint'].toString();
        }
        if (jsonMap['toPoint'] != null) {
          _toPtCtrl.text = jsonMap['toPoint'].toString();
        }
        if (jsonMap['bearingInputStr'] != null) {
          _bearingInputCtrl.text = jsonMap['bearingInputStr'].toString();
        }
        final String qc = jsonMap['quadrantCode']?.toString() ?? 'NE';
        if (['NE', 'SE', 'SW', 'NW'].contains(qc)) _quadrantCode = qc;
        _measuredFromNS = jsonMap['measuredFromNS'] != false;
        final String sr = jsonMap['sketchRefType']?.toString() ?? 'CW_N';
        if (_sketchRefOptions.any((o) => o['key'] == sr)) _sketchRefType = sr;
        if (jsonMap['givenAngleStr'] != null) {
          _givenAngleCtrl.text = jsonMap['givenAngleStr'].toString();
        }
        if (jsonMap['centerPoint'] != null) {
          _centerPtCtrl.text = jsonMap['centerPoint'].toString();
        }
        if (jsonMap['multiRays'] is List) {
          final List mList = jsonMap['multiRays'] as List;
          if (mList.isNotEmpty) {
            for (final r in _rayRows) {
              r.dispose();
            }
            _rayRows.clear();
            for (final item in mList) {
              _rayRows.add(_MultiRayControllerRow(
                point: item['point']?.toString() ?? '',
                angle: item['angle']?.toString() ?? '',
                refType: item['refType']?.toString() ?? 'E_of_N',
              ));
            }
          }
        }
        if (jsonMap['point1Name'] != null) {
          _pt1NameCtrl.text = jsonMap['point1Name'].toString();
        }
        if (jsonMap['point2Name'] != null) {
          _pt2NameCtrl.text = jsonMap['point2Name'].toString();
        }
        _backGivenType =
            ((jsonMap['backGivenType'] as num?)?.toInt() ?? 0).clamp(0, 4);
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
        _result = BearingsLogic.solveBearingConverterAndQuadrant(
          subMode: _subMode,
          fromPointName: _fromPtCtrl.text,
          toPointName: _toPtCtrl.text,
          bearingInputStr: _bearingInputCtrl.text,
          quadrantCode: _quadrantCode,
          measuredFromNS: _measuredFromNS,
          givenAngleStr: _givenAngleCtrl.text,
        );
      } else if (_mode == 1) {
        _result = BearingsLogic.solveSingleRaySketch(
          fromPointName: _fromPtCtrl.text,
          toPointName: _toPtCtrl.text,
          sketchRefType: _sketchRefType,
          givenAngleStr: _givenAngleCtrl.text,
        );
      } else if (_mode == 2) {
        _result = BearingsLogic.solveMultiRayBearings(
          centerPointName: _centerPtCtrl.text,
          rayInputs: _rayRows.map((r) => r.toModel()).toList(),
        );
      } else {
        _result = BearingsLogic.solveBackBearings(
          point1Name: _pt1NameCtrl.text,
          point2Name: _pt2NameCtrl.text,
          backGivenType: _backGivenType,
          givenAngleStr: _givenAngleCtrl.text,
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
    const presets = BearingsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 24c & 24e):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.explore,
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
        'label': 'Acute-Angle ↔ 3-Figure (Ex 24c)',
        'icon': Icons.swap_horiz,
      },
      {
        'idx': 1,
        'label': 'Single-Ray Sketch (Fig 24.18)',
        'icon': Icons.north_east,
      },
      {
        'idx': 2,
        'label': 'Multi-Ray Star (Ex 1 & Fig 24.20)',
        'icon': Icons.hub_outlined,
      },
      {
        'idx': 3,
        'label': 'Back Bearings (Ex 2 & Fig 24.21)',
        'icon': Icons.compare_arrows,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Bearings Problem Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            final IconData iconData =
            idx == 1 ? Icons.north_east : (m['icon'] as IconData);
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
                "2. Acute-Angle Bearing (N/S θ° E/W) ↔ Three-Figure Bearing (000°):"),
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
                      "Enter Any Bearing\n(e.g. N37°E, S66°W, 246°)",
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
                      "Read Quadrant Sketch\n(Fig 24.10 / Ex 24c #1–8)",
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
                  child: _buildTextField(
                    _fromPtCtrl,
                    "Observer Point (From)",
                    hint: "e.g. B or A",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _toPtCtrl,
                    "Target Point (Of)",
                    hint: "e.g. A or Flagpole",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_subMode == 0) ...[
              _buildTextField(
                _bearingInputCtrl,
                "Enter Acute-Angle or Three-Figure Bearing",
                hint: "e.g. N37°E, S66°W, 037°, 246°, or 040°",
              ),
            ] else ...[
              const Text(
                "Select Quadrant Where Target Ray Lies (Figure 24.10):",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  {'code': 'NE', 'lbl': 'NE (North-East)'},
                  {'code': 'SE', 'lbl': 'SE (South-East)'},
                  {'code': 'SW', 'lbl': 'SW (South-West)'},
                  {'code': 'NW', 'lbl': 'NW (North-West)'},
                ].map((q) {
                  final bool isSel = _quadrantCode == q['code'];
                  return ChoiceChip(
                    label: Text(
                      q['lbl']!,
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
                      color: isSel
                          ? Colors.deepPurple
                          : Colors.deepPurple.shade200,
                    ),
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _quadrantCode = q['code']!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                "Which Axis Does the Given Angle Touch in the Sketch?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _measuredFromNS,
                  thumbColor: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade50,
                  children: {
                    true: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Touches N or S Vertical Line\n(Ex 24c #1, #2, #3, #5)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: _measuredFromNS
                              ? Colors.white
                              : Colors.deepPurple,
                        ),
                      ),
                    ),
                    false: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Touches E or W Horizontal Line\n(Ex 24c #4, #6, #7, #8)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: !_measuredFromNS
                              ? Colors.white
                              : Colors.deepPurple,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (bool? v) {
                    if (v != null) setState(() => _measuredFromNS = v);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _givenAngleCtrl,
                "Given Acute Angle in Diagram (°)",
                hint: "e.g. 58, 40, 18, 30, or 20",
              ),
            ],
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Single-Ray Three-Figure Bearing Sketch (Fig 24.18 / Ex 24e #1a–h):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _fromPtCtrl,
                    "Observer Point (From)",
                    hint: "e.g. A",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _toPtCtrl,
                    "Target Point (Of)",
                    hint: "e.g. B",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "How the Angle is Marked in the Sketch:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sketchRefType,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.deepPurple),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                  items: _sketchRefOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt['key']!,
                      child: Text(
                        opt['label']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _sketchRefType = v);
                  },
                ),
              ),
            ),
            if (!['DUE_E', 'DUE_W', 'DUE_S'].contains(_sketchRefType)) ...[
              const SizedBox(height: 12),
              _buildTextField(
                _givenAngleCtrl,
                "Given Angle in Sketch (°)",
                hint: "e.g. 56, 120, 33, or 47",
              ),
            ],
          ] else if (_mode == 2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildSectionTitle(
                      "2. Multi-Ray Bearings from Central Point (Figs 24.14, 24.19, 24.20):"),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (_rayRows.length < 6) {
                      setState(() => _rayRows.add(_MultiRayControllerRow()));
                    }
                  },
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text("Add Ray"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(
              _centerPtCtrl,
              "Central Observer Point Name",
              hint: "e.g. X or O",
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _rayRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _rayRows[i].pointCtrl,
                        "Ray ${i + 1}",
                        hint: String.fromCharCode(65 + i), // A, B, C, D...
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _rayRows[i].angleCtrl,
                        "Angle (°)",
                        hint: "e.g. 63",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                          Border.all(color: Colors.deepPurple.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _rayRows[i].refType,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                size: 18, color: Colors.deepPurple),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                            items: _multiRayRefOptions.map((opt) {
                              return DropdownMenuItem<String>(
                                value: opt['key']!,
                                child: Text(
                                  opt['label']!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _rayRows[i].refType = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_rayRows.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 20),
                        padding: const EdgeInsets.only(left: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _rayRows[i].dispose();
                            _rayRows.removeAt(i);
                          });
                        },
                      ),
                  ],
                ),
              ),
          ] else ...[
            _buildSectionTitle(
                "2. Back Bearings & Parallel North Lines (Ex 2 & Ex 24e #5a–g):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _pt1NameCtrl,
                    "1st Point Name (e.g. X or A)",
                    hint: "e.g. X or A",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pt2NameCtrl,
                    "2nd Point Name (e.g. Y or B)",
                    hint: "e.g. Y or B",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Where is the Given Angle Located in the Problem / Diagram?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _backGivenType,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.deepPurple),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  items: _backGivenOptions.map((opt) {
                    return DropdownMenuItem<int>(
                      value: opt['idx'] as int,
                      child: Text(
                        opt['label'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _backGivenType = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _givenAngleCtrl,
              "Given Bearing / Angle in Degrees (°)",
              hint: "e.g. 247, 250, 150, 57, 319, or 195",
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
                    "Snap a photo of any acute-angle bearing, three-figure bearing, multi-ray star diagram, or back-bearing question from Section 24-2!",
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
              labelText: "Bearings Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. If the bearing of X from Y is 247°, find the bearing of Y from X. Or find the three-figure bearings of A, B, C, D from X...",
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
                "Extract & Calculate Bearings",
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
            icon: const Icon(Icons.explore, color: Colors.white),
            label: const Text(
              "Calculate Bearings & Draw Diagram",
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
                "1. Interactive North-Line & Bearing Diagram Visualizer:",
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
          height: 410,
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
                  painter: BearingsDiagramPainter(
                    data: _result!.canvasData,
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
          'Bearings',
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

class BearingsDiagramPainter extends CustomPainter {
  final BearingsCanvasData data;

  BearingsDiagramPainter({required this.data});

  /// Converts a clockwise bearing from North (0° = Up, 90° = Right) to canvas radians
  double _bearingToCanvasRad(double deg) => (deg - 90.0) * math.pi / 180.0;

  String _fmt(double v) => BearingsLogic.fmt(v, maxDecimals: 1);

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      18,
      fontSize: 14.0,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.subBadge,
      cx,
      36,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );

    if (data.mode == 2) {
      _paintMultiRayStarDiagram(canvas, size);
    } else if (data.mode == 3) {
      _paintParallelNorthBackBearingDiagram(canvas, size);
    } else {
      _paintSingleRayBearingDiagram(canvas, size);
    }
  }

  // ===========================================================================
  // MODES 0 & 1: SINGLE-RAY ACUTE-ANGLE & THREE-FIGURE BEARING VISUALIZER
  // Matches Figures 24.8, 24.9, 24.10 & 24.18
  // ===========================================================================
  void _paintSingleRayBearingDiagram(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, 232.0);
    const double axisLen = 132.0;

    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    // Vertical North-South Line & Horizontal East-West Line (Figure 24.10)
    final Offset nTip = Offset(center.dx, center.dy - axisLen);
    final Offset sTip = Offset(center.dx, center.dy + axisLen);
    final Offset eTip = Offset(center.dx + axisLen, center.dy);
    final Offset wTip = Offset(center.dx - axisLen, center.dy);

    canvas.drawLine(sTip, nTip, axisPaint);
    canvas.drawLine(wTip, eTip, axisPaint);

    _drawArrowHead(canvas, nTip, -math.pi / 2, Colors.black87, len: 9.0);
    _drawArrowHead(canvas, sTip, math.pi / 2, Colors.black87, len: 7.5);
    _drawArrowHead(canvas, eTip, 0, Colors.black87, len: 7.5);
    _drawArrowHead(canvas, wTip, math.pi, Colors.black87, len: 7.5);

    _drawText(canvas, "N (000°)", nTip.dx, nTip.dy - 14,
        fontSize: 13, isBold: true, color: Colors.red.shade800);
    _drawText(canvas, "S (180°)", sTip.dx, sTip.dy + 14,
        fontSize: 12.5, isBold: true);
    _drawText(canvas, "E (090°)", eTip.dx + 32, eTip.dy,
        fontSize: 12.5, isBold: true);
    _drawText(canvas, "W (270°)", wTip.dx - 32, wTip.dy,
        fontSize: 12.5, isBold: true);

    // 1. Draw Clockwise Three-Figure Bearing Arc from North (Purple — Figure 24.9)
    final double startNorthRad = _bearingToCanvasRad(0.0);
    final double sweepThreeFigRad = data.threeFigAngleDeg * math.pi / 180.0;
    const double threeFigArcR = 46.0;

    if (sweepThreeFigRad.abs() > 1e-4) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: threeFigArcR),
        startNorthRad,
        sweepThreeFigRad,
        false,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke,
      );
      final double endThreeRad = startNorthRad + sweepThreeFigRad;
      final Offset tip3 = Offset(
        center.dx + threeFigArcR * math.cos(endThreeRad),
        center.dy + threeFigArcR * math.sin(endThreeRad),
      );
      _drawArrowHead(
          canvas, tip3, endThreeRad + math.pi / 2, Colors.deepPurple,
          len: 8.0);

      final double mid3Rad = startNorthRad + sweepThreeFigRad / 2;
      _drawBadge(
        canvas,
        data.threeFigLabel,
        center.dx + (threeFigArcR + 22) * math.cos(mid3Rad),
        center.dy + (threeFigArcR + 22) * math.sin(mid3Rad),
        Colors.deepPurple,
      );
    }

    // 2. Draw Acute-Angle Bearing Arc with North or South (Green — Figures 24.8 & 24.9)
    if (data.acuteAngleWithNS > 0.1 && data.acuteAngleWithNS < 89.9) {
      final double nsBaseDeg = data.acuteIsFromNorth ? 0.0 : 180.0;
      final double nsStartRad = _bearingToCanvasRad(nsBaseDeg);
      // Determine signed sweep from N or S towards the ray
      double signedAcuteDeg = data.acuteAngleWithNS;
      if (data.acuteIsFromNorth && !data.acuteIsTowardsEast) {
        signedAcuteDeg = -data.acuteAngleWithNS; // NW: anticlockwise from N
      } else if (!data.acuteIsFromNorth && data.acuteIsTowardsEast) {
        signedAcuteDeg = -data.acuteAngleWithNS; // SE: anticlockwise from S
      }
      final double sweepAcuteRad = signedAcuteDeg * math.pi / 180.0;
      const double acuteArcR = 82.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: acuteArcR),
        nsStartRad,
        sweepAcuteRad,
        true,
        Paint()..color = Colors.green.withOpacity(0.18),
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: acuteArcR),
        nsStartRad,
        sweepAcuteRad,
        false,
        Paint()
          ..color = Colors.green.shade800
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke,
      );

      final double midAcRad = nsStartRad + sweepAcuteRad / 2;
      _drawBadge(
        canvas,
        "${_fmt(data.acuteAngleWithNS)}° (${data.acuteBearingLabel})",
        center.dx + (acuteArcR + 26) * math.cos(midAcRad),
        center.dy + (acuteArcR + 26) * math.sin(midAcRad),
        Colors.green.shade800,
      );
    }

    // 3. Draw Target Ray from Observer Point to Target Point
    final double rayRad = _bearingToCanvasRad(data.threeFigAngleDeg);
    const double rayLen = 136.0;
    final Offset targetPos = Offset(
      center.dx + rayLen * math.cos(rayRad),
      center.dy + rayLen * math.sin(rayRad),
    );

    canvas.drawLine(
      center,
      targetPos,
      Paint()
        ..color = Colors.deepPurple.shade800
        ..strokeWidth = 3.5,
    );
    _drawArrowHead(canvas, targetPos, rayRad, Colors.deepPurple.shade800,
        len: 10.5);

    canvas.drawCircle(center, 4.5, Paint()..color = Colors.black87);
    _drawText(
      canvas,
      data.fromPointName,
      center.dx - 16,
      center.dy + 16,
      fontSize: 13.5,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );

    final Offset targetLblPos = Offset(
      center.dx + (rayLen + 26) * math.cos(rayRad),
      center.dy + (rayLen + 22) * math.sin(rayRad),
    );
    _drawBadge(
      canvas,
      data.toPointName,
      targetLblPos.dx.clamp(65.0, size.width - 65.0),
      targetLblPos.dy.clamp(58.0, size.height - 22.0),
      Colors.orange.shade900,
    );
  }

  // ===========================================================================
  // MODE 2: MULTI-RAY STAR DIAGRAM FROM CENTRAL POINT X OR O
  // Matches Figures 24.14 (Example 1), 24.19 (Ex 24e #2) & 24.20 (Ex 24e #3)
  // ===========================================================================
  void _paintMultiRayStarDiagram(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, 232.0);
    const double axisLen = 135.0;

    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    // North-South and East-West reference crosshairs
    final Offset nTip = Offset(center.dx, center.dy - axisLen);
    final Offset sTip = Offset(center.dx, center.dy + axisLen);
    final Offset eTip = Offset(center.dx + axisLen, center.dy);
    final Offset wTip = Offset(center.dx - axisLen, center.dy);

    canvas.drawLine(sTip, nTip, axisPaint);
    canvas.drawLine(
      wTip,
      eTip,
      Paint()
        ..color = Colors.grey.shade500
        ..strokeWidth = 1.4,
    );
    _drawArrowHead(canvas, nTip, -math.pi / 2, Colors.black87, len: 9.5);
    _drawText(canvas, "N", nTip.dx, nTip.dy - 14,
        fontSize: 14, isBold: true, color: Colors.red.shade800);
    _drawText(canvas, "S", sTip.dx, sTip.dy + 13,
        fontSize: 12, isBold: true, color: Colors.grey.shade700);
    _drawText(canvas, "E", eTip.dx + 14, eTip.dy,
        fontSize: 12, isBold: true, color: Colors.grey.shade700);
    _drawText(canvas, "W", wTip.dx - 14, wTip.dy,
        fontSize: 12, isBold: true, color: Colors.grey.shade700);

    const double rayLen = 126.0;
    for (int i = 0; i < data.rays.length; i++) {
      final EvaluatedRayItem ray = data.rays[i];
      final double rad = _bearingToCanvasRad(ray.threeFigDeg);
      final Offset tip = Offset(
        center.dx + rayLen * math.cos(rad),
        center.dy + rayLen * math.sin(rad),
      );

      canvas.drawLine(
        center,
        tip,
        Paint()
          ..color = ray.color
          ..strokeWidth = 3.0,
      );
      _drawArrowHead(canvas, tip, rad, ray.color, len: 9.0);

      final Offset badgePos = Offset(
        center.dx + (rayLen + 36) * math.cos(rad),
        center.dy + (rayLen + 24) * math.sin(rad),
      );
      _drawBadge(
        canvas,
        "${ray.pointLabel}: ${ray.threeFigFormatted} (${ray.referenceLabel})",
        badgePos.dx.clamp(85.0, size.width - 85.0),
        badgePos.dy.clamp(58.0, size.height - 20.0),
        ray.color,
      );
    }

    canvas.drawCircle(center, 5.0, Paint()..color = Colors.black87);
    _drawText(
      canvas,
      data.centerPointName,
      center.dx + 14,
      center.dy + 14,
      fontSize: 14,
      isBold: true,
      color: Colors.deepPurple.shade900,
    );
  }

  // ===========================================================================
  // MODE 3: PARALLEL NORTH LINES (N₁ ∥ N₂) & ALTERNATE-ANGLE BACK BEARINGS
  // Matches Example 2 (Figures 24.16 & 24.17) & Exercise 24e #5 (Figure 24.21)
  // ===========================================================================
  void _paintParallelNorthBackBearingDiagram(Canvas canvas, Size size) {
    final Offset mid = Offset(size.width / 2, 238.0);
    final double rad1From2 = _bearingToCanvasRad(data.threeFigAngleDeg);
    const double halfSep = 118.0;

    // Position Point 2 (Observer 1, e.g. Y or B) and Point 1 (Target 1, e.g. X or A)
    // so the vector from Point 2 to Point 1 matches the true bearing!
    Offset pos2 = Offset(
      mid.dx - halfSep * math.cos(rad1From2),
      mid.dy - halfSep * math.sin(rad1From2),
    );
    Offset pos1 = Offset(
      mid.dx + halfSep * math.cos(rad1From2),
      mid.dy + halfSep * math.sin(rad1From2),
    );

    // Clamp vertical positions so the North arrows at both points always fit on screen
    pos2 = Offset(pos2.dx, pos2.dy.clamp(155.0, 310.0));
    pos1 = Offset(pos1.dx, pos1.dy.clamp(155.0, 310.0));

    // Draw Parallel North Lines N₁ (at Point 2) and N₂ (at Point 1) + Dashed South Extensions
    _drawNorthSouthPoleAtPoint(
      canvas,
      pos2,
      "N₁",
      data.fromPointName,
      Colors.deepPurple,
    );
    _drawNorthSouthPoleAtPoint(
      canvas,
      pos1,
      "N₂",
      data.toPointName,
      Colors.green.shade800,
    );

    // Transversal Line Connecting Point 2 and Point 1
    canvas.drawLine(
      pos2,
      pos1,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.8,
    );

    // Draw Clockwise Forward Bearing Arc at Point 2 (Purple)
    final double actualRad2To1 =
    math.atan2(pos1.dy - pos2.dy, pos1.dx - pos2.dx);
    final double northRad = -math.pi / 2;
    double cwSweep2 = actualRad2To1 - northRad;
    if (cwSweep2 < 0) cwSweep2 += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: pos2, radius: 38.0),
      northRad,
      cwSweep2,
      false,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
    _drawBadge(
      canvas,
      "${data.toPointName} from ${data.fromPointName} = ${data.threeFigLabel}",
      pos2.dx,
      pos2.dy + 76.0,
      Colors.deepPurple,
    );

    // Draw Clockwise Back Bearing Arc at Point 1 (Green)
    final double actualRad1To2 =
    math.atan2(pos2.dy - pos1.dy, pos2.dx - pos1.dx);
    double cwSweep1 = actualRad1To2 - northRad;
    if (cwSweep1 < 0) cwSweep1 += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: pos1, radius: 38.0),
      northRad,
      cwSweep1,
      false,
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
    _drawBadge(
      canvas,
      "${data.fromPointName} from ${data.toPointName} = ${data.backBearingThreeFigLabel}",
      pos1.dx,
      pos1.dy + 76.0,
      Colors.green.shade800,
    );

    // Alternate Angle Badge in the middle of the transversal line
    _drawBadge(
      canvas,
      "Alternate Angle = ${_fmt(data.alternateAcuteDeg)}°",
      (pos1.dx + pos2.dx) / 2,
      (pos1.dy + pos2.dy) / 2 - 18,
      Colors.orange.shade900,
    );
  }

  void _drawNorthSouthPoleAtPoint(
      Canvas canvas,
      Offset pt,
      String northLabel,
      String pointLabel,
      Color color,
      ) {
    const double northLen = 82.0;
    const double southLen = 58.0;

    final Offset nTip = Offset(pt.dx, pt.dy - northLen);
    final Offset sTip = Offset(pt.dx, pt.dy + southLen);

    // Solid North Line upwards (matching Figures 24.16, 24.17 & 24.21)
    canvas.drawLine(
      pt,
      nTip,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.2,
    );
    _drawArrowHead(canvas, nTip, -math.pi / 2, Colors.black87, len: 8.5);
    _drawText(
      canvas,
      northLabel,
      nTip.dx,
      nTip.dy - 12,
      fontSize: 13,
      isBold: true,
      color: Colors.red.shade800,
    );

    // Dashed South Extension downwards (matching Figure 24.17a)
    _drawDashedLine(
      canvas,
      pt,
      sTip,
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1.6,
    );

    canvas.drawCircle(pt, 5.0, Paint()..color = color);
    _drawText(
      canvas,
      pointLabel,
      pt.dx - 18,
      pt.dy,
      fontSize: 14,
      isBold: true,
      color: color,
    );
  }

  void _drawArrowHead(
      Canvas canvas,
      Offset tip,
      double angleRad,
      Color color, {
        double len = 9.0,
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
    const double dashW = 5.0;
    const double gapW = 4.0;
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 100);
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
  bool shouldRepaint(covariant BearingsDiagramPainter oldDelegate) =>
      oldDelegate.data != data;
}