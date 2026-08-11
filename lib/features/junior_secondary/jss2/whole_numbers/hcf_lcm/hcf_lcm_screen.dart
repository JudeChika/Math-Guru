import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'hcf_lcm_logic.dart';
import 'hcf_lcm_models.dart';

enum CalculationMode { none, hcf, lcm }

class HCFLCMScreen extends StatefulWidget {
  const HCFLCMScreen({super.key});

  @override
  State<HCFLCMScreen> createState() => _HCFLCMScreenState();
}

class _HCFLCMScreenState extends State<HCFLCMScreen> {
  final _inputController = TextEditingController();

  CalculationMode _currentMode = CalculationMode.none;
  HCFCalculatorResult? _hcfResult;
  LCMCalculatorResult? _lcmResult;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _calculateHCF() {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentMode = CalculationMode.hcf;
      _hcfResult = HCFLCMLogic.calculateHCF(_inputController.text);
      _lcmResult = null;
    });
  }

  void _calculateLCM() {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentMode = CalculationMode.lcm;
      _lcmResult = HCFLCMLogic.calculateLCM(_inputController.text);
      _hcfResult = null;
    });
  }

  Widget _buildHCFResult(ThemeData theme) {
    if (_hcfResult == null) return const SizedBox.shrink();
    if (!_hcfResult!.valid) return _buildErrorText(_hcfResult!.error ?? "Invalid Input");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Prime Factorization:", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _hcfResult!.factorizationRows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${row.number} = ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Wrap(
                    children: List.generate(row.factors.length, (i) {
                      final isCommon = _hcfResult!.commonFactors.contains(row.factors[i]);
                      return Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: Text(
                          "${row.factors[i]}${i < row.factors.length - 1 ? " × " : ""}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isCommon ? Colors.green.shade800 : Colors.black87,
                            fontWeight: isCommon ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Text("Highest Common Factor (HCF):",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (_hcfResult!.indexForm != "1" && _hcfResult!.indexForm != _hcfResult!.hcf.toString())
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
            child: Text(
              _hcfResult!.indexForm,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          "${_hcfResult!.hcf}",
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step solution:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hcfResult!.steps.length,
          itemBuilder: (context, idx) => Card(
            color: theme.cardColor.withOpacity(0.97),
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
              title: Text(_hcfResult!.steps[idx].description, style: theme.textTheme.bodySmall),
              subtitle: _hcfResult!.steps[idx].detail != null
                  ? Text(
                _hcfResult!.steps[idx].detail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.w600,
                ),
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLCMResult(ThemeData theme) {
    if (_lcmResult == null) return const SizedBox.shrink();
    if (!_lcmResult!.valid) return _buildErrorText(_lcmResult!.error ?? "Invalid Input");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Division Table:", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text("Divisor", style: TextStyle(fontWeight: FontWeight.bold))),
                for (int i = 0; i < _lcmResult!.tableRows[0].numbers.length; i++)
                  DataColumn(label: Text("N${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                for (final row in _lcmResult!.tableRows)
                  DataRow(
                    cells: [
                      DataCell(Text(row.divisor == 1 ? "" : row.divisor.toString(), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))),
                      ...row.numbers.map((n) => DataCell(Text(n.toString()))),
                    ],
                  ),
              ],
              headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
              dataRowColor: WidgetStateProperty.all(Colors.white),
              columnSpacing: 24,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text("Lowest Common Multiple (LCM):",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (_lcmResult!.indexForm != "1" && _lcmResult!.indexForm != _lcmResult!.lcm.toString())
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
            child: Text(
              _lcmResult!.indexForm,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          "${_lcmResult!.lcm}",
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step solution:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lcmResult!.steps.length,
          itemBuilder: (context, idx) => Card(
            color: theme.cardColor.withOpacity(0.97),
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
              title: Text(_lcmResult!.steps[idx].description, style: theme.textTheme.bodySmall),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HCF & LCM Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter one or more numbers separated by commas or spaces:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "e.g. 12, 15, 24",
                  prefixIcon: const Icon(Icons.numbers, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) {
                  if (_currentMode == CalculationMode.hcf) _calculateHCF();
                  if (_currentMode == CalculationMode.lcm) _calculateLCM();
                },
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculateHCF,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text("Solve HCF", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentMode == CalculationMode.hcf ? Colors.deepPurple : Colors.grey.shade200,
                        foregroundColor: _currentMode == CalculationMode.hcf ? Colors.white : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: _currentMode == CalculationMode.hcf ? 2 : 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculateLCM,
                      icon: const Icon(Icons.functions),
                      label: const Text("Solve LCM", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentMode == CalculationMode.lcm ? Colors.deepPurple : Colors.grey.shade200,
                        foregroundColor: _currentMode == CalculationMode.lcm ? Colors.white : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: _currentMode == CalculationMode.lcm ? 2 : 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // Dynamic Results View
              if (_currentMode == CalculationMode.hcf) _buildHCFResult(theme),
              if (_currentMode == CalculationMode.lcm) _buildLCMResult(theme),

              // Helper prompt if nothing is selected yet
              if (_currentMode == CalculationMode.none)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 48, color: Colors.purple.shade200),
                        const SizedBox(height: 16),
                        Text(
                          "Enter numbers above and choose whether you want to calculate the HCF or LCM.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "(Tip: Entering a single number will perform prime factorization!)",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.purple.shade400, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}