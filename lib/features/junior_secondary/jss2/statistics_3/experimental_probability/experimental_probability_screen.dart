import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'experimental_probability_logic.dart';
import 'experimental_probability_models.dart';

class ExperimentalProbabilityScreen extends StatefulWidget {
  const ExperimentalProbabilityScreen({super.key});

  @override
  State<ExperimentalProbabilityScreen> createState() =>
      _ExperimentalProbabilityScreenState();
}

class _ExperimentalProbabilityScreenState
    extends State<ExperimentalProbabilityScreen> {
  int _inputMode = 0; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _topicMode = 0; // 0: Frequency/Tally Table, 1: Raw Data, 2: Direct Solver

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0: Frequency & Tally Table Controllers
  final List<Map<String, TextEditingController>> _tableRowCtrls = [];
  final Set<int> _selectedRowIndices = {1}; // Default selects 2nd row (e.g. Female in Example 1)
  bool _isComplement = false;
  final TextEditingController _tableFutureCtrl = TextEditingController();

  // Mode 1: Raw Observation Data Controllers (e.g. Ibadan Rainfall)
  final TextEditingController _rawDataCtrl = TextEditingController(
      text: "18, 0, 17, 9, 11, 22, 14, 0, 16, 0, 7, 6");
  String _rawConditionOp = '>';
  final TextEditingController _rawTargetValCtrl =
  TextEditingController(text: "0");
  final TextEditingController _rawEventNameCtrl =
  TextEditingController(text: "Rain fell");
  final TextEditingController _rawFutureCtrl = TextEditingController();

  // Mode 2: Quick Direct Solver Controllers
  final TextEditingController _directEventCtrl =
  TextEditingController(text: "Short string chosen");
  final TextEditingController _directFavCtrl = TextEditingController();
  final TextEditingController _directTotalCtrl = TextEditingController();
  final TextEditingController _directFutureCtrl = TextEditingController();

  ExperimentalProbResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void initState() {
    super.initState();
    // Initialize with 2 empty rows ready for any textbook problem
    _addTableRow(defaultName: "Male", defaultCount: "");
    _addTableRow(defaultName: "Female", defaultCount: "");
  }

  void _addTableRow({String defaultName = "", String defaultCount = ""}) {
    setState(() {
      _tableRowCtrls.add({
        'name': TextEditingController(text: defaultName),
        'count': TextEditingController(text: defaultCount),
      });
      if (_selectedRowIndices.isEmpty) {
        _selectedRowIndices.add(0);
      }
    });
  }

  void _removeTableRow(int index) {
    if (_tableRowCtrls.length <= 2) return;
    setState(() {
      _tableRowCtrls[index]['name']!.dispose();
      _tableRowCtrls[index]['count']!.dispose();
      _tableRowCtrls.removeAt(index);

      // Rebuild selected indices safely
      Set<int> updated = {};
      for (int idx in _selectedRowIndices) {
        if (idx < index) {
          updated.add(idx);
        } else if (idx > index) {
          updated.add(idx - 1);
        }
      }
      if (updated.isEmpty) updated.add(0);
      _selectedRowIndices
        ..clear()
        ..addAll(updated);
    });
  }

  @override
  void dispose() {
    _aiController.dispose();
    for (var row in _tableRowCtrls) {
      row['name']!.dispose();
      row['count']!.dispose();
    }
    _tableFutureCtrl.dispose();
    _rawDataCtrl.dispose();
    _rawTargetValCtrl.dispose();
    _rawEventNameCtrl.dispose();
    _rawFutureCtrl.dispose();
    _directEventCtrl.dispose();
    _directFavCtrl.dispose();
    _directTotalCtrl.dispose();
    _directFutureCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final inputText = _aiController.text.trim();

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
      You are a strict JSON data extractor for JSS2 Experimental Probability.
      Analyze the provided word problem or textbook image and classify it into one of 3 modes:
      - "mode": 0 for Frequency/Tally Tables or multi-category counts (e.g., Male vs Female children, Bottle top Mouth up vs Mouth down, Paper clips inside vs outside circle).
      - "mode": 1 for Raw Observation Lists over time (e.g., 12 years of rainfall numbers in mm).
      - "mode": 2 for Direct Favorable vs Total word problems (e.g., 5 short strings chosen out of 20 trials).

      RULES:
      1. Return ONLY a valid JSON object. No markdown, no explanations.
      2. For mode 0:
         - Extract each category into "rows": [{"name": "Male", "count": "2 + 6 + 4 + 5 + 7"}, {"name": "Female", "count": "5 + 8 + 8 + 8 + 7"}]. If a table has multiple rows to sum per column, join them with " + " so the student sees the addition step! If tally marks are shown, count the tallies into a number.
         - Set "targetIndices" (0-based array of ints, e.g. [1]) to the row index(es) the question asks for.
         - Set "isComplement": true ONLY if the question asks for "NOT" that outcome.
      3. For mode 1:
         - Extract comma-separated numbers into "rawData".
         - Set "conditionOp" to one of: ">", "=", "<", ">=", "<=", "!=", "contains".
         - Set "targetVal" (e.g. "0") and "eventName" (e.g. "Rain fell").
      4. For mode 2:
         - Extract "eventName", "favorable", and "total".
      5. If the question asks to predict future trials (e.g. "Out of 5 children, how many are likely to be..."), extract that number into "futureTrials" (otherwise "").

      JSON FORMAT:
      {
        "mode": 0,
        "rows": [
          {"name": "Male", "count": "2 + 6 + 4 + 5 + 7"},
          {"name": "Female", "count": "5 + 8 + 8 + 8 + 7"}
        ],
        "targetIndices": [1],
        "isComplement": false,
        "rawData": "",
        "conditionOp": ">",
        "targetVal": "0",
        "eventName": "First born is a girl",
        "favorable": "",
        "total": "",
        "futureTrials": "5"
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
      rawOutput = rawOutput
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '')
          .replaceAll(RegExp(r'\n```$'), '')
          .trim();

      final jsonMap = json.decode(rawOutput);

      if (!mounted) return;

      setState(() {
        _topicMode = jsonMap['mode'] ?? 0;
        String fut = jsonMap['futureTrials']?.toString() ?? '';

        if (_topicMode == 0) {
          for (var r in _tableRowCtrls) {
            r['name']!.dispose();
            r['count']!.dispose();
          }
          _tableRowCtrls.clear();

          List rowsData = jsonMap['rows'] ?? [];
          for (var r in rowsData) {
            _tableRowCtrls.add({
              'name': TextEditingController(text: r['name']?.toString() ?? ''),
              'count':
              TextEditingController(text: r['count']?.toString() ?? ''),
            });
          }
          while (_tableRowCtrls.length < 2) {
            _addTableRow();
          }

          _selectedRowIndices.clear();
          List tIndices = jsonMap['targetIndices'] ?? [0];
          for (var idx in tIndices) {
            int parsedIdx = idx is int ? idx : (int.tryParse(idx.toString()) ?? 0);
            if (parsedIdx >= 0 && parsedIdx < _tableRowCtrls.length) {
              _selectedRowIndices.add(parsedIdx);
            }
          }
          if (_selectedRowIndices.isEmpty) _selectedRowIndices.add(0);

          _isComplement = jsonMap['isComplement'] ?? false;
          _tableFutureCtrl.text = fut;
        } else if (_topicMode == 1) {
          _rawDataCtrl.text = jsonMap['rawData']?.toString() ?? '';
          String op = jsonMap['conditionOp']?.toString() ?? '>';
          if (['>', '=', '<', '>=', '<=', '!=', 'contains'].contains(op)) {
            _rawConditionOp = op;
          }
          _rawTargetValCtrl.text = jsonMap['targetVal']?.toString() ?? '0';
          _rawEventNameCtrl.text =
              jsonMap['eventName']?.toString() ?? 'Target Event';
          _rawFutureCtrl.text = fut;
        } else {
          _directEventCtrl.text =
              jsonMap['eventName']?.toString() ?? 'Target Event';
          _directFavCtrl.text = jsonMap['favorable']?.toString() ?? '';
          _directTotalCtrl.text = jsonMap['total']?.toString() ?? '';
          _directFutureCtrl.text = fut;
        }

        _inputMode = 1; // Switch to Manual Builder so student sees mapped data
      });

      _solveManual();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'AI extraction failed. Please enter the values in the Manual Builder.')),
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
        List<OutcomeRowInput> rows = _tableRowCtrls
            .map((ctrl) => OutcomeRowInput(
          name: ctrl['name']!.text,
          countExpression: ctrl['count']!.text,
        ))
            .toList();
        _result = ExperimentalProbabilityLogic.solveTable(
          rows: rows,
          selectedIndices: _selectedRowIndices,
          isComplement: _isComplement,
          futureTrialsStr: _tableFutureCtrl.text,
        );
      } else if (_topicMode == 1) {
        _result = ExperimentalProbabilityLogic.solveRawData(
          rawListStr: _rawDataCtrl.text,
          conditionOp: _rawConditionOp,
          targetValStr: _rawTargetValCtrl.text,
          customEventName: _rawEventNameCtrl.text,
          futureTrialsStr: _rawFutureCtrl.text,
        );
      } else {
        _result = ExperimentalProbabilityLogic.solveDirect(
          eventNameStr: _directEventCtrl.text,
          favorableStr: _directFavCtrl.text,
          totalStr: _directTotalCtrl.text,
          futureTrialsStr: _directFutureCtrl.text,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _canvasTransformController.value = Matrix4.identity();
      }
    });
  }

  Widget _buildSmallField(
      TextEditingController controller,
      String label, {
        String? hint,
        ValueChanged<String>? onChanged,
      }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("📷 AI Vision / Word Problem",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("🛠️ Manual Builder",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) setState(() => _inputMode = value);
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
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
                Icon(Icons.camera_alt, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snap a photo of any frequency/tally table, rainfall record, or word problem from Chapter 21. The AI will populate the builder and solve it step-by-step!",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
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
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text("✅ Textbook Image Attached",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    child: const Text("Remove",
                        style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _aiController,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Word Problem or Question Prompt",
              hintText:
              "e.g. In a family there are 24 male and 36 female children. Find the probability that the first born is a girl...",
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
              label: const Text("Extract & Solve",
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
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Frequency /\nTally Table",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Raw Data\nRecords",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Quick Direct\nSolver",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              },
              onValueChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _topicMode = value;
                    _result = null;
                  });
                }
              },
              thumbColor: Colors.deepPurple.shade100,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 20),

          // ===================================================================
          // SUB-MODE 0: FREQUENCY & TALLY TABLE UI
          // ===================================================================
          if (_topicMode == 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tip: For multi-row tables (like Example 1), you can enter a single total (e.g. 36) OR type the numbers with '+' signs (e.g. 5 + 8 + 8 + 8 + 7)!",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text("1. Outcome Categories & Frequencies:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                ),
                TextButton.icon(
                  onPressed: () => _addTableRow(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Row"),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: List.generate(_tableRowCtrls.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildSmallField(
                            _tableRowCtrls[index]['name']!,
                            "Outcome ${index + 1} Name",
                            hint: "e.g. Female",
                            // Live Reactive Binding: Updates Target Event chips immediately!
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: _buildSmallField(
                            _tableRowCtrls[index]['count']!,
                            "Count or Sum",
                            hint: "e.g. 36 or 5+8+8+8+7",
                          ),
                        ),
                        if (_tableRowCtrls.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            padding: const EdgeInsets.only(left: 6),
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeTableRow(index),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            const Text("2. Select Target Event (Updates Live):",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 6),
            const Text(
              "Tap the outcome(s) the question asks for:",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_tableRowCtrls.length, (index) {
                String rawName = _tableRowCtrls[index]['name']!.text.trim();
                String displayLabel = rawName.isEmpty
                    ? "Row ${index + 1}: Outcome ${index + 1}"
                    : "Row ${index + 1}: $rawName";
                bool isSelected = _selectedRowIndices.contains(index);

                return FilterChip(
                  label: Text(
                    displayLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.deepPurple,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.deepPurple.shade50,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedRowIndices.add(index);
                      } else if (_selectedRowIndices.length > 1) {
                        _selectedRowIndices.remove(index);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _isComplement,
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Is Selected Outcome(s)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Is NOT Selected (Complement)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                },
                onValueChanged: (bool? val) {
                  if (val != null) setState(() => _isComplement = val);
                },
                thumbColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text("3. Future Prediction (Optional):",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            _buildSmallField(
              _tableFutureCtrl,
              "Predict out of N future trials (e.g. 5 children)",
              hint: "Leave blank if not asked",
            ),
          ]

          // ===================================================================
          // SUB-MODE 1: RAW OBSERVATION DATA UI (Ibadan Rainfall)
          // ===================================================================
          else if (_topicMode == 1) ...[
            const Text("1. Raw Recorded Data (Comma-Separated):",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            TextField(
              controller: _rawDataCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Recorded Numbers",
                hintText: "e.g. 18, 0, 17, 9, 11, 22, 14, 0, 16, 0, 7, 6",
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("2. Define Favorable Condition:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _rawConditionOp,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: '>',
                              child: Text("Greater than (>)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '=',
                              child: Text("Equal to (=)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '<',
                              child: Text("Less than (<)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '>=',
                              child: Text("At least (>=)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '<=',
                              child: Text("At most (<=)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '!=',
                              child: Text("Not equal (!=)",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: 'contains',
                              child: Text("Contains digit",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() => _rawConditionOp = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildSmallField(
                    _rawTargetValCtrl,
                    "Target Value",
                    hint: "e.g. 0 or 5",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSmallField(
              _rawEventNameCtrl,
              "Event Label (e.g. Rain fell in January)",
            ),
            const SizedBox(height: 16),
            _buildSmallField(
              _rawFutureCtrl,
              "Predict out of N future trials (Optional)",
              hint: "e.g. 12",
            ),
          ]

          // ===================================================================
          // SUB-MODE 2: QUICK DIRECT SOLVER UI
          // ===================================================================
          else ...[
              const Text("Enter the Known Experiment Counts:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 12),
              _buildSmallField(
                _directEventCtrl,
                "Event Name (e.g. Choosing short string)",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallField(
                      _directFavCtrl,
                      "Successful Outcomes (n)",
                      hint: "e.g. 5",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSmallField(
                      _directTotalCtrl,
                      "Total Trials (T)",
                      hint: "e.g. 20",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSmallField(
                _directFutureCtrl,
                "Predict out of N future trials (Optional)",
                hint: "e.g. 100",
              ),
            ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text("Calculate Probability",
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

    final screenWidth = MediaQuery.of(context).size.width - 32;
    double canvasWidth = math.max(screenWidth, 560.0);
    double canvasHeight =
    math.max(330.0, 180.0 + (_result!.outcomes.length * 55.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Probability Scale & Tally Visualizer:",
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
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: ExperimentalProbPainter(result: _result!),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Math.tex(
                    entry.value,
                    textStyle: const TextStyle(
                        fontSize: 24,
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
                    const SizedBox(height: 14)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          _result!.workingsLaTeX[i],
                          textStyle: const TextStyle(
                              fontSize: 18, color: Colors.deepPurple),
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
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
                    fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  e.value.description,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.4),
                ),
                if (e.value.mathLaTeX.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      e.value.mathLaTeX,
                      textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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
      appBar: AppBar(title: const Text('21-1 Experimental Probability')),
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

// =============================================================================
// CUSTOM PAINTER: PROBABILITY SCALE (0 TO 1) & TEXTBOOK TALLY/FREQUENCY CHART
// =============================================================================
class ExperimentalProbPainter extends CustomPainter {
  final ExperimentalProbResult result;

  ExperimentalProbPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 40.0;
    final double rightPad = size.width - 40.0;
    final double scaleWidth = rightPad - leftPad;

    // -------------------------------------------------------------------------
    // PART 1: THE PROBABILITY SCALE (0 to 1 Number Line)
    // -------------------------------------------------------------------------
    _drawText(
      canvas,
      "Probability Scale (0 to 1)",
      size.width / 2,
      22,
      fontSize: 15,
      isBold: true,
      color: Colors.deepPurple,
    );

    const double scaleY = 82.0;
    final trackPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(leftPad, scaleY), Offset(rightPad, scaleY), trackPaint);

    // Draw colored progress up to the calculated probability
    double markerX =
        leftPad + (result.probabilityDecimal.clamp(0.0, 1.0) * scaleWidth);
    final activeTrackPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(leftPad, scaleY), Offset(markerX, scaleY), activeTrackPaint);

    // Draw Ticks for 0 (Impossible), 0.5 (Even Chance), 1 (Certain)
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5;
    final ticks = [
      {'val': 0.0, 'num': '0', 'label': 'Impossible'},
      {'val': 0.25, 'num': '1/4', 'label': 'Unlikely'},
      {'val': 0.5, 'num': '1/2', 'label': 'Even Chance'},
      {'val': 0.75, 'num': '3/4', 'label': 'Likely'},
      {'val': 1.0, 'num': '1', 'label': 'Certain'},
    ];

    for (var t in ticks) {
      double v = t['val'] as double;
      double tx = leftPad + (v * scaleWidth);
      canvas.drawLine(
          Offset(tx, scaleY - 8), Offset(tx, scaleY + 8), tickPaint);
      _drawText(canvas, t['num'] as String, tx, scaleY + 22,
          fontSize: 12, isBold: true);
      _drawText(canvas, t['label'] as String, tx, scaleY + 38,
          fontSize: 11, color: Colors.grey.shade700);
    }

    // Plot Bold Marker Pin for Calculated Probability
    canvas.drawCircle(
        Offset(markerX, scaleY), 9, Paint()..color = Colors.green.shade700);
    canvas.drawCircle(
        Offset(markerX, scaleY), 4, Paint()..color = Colors.white);

    String fracLabel = result.favorableCount == 0
        ? "0"
        : (result.favorableCount == result.totalCount
        ? "1"
        : "${result.simplifiedNum}/${result.simplifiedDen}");
    String pctLabel =
        "${(result.probabilityDecimal * 100).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%";
    String badgeText = "P = $fracLabel ($pctLabel)";

    _drawBadge(
        canvas, badgeText, markerX, scaleY - 28, Colors.green.shade700);

    // Divider line
    canvas.drawLine(
      const Offset(24, 142),
      Offset(size.width - 24, 142),
      Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1.5,
    );

    // -------------------------------------------------------------------------
    // PART 2: VISUAL TALLY TABLE & PROPORTIONAL FREQUENCY BARS
    // -------------------------------------------------------------------------
    _drawText(
      canvas,
      "Tally & Frequency Breakdown (Total = ${result.totalCount})",
      size.width / 2,
      164,
      fontSize: 15,
      isBold: true,
      color: Colors.deepPurple,
    );

    double startY = 195.0;
    const double rowHeight = 48.0;
    const double nameColX = 30.0;
    const double tallyColX = 175.0;
    const double barColX = 355.0;
    final double maxBarWidth = math.max(80.0, size.width - barColX - 65.0);

    for (int i = 0; i < result.outcomes.length; i++) {
      var item = result.outcomes[i];
      double cy = startY + (i * rowHeight);

      Color rowColor =
      item.isTarget ? Colors.green.shade700 : Colors.blueGrey.shade600;

      // 1. Outcome Label
      String cleanName = item.name.length > 18
          ? "${item.name.substring(0, 16)}..."
          : item.name;
      _drawText(
        canvas,
        item.isTarget ? "★ $cleanName" : cleanName,
        nameColX,
        cy,
        fontSize: 13,
        isBold: item.isTarget,
        color: rowColor,
        alignLeft: true,
      );

      // 2. Textbook Tally Marks (Groups of 5: 4 vertical lines + 1 diagonal slash)
      _drawTallyMarks(canvas, item.count, tallyColX, cy, rowColor);

      // 3. Proportional Frequency Bar
      double ratio =
      result.totalCount > 0 ? (item.count / result.totalCount) : 0.0;
      double barW = math.max(4.0, ratio * maxBarWidth);

      RRect bgBar = RRect.fromRectAndRadius(
        Rect.fromLTWH(barColX, cy - 10, maxBarWidth, 20),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgBar, Paint()..color = Colors.grey.shade200);

      RRect fgBar = RRect.fromRectAndRadius(
        Rect.fromLTWH(barColX, cy - 10, barW, 20),
        const Radius.circular(6),
      );
      canvas.drawRRect(fgBar, Paint()..color = rowColor);

      // 4. Numeric Frequency Label
      _drawText(
        canvas,
        "${item.count}",
        barColX + maxBarWidth + 12,
        cy,
        fontSize: 13,
        isBold: true,
        color: rowColor,
        alignLeft: true,
      );
    }
  }

  /// Draws textbook-style 5-bar gate tally marks (IIII with diagonal strike)
  void _drawTallyMarks(
      Canvas canvas, int count, double startX, double centerY, Color color) {
    if (count == 0) {
      _drawText(canvas, "0 (None)", startX, centerY,
          fontSize: 12, color: Colors.grey, alignLeft: true);
      return;
    }

    final tallyPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    int displayCount = math.min(count, 25); // Cap visual tallies at 5 groups
    int fullGroups = displayCount ~/ 5;
    int remainder = displayCount % 5;

    double currX = startX;
    const double strokeSpacing = 5.0;
    const double groupSpacing = 10.0;
    const double halfH = 9.0;

    for (int g = 0; g < fullGroups; g++) {
      double groupStartX = currX;
      for (int s = 0; s < 4; s++) {
        canvas.drawLine(
          Offset(currX, centerY - halfH),
          Offset(currX, centerY + halfH),
          tallyPaint,
        );
        currX += strokeSpacing;
      }
      // 5th diagonal slash across the 4 vertical lines
      canvas.drawLine(
        Offset(groupStartX - 2, centerY + halfH - 2),
        Offset(currX - strokeSpacing + 2, centerY - halfH + 2),
        tallyPaint,
      );
      currX += groupSpacing;
    }

    for (int r = 0; r < remainder; r++) {
      canvas.drawLine(
        Offset(currX, centerY - halfH),
        Offset(currX, centerY + halfH),
        tallyPaint,
      );
      currX += strokeSpacing;
    }

    if (count > 25) {
      _drawText(
        canvas,
        "+${count - 25}",
        currX + 4,
        centerY,
        fontSize: 11,
        isBold: true,
        color: color,
        alignLeft: true,
      );
    }
  }

  void _drawBadge(
      Canvas canvas, String text, double x, double y, Color bgColor) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double padH = 10;
    double padV = 5;
    Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + padH * 2,
      height: tp.height + padV * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = bgColor,
    );
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawText(
      Canvas canvas,
      String text,
      double x,
      double y, {
        double fontSize = 13,
        bool isBold = false,
        Color color = Colors.black87,
        bool alignLeft = false,
      }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    Offset offset = alignLeft
        ? Offset(x, y - tp.height / 2)
        : Offset(x - tp.width / 2, y - tp.height / 2);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}