import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'travel_graphs_logic.dart';
import 'travel_graphs_models.dart';

class TravelGraphsScreen extends StatefulWidget {
  const TravelGraphsScreen({super.key});

  @override
  State<TravelGraphsScreen> createState() => _TravelGraphsScreenState();
}

class _TravelGraphsScreenState extends State<TravelGraphsScreen> {
  int _inputMode = 1; // 0: AI Multimodal, 1: Manual Builder
  int _graphMode = 0; // 0: Distance-Time, 1: Speed-Time

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers for Scales and Labels
  final TextEditingController _timeLabelCtrl = TextEditingController(text: "Time (s)");
  final TextEditingController _valueLabelCtrl = TextEditingController(text: "Distance (m)");
  final TextEditingController _scaleXCtrl = TextEditingController(text: "2");
  final TextEditingController _scaleYCtrl = TextEditingController(text: "5");

  // Journeys Data
  List<Map<String, dynamic>> _journeysData = [];

  TravelResult? _result;
  final TransformationController _graphTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _initDefaultJourney();
  }

  void _initDefaultJourney() {
    _journeysData = [
      {
        'name': TextEditingController(text: "Car A"),
        'waypoints': [
          {'time': TextEditingController(text: "0"), 'val': TextEditingController(text: "0")},
          {'time': TextEditingController(text: "4"), 'val': TextEditingController(text: "18")},
          {'time': TextEditingController(text: "9"), 'val': TextEditingController(text: "18")},
          {'time': TextEditingController(text: "12"), 'val': TextEditingController(text: "0")},
        ]
      }
    ];
  }

  void _addWaypoint(int journeyIndex) {
    setState(() => _journeysData[journeyIndex]['waypoints'].add({'time': TextEditingController(), 'val': TextEditingController()}));
  }

  void _removeWaypoint(int journeyIndex, int wpIndex) {
    setState(() {
      _journeysData[journeyIndex]['waypoints'][wpIndex]['time'].dispose();
      _journeysData[journeyIndex]['waypoints'][wpIndex]['val'].dispose();
      _journeysData[journeyIndex]['waypoints'].removeAt(wpIndex);
    });
  }

  void _addSecondJourney() {
    if (_journeysData.length < 2) {
      setState(() => _journeysData.add({
        'name': TextEditingController(text: "Car B"),
        'waypoints': [ {'time': TextEditingController(), 'val': TextEditingController()}, {'time': TextEditingController(), 'val': TextEditingController()} ]
      }));
    }
  }

  void _removeSecondJourney() {
    if (_journeysData.length > 1) {
      setState(() {
        var j = _journeysData.removeLast();
        j['name'].dispose();
        for (var wp in j['waypoints']) { wp['time'].dispose(); wp['val'].dispose(); }
      });
    }
  }

  @override
  void dispose() {
    _aiController.dispose();
    _timeLabelCtrl.dispose(); _valueLabelCtrl.dispose();
    _scaleXCtrl.dispose(); _scaleYCtrl.dispose();
    for (var j in _journeysData) {
      j['name'].dispose();
      for (var wp in j['waypoints']) { wp['time'].dispose(); wp['val'].dispose(); }
    }
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
      // Using 3.8-flash for Multimodal Vision capabilities
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final promptText = '''
      You are an expert Math teacher. Analyze the provided image (graph/table) or word problem and extract the kinematic journey data.
      
      RULES:
      1. Return ONLY a valid JSON object.
      2. "graphMode": 0 for Distance-Time, 1 for Speed-Time.
      3. "timeLabel" and "valueLabel" MUST include SI units in parentheses (e.g. "Time (s)", "Distance (km)").
      4. Extract the exact waypoints from the table or graph vertices.
      
      JSON FORMAT EXACTLY LIKE THIS:
      {
         "graphMode": 0,
         "timeLabel": "Time (min)",
         "valueLabel": "Distance (m)",
         "scaleX": "1",
         "scaleY": "100",
         "journeys": [
            {
               "name": "Car A",
               "waypoints": [ {"time": "0", "val": "0"}, {"time": "2", "val": "30"} ]
            }
         ]
      }
      
      User Prompt: "$inputText"
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

      setState(() {
        _graphMode = jsonMap['graphMode'] ?? 0;
        _timeLabelCtrl.text = jsonMap['timeLabel']?.toString() ?? 'Time (s)';
        _valueLabelCtrl.text = jsonMap['valueLabel']?.toString() ?? 'Distance (m)';
        _scaleXCtrl.text = jsonMap['scaleX']?.toString() ?? '1';
        _scaleYCtrl.text = jsonMap['scaleY']?.toString() ?? '1';

        // Rebuild Journeys
        for (var j in _journeysData) { j['name'].dispose(); for (var wp in j['waypoints']) { wp['time'].dispose(); wp['val'].dispose(); } }
        _journeysData.clear();

        List jData = jsonMap['journeys'] ?? [];
        for (var jMap in jData) {
          List wps = jMap['waypoints'] ?? [];
          List<Map<String, TextEditingController>> newWps = [];
          for (var wp in wps) {
            newWps.add({'time': TextEditingController(text: wp['time']?.toString() ?? ''), 'val': TextEditingController(text: wp['val']?.toString() ?? '')});
          }
          _journeysData.add({'name': TextEditingController(text: jMap['name']?.toString() ?? ''), 'waypoints': newWps});
        }
        if (_journeysData.isEmpty) _initDefaultJourney();

        _inputMode = 1; // Switch to Manual view to show parsed data
      });
      _solveManual();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Vision Parsing failed. Try typing it manually.')));
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();

    try {
      List<TravelJourney> parsedJourneys = [];
      for (var jData in _journeysData) {
        String name = jData['name'].text.trim();
        List<TravelWaypoint> wps = [];
        for (var wpData in jData['waypoints']) {
          double? t = double.tryParse(wpData['time'].text.replaceAll(RegExp(r'[^\d\.\-]'), ''));
          double? v = double.tryParse(wpData['val'].text.replaceAll(RegExp(r'[^\d\.\-]'), ''));
          if (t != null && v != null) wps.add(TravelWaypoint(time: t, value: v));
        }
        if (wps.length >= 2) {
          wps.sort((a, b) => a.time.compareTo(b.time));
          parsedJourneys.add(TravelJourney(name: name.isEmpty ? "Journey" : name, waypoints: wps));
        }
      }

      double sX = double.tryParse(_scaleXCtrl.text) ?? 1.0;
      double sY = double.tryParse(_scaleYCtrl.text) ?? 1.0;
      if (sX <= 0) sX = 1; if (sY <= 0) sY = 1;

      setState(() {
        if (_graphMode == 0) {
          _result = TravelGraphsLogic.solveDistanceTime(journeys: parsedJourneys, timeLabel: _timeLabelCtrl.text, distLabel: _valueLabelCtrl.text, scaleX: sX, scaleY: sY);
        } else {
          _result = TravelGraphsLogic.solveSpeedTime(journey: parsedJourneys.first, timeLabel: _timeLabelCtrl.text, speedLabel: _valueLabelCtrl.text, scaleX: sX, scaleY: sY);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_result != null && _result!.valid) {
          final screenWidth = MediaQuery.of(context).size.width - 32;
          double dx = (800 - screenWidth) / 2;
          _graphTransformController.value = Matrix4.identity()..translate(-dx, -400.0);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error parsing waypoints.')));
    }
  }

  Widget _buildInputSection() {
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
                Expanded(child: Text("Upload a photo of a graph or a table of values from your textbook. The AI will 'read' the image and plot the journey for you!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
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
              child: const Center(child: Text("✅ Image Attached", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))), // Placeholder for actual Image.file in full environment
            ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _aiController, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2,
            decoration: InputDecoration(labelText: "Extra Instructions (Optional)", hintText: "e.g. Extract the table for Car A", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
              groupValue: _graphMode,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Distance-Time Graph", style: TextStyle(fontWeight: FontWeight.bold))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Speed-Time Graph", style: TextStyle(fontWeight: FontWeight.bold))),
              },
              onValueChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _graphMode = value; _result = null;
                    _valueLabelCtrl.text = value == 0 ? "Distance (m)" : "Speed (m/s)";
                    if (value == 1 && _journeysData.length > 1) _removeSecondJourney();
                  });
                }
              },
              thumbColor: Colors.deepPurple.shade100, backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),

          const Text("1. Set SI Units & Scales:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(children: [ Expanded(child: _buildSmallField(_timeLabelCtrl, "Time Label e.g. Time (s)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_valueLabelCtrl, "Value Label e.g. Distance (m)")) ]),
          const SizedBox(height: 12),
          Row(children: [ Expanded(child: _buildSmallField(_scaleXCtrl, "X Scale (2cm to __)")), const SizedBox(width: 8), Expanded(child: _buildSmallField(_scaleYCtrl, "Y Scale (2cm to __)")) ]),

          const SizedBox(height: 24),
          const Text("2. Build the Journey (Waypoints):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),

          ..._journeysData.asMap().entries.map((entry) {
            int jIdx = entry.key; var jData = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildSmallField(jData['name'], "Journey Name")),
                      if (jIdx == 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _removeSecondJourney)
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(jData['waypoints'].length, (wIdx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Text("At Time = ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: _buildSmallField(jData['waypoints'][wIdx]['time'], "e.g. 0")),
                          const Text("  Val = ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: _buildSmallField(jData['waypoints'][wIdx]['val'], "e.g. 0")),
                          if (jData['waypoints'].length > 2) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _removeWaypoint(jIdx, wIdx))
                          else const SizedBox(width: 24),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(onPressed: () => _addWaypoint(jIdx), icon: const Icon(Icons.add_location_alt, size: 18), label: const Text("Add Waypoint/Stage"))
                ],
              ),
            );
          }),

          if (_graphMode == 0 && _journeysData.length == 1)
            TextButton.icon(onPressed: _addSecondJourney, icon: const Icon(Icons.directions_car, color: Colors.deepPurple), label: const Text("Add Second Journey (Intersection)", style: TextStyle(color: Colors.deepPurple))),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual, icon: const Icon(Icons.show_chart, color: Colors.white), label: const Text("Analyze Kinematics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]
      ],
    );
  }

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller, textAlign: TextAlign.center, keyboardType: TextInputType.text, // Text type so they can type units like (km/h)
      decoration: InputDecoration(hintText: hint, isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) return Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("1. Kinematic Graph Visualizer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
              constrained: false, boundaryMargin: const EdgeInsets.all(200), minScale: 0.2, maxScale: 4.0,
              child: Container(
                width: 800, height: 800, color: Colors.white,
                child: CustomPaint(painter: TravelGraphPainter(result: _result!)),
              ),
            ),
          ),
        ),

        if (_result!.finalAnswers.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text("2. Graph Readings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _result!.finalAnswers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("${entry.key}:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87))),
                        Text(entry.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        const Text("3. Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
        const Text("4. Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX != null && e.value.mathLaTeX!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Math.tex(e.value.mathLaTeX!, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)))
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
      appBar: AppBar(title: const Text('Travel Graphs & Kinematics')),
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

class TravelGraphPainter extends CustomPainter {
  final TravelResult result;

  TravelGraphPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final minorGridPaint = Paint()..color = Colors.green.shade100..strokeWidth = 1;
    final majorGridPaint = Paint()..color = Colors.green.shade400..strokeWidth = 1.5;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2.5;

    final linePaints = [
      Paint()..color = Colors.deepPurple..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round,
      Paint()..color = Colors.orange.shade700..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round,
    ];
    final areaPaint = Paint()..color = Colors.blue.withOpacity(0.15)..style = PaintingStyle.fill;
    final tracePaint = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;

    Offset origin = Offset(80, size.height - 80);
    double pxPerBlock = 50.0; // Represents 2cm

    int numXBlocks = ((size.width - origin.dx) / pxPerBlock).ceil();
    int numYBlocks = (origin.dy / pxPerBlock).ceil();

    // 1. Draw Grid
    double minorSpacing = pxPerBlock / 10;
    for (int i = 0; i <= numXBlocks * 10; i++) {
      double px = origin.dx + (i * minorSpacing);
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }
    for (int i = 0; i <= numYBlocks * 10; i++) {
      double py = origin.dy - (i * minorSpacing);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), i % 10 == 0 ? majorGridPaint : minorGridPaint);
    }

    // 2. Draw Axes
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    _drawText(canvas, "0", origin.dx - 12, origin.dy + 12, isBold: true);

    // Labels & Scales
    for (int i = 1; i <= numXBlocks; i++) {
      double px = origin.dx + (i * pxPerBlock);
      _drawText(canvas, _fmt(i * result.scaleX), px, origin.dy + 15);
    }
    _drawText(canvas, result.timeLabel, size.width - 60, origin.dy + 30, isBold: true);

    for (int i = 1; i <= numYBlocks; i++) {
      double py = origin.dy - (i * pxPerBlock);
      _drawText(canvas, _fmt(i * result.scaleY), origin.dx - 25, py);
    }
    canvas.save();
    canvas.translate(20, 100);
    canvas.rotate(-1.5708);
    _drawText(canvas, result.valueLabel, 0, 0, isBold: true);
    canvas.restore();

    Offset toPx(double t, double v) {
      return Offset(origin.dx + ((t / result.scaleX) * pxPerBlock), origin.dy - ((v / result.scaleY) * pxPerBlock));
    }

    // 3. Draw Journeys
    for (int j = 0; j < result.journeys.length; j++) {
      var journey = result.journeys[j];
      if (journey.waypoints.isEmpty) continue;

      Path jPath = Path();
      List<Offset> pts = [];
      for (int i = 0; i < journey.waypoints.length; i++) {
        Offset pt = toPx(journey.waypoints[i].time, journey.waypoints[i].value);
        pts.add(pt);
        if (i == 0) {
          jPath.moveTo(pt.dx, pt.dy);
        } else {
          jPath.lineTo(pt.dx, pt.dy);
        }

        // Draw cross marker
        canvas.drawLine(Offset(pt.dx - 4, pt.dy), Offset(pt.dx + 4, pt.dy), linePaints[j]);
        canvas.drawLine(Offset(pt.dx, pt.dy - 4), Offset(pt.dx, pt.dy + 4), linePaints[j]);
      }
      canvas.drawPath(jPath, linePaints[j]);

      // Add Name Label to line
      if (pts.length > 1) {
        _drawText(canvas, journey.name, pts[1].dx, pts[1].dy - 20, isBold: true, color: linePaints[j].color);
      }

      // Shaded Area for Speed-Time Graphs
      if (result.graphType == 'Speed-Time') {
        Path areaP = Path()..moveTo(pts.first.dx, origin.dy);
        for (var pt in pts) {
          areaP.lineTo(pt.dx, pt.dy);
        }
        areaP.lineTo(pts.last.dx, origin.dy);
        areaP.close();
        canvas.drawPath(areaP, areaPaint);

        // Drop lines to visualize shapes
        for (var pt in pts) {
          _drawDashedLine(canvas, pt, Offset(pt.dx, origin.dy), Paint()..color = Colors.blue.shade300..strokeWidth = 1);
        }
      }
    }

    // 4. Mark Intersections (Distance-Time)
    if (result.intersection != null) {
      Offset ix = toPx(result.intersection!.time, result.intersection!.value);
      canvas.drawCircle(ix, 6, Paint()..color = Colors.red);

      _drawDashedLine(canvas, ix, Offset(ix.dx, origin.dy), tracePaint);
      _drawDashedLine(canvas, ix, Offset(origin.dx, ix.dy), tracePaint);

      _drawText(canvas, "Meet", ix.dx + 15, ix.dy - 15, color: Colors.red, isBold: true);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double distance = (p2 - p1).distance;
    double dashWidth = 5, dashSpace = 4;
    double startX = p1.dx, startY = p1.dy;
    int count = (distance / (dashWidth + dashSpace)).floor();
    double dx = (p2.dx - p1.dx) / count;
    double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) canvas.drawLine(Offset(startX, startY), Offset(startX + dx, startY + dy), paint);
      startX += dx;
      startY += dy;
    }
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}