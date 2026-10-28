import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'binary_to_base10_logic.dart';
import 'binary_to_base10_models.dart';

class BinaryToBase10Screen extends StatefulWidget {
  const BinaryToBase10Screen({super.key});

  @override
  State<BinaryToBase10Screen> createState() => _BinaryToBase10ScreenState();
}

class _BinaryToBase10ScreenState extends State<BinaryToBase10Screen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Binary to Base 10 Converter (Whole & Fractional Bicimals — Ex 2a, 2b & Ex 1.2 #1a–l)
  // 1: Expand Any Number in Powers of Its Base (Page 8 Diagram, Ex 1a–c & Ex 1.1 #1–20)
  // 2: Square Root of a Binary Number √(N₂) (Ex 3a, 3b & Ex 1.2 #4a–f)
  // 3: Powers (N₂)ᵏ & Multi-Term Additions in Base 10 (Ex 1.2 #2 & #3a–f)

  int _subMode = 0; // For Mode 3: 0 = Power (N₂)ᵏ, 1 = Add 2 or 3 Binary Numbers

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  int _selectedBase = 2; // For Mode 1: 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 16
  int _selectedExponent = 2; // For Mode 3 SubMode 0: 2, 3, 4

  BinaryToBase10Result? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  static const List<int> _supportedBases = [2, 3, 4, 5, 6, 7, 8, 9, 10, 16];

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BinaryToBase10Preset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _selectedBase = p.baseInt;
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
              'Please enter a binary question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 1: Conversion of Binary to Base 10.
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Converting a binary number (whole or bicimal like 1011 or 1101.110) to base 10 (Example 2 & Exercise 1.2 #1).
        1 for Expanding a number in the powers of its base (e.g. 110 001_two, 432_five, 321 011_four, 124_sixteen — Example 1 & Exercise 1.1 #1-20).
        2 for Finding the square root of a binary number √(N_two) (Example 3 & Exercise 1.2 #4a-f).
        3 for Powers of a binary number (subMode 0, e.g. (1.1_two)^3 in Ex 1.2 #3a-e) or Adding 2 or 3 binary numbers in base 10 (subMode 1, e.g. Ex 1.2 #2 & #3f).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "input1": "1101.110",
        "input2": "",
        "input3": "",
        "baseInt": 2,
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
        if (jsonMap['input1'] != null) {
          _input1Ctrl.text = jsonMap['input1'].toString();
        }
        if (jsonMap['input2'] != null) {
          _input2Ctrl.text = jsonMap['input2'].toString();
        }
        if (jsonMap['input3'] != null) {
          _input3Ctrl.text = jsonMap['input3'].toString();
        }
        final int b = (jsonMap['baseInt'] as num?)?.toInt() ?? 2;
        if (_supportedBases.contains(b)) _selectedBase = b;
        _selectedExponent =
            ((jsonMap['exponentK'] as num?)?.toInt() ?? 2).clamp(1, 6);
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
        _result = BinaryToBase10Logic.solveBinaryToBase10(
          binaryInputStr: _input1Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = BinaryToBase10Logic.solveExpandInPowersOfBase(
          numberInputStr: _input1Ctrl.text,
          baseInt: _selectedBase,
        );
      } else if (_mode == 2) {
        _result = BinaryToBase10Logic.solveBinarySquareRoot(
          binaryRadicandStr: _input1Ctrl.text,
        );
      } else {
        _result = BinaryToBase10Logic.solvePowersAndAdditionsInBase10(
          subMode: _subMode,
          bin1Str: _input1Ctrl.text,
          bin2Str: _input2Ctrl.text,
          bin3Str: _input3Ctrl.text,
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

  Widget _buildPresetsBar() {
    const presets = BinaryToBase10Logic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 1.1 & Ex 1.2):"),
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
        'label': 'Binary → Base 10 (Ex 2 & 1.2 #1)',
        'icon': Icons.swap_horiz,
      },
      {
        'idx': 1,
        'label': 'Expand in Powers of Base (Ex 1.1)',
        'icon': Icons.functions,
      },
      {
        'idx': 2,
        'label': 'Square Root √(N₂) (Ex 3 & 1.2 #4)',
        'icon': Icons.square_foot,
      },
      {
        'idx': 3,
        'label': 'Powers & Additions in Base 10 (Ex 1.2 #2–3)',
        'icon': Icons.add_box_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Binary / Number Base Problem Mode:"),
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
                "2. Convert Binary Number (Whole or Bicimal) to Base 10 (Ex 2 & Ex 1.2 #1):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Enter Binary Number (Base 2)",
              hint: "e.g. 1 011, 110 110, 1 101.110, 0.10101, or 0.00011",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Expand Any Number in the Powers of Its Base (Ex 1 & Ex 1.1 #1–20):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Enter Given Number",
              hint: "e.g. 110 001, 432, 3 256, 321 011, 746, or 124",
            ),
            const SizedBox(height: 12),
            const Text(
              "Select Base Subscript (Base Number b):",
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
              children: _supportedBases.map((b) {
                final bool isSel = _selectedBase == b;
                final String bWord = BinaryToBase10Logic.getBaseWord(b);
                final String bSub = BinaryToBase10Logic.toUnicodeSubscript(b);
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
                    color:
                    isSel ? Colors.deepPurple : Colors.deepPurple.shade200,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedBase = b),
                );
              }).toList(),
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Square Root of a Binary Number √(N₂) (Ex 3 & Ex 1.2 #4a–f):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Binary Number Inside Square Root (√)",
              hint: "e.g. 100 100, 1 010 001, 10 000, 11 001, or 0.0001",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Powers & Additions of Binary Numbers in Base 10 (Ex 1.2 #2 & #3):"),
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
                      "Power / Cube (N₂)ᵏ\n(Ex 1.2 #3a–e)",
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
                      "Add 2 or 3 Binary Numbers\n(Ex 1.2 #2 & #3f)",
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
                      _input1Ctrl,
                      "Binary Number Inside Brackets",
                      hint: "e.g. 10, 10 001, 1.1, or 0.110",
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
            ] else ...[
              _buildTextField(
                _input1Ctrl,
                "1st Binary Number",
                hint: "e.g. 110 011 or 0.101",
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input2Ctrl,
                "2nd Binary Number",
                hint: "e.g. 101.11 or 0.100",
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _input3Ctrl,
                "3rd Binary Number (Optional — Leave blank if adding 2 numbers)",
                hint: "e.g. 1 111",
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
                    "Snap a photo of any binary conversion, power expansion, or binary square root question from JSS 3 Chapter 1 (Exercises 1.1 & 1.2)!",
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
              labelText: "Binary / Number Base Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Convert 1 101.110_two to base 10, or find the square root of 1 010 001_two...",
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
                "Extract & Solve Binary Question",
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
              "Convert & Solve Step-by-Step",
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

    final int cellCount = _result!.canvasData.primaryCells.length;
    final bool hasDivisionLadder =
        _result!.canvasData.divisionRows.isNotEmpty;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double neededGridWidth = 140.0 +
        cellCount * 88.0 +
        (hasDivisionLadder ? 260.0 : 40.0);
    final double canvasWidth = math.max(screenWidth, neededGridWidth);
    const double canvasHeight = 360.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Place-Value Power Decomposition Grid:",
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
              boundaryMargin: const EdgeInsets.all(140),
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: BinaryToBase10Painter(
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
          'Conversion of Binary to Base 10',
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

class BinaryToBase10Painter extends CustomPainter {
  final BinaryToBase10CanvasData data;

  BinaryToBase10Painter({required this.data});

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

    // 2. Draw 4-Row Place-Value Power Decomposition Grid
    _paintPlaceValueGridCanvas(canvas, size);

    // 3. Bottom Summary Banner
    if (data.bottomSummaryBanner.isNotEmpty) {
      _drawBadge(
        canvas,
        data.bottomSummaryBanner,
        cx,
        size.height - 22.0,
        Colors.green.shade800,
      );
    }
  }

  void _paintPlaceValueGridCanvas(Canvas canvas, Size size) {
    final List<DigitPowerCell> cells = data.primaryCells;
    if (cells.isEmpty) return;

    const double labelColWidth = 118.0;
    const double cardW = 76.0;
    const double pointW = 28.0;
    const double gapX = 6.0;
    const double rowStartY = 64.0;
    const double rowH = 50.0;
    const double rowGapY = 8.0;

    final bool hasLadder = data.divisionRows.isNotEmpty;
    final double ladderReserveW = hasLadder ? 235.0 : 0.0;

    final double totalCardsW = cells.fold(
      0.0,
          (sum, c) => sum + (c.isPoint ? pointW : cardW) + gapX,
    );
    final double totalContentW = labelColWidth + totalCardsW + ladderReserveW;
    double leftOriginX = (size.width - totalContentW) / 2;
    if (leftOriginX < 14.0) leftOriginX = 14.0;

    final double cardsStartX = leftOriginX + labelColWidth;

    // Draw 4 Row Labels on the left with full room so they are never clipped
    final List<String> rowLabels = [
      "Powers of ${data.baseInt}:",
      "Place Value:",
      "Given Digits:",
      "Term Product:",
    ];

    for (int r = 0; r < 4; r++) {
      final double cy = rowStartY + r * (rowH + rowGapY) + rowH / 2;
      _drawText(
        canvas,
        rowLabels[r],
        leftOriginX + labelColWidth / 2 - 4,
        cy,
        fontSize: 12.0,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );
    }

    double currX = cardsStartX;
    for (int i = 0; i < cells.length; i++) {
      final DigitPowerCell cell = cells[i];
      final double w = cell.isPoint ? pointW : cardW;
      final double cellCenterX = currX + w / 2;

      for (int r = 0; r < 4; r++) {
        final double topY = rowStartY + r * (rowH + rowGapY);
        final Rect cardRect =
        Rect.fromLTWH(currX, topY, w, rowH);

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
          textColor =
          isNonZero ? Colors.green.shade900 : Colors.grey.shade600;
        } else {
          bgColor = isNonZero
              ? Colors.deepPurple.shade50
              : Colors.grey.shade50;
          borderColor = isNonZero
              ? Colors.deepPurple.shade300
              : Colors.grey.shade300;
          textColor = isNonZero
              ? Colors.deepPurple.shade900
              : Colors.grey.shade500;
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
          fontSize: r == 2 ? 15.5 : (r == 3 ? 11.0 : 13.0),
          isBold: r != 1,
          color: textColor,
        );
      }

      currX += w + gapX;
    }

    // Optional Repeated Division by 2 Ladder on the Right (Mode 2 Square Root)
    if (hasLadder) {
      _paintDivisionBy2Ladder(canvas, currX + 28.0, rowStartY);
    }
  }

  void _paintDivisionBy2Ladder(
      Canvas canvas, double startX, double startY) {
    final List<DivisionRemainderRow> rows = data.divisionRows;
    if (rows.isEmpty) return;

    _drawText(
      canvas,
      "Convert Root to Base 2 (÷ 2):",
      startX + 88,
      startY + 8,
      fontSize: 12.0,
      isBold: true,
      color: Colors.deepPurple,
    );

    const double rowH = 30.0;
    final double tableTop = startY + 26.0;
    final double vertLineX = startX + 32.0;
    final double tableRightX = startX + 160.0;

    final Paint linePaint = Paint()
      ..color = Colors.deepPurple.shade700
      ..strokeWidth = 1.8;

    canvas.drawLine(
      Offset(vertLineX, tableTop),
      Offset(vertLineX, tableTop + (rows.length + 1) * rowH),
      linePaint,
    );

    for (int i = 0; i < rows.length; i++) {
      final DivisionRemainderRow r = rows[i];
      final double y = tableTop + i * rowH;

      _drawText(
        canvas,
        "2",
        startX + 16,
        y + rowH / 2,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple,
      );
      _drawText(
        canvas,
        i == 0
            ? "${r.dividend}"
            : "${r.dividend}   r ${rows[i - 1].remainder}",
        vertLineX + 54,
        y + rowH / 2,
        fontSize: 12.5,
        isBold: true,
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
      vertLineX + 54,
      lastY + rowH / 2,
      fontSize: 12.5,
      isBold: true,
      color: Colors.green.shade900,
    );

    // Upward Arrow on the right showing remainders read from bottom to top (↑)
    final double arrowX = tableRightX + 18.0;
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
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + 16,
      height: tp.height + 8,
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
  bool shouldRepaint(covariant BinaryToBase10Painter oldDelegate) =>
      oldDelegate.data != data;
}