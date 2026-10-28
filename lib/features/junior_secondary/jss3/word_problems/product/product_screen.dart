import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'product_logic.dart';
import 'product_models.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Direct Product of 2 or 3 Numbers (Ex 4a–d & Ex 2.2 #1–7, #10, #12)
  // 1: Find 2nd Number Given Product of 2 Numbers (Ex 5 & Ex 2.2 #8, #11, #13)
  // 2: Find 3rd Number Given Product of 3 Numbers (Ex 6 & Ex 2.2 #9, #15)
  // 3: Number Multiplied by Itself (x² = P) / Multiple k*x² = P (Ex 2.2 #14)

  int _subMode = 0;
  // For Mode 3: 0 = Number Multiplied by Itself (x * x = x² = P) [Ex 2.2 #14], 1 = One Number is k Times Another (k*x² = P)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  ProductResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(ProductPreset p) {
    setState(() {
      _mode = p.mode;
      _subMode = p.subMode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
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
              'Please enter a product word problem or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 2: Word Problems — Product (Pages 22–23, Examples 4–6 & Exercise 2.2 #1–15).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Direct Product of 2 or 3 numbers (Example 4a-d & Ex 2.2 #1-#7, #10, #12). Put first number in "input1", second number in "input2", and third number in "input3" (leave "input3" empty if only 2 numbers).
        1 for Finding the 2nd number given the product of 2 numbers (Example 5: product is 63, one is 7; Ex 2.2 #8: product is 9 11/12, one is -2 1/3; #11: product is 7.92, first is -9.9; #13: product is 1 2/5, one is 2/5). Put the known number in "input1" and the given product in "input2".
        2 for Finding the 3rd number given the product of 3 numbers (Example 6: product is 4020, two are 15 and 4; Ex 2.2 #9: product is -0.64, two are 0.4 and 8; #15: product is 134 2/5, two are -16 and 2 2/5). Put first known number in "input1", second known number in "input2", and given product of 3 numbers in "input3".
        3 for When a number is multiplied by itself (subMode 0: x^2 = P, e.g. Ex 2.2 #14: result is 3 6/25; put P in "input1") OR when one number is k times another and their product is P (subMode 1: put P in "input1" and k in "input2").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "subMode": 0,
        "input1": "-6 1/4",
        "input2": "-4/5",
        "input3": ""
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
        _result = ProductLogic.solveDirectProduct(
          factor1Str: _input1Ctrl.text,
          factor2Str: _input2Ctrl.text,
          factor3Str: _input3Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = ProductLogic.solveUnknownOfTwoNumbers(
          knownFactorStr: _input1Ctrl.text,
          givenProductStr: _input2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = ProductLogic.solveUnknownOfThreeNumbers(
          known1Str: _input1Ctrl.text,
          known2Str: _input2Ctrl.text,
          givenProductStr: _input3Ctrl.text,
        );
      } else {
        _result = ProductLogic.solveSelfProductOrMultiple(
          subMode: _subMode.clamp(0, 1),
          targetProductStr: _input1Ctrl.text,
          multipleKStr: _input2Ctrl.text,
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
    const presets = ProductLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Examples 4–6 & Exercise 2.2 #1–15):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.close_fullscreen,
                      size: 15,
                      color: Colors.deepPurple),
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
        'label': 'Direct Product of 2 or 3 Numbers (Ex 4a–d & Ex 2.2 #1–7)',
        'icon': Icons.close,
      },
      {
        'idx': 1,
        'label': 'Find 2nd Number Given Product (Ex 5 & Ex 2.2 #8, #11, #13)',
        'icon': Icons.find_replace,
      },
      {
        'idx': 2,
        'label': 'Find 3rd Number Given Product of 3 (Ex 6 & Ex 2.2 #9, #15)',
        'icon': Icons.account_tree_outlined,
      },
      {
        'idx': 3,
        'label': 'Number Multiplied by Itself x² = P (Ex 2.2 #14)',
        'icon': Icons.grid_on,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Product Word Problem Mode:"),
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
            _buildSectionTitle(
                "2. Direct Product of Two or Three Numbers (Example 4a–d & Ex 2.2 #1–7, #10, #12):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "First Number",
                    hint: "e.g. -24, -13, -6 1/4, or 3",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Second Number",
                    hint: "e.g. 5, -7, -4/5, or 2 1/2",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Third Number (Optional — Leave blank if multiplying 2 numbers)",
              hint: "e.g. -3 1/3, 5, 25, or 6",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Find the Second Number Given the Product of Two Numbers (Example 5 & Ex 2.2 #8, #11, #13):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Known First Number",
                    hint: "e.g. 7, -2 1/3, -9.9, or 2/5",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Given Product of the 2 Numbers",
                    hint: "e.g. 63, 9 11/12, 7.92, or 1 2/5",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Find the Third Number Given the Product of Three Numbers (Example 6 & Ex 2.2 #9, #15):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Known Number",
                    hint: "e.g. 15, 0.4, or -16",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Known Number",
                    hint: "e.g. 4, 8, or 2 2/5",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Given Product of all 3 Numbers",
              hint: "e.g. 4020, -0.64, or 134 2/5",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. A Number Multiplied by Itself (x × x = x² = P — Exercise 2.2 #14):"),
            const SizedBox(height: 8),
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
                      "Multiplied by Itself (x² = P)\n(Ex 2.2 #14: Result is 3 6/25)",
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
                      "One Number is k Times Another\n(k·x × x = k·x² = P)",
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
            if (_subMode == 0)
              _buildTextField(
                _input1Ctrl,
                "Resulting Product When Multiplied by Itself (P)",
                hint: "e.g. 3 6/25, 81/25, 144, or 6.25",
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _input1Ctrl,
                      "Given Product (P)",
                      hint: "e.g. 75 or 3 6/25",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _input2Ctrl,
                      "Multiple (k)",
                      hint: "e.g. 3",
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
                    "Snap a photo of any Product word problem from JSS 3 Chapter 2 (Examples 4–6 or Exercise 2.2 #1–15), and the AI will solve it step-by-step!",
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
              labelText: "Product Word Problem",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. The product of two numbers is 9 11/12. If one of the numbers is -2 1/3, find the other number. Or: When a number is multiplied by itself, the result is 3 6/25...",
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
                "Extract & Solve Product Problem",
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
              "Solve Product Problem Step-by-Step",
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

    final ProductCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 330.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cd.visualType == 0
                    ? "1. Interactive Factor-Tree & Directed-Number Sign Pipeline:"
                    : "1. Interactive Square Area Grid Visualizer (x × x = x²):",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
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
          height: canvasHeight,
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
                  painter: ProductPainter(data: cd),
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
          "3. Mathematical Workings (Line-by-Line):",
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
                      padding: const EdgeInsets.symmetric(vertical: 5.5),
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
          final List<String> mathLines = e.value.mathLinesLaTeX
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
                              const EdgeInsets.symmetric(vertical: 5.0),
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
          'Product Word Problems',
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

class ProductPainter extends CustomPainter {
  final ProductCanvasData data;

  ProductPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    // 1. Top Header & Sub-Header Badges
    _drawText(
      canvas,
      data.headerBadge,
      cx,
      18,
      fontSize: 13.5,
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

    if (data.visualType == 0) {
      _paintFactorTreePipeline(canvas, size);
    } else {
      _paintSquareAreaGrid(canvas, size);
    }

    // 3. Bottom Summary Banner
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

  void _paintFactorTreePipeline(Canvas canvas, Size size) {
    final List<FactorNodeVisual> nodes = data.factorNodes;
    if (nodes.isEmpty) return;

    final double cx = size.width / 2;
    const double topCardsY = 72.0;
    const double cardW = 148.0;
    const double cardH = 58.0;
    const double gapX = 34.0;

    final int n = nodes.length;
    final double totalRowW = n * cardW + (n - 1) * gapX;
    final double startX = cx - totalRowW / 2;

    final Offset signHubCenter = Offset(cx, 178.0);
    final Offset productCenter = Offset(cx, 250.0);

    // Draw connecting lines from each Factor Card down to the Sign-Rule Hub
    for (int i = 0; i < n; i++) {
      final FactorNodeVisual fn = nodes[i];
      final double cardLeft = startX + i * (cardW + gapX);
      final Rect cardRect = Rect.fromLTWH(cardLeft, topCardsY, cardW, cardH);

      canvas.drawLine(
        Offset(cardRect.center.dx, cardRect.bottom),
        Offset(signHubCenter.dx, signHubCenter.dy - 16),
        Paint()
          ..color = fn.isHighlightedUnknown
              ? Colors.green.shade700
              : Colors.deepPurple.shade300
          ..strokeWidth = 2.2,
      );

      // Draw multiplication symbol '×' between adjacent factor cards
      if (i < n - 1) {
        final double multX = cardRect.right + gapX / 2;
        _drawText(
          canvas,
          "×",
          multX,
          cardRect.center.dy,
          fontSize: 20,
          isBold: true,
          color: Colors.deepPurple,
        );
      }

      // Draw the Factor Card
      final Color bg = fn.isHighlightedUnknown
          ? Colors.green.shade50
          : (fn.isNegative
          ? Colors.orange.shade50
          : Colors.deepPurple.shade50);
      final Color border = fn.isHighlightedUnknown
          ? Colors.green.shade700
          : (fn.isNegative
          ? Colors.orange.shade800
          : Colors.deepPurple.shade400);

      canvas.drawRRect(
        RRect.fromRectAndRadius(cardRect, const Radius.circular(10)),
        Paint()..color = bg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cardRect, const Radius.circular(10)),
        Paint()
          ..color = border
          ..strokeWidth = fn.isHighlightedUnknown ? 2.4 : 1.7
          ..style = PaintingStyle.stroke,
      );

      _drawText(
        canvas,
        fn.titleLabel,
        cardRect.center.dx,
        cardRect.top + 14,
        fontSize: 11.0,
        isBold: true,
        color: border,
      );
      _drawText(
        canvas,
        fn.mainValueText,
        cardRect.center.dx,
        cardRect.top + 32,
        fontSize: 13.5,
        isBold: true,
        color: Colors.black87,
      );
      if (fn.subImproperText.isNotEmpty) {
        _drawText(
          canvas,
          fn.subImproperText,
          cardRect.center.dx,
          cardRect.top + 48,
          fontSize: 10.5,
          isBold: true,
          color: Colors.grey.shade700,
        );
      }
    }

    // Draw line from Sign Hub down to Product Node
    canvas.drawLine(
      Offset(cx, signHubCenter.dy + 16),
      Offset(cx, productCenter.dy - 24),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.5,
    );

    // Sign-Rule / Operation Bridge Badge
    if (data.signRuleBadge.isNotEmpty) {
      _drawBadge(
        canvas,
        data.signRuleBadge,
        signHubCenter.dx,
        signHubCenter.dy,
        Colors.deepPurple,
      );
    }

    // Draw Final / Given Product Node
    final Rect prodRect = Rect.fromCenter(
      center: productCenter,
      width: 220.0,
      height: 44.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(prodRect, const Radius.circular(10)),
      Paint()..color = Colors.green.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(prodRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      "${data.productNodeTitle}:  ${data.productNodeValue}",
      productCenter.dx,
      productCenter.dy,
      fontSize: 13.5,
      isBold: true,
      color: Colors.green.shade900,
    );
  }

  void _paintSquareAreaGrid(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    const double sqSize = 156.0;
    const double topY = 78.0;
    final Rect sqRect = Rect.fromLTWH(cx - sqSize / 2, topY, sqSize, sqSize);

    // Fill Square
    canvas.drawRRect(
      RRect.fromRectAndRadius(sqRect, const Radius.circular(8)),
      Paint()..color = Colors.deepPurple.shade50,
    );

    // Internal Sub-Grid Lines (e.g. 5x5 for denominator 5 in Ex 2.2 #14)
    final int rows = data.gridRows.clamp(2, 6);
    final int cols = data.gridCols.clamp(2, 6);
    final Paint gridPaint = Paint()
      ..color = Colors.deepPurple.shade200
      ..strokeWidth = 1.1;

    for (int r = 1; r < rows; r++) {
      final double y = sqRect.top + (r / rows) * sqSize;
      canvas.drawLine(Offset(sqRect.left, y), Offset(sqRect.right, y), gridPaint);
    }
    for (int c = 1; c < cols; c++) {
      final double x = sqRect.left + (c / cols) * sqSize;
      canvas.drawLine(Offset(x, sqRect.top), Offset(x, sqRect.bottom), gridPaint);
    }

    // Outer Border of Square
    canvas.drawRRect(
      RRect.fromRectAndRadius(sqRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Center Area Badge
    _drawBadge(
      canvas,
      data.squareAreaLabel,
      sqRect.center.dx,
      sqRect.center.dy,
      Colors.deepPurple,
    );

    // Top & Left Side Length Labels (Side x)
    _drawBadge(
      canvas,
      data.squareSideLabel,
      sqRect.center.dx,
      sqRect.top - 16,
      Colors.green.shade800,
    );
    _drawBadge(
      canvas,
      data.squareSideLabel,
      sqRect.left - 82,
      sqRect.center.dy,
      Colors.green.shade800,
    );
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
  bool shouldRepaint(covariant ProductPainter oldDelegate) =>
      oldDelegate.data != data;
}