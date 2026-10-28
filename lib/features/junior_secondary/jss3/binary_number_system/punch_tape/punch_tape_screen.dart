import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'punch_tape_logic.dart';
import 'punch_tape_models.dart';

class PunchTapeScreen extends StatefulWidget {
  const PunchTapeScreen({super.key});

  @override
  State<PunchTapeScreen> createState() => _PunchTapeScreenState();
}

class _PunchTapeScreenState extends State<PunchTapeScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Punch Card / Tape Generator — Coded Form + Punch Tape (Example 7a–b & Exercise 1.4 #2a–f)
  // 1: Write Words & Full Names in Coded Binary Form (Exercise 1.4 #1a–h & #5a–e)
  // 2: Decode Coded Binary Form / Punch Tape Back to English (Table 1.8 — Exercise 1.4 #3a–b)
  // 3: Translate Base-10 Number-Coded Messages into Words (Exercise 1.4 #4a & #4b)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _inputCtrl = TextEditingController();
  int _punchTapeStyle = 0;
  // 0: Textbook Table 1.7(b)/(d) Style (● for 1s, Blank for 0s)
  // 1: Labeled 5-Track Grid (16, 8 : 4, 2, 1 with ○ = 0 Unpunched Guides)

  PunchTapeResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _inputCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(PunchTapePreset p) {
    setState(() {
      _mode = p.mode;
      _punchTapeStyle = p.punchTapeStyle;
      _inputCtrl.text = p.inputStr;
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
              'Please enter a punch tape or coded message question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 1: The Punch Tape (Example 7 [Tables 1.7a-d] & Exercise 1.4 #1-5 [including Table 1.8]).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Putting a word or sentence on a punch card / punch tape (Example 7a-b: LAGOS, I AM A NIGERIAN; Exercise 1.4 #2a-f: I AM A SUPERSTAR, I HATE CORRUPTION, MY MOTHER IS BEAUTIFUL, NIGERIA IS A GREAT NATION, I LIKE MY MATHEMATICS TEACHER, MATHEMATICS IS AN INTERESTING SUBJECT).
        1 for Writing a word or full name in coded binary form (Exercise 1.4 #1a-h: Sokoto, Keffi, Osogbo, Yenegoa, Abakaliki, Damaturu, Vandekya, Aeroplane; #5a-e: full names).
        2 for Decoding a statement shown in coded binary form or on a punch tape back into English (Exercise 1.4 #3a-b / Table 1.8a & 1.8b; separate letters in a word by commas ',' and separate words by semicolons ';').
        3 for Translating a Base-10 number-coded message into words (Exercise 1.4 #4a & #4b, e.g. "9, 12, 9, 11, 5; 13, 1, 20, 8, 5, 13; 1; 20; 9, 3, 19" or "9; 1, 13; 1; 7, 15, 15, 4; 14, 9, 7, 18, 9, 1, 14").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "punchTapeStyle": 0,
        "inputStr": "I AM A NIGERIAN"
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
      if (_mode == 0 || _mode == 1) {
        _result = PunchTapeLogic.solveEncodeAndPunchTape(
          mode: _mode,
          rawTextInput: _inputCtrl.text,
          punchTapeStyle: _punchTapeStyle,
        );
      } else if (_mode == 2) {
        _result = PunchTapeLogic.solveDecodeBinaryTable1_8(
          rawBinaryCodesInput: _inputCtrl.text,
        );
      } else {
        _result = PunchTapeLogic.solveTranslateBase10NumbersToWords(
          rawNumbersInput: _inputCtrl.text,
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
    const presets = PunchTapeLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Ex 7 [Tables 1.7a–d] & Ex 1.4 #1–5):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.confirmation_number_outlined,
                      size: 16,
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
        'label': 'Punch Card / Tape (Ex 7 & Ex 1.4 #2)',
        'icon': Icons.confirmation_number_outlined,
      },
      {
        'idx': 1,
        'label': 'Words & Names → Coded Form (Ex 1.4 #1 & #5)',
        'icon': Icons.list_alt,
      },
      {
        'idx': 2,
        'label': 'Decode Binary Table 1.8 (Ex 1.4 #3)',
        'icon': Icons.lock_open_outlined,
      },
      {
        'idx': 3,
        'label': 'Translate Base-10 Numbers (Ex 1.4 #4)',
        'icon': Icons.translate,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Punch Tape / Coded Message Mode:"),
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
                "2. Put Word or Sentence on a Punch Card / Tape (Example 7 & Exercise 1.4 #2a–f):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Word or Sentence (Up to 48 Letters)",
              hint:
              "e.g. LAGOS, I AM A NIGERIAN, I AM A SUPERSTAR, or I HATE CORRUPTION",
            ),
            const SizedBox(height: 12),
            const Text(
              "Select Punch Card / Tape Display Style:",
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
                      "Textbook Table 1.7(b)/(d) Style\n(● for 1s, Blank for 0s)",
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
                      "Labeled 5-Track Guide Grid\n(● = 1 Punched, ○ = 0 Unpunched)",
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
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Write Words & Full Names in Coded Form (Exercise 1.4 #1a–h & #5a–e):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Word or Full Name",
              hint:
              "e.g. Sokoto, Keffi, Osogbo, Yenegoa, Abakaliki, Damaturu, Vandekya, or Aeroplane",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Write Down Statements Shown in Coded Binary Form (Table 1.8 — Ex 1.4 #3a–b):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Binary Codes (Commas ',' Within Words, Semicolons ';' Between Words)",
              hint:
              "e.g. 10:011, 10:101, 11, 11, 101, 10:011, 10:011 ; 1:001, 10:011 ; 1:101, 1:001, 1:110, 101",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Translate Base-10 Number-Coded Messages into Words (Exercise 1.4 #4a & #4b):"),
            const SizedBox(height: 10),
            _buildTextField(
              _inputCtrl,
              "Enter Base 10 Numbers (1–26; Commas ',' Within Words, Semicolons ';' Between Words)",
              hint:
              "e.g. 9, 12, 9, 11, 5; 13, 1, 20, 8, 5, 13, 1, 20, 9, 3, 19",
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
                    "Snap a photo of any punch card/tape or coded message question from JSS 3 Chapter 1 (Example 7, Table 1.8, or Exercise 1.4 #1–5)!",
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
              labelText: "Punch Tape or Coded Message Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Put 'I HATE CORRUPTION' on a punch card/tape, or translate 9, 12, 9, 11, 5; 13, 1, 20, 8, 5, 13, 1, 20, 9, 3, 19...",
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
                "Extract & Solve Punch Tape",
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
            icon: const Icon(Icons.confirmation_number, color: Colors.white),
            label: const Text(
              "Generate Coded Form & Punch Tape",
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

    final PunchTapeCanvasData cd = _result!.canvasData;
    final int rowCount = cd.rows.length;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 690.0);
    final double canvasHeight = math.max(360.0, 150.0 + rowCount * 29.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Table 1.7(a)/(c) Coded Form & Table 1.7(b)/(d) Punch Card/Tape:",
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
          height: 430,
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
                  painter: PunchTapePainter(data: cd),
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
          "3. Mathematical & Punch-Tape Workings:",
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
          'The Punch Tape',
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

class PunchTapePainter extends CustomPainter {
  final PunchTapeCanvasData data;

  PunchTapePainter({required this.data});

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
    const double codedPanelW = 248.0;
    const double gapW = 42.0;
    const double tapePanelW = 326.0;
    const double totalW = codedPanelW + gapW + tapePanelW;

    double startX = (size.width - totalW) / 2;
    if (startX < 16.0) startX = 16.0;

    // 2. Left Panel: Table 1.7(a)/(c) Coded Form
    _paintTable1_7CodedForm(canvas, startX, topY, codedPanelW, rowH);

    // 3. Right Panel: Table 1.7(b)/(d) Punch Card / Tape
    _paintTable1_7PunchCardTape(
      canvas,
      startX + codedPanelW + gapW,
      topY,
      tapePanelW,
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

  void _paintTable1_7CodedForm(
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
      "Table 1.7(a)/(c) Coded form",
      leftX + width / 2,
      topY,
      Colors.deepPurple,
    );

    final double boxTop = topY + 18.0;
    final Rect boxRect = Rect.fromLTWH(leftX, boxTop, width, totalH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(10)),
      Paint()..color = Colors.deepPurple.shade50.withOpacity(0.42),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.deepPurple.shade200
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    final double colLetterX = leftX + 32.0;
    final double colPos10X = leftX + 78.0;
    final double dashedSplitX = leftX + 158.0;
    final List<double> bitColX = [
      leftX + 120.0, // 16
      leftX + 142.0, // 8
      leftX + 174.0, // 4
      leftX + 198.0, // 2
      leftX + 222.0, // 1
    ];
    const List<String> bitHeaders = ["16", "8", "4", "2", "1"];

    // Column Header Row
    final double headerCy = boxTop + rowH / 2 + 2;
    _drawText(canvas, "Letter", colLetterX, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.deepPurple.shade900);
    _drawText(canvas, "Base 10", colPos10X, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.deepPurple.shade900);
    for (int c = 0; c < 5; c++) {
      _drawText(
        canvas,
        bitHeaders[c],
        bitColX[c],
        headerCy,
        fontSize: 10.5,
        isBold: true,
        color: Colors.deepPurple.shade700,
      );
    }

    canvas.drawLine(
      Offset(leftX + 8, boxTop + rowH + 2),
      Offset(leftX + width - 8, boxTop + rowH + 2),
      Paint()
        ..color = Colors.deepPurple.shade300
        ..strokeWidth = 1.3,
    );

    // Vertical Dashed Line between column 8 and column 4 (exact match for Table 1.7a & 1.7c)
    _drawDashedLine(
      canvas,
      Offset(dashedSplitX, boxTop + 6),
      Offset(dashedSplitX, boxTop + totalH - 6),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );

    for (int i = 0; i < nRows; i++) {
      final PunchTapeRow r = data.rows[i];
      final double cy = boxTop + (i + 1) * rowH + rowH / 2 + 2;

      if (r.isWordSeparator) {
        // Horizontal dashed word separator line (exact match for Table 1.7c & Table 1.8)
        _drawDashedLine(
          canvas,
          Offset(leftX + 12, cy),
          Offset(leftX + width - 12, cy),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.5,
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
        colPos10X,
        cy,
        fontSize: 12.0,
        color: Colors.black87,
      );

      // Print each active binary digit in its exact column (from first '1' to the right)
      final int firstOneIdx = r.fiveTrackBits.indexOf(1);
      for (int c = firstOneIdx; c < 5 && firstOneIdx != -1; c++) {
        _drawText(
          canvas,
          "${r.fiveTrackBits[c]}",
          bitColX[c],
          cy,
          fontSize: 13.5,
          isBold: true,
          color: r.fiveTrackBits[c] == 1
              ? Colors.green.shade900
              : Colors.grey.shade700,
        );
      }
    }
  }

  void _paintTable1_7PunchCardTape(
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
      "Table 1.7(b)/(d) Punch card / tape",
      leftX + width / 2,
      topY,
      Colors.green.shade800,
    );

    final double tapeTop = topY + 18.0;
    final Rect tapeRect = Rect.fromLTWH(leftX, tapeTop, width, totalH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tapeRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tapeRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.amber.shade900
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    final double colLetterX = leftX + 28.0;
    final double dashedLineX = leftX + 148.0;
    final List<double> holeTrackX = [
      leftX + 76.0, // Column 16 (2⁴)
      leftX + 114.0, // Column 8  (2³)
      leftX + 182.0, // Column 4  (2²)
      leftX + 220.0, // Column 2  (2¹)
      leftX + 258.0, // Column 1  (2⁰)
    ];
    const List<String> trackHeaders = ["16", "8", "4", "2", "1"];

    // Header Row on the Punch Card/Tape
    final double headerCy = tapeTop + rowH / 2 + 2;
    _drawText(canvas, "Letter", colLetterX, headerCy,
        fontSize: 11.0, isBold: true, color: Colors.brown.shade900);
    for (int c = 0; c < 5; c++) {
      _drawText(
        canvas,
        trackHeaders[c],
        holeTrackX[c],
        headerCy,
        fontSize: 11.0,
        isBold: true,
        color: Colors.brown.shade800,
      );
    }
    _drawText(canvas, "Sum", leftX + 300.0, headerCy,
        fontSize: 10.5, isBold: true, color: Colors.green.shade900);

    canvas.drawLine(
      Offset(leftX + 8, tapeTop + rowH + 2),
      Offset(leftX + width - 8, tapeTop + rowH + 2),
      Paint()
        ..color = Colors.amber.shade800
        ..strokeWidth = 1.3,
    );

    // Vertical Dashed Line on the Punch Card/Tape (matching Table 1.7b & Table 1.7d on Page 14!)
    _drawDashedLine(
      canvas,
      Offset(dashedLineX, tapeTop + 6),
      Offset(dashedLineX, tapeTop + totalH - 6),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6,
    );

    for (int i = 0; i < nRows; i++) {
      final PunchTapeRow r = data.rows[i];
      final double cy = tapeTop + (i + 1) * rowH + rowH / 2 + 2;

      if (r.isWordSeparator) {
        // Horizontal dashed word-separator line across the punch card/tape (matching Table 1.7d)
        _drawDashedLine(
          canvas,
          Offset(leftX + 12, cy),
          Offset(leftX + width - 12, cy),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.6,
        );
        continue;
      }

      // Letter label on the left of the punch card/tape (matching Table 1.7b & 1.7d)
      _drawText(
        canvas,
        r.letter,
        colLetterX,
        cy,
        fontSize: 13.5,
        isBold: true,
        color: Colors.black87,
      );

      for (int c = 0; c < 5; c++) {
        final int bitVal = r.fiveTrackBits[c];
        final Offset center = Offset(holeTrackX[c], cy);

        if (bitVal == 1) {
          // Solid Black Punched Hole (●) in place of binary digit '1' (Table 1.7b & 1.7d)
          canvas.drawCircle(
            center,
            6.2,
            Paint()..color = Colors.black87,
          );
        } else if (data.punchTapeStyle == 1) {
          // Optional Labeled 5-Track Guide Mode: draw faint open circle for unpunched '0'
          canvas.drawCircle(
            center,
            5.5,
            Paint()..color = Colors.white,
          );
          canvas.drawCircle(
            center,
            5.5,
            Paint()
              ..color = Colors.amber.shade700
              ..strokeWidth = 1.2
              ..style = PaintingStyle.stroke,
          );
          _drawText(
            canvas,
            "0",
            center.dx,
            center.dy,
            fontSize: 8.5,
            color: Colors.brown.shade400,
          );
        }
      }

      _drawText(
        canvas,
        "= ${r.base10Position}",
        leftX + 300.0,
        cy,
        fontSize: 11.0,
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
  bool shouldRepaint(covariant PunchTapePainter oldDelegate) =>
      oldDelegate.data != data;
}