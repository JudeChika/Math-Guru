import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'other_bases_to_binary_logic.dart';
import 'other_bases_to_binary_models.dart';

class OtherBasesToBinaryScreen extends StatefulWidget {
  const OtherBasesToBinaryScreen({super.key});

  @override
  State<OtherBasesToBinaryScreen> createState() =>
      _OtherBasesToBinaryScreenState();
}

class _OtherBasesToBinaryScreenState extends State<OtherBasesToBinaryScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Base 10 to Binary (Whole Numbers, Decimals, Mixed & Proper Fractions — Ex 4a, Ex 1.3 #1a–h, #3h)
  // 1: Other Number Bases (b = 3..16) to Binary — Whole Numbers (Ex 4b, Ex 1.3 #3a–g)
  // 2: Fractional Numbers in Other Bases to Binary — Method 1 & Method 2 (Ex 4c, Ex 1.3 #3i)
  // 3: Powers (N_b)ᵏ to Binary & Bicimal Revision (Ex 1.3 #2a–f & #3j)

  int _subMode = 0; // For Mode 3: 0 = Power (N_b)ᵏ to Binary, 1 = Bicimal to Base 10 Revision

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _inputCtrl = TextEditingController();
  int _selectedBase = 5; // For Mode 1, 2, 3: 3, 4, 5, 6, 7, 8, 9, 10, 12, 16
  int _selectedExponent = 2; // For Mode 3 SubMode 0: 2, 3, 4

  OtherBasesToBinaryResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<int> _supportedOtherBases = [
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    12,
    16,
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _inputCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(OtherBasesToBinaryPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _inputCtrl.text = p.inputStr;
      if (_supportedOtherBases.contains(p.baseInt)) {
        _selectedBase = p.baseInt;
      }
      _selectedExponent = p.exponentK;
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
              'Please enter a number base conversion question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 1: Conversion of Other Number Bases to Binary.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Converting a Base 10 whole number, decimal, mixed number, or fraction (e.g. 324, 25.0625, 112.125, 20 3/4, 15/16, 0.75) to binary (Example 4a & Exercise 1.3 #1a-h, #3h).
        1 for Converting a whole number in another base (b = 3, 4, 5, 6, 7, 8, 9, 12, 16) to binary (e.g. 124_five, 234_six, 245_eight, 857_nine, 121_three — Example 4b & Exercise 1.3 #3a-g).
        2 for Converting a fractional number in another base to binary (e.g. 306.43_eight or 73.5_nine — Example 4c & Exercise 1.3 #3i).
        3 for Expressing a power (N_b)^k in binary (subMode 0, e.g. (9_ten)^2 in Ex 1.3 #3j) OR converting a binary/bicimal number to base 10 (subMode 1, e.g. 1 101.100 1_two in Ex 1.3 #2a-f).

      Return ONLY valid JSON:
      {
        "mode": 2,
        "subMode": 0,
        "inputStr": "306.43",
        "baseInt": 8,
        "exponentK": 2
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
        if (jsonMap['inputStr'] != null) {
          _inputCtrl.text = jsonMap['inputStr'].toString();
        }
        final int b = (jsonMap['baseInt'] as num?)?.toInt() ?? 8;
        if (_supportedOtherBases.contains(b)) {
          _selectedBase = b;
        }
        _selectedExponent =
            ((jsonMap['exponentK'] as num?)?.toInt() ?? 2).clamp(1, 5);
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
        _result = OtherBasesToBinaryLogic.solveBase10ToBinary(
          base10InputStr: _inputCtrl.text,
        );
      } else if (_mode == 1 || _mode == 2) {
        _result = OtherBasesToBinaryLogic.solveOtherBaseToBinary(
          mode: _mode,
          rawInputStr: _inputCtrl.text,
          baseInt: _selectedBase,
        );
      } else {
        _result = OtherBasesToBinaryLogic.solvePowerOrBicimalRevision(
          subMode: _subMode,
          inputStr: _inputCtrl.text,
          baseInt: _selectedBase,
          exponentK: _selectedExponent,
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

  Widget _buildBaseSelectorChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Select Given Base Subscript (Base b):",
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
          children: _supportedOtherBases.map((b) {
            final bool isSel = _selectedBase == b;
            final String bWord = OtherBasesToBinaryLogic.getBaseWord(b);
            final String bSub = OtherBasesToBinaryLogic.toUnicodeSubscript(b);
            return ChoiceChip(
              label: Text(
                "$bWord ($bSub)",
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
                color: isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedBase = b),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetsBar() {
    const presets = OtherBasesToBinaryLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 4a–c & Ex 1.3 #1–3):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.calculate_outlined,
                      size: 16, color: Colors.deepPurple),
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
        'label': 'Base 10 → Binary (Ex 4a & 1.3 #1)',
        'icon': Icons.tag,
      },
      {
        'idx': 1,
        'label': 'Other Bases → Binary (Ex 4b & 1.3 #3)',
        'icon': Icons.swap_horiz,
      },
      {
        'idx': 2,
        'label': 'Fractional Base → Binary (Ex 4c & 1.3 #3i)',
        'icon': Icons.pie_chart_outline,
      },
      {
        'idx': 3,
        'label': 'Powers (N_b)ᵏ & Bicimals (Ex 1.3 #2 & #3j)',
        'icon': Icons.functions,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Conversion Problem Mode:"),
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
                if (idx == 2 && _selectedBase == 10) {
                  _selectedBase = 8;
                }
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
            _buildSectionTitle(
                "2. Convert Base 10 Number (Whole, Decimal, Mixed or Fraction) to Binary:"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Base 10 Number",
              hint: "e.g. 324, 25, 623, 25.0625, 112.125, 20 3/4, or 15/16",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Convert Whole Number in Base b to Binary (Ex 4b & Ex 1.3 #3a–g):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Number in Base $_selectedBase (${OtherBasesToBinaryLogic.getBaseWord(_selectedBase)})",
              hint: "e.g. 124, 234, 23, 245, 32, 857, 121, or 623",
            ),
            _buildBaseSelectorChips(),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Convert Fractional Number in Base b to Binary — Method 1 & 2 (Ex 4c & Ex 1.3 #3i):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Fractional Number in Base $_selectedBase (${OtherBasesToBinaryLogic.getBaseWord(_selectedBase)})",
              hint: "e.g. 306.43 (base 8) or 73.5 (base 9)",
            ),
            _buildBaseSelectorChips(),
          ] else ...[
            _buildSectionTitle(
                "2. Powers Expressed in Binary (Ex 1.3 #3j) & Bicimal Revision (Ex 1.3 #2a–f):"),
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
                      "Express Power (N_b)ᵏ in Binary\n(Ex 1.3 #3j: (9₁₀)²)",
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
                      "Bicimal / Binary → Base 10\n(Ex 1.3 #2a–f Revision)",
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
            if (_subMode == 0) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      _inputCtrl,
                      "Number Inside Brackets",
                      hint: "e.g. 9",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedExponent,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 2, child: Text("Power: ² (Square)")),
                            DropdownMenuItem(
                                value: 3, child: Text("Power: ³ (Cube)")),
                            DropdownMenuItem(
                                value: 4, child: Text("Power: ⁴ (4th)")),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedExponent = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildBaseSelectorChips(),
            ] else ...[
              _buildTextField(
                _inputCtrl,
                "Enter Binary / Bicimal Number (Base 2)",
                hint: "e.g. 100.111 1, 1 001 100, 111 111, or 1 101.100 1",
              ),
            ],
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
                    "Snap a photo of any base conversion question from JSS 3 Chapter 1 (Example 4 or Exercise 1.3), and the AI will solve it step-by-step!",
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
              labelText: "Base Conversion Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Convert 306.43_eight to binary, or convert 20 3/4_ten to binary...",
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
                "Extract & Convert to Binary",
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
              "Convert to Binary Step-by-Step",
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

    final OtherBasesToBinaryCanvasData cd = _result!.canvasData;
    final int cellCount = cd.stage1Cells.length;
    final int ladderCount = cd.divisionLadders.length;
    int maxRows = 4;
    for (final l in cd.divisionLadders) {
      if (l.rows.length > maxRows) maxRows = l.rows.length;
    }

    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double stage1W =
    cellCount > 0 ? (135.0 + cellCount * 86.0 + 24.0) : 0.0;
    final double laddersW = ladderCount * 220.0 + 40.0;
    final double canvasWidth = math.max(screenWidth, stage1W + laddersW);
    final double canvasHeight = math.max(380.0, 130.0 + (maxRows + 1) * 28.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Two-Stage Conversion & Division-by-2 Visualizer:",
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
              boundaryMargin: const EdgeInsets.all(150),
              minScale: 0.35,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: OtherBasesToBinaryPainter(data: cd),
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
          'Conversion of Other Bases to Binary',
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

class OtherBasesToBinaryPainter extends CustomPainter {
  final OtherBasesToBinaryCanvasData data;

  OtherBasesToBinaryPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Top Header & Sub-Header Badges
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

    const double contentStartY = 62.0;
    const double labelColWidth = 118.0;
    const double cardW = 76.0;
    const double pointW = 28.0;
    const double gapX = 6.0;

    final double cardsW = data.stage1Cells.fold(
      0.0,
          (sum, c) => sum + (c.isPoint ? pointW : cardW) + gapX,
    );
    final double stage1BlockW =
    data.stage1Cells.isNotEmpty ? (labelColWidth + cardsW + 24.0) : 0.0;
    final double laddersBlockW = data.divisionLadders.length * 210.0;
    final double totalContentW = stage1BlockW + laddersBlockW;

    double currX = (size.width - totalContentW) / 2;
    if (currX < 14.0) currX = 14.0;

    // 2. Left Panel: Stage 1 Place-Value Expansion Grid (if base != 10 or in Bicimal Revision)
    if (data.stage1Cells.isNotEmpty) {
      currX = _paintStage1Grid(canvas, currX, contentStartY);
      currX += 24.0;
    }

    // 3. Right Panel: Stage 2 Repeated Division by 2 Remainder Ladders
    for (int i = 0; i < data.divisionLadders.length; i++) {
      _paintDivisionLadder(
        canvas,
        data.divisionLadders[i],
        currX,
        contentStartY,
      );
      currX += 210.0;
    }

    // 4. Bottom Summary Banner
    if (data.bottomSummaryBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.bottomSummaryBanner,
        cx,
        size.height - 20.0,
        Colors.green.shade800,
      );
    }
  }

  double _paintStage1Grid(Canvas canvas, double startX, double startY) {
    const double labelColWidth = 118.0;
    const double cardW = 76.0;
    const double pointW = 28.0;
    const double gapX = 6.0;
    const double rowH = 48.0;
    const double rowGapY = 8.0;

    final List<String> rowLabels = [
      "Powers of ${data.baseInt}:",
      "Place Value:",
      "Given Digits:",
      "Term Product:",
    ];

    for (int r = 0; r < 4; r++) {
      final double cy = startY + r * (rowH + rowGapY) + rowH / 2;
      _drawText(
        canvas,
        rowLabels[r],
        startX + labelColWidth / 2 - 4,
        cy,
        fontSize: 12.0,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );
    }

    double currX = startX + labelColWidth;
    for (int i = 0; i < data.stage1Cells.length; i++) {
      final BaseExpansionCell cell = data.stage1Cells[i];
      final double w = cell.isPoint ? pointW : cardW;
      final double cellCenterX = currX + w / 2;

      for (int r = 0; r < 4; r++) {
        final double topY = startY + r * (rowH + rowGapY);
        final Rect cardRect = Rect.fromLTWH(currX, topY, w, rowH);

        if (cell.isPoint) {
          _drawText(
            canvas,
            r == 3 ? "+" : "•",
            cellCenterX,
            topY + rowH / 2,
            fontSize: 18,
            isBold: true,
            color: Colors.deepPurple,
          );
          continue;
        }

        final bool isNonZero = cell.digitVal > 0;
        Color bgColor = Colors.white;
        Color borderColor = Colors.deepPurple.shade200;
        Color textColor = Colors.black87;

        if (r == 0) {
          bgColor = Colors.deepPurple.shade50;
          borderColor = Colors.deepPurple.shade300;
          textColor = Colors.deepPurple.shade900;
        } else if (r == 1) {
          bgColor = Colors.white;
          borderColor = Colors.grey.shade400;
          textColor = Colors.black87;
        } else if (r == 2) {
          bgColor = isNonZero ? Colors.green.shade50 : Colors.grey.shade100;
          borderColor =
          isNonZero ? Colors.green.shade600 : Colors.grey.shade400;
          textColor = isNonZero ? Colors.green.shade900 : Colors.grey.shade600;
        } else {
          bgColor =
          isNonZero ? Colors.deepPurple.shade50 : Colors.grey.shade50;
          borderColor =
          isNonZero ? Colors.deepPurple.shade300 : Colors.grey.shade300;
          textColor =
          isNonZero ? Colors.deepPurple.shade900 : Colors.grey.shade500;
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(8)),
          Paint()..color = bgColor,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(8)),
          Paint()
            ..color = borderColor
            ..strokeWidth = (r == 2 && isNonZero) ? 2.0 : 1.3
            ..style = PaintingStyle.stroke,
        );

        final String cellText = r == 0
            ? cell.powerHeaderText
            : (r == 1
            ? cell.placeValueText
            : (r == 2 ? cell.digitChar : cell.productTermText));

        _drawText(
          canvas,
          cellText,
          cellCenterX,
          topY + rowH / 2,
          fontSize: r == 2 ? 15.0 : (r == 3 ? 11.0 : 12.5),
          isBold: r != 1,
          color: textColor,
        );
      }

      currX += w + gapX;
    }

    return currX;
  }

  void _paintDivisionLadder(
      Canvas canvas,
      DivisionLadderTable ladder,
      double startX,
      double startY,
      ) {
    final List<BinaryDivisionRow> rows = ladder.rows;
    if (rows.isEmpty) return;

    _drawBadge(
      canvas,
      ladder.title,
      startX + 92,
      startY + 8,
      Colors.deepPurple,
    );

    const double rowH = 26.0;
    final double tableTop = startY + 26.0;
    final double vertLineX = startX + 34.0;
    final double tableRightX = startX + 162.0;

    final Paint linePaint = Paint()
      ..color = Colors.deepPurple.shade700
      ..strokeWidth = 1.7;

    canvas.drawLine(
      Offset(vertLineX, tableTop),
      Offset(vertLineX, tableTop + (rows.length + 1) * rowH),
      linePaint,
    );

    for (int i = 0; i < rows.length; i++) {
      final BinaryDivisionRow r = rows[i];
      final double y = tableTop + i * rowH;

      _drawText(
        canvas,
        "2",
        startX + 17,
        y + rowH / 2,
        fontSize: 12.0,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        i == 0
            ? "${r.dividend}"
            : "${r.dividend}   r ${rows[i - 1].remainder}",
        vertLineX + 56,
        y + rowH / 2,
        fontSize: 12.0,
        isBold: true,
        color: i == 0 ? Colors.black87 : Colors.green.shade900,
      );

      canvas.drawLine(
        Offset(startX + 4, y + rowH),
        Offset(tableRightX, y + rowH),
        linePaint,
      );
    }

    // Final quotient 0 row with last remainder
    final double lastY = tableTop + rows.length * rowH;
    _drawText(
      canvas,
      "0   r ${rows.last.remainder}",
      vertLineX + 56,
      lastY + rowH / 2,
      fontSize: 12.0,
      isBold: true,
      color: Colors.green.shade900,
    );

    // Red Upward Arrow on the right showing remainders read from bottom to top (↑)
    final double arrowX = tableRightX + 16.0;
    final Offset arrowBot = Offset(arrowX, lastY + rowH - 4);
    final Offset arrowTop = Offset(arrowX, tableTop + rowH / 2);
    canvas.drawLine(
      arrowBot,
      arrowTop,
      Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 2.2,
    );
    final Path head = Path()
      ..moveTo(arrowTop.dx, arrowTop.dy)
      ..lineTo(arrowTop.dx - 5, arrowTop.dy + 9)
      ..lineTo(arrowTop.dx + 5, arrowTop.dy + 9)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.red.shade700);
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
      height: tp.height + 7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
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
  bool shouldRepaint(covariant OtherBasesToBinaryPainter oldDelegate) =>
      oldDelegate.data != data;
}