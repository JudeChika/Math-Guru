import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class MathSolverService {
  Interpreter? _interpreter;
  Map<String, int> _vocab = {};

  Future<void> init() async {
    // 1. Load the model
    _interpreter = await Interpreter.fromAsset('math_guru_offline.tflite');

    // 2. Load the dictionary
    final vocabData = await rootBundle.loadString('assets/vocab.txt');
    List<String> lines = vocabData.split('\n');
    for (int i = 0; i < lines.length; i++) {
      _vocab[lines[i].trim()] = i;
    }
  }

  List<int> _tokenize(String text) {
    // Simple whitespace tokenizer matching T5's behavior
    final tokens = text.toLowerCase().split(RegExp(r"\s+"));
    return tokens.map((t) => _vocab[t] ?? _vocab['<unk>'] ?? 0).toList();
  }

  Future<String> translate(String input, bool toMath) async {
    String prefix = toMath ? "translate English to Math: " : "translate Math to English: ";

    List<int> inputIds = _tokenize(prefix + input);

    // Pad to 128
    while (inputIds.length < 128) {
      inputIds.add(0);
    }

    var output = List.filled(1 * 128, 0).reshape([1, 128]);
    _interpreter!.run([inputIds], output);

    // Decode: Look up index in vocab (simplified decoding for JSS1 algebra)
    List<String> keys = _vocab.keys.toList();
    List<int> outputIds = (output[0] as List).cast<int>();

    return outputIds
        .map((id) => (id < keys.length) ? keys[id] : "")
        .join(" ")
        .replaceAll("<pad>", "")
        .trim();
  }
}