import 'package:flutter/material.dart';
import 'models.dart';
import 'fraction_widgets.dart';
import 'mixed_to_improper_logic.dart';
import 'improper_to_mixed_logic.dart';

class MixedImproperScreen extends StatefulWidget {
  const MixedImproperScreen({super.key});

  @override
  State<MixedImproperScreen> createState() => _MixedImproperScreenState();
}

class _MixedImproperScreenState extends State<MixedImproperScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mixed to Improper
  final _mixedWholeController = TextEditingController();
  final _mixedNumeratorController = TextEditingController();
  final _mixedDenominatorController = TextEditingController();
  MixedToImproperResult? _mixedToImproperResult;

  // Improper to Mixed
  final _improperNumeratorController = TextEditingController();
  final _improperDenominatorController = TextEditingController();
  ImproperToMixedResult? _improperToMixedResult;
  bool _showLongDivision = false;

  void _convertMixedToImproper() {
    setState(() {
      final whole = int.tryParse(_mixedWholeController.text) ?? 0;
      final num = int.tryParse(_mixedNumeratorController.text) ?? 0;
      final denom = int.tryParse(_mixedDenominatorController.text) ?? 1;
      final input = MixedNumber(whole: whole, numerator: num, denominator: denom);
      _mixedToImproperResult = MixedToImproperLogic.convert(input);
    });
  }

  void _convertImproperToMixed() {
    setState(() {
      final num = int.tryParse(_improperNumeratorController.text) ?? 0;
      final denom = int.tryParse(_improperDenominatorController.text) ?? 1;
      final input = ImproperFraction(numerator: num, denominator: denom);
      _improperToMixedResult = ImproperToMixedLogic.convert(input);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _mixedToImproperSection(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Mixed Number to Improper Fraction",
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _mixedWholeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Whole"),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextField(
                  controller: _mixedNumeratorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Numerator"),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextField(
                  controller: _mixedDenominatorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Denominator"),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _convertMixedToImproper,
                child: const Text("Convert"),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_mixedToImproperResult != null)
            _mixedToImproperResultCard(_mixedToImproperResult!, theme),
        ],
      ),
    );
  }

  Widget _mixedToImproperResultCard(MixedToImproperResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? "Invalid input.",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ),
      );
    }
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: FractionText(
                numerator: result.output.numerator,
                denominator: result.output.denominator,
                fontSize: 32,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text("Workings:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.workings.map((line) =>
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(line, style: theme.textTheme.bodySmall),
                  )).toList(),
            ),
            const SizedBox(height: 10),
            Text("Step-by-step Explanation:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ...result.steps.map((e) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(e, style: theme.textTheme.bodySmall),
            )),
          ],
        ),
      ),
    );
  }

  Widget _improperToMixedSection(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Improper Fraction to Mixed Number",
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _improperNumeratorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Numerator"),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextField(
                  controller: _improperDenominatorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Denominator"),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _convertImproperToMixed,
                child: const Text("Convert"),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                  value: _showLongDivision,
                  onChanged: (val) {
                    setState(() {
                      _showLongDivision = val ?? false;
                    });
                  }),
              const Text("Show Long Division Method"),
            ],
          ),
          const SizedBox(height: 18),
          if (_improperToMixedResult != null)
            _improperToMixedResultCard(_improperToMixedResult!, theme),
        ],
      ),
    );
  }

  Widget _improperToMixedResultCard(ImproperToMixedResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? "Invalid input.",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: result.output.numerator == 0
                    ? Text(
                  "${result.output.whole}",
                  style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold),
                )
                    : MixedNumberText(
                  whole: result.output.whole,
                  numerator: result.output.numerator,
                  denominator: result.output.denominator,
                  fontSize: 32,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            if (!_showLongDivision) ...[
              Text("Workings (Decompose & Split):",
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.workingsDecompose.map((line) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(line, style: theme.textTheme.bodySmall),
                    )).toList(),
              ),
              const SizedBox(height: 10),
              Text("Step-by-step Explanation:",
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ...result.stepsDecomposeMethod.map((e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(e, style: theme.textTheme.bodySmall),
              )),
            ],
            if (_showLongDivision) ...[
              Text("Workings (Long Division):",
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.workingsLongDivision.map((line) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(line, style: theme.textTheme.bodySmall),
                    )).toList(),
              ),
              const SizedBox(height: 10),
              Text("Step-by-step Explanation:",
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ...result.stepsLongDivision.map((e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(e, style: theme.textTheme.bodySmall),
              )),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mixedWholeController.dispose();
    _mixedNumeratorController.dispose();
    _mixedDenominatorController.dispose();
    _improperNumeratorController.dispose();
    _improperDenominatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixed Numbers & Improper Fractions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: Text("Mixed → Improper")),
            Tab(child: Text("Improper → Mixed")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _mixedToImproperSection(context),
          _improperToMixedSection(context),
        ],
      ),
    );
  }
}