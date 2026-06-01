// lib/features/junior_secondary/jss1/algebra/algebra_input_and_solution_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'algebra_solver.dart';
import 'algebra_models.dart';

class AlgebraInputAndSolutionScreen extends StatefulWidget {
  const AlgebraInputAndSolutionScreen({super.key});

  @override
  State<AlgebraInputAndSolutionScreen> createState() => _AlgebraInputAndSolutionScreenState();
}

class _AlgebraInputAndSolutionScreenState extends State<AlgebraInputAndSolutionScreen> {
  final TextEditingController _equationController = TextEditingController();
  AlgebraResult? _result;
  String? _selectedSubject;

  void _solveEquation({String? subjectOverride}) {
    FocusScope.of(context).unfocus();
    if (_equationController.text.trim().isNotEmpty) {
      setState(() {
        _result = AlgebraSolver.solveLinearEquation(
          _equationController.text.trim(),
          targetSubject: subjectOverride ?? _selectedSubject,
        );
        // Sync selected subject with what the solver actually used
        if (_result != null && _result!.valid) {
          _selectedSubject = _result!.subjectUsed;
        } else {
          _selectedSubject = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Problems with Letters'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your equation below (e.g., x/2 + y = 10z):",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _equationController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "e.g. x/2 + y = 10z",
                      ),
                      onSubmitted: (_) {
                        _selectedSubject = null; // Reset selection on new text
                        _solveEquation();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _selectedSubject = null; // Reset selection on new submission
                      _solveEquation();
                    },
                    child: const Text("Solve"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_result != null)
                _result!.valid
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NEW: Variable Selector (Subject of Formula) ---
                    if (_result!.availableVariables.length > 1) ...[
                      Text("Make subject of formula:",
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple
                          )
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _result!.availableVariables.map((variable) {
                          final isSelected = variable == _selectedSubject;
                          return ChoiceChip(
                            label: Text(variable),
                            selected: isSelected,
                            selectedColor: Colors.deepPurple.shade100,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                                color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontFamily: 'Poppins'
                            ),
                            onSelected: (bool selected) {
                              if (selected && variable != _selectedSubject) {
                                _solveEquation(subjectOverride: variable);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- 1. FINAL RESULT TOP CARD ---
                    Text("Final Result:",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                        )
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.green.shade50,
                      elevation: 1.0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Math.tex(
                              _result!.finalAnswerLaTeX,
                              textStyle: theme.textTheme.displayLarge?.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. WORKINGS SUMMARY ---
                    Text("Workings:",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                        )
                    ),
                    const SizedBox(height: 8),
                    _buildWorkingsCard(_result!.steps, theme),
                    const SizedBox(height: 24),

                    // --- 3. STEP-BY-STEP EXPLANATION ---
                    Text("Step-by-step Explanation:",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                        )
                    ),
                    const SizedBox(height: 8),
                    _buildStepsList(_result!.steps, theme),
                  ],
                )
                    : Card(
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _result!.errorMessage ?? "Invalid input",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingsCard(List<AlgebraSolutionStep> steps, ThemeData theme) {
    return Card(
      color: Colors.deepPurple.shade50,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Center(
          child: Column(
            children: steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  step.workingLaTeX,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: step.isFinalAnswer ? 20 : 16,
                    fontWeight: step.isFinalAnswer ? FontWeight.bold : FontWeight.normal,
                    color: step.isFinalAnswer ? Colors.green.shade800 : Colors.deepPurple.shade900,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList(List<AlgebraSolutionStep> steps, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) {
        final step = steps[idx];
        return Card(
          color: theme.cardColor.withOpacity(0.98),
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                      color: Colors.deepPurple,
                      fontFamily: 'Poppins'
                  )
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                  child: Text(
                    step.explanation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    step.workingLaTeX,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: step.isFinalAnswer ? FontWeight.bold : FontWeight.normal,
                      color: step.isFinalAnswer ? Colors.green.shade800 : Colors.deepPurple.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}