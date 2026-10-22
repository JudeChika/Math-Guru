import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'inequalities_logic.dart';
import 'inequalities_models.dart';

class InequalitiesScreen extends StatefulWidget {
  const InequalitiesScreen({super.key});

  @override
  State<InequalitiesScreen> createState() => _InequalitiesScreenState();
}

class _InequalitiesScreenState extends State<InequalitiesScreen> {
  int _inputMode = 1; // 0: AI Vision / Word Problem, 1: Manual Builder
  int _mode = 0; // 0: Compare/T-F, 1: QR Substitution, 2: Word Translation, 3: 2-Person, 4: Geometry
  int _subMode = 0;

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0 & Mode 1 Controllers (Compare Quantities, True/False & QR Box)
  final TextEditingController _lhsCtrl = TextEditingController(text: '(-5)^2');
  final TextEditingController _rhsCtrl = TextEditingController(text: '(2)^2');
  String _claimSymbol = '>';
  final TextEditingController _varNameCtrl = TextEditingController(text: 'n');
  final TextEditingController _varValCtrl = TextEditingController(text: '3');

  // Mode 2 Controllers (From Words to Algebraic Inequalities)
  final TextEditingController _contextDescCtrl =
  TextEditingController(text: 'The distance between two villages');
  String _phraseKey = 'over';
  final TextEditingController _boundValCtrl = TextEditingController(text: '18');
  final TextEditingController _secondValCtrl =
  TextEditingController(text: '200');
  final TextEditingController _unitCtrl = TextEditingController(text: 'km');
  bool _convertHoursToMins = false;

  // Mode 3 Controllers (Two-Person Threshold Comparison — Example 4)
  final TextEditingController _p1NameCtrl =
  TextEditingController(text: 'Deborah');
  final TextEditingController _p1VarCtrl = TextEditingController(text: 'd');
  final TextEditingController _p2NameCtrl =
  TextEditingController(text: 'Taiwo');
  final TextEditingController _p2VarCtrl = TextEditingController(text: 't');
  final TextEditingController _itemLabelCtrl =
  TextEditingController(text: 'Notebook cost (₦)');

  // Mode 4 Controllers (Geometric Bounds — Squares & Circles)
  String _geoSymbol = '<';

  InequalityResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<Map<String, String>> _phraseOptions = [
    {
      'key': 'less',
      'label': '<  (is less than / under / below)',
    },
    {
      'key': 'over',
      'label': '>  (is greater than / over / more than)',
    },
    {
      'key': 'not_greater',
      'label':
      '≤  (is not greater than / at most / or less / within limit / never more than)',
    },
    {
      'key': 'not_less',
      'label': '≥  (is not less than / at least / or more / minimum)',
    },
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _lhsCtrl.dispose();
    _rhsCtrl.dispose();
    _varNameCtrl.dispose();
    _varValCtrl.dispose();
    _contextDescCtrl.dispose();
    _boundValCtrl.dispose();
    _secondValCtrl.dispose();
    _unitCtrl.dispose();
    _p1NameCtrl.dispose();
    _p1VarCtrl.dispose();
    _p2NameCtrl.dispose();
    _p2VarCtrl.dispose();
    _itemLabelCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(InequalityPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _lhsCtrl.text = p.lhsExpr;
      _rhsCtrl.text = p.rhsExpr;
      _claimSymbol = p.claimSymbol;
      _varNameCtrl.text = p.varName;
      _varValCtrl.text = p.varValue;
      _phraseKey = p.phraseKey;
      _boundValCtrl.text = p.boundaryVal;
      _secondValCtrl.text = p.secondVal;
      _unitCtrl.text = p.unit;
      _contextDescCtrl.text = p.contextDescription;
      _convertHoursToMins = false;
      _p1NameCtrl.text = p.person1Name;
      _p1VarCtrl.text = p.person1Var;
      _p2NameCtrl.text = p.person2Name;
      _p2VarCtrl.text = p.person2Var;
      _itemLabelCtrl.text = p.itemLabel;
      _geoSymbol = p.geoSymbol;
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
            content: Text('Please enter a question or upload a textbook image.')),
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
      You are a strict JSON data extractor for JSS2 Section 22-1: Inequalities.
      Classify the question or image into one of 5 modes:
      - "mode":
        0 for Comparing two numbers/expressions with > or < (subMode 0) OR checking if an inequality is True (T) or False (F) (subMode 1).
        1 for Algebraic Substitution Comparison (QR Box: e.g. when n = 3, compare 5n - n and 7 + 2n).
        2 for Translating Word Statements into Algebraic Inequalities:
          subMode 0: Direct statement (e.g. distance d is over 18 km; speed v is never more than 120 km/h).
          subMode 1: Spending money (Have x naira, spend secondVal, amount left < boundaryVal).
          subMode 2: Savings + Father's gift (Saved > boundaryVal, given secondVal, total is y).
          subMode 3: Future age (In secondVal years' time, will be > boundaryVal).
          subMode 4: Multi-unit load or density per hectare (secondVal lorries/hectares, each > or < boundaryVal).
        3 for Two-Person Threshold Comparison (Example 4: Deborah d cannot afford 120, Taiwo t can afford 120; or pass mark 27 where x failed and y passed).
        4 for Geometric Inequalities:
          subMode 0: Square Area -> Side & Perimeter (Example 3 & Ex 22b #7).
          subMode 1: Square Perimeter -> Side & Area (Ex 22b #8).
          subMode 2: Circle Radius -> Circumference & Area in terms of pi (Ex 22c #5).

      Note on "phraseKey": one of "less", "over", "not_greater", "not_less".
      Return ONLY valid JSON:
      {
        "mode": 2,
        "subMode": 0,
        "lhsExpr": "(-5)^2",
        "rhsExpr": "(2)^2",
        "claimSymbol": ">",
        "varName": "d",
        "varValue": "3",
        "phraseKey": "over",
        "boundaryVal": "18",
        "secondVal": "200",
        "unit": "km",
        "contextDescription": "The distance between two villages",
        "person1Name": "Deborah",
        "person1Var": "d",
        "person2Name": "Taiwo",
        "person2Var": "t",
        "itemLabel": "Notebook cost (₦)",
        "geoSymbol": "<"
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 4);
        _subMode = ((jsonMap['subMode'] as num?)?.toInt() ?? 0).clamp(0, 4);
        if (jsonMap['lhsExpr'] != null) {
          _lhsCtrl.text = jsonMap['lhsExpr'].toString();
        }
        if (jsonMap['rhsExpr'] != null) {
          _rhsCtrl.text = jsonMap['rhsExpr'].toString();
        }
        final String cs = jsonMap['claimSymbol']?.toString() ?? '>';
        if (['>', '<', '>=', '<='].contains(cs)) _claimSymbol = cs;
        if (jsonMap['varName'] != null) {
          _varNameCtrl.text = jsonMap['varName'].toString();
        }
        if (jsonMap['varValue'] != null) {
          _varValCtrl.text = jsonMap['varValue'].toString();
        }
        final String pk = jsonMap['phraseKey']?.toString() ?? 'over';
        if (['less', 'over', 'not_greater', 'not_less'].contains(pk)) {
          _phraseKey = pk;
        }
        if (jsonMap['boundaryVal'] != null) {
          _boundValCtrl.text = jsonMap['boundaryVal'].toString();
        }
        if (jsonMap['secondVal'] != null) {
          _secondValCtrl.text = jsonMap['secondVal'].toString();
        }
        if (jsonMap['unit'] != null) _unitCtrl.text = jsonMap['unit'].toString();
        if (jsonMap['contextDescription'] != null) {
          _contextDescCtrl.text = jsonMap['contextDescription'].toString();
        }
        if (jsonMap['person1Name'] != null) {
          _p1NameCtrl.text = jsonMap['person1Name'].toString();
        }
        if (jsonMap['person1Var'] != null) {
          _p1VarCtrl.text = jsonMap['person1Var'].toString();
        }
        if (jsonMap['person2Name'] != null) {
          _p2NameCtrl.text = jsonMap['person2Name'].toString();
        }
        if (jsonMap['person2Var'] != null) {
          _p2VarCtrl.text = jsonMap['person2Var'].toString();
        }
        if (jsonMap['itemLabel'] != null) {
          _itemLabelCtrl.text = jsonMap['itemLabel'].toString();
        }
        final String gs = jsonMap['geoSymbol']?.toString() ?? '<';
        if (['<', '>', '<=', '>='].contains(gs)) _geoSymbol = gs;
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
        _result = InequalitiesLogic.solveComparisonAndTruth(
          subMode: _subMode.clamp(0, 1),
          lhsStr: _lhsCtrl.text,
          rhsStr: _rhsCtrl.text,
          claimSymbol: _claimSymbol,
        );
      } else if (_mode == 1) {
        _result = InequalitiesLogic.solveSubstitutionComparison(
          varName: _varNameCtrl.text,
          varValueStr: _varValCtrl.text,
          lhsExprStr: _lhsCtrl.text,
          rhsExprStr: _rhsCtrl.text,
        );
      } else if (_mode == 2) {
        _result = InequalitiesLogic.solveWordTranslation(
          subMode: _subMode.clamp(0, 4),
          contextDesc: _contextDescCtrl.text,
          varName: _varNameCtrl.text,
          phraseKey: _phraseKey,
          boundaryValStr: _boundValCtrl.text,
          secondValStr: _secondValCtrl.text,
          unitStr: _unitCtrl.text,
          convertHoursToMinutes: _convertHoursToMins,
        );
      } else if (_mode == 3) {
        _result = InequalitiesLogic.solveTwoPersonThreshold(
          person1Name: _p1NameCtrl.text,
          person1Var: _p1VarCtrl.text,
          person2Name: _p2NameCtrl.text,
          person2Var: _p2VarCtrl.text,
          thresholdStr: _boundValCtrl.text,
          itemLabel: _itemLabelCtrl.text,
        );
      } else {
        _result = InequalitiesLogic.solveGeometryBounds(
          subMode: _subMode.clamp(0, 2),
          varName: _varNameCtrl.text,
          symStr: _geoSymbol,
          boundValStr: _boundValCtrl.text,
          unitStr: _unitCtrl.text,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _canvasTransformController.value = Matrix4.identity();
      }
    });
  }

  // ===========================================================================
  // REUSABLE UI WIDGET HELPERS
  // ===========================================================================
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

  Widget _buildSymbolSelector({
    required String currentSymbol,
    required ValueChanged<String> onChanged,
    String title = "Select Inequality Symbol:",
  }) {
    const List<Map<String, String>> syms = [
      {'val': '<', 'disp': '< (Less than)'},
      {'val': '>', 'disp': '> (Greater than)'},
      {'val': '<=', 'disp': '≤ (Not greater)'},
      {'val': '>=', 'disp': '≥ (Not less)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: syms.map((s) {
            final bool isSel = currentSymbol == s['val'];
            return ChoiceChip(
              label: Text(
                s['disp']!,
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
              onSelected: (_) => onChanged(s['val']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetsBar() {
    const presets = InequalitiesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick-Load Textbook Examples & Exercises:"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.auto_stories,
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
        'label': 'Compare (> / <) & True/False',
        'icon': Icons.compare_arrows,
      },
      {
        'idx': 1,
        'label': 'Substitution Box (n = 3)',
        'icon': Icons.functions,
      },
      {
        'idx': 2,
        'label': 'Words to Algebra (≤ / ≥)',
        'icon': Icons.translate,
      },
      {
        'idx': 3,
        'label': 'Two-Person Threshold (Ex 4)',
        'icon': Icons.people_alt_outlined,
      },
      {
        'idx': 4,
        'label': 'Square & Circle Bounds',
        'icon': Icons.square_foot,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Inequality Problem Type:"),
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
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _subMode.clamp(0, 1),
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Fill in Box (> or <)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: _subMode == 0 ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "True (T) or False (F) Check",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
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
                    _lhsCtrl,
                    "Left-Hand Side (LHS)",
                    hint: "e.g. (-5)^2, 30, or 4",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _rhsCtrl,
                    "Right-Hand Side (RHS)",
                    hint: "e.g. (2)^2, -50 + 20, or a",
                  ),
                ),
              ],
            ),
            if (_subMode == 1) ...[
              const SizedBox(height: 12),
              _buildSymbolSelector(
                currentSymbol: _claimSymbol,
                title: "Claimed Symbol to Test (True or False):",
                onChanged: (val) => setState(() => _claimSymbol = val),
              ),
            ],
          ] else if (_mode == 1) ...[
            const Text(
              "QR Box — Put > or < in the box when variable = given value:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varNameCtrl,
                    "Variable Letter",
                    hint: "e.g. n",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _varValCtrl,
                    "Given Value",
                    hint: "e.g. 3",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _lhsCtrl,
                    "Left Algebraic Expression",
                    hint: "e.g. 5n - n or 1 - n^2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _rhsCtrl,
                    "Right Algebraic Expression",
                    hint: "e.g. 7 + 2n or 21 - 10n",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle("Select Word Problem Archetype:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                {'idx': 0, 'label': 'Direct Statement (Ex 1)'},
                {'idx': 1, 'label': 'Spend Money (Ex 2: x − A < B)'},
                {'idx': 2, 'label': 'Savings + Gift (Ex 22b #4)'},
                {'idx': 3, 'label': 'Future Age (Ex 22b #5)'},
                {'idx': 4, 'label': 'Load / Per Hectare (Ex 22b #3, #6)'},
              ].map((opt) {
                final int idx = opt['idx'] as int;
                final bool isSel = _subMode == idx;
                return ChoiceChip(
                  label: Text(
                    opt['label'] as String,
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
                    color:
                    isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _subMode = idx),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTextField(
                    _contextDescCtrl,
                    "Description of Unknown Quantity",
                    hint: "e.g. Distance between two villages",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varNameCtrl,
                    "Letter",
                    hint: "e.g. d, x, y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Key Inequality Phrase in Word Problem:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
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
                  value: _phraseKey,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.deepPurple),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                  items: _phraseOptions.map((po) {
                    return DropdownMenuItem<String>(
                      value: po['key']!,
                      child: Text(
                        po['label']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _phraseKey = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _boundValCtrl,
                    _subMode == 1
                        ? "Remaining Bound (e.g. 50)"
                        : (_subMode == 2
                        ? "Initial Saved Bound (e.g. 500)"
                        : "Boundary Number (e.g. 18)"),
                    hint: "e.g. 18 or 50",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _unitCtrl,
                    "Unit (Optional)",
                    hint: "e.g. km, ₦, min",
                  ),
                ),
              ],
            ),
            if (_subMode > 0) ...[
              const SizedBox(height: 12),
              _buildTextField(
                _secondValCtrl,
                _subMode == 1
                    ? "Amount Spent (e.g. 200)"
                    : (_subMode == 2
                    ? "Additional Gift (e.g. 200)"
                    : (_subMode == 3
                    ? "Years in Future (e.g. 3)"
                    : "Number of Lorries / Hectares (e.g. 7 or 3)")),
                hint: "e.g. 200 or 3",
              ),
            ],
            if (_subMode == 0) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Convert Boundary from Hours to Minutes (Ex 22b #1h)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: _convertHoursToMins,
                    activeColor: Colors.deepPurple,
                    onChanged: (v) =>
                        setState(() => _convertHoursToMins = v),
                  ),
                ],
              ),
            ],
          ] else if (_mode == 3) ...[
            const Text(
              "Two-Person Threshold Comparison (Example 4 & Ex 22c #3–4):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _p1NameCtrl,
                    "Person 1 (Below / Failed)",
                    hint: "e.g. Deborah",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _p1VarCtrl,
                    "Letter 1",
                    hint: "e.g. d or x",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _p2NameCtrl,
                    "Person 2 (Able / Passed)",
                    hint: "e.g. Taiwo",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _p2VarCtrl,
                    "Letter 2",
                    hint: "e.g. t or y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _boundValCtrl,
                    "Cost / Pass Mark Threshold",
                    hint: "e.g. 120, 27, or 150",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _itemLabelCtrl,
                    "Threshold Description",
                    hint: "e.g. Notebook cost (₦)",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle("Select Geometric Inequality Scenario:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                {'idx': 0, 'label': 'Square Area → Side & Perimeter (Ex 3)'},
                {'idx': 1, 'label': 'Square Perimeter → Side & Area (Ex 22b #8)'},
                {'idx': 2, 'label': 'Circle Radius → C & Area in π (Ex 22c #5)'},
              ].map((opt) {
                final int idx = opt['idx'] as int;
                final bool isSel = _subMode == idx;
                return ChoiceChip(
                  label: Text(
                    opt['label'] as String,
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
                    color:
                    isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _subMode = idx),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildSymbolSelector(
              currentSymbol: _geoSymbol,
              title: "Given Inequality Symbol:",
              onChanged: (val) => setState(() => _geoSymbol = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    _boundValCtrl,
                    _subMode == 0
                        ? "Area Bound (e.g. 25 or 36)"
                        : (_subMode == 1
                        ? "Perimeter Bound (e.g. 28)"
                        : "Radius Bound (e.g. 3)"),
                    hint: "e.g. 25, 28, or 3",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _varNameCtrl,
                    "Side/Radius Letter",
                    hint: _subMode == 2 ? "r" : "a",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _unitCtrl,
                    "Unit",
                    hint: "cm or m",
                  ),
                ),
              ],
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
                    "Snap a photo of any inequality statement, QR substitution box, or word problem from Section 22-1, and the AI will solve it step-by-step!",
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
              labelText: "Word Problem or Inequality Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Notebooks cost ₦120 each. Deborah has d naira and cannot buy one. Taiwo has t naira and is able to buy one...",
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
                "Extract & Solve Inequality",
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
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Solve & Explain Step-by-Step",
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
    final double canvasWidth = math.max(screenWidth, 650.0);
    const double canvasHeight = 300.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Inequality & Number Line Visualizer:",
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
          height: 300,
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
              boundaryMargin: const EdgeInsets.all(120),
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: InequalityVisualizerPainter(
                    visual: _result!.visualData,
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
          '22-1 Inequalities',
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

class InequalityVisualizerPainter extends CustomPainter {
  final InequalityVisualData visual;

  InequalityVisualizerPainter({required this.visual});

  String _fmt(double v) => InequalitiesLogic.fmt(v, maxDecimals: 1);

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // Header Badge
    _drawText(
      canvas,
      visual.headerBadge,
      cx,
      26,
      fontSize: 15,
      isBold: true,
      color: Colors.deepPurple,
    );

    if (visual.subBadge1.isNotEmpty) {
      _drawText(
        canvas,
        visual.subBadge1,
        cx,
        52,
        fontSize: 12.5,
        isBold: true,
        color: Colors.green.shade800,
      );
    }

    if (visual.visualType == 0) {
      _paintNumberLineComparison(canvas, size);
    } else if (visual.visualType == 1) {
      _paintSingleRayThreshold(canvas, size);
    } else if (visual.visualType == 2) {
      _paintTwoPersonThreshold(canvas, size);
    } else {
      _paintGeometryBounds(canvas, size);
    }
  }

  void _paintNumberLineComparison(Canvas canvas, Size size) {
    const double lineY = 185.0;
    const double leftX = 70.0;
    final double rightX = size.width - 70.0;

    canvas.drawLine(
      Offset(leftX, lineY),
      Offset(rightX, lineY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5,
    );

    final double minV = math.min(math.min(visual.val1, visual.val2), 0.0) - 2.0;
    final double maxV = math.max(math.max(visual.val1, visual.val2), 0.0) + 2.0;
    final double span = math.max(maxV - minV, 1.0);

    double toX(double v) => leftX + ((v - minV) / span) * (rightX - leftX);

    // Draw Origin 0 tick
    final double zeroX = toX(0);
    canvas.drawLine(
      Offset(zeroX, lineY - 8),
      Offset(zeroX, lineY + 8),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );
    _drawText(canvas, "0", zeroX, lineY + 22, fontSize: 12, isBold: true);

    final double x1 = toX(visual.val1);
    final double x2 = toX(visual.val2);

    // Plot RHS point
    canvas.drawCircle(
      Offset(x2, lineY),
      7.5,
      Paint()..color = Colors.orange.shade800,
    );
    _drawText(
      canvas,
      visual.label2,
      x2,
      lineY + 42,
      fontSize: 12.5,
      isBold: true,
      color: Colors.orange.shade900,
    );

    // Plot LHS point
    canvas.drawCircle(
      Offset(x1, lineY),
      8.5,
      Paint()..color = Colors.deepPurple,
    );
    _drawText(
      canvas,
      visual.label1,
      x1,
      lineY - 34,
      fontSize: 12.5,
      isBold: true,
      color: Colors.deepPurple,
    );

    _drawText(
      canvas,
      "Number Line Rule: Numbers further to the RIGHT are GREATER (>)",
      size.width / 2,
      265,
      fontSize: 12,
      isBold: true,
      color: Colors.grey.shade700,
    );
  }

  void _paintSingleRayThreshold(Canvas canvas, Size size) {
    const double lineY = 185.0;
    const double leftX = 80.0;
    final double rightX = size.width - 80.0;
    final double midX = size.width / 2;

    // Base number line
    canvas.drawLine(
      Offset(leftX, lineY),
      Offset(rightX, lineY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5,
    );

    // Tick at boundary
    canvas.drawLine(
      Offset(midX, lineY - 10),
      Offset(midX, lineY + 10),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5,
    );
    _drawText(
      canvas,
      _fmt(visual.val1),
      midX,
      lineY + 28,
      fontSize: 13.5,
      isBold: true,
    );

    // Raised Inequality Ray (Previewing Figure 22.1 & 22.2!)
    const double rayY = lineY - 42.0;
    final double endX = visual.pointsRight ? rightX - 20 : leftX + 20;

    canvas.drawLine(
      Offset(midX, rayY),
      Offset(endX, rayY),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 4.0,
    );

    // Arrowhead on ray
    final double dir = visual.pointsRight ? -1.0 : 1.0;
    final Path arrow = Path()
      ..moveTo(endX, rayY)
      ..lineTo(endX + dir * 12, rayY - 6)
      ..lineTo(endX + dir * 12, rayY + 6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.green.shade700);

    // Open circle (< or >) vs Solid shaded circle (≤ or ≥)
    canvas.drawCircle(
      Offset(midX, rayY),
      8.0,
      Paint()
        ..color = visual.isInclusive ? Colors.green.shade700 : Colors.white,
    );
    canvas.drawCircle(
      Offset(midX, rayY),
      8.0,
      Paint()
        ..color = Colors.green.shade800
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      visual.isInclusive
          ? "Solid Circle (●): Boundary ${_fmt(visual.val1)} IS Included (${visual.symbol})"
          : "Open Circle (○): Boundary ${_fmt(visual.val1)} is NOT Included (${visual.symbol})",
      midX,
      258,
      fontSize: 12,
      isBold: true,
      color: Colors.deepPurple,
    );
  }

  void _paintTwoPersonThreshold(Canvas canvas, Size size) {
    const double lineY = 195.0;
    const double leftX = 80.0;
    final double rightX = size.width - 80.0;
    final double midX = size.width / 2;

    canvas.drawLine(
      Offset(leftX, lineY),
      Offset(rightX, lineY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(midX, lineY - 12),
      Offset(midX, lineY + 12),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5,
    );
    _drawText(
      canvas,
      "Threshold = ${_fmt(visual.val1)}",
      midX,
      lineY + 28,
      fontSize: 13,
      isBold: true,
    );

    // Left Ray: Person 1 (< K, Open Circle)
    const double p1Y = lineY - 38.0;
    canvas.drawLine(
      Offset(midX, p1Y),
      Offset(leftX + 20, p1Y),
      Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 3.5,
    );
    canvas.drawCircle(Offset(midX, p1Y), 7, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(midX, p1Y),
      7,
      Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      visual.label1,
      (midX + leftX) / 2,
      p1Y - 18,
      fontSize: 12,
      isBold: true,
      color: Colors.orange.shade900,
    );

    // Right Ray: Person 2 (≥ K, Solid Circle)
    const double p2Y = lineY - 72.0;
    canvas.drawLine(
      Offset(midX, p2Y),
      Offset(rightX - 20, p2Y),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 3.5,
    );
    canvas.drawCircle(
      Offset(midX, p2Y),
      7.5,
      Paint()..color = Colors.green.shade700,
    );
    _drawText(
      canvas,
      visual.label2,
      (midX + rightX) / 2,
      p2Y - 18,
      fontSize: 12,
      isBold: true,
      color: Colors.green.shade800,
    );
  }

  void _paintGeometryBounds(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double cy = 175.0;

    final Paint fill = Paint()..color = Colors.deepPurple.shade50;
    final Paint stroke = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    if (visual.label1 == 'circle') {
      canvas.drawCircle(Offset(cx, cy), 64, fill);
      canvas.drawCircle(Offset(cx, cy), 64, stroke);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + 64, cy),
        Paint()
          ..color = Colors.green.shade700
          ..strokeWidth = 2.5,
      );
      _drawText(
        canvas,
        "r ${visual.symbol} ${_fmt(visual.val1)}",
        cx + 32,
        cy - 12,
        fontSize: 12,
        isBold: true,
        color: Colors.green.shade900,
      );
    } else {
      final Rect sq =
      Rect.fromCenter(center: Offset(cx, cy), width: 120, height: 120);
      canvas.drawRect(sq, fill);
      canvas.drawRect(sq, stroke);
      _drawText(
        canvas,
        visual.subBadge1,
        cx,
        cy + 78,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple,
      );
    }

    if (visual.subBadge2.isNotEmpty) {
      _drawText(
        canvas,
        visual.subBadge2,
        cx,
        cy,
        fontSize: 12.5,
        isBold: true,
        color: Colors.green.shade900,
      );
    }
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
  bool shouldRepaint(covariant InequalityVisualizerPainter oldDelegate) =>
      oldDelegate.visual != visual;
}