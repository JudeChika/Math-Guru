// lib/features/junior_secondary/jss1/algebra/translations/translation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'translation_solver.dart';
import 'translation_models.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  TranslationResult? _result;
  bool _isWordToMath = true; // True = Words to Math, False = Math to Words

  void _translate() {
    FocusScope.of(context).unfocus();
    if (_inputController.text.trim().isNotEmpty) {
      setState(() {
        if (_isWordToMath) {
          _result = TranslationSolver.translateWordsToMath(_inputController.text.trim());
        } else {
          _result = TranslationSolver.translateMathToWords(_inputController.text.trim());
        }
      });
    }
  }

  void _toggleMode(bool isWordToMath) {
    if (_isWordToMath == isWordToMath) return;
    setState(() {
      _isWordToMath = isWordToMath;
      _inputController.clear();
      _result = null;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Algebraic Translations'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEGMENTED TOGGLE SWITCH ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleMode(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isWordToMath ? Colors.deepPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Words → Math",
                              style: TextStyle(
                                  color: _isWordToMath ? Colors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleMode(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isWordToMath ? Colors.deepPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Math → Words",
                              style: TextStyle(
                                  color: !_isWordToMath ? Colors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _isWordToMath
                    ? "Enter your word problem:"
                    : "Enter your algebraic equation:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _isWordToMath
                    ? "e.g. When three times a number is added to 4, the result is 25"
                    : "e.g. 3x + 4 = 25",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: _isWordToMath ? TextInputType.multiline : TextInputType.text,
                      maxLines: _isWordToMath ? 3 : 1,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: _isWordToMath ? "Type sentence here..." : "e.g. 3x + 4 = 25",
                      ),
                      onSubmitted: (_) => _translate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _translate,
                    child: const Text("Translate"),
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
                    Text("Final Translation:",
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
                            child: _result!.isOutputMath
                                ? Math.tex(
                              _result!.finalOutput,
                              textStyle: theme.textTheme.displaySmall?.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.green.shade800,
                              ),
                            )
                                : Text(
                              _result!.finalOutput,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. STEP-BY-STEP EXPLANATION ---
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
                      _result!.errorMessage ?? "Translation error",
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

  Widget _buildStepsList(List<TranslationStep> steps, ThemeData theme) {
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
                  child: step.isMathFormat
                      ? Math.tex(
                    step.content,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: step.isFinalAnswer ? 20 : 16,
                      fontWeight: step.isFinalAnswer ? FontWeight.bold : FontWeight.normal,
                      color: step.isFinalAnswer ? Colors.green.shade800 : Colors.deepPurple.shade900,
                    ),
                  )
                      : Text(
                    step.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: step.isFinalAnswer ? FontWeight.bold : FontWeight.w600,
                      color: step.isFinalAnswer ? Colors.green.shade800 : Colors.black87,
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