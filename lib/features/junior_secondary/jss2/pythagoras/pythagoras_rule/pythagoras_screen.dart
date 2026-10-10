import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'pythagoras_logic.dart';
import 'pythagoras_models.dart';
import 'dart:math' as math;

class PythagorasScreen extends StatefulWidget {
  const PythagorasScreen({super.key});

  @override
  State<PythagorasScreen> createState() => _PythagorasScreenState();
}

class _PythagorasScreenState extends State<PythagorasScreen> {
  int _inputMode = 0; // 0: AI, 1: Manual
  int _topicMode = 0; // 0: Single, 1: Composite, 2: Triples, 3: Real-Life
  int _tripleMode = 0; // 0: Verify, 1: Multiples, 2: Complete Pattern
  String _rlScenario = 'ladder'; // 'ladder', 'rectangle', 'navigation', 'pole'

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Shared Unit Controller
  final TextEditingController _unitCtrl = TextEditingController();

  // Mode 0: Single Triangle Controllers
  final TextEditingController _sBaseCtrl = TextEditingController();
  final TextEditingController _sHeightCtrl = TextEditingController();
  final TextEditingController _sHypCtrl = TextEditingController();

  // Mode 1: Composite Triangle (N-Chain) Controllers
  final List<Map<String, TextEditingController>> _compTriangles = [];

  // Mode 2: Pythagorean Triples Controllers
  final TextEditingController _tripACtrl = TextEditingController();
  final TextEditingController _tripBCtrl = TextEditingController();
  final TextEditingController _tripCCtrl = TextEditingController();
  final TextEditingController _tripCountCtrl = TextEditingController(text: "4");
  final TextEditingController _tripPatternCtrl = TextEditingController();

  // Mode 3: Real-Life Scenarios Controllers
  final TextEditingController _rlBaseCtrl = TextEditingController();
  final TextEditingController _rlHeightCtrl = TextEditingController();
  final TextEditingController _rlHypCtrl = TextEditingController();

  PythagorasResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _addCompositeTriangle("1 (Known)");
    _addCompositeTriangle("2 (Target)");
  }

  void _addCompositeTriangle([String? defaultName]) {
    setState(() {
      int idx = _compTriangles.length + 1;
      _compTriangles.add({
        'name': TextEditingController(text: defaultName ?? "$idx"),
        'base': TextEditingController(),
        'height': TextEditingController(),
        'hyp': TextEditingController(),
      });
    });
  }

  void _removeCompositeTriangle(int index) {
    setState(() {
      _compTriangles[index]['name']!.dispose();
      _compTriangles[index]['base']!.dispose();
      _compTriangles[index]['height']!.dispose();
      _compTriangles[index]['hyp']!.dispose();
      _compTriangles.removeAt(index);
    });
  }

  @override
  void dispose() {
    _aiController.dispose();
    _unitCtrl.dispose();
    _sBaseCtrl.dispose(); _sHeightCtrl.dispose(); _sHypCtrl.dispose();
    for (var t in _compTriangles) {
      t['name']!.dispose(); t['base']!.dispose(); t['height']!.dispose(); t['hyp']!.dispose();
    }
    _tripACtrl.dispose(); _tripBCtrl.dispose(); _tripCCtrl.dispose(); _tripCountCtrl.dispose(); _tripPatternCtrl.dispose();
    _rlBaseCtrl.dispose(); _rlHeightCtrl.dispose(); _rlHypCtrl.dispose();
    _graphTransformController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image.')));
    }
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _aiController.text.trim();

    if (inputText.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a prompt or upload an image.')));
      return;
    }

    setState(() { _isLoadingAI = true; _result = null; });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      const promptText = '''
      You are a strict data extractor for JSS2 Pythagoras Rule.
      Extract the triangle side lengths from the image or word problem.
      
      RULES:
      1. ONLY return a valid JSON object.
      2. "mode": 0 (Single Triangle), 1 (Composite chain), 2 (Triples), 3 (Real-Life Word Problem).
      3. Use "x", "y", "z" for unknown or shared variables.
      4. "unit": Extract the SI unit (e.g. "cm", "m") if present.
      5. For mode 3 (Real-Life): Determine "realLifeScenario" ("ladder", "rectangle", "navigation", "pole") and map lengths to "rlBase", "rlHeight", "rlHyp".
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "mode": 3,
         "unit": "m",
         "triangles": [
            {"name": "1", "base": "15", "height": "8", "hyp": "y"}
         ],
         "tripleMode": 0, "tripleA": "", "tripleB": "", "tripleC": "", "tripleCount": "4", "triplePattern": "",
         "realLifeScenario": "ladder", "rlBase": "1.8", "rlHeight": "h", "rlHyp": "7.3"
      }
      
      User Prompt: "\$inputText"
      ''';

      List<Part> parts = [TextPart(promptText)];
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        parts.add(DataPart('image/jpeg', bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      String rawOutput = response.text?.trim() ?? '';
      rawOutput = rawOutput.replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '').replaceAll(RegExp(r'\n```$'), '').trim();

      final jsonMap = json.decode(rawOutput);

      if (!mounted) return;

      setState(() {
        _topicMode = jsonMap['mode'] ?? 0;
        _unitCtrl.text = jsonMap['unit']?.toString() ?? '';

        if (_topicMode == 0) {
          var tData = jsonMap['triangles']?[0] ?? {};
          _sBaseCtrl.text = tData['base']?.toString() ?? '';
          _sHeightCtrl.text = tData['height']?.toString() ?? '';
          _sHypCtrl.text = tData['hyp']?.toString() ?? '';
        } else if (_topicMode == 1) {
          List tList = jsonMap['triangles'] ?? [];

          for (var t in _compTriangles) { t['name']!.dispose(); t['base']!.dispose(); t['height']!.dispose(); t['hyp']!.dispose(); }
          _compTriangles.clear();

          for (var tData in tList) {
            _compTriangles.add({
              'name': TextEditingController(text: tData['name']?.toString() ?? ''),
              'base': TextEditingController(text: tData['base']?.toString() ?? ''),
              'height': TextEditingController(text: tData['height']?.toString() ?? ''),
              'hyp': TextEditingController(text: tData['hyp']?.toString() ?? ''),
            });
          }
          if (_compTriangles.length < 2) {
            _addCompositeTriangle("1"); _addCompositeTriangle("2");
          }
        } else if (_topicMode == 2) {
          _tripleMode = jsonMap['tripleMode'] ?? 0;
          _tripACtrl.text = jsonMap['tripleA']?.toString() ?? '';
          _tripBCtrl.text = jsonMap['tripleB']?.toString() ?? '';
          _tripCCtrl.text = jsonMap['tripleC']?.toString() ?? '';
          _tripCountCtrl.text = jsonMap['tripleCount']?.toString() ?? '4';
          _tripPatternCtrl.text = jsonMap['triplePattern']?.toString() ?? '';
        } else if (_topicMode == 3) {
          String scenario = jsonMap['realLifeScenario']?.toString() ?? 'ladder';
          if (['ladder', 'rectangle', 'navigation', 'pole'].contains(scenario)) _rlScenario = scenario;
          _rlBaseCtrl.text = jsonMap['rlBase']?.toString() ?? '';
          _rlHeightCtrl.text = jsonMap['rlHeight']?.toString() ?? '';
          _rlHypCtrl.text = jsonMap['rlHyp']?.toString() ?? '';
        }

        _inputMode = 1;
      });
      _solveManual();

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Vision Parsing failed. Try entering the values manually.')));
    } finally {
      if (mounted) setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_topicMode == 0) {
        _result = PythagorasLogic.solveSingle(PythagorasTriangleData(
            name: "ABC", base: _sBaseCtrl.text, height: _sHeightCtrl.text, hypotenuse: _sHypCtrl.text
        ), _unitCtrl.text);
      } else if (_topicMode == 1) {
        List<PythagorasTriangleData> tList = _compTriangles.map((map) => PythagorasTriangleData(
            name: map['name']!.text,
            base: map['base']!.text,
            height: map['height']!.text,
            hypotenuse: map['hyp']!.text
        )).toList();
        _result = PythagorasLogic.solveComposite(tList, _unitCtrl.text);
      } else if (_topicMode == 2) {
        if (_tripleMode == 0) {
          _result = PythagorasLogic.verifyTriple(_tripACtrl.text, _tripBCtrl.text, _tripCCtrl.text);
        } else if (_tripleMode == 1) {
          _result = PythagorasLogic.generateMultiples(_tripACtrl.text, _tripBCtrl.text, _tripCCtrl.text, _tripCountCtrl.text);
        } else {
          _result = PythagorasLogic.completePattern(_tripPatternCtrl.text);
        }
      } else if (_topicMode == 3) {
        _result = PythagorasLogic.solveRealLife(
            scenarioType: _rlScenario, baseStr: _rlBaseCtrl.text, heightStr: _rlHeightCtrl.text, hypStr: _rlHypCtrl.text, unit: _unitCtrl.text
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _graphTransformController.value = Matrix4.identity();
      }
    });
  }

  Widget _buildInputSection() {
    Map<String, List<String>> rlLabels = {
      'ladder': ['Distance on Ground', 'Height up Wall', 'Length of Ladder'],
      'rectangle': ['Length of Rectangle', 'Width of Rectangle', 'Diagonal'],
      'navigation': ['Distance East/West', 'Distance North/South', 'Shortest Direct Dist.'],
      'pole': ['Distance on Ground', 'Height of Pole', 'Length of Wire'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("📷 AI Vision", style: TextStyle(fontWeight: FontWeight.bold))),
              1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("🛠️ Manual Builder", style: TextStyle(fontWeight: FontWeight.bold))),
            },
            onValueChanged: (int? value) { if (value != null) setState(() => _inputMode = value); },
            thumbColor: Colors.deepPurple.shade100, backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),

        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
            child: const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text("Upload a photo of a complex composite triangle or a real-life word problem. The AI will map the shared variables for you!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library), label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade900, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera), label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade900, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200))),
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
              child: const Center(child: Text("✅ Image Attached", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
            ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2,
            decoration: InputDecoration(labelText: "Extra Instructions (Optional)", hintText: "e.g. Find the length of AD", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI) const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else ElevatedButton.icon(
            onPressed: _solveWithAI, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("Scan & Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Single\nTriangle", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Composite\nTriangles", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Pythagorean\nTriples", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                3: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Real-Life\nProblems", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              },
              onValueChanged: (int? value) {
                if (value != null) setState(() { _topicMode = value; _result = null; });
              },
              thumbColor: Colors.deepPurple.shade100, backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),

          if (_topicMode != 2) ...[
            _buildSmallField(_unitCtrl, "SI Unit (e.g. cm, m) - Optional"),
            const SizedBox(height: 16),
          ],

          if (_topicMode == 0) ...[
            const Text("Enter two known sides. Leave the unknown blank or enter a variable (e.g. 'x'):", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            const SizedBox(height: 12),
            _buildSmallField(_sBaseCtrl, "Base (Bottom)"),
            const SizedBox(height: 8),
            _buildSmallField(_sHeightCtrl, "Height (Vertical)"),
            const SizedBox(height: 8),
            _buildSmallField(_sHypCtrl, "Hypotenuse (Longest)"),
          ] else if (_topicMode == 1) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
              child: const Row(
                children: [
                  Icon(Icons.link, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(child: Text("Link them together! Use the exact same letter (e.g. 'y') for the side they share.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Chained Triangles:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                TextButton.icon(onPressed: () => _addCompositeTriangle(), icon: const Icon(Icons.add, size: 18), label: const Text("Add Triangle"))
              ],
            ),

            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: List.generate(_compTriangles.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Triangle ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            if (_compTriangles.length > 2) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removeCompositeTriangle(index))
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(children: [ Expanded(child: _buildSmallField(_compTriangles[index]['base']!, "Base")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_compTriangles[index]['height']!, "Height")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_compTriangles[index]['hyp']!, "Hyp")) ]),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ] else if (_topicMode == 2) ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _tripleMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Verify a\nTriple", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Generate\nMultiples", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Complete\nPattern", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                },
                onValueChanged: (int? value) {
                  if (value != null) setState(() { _tripleMode = value; _result = null; });
                },
                thumbColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            if (_tripleMode == 0 || _tripleMode == 1) ...[
              const Text("Enter the three numbers of the triple:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSmallField(_tripACtrl, "1st Num")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_tripBCtrl, "2nd Num")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallField(_tripCCtrl, "3rd Num")),
                ],
              ),
              if (_tripleMode == 1) ...[
                const SizedBox(height: 16),
                _buildSmallField(_tripCountCtrl, "How many multiples to generate? (e.g. 4)"),
              ]
            ] else ...[
              const Text("Enter the starting number of the pattern:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 12),
              _buildSmallField(_tripPatternCtrl, "Start Number (e.g. 9 or 12)"),
            ]
          ] else if (_topicMode == 3) ...[
            Container(
              height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _rlScenario, isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'ladder', child: Text("Ladders & Walls / Trees", style: TextStyle(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'rectangle', child: Text("Diagonals of Rectangles", style: TextStyle(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'navigation', child: Text("Navigation (North/East)", style: TextStyle(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'pole', child: Text("Poles & Wires", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (String? val) { if (val != null) setState(() { _rlScenario = val; _result = null; }); },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Enter the known lengths. Leave one blank for the unknown:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            const SizedBox(height: 12),
            _buildSmallField(_rlBaseCtrl, rlLabels[_rlScenario]![0]),
            const SizedBox(height: 8),
            _buildSmallField(_rlHeightCtrl, rlLabels[_rlScenario]![1]),
            const SizedBox(height: 8),
            _buildSmallField(_rlHypCtrl, rlLabels[_rlScenario]![2]),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.calculate, color: Colors.white), label: const Text("Solve", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller, textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: hint, isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    // Dynamic width calculation allowing scroll if many triangles
    final screenWidth = MediaQuery.of(context).size.width - 32;
    double canvasWidth = math.max(screenWidth, _result!.drawnTriangles.length * 250.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_result!.drawnTriangles.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1. Shape Visualizer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
              Text("💡 Pan & Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            height: 350, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.deepPurple.shade200, width: 2), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InteractiveViewer(
                transformationController: _graphTransformController,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(200),
                minScale: 0.2, maxScale: 4.0,
                child: Container(
                  width: canvasWidth, height: 350, color: Colors.white,
                  child: CustomPaint(painter: PythagorasPainter(result: _result!)),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        Text("${_result!.drawnTriangles.isNotEmpty ? '2' : '1'}. Final Answers:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12, runSpacing: 12,
          children: _result!.finalAnswers.entries.map((entry) {
            bool isSimpleText = entry.key.contains("Triple") || entry.key.contains("Multiples");
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: Colors.green.shade50, border: Border.all(color: Colors.green.shade200, width: 2), borderRadius: BorderRadius.circular(12)),
              child: isSimpleText
                  ? Text("${entry.key}: ${entry.value}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))
                  : Math.tex("${entry.key} = ${entry.value}", textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        Text("${_result!.drawnTriangles.isNotEmpty ? '3' : '2'}. Mathematical Workings:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50, elevation: 0.5, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  if (_result!.workingsLaTeX[i].isEmpty) const SizedBox(height: 16)
                  else Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(_result!.workingsLaTeX[i], textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple))),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("${_result!.drawnTriangles.isNotEmpty ? '4' : '3'}. Step-by-Step Breakdown:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, foregroundColor: Colors.deepPurple, child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description.replaceAll('^2', '²'), style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)))
                ]
              ],
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pythagoras' Rule")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(Theme.of(context)),
          ],
        ),
      ),
    );
  }
}

class PythagorasPainter extends CustomPainter {
  final PythagorasResult result;

  PythagorasPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    if (result.drawnTriangles.isEmpty) return;

    final linePaint = Paint()..color = Colors.black87..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final squarePaint = Paint()..color = Colors.red.shade700..strokeWidth = 2..style = PaintingStyle.stroke;
    final shapeFill = Paint()..color = Colors.blue.withOpacity(0.1)..style = PaintingStyle.fill;

    int count = result.drawnTriangles.length;
    double cellWidth = size.width / count;

    for (int i = 0; i < count; i++) {
      var t = result.drawnTriangles[i];

      double cx = (i * cellWidth) + (cellWidth / 2);
      double cy = size.height / 2;

      double maxDim = math.max(t.baseVal, t.heightVal);
      if (maxDim == 0) maxDim = 1;
      double scale = (cellWidth * 0.6) / maxDim;

      double w = t.baseVal * scale;
      double h = t.heightVal * scale;

      Offset ptRightAngle = Offset(cx - w/2, cy + h/2);
      Offset ptTop = Offset(cx - w/2, cy - h/2);
      Offset ptRight = Offset(cx + w/2, cy + h/2);

      Path p = Path()..moveTo(ptRightAngle.dx, ptRightAngle.dy)..lineTo(ptTop.dx, ptTop.dy)..lineTo(ptRight.dx, ptRight.dy)..close();
      canvas.drawPath(p, shapeFill);

      canvas.drawLine(ptRightAngle, ptTop, linePaint);
      canvas.drawLine(ptRightAngle, ptRight, linePaint);
      canvas.drawLine(ptTop, ptRight, linePaint);

      double sqSize = 10;
      canvas.drawLine(Offset(ptRightAngle.dx, ptRightAngle.dy - sqSize), Offset(ptRightAngle.dx + sqSize, ptRightAngle.dy - sqSize), squarePaint);
      canvas.drawLine(Offset(ptRightAngle.dx + sqSize, ptRightAngle.dy - sqSize), Offset(ptRightAngle.dx + sqSize, ptRightAngle.dy), squarePaint);

      // Contextual Labels that format cleanly without ^2 showing on visualizer
      String cleanHLabel = t.heightLabel.replaceAll(RegExp(r'\^2$'), '²');
      String cleanBLabel = t.baseLabel.replaceAll(RegExp(r'\^2$'), '²');
      String cleanHypLabel = t.hypLabel.replaceAll(RegExp(r'\^2$'), '²');

      _drawText(canvas, cleanHLabel, ptRightAngle.dx - 20, cy);
      _drawText(canvas, cleanBLabel, cx, ptRightAngle.dy + 15);

      canvas.save();
      double angle = math.atan2(ptRight.dy - ptTop.dy, ptRight.dx - ptTop.dx);
      Offset midHyp = Offset((ptTop.dx + ptRight.dx)/2, (ptTop.dy + ptRight.dy)/2);
      canvas.translate(midHyp.dx, midHyp.dy);
      canvas.rotate(angle);
      _drawText(canvas, cleanHypLabel, 0, -15, isBold: true, color: Colors.deepPurple);
      canvas.restore();

      _drawText(canvas, t.name.startsWith('Real-Life') ? t.name : "Triangle ${t.name}", cx, ptTop.dy - 30, isBold: true, color: Colors.grey.shade600);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}