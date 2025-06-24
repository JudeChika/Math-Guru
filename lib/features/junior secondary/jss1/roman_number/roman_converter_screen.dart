import 'package:flutter/material.dart';
import 'roman_converter_logic.dart';
import 'roman_conversion_step.dart';

class RomanConverterScreen extends StatefulWidget {
  const RomanConverterScreen({super.key});

  @override
  State<RomanConverterScreen> createState() => _RomanConverterScreenState();
}

class _RomanConverterScreenState extends State<RomanConverterScreen> with SingleTickerProviderStateMixin {
  final _englishController = TextEditingController();
  final _romanController = TextEditingController();
  String _englishToRomanResult = '';
  List<RomanConversionStep> _englishToRomanSteps = [];
  String _romanToEnglishResult = '';
  List<RomanConversionStep> _romanToEnglishSteps = [];
  bool _romanToEnglishValid = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _englishController.dispose();
    _romanController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _convertEnglishToRoman() {
    setState(() {
      int? number = int.tryParse(_englishController.text.trim());
      if (number == null) {
        _englishToRomanResult = '';
        _englishToRomanSteps = [
          RomanConversionStep(
            description: "Please enter a valid integer (1-3999).",
            resultSoFar: '',
          ),
        ];
      } else {
        final (roman, steps) = RomanConverter.englishToRoman(number);
        _englishToRomanResult = roman;
        _englishToRomanSteps = steps;
      }
    });
  }

  void _convertRomanToEnglish() {
    setState(() {
      final input = _romanController.text.trim();
      if (input.isEmpty) {
        _romanToEnglishResult = '';
        _romanToEnglishSteps = [
          RomanConversionStep(
            description: "Please enter a Roman numeral (e.g., XLII).",
            resultSoFar: '',
          ),
        ];
        _romanToEnglishValid = false;
      } else {
        final (arabic, steps, isValid) = RomanConverter.romanToEnglish(input);
        _romanToEnglishResult = isValid ? arabic.toString() : '';
        _romanToEnglishSteps = steps;
        _romanToEnglishValid = isValid;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roman Number Converter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "English → Roman"),
            Tab(text: "Roman → English"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnglishToRoman(context, theme),
          _buildRomanToEnglish(context, theme),
        ],
      ),
    );
  }

  Widget _buildEnglishToRoman(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter a number (between 1 to 3999):",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _englishController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "e.g. 1987",
                  ),
                  onSubmitted: (_) => _convertEnglishToRoman(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _convertEnglishToRoman,
                child: const Text("Convert"),
              )
            ],
          ),
          const SizedBox(height: 18),
          if (_englishToRomanResult.isNotEmpty)
            Center(
              child: Column(
                children: [
                  Text("Roman Numeral:", style: theme.textTheme.bodyMedium),
                  Text(
                    _englishToRomanResult,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _englishToRomanSteps.length,
              itemBuilder: (context, idx) => Card(
                color: theme.cardColor.withOpacity(0.98),
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_englishToRomanSteps[idx].description, style: theme.textTheme.bodySmall),
                  subtitle: _englishToRomanSteps[idx].resultSoFar.isNotEmpty
                      ? Text("Result so far: ${_englishToRomanSteps[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRomanToEnglish(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter a Roman numeral (e.g. XLII):",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _romanController,
                  decoration: const InputDecoration(
                    hintText: "e.g. XLII",
                  ),
                  onSubmitted: (_) => _convertRomanToEnglish(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _convertRomanToEnglish,
                child: const Text("Convert"),
              )
            ],
          ),
          const SizedBox(height: 18),
          if (_romanToEnglishResult.isNotEmpty)
            Center(
              child: Column(
                children: [
                  Text("English Number:", style: theme.textTheme.bodyMedium),
                  Text(
                    _romanToEnglishResult,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _romanToEnglishSteps.length,
              itemBuilder: (context, idx) => Card(
                color: _romanToEnglishValid
                    ? theme.cardColor.withOpacity(0.98)
                    : Colors.red.shade50,
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                  title: Text(_romanToEnglishSteps[idx].description, style: theme.textTheme.bodySmall),
                  subtitle: _romanToEnglishSteps[idx].resultSoFar.isNotEmpty
                      ? Text("Result so far: ${_romanToEnglishSteps[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}