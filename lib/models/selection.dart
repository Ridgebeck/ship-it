import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Selection extends Equatable {
  const Selection({
    this.selectionIdx,
    this.lengthOfSelectedContent = 0,
    //this.colorOfSelectedContent,
    this.colorNoOfSelection,
  });
  final int? selectionIdx;
  final int lengthOfSelectedContent;
  //final Color? colorOfSelectedContent;
  final int? colorNoOfSelection;

  @override
  List<Object?> get props => [
        selectionIdx,
        lengthOfSelectedContent,
        //colorOfSelectedContent,
        colorNoOfSelection,
      ];
}
