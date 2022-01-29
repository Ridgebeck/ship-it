import 'package:flutter/material.dart';
import 'container_content.dart';

class Blueprint {
  Blueprint({
    required this.position,
    this.containerContents = const [],
    //this.shipColor,
    this.shipColorNumber,
    this.canAcceptHazardousContent = true,
    this.isWarehouse = false,
    this.isSelected = false,
    required this.size,
  }) : assert(isWarehouse ? true : shipColorNumber != null);

  int position;
  List<ContainerContent> containerContents;
  //Color? shipColor;
  int? shipColorNumber;
  bool canAcceptHazardousContent;
  bool isWarehouse;
  bool isSelected;
  int size;

  // implement copyWith method
  Blueprint copyWith({
    int? position,
    List<ContainerContent>? containerContents,
    //Color? shipColor,
    int? shipColorNumber,
    bool? canAcceptHazardousContent,
    bool? isWarehouse,
    bool? isSelected,
    int? size,
  }) {
    return Blueprint(
      position: position ?? this.position,
      containerContents: containerContents ??
          List.generate(
              this.containerContents.length, (index) => this.containerContents[index].copyWith()),
      //shipColor: shipColor ?? this.shipColor,
      shipColorNumber: shipColorNumber ?? this.shipColorNumber,
      canAcceptHazardousContent: canAcceptHazardousContent ?? this.canAcceptHazardousContent,
      isWarehouse: isWarehouse ?? this.isWarehouse,
      isSelected: isSelected ?? this.isSelected,
      size: size ?? this.size,
    );
  }
}
