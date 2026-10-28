import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'binary_computer_logic.dart';
import 'binary_computer_models.dart';

class BinaryComputerScreen extends StatefulWidget {
  const BinaryComputerScreen({super.key});

  @override
  State<BinaryComputerScreen> createState() => _BinaryComputerScreenState();
}

class _BinaryComputerScreenState extends State<BinaryComputerScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Word & Sentence to Coded Binary Form (Examples 5 & 6 — Tables 1.2 to 1.6)
  // 1: Computer Punch Tape Generator (Example 7a & 7b)
  // 2: Decode Binary Code / Punch Tape Back to English (Exercise 1.4 Reverse)
  // 3: Interactive Table 1.1 Explorer (A–Z Lookup & 5-Bit Place-Value Grid)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _inputCtrl = TextEditingController();
  bool _includeFullTable1_1 = false;
  int _punchTapeStyle = 0; // 0: Punched Holes Only for 1s (Textbook Style), 1: Full 5-Bit Track (● = 1, ○ = 0)

  BinaryComputerResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _inputCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(BinaryComputerPreset p) {
    setState(() {
      _mode = p.mode;
      _punchTapeStyle = p.punchTapeStyle;
      _inputCtrl.text = p.inputStr;
      _includeFullTable1_1 = p.showFullTable1_1;
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
              'Please enter a binary computer coding question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 1: Application of Binary Numbers to Computers (Table 1.1, Coded Words/Sentences & Punch Tapes).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Translating an English word or sentence into coded binary form (e.g. LAGOS, KADUNA, BENIN, ENUGU, I LIKE MATHEMATICS — Examples 5 & 6).
        1 for Writing a word or sentence on a computer punch tape / punch card (e.g. LAGOS or I AM A NIGERIAN — Example 7).
        2 for Decoding a sequence of binary numbers (or a punch tape diagram) back into an English word or sentence (e.g. "1 100, 1, 111, 1 111, 10 011").
        3 for Viewing or exploring Table 1.1 (A-Z alphabet binary coding table, e.g. "A-Z", "H-O", "P-Z").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "punchTapeStyle": 0,
        "inputStr": "LAGOS"
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
        _punchTapeStyle =
            ((jsonMap['punchTapeStyle'] as num?)?.toInt() ?? 0).clamp(0, 1);
        if (jsonMap['inputStr'] != null) {
          _inputCtrl.text = jsonMap['inputStr'].toString();
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
        _result = BinaryComputerLogic.solveWordOrSentenceToBinary(
          rawTextInput: _inputCtrl.text,
          includeFullTable1_1: _includeFullTable1_1,
        );
      } else if (_mode == 1) {
        _result = BinaryComputerLogic.solvePunchTapeGenerator(
          rawTextInput: _inputCtrl.text,
          punchTapeStyle: _punchTapeStyle,
        );
      } else if (_mode == 2) {
        _result = BinaryComputerLogic.solveDecodeBinaryToEnglish(
          rawBinaryCodesInput: _inputCtrl.text,
        );
      } else {
        _result = BinaryComputerLogic.solveTable1_1Explorer(
          filterInputStr: _inputCtrl.text,
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
    const presets = BinaryComputerLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Table 1.1 & Examples 5–7):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.memory,
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
        'label': 'Words & Sentences → Binary (Ex 5 & 6)',
        'icon': Icons.translate,
      },
      {
        'idx': 1,
        'label': 'Computer Punch Tape (Ex 7)',
        'icon': Icons.confirmation_number_outlined,
      },
      {
        'idx': 2,
        'label': 'Decode Binary → English',
        'icon': Icons.lock_open,
      },
      {
        'idx': 3,
        'label': 'Table 1.1 Explorer (A–Z)',
        'icon': Icons.table_chart_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Computer Binary Application Mode:"),
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
                "2. Translate Word or Sentence to Coded Binary Form (Examples 5 & 6):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Word or Sentence (Letters A–Z)",
              hint: "e.g. LAGOS, KADUNA, BENIN, ENUGU, or I LIKE MATHEMATICS",
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Also Show Complete Table 1.1 (A–Z Reference) in Workings",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: _includeFullTable1_1,
                  activeColor: Colors.deepPurple,
                  onChanged: (v) => setState(() => _includeFullTable1_1 = v),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Write Word or Sentence on a Computer Punch Tape (Example 7a & 7b):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Message for Punch Tape",
              hint: "e.g. LAGOS or I AM A NIGERIAN",
            ),
            const SizedBox(height: 12),
            const Text(
              "Select Punch Tape Display Style:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _punchTapeStyle,
                thumbColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Punched Holes Only for 1s\n(Textbook Example 7 Style)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _punchTapeStyle == 0
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Full 5-Bit Track Grid\n(● = 1 Punched, ○ = 0 Unpunched)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: _punchTapeStyle == 1
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
                },
                onValueChanged: (int? v) {
                  if (v != null) setState(() => _punchTapeStyle = v);
                },
              ),
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Decode Binary Codes / Punch Tape Back to English:"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Binary Codes (Comma-Separated; Use '/' Between Words)",
              hint: "e.g. 1 100, 1, 111, 1 111, 10 011  (or 1001 / 1, 1101)",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Interactive Table 1.1 Explorer (A = 1₁₀ to Z = 26₁₀):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Letter Range or Word (or Leave Blank for Full A–Z)",
              hint: "e.g. A-Z, A-G, H-O, P-Z, or NIGERIA",
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                {'lbl': 'Full A–Z (1–26)', 'val': 'A-Z'},
                {'lbl': '1–3 Bit Letters (A–G)', 'val': 'A-G'},
                {'lbl': '4-Bit Letters (H–O)', 'val': 'H-O'},
                {'lbl': '5-Bit Letters (P–Z)', 'val': 'P-Z'},
              ].map((q) {
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    q['lbl']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () {
                    setState(() => _inputCtrl.text = q['val']!);
                    _solveManual();
                  },
                );
              }).toList(),
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
                    "Snap a photo of any binary coding or computer punch-tape question from JSS 3 Chapter 1 (Examples 5–7 or Exercise 1.4)!",
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
              labelText: "Binary Coding / Punch Tape Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Translate KADUNA into coded form, or write I AM A NIGERIAN on a punch tape...",
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
                "Extract & Solve Binary Coding",
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
            icon: const Icon(Icons.memory, color: Colors.white),
            label: const Text(
              "Encode / Decode & Draw Punch Tape",
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

    final BinaryComputerCanvasData cd = _result!.canvasData;
    final int rowCount = cd.rows.length;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 690.0);
    final double canvasHeight = math.max(360.0, 145.0 + rowCount * 30.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Coded Table & 5-Track Computer Punch Tape:",
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
              minScale: 0.35,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: BinaryComputerPainter(data: cd),
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
          "3. Mathematical & Binary Coding Workings:",
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
          'Application of Binary to Computers',
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

class BinaryComputerPainter extends CustomPainter {
  final BinaryComputerCanvasData data;

  BinaryComputerPainter({required this.data});

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

    if (data.rows.isEmpty) return;

    const double topY = 64.0;
    const double rowH = 28.0;
    const double tableW = 240.0;
    const double gapBetweenPanels = 44.0;
    const double tapeW = 330.0;
    const double totalW = tableW + gapBetweenPanels + tapeW;

    double startX = (size.width - totalW) / 2;
    if (startX < 16.0) startX = 16.0;

    // 2. Left Panel: Textbook Coded Binary Table (Tables 1.2–1.6 Style)
    _paintTextbookCodedTable(canvas, startX, topY, tableW, rowH);

    // 3. Right Panel: Authentic 5-Track Computer Punch Tape (Example 7 Style)
    _paintComputerPunchTape(
      canvas,
      startX + tableW + gapBetweenPanels,
      topY,
      tapeW,
      rowH,
    );

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

  void _paintTextbookCodedTable(
      Canvas canvas,
      double leftX,
      double topY,
      double width,
      double rowH,
      ) {
    final int nRows = data.rows.length;
    final double totalH = (nRows + 1) * rowH + 10.0;

    _drawBadge(
      canvas,
      "Textbook Coded Table (Tables 1.2–1.6)",
      leftX + width / 2,
      topY,
      Colors.deepPurple,
    );

    final double tableTop = topY + 18.0;
    final Rect outerRect = Rect.fromLTWH(leftX, tableTop, width, totalH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(10)),
      Paint()..color = Colors.deepPurple.shade50.withOpacity(0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.deepPurple.shade200
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    final double colLetterX = leftX + 34.0;
    final double colBase10X = leftX + 86.0;
    final double solidBarX = leftX + 118.0;
    final double colUpperBitsX = leftX + 150.0;
    final double dashedBarX = leftX + 174.0;
    final double colLower3BitsX = leftX + 206.0;

    // Column Headers
    final double headerCy = tableTop + rowH / 2 + 2;
    _drawText(canvas, "Letter", colLetterX, headerCy,
        fontSize: 11.5, isBold: true, color: Colors.deepPurple.shade900);
    _drawText(canvas, "Base 10", colBase10X, headerCy,
        fontSize: 11.5, isBold: true, color: Colors.deepPurple.shade900);
    _drawText(canvas, "16, 8", colUpperBitsX, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.deepPurple.shade700);
    _drawText(canvas, "4, 2, 1", colLower3BitsX, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.deepPurple.shade700);

    canvas.drawLine(
      Offset(leftX + 8, tableTop + rowH + 2),
      Offset(leftX + width - 8, tableTop + rowH + 2),
      Paint()
        ..color = Colors.deepPurple.shade300
        ..strokeWidth = 1.4,
    );

    // Solid Vertical Bar (matching Tables 1.2–1.5)
    canvas.drawLine(
      Offset(solidBarX, tableTop + 6),
      Offset(solidBarX, tableTop + totalH - 6),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.8,
    );

    // Vertical Dashed 3-Bit Grouping Line (matching Tables 1.2–1.6)
    _drawDashedLine(
      canvas,
      Offset(dashedBarX, tableTop + 6),
      Offset(dashedBarX, tableTop + totalH - 6),
      Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 1.5,
    );

    for (int i = 0; i < nRows; i++) {
      final CodedLetterRow r = data.rows[i];
      final double cy = tableTop + (i + 1) * rowH + rowH / 2 + 2;

      if (r.isWordSeparator) {
        // Horizontal dashed word separator line (matching Table 1.6 for "I LIKE MATHEMATICS")
        _drawDashedLine(
          canvas,
          Offset(leftX + 12, cy),
          Offset(leftX + width - 12, cy),
          Paint()
            ..color = Colors.deepPurple.shade700
            ..strokeWidth = 1.8,
        );
        continue;
      }

      _drawText(
        canvas,
        r.letter,
        colLetterX,
        cy,
        fontSize: 13.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );
      _drawText(
        canvas,
        "${r.base10Position}",
        colBase10X,
        cy,
        fontSize: 12.5,
        isBold: false,
        color: Colors.black87,
      );
      if (r.upperBits.isNotEmpty) {
        _drawText(
          canvas,
          r.upperBits,
          colUpperBitsX,
          cy,
          fontSize: 13.5,
          isBold: true,
          color: Colors.green.shade900,
        );
      }
      _drawText(
        canvas,
        r.lower3Bits,
        colLower3BitsX,
        cy,
        fontSize: 13.5,
        isBold: true,
        color: Colors.green.shade900,
      );
    }
  }

  void _paintComputerPunchTape(
      Canvas canvas,
      double leftX,
      double topY,
      double width,
      double rowH,
      ) {
    final int nRows = data.rows.length;
    final double totalH = (nRows + 1) * rowH + 10.0;

    _drawBadge(
      canvas,
      "5-Track Computer Punch Tape (Example 7)",
      leftX + width / 2,
      topY,
      Colors.green.shade800,
    );

    final double tapeTop = topY + 18.0;
    const double stripWidth = 232.0;
    final double stripLeft = leftX + 42.0;

    // Warm Manila / Amber Paper Punch Tape Background
    final Rect tapeRect =
    Rect.fromLTWH(stripLeft, tapeTop, stripWidth, totalH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tapeRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tapeRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.amber.shade800
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 5 Binary Track X-Coordinates + Sprocket Feed Track between 8 and 4
    final List<double> trackX = [
      stripLeft + 28.0, // Track 16 (2⁴)
      stripLeft + 68.0, // Track 8  (2³)
      stripLeft + 124.0, // Track 4  (2²)
      stripLeft + 164.0, // Track 2  (2¹)
      stripLeft + 204.0, // Track 1  (2⁰)
    ];
    final double sprocketX = stripLeft + 96.0;
    const List<String> trackHeaders = ["16", "8", "4", "2", "1"];

    // Header Row on the Tape
    final double headerCy = tapeTop + rowH / 2 + 2;
    _drawText(canvas, "Row", leftX + 18, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.deepPurple);
    for (int c = 0; c < 5; c++) {
      _drawText(
        canvas,
        trackHeaders[c],
        trackX[c],
        headerCy,
        fontSize: 11.5,
        isBold: true,
        color: Colors.brown.shade900,
      );
    }
    _drawText(
      canvas,
      "Base 10",
      stripLeft + stripWidth + 32,
      headerCy,
      fontSize: 11.0,
      isBold: true,
      color: Colors.deepPurple,
    );

    canvas.drawLine(
      Offset(stripLeft, tapeTop + rowH + 2),
      Offset(stripLeft + stripWidth, tapeTop + rowH + 2),
      Paint()
        ..color = Colors.amber.shade800
        ..strokeWidth = 1.4,
    );

    // Vertical Dashed Sprocket Feed Line
    _drawDashedLine(
      canvas,
      Offset(sprocketX, tapeTop + 6),
      Offset(sprocketX, tapeTop + totalH - 6),
      Paint()
        ..color = Colors.brown.shade400
        ..strokeWidth = 1.3,
    );

    for (int i = 0; i < nRows; i++) {
      final CodedLetterRow r = data.rows[i];
      final double cy = tapeTop + (i + 1) * rowH + rowH / 2 + 2;

      // Subtle horizontal row guide across the paper tape
      canvas.drawLine(
        Offset(stripLeft + 4, cy + rowH / 2),
        Offset(stripLeft + stripWidth - 4, cy + rowH / 2),
        Paint()
          ..color = Colors.amber.shade200
          ..strokeWidth = 0.8,
      );

      // Small sprocket feed hole along the dashed line
      canvas.drawCircle(
        Offset(sprocketX, cy),
        2.5,
        Paint()..color = Colors.brown.shade400,
      );

      if (r.isWordSeparator) {
        _drawDashedLine(
          canvas,
          Offset(stripLeft + 8, cy),
          Offset(stripLeft + stripWidth - 8, cy),
          Paint()
            ..color = Colors.brown.shade700
            ..strokeWidth = 1.6,
        );
        _drawText(
          canvas,
          "(Space)",
          stripLeft + stripWidth + 32,
          cy,
          fontSize: 10.5,
          isBold: true,
          color: Colors.grey.shade700,
        );
        continue;
      }

      // Letter label on the left of the tape
      _drawText(
        canvas,
        r.letter,
        leftX + 18,
        cy,
        fontSize: 13.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );

      final int bitLen = r.rawBinary.length;
      for (int c = 0; c < 5; c++) {
        final int bitVal = r.fiveTrackBits[c];
        final int bitPower = 4 - c;
        final Offset holeCenter = Offset(trackX[c], cy);

        if (bitVal == 1) {
          // Punched Hole (●) for Binary '1'
          canvas.drawCircle(
            holeCenter,
            7.5,
            Paint()..color = Colors.deepPurple.shade900,
          );
          _drawText(
            canvas,
            "1",
            holeCenter.dx,
            holeCenter.dy,
            fontSize: 9.5,
            isBold: true,
            color: Colors.white,
          );
        } else {
          if (data.punchTapeStyle == 1) {
            // Full 5-Bit Track mode: draw open unpunched circle (○ = 0)
            canvas.drawCircle(
              holeCenter,
              6.5,
              Paint()..color = Colors.white,
            );
            canvas.drawCircle(
              holeCenter,
              6.5,
              Paint()
                ..color = Colors.amber.shade700
                ..strokeWidth = 1.3
                ..style = PaintingStyle.stroke,
            );
            _drawText(
              canvas,
              "0",
              holeCenter.dx,
              holeCenter.dy,
              fontSize: 9.0,
              color: Colors.brown.shade400,
            );
          } else if (bitPower < bitLen) {
            // Textbook style: subtle dot at internal unpunched 0 positions
            canvas.drawCircle(
              holeCenter,
              2.2,
              Paint()..color = Colors.amber.shade700,
            );
          }
        }
      }

      // Base 10 value on the right of the tape
      _drawText(
        canvas,
        "= ${r.base10Position}₁₀",
        stripLeft + stripWidth + 32,
        cy,
        fontSize: 12.0,
        isBold: true,
        color: Colors.green.shade900,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double dist = (p2 - p1).distance;
    if (dist < 2) return;
    const double dashW = 5.0;
    const double gapW = 4.0;
    final int count = (dist / (dashW + gapW)).floor().clamp(1, 200);
    final double dx = (p2.dx - p1.dx) / count;
    final double dy = (p2.dy - p1.dy) / count;

    for (int i = 0; i < count; i++) {
      canvas.drawLine(
        Offset(p1.dx + i * dx, p1.dy + i * dy),
        Offset(p1.dx + (i + 0.55) * dx, p1.dy + (i + 0.55) * dy),
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
  bool shouldRepaint(covariant BinaryComputerPainter oldDelegate) =>
      oldDelegate.data != data;
}