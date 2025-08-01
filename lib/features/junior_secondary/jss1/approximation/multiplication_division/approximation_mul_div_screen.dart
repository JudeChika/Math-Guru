import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

import 'approximation_mul_div_logic.dart';

class ApproximationMulDivScreen extends StatefulWidget {
  const ApproximationMulDivScreen({super.key});

  @override
  State<ApproximationMulDivScreen> createState() => _ApproximationMulDivScreenState();
}

class _ApproximationMulDivScreenState extends State<ApproximationMulDivScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _modes = [
    'Nearest Unit',
    'Nearest Ten',
    'Nearest Hundred',
    'Nearest Thousand',
    'Nearest Tenth',
    'Nearest Hundredth',
    'Nearest Thousandth',
    '1dp',
    '2dp',
    '3dp',
    '4dp',
    '5dp',
    '1sf',
    '2sf',
    '3sf',
    '4sf',
    '5sf',
  ];

  // For simplicity, 2 operands. Can extend to more.
  final TextEditingController _controller1Mul = TextEditingController();
  final TextEditingController _controller2Mul = TextEditingController();
  String _selectedModeMul = 'Nearest Unit';
  ApproxResult? _resultMul;

  final TextEditingController _controller1Div = TextEditingController();
  final TextEditingController _controller2Div = TextEditingController();
  String _selectedModeDiv = 'Nearest Unit';
  ApproxResult? _resultDiv;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller1Mul.dispose();
    _controller2Mul.dispose();
    _controller1Div.dispose();
    _controller2Div.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildMathOrText(String latex) {
    try {
      if (latex.trim().startsWith(r"\") ||
          latex.contains(r"_") ||
          latex.contains(r"frac") ||
          latex.contains('=') ||
          latex.contains(r"\text")) {
        return Math.tex(
          latex,
          textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
          mathStyle: MathStyle.display,
        );
      } else {
        return Text(
          latex,
          style: GoogleFonts.poppins(fontSize: 17, color: Colors.deepPurple),
          softWrap: true,
        );
      }
    } catch (_) {
      return Text(
        latex,
        style: GoogleFonts.poppins(fontSize: 17, color: Colors.deepPurple),
        softWrap: true,
      );
    }
  }

  Widget _buildResultSection(String? latex, String title) {
    if (latex == null) return const SizedBox.shrink();
    String math = latex.split(r'\text').first.trim();
    String? explanation;
    final expMatch = RegExp(r'\\text\{(.+?)\}').firstMatch(latex);
    if (expMatch != null) {
      explanation = expMatch.group(1);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        // Fix for overflow by enabling horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Math.tex(
              math,
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.green[700],
              ),
              mathStyle: MathStyle.display,
            ),
          ),
        ),
        if (explanation != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              explanation,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildStepCard(List<ApproxSolutionStep> steps, {required String title, required bool isExplanation}) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.purple.shade50,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: steps.asMap().entries.map((entry) {
                final step = entry.value;
                if (isExplanation) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (step.description.isNotEmpty) ...[
                          Text(
                            step.description,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple[800],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        _buildMathOrText(step.latex),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildMathOrText(step.latex),
                  );
                }
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _computeMultiplication() {
    final input1 = _controller1Mul.text.trim();
    final input2 = _controller2Mul.text.trim();
    if (input1.isEmpty || input2.isEmpty) {
      setState(() {
        _resultMul = null;
      });
      return;
    }
    final result = ApproximationMulDivLogic.solve(
      inputs: [input1, input2],
      mode: _selectedModeMul,
      operation: "×", // Unicode multiplication sign
    );
    setState(() {
      _resultMul = result;
    });
  }

  void _computeDivision() {
    final input1 = _controller1Div.text.trim();
    final input2 = _controller2Div.text.trim();
    if (input1.isEmpty || input2.isEmpty) {
      setState(() {
        _resultDiv = null;
      });
      return;
    }
    final result = ApproximationMulDivLogic.solve(
      inputs: [input1, input2],
      mode: _selectedModeDiv,
      operation: "÷", // Unicode division sign
    );
    setState(() {
      _resultDiv = result;
    });
  }

  Widget _buildTabContent({
    required TextEditingController controller1,
    required TextEditingController controller2,
    required String selectedMode,
    required Function(String?) onModeChanged,
    required Function() onCompute,
    required ApproxResult? result,
    required String opSymbol,
  }) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter ${opSymbol == '×' ? 'numbers to multiply' : 'numbers to divide'} (whole, decimal, or fraction):",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller1,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: "First Number",
                    labelStyle: labelStyle,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  opSymbol,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: controller2,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: "Second Number",
                    labelStyle: labelStyle,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedMode,
            items: _modes
                .map((mode) => DropdownMenuItem(
              value: mode,
              child: Text(mode),
            ))
                .toList(),
            onChanged: onModeChanged,
            decoration: InputDecoration(
              labelText: "Select Rounding Mode",
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
              onPressed: onCompute,
              child: const Text("Compute",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 22),
          if (result != null) ...[
            _buildResultSection(result.finalApproxLatex, "Approximated Value"),
            const SizedBox(height: 18),
            _buildResultSection(result.finalExactLatex, "Exact Value"),
            const SizedBox(height: 18),
            _buildStepCard(result.approxSteps, title: "Working (Approximation)", isExplanation: false),
            const SizedBox(height: 18),
            _buildStepCard(result.approxSteps, title: "Step-by-step Explanation (Approximation)", isExplanation: true),
            const SizedBox(height: 18),
            _buildStepCard(result.exactSteps, title: "Working (Exact Value)", isExplanation: false),
            const SizedBox(height: 18),
            _buildStepCard(result.exactSteps, title: "Step-by-step Explanation (Exact Value)", isExplanation: true),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Approximate Multiplication & Division",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Multiplication"),
            Tab(text: "Division"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            controller1: _controller1Mul,
            controller2: _controller2Mul,
            selectedMode: _selectedModeMul,
            onModeChanged: (val) {
              if (val != null) setState(() => _selectedModeMul = val);
            },
            onCompute: _computeMultiplication,
            result: _resultMul,
            opSymbol: "×",
          ),
          _buildTabContent(
            controller1: _controller1Div,
            controller2: _controller2Div,
            selectedMode: _selectedModeDiv,
            onModeChanged: (val) {
              if (val != null) setState(() => _selectedModeDiv = val);
            },
            onCompute: _computeDivision,
            result: _resultDiv,
            opSymbol: "÷",
          ),
        ],
      ),
    );
  }
}