// lib/features/junior_secondary/jss1/algebra/brackets_operations/brackets_operations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'brackets_operations_solver.dart';
import 'brackets_operations_models.dart';

class BracketsOperationsScreen extends StatefulWidget {
  const BracketsOperationsScreen({super.key});

  @override
  State<BracketsOperationsScreen> createState() => _BracketsOperationsScreenState();
}

class _BracketsOperationsScreenState extends State<BracketsOperationsScreen> {
  final TextEditingController _expressionController = TextEditingController();
  BracketResult? _result;
  String? _selectedSubject;

  void _solveExpression({String? subjectOverride}) {
    FocusScope.of(context).unfocus();
    if (_expressionController.text.trim().isNotEmpty) {
      setState(() {
        _result = BracketsOperationsSolver.simplifyExpression(
          _expressionController.text.trim(),
          targetSubject: subjectOverride ?? _selectedSubject,
        );

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
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expressions & Equations with Brackets'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your expression or equation:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "e.g., 3(2x - 1) or 2(3x - 1) = 3(3y + 1)",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expressionController,
                      decoration: const InputDecoration(
                        hintText: "e.g. 2(3x - 1) = 3(3y + 1)",
                      ),
                      onSubmitted: (_) {
                        _selectedSubject = null;
                        _solveExpression();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _selectedSubject = null;
                      _solveExpression();
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
                    // --- VARIABLE SELECTOR ---
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
                                _solveExpression(subjectOverride: variable);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- FINAL RESULT CARD ---
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
                              textStyle: theme.textTheme.displaySmall?.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- WORKINGS SECTION ---
                    Text("Workings:",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                        )
                    ),
                    const SizedBox(height: 8),
                    _buildWorkingsCard(_result!.steps, theme),
                    const SizedBox(height: 24),

                    // --- STEP-BY-STEP BREAKDOWN ---
                    Text("Step-by-step Breakdown:",
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
                      _result!.errorMessage ?? "Error evaluating input.",
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

  Widget _buildWorkingsCard(List<BracketSolutionStep> steps, ThemeData theme) {
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

  Widget _buildStepsList(List<BracketSolutionStep> steps, ThemeData theme) {
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