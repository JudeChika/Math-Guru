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

  void _solveExpression() {
    FocusScope.of(context).unfocus();
    if (_expressionController.text.trim().isNotEmpty) {
      setState(() {
        _result = BracketsOperationsSolver.simplifyExpression(_expressionController.text.trim());
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
        title: const Text('Simplifying Expressions with Brackets'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter expression with brackets e.g. 2x + 3(4x - y/2):",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Use parentheses () to group terms.",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expressionController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "e.g. 2(3x + 4y) - 4(x - y)",
                      ),
                      onSubmitted: (_) => _solveExpression(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _solveExpression,
                    child: const Text("Simplify"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_result != null)
                _result!.valid
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. FINAL RESULT TOP CARD ---
                    Text("Final Simplified Answer:",
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