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
  int? _selectedIndex;

  List<int> _digits = [];
  List<Map<String, dynamic>> _tableRows = [];
  List<PlaceValueConversionStep> _parseSteps = [];
  List<PlaceValueConversionStep> _mappingSteps = [];

  Map<String, dynamic>? _selectedPlaceValueResult;
  List<PlaceValueConversionStep> _placeValueSteps = [];
  bool _isValidInput = true;

  void _processInput() {
    setState(() {
      _selectedIndex = null;
      _selectedPlaceValueResult = null;
      final parseResult = PlaceValueLogic.parseDigits(_numbersController.text);
      _digits = parseResult.digits;
      _parseSteps = parseResult.steps;
      _isValidInput = parseResult.valid;
      if (_isValidInput) {
        final mapResult = PlaceValueLogic.mapDigitsToCategories(_digits);
        _tableRows = mapResult.tableRows;
        _mappingSteps = mapResult.steps;
      } else {
        _tableRows = [];
        _mappingSteps = [];
      }
    });
  }

  void _findPlaceValue(int index) {
    setState(() {
      _selectedIndex = index;
      final pvResult = PlaceValueLogic.findPlaceValue(_digits, index);
      _selectedPlaceValueResult = pvResult.result;
      _placeValueSteps = pvResult.steps;
    });
  }

  Widget _categoryTable(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Digit')),
          DataColumn(label: Text('Position')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Place Value')),
        ],
        rows: [
          for (int i = 0; i < _tableRows.length; i++)
            DataRow(
              selected: _selectedIndex == i,
              color: MaterialStateProperty.resolveWith<Color?>(
                    (states) => _selectedIndex == i
                    ? Colors.deepPurple.shade50
                    : Colors.grey.shade50,
              ),
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: () => _findPlaceValue(i),
                    child: Text(
                      '${_tableRows[i]['digit']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: _selectedIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedIndex == i
                            ? Colors.deepPurple
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${_tableRows[i]['position']}')),
                DataCell(Text('${_tableRows[i]['category']}')),
                DataCell(Text(
                    '${_tableRows[i]['placeValue'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ",")}')),
              ],
            )
        ],
        headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
        columnSpacing: 18,
        dataRowColor: MaterialStateProperty.all(Colors.grey.shade50),
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
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'The place value of ${result['digit']} is ${result['category']} (${result['digit']} × ${result['categoryValue']} = ${result['placeValue'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ",")})',
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
                "Enter a set of numbers (e.g.: 3570412 or 3 5 7 0 4 1 2):",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numbersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "e.g. 3570412",
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
              if (_isValidInput && _digits.isNotEmpty)
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