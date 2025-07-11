import 'package:flutter/material.dart';
import 'models.dart';
import 'fraction_widgets.dart';
import 'mixed_to_improper_logic.dart';
import 'improper_to_mixed_logic.dart';
import 'formatted_workings.dart';
import 'long_division_widget.dart';

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
      final input =
      MixedNumber(whole: whole, numerator: num, denominator: denom);
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

  List<Widget> _mixedToImproperSteps(MixedToImproperResult result, ThemeData theme) {
    final input = result.input;
    final impNum = input.whole * input.denominator + input.numerator;
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 13);

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 1: Multiply ', style: textStyle),
            Text('${input.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' by ', style: textStyle),
            Text('${input.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text('= ', style: textStyle),
            Text('${input.whole * input.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 2: Add the numerator: ', style: textStyle),
            Text('${input.whole * input.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' + ', style: textStyle),
            Text('${input.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' = ', style: textStyle),
            Text('$impNum', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 3: Place the result over the denominator: ', style: textStyle),
            FractionText(numerator: impNum, denominator: input.denominator, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Final Solution: ', style: textStyle),
            Text('${input.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(width: 2),
            FractionText(numerator: input.numerator, denominator: input.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            Text(' = ', style: textStyle),
            FractionText(numerator: impNum, denominator: input.denominator, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ],
        ),
      ),
    ];
  }

  List<Widget> _improperToMixedSteps(ImproperToMixedResult result, ThemeData theme) {
    final input = result.input;
    final output = result.output;
    final prod = output.whole * output.denominator;
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 13);

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 1: Find the largest multiple of ', style: textStyle),
            Text('${input.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' less than or equal to ', style: textStyle),
            Text('${input.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(': ', style: textStyle),
            Text('${output.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' × ', style: textStyle),
            Text('${output.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' = ', style: textStyle),
            Text('$prod', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 2: Write the numerator as a sum: ', style: textStyle),
            Text('${input.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' = ', style: textStyle),
            Text('$prod', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' + ', style: textStyle),
            Text('${output.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 3: Split the fraction: ', style: textStyle),
            FractionText(
              numerator: '$prod + ${output.numerator}',
              denominator: output.denominator,
              fontSize: 14,
              fontWeight: FontWeight.bold, color: Colors.deepPurple,
            ),
            Text(' = ', style: textStyle),
            FractionText(numerator: prod, denominator: output.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            Text(' + ', style: textStyle),
            FractionText(numerator: output.numerator, denominator: output.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 4: Simplify: ', style: textStyle),
            FractionText(numerator: prod, denominator: output.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            Text(' = ', style: textStyle),
            Text('${output.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text('; so ', style: textStyle),
            Text('${output.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            if (output.numerator != 0) ...[
              Text(' + ', style: textStyle),
              FractionText(numerator: output.numerator, denominator: output.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Final Solution: ', style: textStyle),
            FractionText(numerator: input.numerator, denominator: input.denominator, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            Text(' = ', style: textStyle),
            if (output.numerator == 0)
              Text('${output.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple))
            else
              MixedNumberText(
                whole: output.whole,
                numerator: output.numerator,
                denominator: output.denominator,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _improperToMixedLongDivisionSteps(ImproperToMixedResult result, ThemeData theme) {
    final input = result.input;
    final output = result.output;
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 13);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Step 1: Divide numerator by denominator: ', style: textStyle),
            Text('${input.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' ÷ ', style: textStyle),
            Text('${input.denominator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' = ', style: textStyle),
            Text('${output.whole}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(' remainder ', style: textStyle),
            Text('${output.numerator}', style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (output.numerator == 0)
              Text('Step 2: The answer is ${output.whole}.', style: textStyle)
            else ...[
              Text('Step 2: The mixed number is ', style: textStyle),
              MixedNumberText(
                whole: output.whole,
                numerator: output.numerator,
                denominator: output.denominator,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
              ),
            ]
          ],
        ),
      ),
    ];
  }

  Widget _stepsCard(List<Widget> steps, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: theme.cardColor.withOpacity(0.98),
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade50,
            child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple)),
          ),
          title: steps[idx],
        ),
      ),
    );
  }

  Widget _mixedToImproperSection(BuildContext context) {
    final theme = Theme.of(context);
    final r = _mixedToImproperResult;
    final input = r?.input;
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
          if (r != null)
            r.valid
                ? Card(
              color: Colors.green.shade50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FractionText(
                        numerator: r.output.numerator,
                        denominator: r.output.denominator,
                        fontSize: 32,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Workings:",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (input != null)
                      MixedToImproperWorkings(
                        whole: input.whole,
                        numerator: input.numerator,
                        denominator: input.denominator,
                      ),
                    const SizedBox(height: 18),
                    Text("Step-by-step Explanation:",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    _stepsCard(_mixedToImproperSteps(r, theme), theme),
                  ],
                ),
              ),
            )
                : Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  r.error ?? "Invalid input.",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _improperToMixedSection(BuildContext context) {
    final theme = Theme.of(context);
    final r = _improperToMixedResult;
    final num = int.tryParse(_improperNumeratorController.text) ?? 0;
    final denom = int.tryParse(_improperDenominatorController.text) ?? 1;
    final output = r?.output;
    final valid = r?.valid ?? false;

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
          if (r != null)
            valid
                ? Card(
              color: Colors.green.shade50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: output!.numerator == 0
                            ? Text(
                          "${output.whole}",
                          style: theme.textTheme.displayLarge
                              ?.copyWith(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                        )
                            : MixedNumberText(
                          whole: output.whole,
                          numerator: output.numerator,
                          denominator: output.denominator,
                          fontSize: 32,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 16),
                    if (!_showLongDivision) ...[
                      Text("Workings (Decompose & Split):",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ImproperToMixedWorkings(
                        numerator: num,
                        denominator: denom,
                      ),
                      const SizedBox(height: 18),
                      Text("Step-by-step Explanation:",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      _stepsCard(_improperToMixedSteps(r, theme), theme),
                    ],
                    if (_showLongDivision) ...[
                      Text("Workings (Long Division):",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      LongDivisionWidget(
                        numerator: num,
                        denominator: denom,
                      ),
                      const SizedBox(height: 18),
                      Text("Step-by-step Explanation:",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      _stepsCard(_improperToMixedLongDivisionSteps(r, theme), theme),
                    ]
                  ],
                ),
              ),
            )
                : Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  r.error ?? "Invalid input.",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
            ),
        ],
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