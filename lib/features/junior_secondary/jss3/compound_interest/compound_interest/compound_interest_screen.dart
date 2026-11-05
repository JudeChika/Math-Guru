import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'compound_interest_logic.dart';
import 'compound_interest_models.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Constant-Rate Compound Interest & Final Amount — Method 1 & Method 2 (Examples 5 & 6, Ex 4.2 #1–10)
  // 1: Variable / Changing Yearly Interest Rates r₁%, r₂%, r₃% (Exercise 4.2 #11a–c)
  // 2: Reverse Compound Interest — Find Initial Principal (P) Given Final Amount (A) (Exercise 4.2 #12a–c)
  // 3: Loan Amortisation with Periodic Annual Repayments (Example 7: Mrs Mohammed's ₦12m Loan)

  String _currency = '₦'; // '₦', '£', '$'

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _input4Ctrl = TextEditingController();

  CompoundInterestResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(CompoundInterestPreset p) {
    setState(() {
      _mode = p.mode;
      _currency = p.currency;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
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
              'Please enter a compound interest question or upload a textbook image.'),
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
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      final promptText = '''
      You are a strict JSON data extractor for JSS3 Chapter 4: Compound Interest (Pages 47–49, Examples 5–7 & Exercise 4.2 #1–12).
      Classify the question or image into one of 4 modes:
      - "mode":
        0 for Constant-Rate Compound Interest & Final Amount (Examples 5 & 6, Ex 4.2 #1–10: put Principal P in "input1", Years n in "input2", and Rate r% in "input3").
        1 for Variable / Changing Yearly Interest Rates (Exercise 4.2 #11: put Principal P in "input1", 1st year rate r1 in "input2", 2nd year rate r2 in "input3", and 3rd year rate r3 in "input4").
        2 for Reverse Compound Interest — Finding the Initial Principal (P) given the Final Amount (A) (Exercise 4.2 #12a–c: put Final Amount A in "input1", Years n in "input2", and Rate r% in "input3").
        3 for Loan Amortisation with Periodic Annual Repayments (Example 7: Mrs Mohammed obtained a loan of 12m at 10% for 4 years, repaying 1350000 each year -> put Loan Principal in "input1", Years in "input2", Rate r% in "input3", and Annual Repayment in "input4").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "currency": "₦",
        "input1": "45000",
        "input2": "3",
        "input3": "10",
        "input4": ""
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
        final String curr = jsonMap['currency']?.toString() ?? '₦';
        if (['₦', '£', '\$'].contains(curr)) _currency = curr;
        if (jsonMap['input1'] != null) {
          _input1Ctrl.text = jsonMap['input1'].toString();
        }
        if (jsonMap['input2'] != null) {
          _input2Ctrl.text = jsonMap['input2'].toString();
        }
        if (jsonMap['input3'] != null) {
          _input3Ctrl.text = jsonMap['input3'].toString();
        }
        if (jsonMap['input4'] != null) {
          _input4Ctrl.text = jsonMap['input4'].toString();
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
        _result = CompoundInterestLogic.solveConstantRateCompoundInterest(
          principalStr: _input1Ctrl.text,
          timeYearsStr: _input2Ctrl.text,
          rateStr: _input3Ctrl.text,
          currency: _currency,
        );
      } else if (_mode == 1) {
        _result = CompoundInterestLogic.solveVariableRatesCompoundInterest(
          principalStr: _input1Ctrl.text,
          rate1Str: _input2Ctrl.text,
          rate2Str: _input3Ctrl.text,
          rate3Str: _input4Ctrl.text,
          currency: _currency,
        );
      } else if (_mode == 2) {
        _result = CompoundInterestLogic.solveReverseFindPrincipal(
          targetAmountStr: _input1Ctrl.text,
          timeYearsStr: _input2Ctrl.text,
          rateStr: _input3Ctrl.text,
          currency: _currency,
        );
      } else {
        _result = CompoundInterestLogic.solveLoanWithAnnualRepayments(
          initialLoanStr: _input1Ctrl.text,
          yearsStr: _input2Ctrl.text,
          rateStr: _input3Ctrl.text,
          annualRepaymentStr: _input4Ctrl.text,
          currency: _currency,
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

  Widget _buildCurrencySelector() {
    return Row(
      children: [
        const Text(
          "Currency:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(width: 10),
        for (final String c in ['₦', '£', '\$'])
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                c == '₦'
                    ? '₦ (Naira)'
                    : (c == '£' ? '£ (Pounds)' : '\$ (Dollars)'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _currency == c ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: _currency == c,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: _currency == c
                    ? Colors.deepPurple
                    : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _currency = c),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetsBar() {
    const presets = CompoundInterestLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Examples 5–7 & Exercise 4.2 #1–12):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(
                      Icons.trending_up,
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
        'label': 'Compound Interest & Amount — Method 1 & 2 (Ex 5–6 & Ex 4.2 #1–10)',
        'icon': Icons.trending_up,
      },
      {
        'idx': 1,
        'label': 'Variable Yearly Rates: r₁%, r₂%, r₃% (Exercise 4.2 #11a–c)',
        'icon': Icons.stacked_line_chart,
      },
      {
        'idx': 2,
        'label': 'Find Initial Sum of Money P Given Amount A (Exercise 4.2 #12a–c)',
        'icon': Icons.find_replace,
      },
      {
        'idx': 3,
        'label': 'Loan with Annual Repayments (Example 7: Mrs Mohammed)',
        'icon': Icons.real_estate_agent_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Compound Interest Problem Mode:"),
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
          _buildCurrencySelector(),
          const SizedBox(height: 12),
          if (_mode == 0) ...[
            _buildSectionTitle(
                "2. Constant-Rate Compound Interest — Shows Both Method 1 (Step-by-Step) & Method 2 (Formula):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Initial Principal (P) in $_currency",
              hint: "e.g. 45000, 20000, 15000, 450, or 950",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Number of Years (n)",
                    hint: "e.g. 2 or 3",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Rate (r) % per Annum",
                    hint: "e.g. 10, 7, 5, or 7 1/2",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Variable / Changing Yearly Interest Rates (Exercise 4.2 #11a–c, Page 49):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Initial Principal (P) in $_currency",
              hint: "e.g. 960000",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "1st Year Rate (r₁%)",
                    hint: "e.g. 3",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "2nd Year Rate (r₂%)",
                    hint: "e.g. 4",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "3rd Year Rate (r₃%, Opt.)",
                    hint: "e.g. 5 1/2",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Find Initial Sum of Money (Principal P) Given Final Amount A (Exercise 4.2 #12a–c):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Target Final Amount (A) in $_currency (Supports 'm' for million, e.g. 5.6m)",
              hint: "e.g. 156000, 1750000, or 5.6m",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Number of Years (n)",
                    hint: "e.g. 3, 2 1/2, or 4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Compound Rate (r) % p.a.",
                    hint: "e.g. 5, 3 1/2, or 4",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Loan Amortisation with Periodic Annual Repayments (Example 7, Page 49):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Initial Loan Principal (P)",
                    hint: "e.g. 12m or 12000000",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Number of Years (n)",
                    hint: "e.g. 4",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Annual Interest Rate (r%)",
                    hint: "e.g. 10",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "Repayment at End of Each Year",
                    hint: "e.g. 1350000",
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
                    "Snap a photo of any Compound Interest or Loan Repayment question from JSS 3 Chapter 4 (Pages 47–49, Examples 5–7, or Exercise 4.2 #1–12)!",
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
              labelText: "Compound Interest Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Find the compound interest on ₦45,000 in 3 years at 10% per annum. Or: Mrs Mohammed obtained a loan of ₦12 million at 10% for 4 years...",
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
                "Extract & Solve Compound Interest",
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
              "Calculate Compound Interest Step-by-Step",
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

  /// Builds the Interactive Visualisation Area where EVERY fraction expression
  /// (year-by-year I = PRT/100 cards, A = P(1 + r/100)^n, and loan repayment steps) is rendered via Math.tex!
  Widget _buildMathForkVisualisationArea(
      CompoundInterestCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Header & Sub-Header (Rendered via Math.tex!)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.headerLaTeX,
              textStyle: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.subHeaderLaTeX,
              textStyle: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),

          // 2. Year-by-Year Compounding / Repayment Pipeline Cards (All Fractions Rendered via Math.tex!)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < cd.yearCards.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward,
                          color: Colors.deepPurple, size: 22),
                    ),
                  Container(
                    width: 245,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: i == cd.yearCards.length - 1
                          ? Colors.green.shade50
                          : Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: i == cd.yearCards.length - 1
                            ? Colors.green.shade700
                            : Colors.deepPurple.shade300,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          cd.yearCards[i].yearTitle,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: i == cd.yearCards.length - 1
                                ? Colors.green.shade900
                                : Colors.deepPurple.shade900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.yearCards[i].startPrincipalLaTeX,
                            textStyle: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.yearCards[i].interestFractionLaTeX,
                            textStyle: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.yearCards[i].endAmountLaTeX,
                            textStyle: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. Method 2 Formula Banner (Rendered via Math.tex!)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple, width: 1.8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.formulaBannerLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ),

          // 4. Bottom Summary Banner (Rendered via Math.tex!)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.bottomSummaryLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

    final CompoundInterestCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double neededW =
    math.max(680.0, cd.yearCards.length * 265.0 + 40.0);
    final double canvasWidth = math.max(screenWidth, neededW);
    const double canvasHeight = 370.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Year-by-Year Compounding & Formula Visualizer:",
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
              child: _buildMathForkVisualisationArea(
                cd,
                canvasWidth,
                canvasHeight,
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
          children: _result!.finalAnswersLaTeX.entries.map((entry) {
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
                  const SizedBox(height: 6),
                  Math.tex(
                    entry.value,
                    textStyle: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
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
          'Compound Interest',
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