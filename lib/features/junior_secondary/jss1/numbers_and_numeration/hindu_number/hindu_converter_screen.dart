import 'package:flutter/material.dart';
import 'hindu_symbols.dart';
import 'hindu_converter_logic.dart';
import 'hindu_conversion_step.dart';

class HinduConverterScreen extends StatefulWidget {
  const HinduConverterScreen({super.key});

  @override
  State<HinduConverterScreen> createState() => _HinduConverterScreenState();
}

class _HinduConverterScreenState extends State<HinduConverterScreen>
    with SingleTickerProviderStateMixin {
  final _englishController = TextEditingController();

  List<String> _englishToHinduAssets = [];
  List<HinduConversionStep> _englishToHinduSteps = [];
  bool _englishToHinduValid = true;

  final List<String> _selectedHinduAssets = [];
  String _hinduToEnglishResult = "";
  List<HinduConversionStep> _hinduToEnglishSteps = [];
  bool _hinduToEnglishValid = true;

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

  void _convertEnglishToHindu() {
    setState(() {
      final (assets, steps, valid) =
      HinduConverter.englishToHindu(_englishController.text);
      _englishToHinduAssets = assets;
      _englishToHinduSteps = steps;
      _englishToHinduValid = valid;
    });
  }

  void _convertHinduToEnglish() {
    setState(() {
      final (result, steps, valid) =
      HinduConverter.hinduToEnglish(_selectedHinduAssets);
      _hinduToEnglishResult = result;
      _hinduToEnglishSteps = steps;
      _hinduToEnglishValid = valid;
    });
  }

  void _resetHinduSymbols() {
    setState(() {
      _selectedHinduAssets.clear();
      _hinduToEnglishResult = "";
      _hinduToEnglishSteps = [];
      _hinduToEnglishValid = true;
    });
  }

  Widget _symbolLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 20,
      children: [
        for (final symbol in hinduSymbols)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(symbol.assetPath, width: 28, height: 28),
              Text("${symbol.digit}", style: theme.textTheme.bodySmall),
            ],
          ),
      ],
    );
  }

  Widget _hinduNumberRow(List<String> assets) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final asset in assets)
          Image.asset(
            asset,
            width: 32,
            height: 32,
          ),
      ],
    );
  }

  Widget _buildEnglishToHindu(BuildContext context, ThemeData theme) {
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
                      hintText: "e.g. 2049",
                    ),
                    onSubmitted: (_) => _convertEnglishToHindu(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _convertEnglishToHindu,
                  child: const Text("Convert"),
                )
              ],
            ),
            const SizedBox(height: 18),
            if (_englishToHinduAssets.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Early Hindu Numeral:", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  _hinduNumberRow(_englishToHinduAssets),
                  const SizedBox(height: 14),
                ],
              ),
            Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _englishToHinduSteps.length,
              itemBuilder: (context, idx) => Card(
                color: _englishToHinduValid
                    ? theme.cardColor.withOpacity(0.97)
                    : Colors.red.shade50,
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}',
                        style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_englishToHinduSteps[idx].description,
                      style: theme.textTheme.bodySmall),
                  subtitle: _englishToHinduSteps[idx].resultSoFar.isNotEmpty
                      ? Text(
                      "Result so far: ${_englishToHinduSteps[idx].resultSoFar}",
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
              child: Text("Legend:",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            _symbolLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHinduToEnglish(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Build an Early Hindu numeral (tap icons to add/remove):",
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (int i = 0; i < hinduSymbols.length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedHinduAssets.add(hinduSymbols[i].assetPath);
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                final idx = _selectedHinduAssets.lastIndexOf(hinduSymbols[i].assetPath);
                                if (idx != -1) _selectedHinduAssets.removeAt(idx);
                              });
                            },
                            child: Image.asset(
                              hinduSymbols[i].assetPath,
                              width: 38,
                              height: 38,
                            ),
                          ),
                          if (_selectedHinduAssets.where((e) => e == hinduSymbols[i].assetPath).isNotEmpty)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  '${_selectedHinduAssets.where((e) => e == hinduSymbols[i].assetPath).length}',
                                  style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        hinduSymbols[i].label,
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
                  onPressed: _convertHinduToEnglish,
                  child: const Text("Convert"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _resetHinduSymbols,
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_hinduToEnglishResult.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("English Number:", style: theme.textTheme.bodyMedium),
                  Text(
                    _hinduToEnglishResult,
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
              itemCount: _hinduToEnglishSteps.length,
              itemBuilder: (context, idx) => Card(
                color: _hinduToEnglishValid
                    ? theme.cardColor.withOpacity(0.97)
                    : Colors.red.shade50,
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}',
                        style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_hinduToEnglishSteps[idx].description,
                      style: theme.textTheme.bodySmall),
                  subtitle: _hinduToEnglishSteps[idx].resultSoFar.isNotEmpty
                      ? Text(
                      "Result so far: ${_hinduToEnglishSteps[idx].resultSoFar}",
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
              child: Text("Legend:",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
        title: const Text('Hindu Number Converter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "English → Hindu"),
            Tab(text: "Hindu → English"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnglishToHindu(context, theme),
          _buildHinduToEnglish(context, theme),
        ],
      ),
    );
  }
}