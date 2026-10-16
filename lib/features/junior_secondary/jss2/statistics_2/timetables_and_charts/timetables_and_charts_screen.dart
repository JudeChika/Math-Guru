import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_guru/features/junior_secondary/jss2/statistics_2/timetables_and_charts/timetables_and_charts.dart';
import 'timetables_and_charts_logic.dart';

class _StopControllerTriplet {
  final TextEditingController stationCtrl;
  final TextEditingController arrCtrl;
  final TextEditingController depCtrl;

  _StopControllerTriplet({
    String station = '',
    String arr = '',
    String dep = '',
  })  : stationCtrl = TextEditingController(text: station),
        arrCtrl = TextEditingController(text: arr),
        depCtrl = TextEditingController(text: dep);

  JourneyStopInput toModel() => JourneyStopInput(
    stationName: stationCtrl.text,
    arrivalTime: arrCtrl.text,
    departureTime: depCtrl.text,
  );

  void dispose() {
    stationCtrl.dispose();
    arrCtrl.dispose();
    depCtrl.dispose();
  }
}

class _SchoolDayControllerPair {
  final TextEditingController dayCtrl;
  final TextEditingController subjectsCtrl;

  _SchoolDayControllerPair({String day = '', String subjects = ''})
      : dayCtrl = TextEditingController(text: day),
        subjectsCtrl = TextEditingController(text: subjects);

  SchoolDayInput toModel() => SchoolDayInput(
    dayName: dayCtrl.text,
    subjectsCsv: subjectsCtrl.text,
  );

  void dispose() {
    dayCtrl.dispose();
    subjectsCtrl.dispose();
  }
}

class TimetablesAndChartsScreen extends StatefulWidget {
  const TimetablesAndChartsScreen({super.key});

  @override
  State<TimetablesAndChartsScreen> createState() =>
      _TimetablesAndChartsScreenState();
}

class _TimetablesAndChartsScreenState extends State<TimetablesAndChartsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _topicMode = 1; // 0: Clock, 1: Journey, 2: School, 3: Distance, 4: Bracket/Target

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Mode 0: 12h/24h Clock & Time Arithmetic
  int _clockSubMode = 0; // 0: Convert List, 1: Elapsed, 2: Add/Sub Duration
  final TextEditingController _clockListCtrl = TextEditingController();
  final TextEditingController _clockStartCtrl = TextEditingController();
  final TextEditingController _clockEndCtrl = TextEditingController();
  final TextEditingController _durHoursCtrl = TextEditingController();
  final TextEditingController _durMinsCtrl = TextEditingController();
  bool _durIsAdd = true;

  // Mode 1: Journey & Flight Timetable
  final TextEditingController _serviceTitleCtrl = TextEditingController();
  final List<_StopControllerTriplet> _stopCtrls = [];
  int _originStopIdx = 0;
  int _destStopIdx = 1;
  final TextEditingController _actualFlightDurCtrl = TextEditingController();
  final TextEditingController _compareLegDurCtrl = TextEditingController();

  // Mode 2: School Timetable
  final TextEditingController _periodSlotsCtrl = TextEditingController();
  final List<_SchoolDayControllerPair> _schoolDayCtrls = [];

  // Mode 3: Triangular Distance Chart & Route Planner
  int _distanceSubMode = 0; // 0: Direct vs Via, 1: Multi-Stop Tour
  int _originCityIdx = 4; // Benin City
  int _destCityIdx = 11; // Kaduna
  int _viaCityIdx = 9; // Ilorin
  final TextEditingController _multiStopRouteCtrl = TextEditingController();

  // Mode 4: Knockout Bracket & Target Chart
  int _chartSubMode = 0; // 0: Knockout Bracket, 1: Target Line Chart
  final TextEditingController _bracketTitleCtrl = TextEditingController();
  List<KnockoutMatchInput> _bracketMatches = [];
  final TextEditingController _targetPlayerCtrl = TextEditingController();
  final TextEditingController _targetChartTitleCtrl = TextEditingController();
  final TextEditingController _targetUnitCtrl = TextEditingController();
  final TextEditingController _targetThresholdCtrl = TextEditingController();
  final TextEditingController _targetLabelsCtrl = TextEditingController();
  final TextEditingController _targetValuesCtrl = TextEditingController();

  TimetableChartResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void initState() {
    super.initState();
    _loadPreset(1, autoSolve: false); // Default to Fig 18.2 Ibadan–Offa Railway
  }

  @override
  void dispose() {
    _aiController.dispose();
    _clockListCtrl.dispose();
    _clockStartCtrl.dispose();
    _clockEndCtrl.dispose();
    _durHoursCtrl.dispose();
    _durMinsCtrl.dispose();
    _serviceTitleCtrl.dispose();
    _clearAndDisposeStops();
    _actualFlightDurCtrl.dispose();
    _compareLegDurCtrl.dispose();
    _periodSlotsCtrl.dispose();
    _clearAndDisposeSchoolDays();
    _multiStopRouteCtrl.dispose();
    _bracketTitleCtrl.dispose();
    _targetPlayerCtrl.dispose();
    _targetChartTitleCtrl.dispose();
    _targetUnitCtrl.dispose();
    _targetThresholdCtrl.dispose();
    _targetLabelsCtrl.dispose();
    _targetValuesCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _clearAndDisposeStops() {
    for (final s in _stopCtrls) {
      s.dispose();
    }
    _stopCtrls.clear();
  }

  void _clearAndDisposeSchoolDays() {
    for (final d in _schoolDayCtrls) {
      d.dispose();
    }
    _schoolDayCtrls.clear();
  }

  void _loadPreset(int index, {bool autoSolve = true}) {
    final TimetableChartPreset p =
    TimetablesAndChartsLogic.textbookPresets[index];

    setState(() {
      _topicMode = p.topicMode;

      if (p.clockListCsv.isNotEmpty) {
        _clockSubMode = p.clockSubMode;
        _clockListCtrl.text = p.clockListCsv;
        _clockStartCtrl.text = p.clockStart;
        _clockEndCtrl.text = p.clockEnd;
        _durHoursCtrl.text = p.durationHours;
        _durMinsCtrl.text = p.durationMins;
        _durIsAdd = p.durationIsAdd;
      }

      if (p.stops.isNotEmpty) {
        _clearAndDisposeStops();
        _serviceTitleCtrl.text = p.serviceTitle;
        for (final stop in p.stops) {
          _stopCtrls.add(_StopControllerTriplet(
            station: stop.stationName,
            arr: stop.arrivalTime,
            dep: stop.departureTime,
          ));
        }
        _originStopIdx = p.originStopIdx;
        _destStopIdx = p.destStopIdx;
        _actualFlightDurCtrl.text = p.actualFlightDuration;
        _compareLegDurCtrl.text = p.compareLegDuration;
      }

      if (p.periodSlotsCsv.isNotEmpty) {
        _clearAndDisposeSchoolDays();
        _periodSlotsCtrl.text = p.periodSlotsCsv;
        for (final d in p.schoolDays) {
          _schoolDayCtrls.add(_SchoolDayControllerPair(
            day: d.dayName,
            subjects: d.subjectsCsv,
          ));
        }
      }

      if (p.multiStopRouteCsv.isNotEmpty) {
        _distanceSubMode = p.distanceSubMode;
        _originCityIdx = p.originCityIdx;
        _destCityIdx = p.destCityIdx;
        _viaCityIdx = p.viaCityIdx;
        _multiStopRouteCtrl.text = p.multiStopRouteCsv;
      }

      if (p.matches.isNotEmpty) {
        _chartSubMode = p.chartSubMode;
        _bracketTitleCtrl.text = p.bracketTitle;
        _bracketMatches = List<KnockoutMatchInput>.from(p.matches);
        _targetPlayerCtrl.text = p.targetPlayerName;
        _targetChartTitleCtrl.text = p.targetChartTitle;
        _targetUnitCtrl.text = p.targetUnit;
        _targetThresholdCtrl.text = p.targetThreshold;
        _targetLabelsCtrl.text = p.targetLabelsCsv;
        _targetValuesCtrl.text = p.targetValuesCsv;
      }
    });

    // Ensure all other modes have sensible defaults if not yet initialized
    if (_clockListCtrl.text.isEmpty) {
      _clockListCtrl.text =
          TimetablesAndChartsLogic.textbookPresets[0].clockListCsv;
    }
    if (_periodSlotsCtrl.text.isEmpty) {
      final schP = TimetablesAndChartsLogic.textbookPresets[4];
      _periodSlotsCtrl.text = schP.periodSlotsCsv;
      for (final d in schP.schoolDays) {
        _schoolDayCtrls.add(_SchoolDayControllerPair(
          day: d.dayName,
          subjects: d.subjectsCsv,
        ));
      }
    }
    if (_multiStopRouteCtrl.text.isEmpty) {
      _multiStopRouteCtrl.text =
          TimetablesAndChartsLogic.textbookPresets[5].multiStopRouteCsv;
    }
    if (_bracketMatches.isEmpty) {
      final brkP = TimetablesAndChartsLogic.textbookPresets[6];
      _bracketTitleCtrl.text = brkP.bracketTitle;
      _bracketMatches = List<KnockoutMatchInput>.from(brkP.matches);
      _targetPlayerCtrl.text = brkP.targetPlayerName;
      _targetChartTitleCtrl.text = brkP.targetChartTitle;
      _targetUnitCtrl.text = brkP.targetUnit;
      _targetThresholdCtrl.text = brkP.targetThreshold;
      _targetLabelsCtrl.text = brkP.targetLabelsCsv;
      _targetValuesCtrl.text = brkP.targetValuesCsv;
    }

    if (autoSolve) {
      _solveManual();
    }
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
            content:
            Text('Please enter a question or upload a timetable/chart image.')),
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
      You are a strict JSON data extractor for JSS2 Section 18-2: Timetables and Charts.
      Classify the user's question or image into one of 5 topicModes:
      - "topicMode": 0 for 12-hour (a.m./p.m.) and 24-hour clock conversions or time addition/subtraction.
      - "topicMode": 1 for Railway, Bus, or Flight Timetables (Arrival 'A' and Departure 'D' times across stations).
      - "topicMode": 2 for School Timetables (period time slots, breaks, and daily subjects).
      - "topicMode": 3 for Triangular Distance Charts between Nigerian cities (Abeokuta, Abuja, Akure, Bauchi, Benin City, Calabar, Enugu, Ibadan, Ikeja, Ilorin, Jos, Kaduna, Kano, Maiduguri, Makurdi, Minna, Owerri, Port Harcourt, Sokoto, Yola).
      - "topicMode": 4 for Knockout Tournament Brackets (chartSubMode: 0) or Target Line Charts like Gbenga's Walking Paces (chartSubMode: 1).

      RULES:
      1. Return ONLY a valid JSON object. No markdown, no explanations.
      2. If a railway timetable has a 'DN' (down) column that reads bottom-to-top (like 202 DN from Offa to Ibadan), list the stations in chronological travel order (Offa -> Oshogbo -> Ibadan).

      JSON FORMAT:
      {
        "topicMode": 1,
        "clockSubMode": 0,
        "clockListCsv": "5.40 a.m., 7.25 p.m.",
        "clockStart": "06:00",
        "clockEnd": "11:30",
        "serviceTitle": "Train 201 UP (Ibadan to Offa)",
        "stops": [
          {"station": "Ibadan", "arr": "", "dep": "6.00 pm"},
          {"station": "Oshogbo", "arr": "9.32 pm", "dep": "9.42 pm"},
          {"station": "Offa", "arr": "11.45 pm", "dep": ""}
        ],
        "originStopIdx": 0,
        "destStopIdx": 2,
        "actualFlightDuration": "",
        "compareLegDuration": "",
        "distanceSubMode": 0,
        "originCity": "Benin City",
        "destCity": "Kaduna",
        "viaCity": "Ilorin",
        "multiStopRouteCsv": "Port Harcourt, Owerri, Enugu, Calabar, Port Harcourt",
        "chartSubMode": 0,
        "targetPlayerName": "Ojo",
        "targetThreshold": "8000",
        "targetLabelsCsv": "S, M, T, W, T, F, S",
        "targetValuesCsv": "10000, 9000, 0, 8000, 7000, 5000, 9000"
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

      setState(() {
        _topicMode =
            ((jsonMap['topicMode'] as num?)?.toInt() ?? 1).clamp(0, 4);

        if (_topicMode == 0) {
          _clockSubMode =
              ((jsonMap['clockSubMode'] as num?)?.toInt() ?? 0).clamp(0, 2);
          if ((jsonMap['clockListCsv']?.toString() ?? '').isNotEmpty) {
            _clockListCtrl.text = jsonMap['clockListCsv'].toString();
          }
          if ((jsonMap['clockStart']?.toString() ?? '').isNotEmpty) {
            _clockStartCtrl.text = jsonMap['clockStart'].toString();
          }
          if ((jsonMap['clockEnd']?.toString() ?? '').isNotEmpty) {
            _clockEndCtrl.text = jsonMap['clockEnd'].toString();
          }
        } else if (_topicMode == 1) {
          _serviceTitleCtrl.text =
              jsonMap['serviceTitle']?.toString() ?? 'Journey Timetable';
          final List stopsData = jsonMap['stops'] as List? ?? [];
          if (stopsData.length >= 2) {
            _clearAndDisposeStops();
            for (final s in stopsData) {
              _stopCtrls.add(_StopControllerTriplet(
                station: s['station']?.toString() ?? '',
                arr: s['arr']?.toString() ?? '',
                dep: s['dep']?.toString() ?? '',
              ));
            }
          }
          _originStopIdx =
              int.tryParse(jsonMap['originStopIdx']?.toString() ?? '0') ?? 0;
          _destStopIdx = int.tryParse(jsonMap['destStopIdx']?.toString() ??
              '${_stopCtrls.length - 1}') ??
              (_stopCtrls.length - 1);
          _actualFlightDurCtrl.text =
              jsonMap['actualFlightDuration']?.toString() ?? '';
          _compareLegDurCtrl.text =
              jsonMap['compareLegDuration']?.toString() ?? '';
        } else if (_topicMode == 3) {
          _distanceSubMode =
              ((jsonMap['distanceSubMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
          final String origC = jsonMap['originCity']?.toString() ?? '';
          final String destC = jsonMap['destCity']?.toString() ?? '';
          final String viaC = jsonMap['viaCity']?.toString() ?? '';
          final int oIdx = TimetablesAndChartsLogic.nigerianCities.indexWhere(
                  (c) => c.toLowerCase().contains(origC.toLowerCase()));
          final int dIdx = TimetablesAndChartsLogic.nigerianCities.indexWhere(
                  (c) => c.toLowerCase().contains(destC.toLowerCase()));
          final int vIdx = TimetablesAndChartsLogic.nigerianCities.indexWhere(
                  (c) => c.toLowerCase().contains(viaC.toLowerCase()));
          if (oIdx != -1) _originCityIdx = oIdx;
          if (dIdx != -1) _destCityIdx = dIdx;
          if (vIdx != -1) _viaCityIdx = vIdx;
          if ((jsonMap['multiStopRouteCsv']?.toString() ?? '').isNotEmpty) {
            _multiStopRouteCtrl.text = jsonMap['multiStopRouteCsv'].toString();
          }
        } else if (_topicMode == 4) {
          _chartSubMode =
              ((jsonMap['chartSubMode'] as num?)?.toInt() ?? 0).clamp(0, 1);
          if ((jsonMap['targetPlayerName']?.toString() ?? '').isNotEmpty) {
            _targetPlayerCtrl.text = jsonMap['targetPlayerName'].toString();
          }
          if ((jsonMap['targetThreshold']?.toString() ?? '').isNotEmpty) {
            _targetThresholdCtrl.text = jsonMap['targetThreshold'].toString();
          }
          if ((jsonMap['targetLabelsCsv']?.toString() ?? '').isNotEmpty) {
            _targetLabelsCtrl.text = jsonMap['targetLabelsCsv'].toString();
          }
          if ((jsonMap['targetValuesCsv']?.toString() ?? '').isNotEmpty) {
            _targetValuesCtrl.text = jsonMap['targetValuesCsv'].toString();
          }
        }
        _inputMode = 1;
      });

      _solveManual();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'AI extraction failed. Please tap a preset chip or enter values in the Manual Builder.'),
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
      if (_topicMode == 0) {
        _result = TimetablesAndChartsLogic.solveClockAndTime(
          subMode: _clockSubMode,
          clockListCsv: _clockListCtrl.text,
          startTimeStr: _clockStartCtrl.text,
          endTimeStr: _clockEndCtrl.text,
          durationHoursStr: _durHoursCtrl.text,
          durationMinsStr: _durMinsCtrl.text,
          isAddDuration: _durIsAdd,
        );
      } else if (_topicMode == 1) {
        _result = TimetablesAndChartsLogic.solveJourneyTimetable(
          serviceTitle: _serviceTitleCtrl.text,
          stops: _stopCtrls.map((s) => s.toModel()).toList(),
          originIdx: _originStopIdx,
          destIdx: _destStopIdx,
          actualFlightDurationStr: _actualFlightDurCtrl.text,
          compareLegDurationStr: _compareLegDurCtrl.text,
        );
      } else if (_topicMode == 2) {
        _result = TimetablesAndChartsLogic.solveSchoolTimetable(
          periodSlotsCsv: _periodSlotsCtrl.text,
          schoolDays: _schoolDayCtrls.map((d) => d.toModel()).toList(),
        );
      } else if (_topicMode == 3) {
        _result = TimetablesAndChartsLogic.solveDistanceChart(
          subMode: _distanceSubMode,
          originCityIdx: _originCityIdx,
          destCityIdx: _destCityIdx,
          viaCityIdx: _viaCityIdx,
          multiStopRouteCsv: _multiStopRouteCtrl.text,
        );
      } else {
        if (_chartSubMode == 0) {
          _result = TimetablesAndChartsLogic.solveKnockoutBracket(
            bracketTitle: _bracketTitleCtrl.text,
            matches: _bracketMatches,
            targetPlayerName: _targetPlayerCtrl.text,
          );
        } else {
          _result = TimetablesAndChartsLogic.solveTargetChart(
            chartTitle: _targetChartTitleCtrl.text,
            unitStr: _targetUnitCtrl.text,
            thresholdStr: _targetThresholdCtrl.text,
            labelsCsv: _targetLabelsCtrl.text,
            valuesCsv: _targetValuesCtrl.text,
          );
        }
      }
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

  Widget _buildStyledDropdown({
    required int value,
    required List<String> labels,
    required String prefix,
    required ValueChanged<int> onSelected,
  }) {
    final int safeVal = value.clamp(0, math.max(0, labels.length - 1));
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
          value: safeVal,
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

  Widget _buildPresetBar() {
    const presets = TimetablesAndChartsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick-Load Textbook Schedules & Charts (One-Tap Shortcut):",
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
                  avatar: const Icon(Icons.schedule,
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

  Widget _buildClockModeUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _clockSubMode,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Convert 12h ↔ 24h\n& Word Times",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Elapsed Time\n(Start → End)",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Add / Subtract\nHours & Mins",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _clockSubMode = v);
            },
            thumbColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        if (_clockSubMode == 0)
          _buildSmallField(
            _clockListCtrl,
            "Times to Convert (Comma-Separated: 12h, 24h, or Word Phrases)",
            hint:
            "e.g. 5.40 a.m., 7.25 p.m., 22:25 hours, 5 to 9 at night, Midday",
          )
        else if (_clockSubMode == 1)
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  _clockStartCtrl,
                  "Start / Departure Time",
                  hint: "e.g. 6.00 pm or 13:00",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallField(
                  _clockEndCtrl,
                  "End / Arrival Time",
                  hint: "e.g. 11.45 pm or 20:55",
                ),
              ),
            ],
          )
        else ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSmallField(
                    _clockStartCtrl,
                    "Start Time",
                    hint: "e.g. 13:00",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildSmallField(_durHoursCtrl, "Hours", hint: "6"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildSmallField(_durMinsCtrl, "Mins", hint: "10"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _durIsAdd,
                children: const {
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Add Duration (+)",
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Subtract Duration (−)",
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                },
                onValueChanged: (bool? v) {
                  if (v != null) setState(() => _durIsAdd = v);
                },
                thumbColor: Colors.deepPurple.shade100,
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildJourneyModeUI() {
    final List<String> liveStations = List.generate(_stopCtrls.length, (i) {
      final String s = _stopCtrls[i].stationCtrl.text.trim();
      return s.isEmpty ? "Station ${i + 1}" : s;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallField(
          _serviceTitleCtrl,
          "Service / Train / Flight Name",
          hint: "e.g. 201 UP Train or Flight WT751",
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Stations / Stops in Travel Order (A = Arrive, D = Depart):",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _stopCtrls.add(_StopControllerTriplet());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Stop"),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(_stopCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSmallField(
                        _stopCtrls[i].stationCtrl,
                        "Station ${i + 1}",
                        hint: "e.g. Oshogbo",
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: _buildSmallField(
                        _stopCtrls[i].arrCtrl,
                        "Arrive (A)",
                        hint: i == 0 ? "Start (Blank)" : "e.g. 9.32 pm",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: _buildSmallField(
                        _stopCtrls[i].depCtrl,
                        "Depart (D)",
                        hint: i == _stopCtrls.length - 1
                            ? "End (Blank)"
                            : "e.g. 9.42 pm",
                      ),
                    ),
                    if (_stopCtrls.length > 2)
                      IconButton(
                        icon:
                        const Icon(Icons.remove_circle, color: Colors.red),
                        padding: const EdgeInsets.only(left: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _stopCtrls[i].dispose();
                            _stopCtrls.removeAt(i);
                            _originStopIdx = _originStopIdx.clamp(
                                0, _stopCtrls.length - 2);
                            _destStopIdx =
                                _destStopIdx.clamp(1, _stopCtrls.length - 1);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStyledDropdown(
                value: _originStopIdx,
                labels: liveStations,
                prefix: "From",
                onSelected: (v) {
                  setState(() => _originStopIdx = v);
                  if (_result != null) _solveManual();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStyledDropdown(
                value: _destStopIdx,
                labels: liveStations,
                prefix: "To",
                onSelected: (v) {
                  setState(() => _destStopIdx = v);
                  if (_result != null) _solveManual();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSmallField(
                _actualFlightDurCtrl,
                "Actual Flight Time (Optional, Time Zones)",
                hint: "e.g. 6 h 10 min",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallField(
                _compareLegDurCtrl,
                "Compare Leg Time (Optional)",
                hint: "e.g. 1 h 48 min",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchoolModeUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallField(
          _periodSlotsCtrl,
          "Period Time Slots (Comma-Separated, e.g. 07:00-07:40)",
          hint: "07:00-07:40, 07:40-08:20, 08:20-09:00, 10:00-10:40...",
        ),
        const SizedBox(height: 12),
        const Text(
          "Daily Subjects (Comma-Separated per Day):",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(_schoolDayCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildSmallField(
                        _schoolDayCtrls[i].dayCtrl,
                        "Day",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: _buildSmallField(
                        _schoolDayCtrls[i].subjectsCtrl,
                        "Subjects across periods",
                      ),
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

  Widget _buildDistanceModeUI() {
    const List<String> cities = TimetablesAndChartsLogic.nigerianCities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _distanceSubMode,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Direct vs. Via\nIntermediate City",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Multi-Stop Tour /\nRound Trip",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) setState(() => _distanceSubMode = v);
            },
            thumbColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        if (_distanceSubMode == 0) ...[
          Row(
            children: [
              Expanded(
                child: _buildStyledDropdown(
                  value: _originCityIdx,
                  labels: cities,
                  prefix: "From",
                  onSelected: (v) {
                    setState(() => _originCityIdx = v);
                    if (_result != null) _solveManual();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStyledDropdown(
                  value: _destCityIdx,
                  labels: cities,
                  prefix: "To",
                  onSelected: (v) {
                    setState(() => _destCityIdx = v);
                    if (_result != null) _solveManual();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStyledDropdown(
            value: _viaCityIdx,
            labels: cities,
            prefix: "Compare Route Via",
            onSelected: (v) {
              setState(() => _viaCityIdx = v);
              if (_result != null) _solveManual();
            },
          ),
        ] else
          _buildSmallField(
            _multiStopRouteCtrl,
            "Multi-Stop City Chain (Comma-Separated)",
            hint: "Port Harcourt, Owerri, Enugu, Calabar, Port Harcourt",
          ),
      ],
    );
  }

  Widget _buildBracketAndTargetModeUI() {
    final Set<String> playerNames = {};
    for (final m in _bracketMatches) {
      playerNames.add(m.player1Name);
      playerNames.add(m.player2Name);
    }
    final List<String> playerList = playerNames.toList();
    final int selectedPlayerIdx = math.max(
      0,
      playerList.indexWhere((p) =>
      p.toLowerCase() == _targetPlayerCtrl.text.trim().toLowerCase()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _chartSubMode,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Knockout Tournament\nBracket (Fig 18.7)",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Target Line Chart\n(Fig 18.8 Walking)",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            },
            onValueChanged: (int? v) {
              if (v != null) {
                setState(() => _chartSubMode = v);
                _solveManual();
              }
            },
            thumbColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        if (_chartSubMode == 0) ...[
          _buildSmallField(
            _bracketTitleCtrl,
            "Tournament Title",
          ),
          const SizedBox(height: 10),
          if (playerList.isNotEmpty)
            _buildStyledDropdown(
              value: selectedPlayerIdx,
              labels: playerList,
              prefix: "Inspect Player Stats",
              onSelected: (idx) {
                setState(() => _targetPlayerCtrl.text = playerList[idx]);
                if (_result != null) _solveManual();
              },
            ),
        ] else ...[
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildSmallField(
                  _targetChartTitleCtrl,
                  "Chart Title",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSmallField(
                  _targetThresholdCtrl,
                  "Target Value",
                  hint: "8000",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSmallField(
                  _targetUnitCtrl,
                  "Unit",
                  hint: "paces",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSmallField(
            _targetLabelsCtrl,
            "Day / Period Labels (Comma-Separated)",
            hint: "Sun (S), Mon (M), Tue (T), Wed (W), Thu (T), Fri (F), Sat (S)",
          ),
          const SizedBox(height: 10),
          _buildSmallField(
            _targetValuesCtrl,
            "Recorded Values (Comma-Separated)",
            hint: "10000, 9000, 0, 8000, 7000, 5000, 9000",
          ),
        ],
      ],
    );
  }

  Widget _buildInputSection() {
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
                child: Text("🛠️ Timetable & Chart Builder",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            },
            onValueChanged: (int? val) {
              if (val != null) setState(() => _inputMode = val);
            },
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 16),
        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snap a photo of any train/flight schedule, school timetable, distance chart, or tournament bracket from Section 18-2 (Exercises 18c–18f)!",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            Container(
              height: 60,
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
                  const Text("✅ Schedule/Chart Image Attached",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                  TextButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    child: const Text("Remove",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _aiController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Question or Schedule Description",
              hintText:
              "e.g. How long does the 201 UP train stay at Oshogbo, and how long does the journey take from Ibadan to Offa?",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              label: const Text("Extract & Solve with AI",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          _buildPresetBar(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _topicMode,
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("12h / 24h\nClock",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Train & Flight\nTimetables",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("School\nTimetable",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ),
                3: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Distance\nChart",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ),
                4: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Bracket &\nTarget Chart",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ),
              },
              onValueChanged: (int? val) {
                if (val != null) {
                  setState(() => _topicMode = val);
                }
              },
              thumbColor: Colors.deepPurple.shade100,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 16),
          if (_topicMode == 0)
            _buildClockModeUI()
          else if (_topicMode == 1)
            _buildJourneyModeUI()
          else if (_topicMode == 2)
              _buildSchoolModeUI()
            else if (_topicMode == 3)
                _buildDistanceModeUI()
              else
                _buildBracketAndTargetModeUI(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.analytics, color: Colors.white),
            label: const Text("Analyze Timetable / Chart",
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
            _result!.errorMessage ?? "Invalid input.",
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 680.0);
    const double canvasHeight = 360.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("1. Interactive Schedule & Chart Visualizer:",
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
              minScale: 0.4,
              maxScale: 3.5,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                color: Colors.white,
                child: CustomPaint(
                  painter: TimetablesAndChartsPainter(result: _result!),
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
                  Text(
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
                  ],
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
      appBar: AppBar(title: const Text('Timetables and Charts')),
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

class TimetablesAndChartsPainter extends CustomPainter {
  final TimetableChartResult result;

  TimetablesAndChartsPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    _drawText(
      canvas,
      result.title,
      size.width / 2,
      24,
      fontSize: 15,
      isBold: true,
      color: Colors.deepPurple,
    );

    if (result.topicMode == 0) {
      _paintClockConversionDiagram(canvas, size);
    } else if (result.topicMode == 1) {
      _paintJourneyTimeline(canvas, size);
    } else if (result.topicMode == 2) {
      _paintSchoolTimetableChart(canvas, size);
    } else if (result.topicMode == 3) {
      _paintDistanceRouteDiagram(canvas, size);
    } else {
      if (result.subMode == 0) {
        _paintKnockoutBracket(canvas, size);
      } else {
        _paintTargetLineChart(canvas, size);
      }
    }
  }

  void _paintClockConversionDiagram(Canvas canvas, Size size) {
    const double barLeft = 48.0;
    final double barRight = size.width - 48.0;
    final double barW = barRight - barLeft;
    const double barY = 92.0;

    // 24-Hour Ruler Track (00:00 to 24:00)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, barY - 12, barW / 2, 24),
          const Radius.circular(6)),
      Paint()..color = Colors.blue.shade50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft + barW / 2, barY - 12, barW / 2, 24),
          const Radius.circular(6)),
      Paint()..color = Colors.amber.shade50,
    );

    _drawText(canvas, "a.m. (Morning: 00:00 – 11:59)", barLeft + barW * 0.25,
        barY - 26,
        fontSize: 12, isBold: true, color: Colors.blue.shade800);
    _drawText(
        canvas,
        "p.m. (Afternoon/Night: Add 12 → 12:00 – 23:59)",
        barLeft + barW * 0.75,
        barY - 26,
        fontSize: 12,
        isBold: true,
        color: Colors.orange.shade900);

    for (int h = 0; h <= 24; h += 3) {
      final double x = barLeft + (h / 24.0) * barW;
      canvas.drawLine(Offset(x, barY - 12), Offset(x, barY + 12),
          Paint()..color = Colors.grey.shade600);
      _drawText(canvas, "${h.toString().padLeft(2, '0')}:00", x, barY + 24,
          fontSize: 11, isBold: h == 0 || h == 12 || h == 24);
    }

    // Conversion cards below the 24-hour ruler
    final int count = math.min(result.clockVisuals.length, 6);
    for (int i = 0; i < count; i++) {
      final v = result.clockVisuals[i];
      final double ratio = ((v.hours24 * 60 + v.minutes) / 1440.0).clamp(0.0, 1.0);
      final double pinX = barLeft + ratio * barW;

      canvas.drawCircle(
          Offset(pinX, barY), 6, Paint()..color = Colors.deepPurple);

      final int col = i % 2;
      final int row = i ~/ 2;
      final double cardW = (barW - 20) / 2;
      final double cardX = barLeft + col * (cardW + 20);
      final double cardY = 148.0 + row * 62.0;

      final RRect cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cardX, cardY, cardW, 50),
        const Radius.circular(8),
      );
      canvas.drawRRect(cardRect, Paint()..color = Colors.deepPurple.shade50);
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = Colors.deepPurple.shade200
          ..style = PaintingStyle.stroke,
      );

      _drawText(
        canvas,
        "${v.formatted12h}  ↔  ${v.formatted24h}",
        cardX + cardW / 2,
        cardY + 25,
        fontSize: 12.5,
        isBold: true,
        color: Colors.deepPurple.shade900,
      );
    }
  }

  void _paintJourneyTimeline(Canvas canvas, Size size) {
    final stops = result.stationVisuals;
    if (stops.isEmpty) return;

    const double leftX = 75.0;
    final double rightX = size.width - 75.0;
    final double trackW = rightX - leftX;
    const double trackY = 175.0;

    // Draw main railway/flight track
    canvas.drawLine(
      const Offset(leftX, trackY),
      Offset(rightX, trackY),
      Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final int n = stops.length;
    for (int i = 0; i < n; i++) {
      final double sx = n == 1 ? size.width / 2 : leftX + (i / (n - 1)) * trackW;
      final bool isSelectedLeg =
          i >= result.selectedOriginIdx && i < result.selectedDestIdx;

      if (i < n - 1) {
        final double nextX = leftX + ((i + 1) / (n - 1)) * trackW;
        if (isSelectedLeg) {
          canvas.drawLine(
            Offset(sx, trackY),
            Offset(nextX, trackY),
            Paint()
              ..color = Colors.green.shade600
              ..strokeWidth = 7,
          );
        }
        if (stops[i].legMinsToNext != null) {
          final String legStr =
          TimetablesAndChartsLogic.formatDuration(stops[i].legMinsToNext!);
          _drawBadge(
            canvas,
            "Leg: $legStr",
            (sx + nextX) / 2,
            trackY - 36,
            Colors.deepPurple,
          );
        }
      }

      // Station Circle
      final bool isEndpoint =
          i == result.selectedOriginIdx || i == result.selectedDestIdx;
      canvas.drawCircle(
        Offset(sx, trackY),
        14,
        Paint()
          ..color =
          isEndpoint ? Colors.green.shade700 : Colors.deepPurple.shade600,
      );
      canvas.drawCircle(
          Offset(sx, trackY), 6, Paint()..color = Colors.white);

      // Station Name & A/D Badges
      _drawText(canvas, stops[i].name, sx, trackY - 72,
          fontSize: 14, isBold: true, color: Colors.black87);
      _drawText(canvas, "A: ${stops[i].arr24}", sx, trackY + 34,
          fontSize: 12, isBold: true, color: Colors.blue.shade800);
      _drawText(canvas, "D: ${stops[i].dep24}", sx, trackY + 54,
          fontSize: 12, isBold: true, color: Colors.green.shade800);

      if (stops[i].stopoverMins != null) {
        _drawBadge(
          canvas,
          "Stopover: ${TimetablesAndChartsLogic.formatDuration(stops[i].stopoverMins!)}",
          sx,
          trackY + 86,
          Colors.orange.shade800,
        );
      }
    }
  }

  void _paintSchoolTimetableChart(Canvas canvas, Size size) {
    // Draw Subject Frequency Horizontal Bars
    final entries = result.subjectFrequencies.entries.toList();
    if (entries.isEmpty) return;

    const double startX = 115.0;
    final double maxBarW = size.width - startX - 95.0;
    final int maxCount =
    entries.map((e) => e.value).fold(1, (a, b) => math.max(a, b));

    _drawText(
      canvas,
      "Periods per Day: ${result.periodHeaders.length}   |   ${result.breakSummaries.isEmpty ? 'No Breaks' : result.breakSummaries.join('  •  ')}",
      size.width / 2,
      54,
      fontSize: 12,
      isBold: true,
      color: Colors.green.shade800,
    );

    final int limit = math.min(entries.length, 9);
    for (int i = 0; i < limit; i++) {
      final double y = 92.0 + i * 28.0;
      final String sub = entries[i].key;
      final int count = entries[i].value;
      final double w = (count / maxCount) * maxBarW;

      _drawText(canvas, sub, startX - 12, y,
          fontSize: 12, isBold: true, alignRight: true);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(startX, y - 9, w, 18), const Radius.circular(5)),
        Paint()..color = Colors.deepPurple.shade400,
      );
      _drawText(canvas, "$count periods", startX + w + 8, y,
          fontSize: 11.5,
          isBold: true,
          color: Colors.deepPurple.shade900,
          alignLeft: true);
    }
  }

  void _paintDistanceRouteDiagram(Canvas canvas, Size size) {
    final cities = result.routeCities;
    if (cities.isEmpty) return;

    if (result.subMode == 0 &&
        result.directDistance != null &&
        result.viaDistance != null &&
        cities.length == 3) {
      // Draw Triangle comparing Direct (A -> B) vs Via Intermediate (A -> Via -> B)
      final Offset pOrig = Offset(110, size.height - 85);
      final Offset pDest = Offset(size.width - 110, size.height - 85);
      final Offset pVia = Offset(size.width / 2, 95);

      // Direct Path
      canvas.drawLine(
        pOrig,
        pDest,
        Paint()
          ..color = Colors.green.shade600
          ..strokeWidth = 5,
      );
      _drawBadge(
        canvas,
        "Direct: ${result.directDistance!.round()} km",
        (pOrig.dx + pDest.dx) / 2,
        pOrig.dy + 26,
        Colors.green.shade700,
      );

      // Via Path
      final Paint viaPaint = Paint()
        ..color = Colors.orange.shade700
        ..strokeWidth = 4;
      canvas.drawLine(pOrig, pVia, viaPaint);
      canvas.drawLine(pVia, pDest, viaPaint);

      _drawBadge(
        canvas,
        "${result.routeLegDistances[0].round()} km",
        (pOrig.dx + pVia.dx) / 2 - 20,
        (pOrig.dy + pVia.dy) / 2,
        Colors.orange.shade800,
      );
      _drawBadge(
        canvas,
        "${result.routeLegDistances[1].round()} km",
        (pVia.dx + pDest.dx) / 2 + 20,
        (pVia.dy + pDest.dy) / 2,
        Colors.orange.shade800,
      );

      for (final ptEntry in [
        MapEntry(pOrig, cities[0]),
        MapEntry(pVia, "Via ${cities[1]}"),
        MapEntry(pDest, cities[2]),
      ]) {
        canvas.drawCircle(
            ptEntry.key, 10, Paint()..color = Colors.deepPurple.shade700);
        _drawText(
          canvas,
          ptEntry.value,
          ptEntry.key.dx,
          ptEntry.key == pVia ? ptEntry.key.dy - 24 : ptEntry.key.dy - 22,
          fontSize: 13.5,
          isBold: true,
        );
      }
    } else {
      // Multi-stop chain
      const double leftX = 65.0;
      final double rightX = size.width - 65.0;
      final double spanW = rightX - leftX;
      const double y = 185.0;
      final int n = cities.length;

      for (int i = 0; i < n; i++) {
        final double x = n == 1 ? size.width / 2 : leftX + (i / (n - 1)) * spanW;
        if (i < n - 1) {
          final double nx = leftX + ((i + 1) / (n - 1)) * spanW;
          canvas.drawLine(
            Offset(x, y),
            Offset(nx, y),
            Paint()
              ..color = Colors.deepPurple
              ..strokeWidth = 4,
          );
          if (i < result.routeLegDistances.length) {
            _drawBadge(
              canvas,
              "${result.routeLegDistances[i].round()} km",
              (x + nx) / 2,
              y - 28,
              Colors.green.shade700,
            );
          }
        }
        canvas.drawCircle(
            Offset(x, y), 9, Paint()..color = Colors.deepPurple.shade700);
        _drawText(canvas, cities[i], x, y + (i.isEven ? 26 : 44),
            fontSize: 12, isBold: true);
      }
    }
  }

  void _paintKnockoutBracket(Canvas canvas, Size size) {
    final matches = result.bracketMatches;
    if (matches.length < 7) return;

    const double col1X = 95.0;
    const double col2X = 275.0;
    const double col3X = 455.0;
    const double col4X = 605.0;

    final List<String> headers = ["1st Round", "Semifinals", "Finals", "Winner"];
    final List<double> cols = [col1X, col2X, col3X, col4X];
    for (int c = 0; c < 4; c++) {
      _drawBadge(canvas, headers[c], cols[c], 56, Colors.green.shade700);
    }

    final Paint linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    // 4 First-round matches
    for (int m = 0; m < 4; m++) {
      final double y1 = 96.0 + m * 66.0;
      final double y2 = y1 + 26.0;
      final match = matches[m];

      _drawPlayerBox(
          canvas, "${match.player1Name} (${match.player1Score})", col1X, y1);
      _drawPlayerBox(
          canvas, "${match.player2Name} (${match.player2Score})", col1X, y2);
      canvas.drawLine(
          Offset(col1X + 68, (y1 + y2) / 2), Offset(col2X - 68, (y1 + y2) / 2), linePaint);
    }

    // 2 Semifinal matches
    for (int s = 0; s < 2; s++) {
      final double y1 = 109.0 + s * 132.0;
      final double y2 = y1 + 66.0;
      final match = matches[4 + s];
      _drawPlayerBox(
          canvas, "${match.player1Name} (${match.player1Score})", col2X, y1);
      _drawPlayerBox(
          canvas, "${match.player2Name} (${match.player2Score})", col2X, y2);
      canvas.drawLine(
          Offset(col2X + 68, (y1 + y2) / 2), Offset(col3X - 68, (y1 + y2) / 2), linePaint);
    }

    // Final match
    final finalM = matches[6];
    _drawPlayerBox(
        canvas, "${finalM.player1Name} (${finalM.player1Score})", col3X, 142.0);
    _drawPlayerBox(
        canvas, "${finalM.player2Name} (${finalM.player2Score})", col3X, 274.0);
    canvas.drawLine(
        const Offset(col3X + 68, 208.0), const Offset(col4X - 55, 208.0), linePaint);

    // Champion
    _drawBadge(
        canvas, "🏆 ${finalM.winnerName}", col4X, 208.0, Colors.deepPurple);
  }

  void _drawPlayerBox(Canvas canvas, String text, double cx, double cy) {
    final bool isHighlighted = result.highlightedPlayer.isNotEmpty &&
        text.toLowerCase().contains(result.highlightedPlayer.toLowerCase());
    final Rect r = Rect.fromCenter(center: Offset(cx, cy), width: 132, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(5)),
      Paint()
        ..color = isHighlighted
            ? Colors.deepPurple.shade100
            : Colors.grey.shade100,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(5)),
      Paint()
        ..color =
        isHighlighted ? Colors.deepPurple : Colors.grey.shade400
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      text,
      cx,
      cy,
      fontSize: 11,
      isBold: isHighlighted,
      color: isHighlighted ? Colors.deepPurple.shade900 : Colors.black87,
    );
  }

  void _paintTargetLineChart(Canvas canvas, Size size) {
    final vals = result.targetValues;
    final labels = result.targetLabels;
    if (vals.isEmpty) return;

    const double leftPad = 68.0;
    final double rightPad = size.width - 36.0;
    const double topPad = 56.0;
    final double bottomPad = size.height - 46.0;
    final double plotW = rightPad - leftPad;
    final double plotH = bottomPad - topPad;

    final double maxVal =
        math.max(result.targetThreshold, vals.reduce(math.max)) * 1.1;

    // Grid lines
    for (int g = 0; g <= 5; g++) {
      final double gy = bottomPad - (g / 5.0) * plotH;
      final double gVal = (g / 5.0) * maxVal;
      canvas.drawLine(Offset(leftPad, gy), Offset(rightPad, gy),
          Paint()..color = Colors.green.shade100);
      _drawText(
        canvas,
        TimetablesAndChartsLogic.formatNumber(gVal, maxDecimals: 0),
        leftPad - 8,
        gy,
        fontSize: 10.5,
        alignRight: true,
      );
    }

    // Axes
    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(leftPad, topPad), Offset(leftPad, bottomPad), axisPaint);
    canvas.drawLine(
        Offset(leftPad, bottomPad), Offset(rightPad, bottomPad), axisPaint);

    // Bold Target Threshold Line
    final double targetY =
        bottomPad - (result.targetThreshold / maxVal).clamp(0.0, 1.0) * plotH;
    canvas.drawLine(
      Offset(leftPad, targetY),
      Offset(rightPad, targetY),
      Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2.5,
    );
    _drawBadge(
      canvas,
      "Target = ${TimetablesAndChartsLogic.formatNumber(result.targetThreshold)}",
      leftPad + 64,
      targetY - 14,
      Colors.green.shade700,
    );

    // Plot points & dashed connectors
    final List<Offset> pts = [];
    for (int i = 0; i < vals.length; i++) {
      final double px = vals.length == 1
          ? leftPad + plotW / 2
          : leftPad + (i / (vals.length - 1)) * plotW;
      final double py = bottomPad - (vals[i] / maxVal).clamp(0.0, 1.0) * plotH;
      pts.add(Offset(px, py));

      _drawText(canvas, labels[i], px, bottomPad + 18,
          fontSize: 11, isBold: true);
    }

    for (int i = 0; i < pts.length - 1; i++) {
      canvas.drawLine(
        pts[i],
        pts[i + 1],
        Paint()
          ..color = Colors.deepPurple.shade400
          ..strokeWidth = 2,
      );
    }

    for (int i = 0; i < pts.length; i++) {
      final bool met = vals[i] >= result.targetThreshold - 1e-9;
      final Color ptColor = met ? Colors.green.shade700 : Colors.red.shade700;
      canvas.drawCircle(pts[i], 5.5, Paint()..color = ptColor);
      _drawText(
        canvas,
        TimetablesAndChartsLogic.formatNumber(vals[i]),
        pts[i].dx,
        pts[i].dy - 14,
        fontSize: 10.5,
        isBold: true,
        color: ptColor,
      );
    }
  }

  void _drawBadge(
      Canvas canvas, String text, double x, double y, Color bgColor) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect rect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + 14,
      height: tp.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = bgColor,
    );
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
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
        bool alignRight = false,
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
        : (alignRight
        ? Offset(x - tp.width, y - tp.height / 2)
        : Offset(x - tp.width / 2, y - tp.height / 2));
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant TimetablesAndChartsPainter oldDelegate) =>
      oldDelegate.result != result;
}