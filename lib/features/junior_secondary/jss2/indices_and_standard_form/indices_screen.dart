import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'indices_logic.dart';
import 'indices_models.dart';

class IndicesAndStandardFormScreen extends StatefulWidget {
  const IndicesAndStandardFormScreen({super.key});

  @override
  State<IndicesAndStandardFormScreen> createState() => _IndicesAndStandardFormScreenState();
}

class _IndicesAndStandardFormScreenState extends State<IndicesAndStandardFormScreen> {
  // Dynamic lists holding an arbitrary number of inputs
  final List<TextEditingController> _termControllers = [TextEditingController(), TextEditingController()];
  final List<FocusNode> _focusNodes = [FocusNode(), FocusNode()];
  final List<String> _selectedOperators = ['×'];

  IndicesResult? _result;
  TextEditingController? _activeController;

  final List<String> _operators = ['+', '-', '×', '÷'];

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  void _setupFocusNodes() {
    for (int i = 0; i < _focusNodes.length; i++) {
      // Remove old listeners to prevent memory leaks if setup is called multiple times
      _focusNodes[i].removeListener(() {});
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) setState(() => _activeController = _termControllers[i]);
      });
    }
    // Set default active controller
    if (_activeController == null || !_termControllers.contains(_activeController)) {
      _activeController = _termControllers.first;
    }
  }

  void _addTerm() {
    setState(() {
      _termControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _selectedOperators.add('×'); // Default to multiplication
      _setupFocusNodes();
    });
  }

  void _removeTerm(int index) {
    if (_termControllers.length > 2) {
      setState(() {
        _termControllers[index].dispose();
        _focusNodes[index].dispose();
        _termControllers.removeAt(index);
        _focusNodes.removeAt(index);

        // Remove the operator associated with this field
        if (index > 0) {
          _selectedOperators.removeAt(index - 1);
        } else {
          _selectedOperators.removeAt(0);
        }

        _activeController = _termControllers.last;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _termControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _insertText(String text) {
    if (_activeController == null) return;
    final currentText = _activeController!.text;
    final selection = _activeController!.selection;

    if (selection.start >= 0) {
      final newText = currentText.replaceRange(selection.start, selection.end, text);
      _activeController!.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _activeController!.text += text;
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<String> terms = _termControllers.map((c) => c.text).toList();

    if (terms.any((t) => t.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all term fields')),
      );
      return;
    }

    setState(() {
      _result = null;
      _result = IndicesSolver.solveExpression(terms, _selectedOperators);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Indices & Standard Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter the expressions to apply the laws of indices. You can add as many terms as you'd like!",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // Dynamic List View of fields
            _buildDynamicTermInputs(),

            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _addTerm,
                icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                label: const Text("Add Another Term", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildMathBtn('^', 'Power'),
                _buildMathBtn('x', 'Base x'),
                _buildMathBtn('y', 'Base y'),
                _buildMathBtn('-', 'Negative'),
                _buildMathBtn('*10^', 'Standard Form'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _solve,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("Solve", style: TextStyle(fontSize: 18))
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicTermInputs() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _termControllers.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedOperators[index - 1],
                        items: _operators.map((String op) {
                          return DropdownMenuItem(
                            value: op,
                            child: Text(op, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedOperators[index - 1] = val);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _termControllers[index],
                      focusNode: _focusNodes[index],
                      decoration: InputDecoration(
                        labelText: "Term ${index + 1}",
                        hintText: index == 0 ? "e.g. 5x^2" : "e.g. 2x^4",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      )
                  ),
                ),
                if (_termControllers.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28),
                      onPressed: () => _removeTerm(index),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Math.tex(
                        _result!.finalAnswerLaTeX,
                        textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                    ),
                  )
              )
          ),
        ),

        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          _formatWorkingLaTeX(i, _result!.steps[i].workingLaTeX),
                          textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontFamily: 'Poppins')
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('${e.key+1}')),
            title: _buildExplanationText(e.value.explanation),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Math.tex(
                    _formatWorkingLaTeX(e.key, e.value.workingLaTeX)
                ),
              ),
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  String _formatWorkingLaTeX(int index, String working) {
    String formatted = index == 0 ? working : '= $working';
    return formatted.replaceAll(')(', ') \\times (');
  }

  Widget _buildExplanationText(String text) {
    final parts = text.split('\$');
    if (parts.length <= 1) {
      return Text(text, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic));
    }

    List<Widget> children = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Math.tex(parts[i], textStyle: const TextStyle(fontSize: 13, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ));
      } else if (parts[i].isNotEmpty) {
        children.add(Text(parts[i], style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Widget _buildMathBtn(String text, String tooltip) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      tooltip: tooltip,
      backgroundColor: Colors.grey.shade200,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () => _insertText(text),
    );
  }
}