import 'package:flutter/material.dart';

class EgyptianSymbol {
  final int value;
  final String label;
  final String assetPath;

  const EgyptianSymbol({
    required this.value,
    required this.label,
    required this.assetPath,
  });
}

/// List of symbols in descending value order.
const List<EgyptianSymbol> egyptianSymbols = [
  EgyptianSymbol(
    value: 1000000,
    label: "Astonished Man",
    assetPath: "assets/images/astonished_man.png",
  ),
  EgyptianSymbol(
    value: 100000,
    label: "Tadpole",
    assetPath: "assets/images/tadpole.png",
  ),
  EgyptianSymbol(
    value: 10000,
    label: "Pointed Finger",
    assetPath: "assets/images/pointed_finger.png",
  ),
  EgyptianSymbol(
    value: 1000,
    label: "Lotus Flower",
    assetPath: "assets/images/lotus_flower.png",
  ),
  EgyptianSymbol(
    value: 100,
    label: "Coiled Rope",
    assetPath: "assets/images/coiled_rope.png",
  ),
  EgyptianSymbol(
    value: 10,
    label: "Heel Bone",
    assetPath: "assets/images/heel_bone.png",
  ),
  EgyptianSymbol(
    value: 1,
    label: "Stroke",
    assetPath: "assets/images/stroke.png",
  ),
];