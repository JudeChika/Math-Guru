import 'package:flutter/material.dart';
import 'frequency_table_logic.dart';
import 'frequency_table_models.dart';

class FrequencyTableScreen extends StatefulWidget {
  const FrequencyTableScreen({super.key});

  @override
  State<FrequencyTableScreen> createState() => _FrequencyTableScreenState();
}

class _FrequencyTableScreenState extends State<FrequencyTableScreen> {
  final TextEditingController _inputController = TextEditingController();
  FrequencyResult? _result;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter some data.')));
      return;
    }
    setState(() {
      _result = FrequencyTableLogic.processData(_inputController.text);
    });
  }

  Widget _buildDataChip(String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildFrequencyTable(ThemeData theme) {
    if (_result == null || !_result!.valid) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade50),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Data (x)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
            DataColumn(label: Text('Tally', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
            DataColumn(label: Text('Freq (f)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), numeric: true),
          ],
          rows: _result!.tableRows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.value, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: CustomPaint(
                    size: Size(row.frequency * 8.0 + (row.frequency ~/ 5) * 10.0, 24),
                    painter: TallyPainter(count: row.frequency),
                  ),
                ),
              ),
              DataCell(Text(row.frequency.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Frequency Distribution')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter your raw data. We will sort it, count it, and build a frequency distribution table!",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              maxLines: 3,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Raw Data (Separated by commas or spaces)",
                hintText: "e.g. Apple, Banana, Apple OR 5, 3, 4, 5",
                prefixIcon: const Icon(Icons.dataset, color: Colors.deepPurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.table_chart),
              label: const Text("Create Frequency Table", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) ...[
              const SizedBox(height: 32),

              // Rank Order Section
              const Text("1. Rank Order (Sorted Data):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Wrap(
                  children: _result!.sortedData.map((v) => _buildDataChip(v, theme)).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // The Frequency Table
              const Text("2. Frequency Distribution Table:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              _buildFrequencyTable(theme),

              const SizedBox(height: 32),

              // Interpretation Section
              const Text("3. Data Interpretation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _result!.interpretations.map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.insights, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Steps Section
              const Text("4. Step-by-Step Process:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              ..._result!.steps.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.deepPurple,
                    child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(e.value.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(e.value.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4)),
                  ),
                ),
              )),

              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }
}

/// A highly optimized custom painter to draw realistic Tally marks
class TallyPainter extends CustomPainter {
  final int count;

  TallyPainter({required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    int fives = count ~/ 5;
    int ones = count % 5;

    double currentX = 2.0;

    // Draw groups of 5
    for (int i = 0; i < fives; i++) {
      double startX = currentX;
      // 4 vertical lines
      for (int j = 0; j < 4; j++) {
        canvas.drawLine(Offset(currentX, 2), Offset(currentX, 22), paint);
        currentX += 6;
      }
      // 1 diagonal strike-through
      canvas.drawLine(Offset(startX - 2, 20), Offset(currentX - 2, 4), paint);
      currentX += 8; // Spacing before next group
    }

    // Draw remaining ones
    for (int i = 0; i < ones; i++) {
      canvas.drawLine(Offset(currentX, 2), Offset(currentX, 22), paint);
      currentX += 6;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}