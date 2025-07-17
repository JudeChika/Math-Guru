import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fraction_addition_logic.dart';
import 'fraction_subtraction_logic.dart';
import 'fraction_models.dart';

class FractionAdditionSubtractionScreen extends StatefulWidget {
  const FractionAdditionSubtractionScreen({super.key});

  @override
  State<FractionAdditionSubtractionScreen> createState() =>
      _FractionAdditionSubtractionScreenState();
}

class _FractionAdditionSubtractionScreenState
    extends State<FractionAdditionSubtractionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Addition Tab
  final List<TextEditingController> _addControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  String? _addResult;
  List<FractionWorkingStep> _addWorkings = [];
  List<FractionExplanation> _addExplanations = [];

  // Subtraction Tab
  final List<TextEditingController> _subControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  String? _subResult;
  List<FractionWorkingStep> _subWorkings = [];
  List<FractionExplanation> _subExplanations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addFractionInput(bool isAddition) {
    setState(() {
      if (isAddition) {
        _addControllers.add(TextEditingController());
      } else {
        _subControllers.add(TextEditingController());
      }
    });
  }

  void _calculateAddition() {
    final inputs = _addControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (inputs.length < 2) return;

    final solution = FractionAdditionLogic.solve(inputs);

    setState(() {
      _addResult = solution?.finalLatex;
      _addWorkings = solution?.workings ?? [];
      _addExplanations = solution?.explanations ?? [];
    });
  }

  void _calculateSubtraction() {
    final inputs = _subControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (inputs.length < 2) return;

    final solution = FractionSubtractionLogic.solve(inputs);

    setState(() {
      _subResult = solution?.finalLatex;
      _subWorkings = solution?.workings ?? [];
      _subExplanations = solution?.explanations ?? [];
    });
  }

  Widget buildTab({
    required bool isAddition,
    required List<TextEditingController> controllers,
    required String? result,
    required List<FractionWorkingStep> workings,
    required List<FractionExplanation> explanations,
    required VoidCallback onCalculate,
  }) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
        fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAddition
                ? "Enter fractions to add (e.g. 1/2, 3/4, 2 1/3):"
                : "Enter fractions to subtract (e.g. 3/4, 1/2, 2 1/3):",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),
          ...controllers.map((controller) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: controller,
              style: inputStyle,
              decoration: InputDecoration(
                labelText: "Fraction or Mixed Number",
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              ),
            ),
          )),
          Center(
            child: TextButton.icon(
              onPressed: () => _addFractionInput(isAddition),
              icon: const Icon(Icons.add, color: Colors.deepPurple),
              label: Text(
                "Add More Inputs",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              onPressed: onCalculate,
              child: Text(
                isAddition ? "Add Fractions" : "Subtract Fractions",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (result != null)
            Center(
              child: Column(
                children: [
                  Text(
                    "Result:",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  Math.tex(
                    result,
                    textStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.green[700],
                    ),
                    mathStyle: MathStyle.display,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (workings.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Working:",
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: workings
                          .map((step) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Math.tex(
                          step.latexMath,
                          textStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.deepPurple),
                          mathStyle: MathStyle.display,
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          if (explanations.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Step-by-step Solution:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                ...explanations.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final explanation = entry.value;
                  return Card(
                    color: Colors.purple.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          '$index',
                          style: GoogleFonts.poppins(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            explanation.description,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple[800],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (explanation.latexMath != null)
                            Math.tex(
                              explanation.latexMath!,
                              textStyle: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.deepPurple),
                              mathStyle: MathStyle.display,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _addControllers) {
      c.dispose();
    }
    for (var c in _subControllers) {
      c.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Fraction Addition & Subtraction',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Addition"),
              Tab(text: "Subtraction"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildTab(
              isAddition: true,
              controllers: _addControllers,
              result: _addResult,
              workings: _addWorkings,
              explanations: _addExplanations,
              onCalculate: _calculateAddition,
            ),
            buildTab(
              isAddition: false,
              controllers: _subControllers,
              result: _subResult,
              workings: _subWorkings,
              explanations: _subExplanations,
              onCalculate: _calculateSubtraction,
            ),
          ],
        ),
      ),
    );
  }
}
