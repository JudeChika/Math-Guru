import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'number_line_integer_logic.dart';
import 'number_line_painter.dart';

class NumberLineScreen extends StatefulWidget {
  const NumberLineScreen({super.key});

  @override
  State<NumberLineScreen> createState() => _NumberLineScreenState();
}

class _NumberLineScreenState extends State<NumberLineScreen> {
  final _num1Controller = TextEditingController();
  final _num2Controller = TextEditingController();
  String _operation = '+';
  String? _errorMsg;
  int? _from;
  int? _to;
  int? _result;
  List<String> _explanations = [];

  void _calculate() {
    final from = int.tryParse(_num1Controller.text.trim());
    final second = int.tryParse(_num2Controller.text.trim());

    if (from == null || second == null) {
      setState(() {
        _errorMsg = "Please enter valid integers.";
        _result = null;
        _from = null;
        _to = null;
        _explanations = [];
      });
      return;
    }

    final solution = NumberLineIntegerLogic.compute(from, second, _operation);

    setState(() {
      _errorMsg = null;
      _from = from;
      _to = solution.result;
      _result = solution.result;
      _explanations = solution.explanations;
    });
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Integer Operation on Number Line',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter two integers:",
              style: labelStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _num1Controller,
                    keyboardType: TextInputType.number,
                    style: inputStyle,
                    decoration: InputDecoration(
                      labelText: "Start Integer",
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _operation,
                  items: const [
                    DropdownMenuItem(value: '+', child: Text('+')),
                    DropdownMenuItem(value: '-', child: Text('-')),
                  ],
                  onChanged: (val) {
                    setState(() => _operation = val ?? '+');
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _num2Controller,
                    keyboardType: TextInputType.number,
                    style: inputStyle,
                    decoration: InputDecoration(
                      labelText: "Second Integer",
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                child: const Text("Calculate", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMsg != null)
              Text(
                _errorMsg!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
            if (_result != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Result: $_from $_operation ${_num2Controller.text} = $_result",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Visual Number Line:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.purple.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CustomPaint(
                          size: Size(
                            (_to! - (_from! - 5) + (_from! - 0).abs() + 10) * 40.0,
                            120,
                          ),
                          painter: NumberLinePainter(
                            start: (_from! - (_operation == '+' ? 5 : 8)).clamp(-50, 0),
                            end: (_to! + 5),
                            from: _from!,
                            to: _to!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_explanations.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Step-by-step Explanation:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _explanations.length; i++)
                          Card(
                            color: Colors.purple.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                _explanations[i],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[800],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
