import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'divisibility_logic.dart';
import 'divisibility_models.dart';

class DivisibilityScreen extends StatefulWidget {
  const DivisibilityScreen({super.key});

  @override
  State<DivisibilityScreen> createState() => _DivisibilityScreenState();
}

class _DivisibilityScreenState extends State<DivisibilityScreen> {
  final _numberController = TextEditingController();
  final _divisorController = TextEditingController();

  DivisibilityResult? _result;

  @override
  void dispose() {
    _numberController.dispose();
    _divisorController.dispose();
    super.dispose();
  }

  void _checkDivisibility() {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = DivisibilityLogic.checkDivisibility(
          _numberController.text,
          _divisorController.text
      );
    });
  }

  Widget _buildResultBanner(ThemeData theme) {
    if (_result == null || !_result!.valid) return const SizedBox.shrink();

    final isYes = _result!.isDivisible;
    final bannerColor = isYes ? Colors.green.shade600 : Colors.red.shade600;
    final bannerIcon = isYes ? Icons.check_circle : Icons.cancel;
    final bannerText = isYes ? "YES! It is divisible." : "NO! It is not divisible.";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: bannerColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(bannerIcon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bannerText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Is ${_result!.number} divisible by ${_result!.divisor}?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(ThemeData theme) {
    if (_result == null || !_result!.valid) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "The Rule for ${_result!.divisor}",
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _result!.ruleApplied,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList(ThemeData theme) {
    if (_result == null || !_result!.valid) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _result!.steps.length,
          itemBuilder: (context, idx) {
            final step = _result!.steps[idx];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  child: Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(step.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: step.workingLaTeX != null
                    ? Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      step.workingLaTeX!,
                      textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules for Divisibility'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter a large number and the divisor you want to test:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Large Number",
                        hintText: "e.g. 84562",
                        prefixIcon: const Icon(Icons.numbers, color: Colors.deepPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _divisorController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Divisor",
                        hintText: "e.g. 3",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => _checkDivisibility(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkDivisibility,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text("Check Divisibility", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              if (_result != null && !_result!.valid)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      _result!.error ?? "Invalid Input",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              if (_result != null && _result!.valid) ...[
                const SizedBox(height: 24),
                _buildResultBanner(theme),
                const SizedBox(height: 16),
                _buildRuleCard(theme),
                const SizedBox(height: 24),
                _buildStepsList(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}