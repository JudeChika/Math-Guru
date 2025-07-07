import 'package:flutter/material.dart';
import 'place_value_logic.dart';
import 'place_value_conversion_step.dart';

class PlaceValueScreen extends StatefulWidget {
  const PlaceValueScreen({super.key});

  @override
  State<PlaceValueScreen> createState() => _PlaceValueScreenState();
}

class _PlaceValueScreenState extends State<PlaceValueScreen> {
  final _numbersController = TextEditingController();
  int? _selectedIntIndex;
  int? _selectedDecIndex;

  List<int> _integerDigits = [];
  List<int> _decimalDigits = [];
  List<Map<String, dynamic>> _tableRows = [];
  List<PlaceValueConversionStep> _parseSteps = [];
  List<PlaceValueConversionStep> _mappingSteps = [];

  Map<String, dynamic>? _selectedPlaceValueResult;
  List<PlaceValueConversionStep> _placeValueSteps = [];
  bool _isValidInput = true;

  void _processInput() {
    setState(() {
      _selectedIntIndex = null;
      _selectedDecIndex = null;
      _selectedPlaceValueResult = null;
      final parseResult = PlaceValueLogic.parseDigits(_numbersController.text);
      _integerDigits = parseResult.integerDigits;
      _decimalDigits = parseResult.decimalDigits;
      _parseSteps = parseResult.steps;
      _isValidInput = parseResult.valid;
      if (_isValidInput) {
        final mapResult = PlaceValueLogic.mapDigitsToCategories(_integerDigits, _decimalDigits);
        _tableRows = mapResult.tableRows;
        _mappingSteps = mapResult.steps;
      } else {
        _tableRows = [];
        _mappingSteps = [];
      }
    });
  }

  void _findPlaceValue(int index, bool isDecimal) {
    setState(() {
      if (isDecimal) {
        _selectedDecIndex = index;
        _selectedIntIndex = null;
      } else {
        _selectedIntIndex = index;
        _selectedDecIndex = null;
      }
      final pvResult = PlaceValueLogic.findPlaceValue(
          _integerDigits, _decimalDigits, index, isDecimal);
      _selectedPlaceValueResult = pvResult.result;
      _placeValueSteps = pvResult.steps;
    });
  }

  // Patch: Helper to format decimal place values based on category label
  String formatDecimalPlaceValue(num value, String categoryLabel) {
    final decimalPlaces = {
      'Tenth': 1,
      'Hundredth': 2,
      'Thousandth': 3,
      'Ten Thousandth': 4,
      'Hundred Thousandth': 5,
      'Millionth': 6,
      'Ten Millionth': 7,
      'Hundred Millionth': 8,
      'Billionth': 9,
    }[categoryLabel];
    if (decimalPlaces != null) {
      return value.toStringAsFixed(decimalPlaces);
    }
    // fallback: display with up to 12 decimal places, trimmed
    return value.toStringAsFixed(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _categoryTable(ThemeData theme) {
    if (_integerDigits.isEmpty && _decimalDigits.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Digit')),
          DataColumn(label: Text('Part')),
          DataColumn(label: Text('Position')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Place Value')),
        ],
        rows: [
          // Integer part
          for (int i = 0; i < _integerDigits.length; i++)
            DataRow(
              selected: _selectedIntIndex == i,
              color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => _selectedIntIndex == i
                    ? Colors.deepPurple.shade50
                    : Colors.grey.shade50,
              ),
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: () => _findPlaceValue(i, false),
                    child: Text(
                      '${_tableRows[i]['digit']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: _selectedIntIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedIntIndex == i
                            ? Colors.deepPurple
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(const Text('Integer')),
                DataCell(Text('${_tableRows[i]['position']}')),
                DataCell(Text('${_tableRows[i]['category']}')),
                DataCell(Text(
                    _tableRows[i]['placeValue'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ","))),
              ],
            ),
          if (_decimalDigits.isNotEmpty)
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Center(child: Text('')), placeholder: true),
                const DataCell(Center(child: Text('.')), placeholder: true),
              ],
            ),
          // Decimal part
          for (int j = 0; j < _decimalDigits.length; j++)
            DataRow(
              selected: _selectedDecIndex == j,
              color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => _selectedDecIndex == j
                    ? Colors.orange.shade50
                    : Colors.grey.shade50,
              ),
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: () => _findPlaceValue(j, true),
                    child: Text(
                      '${_tableRows[_integerDigits.length + j]['digit']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: _selectedDecIndex == j
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedDecIndex == j
                            ? Colors.orange
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(const Text('Decimal')),
                DataCell(Text('${_tableRows[_integerDigits.length + j]['position']}')),
                DataCell(Text('${_tableRows[_integerDigits.length + j]['category']}')),
                DataCell(
                  Builder(
                    builder: (context) {
                      final row = _tableRows[_integerDigits.length + j];
                      final categoryLabel = row['category'] as String? ?? '';
                      final pv = row['placeValue'] as num;
                      return Text(formatDecimalPlaceValue(pv, categoryLabel));
                    },
                  ),
                ),
              ],
            ),
        ],
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        columnSpacing: 18,
        dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
      ),
    );
  }

  Widget _stepsList(List<PlaceValueConversionStep> steps, bool valid) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: valid
            ? Theme.of(context).cardColor.withOpacity(0.97)
            : Colors.red.shade50,
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade50,
            child: Text('${idx + 1}',
                style: const TextStyle(color: Colors.deepPurple)),
          ),
          title: Text(steps[idx].description,
              style: Theme.of(context).textTheme.bodySmall),
          subtitle: steps[idx].resultSoFar != null
              ? Text(
            "Result so far: ${steps[idx].resultSoFar}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.purple.shade800,
              fontWeight: FontWeight.w600,
            ),
          )
              : null,
        ),
      ),
    );
  }

  Widget _placeValueResultWidget(Map<String, dynamic> result, ThemeData theme) {
    // Patch: format decimal place value
    String pvString;
    if (result['isDecimal'] == true) {
      pvString = formatDecimalPlaceValue(result['placeValue'] as num, result['category'] as String? ?? '');
    } else {
      pvString = (result['placeValue'] as num).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ",");
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'The place value of ${result['digit']} is ${result['category']} (${result['digit']} × ${result['categoryValue']} = $pvString)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Value'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter a number (whole or decimal, e.g.: 3570412.6871 or 3 5 7 0 4 1 2 . 6 8 7 1):",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numbersController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "e.g. 3570412.6871",
                      ),
                      onSubmitted: (_) => _processInput(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _processInput,
                    child: const Text("Categorize"),
                  )
                ],
              ),
              const SizedBox(height: 18),
              if (_isValidInput && (_integerDigits.isNotEmpty || _decimalDigits.isNotEmpty))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Digit Category Table:",
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    _categoryTable(theme),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Tap any digit to get its place value.",
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              if (_selectedPlaceValueResult != null)
                _placeValueResultWidget(_selectedPlaceValueResult!, theme),
              const SizedBox(height: 18),
              if (_parseSteps.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Step-by-step parsing:",
                        style: theme.textTheme.bodyMedium),
                    _stepsList(_parseSteps, _isValidInput),
                  ],
                ),
              const SizedBox(height: 18),
              if (_mappingSteps.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Step-by-step categorization:",
                        style: theme.textTheme.bodyMedium),
                    _stepsList(_mappingSteps, _isValidInput),
                  ],
                ),
              const SizedBox(height: 18),
              if (_selectedPlaceValueResult != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Step-by-step place value solution:",
                        style: theme.textTheme.bodyMedium),
                    _stepsList(_placeValueSteps, true),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}