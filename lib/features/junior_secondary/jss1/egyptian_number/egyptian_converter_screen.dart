import 'package:flutter/material.dart';
import 'egyptian_symbols.dart';
import 'egyptian_converter_logic.dart';
import 'egyptian_conversion_step.dart';

class EgyptianConverterScreen extends StatefulWidget {
  const EgyptianConverterScreen({super.key});

  @override
  State<EgyptianConverterScreen> createState() => _EgyptianConverterScreenState();
}

class _EgyptianConverterScreenState extends State<EgyptianConverterScreen>
    with SingleTickerProviderStateMixin {
  final _englishController = TextEditingController();
  List<int> _egyptianSymbolCounts =
  List.filled(egyptianSymbols.length, 0); // for Egyptian→English
  List<int> _englishToEgyptianCounts =
  List.filled(egyptianSymbols.length, 0); // for result
  int _egyptianToEnglishResult = 0;
  int _englishToEgyptianInput = 0;
  List<EgyptianConversionStep> _englishToEgyptianSteps = [];
  List<EgyptianConversionStep> _egyptianToEnglishSteps = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _englishController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _convertArabicToEgyptian() {
    setState(() {
      int? number = int.tryParse(_englishController.text.trim());
      if (number == null || number <= 0) {
        _englishToEgyptianCounts = List.filled(egyptianSymbols.length, 0);
        _englishToEgyptianSteps = [
          EgyptianConversionStep(
            description: "Please enter a positive integer (no zero or negative).",
            resultSoFar: '',
          ),
        ];
        _englishToEgyptianInput = 0;
      } else {
        final (counts, steps) = EgyptianConverter.englishToEgyptian(number);
        _englishToEgyptianCounts = counts;
        _englishToEgyptianSteps = steps;
        _englishToEgyptianInput = number;
      }
    });
  }

  void _convertEgyptianToArabic() {
    setState(() {
      final (english, steps) =
      EgyptianConverter.egyptianToEnglish(_egyptianSymbolCounts);
      _egyptianToEnglishResult = english;
      _egyptianToEnglishSteps = steps;
    });
  }

  void _resetEgyptianSymbols() {
    setState(() {
      _egyptianSymbolCounts = List.filled(egyptianSymbols.length, 0);
      _egyptianToEnglishResult = 0;
      _egyptianToEnglishSteps = [];
    });
  }

  Widget _symbolLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 20,
      children: [
        for (final symbol in egyptianSymbols)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(symbol.assetPath, width: 28, height: 28),
              Text("${symbol.value}", style: theme.textTheme.bodySmall),
            ],
          ),
      ],
    );
  }

  Widget _egyptianNumberRow(List<int> counts) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        for (int i = 0; i < counts.length; i++)
          if (counts[i] > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                counts[i],
                    (idx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.asset(
                    egyptianSymbols[i].assetPath,
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildEnglishToEgyptian(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter an English number:",
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _englishController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "e.g. 2543",
                    ),
                    onSubmitted: (_) => _convertArabicToEgyptian(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _convertArabicToEgyptian,
                  child: const Text("Convert"),
                )
              ],
            ),
            const SizedBox(height: 18),
            if (_englishToEgyptianInput > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Egyptian Numeral:", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  _egyptianNumberRow(_englishToEgyptianCounts),
                  const SizedBox(height: 14),
                ],
              ),
            Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _englishToEgyptianSteps.length,
              itemBuilder: (context, idx) => Card(
                color: theme.cardColor.withOpacity(0.97),
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_englishToEgyptianSteps[idx].description, style: theme.textTheme.bodySmall),
                  subtitle: _englishToEgyptianSteps[idx].resultSoFar.isNotEmpty
                      ? Text("Result so far: ${_englishToEgyptianSteps[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Legend:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            _symbolLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEgyptianToArabic(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Build an Egyptian numeral (tap icons to add/remove):",
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (int i = 0; i < egyptianSymbols.length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _egyptianSymbolCounts[i]++;
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                if (_egyptianSymbolCounts[i] > 0) _egyptianSymbolCounts[i]--;
                              });
                            },
                            child: Image.asset(
                              egyptianSymbols[i].assetPath,
                              width: 38,
                              height: 38,
                            ),
                          ),
                          if (_egyptianSymbolCounts[i] > 0)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  '${_egyptianSymbolCounts[i]}',
                                  style: const TextStyle(
                                      color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        egyptianSymbols[i].label,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _convertEgyptianToArabic,
                  child: const Text("Convert"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _resetEgyptianSymbols,
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_egyptianToEnglishResult > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("English Number:", style: theme.textTheme.bodyMedium),
                  Text(
                    '$_egyptianToEnglishResult',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _egyptianToEnglishSteps.length,
              itemBuilder: (context, idx) => Card(
                color: theme.cardColor.withOpacity(0.97),
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_egyptianToEnglishSteps[idx].description, style: theme.textTheme.bodySmall),
                  subtitle: _egyptianToEnglishSteps[idx].resultSoFar.isNotEmpty
                      ? Text("Result so far: ${_egyptianToEnglishSteps[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Legend:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            _symbolLegend(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egyptian Number Converter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "English → Egyptian"),
            Tab(text: "Egyptian → English"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnglishToEgyptian(context, theme),
          _buildEgyptianToArabic(context, theme),
        ],
      ),
    );
  }
}