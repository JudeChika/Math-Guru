import 'package:flutter/material.dart';
import 'binary_to_decimal_logic.dart';
import 'decimal_to_binary_logic.dart';
import 'binary_conversion_models.dart';

class BinaryConversionScreen extends StatefulWidget {
  const BinaryConversionScreen({super.key});

  @override
  State<BinaryConversionScreen> createState() => _BinaryConversionScreenState();
}

class _BinaryConversionScreenState extends State<BinaryConversionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _binaryInputController = TextEditingController();
  final _decimalInputController = TextEditingController();
  // For decimal to binary, toggle between division and sum of powers
  bool _useSumOfPowers = false;

  List<BinaryToDecimalResult> _binaryToDecimalResults = [];
  List<DecimalToBinaryResult> _decimalToBinaryResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _convertBinaryToDecimal() {
    final binaries = _binaryInputController.text
        .replaceAll(',', ' ')
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    setState(() {
      _binaryToDecimalResults = BinaryToDecimalLogic.convert(binaries);
    });
  }

  void _convertDecimalToBinary() {
    final decimals = _decimalInputController.text
        .replaceAll(',', ' ')
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    setState(() {
      _decimalToBinaryResults = DecimalToBinaryLogic.convert(decimals, useSumOfPowers: _useSumOfPowers);
    });
  }

  Widget _binaryToDecimalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter binary numbers (e.g. 1101 1010 111):",
            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _binaryInputController,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration: const InputDecoration(
                    hintText: "e.g. 1101 1010 111",
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
                  ),
                  onSubmitted: (_) => _convertBinaryToDecimal(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _convertBinaryToDecimal,
                child: const Text("Convert", style: TextStyle(fontFamily: 'Poppins')),
              )
            ],
          ),
          const SizedBox(height: 18),
          for (final res in _binaryToDecimalResults)
            Card(
              color: Colors.green.shade50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Binary: ${res.binary}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Expanded Notation:", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ...res.expandedSteps.map((line) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "= $line",
                        style: const TextStyle(fontFamily: 'Poppins', color: Colors.deepPurple),
                      ),
                    )),
                    const SizedBox(height: 8),
                    const Text("Step-by-step Solution:", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ...res.stepByStep.map((step) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        step,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _decimalToBinarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter decimal numbers (e.g. 13 7 19):",
            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _decimalInputController,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration: const InputDecoration(
                    hintText: "e.g. 13 7 19",
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
                  ),
                  onSubmitted: (_) => _convertDecimalToBinary(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _convertDecimalToBinary,
                child: const Text("Convert", style: TextStyle(fontFamily: 'Poppins')),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Text("Sum of Powers", style: TextStyle(fontFamily: 'Poppins')),
                  Switch(
                    value: _useSumOfPowers,
                    onChanged: (val) {
                      setState(() {
                        _useSumOfPowers = val;
                        _convertDecimalToBinary();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final res in _decimalToBinaryResults)
            Card(
              color: Colors.green.shade50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Decimal: ${res.decimal}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Expanded Notation:", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ...res.expandedSteps.map((line) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "= $line",
                        style: const TextStyle(fontFamily: 'Poppins', color: Colors.deepPurple),
                      ),
                    )),
                    const SizedBox(height: 8),
                    const Text("Step-by-step Solution:", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ...res.stepByStep.map((step) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        step,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Conversion'), // AppBar remains default (Montserrat)
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: Text('Base 2 → Base 10')),
            Tab(child: Text('Base 10 → Base 2')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _binaryToDecimalSection(),
          _decimalToBinarySection(),
        ],
      ),
    );
  }
}