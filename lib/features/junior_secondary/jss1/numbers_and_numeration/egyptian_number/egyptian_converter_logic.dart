import 'egyptian_symbols.dart';
import 'egyptian_conversion_step.dart';

class EgyptianConverter {
  /// Arabic to Egyptian
  static (List<int> symbolCounts, List<EgyptianConversionStep> steps) englishToEgyptian(int number) {
    List<int> counts = List.filled(egyptianSymbols.length, 0);
    List<EgyptianConversionStep> steps = [];
    int remaining = number;
    StringBuffer resultBuffer = StringBuffer();

    for (int i = 0; i < egyptianSymbols.length; i++) {
      final symbol = egyptianSymbols[i];
      int count = remaining ~/ symbol.value;
      counts[i] = count;
      if (count > 0) {
        resultBuffer.write("${List.filled(count, symbol.label).join(", ")}; ");
        steps.add(
          EgyptianConversionStep(
            description:
            "Extract $count × ${symbol.value} (${symbol.label}) from $remaining.",
            resultSoFar: resultBuffer.toString(),
          ),
        );
        remaining -= count * symbol.value;
      }
    }
    if (number == 0) {
      steps.add(
        EgyptianConversionStep(
          description: "Egyptian numerals do not have a symbol for zero.",
          resultSoFar: "",
        ),
      );
    } else {
      steps.add(
        EgyptianConversionStep(
          description: "Final Egyptian numeral obtained using the symbols.",
          resultSoFar: resultBuffer.toString(),
        ),
      );
    }
    return (counts, steps);
  }

  /// Egyptian to English
  static (int result, List<EgyptianConversionStep> steps) egyptianToEnglish(List<int> symbolCounts) {
    int total = 0;
    List<EgyptianConversionStep> steps = [];
    StringBuffer resultBuffer = StringBuffer();

    for (int i = 0; i < egyptianSymbols.length; i++) {
      int count = symbolCounts[i];
      final symbol = egyptianSymbols[i];
      if (count > 0) {
        int value = count * symbol.value;
        total += value;
        resultBuffer.write("$count × ${symbol.value} (${symbol.label}) = $value; ");
        steps.add(
          EgyptianConversionStep(
            description:
            "$count × ${symbol.value} = $value added for ${symbol.label}. Running total: $total",
            resultSoFar: resultBuffer.toString(),
          ),
        );
      }
    }

    steps.add(
      EgyptianConversionStep(
        description: "Final English number: $total",
        resultSoFar: "$total",
      ),
    );
    return (total, steps);
  }
}