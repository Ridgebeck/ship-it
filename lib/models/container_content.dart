import 'package:flutter/material.dart';

class ContainerContent {
  const ContainerContent({
    //required this.color,
    required this.colorNumber,
    this.isHazardous = false,
    this.isSelected = false,
    this.isDiscovered = false,
  });

  //final Color color;
  final int colorNumber;
  final bool isHazardous;
  final bool isSelected;
  final bool isDiscovered;

  // implement copyWith method
  ContainerContent copyWith({
    //Color? color,
    int? colorNumber,
    bool? isHazardous,
    bool? isSelected,
    bool? isDiscovered,
  }) {
    return ContainerContent(
      //color: color ?? this.color,
      colorNumber: colorNumber ?? this.colorNumber,
      isHazardous: isHazardous ?? this.isHazardous,
      isSelected: isSelected ?? this.isSelected,
      isDiscovered: isDiscovered ?? this.isDiscovered,
    );
  }
}
