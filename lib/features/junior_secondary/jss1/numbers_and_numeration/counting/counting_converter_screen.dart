import 'package:flutter/material.dart';
import 'counting_converter_logic.dart';
import 'counting_categories.dart';
import 'counting_conversion_step.dart';

class CountingConverterScreen extends StatefulWidget {
  const CountingConverterScreen({super.key});

  @override
  State<CountingConverterScreen> createState() =>
      _CountingConverterScreenState();
}

class _CountingConverterScreenState extends State<CountingConverterScreen>
    with SingleTickerProviderStateMixin {
  final _numberController = TextEditingController();
  final _wordsController = TextEditingController();

  Map<String, int> _categoryMap = {};
  String _inWords = '';
  List<CountingConversionStep> _stepsNumberToWords = [];
  bool _validNumberToWords = true;

  int? _wordsToNumber;
  Map<String, int> _wordsCategoryMap = {};
  List<CountingConversionStep> _stepsWordsToNumber = [];
  bool _validWordsToNumber = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _wordsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _convertNumberToWords() {
    setState(() {
      final result = CountingConverter.numberToCategoriesAndWords(_numberController.text);
      _categoryMap = result.categoryMap;
      _inWords = result.inWords;
      _stepsNumberToWords = result.steps;
      _validNumberToWords = result.valid;
    });
  }

  void _convertWordsToNumber() {
    setState(() {
      final result = CountingConverter.wordsToCategoriesAndNumber(_wordsController.text);
      _wordsToNumber = result.number;
      _wordsCategoryMap = result.categoryMap;
      _stepsWordsToNumber = result.steps;
      _validWordsToNumber = result.valid;
    });
  }

  Widget _categoryTable(Map<String, int> categoryMap) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Value')),
      ],
      rows: [
        for (final cat in countingCategories)
          DataRow(cells: [
            DataCell(Text(cat.label)),
            DataCell(Text('${categoryMap[cat.label] ?? 0}')),
          ])
      ],
      headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
      columnSpacing: 18,
      dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
    );
  }

  Widget _buildNumberToWords(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a number:",
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "e.g. 123456789123",
                    ),
                    onSubmitted: (_) => _convertNumberToWords(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _convertNumberToWords,
                  child: const Text("Convert"),
                )
              ],
            ),
            const SizedBox(height: 18),
            if (_categoryMap.isNotEmpty && _validNumberToWords)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Breakdown by Category:", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  _categoryTable(_categoryMap),
                  const SizedBox(height: 12),
                  Text("Number in Words:", style: theme.textTheme.bodyMedium),
                  Text(
                    _inWords,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.deepPurple, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stepsNumberToWords.length,
              itemBuilder: (context, idx) => Card(
                color: _validNumberToWords
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
                  title: Text(_stepsNumberToWords[idx].description,
                      style: theme.textTheme.bodySmall),
                  subtitle: _stepsNumberToWords[idx].resultSoFar != null
                      ? Text(
                      "Result so far: ${_stepsNumberToWords[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsToNumber(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a number in words:",
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordsController,
                    decoration: const InputDecoration(
                      hintText: "e.g. One Billion Two Hundred Million",
                    ),
                    onSubmitted: (_) => _convertWordsToNumber(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _convertWordsToNumber,
                  child: const Text("Convert"),
                )
              ],
            ),
            const SizedBox(height: 18),
            if (_wordsToNumber != null && _validWordsToNumber)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Breakdown by Category:", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  _categoryTable(_wordsCategoryMap),
                  const SizedBox(height: 12),
                  Text("Number in Digits:", style: theme.textTheme.bodyMedium),
                  Text(
                    '$_wordsToNumber',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
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
              itemCount: _stepsWordsToNumber.length,
              itemBuilder: (context, idx) => Card(
                color: _validWordsToNumber
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
                  title: Text(_stepsWordsToNumber[idx].description,
                      style: theme.textTheme.bodySmall),
                  subtitle: _stepsWordsToNumber[idx].resultSoFar != null
                      ? Text(
                      "Result so far: ${_stepsWordsToNumber[idx].resultSoFar}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                      ))
                      : null,
                ),
              ),
            ),
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
        title: const Text('Counting'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Number → Words"),
            Tab(text: "Words → Number"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNumberToWords(context, theme),
          _buildWordsToNumber(context, theme),
        ],
      ),
    );
  }
}