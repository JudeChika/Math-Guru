import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'compass_directions_logic.dart';
import 'compass_directions_models.dart';

class CompassDirectionsScreen extends StatefulWidget {
  const CompassDirectionsScreen({super.key});

  @override
  State<CompassDirectionsScreen> createState() =>
      _CompassDirectionsScreenState();
}

class _CompassDirectionsScreenState extends State<CompassDirectionsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Direction & Turning Simulator (Fig 24.1 & Ex 24a #1a–d)
  // 1: Angle Between Two Compass Directions (Fig 24.4 & Ex 24a #2a–h)
  // 2: Relative Compass Bearing B from A & A from B (Fig 24.5 & Ex 24b)
  // 3: Sunrise, Sunset & Magnetic Compass Orientation Explorer (Figs 24.1 & 24.3)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0, 1 & 3 Controllers (Initialized completely EMPTY on launch!)
  final TextEditingController _startDirCtrl = TextEditingController();
  bool _turnClockwise = true; // true: Right (Clockwise), false: Left (Anticlockwise)
  final TextEditingController _turnAngleCtrl = TextEditingController();
  final TextEditingController _secondTurnAngleCtrl = TextEditingController();
  bool _secondTurnClockwise = true;

  // Mode 1 Controller (Second Direction)
  final TextEditingController _secondDirCtrl = TextEditingController();

  // Mode 2 Controllers (Relative Two-Point Bearing — Figure 24.5)
  final TextEditingController _pointACtrl = TextEditingController();
  final TextEditingController _pointBCtrl = TextEditingController();
  final TextEditingController _dirBFromACtrl = TextEditingController();

  CompassDirectionResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<String> _quickCompassCodes = [
    'N',
    'NE',
    'E',
    'SE',
    'S',
    'SW',
    'W',
    'NW',
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _startDirCtrl.dispose();
    _turnAngleCtrl.dispose();
    _secondTurnAngleCtrl.dispose();
    _secondDirCtrl.dispose();
    _pointACtrl.dispose();
    _pointBCtrl.dispose();
    _dirBFromACtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(CompassDirectionPreset p) {
    setState(() {
      _mode = p.mode;
      _startDirCtrl.text = p.startDir;
      _turnClockwise = p.turnClockwise;
      _turnAngleCtrl.text = p.turnAngleStr;
      _secondTurnAngleCtrl.text = p.secondTurnAngleStr;
      _secondTurnClockwise = p.secondTurnClockwise;
      _secondDirCtrl.text = p.secondDir;
      _pointACtrl.text = p.pointAName;
      _pointBCtrl.text = p.pointBName;
      _dirBFromACtrl.text = p.dirBFromA;
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
              'Please enter a compass direction question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS2 Section 24-1: Compass Directions.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Turning from a Starting Direction through a given angle left (anticlockwise) or right (clockwise) (Figure 24.1 & Exercise 24a #1).
        1 for Finding the Angle between two compass directions (Figure 24.4 & Exercise 24a #2).
        2 for Relative Compass Bearing between two points B from A and A from B (Figure 24.5 & Exercise 24b).
        3 for Sunrise, Sunset, Magnetic Needle & 360-degree Orientation when facing a given direction (Figures 24.1 & 24.3).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "startDir": "East",
        "turnClockwise": true,
        "turnAngleStr": "90",
        "secondTurnAngleStr": "",
        "secondTurnClockwise": true,
        "secondDir": "SW",
        "pointAName": "A",
        "pointBName": "B",
        "dirBFromA": "NW"
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
        if (jsonMap['startDir'] != null) {
          _startDirCtrl.text = jsonMap['startDir'].toString();
        }
        _turnClockwise = jsonMap['turnClockwise'] != false;
        if (jsonMap['turnAngleStr'] != null) {
          _turnAngleCtrl.text = jsonMap['turnAngleStr'].toString();
        }
        if (jsonMap['secondTurnAngleStr'] != null) {
          _secondTurnAngleCtrl.text = jsonMap['secondTurnAngleStr'].toString();
        }
        _secondTurnClockwise = jsonMap['secondTurnClockwise'] != false;
        if (jsonMap['secondDir'] != null) {
          _secondDirCtrl.text = jsonMap['secondDir'].toString();
        }
        if (jsonMap['pointAName'] != null) {
          _pointACtrl.text = jsonMap['pointAName'].toString();
        }
        if (jsonMap['pointBName'] != null) {
          _pointBCtrl.text = jsonMap['pointBName'].toString();
        }
        if (jsonMap['dirBFromA'] != null) {
          _dirBFromACtrl.text = jsonMap['dirBFromA'].toString();
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
        _result = CompassDirectionsLogic.solveDirectionTurn(
          startDirStr: _startDirCtrl.text,
          turnClockwise: _turnClockwise,
          turnAngleStr: _turnAngleCtrl.text,
          secondTurnAngleStr: _secondTurnAngleCtrl.text,
          secondTurnClockwise: _secondTurnClockwise,
        );
      } else if (_mode == 1) {
        _result = CompassDirectionsLogic.solveAngleBetweenDirections(
          firstDirStr: _startDirCtrl.text,
          secondDirStr: _secondDirCtrl.text,
        );
      } else if (_mode == 2) {
        _result = CompassDirectionsLogic.solveRelativeCompassBearing(
          pointAName: _pointACtrl.text,
          pointBName: _pointBCtrl.text,
          dirBFromAStr: _dirBFromACtrl.text,
        );
      } else {
        _result = CompassDirectionsLogic.solveOrientationExplorer(
          facingDirStr: _startDirCtrl.text,
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

  Widget _buildQuickDirectionChips(
      TextEditingController targetCtrl, {
        bool includeSun = false,
      }) {
    final List<String> items = [
      ..._quickCompassCodes,
      if (includeSun) ...['Sunrise', 'Sunset'],
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((code) {
        return ActionChip(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          label: Text(
            code,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
              color: Colors.deepPurple,
            ),
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.deepPurple.shade200),
          onPressed: () => setState(() => targetCtrl.text = code),
        );
      }).toList(),
    );
  }

  Widget _buildPresetsBar() {
    const presets = CompassDirectionsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 24a & 24b):"),
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
        'label': 'Turn Left / Right (Ex 24a #1)',
        'icon': Icons.rotate_right,
      },
      {
        'idx': 1,
        'label': 'Angle Between Directions (Ex 24a #2)',
        'icon': Icons.architecture,
      },
      {
        'idx': 2,
        'label': 'Compass Bearing B from A (Fig 24.5)',
        'icon': Icons.compare_arrows,
      },
      {
        'idx': 3,
        'label': 'Sunrise / Sunset & Orientation',
        'icon': Icons.wb_sunny_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Compass Direction Problem Mode:"),
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
                "2. Enter Starting Direction & Turn Angle (Fig 24.1 & Ex 24a #1):"),
            const SizedBox(height: 10),
            _buildTextField(
              _startDirCtrl,
              "Starting Direction You Face",
              hint: "e.g. East, E, North, NE, SW, or Sunrise",
            ),
            const SizedBox(height: 6),
            _buildQuickDirectionChips(_startDirCtrl, includeSun: true),
            const SizedBox(height: 12),
            const Text(
              "Direction of Turn:",
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
                groupValue: _turnClockwise,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  true: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "↻ Turn Right (Clockwise)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color:
                        _turnClockwise ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  false: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      "↺ Turn Left (Anticlockwise)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color:
                        !_turnClockwise ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (bool? v) {
                  if (v != null) setState(() => _turnClockwise = v);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _turnAngleCtrl,
              "Angle of Turn in Degrees (°)",
              hint: "e.g. 90, 45, 135, 180, or half turn",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTextField(
                    _secondTurnAngleCtrl,
                    "Optional 2nd Turn (°)",
                    hint: "Leave blank if 1 turn",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _secondTurnClockwise,
                    thumbColor: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade50,
                    children: {
                      true: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Text(
                          "2nd: Right ↻",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: _secondTurnClockwise
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      false: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Text(
                          "2nd: Left ↺",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: !_secondTurnClockwise
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (bool? v) {
                      if (v != null) {
                        setState(() => _secondTurnClockwise = v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Two Compass Directions to Find the Angle Between Them (Ex 24a #2):"),
            const SizedBox(height: 10),
            _buildTextField(
              _startDirCtrl,
              "First Compass Direction",
              hint: "e.g. N, NE, E, SW",
            ),
            const SizedBox(height: 6),
            _buildQuickDirectionChips(_startDirCtrl),
            const SizedBox(height: 12),
            _buildTextField(
              _secondDirCtrl,
              "Second Compass Direction",
              hint: "e.g. S, E, W, SW, NW",
            ),
            const SizedBox(height: 6),
            _buildQuickDirectionChips(_secondDirCtrl),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Two Points & Compass Bearing of B from A (Fig 24.5 & Ex 24b):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _pointACtrl,
                    "First Point Name (A)",
                    hint: "e.g. A or Lagos",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _pointBCtrl,
                    "Second Point Name (B)",
                    hint: "e.g. B or Kano",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _dirBFromACtrl,
              "Compass Direction / Bearing of B from A",
              hint: "e.g. NW, NE, N, SE, S, SW, E, or W",
            ),
            const SizedBox(height: 6),
            _buildQuickDirectionChips(_dirBFromACtrl),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Direction You Are Facing (Sunrise, Sunset, or Any Compass Point):"),
            const SizedBox(height: 10),
            _buildTextField(
              _startDirCtrl,
              "Direction You Are Facing",
              hint: "e.g. Sunrise, Sunset, East, North, NE, or SW",
            ),
            const SizedBox(height: 6),
            _buildQuickDirectionChips(_startDirCtrl, includeSun: true),
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
                    "Snap a photo of any compass direction, turning angle, or compass bearing question from Section 24-1 (Exercises 24a & 24b)!",
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
              labelText: "Compass Direction Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Face east, turn through 90 degrees to your left. What direction do you face? Or find the angle between E and SW...",
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
                "Extract & Solve Compass Problem",
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
              "Solve & Draw Compass Diagram",
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
    final double canvasWidth = math.max(screenWidth, 660.0);
    const double canvasHeight = 400.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive 8-Point Magnetic Compass Visualizer:",
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
          height: 390,
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
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: CompassRosePainter(
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
          'Compass Directions',
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

class CompassRosePainter extends CustomPainter {
  final CompassCanvasData data;

  CompassRosePainter({required this.data});

  /// Converts a compass angle (0° = North/Up, 90° = East/Right) to canvas radians
  double _compassDegToCanvasRad(double compassDeg) =>
      (compassDeg - 90.0) * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      20,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );
    _drawText(
      canvas,
      data.subBadge,
      cx,
      40,
      fontSize: 11.5,
      isBold: true,
      color: Colors.green.shade800,
    );

    if (data.mode == 2) {
      _paintTwoPointCompassBearing(canvas, size);
    } else {
      _paintSingleCompassRose(canvas, size);
    }
  }

  void _paintSingleCompassRose(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, 222.0);
    const double outerR = 122.0;

    // Subtle Sunrise (East) and Sunset (West) badges (Figure 24.1)
    _drawBadge(
      canvas,
      "🌅 Sunrise (East)",
      center.dx + outerR + 92,
      center.dy,
      Colors.amber.shade800,
    );
    _drawBadge(
      canvas,
      "🌇 Sunset (West)",
      center.dx - outerR - 92,
      center.dy,
      Colors.deepOrange.shade700,
    );

    // Outer Compass Ring (Figure 24.4)
    canvas.drawCircle(
      center,
      outerR,
      Paint()..color = Colors.deepPurple.shade50.withOpacity(0.45),
    );
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      center,
      outerR - 6,
      Paint()
        ..color = Colors.grey.shade500
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Draw all 8 Compass Spokes & Labels (N, NE, E, SE, S, SW, W, NW)
    for (final pt in CompassDirectionsLogic.eightPoints) {
      final double rad = _compassDegToCanvasRad(pt.angleDeg);
      final double lineLen = pt.isMainCardinal ? (outerR - 6) : (outerR - 14);
      final Offset tip = Offset(
        center.dx + lineLen * math.cos(rad),
        center.dy + lineLen * math.sin(rad),
      );

      canvas.drawLine(
        center,
        tip,
        Paint()
          ..color = pt.isMainCardinal ? Colors.black87 : Colors.grey.shade600
          ..strokeWidth = pt.isMainCardinal ? 2.0 : 1.3,
      );

      if (pt.isMainCardinal) {
        _drawArrowHead(canvas, tip, rad, Colors.black87, len: 8.0);
      }

      final double labelR = outerR + 20.0;
      final Offset lblPos = Offset(
        center.dx + labelR * math.cos(rad),
        center.dy + labelR * math.sin(rad),
      );
      _drawText(
        canvas,
        pt.code,
        lblPos.dx,
        lblPos.dy,
        fontSize: pt.isMainCardinal ? 14.0 : 12.0,
        isBold: true,
        color: pt.code == 'N'
            ? Colors.red.shade800
            : (pt.isMainCardinal ? Colors.black87 : Colors.deepPurple.shade700),
      );
    }

    // Draw Shaded Angle Sector / Turn Sweep Arc
    final double startRad = _compassDegToCanvasRad(data.startAngleDeg);
    final double sweepRad = data.turnSweepDeg * math.pi / 180.0;
    const double arcR = 64.0;

    if (sweepRad.abs() > 1e-4) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcR),
        startRad,
        sweepRad,
        true,
        Paint()..color = Colors.green.withOpacity(0.18),
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcR),
        startRad,
        sweepRad,
        false,
        Paint()
          ..color = Colors.green.shade800
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke,
      );

      // Arrowhead at end of turn arc
      final double endArcRad = startRad + sweepRad;
      final Offset arcTip = Offset(
        center.dx + arcR * math.cos(endArcRad),
        center.dy + arcR * math.sin(endArcRad),
      );
      final double tangentAngle =
          endArcRad + (sweepRad >= 0 ? math.pi / 2 : -math.pi / 2);
      _drawArrowHead(canvas, arcTip, tangentAngle, Colors.green.shade900,
          len: 9.0);

      // Degree label in middle of arc
      final double midRad = startRad + sweepRad / 2;
      final Offset midPos = Offset(
        center.dx + (arcR * 0.65) * math.cos(midRad),
        center.dy + (arcR * 0.65) * math.sin(midRad),
      );
      _drawBadge(
        canvas,
        "${CompassDirectionsLogic.fmt(data.turnSweepDeg.abs())}°",
        midPos.dx,
        midPos.dy,
        Colors.green.shade800,
      );
    }

    // Highlight Start Direction Ray (Purple)
    final Offset startRayEnd = Offset(
      center.dx + (outerR - 8) * math.cos(startRad),
      center.dy + (outerR - 8) * math.sin(startRad),
    );
    canvas.drawLine(
      center,
      startRayEnd,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 3.8,
    );
    _drawArrowHead(canvas, startRayEnd, startRad, Colors.deepPurple, len: 11.0);

    // Highlight End Direction Ray (Green)
    final double endRad = _compassDegToCanvasRad(data.endAngleDeg);
    final Offset endRayEnd = Offset(
      center.dx + (outerR - 8) * math.cos(endRad),
      center.dy + (outerR - 8) * math.sin(endRad),
    );
    canvas.drawLine(
      center,
      endRayEnd,
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 3.8,
    );
    _drawArrowHead(canvas, endRayEnd, endRad, Colors.green.shade700, len: 11.0);

    // Optional Second Turn Ray (Orange)
    if (data.finalAfterSecondTurnDeg != null) {
      final double fin2Rad =
      _compassDegToCanvasRad(data.finalAfterSecondTurnDeg!);
      final Offset fin2End = Offset(
        center.dx + (outerR - 8) * math.cos(fin2Rad),
        center.dy + (outerR - 8) * math.sin(fin2Rad),
      );
      canvas.drawLine(
        center,
        fin2End,
        Paint()
          ..color = Colors.orange.shade800
          ..strokeWidth = 3.4,
      );
      _drawArrowHead(
          canvas, fin2End, fin2Rad, Colors.orange.shade800, len: 10.0);
    }

    canvas.drawCircle(center, 5.0, Paint()..color = Colors.black87);
  }

  void _paintTwoPointCompassBearing(Canvas canvas, Size size) {
    final Offset mid = Offset(size.width / 2, 225.0);
    final double radBFromA = _compassDegToCanvasRad(data.startAngleDeg);
    const double halfSep = 115.0;

    // Position A and B so the vector from A to B matches the true compass direction!
    final Offset posA = Offset(
      mid.dx - halfSep * math.cos(radBFromA),
      mid.dy - halfSep * math.sin(radBFromA),
    );
    final Offset posB = Offset(
      mid.dx + halfSep * math.cos(radBFromA),
      mid.dy + halfSep * math.sin(radBFromA),
    );

    // Dashed Line of Sight AB (matching Figure 24.5)
    _drawDashedLine(
      canvas,
      posA,
      posB,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 2.2,
    );

    // Draw Mini Compass Rose at A and at B (with North arrows pointing straight up)
    _drawMiniCompassAtPoint(
      canvas,
      posA,
      data.pointAName,
      "At ${data.pointAName}: ${data.pointBName} is ${data.dirBFromACode}",
      Colors.deepPurple,
    );
    _drawMiniCompassAtPoint(
      canvas,
      posB,
      data.pointBName,
      "At ${data.pointBName}: ${data.pointAName} is ${data.dirAFromBCode}",
      Colors.green.shade800,
    );
  }

  void _drawMiniCompassAtPoint(
      Canvas canvas,
      Offset center,
      String pointLabel,
      String caption,
      Color highlightColor,
      ) {
    const double r = 34.0;
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 8 spokes inside the mini compass wheel
    for (int i = 0; i < 8; i++) {
      final double a = i * math.pi / 4;
      canvas.drawLine(
        center,
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = i.isEven ? 1.6 : 1.0,
      );
    }

    // North Pointer Arrow above the compass wheel (matching Figure 24.5)
    final Offset nStart = Offset(center.dx, center.dy - r - 2);
    final Offset nTip = Offset(center.dx, center.dy - r - 28);
    canvas.drawLine(
      nStart,
      nTip,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.2,
    );
    _drawArrowHead(canvas, nTip, -math.pi / 2, Colors.black87, len: 8.0);
    _drawText(
      canvas,
      "N",
      nTip.dx,
      nTip.dy - 11,
      fontSize: 13,
      isBold: true,
      color: Colors.red.shade800,
    );

    // Point Name Label
    _drawText(
      canvas,
      pointLabel,
      center.dx + r + 22,
      center.dy,
      fontSize: 14,
      isBold: true,
      color: highlightColor,
    );

    // Caption Badge below compass
    _drawBadge(
      canvas,
      caption,
      center.dx,
      center.dy + r + 22,
      highlightColor,
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
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + 14,
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
  bool shouldRepaint(covariant CompassRosePainter oldDelegate) =>
      oldDelegate.data != data;
}