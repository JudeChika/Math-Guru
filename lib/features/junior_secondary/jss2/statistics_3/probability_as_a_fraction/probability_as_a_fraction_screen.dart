import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'probability_as_a_fraction_logic.dart';
import 'probability_as_a_fraction_models.dart';

class ProbabilityAsAFractionScreen extends StatefulWidget {
  const ProbabilityAsAFractionScreen({super.key});

  @override
  State<ProbabilityAsAFractionScreen> createState() =>
      _ProbabilityAsAFractionScreenState();
}

class _ProbabilityAsAFractionScreenState
    extends State<ProbabilityAsAFractionScreen> {
  int _inputMode = 0; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _topicMode = 0; // 0: Multi-Category Bag/Table, 1: Direct/Complement/Reverse, 2: Range/Cards/Dice

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0 (Mode A): Multi-Category Bag / Box / Survey / Table
  final List<Map<String, TextEditingController>> _catRowCtrls = [];
  final Set<int> _selectedCatIndices = {0};
  int _queryType = 0; // 0: Selected (Either/Or), 1: Complement (Neither/Nor), 2: Unlisted (Zero/Impossible)
  final TextEditingController _unlistedNameCtrl =
  TextEditingController(text: "Green ball");
  final TextEditingController _knownTotalCtrl = TextEditingController();
  String _preRoundRule = 'none'; // 'none', '10', '100', '1000'
  final TextEditingController _catFutureCtrl = TextEditingController();

  // Mode 1 (Mode B): Direct Fraction, Complement (1 - P) & Reverse Algebra Solver
  int _directSubMode = 0; // 0: Standard n/T, 1: Given P find 1-P, 2: Reverse Solver (Find T or n)
  final TextEditingController _directEventCtrl =
  TextEditingController(text: "Good orange");
  final TextEditingController _directFavCtrl = TextEditingController();
  final TextEditingController _directTotalCtrl = TextEditingController();
  bool _directFindComplement = false;
  final TextEditingController _directFutureCtrl = TextEditingController();

  final TextEditingController _givenProbCtrl =
  TextEditingController(text: "0.8");
  bool _reverseFindTotal = true; // true: Find Total T = n/P, false: Find n = P*T
  final TextEditingController _reverseCountCtrl =
  TextEditingController(text: "35");
  final TextEditingController _reverseProbCtrl =
  TextEditingController(text: "0.25");

  // Mode 2 (Mode C): Numbered Range, Dice & Cards Analyzer
  int _rangeSourceType = 0; // 0: Number Range (A to B), 1: Custom List
  final TextEditingController _rangeStartCtrl =
  TextEditingController(text: "1");
  final TextEditingController _rangeEndCtrl =
  TextEditingController(text: "20");
  final TextEditingController _customListCtrl =
  TextEditingController(text: "26, 26, 27, 27, 26, 27, 27");
  String _rangeCondition = 'not_contains_digit';
  final TextEditingController _rangeTargetValCtrl =
  TextEditingController(text: "1");
  final TextEditingController _rangeFutureCtrl = TextEditingController();

  ProbFractionResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void initState() {
    super.initState();
    // Initialize with 3 categories matching Example 6 (Red, White, Blue balls)
    _addCategoryRow(defaultName: "Red", defaultCount: "");
    _addCategoryRow(defaultName: "White", defaultCount: "");
    _addCategoryRow(defaultName: "Blue", defaultCount: "");
  }

  void _addCategoryRow({String defaultName = "", String defaultCount = ""}) {
    setState(() {
      _catRowCtrls.add({
        'name': TextEditingController(text: defaultName),
        'count': TextEditingController(text: defaultCount),
      });
      if (_selectedCatIndices.isEmpty) {
        _selectedCatIndices.add(0);
      }
    });
  }

  void _removeCategoryRow(int index) {
    if (_catRowCtrls.length <= 1) return;
    setState(() {
      _catRowCtrls[index]['name']!.dispose();
      _catRowCtrls[index]['count']!.dispose();
      _catRowCtrls.removeAt(index);

      Set<int> updated = {};
      for (int idx in _selectedCatIndices) {
        if (idx < index) {
          updated.add(idx);
        } else if (idx > index) {
          updated.add(idx - 1);
        }
      }
      if (updated.isEmpty) updated.add(0);
      _selectedCatIndices
        ..clear()
        ..addAll(updated);
    });
  }

  @override
  void dispose() {
    _aiController.dispose();
    for (var row in _catRowCtrls) {
      row['name']!.dispose();
      row['count']!.dispose();
    }
    _unlistedNameCtrl.dispose();
    _knownTotalCtrl.dispose();
    _catFutureCtrl.dispose();
    _directEventCtrl.dispose();
    _directFavCtrl.dispose();
    _directTotalCtrl.dispose();
    _directFutureCtrl.dispose();
    _givenProbCtrl.dispose();
    _reverseCountCtrl.dispose();
    _reverseProbCtrl.dispose();
    _rangeStartCtrl.dispose();
    _rangeEndCtrl.dispose();
    _customListCtrl.dispose();
    _rangeTargetValCtrl.dispose();
    _rangeFutureCtrl.dispose();
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
      You are a strict JSON data extractor for JSS2 Section 21-2: Probability as a Fraction.
      Analyze the provided word problem or textbook image and classify it into one of 3 universal modes:

      - "topicMode": 0 for Multi-Category Bags, Boxes, Surveys, or 2D Population/Traffic Tables (e.g., Red/White/Blue balls, Large/Small eggs, Coke/Fanta/Sprite, Mangoes, Village Population Table 21.7, Traffic Survey Table 21.9).
      - "topicMode": 1 for Direct Fraction (n out of T), WASSCE Multi-Year Pass Rate Tables (Table 21.6 / 21.8), Complement (1 - x) questions (e.g. "If P(pass) = 0.8, find P(fail)"), or Reverse Unknown Total problems (e.g. "35 participants are nurses, P(nurse) = 0.25, how many people at the seminar?").
      - "topicMode": 2 for Numbered Cards, Dice (1 to 6), or Temperature Lists (e.g., "Twenty cards numbered 1 to 20, probability it does not have digit 1", or "Midday temperatures 26, 26, 27...").

      RULES:
      1. Return ONLY a valid JSON object. No markdown, no explanations.
      2. For topicMode 0:
         - "rows": [{"name": "Red", "count": "7"}, {"name": "White", "count": "8"}, {"name": "Blue", "count": "5"}]. For multi-hour/multi-year columns, join with " + " (e.g. "28 + 14 + 13 + 20").
         - "selectedIndices": array of 0-based ints for the target categories.
         - "queryType": 0 for Selected ("Either A or B"), 1 for Complement ("Neither A nor B" or "NOT A"), 2 for Unlisted zero category (e.g. "Green ball" when only Red/White/Blue exist).
         - "unlistedName": name of the unlisted item if queryType == 2.
         - "knownTotal": if the problem gives a grand total larger than the listed categories (e.g. "100 mangoes: 20 unripe, 5 bad"), put "100" here, otherwise "".
         - "preRoundRule": "100" if the question says "Round each number to the nearest hundred" (like Ex. 21c #15), otherwise "none".
      3. For topicMode 1:
         - "directSubMode": 0 for n/T (or WASSCE sum table), 1 for Given P find 1-P, 2 for Reverse Unknown Total (T = n/P).
         - For subMode 0: set "eventName", "favorable" (e.g. "51 + 56 + 57 + 65 + 70" or "4"), "total" (e.g. "86 + 93 + 102 + 117 + 116" or "100"), and "findComplement" (true if given bad oranges and asked for good oranges).
         - For subMode 1: set "eventName" and "givenProb" (e.g. "0.8" or "9/12").
         - For subMode 2: set "reverseFindTotal": true, "reverseCount": "35", "reverseProb": "0.25".
      4. For topicMode 2:
         - "rangeSourceType": 0 for Range (start to end), 1 for Custom List.
         - "rangeStart": "1", "rangeEnd": "20", "customList": "".
         - "rangeCondition": one of "equals", "not_equals", "not_contains_digit", "contains_digit", "even", "odd", "prime", "multiple", "greater", "less".
         - "rangeTargetVal": e.g. "1" or "6".
      5. Set "futureTrials" if the question asks how many are expected out of N future trials (otherwise "").

      JSON FORMAT:
      {
        "topicMode": 0,
        "rows": [{"name": "Red", "count": "7"}, {"name": "White", "count": "8"}, {"name": "Blue", "count": "5"}],
        "selectedIndices": [0, 2],
        "queryType": 0,
        "unlistedName": "",
        "knownTotal": "",
        "preRoundRule": "none",
        "directSubMode": 0,
        "eventName": "Target Event",
        "favorable": "",
        "total": "",
        "findComplement": false,
        "givenProb": "0.8",
        "reverseFindTotal": true,
        "reverseCount": "35",
        "reverseProb": "0.25",
        "rangeSourceType": 0,
        "rangeStart": "1",
        "rangeEnd": "20",
        "customList": "",
        "rangeCondition": "not_contains_digit",
        "rangeTargetVal": "1",
        "futureTrials": ""
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
        _topicMode = jsonMap['topicMode'] ?? 0;
        String fut = jsonMap['futureTrials']?.toString() ?? '';

        if (_topicMode == 0) {
          for (var r in _catRowCtrls) {
            r['name']!.dispose();
            r['count']!.dispose();
          }
          _catRowCtrls.clear();

          List rowsData = jsonMap['rows'] ?? [];
          for (var r in rowsData) {
            _catRowCtrls.add({
              'name': TextEditingController(text: r['name']?.toString() ?? ''),
              'count':
              TextEditingController(text: r['count']?.toString() ?? ''),
            });
          }
          while (_catRowCtrls.length < 2) {
            _addCategoryRow();
          }

          _selectedCatIndices.clear();
          List sIndices = jsonMap['selectedIndices'] ?? [0];
          for (var idx in sIndices) {
            int parsedIdx =
            idx is int ? idx : (int.tryParse(idx.toString()) ?? 0);
            if (parsedIdx >= 0 && parsedIdx < _catRowCtrls.length) {
              _selectedCatIndices.add(parsedIdx);
            }
          }
          if (_selectedCatIndices.isEmpty) _selectedCatIndices.add(0);

          _queryType = jsonMap['queryType'] ?? 0;
          _unlistedNameCtrl.text =
              jsonMap['unlistedName']?.toString() ?? 'Unlisted Item';
          _knownTotalCtrl.text = jsonMap['knownTotal']?.toString() ?? '';
          String pr = jsonMap['preRoundRule']?.toString() ?? 'none';
          _preRoundRule =
          ['none', '10', '100', '1000'].contains(pr) ? pr : 'none';
          _catFutureCtrl.text = fut;
        } else if (_topicMode == 1) {
          _directSubMode = jsonMap['directSubMode'] ?? 0;
          _directEventCtrl.text =
              jsonMap['eventName']?.toString() ?? 'Target Event';
          _directFavCtrl.text = jsonMap['favorable']?.toString() ?? '';
          _directTotalCtrl.text = jsonMap['total']?.toString() ?? '';
          _directFindComplement = jsonMap['findComplement'] ?? false;
          _directFutureCtrl.text = fut;
          _givenProbCtrl.text = jsonMap['givenProb']?.toString() ?? '0.8';
          _reverseFindTotal = jsonMap['reverseFindTotal'] ?? true;
          _reverseCountCtrl.text = jsonMap['reverseCount']?.toString() ?? '35';
          _reverseProbCtrl.text = jsonMap['reverseProb']?.toString() ?? '0.25';
        } else {
          _rangeSourceType = jsonMap['rangeSourceType'] ?? 0;
          _rangeStartCtrl.text = jsonMap['rangeStart']?.toString() ?? '1';
          _rangeEndCtrl.text = jsonMap['rangeEnd']?.toString() ?? '20';
          _customListCtrl.text = jsonMap['customList']?.toString() ?? '';
          String cond =
              jsonMap['rangeCondition']?.toString() ?? 'not_contains_digit';
          if ([
            'equals',
            'not_equals',
            'not_contains_digit',
            'contains_digit',
            'even',
            'odd',
            'prime',
            'multiple',
            'greater',
            'less'
          ].contains(cond)) {
            _rangeCondition = cond;
          }
          _rangeTargetValCtrl.text =
              jsonMap['rangeTargetVal']?.toString() ?? '1';
          _rangeFutureCtrl.text = fut;
        }

        _inputMode = 1; // Switch to Manual Builder so student sees mapped fields
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
        List<CategoryRowInput> rows = _catRowCtrls
            .map((ctrl) => CategoryRowInput(
          name: ctrl['name']!.text,
          countExpression: ctrl['count']!.text,
        ))
            .toList();
        _result = ProbabilityAsAFractionLogic.solveMultiCategory(
          rows: rows,
          selectedIndices: _selectedCatIndices,
          queryType: _queryType,
          unlistedName: _unlistedNameCtrl.text,
          knownTotalStr: _knownTotalCtrl.text,
          preRoundRule: _preRoundRule,
          futureTrialsStr: _catFutureCtrl.text,
        );
      } else if (_topicMode == 1) {
        _result = ProbabilityAsAFractionLogic.solveDirectAndComplement(
          subMode: _directSubMode,
          eventNameStr: _directEventCtrl.text,
          favExprStr: _directFavCtrl.text,
          totalExprStr: _directTotalCtrl.text,
          findComplement: _directFindComplement,
          futureTrialsStr: _directFutureCtrl.text,
          givenProbStr: _givenProbCtrl.text,
          reverseFindTotal: _reverseFindTotal,
          reverseKnownCountStr: _reverseCountCtrl.text,
          reverseGivenProbStr: _reverseProbCtrl.text,
        );
      } else {
        _result = ProbabilityAsAFractionLogic.solveRangeAnalyzer(
          sourceType: _rangeSourceType,
          startNumStr: _rangeStartCtrl.text,
          endNumStr: _rangeEndCtrl.text,
          customListStr: _customListCtrl.text,
          conditionType: _rangeCondition,
          targetValStr: _rangeTargetValCtrl.text,
          futureTrialsStr: _rangeFutureCtrl.text,
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
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snap a photo of any problem or statistical table from Section 21-2 (Exercise 21c), or paste a word problem below!",
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
              height: 80,
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
              "e.g. There are 7 red balls, 8 white balls and 5 blue balls in a box. Find the probability of selecting neither red nor white...",
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
                  child: Text("Multi-Category\nBag / Table",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Direct, (1 - P) &\nReverse Solver",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Numbered Cards,\nDice & Lists",
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
          // MODE 0: MULTI-CATEGORY BAG / SURVEY / TABLE UI
          // ===================================================================
          if (_topicMode == 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text("1. Categories & Counts (Bag / Survey / Table):",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                ),
                TextButton.icon(
                  onPressed: () => _addCategoryRow(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Category"),
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
                children: List.generate(_catRowCtrls.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildSmallField(
                            _catRowCtrls[index]['name']!,
                            "Category ${index + 1}",
                            hint: "e.g. Red",
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: _buildSmallField(
                            _catRowCtrls[index]['count']!,
                            "Count or Sum",
                            hint: "e.g. 7 or 28+14+13+20",
                          ),
                        ),
                        if (_catRowCtrls.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            padding: const EdgeInsets.only(left: 6),
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeCategoryRow(index),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSmallField(
                    _knownTotalCtrl,
                    "Known Grand Total (Optional)",
                    hint: "Auto-sums if blank",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _preRoundRule,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'none',
                              child: Text("Exact Counts",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '10',
                              child: Text("Round Nearest 10",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '100',
                              child: Text("Round Nearest 100",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: '1000',
                              child: Text("Round Nearest 1000",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (String? val) {
                          if (val != null) setState(() => _preRoundRule = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("2. Question Type & Target Selection:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _queryType,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Selected\n(Either / Or)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("NOT Selected\n(Neither / Nor)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Unlisted Item\n(Impossible = 0)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                },
                onValueChanged: (int? val) {
                  if (val != null) setState(() => _queryType = val);
                },
                thumbColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_queryType == 2) ...[
              _buildSmallField(
                _unlistedNameCtrl,
                "Name of Unlisted Item (e.g. Green ball)",
              ),
            ] else ...[
              const Text(
                "Tap one or more category chips below:",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_catRowCtrls.length, (index) {
                  String rawName = _catRowCtrls[index]['name']!.text.trim();
                  String label = rawName.isEmpty
                      ? "Category ${index + 1}"
                      : rawName;
                  bool isSelected = _selectedCatIndices.contains(index);

                  return FilterChip(
                    label: Text(
                      label,
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
                          _selectedCatIndices.add(index);
                        } else if (_selectedCatIndices.length > 1) {
                          _selectedCatIndices.remove(index);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            _buildSmallField(
              _catFutureCtrl,
              "Predict out of N future selections (Optional)",
              hint: "e.g. 20 mangoes",
            ),
          ]

          // ===================================================================
          // MODE 1: DIRECT FRACTION, COMPLEMENT (1 - P) & REVERSE SOLVER UI
          // ===================================================================
          else if (_topicMode == 1) ...[
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _directSubMode,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Standard (n / T)\n& WASSCE Tables",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Given P, Find\nComplement (1 - x)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Reverse Solver\n(Find Total T)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                },
                onValueChanged: (int? val) {
                  if (val != null) {
                    setState(() {
                      _directSubMode = val;
                      _result = null;
                    });
                  }
                },
                thumbColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildSmallField(
              _directEventCtrl,
              "Event Name (e.g. Faulty car, WASSCE pass, Nurse)",
            ),
            const SizedBox(height: 12),
            if (_directSubMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildSmallField(
                      _directFavCtrl,
                      "Required Count (n)",
                      hint: "e.g. 50 or 51+56+57",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSmallField(
                      _directTotalCtrl,
                      "Total Count (T)",
                      hint: "e.g. 1000 or 86+93+102",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _directFindComplement,
                  children: const {
                    false: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Find P(Event) = n / T",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    true: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Find Complement (1 - n/T)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  },
                  onValueChanged: (bool? val) {
                    if (val != null) {
                      setState(() => _directFindComplement = val);
                    }
                  },
                  thumbColor: Colors.deepPurple.shade100,
                ),
              ),
              const SizedBox(height: 12),
              _buildSmallField(
                _directFutureCtrl,
                "Predict out of N future trials (Optional)",
                hint: "e.g. 50",
              ),
            ] else if (_directSubMode == 1) ...[
              _buildSmallField(
                _givenProbCtrl,
                "Known Probability x (Decimal, Fraction, or %)",
                hint: "e.g. 0.8, 0.05, or 9/12",
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _reverseFindTotal,
                  children: const {
                    true: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Given n & P → Find Total (T)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                    false: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Given T & P → Find Count (n)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                  },
                  onValueChanged: (bool? val) {
                    if (val != null) setState(() => _reverseFindTotal = val);
                  },
                  thumbColor: Colors.deepPurple.shade100,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallField(
                      _reverseCountCtrl,
                      _reverseFindTotal
                          ? "Known Required Count (n)"
                          : "Known Total (T)",
                      hint: "e.g. 35",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSmallField(
                      _reverseProbCtrl,
                      "Given Probability (P)",
                      hint: "e.g. 0.25 or 7/10",
                    ),
                  ),
                ],
              ),
            ],
          ]

          // ===================================================================
          // MODE 2: NUMBERED RANGE, DICE & CARDS ANALYZER UI
          // ===================================================================
          else ...[
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _rangeSourceType,
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Numbered Range (A to B)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Custom Number List",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  },
                  onValueChanged: (int? val) {
                    if (val != null) setState(() => _rangeSourceType = val);
                  },
                  thumbColor: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              if (_rangeSourceType == 0)
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallField(
                        _rangeStartCtrl,
                        "Start Number",
                        hint: "e.g. 1",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSmallField(
                        _rangeEndCtrl,
                        "End Number",
                        hint: "e.g. 6 or 20",
                      ),
                    ),
                  ],
                )
              else
                _buildSmallField(
                  _customListCtrl,
                  "Comma-Separated Numbers (e.g. Temperatures)",
                  hint: "26, 26, 27, 27, 26, 27, 27",
                ),
              const SizedBox(height: 14),
              const Text("Select Favorable Condition:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _rangeCondition,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                                value: 'equals',
                                child: Text("Equals number(s)",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'not_equals',
                                child: Text("Does NOT equal",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'not_contains_digit',
                                child: Text("Does NOT have digit",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'contains_digit',
                                child: Text("Contains digit",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'even',
                                child: Text("Even numbers",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'odd',
                                child: Text("Odd numbers",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'prime',
                                child: Text("Prime numbers",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'multiple',
                                child: Text("Multiple of k",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'greater',
                                child: Text("Greater than (>)",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(
                                value: 'less',
                                child: Text("Less than (<)",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          onChanged: (String? val) {
                            if (val != null) {
                              setState(() => _rangeCondition = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  if (!['even', 'odd', 'prime'].contains(_rangeCondition)) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _buildSmallField(
                        _rangeTargetValCtrl,
                        "Target Value",
                        hint: "e.g. 1 or 6",
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _buildSmallField(
                _rangeFutureCtrl,
                "Predict out of N future trials (Optional)",
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
    math.max(360.0, 235.0 + (_result!.categories.length * 46.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Probability Scale & Fraction Partition:",
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
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: ProbFractionPainter(result: _result!),
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
      appBar: AppBar(title: const Text('Probability as a Fraction')),
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
// CUSTOM PAINTER: PROBABILITY SCALE (0 TO 1) & SAMPLE SPACE FRACTION PARTITION
// =============================================================================
class ProbFractionPainter extends CustomPainter {
  final ProbFractionResult result;

  ProbFractionPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 42.0;
    final double rightPad = size.width - 42.0;
    final double scaleWidth = rightPad - leftPad;

    // -------------------------------------------------------------------------
    // PART 1: THE PROBABILITY SCALE (0 to 1 Number Line)
    // -------------------------------------------------------------------------
    _drawText(
      canvas,
      "Probability Scale (0 = Impossible, 1 = Certain)",
      size.width / 2,
      20,
      fontSize: 14.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    const double scaleY = 76.0;
    final trackPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(leftPad, scaleY), Offset(rightPad, scaleY), trackPaint);

    double clampedP = result.probabilityDecimal.clamp(0.0, 1.0);
    double markerX = leftPad + (clampedP * scaleWidth);

    final activeTrackPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(leftPad, scaleY), Offset(markerX, scaleY), activeTrackPaint);

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
      _drawText(canvas, t['num'] as String, tx, scaleY + 20,
          fontSize: 12, isBold: true);
      _drawText(canvas, t['label'] as String, tx, scaleY + 35,
          fontSize: 11, color: Colors.grey.shade700);
    }

    canvas.drawCircle(
        Offset(markerX, scaleY), 9, Paint()..color = Colors.green.shade700);
    canvas.drawCircle(
        Offset(markerX, scaleY), 4, Paint()..color = Colors.white);

    String fracLabel = result.simplifiedNum == 0
        ? "0"
        : (result.simplifiedNum == result.simplifiedDen
        ? "1"
        : "${result.simplifiedNum}/${result.simplifiedDen}");
    String pctLabel =
        "${(clampedP * 100).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%";
    _drawBadge(canvas, "P = $fracLabel ($pctLabel)", markerX, scaleY - 26,
        Colors.green.shade700);

    // -------------------------------------------------------------------------
    // PART 2: COMPLEMENT PARTITION BAR (P + (1 - P) = 1)
    // -------------------------------------------------------------------------
    const double partBarY = 148.0;
    const double partBarH = 26.0;
    _drawText(
      canvas,
      "Sample Space Partition: Required (${result.favorableCount}) vs Complement (${result.totalCount - result.favorableCount}) out of ${result.totalCount}",
      size.width / 2,
      partBarY - 14,
      fontSize: 13,
      isBold: true,
      color: Colors.deepPurple,
    );

    RRect fullPartRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(leftPad, partBarY, scaleWidth, partBarH),
      const Radius.circular(8),
    );
    canvas.drawRRect(fullPartRect, Paint()..color = Colors.deepPurple.shade100);

    double favW = clampedP * scaleWidth;
    if (favW > 0) {
      RRect favRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPad, partBarY, favW, partBarH),
        const Radius.circular(8),
      );
      canvas.drawRRect(favRect, Paint()..color = Colors.green.shade600);
    }

    if (clampedP >= 0.14) {
      _drawText(
        canvas,
        "P = $fracLabel",
        leftPad + favW / 2,
        partBarY + partBarH / 2,
        fontSize: 11.5,
        isBold: true,
        color: Colors.white,
      );
    }
    if (1.0 - clampedP >= 0.16) {
      int compN = result.simplifiedDen - result.simplifiedNum;
      String compFrac = compN == 0
          ? "0"
          : (compN == result.simplifiedDen
          ? "1"
          : "$compN/${result.simplifiedDen}");
      _drawText(
        canvas,
        "1 - P = $compFrac",
        leftPad + favW + (scaleWidth - favW) / 2,
        partBarY + partBarH / 2,
        fontSize: 11.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );
    }

    // -------------------------------------------------------------------------
    // PART 3: CATEGORY BREAKDOWN BARS
    // -------------------------------------------------------------------------
    double startY = 212.0;
    const double rowHeight = 42.0;
    const double nameColX = 42.0;
    const double barColX = 240.0;
    final double maxBarWidth = math.max(90.0, size.width - barColX - 75.0);

    for (int i = 0; i < result.categories.length; i++) {
      var cat = result.categories[i];
      double cy = startY + (i * rowHeight);
      Color rowColor =
      cat.isTarget ? Colors.green.shade700 : Colors.blueGrey.shade600;

      String cleanName = cat.name.length > 22
          ? "${cat.name.substring(0, 20)}..."
          : cat.name;
      _drawText(
        canvas,
        cat.isTarget ? "★ $cleanName" : cleanName,
        nameColX,
        cy,
        fontSize: 12.5,
        isBold: cat.isTarget,
        color: rowColor,
        alignLeft: true,
      );

      double ratio = result.totalCount > 0
          ? (cat.effectiveCount / result.totalCount)
          : 0.0;
      double barW = math.max(4.0, ratio.clamp(0.0, 1.0) * maxBarWidth);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barColX, cy - 9, maxBarWidth, 18),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.grey.shade200,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barColX, cy - 9, barW, 18),
          const Radius.circular(6),
        ),
        Paint()..color = rowColor,
      );

      _drawText(
        canvas,
        "${cat.effectiveCount}/${result.totalCount}",
        barColX + maxBarWidth + 10,
        cy,
        fontSize: 12,
        isBold: true,
        color: rowColor,
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
            color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double padH = 10;
    double padV = 5;
    double clampedX =
    x.clamp(tp.width / 2 + padH + 6, 560.0 - tp.width / 2 - padH - 6);
    Rect rect = Rect.fromCenter(
      center: Offset(clampedX, y),
      width: tp.width + padH * 2,
      height: tp.height + padV * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = bgColor,
    );
    tp.paint(canvas, Offset(clampedX - tp.width / 2, y - tp.height / 2));
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