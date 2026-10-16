import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'reading_tabulated_data_logic.dart';
import 'reading_tabulated_data_models.dart';

/// Strongly-typed controller pair for a single 2D table row, replacing raw Map<String, TextEditingController>.
class _RowControllerPair {
  final TextEditingController nameCtrl;
  final TextEditingController valuesCtrl;

  _RowControllerPair({String name = '', String values = ''})
      : nameCtrl = TextEditingController(text: name),
        valuesCtrl = TextEditingController(text: values);

  TableRowInput toModel() => TableRowInput(
    rowName: nameCtrl.text,
    valuesCsv: valuesCtrl.text,
  );

  void dispose() {
    nameCtrl.dispose();
    valuesCtrl.dispose();
  }
}

class ReadingTabulatedDataScreen extends StatefulWidget {
  const ReadingTabulatedDataScreen({super.key});

  @override
  State<ReadingTabulatedDataScreen> createState() =>
      _ReadingTabulatedDataScreenState();
}

class _ReadingTabulatedDataScreenState
    extends State<ReadingTabulatedDataScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: 2D Table Builder
  int _analysisMode = 0; // 0: Cross-Ref, 1: Totals & Trends, 2: Schedule, 3: Pie Chart

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Table Builder Controllers
  final TextEditingController _tableTitleCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _colHeadersCtrl = TextEditingController();
  final List<_RowControllerPair> _rowCtrls = [];

  // Mode 0 & Mode 3 Selector State
  int _targetRowIdx = 0;
  int _targetColIdx = 0;
  final TextEditingController _exactSearchCtrl = TextEditingController();
  bool _pieByColumn = true;
  int _pieTargetIdx = 0;

  TabulatedDataResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void initState() {
    super.initState();
    _loadPreset(0, autoSolve: false);
  }

  @override
  void dispose() {
    _aiController.dispose();
    _tableTitleCtrl.dispose();
    _unitCtrl.dispose();
    _colHeadersCtrl.dispose();
    _clearAndDisposeRows();
    _exactSearchCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _clearAndDisposeRows() {
    for (final row in _rowCtrls) {
      row.dispose();
    }
    _rowCtrls.clear();
  }

  void _addRow({String name = "", String values = ""}) {
    setState(() {
      _rowCtrls.add(_RowControllerPair(name: name, values: values));
    });
  }

  void _removeRow(int index) {
    if (_rowCtrls.length <= 1) return;
    setState(() {
      _rowCtrls[index].dispose();
      _rowCtrls.removeAt(index);
      if (_targetRowIdx >= _rowCtrls.length) {
        _targetRowIdx = _rowCtrls.length - 1;
      }
      if (!_pieByColumn && _pieTargetIdx >= _rowCtrls.length) {
        _pieTargetIdx = _rowCtrls.length - 1;
      }
    });
  }

  /// Loads any of the textbook presets from [ReadingTabulatedDataLogic.textbookPresets].
  void _loadPreset(int presetIndex, {bool autoSolve = true}) {
    final TablePreset preset =
    ReadingTabulatedDataLogic.textbookPresets[presetIndex];
    _clearAndDisposeRows();

    setState(() {
      _tableTitleCtrl.text = preset.tableTitle;
      _unitCtrl.text = preset.unit;
      _colHeadersCtrl.text = preset.colHeadersCsv;
      for (final row in preset.rows) {
        _rowCtrls.add(
          _RowControllerPair(name: row.rowName, values: row.valuesCsv),
        );
      }
      _analysisMode = preset.defaultAnalysisMode;
      _targetRowIdx = preset.defaultTargetRow;
      _targetColIdx = preset.defaultTargetCol;
      _exactSearchCtrl.text = preset.defaultExactSearch;
      _pieByColumn = preset.defaultPieByColumn;
      _pieTargetIdx = preset.defaultPieTargetIdx;
    });

    if (autoSolve) {
      _solveManual();
    }
  }

  List<String> _getLiveDecodedColumns() {
    final List<String> raw = _colHeadersCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (raw.isEmpty) return ["Col 1"];
    return ReadingTabulatedDataLogic.decodeColumnHeaders(raw);
  }

  List<String> _getLiveRowNames() {
    if (_rowCtrls.isEmpty) return ["Row 1"];
    return List.generate(_rowCtrls.length, (i) {
      final String txt = _rowCtrls[i].nameCtrl.text.trim();
      return txt.isEmpty ? "Row ${i + 1}" : txt;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final String inputText = _aiController.text.trim();

    if (inputText.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a question or upload a table image.')),
      );
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null;
    });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.8-flash', apiKey: apiKey);

      final promptText = '''
      You are a strict JSON data extractor for JSS2 Section 18-1: Reading Tabulated Data.
      Analyze the provided statistical table image or word problem and extract the 2D table structure and analysis mode:

      - "analysisMode":
        0 for Cross-Reference Lookup, Highest/Lowest extremes, or finding zero/exact values.
        1 for Totals, Averages (Means), and Trend/Improvement over time.
        2 for Schedule / Shaded Planning Charts where shaded boxes = 1 and empty boxes = 0.
        3 for Converting a table column or row into Pie Chart sector angles.

      RULES:
      1. Return ONLY a valid JSON object. No markdown, no explanations.
      2. Do NOT include "Total" or "Average" summary rows as data rows.
      3. For shaded schedule grids, represent shaded cells as 1 and unshaded cells as 0.
      4. Set "targetRowIdx" and "targetColIdx" (0-based integers) to the row/column asked in the user's question.

      JSON FORMAT:
      {
        "analysisMode": 0,
        "tableTitle": "Mean monthly rainfall",
        "unit": "mm",
        "colHeaders": "J, F, M, A, M, J, J, A, S, O, N, D",
        "rows": [
          {"name": "Sokoto", "values": "0, 0, 0, 10, 48, 91, 155, 249, 145, 15, 15, 0"}
        ],
        "targetRowIdx": 0,
        "targetColIdx": 0,
        "exactSearch": "",
        "pieByColumn": true,
        "pieTargetIdx": 0
      }

      User Prompt: "$inputText"
      ''';

      final List<Part> parts = [TextPart(promptText)];
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        parts.add(DataPart('image/jpeg', bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      final String rawOutput = (response.text ?? '')
          .trim()
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '')
          .replaceAll(RegExp(r'\n```$'), '')
          .trim();

      final Map<String, dynamic> jsonMap = json.decode(rawOutput);
      if (!mounted) return;

      _clearAndDisposeRows();
      setState(() {
        _analysisMode = ((jsonMap['analysisMode'] as num?)?.toInt() ?? 0).clamp(0, 3);
        _tableTitleCtrl.text =
            jsonMap['tableTitle']?.toString() ?? 'Statistical Table';
        _unitCtrl.text = jsonMap['unit']?.toString() ?? '';
        _colHeadersCtrl.text =
            jsonMap['colHeaders']?.toString() ?? 'Col 1, Col 2';

        final List rowsData = jsonMap['rows'] as List? ?? [];
        for (final r in rowsData) {
          _rowCtrls.add(
            _RowControllerPair(
              name: r['name']?.toString() ?? '',
              values: r['values']?.toString() ?? '',
            ),
          );
        }
        if (_rowCtrls.isEmpty) {
          _rowCtrls.add(_RowControllerPair(name: "Row 1", values: "10, 20"));
        }

        _targetRowIdx =
            int.tryParse(jsonMap['targetRowIdx']?.toString() ?? '0') ?? 0;
        _targetColIdx =
            int.tryParse(jsonMap['targetColIdx']?.toString() ?? '0') ?? 0;
        _exactSearchCtrl.text = jsonMap['exactSearch']?.toString() ?? '';
        _pieByColumn = jsonMap['pieByColumn'] == true;
        _pieTargetIdx =
            int.tryParse(jsonMap['pieTargetIdx']?.toString() ?? '0') ?? 0;
        _inputMode = 1;
      });

      _solveManual();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'AI extraction failed. Please select a preset or enter the table in the Manual Builder.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAI = false);
      }
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = ReadingTabulatedDataLogic.analyzeTable(
        analysisMode: _analysisMode,
        tableTitle: _tableTitleCtrl.text,
        unitStr: _unitCtrl.text,
        colHeadersCsv: _colHeadersCtrl.text,
        rowsInput: _rowCtrls.map((r) => r.toModel()).toList(),
        targetRowIdx: _targetRowIdx,
        targetColIdx: _targetColIdx,
        exactSearchStr: _exactSearchCtrl.text,
        pieByColumn: _pieByColumn,
        pieTargetIndex: _pieTargetIdx,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _canvasTransformController.value = Matrix4.identity();
      }
    });
  }

  Widget _buildSmallField(
      TextEditingController controller,
      String label, {
        String? hint,
        ValueChanged<String>? onChanged,
      }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Reusable styled dropdown to eliminate repetitive container boilerplate.
  Widget _buildStyledDropdown({
    required int value,
    required List<String> labels,
    required String prefix,
    required ValueChanged<int> onSelected,
  }) {
    final int safeValue = value.clamp(0, math.max(0, labels.length - 1));
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: safeValue,
          isExpanded: true,
          items: List.generate(labels.length, (i) {
            return DropdownMenuItem<int>(
              value: i,
              child: Text(
                "$prefix: ${labels[i]}",
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            );
          }),
          onChanged: (int? v) {
            if (v != null) onSelected(v);
          },
        ),
      ),
    );
  }

  Widget _buildAiVisionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.table_view, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Snap a photo of any statistical table or planning schedule from Chapter 18 (Exercises 18a & 18b) and type the question you want answered!",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text("✅ Table Image Attached",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  child:
                  const Text("Remove", style: TextStyle(color: Colors.red)),
                )
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _aiController,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Question or Table Description",
            hintText:
            "e.g. Find the average rainfall for Ibadan in September, and name the month(s) with the lowest rainfall for Sokoto...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingAI)
          const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple))
        else
          ElevatedButton.icon(
            onPressed: _solveWithAI,
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text("Extract Table & Analyze",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetBar() {
    const presets = ReadingTabulatedDataLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick-Load Textbook Tables (Optional Shortcut):",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 13)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(presets.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.table_chart,
                      size: 16, color: Colors.deepPurple),
                  label: Text(
                    presets[index].chipLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.deepPurple),
                  ),
                  backgroundColor: Colors.deepPurple.shade50,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () => _loadPreset(index),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTableRowsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text("2. Table Rows (Heading & Comma-Separated Values):",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
            TextButton.icon(
              onPressed: () => _addRow(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Row"),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(_rowCtrls.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSmallField(
                        _rowCtrls[index].nameCtrl,
                        "Row ${index + 1} Name",
                        hint: "e.g. Ibadan",
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: _buildSmallField(
                        _rowCtrls[index].valuesCtrl,
                        "Row Values (comma-separated)",
                        hint: "e.g. 10, 23, 89, 137...",
                      ),
                    ),
                    if (_rowCtrls.length > 1)
                      IconButton(
                        icon:
                        const Icon(Icons.remove_circle, color: Colors.red),
                        padding: const EdgeInsets.only(left: 6),
                        constraints: const BoxConstraints(),
                        onPressed: () => _removeRow(index),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSubModeControls(List<String> liveRows, List<String> liveCols) {
    if (_analysisMode == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Interactive Cross-Reference Selector:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStyledDropdown(
                    value: _targetRowIdx,
                    labels: liveRows,
                    prefix: "Row",
                    onSelected: (v) {
                      setState(() => _targetRowIdx = v);
                      if (_result != null) _solveManual();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStyledDropdown(
                    value: _targetColIdx,
                    labels: liveCols,
                    prefix: "Col",
                    onSelected: (v) {
                      setState(() => _targetColIdx = v);
                      if (_result != null) _solveManual();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSmallField(
              _exactSearchCtrl,
              "Find Exact Number in Table (Optional, e.g. 0)",
              hint: "e.g. 0 for 'costs no money'",
            ),
          ],
        ),
      );
    }

    if (_analysisMode == 3) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Column or Row to Convert into a 360° Pie Chart:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _pieByColumn,
                    children: const {
                      true: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("By Column",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      false: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("By Row",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    },
                    onValueChanged: (bool? val) {
                      if (val != null) {
                        setState(() {
                          _pieByColumn = val;
                          _pieTargetIdx = 0;
                        });
                      }
                    },
                    thumbColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStyledDropdown(
                    value: _pieTargetIdx,
                    labels: _pieByColumn ? liveCols : liveRows,
                    prefix: _pieByColumn ? "Col" : "Row",
                    onSelected: (v) {
                      setState(() => _pieTargetIdx = v);
                      if (_result != null) _solveManual();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputSection() {
    final List<String> liveCols = _getLiveDecodedColumns();
    final List<String> liveRows = _getLiveRowNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("📷 AI Vision / Question",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("🛠️ 2D Table Builder",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) setState(() => _inputMode = value);
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),
        if (_inputMode == 0)
          _buildAiVisionTab()
        else ...[
          _buildPresetBar(),
          const SizedBox(height: 16),
          const Text("1. Table Title & Column Headings:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildSmallField(
                  _tableTitleCtrl,
                  "Table Title",
                  hint: "e.g. Mean monthly rainfall",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSmallField(
                  _unitCtrl,
                  "Unit",
                  hint: "e.g. mm, %",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSmallField(
            _colHeadersCtrl,
            "Column Headings (Comma-Separated)",
            hint: "e.g. J, F, M, A, M, J, J, A, S, O, N, D",
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildTableRowsEditor(),
          const SizedBox(height: 18),
          const Text("3. Select Analysis Mode:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _analysisMode,
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Cross-Ref\n& Extremes",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Totals, Means\n& Trends",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Schedule\nChart (1/0)",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                3: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Table to\nPie Chart",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              },
              onValueChanged: (int? val) {
                if (val != null) setState(() => _analysisMode = val);
              },
              thumbColor: Colors.deepPurple.shade100,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 14),
          _buildSubModeControls(liveRows, liveCols),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.analytics, color: Colors.white),
            label: const Text("Read & Interpret Table",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Invalid table input.",
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final int numCols = _result!.decodedColHeaders.length;
    final int numRows = _result!.rowHeaders.length;

    final double gridWidth = 170.0 + (numCols * 76.0);
    final double extraPieWidth = _result!.analysisMode == 3 ? 340.0 : 0.0;
    final double canvasWidth =
    math.max(screenWidth, gridWidth + extraPieWidth + 48.0);
    final double canvasHeight = math.max(
      340.0,
      130.0 +
          ((numRows + 1) * 44.0) +
          (_result!.analysisMode == 3 ? 60.0 : 0.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Interactive Cross-Reference & Table Visualizer:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 18)),
            ),
            SizedBox(width: 8),
            Text("💡 Pan & Zoom",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 360,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _canvasTransformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(150),
              minScale: 0.35,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: TabulatedDataPainter(result: _result!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text("2. Key Findings & Final Answers:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAnswers.entries.map((entry) {
            final bool isLatexAngle = entry.value.contains('^\\circ');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  isLatexAngle
                      ? Math.tex(
                    entry.value,
                    textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  )
                      : Text(
                    entry.value,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text("3. Mathematical Workings:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in _result!.workingsLaTeX)
                  if (line.isEmpty)
                    const SizedBox(height: 14)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          line,
                          textStyle: const TextStyle(
                              fontSize: 17, color: Colors.deepPurple),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text("4. Step-by-Step Breakdown:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) {
          final List<String> mathLines = e.value.mathLaTeX
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                foregroundColor: Colors.deepPurple,
                child: Text('${e.key + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(e.value.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    e.value.description,
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.45),
                  ),
                  if (mathLines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final mLine in mathLines)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 4.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  mLine,
                                  textStyle: const TextStyle(
                                      fontSize: 16.5,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Tabulated Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(),
          ],
        ),
      ),
    );
  }
}

class TabulatedDataPainter extends CustomPainter {
  final TabulatedDataResult result;

  TabulatedDataPainter({required this.result});

  String _fmt(double v) =>
      ReadingTabulatedDataLogic.formatNumber(v, maxDecimals: 1);

  @override
  void paint(Canvas canvas, Size size) {
    const double startX = 24.0;
    const double startY = 54.0;
    const double rowHeaderW = 155.0;
    const double colW = 74.0;
    const double cellH = 38.0;

    final int numRows = result.rowHeaders.length;
    final int numCols = result.decodedColHeaders.length;
    final double tableWidth = rowHeaderW + (numCols * colW);

    // 1. Draw Title Banner
    final String titleBanner = result.unit.isEmpty
        ? result.tableTitle
        : "${result.tableTitle} (${result.unit})";
    _drawText(
      canvas,
      titleBanner,
      startX + tableWidth / 2,
      24,
      fontSize: 15,
      isBold: true,
      color: Colors.deepPurple,
    );

    // 2. Draw Column Headers Row
    final Paint headerPaint = Paint()..color = Colors.green.shade700;
    final Paint gridBorderPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const Rect topLeftRect = Rect.fromLTWH(startX, startY, rowHeaderW, cellH);
    canvas.drawRect(topLeftRect, headerPaint);
    canvas.drawRect(topLeftRect, gridBorderPaint);
    _drawText(
      canvas,
      "Category / Period",
      startX + rowHeaderW / 2,
      startY + cellH / 2,
      fontSize: 12,
      isBold: true,
      color: Colors.white,
    );

    for (int c = 0; c < numCols; c++) {
      final double cx = startX + rowHeaderW + (c * colW);
      final Rect cRect = Rect.fromLTWH(cx, startY, colW, cellH);
      final bool isSelectedCol =
          result.analysisMode == 0 && c == result.targetColIndex;

      canvas.drawRect(
        cRect,
        Paint()
          ..color = isSelectedCol
              ? Colors.deepPurple.shade700
              : Colors.green.shade700,
      );
      canvas.drawRect(cRect, gridBorderPaint);

      String colLbl = result.decodedColHeaders[c];
      if (colLbl.length > 9) colLbl = colLbl.substring(0, 8);
      _drawText(
        canvas,
        colLbl,
        cx + colW / 2,
        startY + cellH / 2,
        fontSize: 11.5,
        isBold: true,
        color: Colors.white,
      );
    }

    // 3. Draw Data Rows + Cross-Reference Beams / Schedule Shading
    for (int r = 0; r < numRows; r++) {
      final double ry = startY + ((r + 1) * cellH);
      final bool isSelectedRow =
          result.analysisMode == 0 && r == result.targetRowIndex;

      final Rect rHeadRect = Rect.fromLTWH(startX, ry, rowHeaderW, cellH);
      canvas.drawRect(
        rHeadRect,
        Paint()
          ..color = isSelectedRow
              ? Colors.deepPurple.shade100
              : Colors.green.shade50,
      );
      canvas.drawRect(rHeadRect, gridBorderPaint);

      String rLbl = result.rowHeaders[r];
      if (rLbl.length > 20) rLbl = "${rLbl.substring(0, 18)}...";
      _drawText(
        canvas,
        rLbl,
        startX + 10,
        ry + cellH / 2,
        fontSize: 12,
        isBold: true,
        color: isSelectedRow ? Colors.deepPurple.shade900 : Colors.black87,
        alignLeft: true,
      );

      final double rMax = result.matrix[r].reduce(math.max);
      final double rMin = result.matrix[r].reduce(math.min);

      for (int c = 0; c < numCols; c++) {
        final double cx = startX + rowHeaderW + (c * colW);
        final Rect cellRect = Rect.fromLTWH(cx, ry, colW, cellH);
        final double val = result.matrix[r][c];

        final bool isSelectedCol =
            result.analysisMode == 0 && c == result.targetColIndex;
        final bool isCrossIntersection = isSelectedRow && isSelectedCol;

        Color cellBg = Colors.white;
        Color textColor = Colors.black87;
        bool boldCell = false;

        if (result.analysisMode == 2) {
          if (val > 0) {
            cellBg = Colors.green.shade400;
            textColor = Colors.white;
            boldCell = true;
          } else {
            cellBg = Colors.grey.shade100;
            textColor = Colors.grey.shade500;
          }
        } else if (isCrossIntersection) {
          cellBg = Colors.green.shade600;
          textColor = Colors.white;
          boldCell = true;
        } else if (isSelectedRow || isSelectedCol) {
          cellBg = Colors.deepPurple.shade50;
          textColor = Colors.deepPurple.shade900;
          boldCell = true;
        } else if (result.analysisMode == 0 && (val - rMax).abs() < 1e-9) {
          cellBg = Colors.blue.shade50;
        } else if (result.analysisMode == 0 && (val - rMin).abs() < 1e-9) {
          cellBg = Colors.orange.shade50;
        }

        canvas.drawRect(cellRect, Paint()..color = cellBg);
        canvas.drawRect(cellRect, gridBorderPaint);

        if (isCrossIntersection) {
          canvas.drawRect(
            cellRect.deflate(1.5),
            Paint()
              ..color = Colors.green.shade900
              ..strokeWidth = 2.5
              ..style = PaintingStyle.stroke,
          );
        }

        final String cellText = result.analysisMode == 2
            ? (val > 0 ? "✓ (${_fmt(val)})" : "—")
            : _fmt(val);

        _drawText(
          canvas,
          cellText,
          cx + colW / 2,
          ry + cellH / 2,
          fontSize: 12,
          isBold: boldCell,
          color: textColor,
        );
      }
    }

    // 4. Legend Footer below the Table
    final double footerY = startY + ((numRows + 1) * cellH) + 22.0;
    if (result.analysisMode == 0) {
      final String rName = result.rowHeaders[result.targetRowIndex];
      final String cName = result.decodedColHeaders[result.targetColIndex];
      final String valStr = _fmt(result.targetValue ?? 0);
      _drawText(
        canvas,
        "Cross-Reference: Row '$rName' × Column '$cName' = $valStr ${result.unit}   |   Blue = Row Max, Orange = Row Min",
        startX + tableWidth / 2,
        footerY,
        fontSize: 12,
        isBold: true,
        color: Colors.deepPurple,
      );
    } else if (result.analysisMode == 2) {
      _drawText(
        canvas,
        "Planning Schedule Key: Green Shaded (✓) = Active / Scheduled Period   |   Grey (—) = Inactive Period",
        startX + tableWidth / 2,
        footerY,
        fontSize: 12,
        isBold: true,
        color: Colors.green.shade800,
      );
    }

    // 5. Mode 3: Draw Proportional 360° Pie Chart to the Right of the Table
    if (result.analysisMode == 3 && result.pieSectors.isNotEmpty) {
      _drawPieChartSection(canvas, startX + tableWidth + 175.0, startY + 135.0);
    }
  }

  void _drawPieChartSection(Canvas canvas, double pieCenterX, double pieCenterY) {
    const double radius = 92.0;

    _drawText(
      canvas,
      "Pie Chart: ${result.pieSourceTitle}",
      pieCenterX,
      24,
      fontSize: 14,
      isBold: true,
      color: Colors.deepPurple,
    );

    final List<Color> palette = [
      Colors.deepPurple.shade500,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.blue.shade600,
      Colors.teal.shade600,
      Colors.pink.shade500,
      Colors.amber.shade700,
      Colors.indigo.shade500,
    ];

    double startAngle = -math.pi / 2;
    final Rect pieRect =
    Rect.fromCircle(center: Offset(pieCenterX, pieCenterY), radius: radius);

    for (int i = 0; i < result.pieSectors.length; i++) {
      final TablePieSector sec = result.pieSectors[i];
      final double sweep = (sec.angleDegrees / 360.0) * 2 * math.pi;
      final Color c = palette[i % palette.length];

      canvas.drawArc(pieRect, startAngle, sweep, true, Paint()..color = c);
      canvas.drawArc(
        pieRect,
        startAngle,
        sweep,
        true,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      if (sec.angleDegrees >= 18) {
        final double midAngle = startAngle + sweep / 2;
        const double labelR = radius * 0.62;
        _drawText(
          canvas,
          "${_fmt(sec.angleDegrees)}°",
          pieCenterX + math.cos(midAngle) * labelR,
          pieCenterY + math.sin(midAngle) * labelR,
          fontSize: 11,
          isBold: true,
          color: Colors.white,
        );
      }

      final double legY = pieCenterY + radius + 24.0 + (i * 22.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pieCenterX - 115, legY - 7, 14, 14),
          const Radius.circular(3),
        ),
        Paint()..color = c,
      );

      String legText =
          "${sec.label}: ${_fmt(sec.value)}${result.unit} (${_fmt(sec.angleDegrees)}°)";
      if (legText.length > 34) legText = "${legText.substring(0, 32)}...";
      _drawText(
        canvas,
        legText,
        pieCenterX - 94,
        legY,
        fontSize: 11.5,
        isBold: true,
        color: Colors.black87,
        alignLeft: true,
      );

      startAngle += sweep;
    }
  }

  void _drawText(
      Canvas canvas,
      String text,
      double x,
      double y, {
        double fontSize = 13,
        bool isBold = false,
        Color color = Colors.black87,
        bool alignLeft = false,
      }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset offset = alignLeft
        ? Offset(x, y - tp.height / 2)
        : Offset(x - tp.width / 2, y - tp.height / 2);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant TabulatedDataPainter oldDelegate) =>
      oldDelegate.result != result;
}