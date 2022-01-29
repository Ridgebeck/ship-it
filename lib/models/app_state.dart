import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:ship_it/levels/levels.dart';
import 'package:ship_it/models/models.dart';
import 'package:ship_it/puzzle/puzzle_state.dart';
import 'package:ship_it/theme/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AppState extends ChangeNotifier {
  /// selected theme
  PuzzleTheme _currentPuzzleTheme = BasicTheme();

  /// variables for previous, current, and next puzzle
  late PuzzleState _previousPuzzleState;
  late PuzzleState _currentPuzzleState;
  late PuzzleState _nextPuzzleState;

  /// variable for last saved puzzle
  late PuzzleState _lastSavedPuzzleState;

  /// internal private state of the blueprints of the current puzzle
  List<Blueprint> _blueprintList = [];

  /// internal private state of the selected items
  Selection? _selectedContent;

  /// save last turns in order to go back
  List<List<Blueprint>> _lastTurns = [];

  /// get current puzzle theme
  PuzzleTheme get puzzleTheme => _currentPuzzleTheme;

  /// get different puzzle states
  PuzzleState get previousPuzzleState => _previousPuzzleState;
  PuzzleState get currentPuzzleState => _currentPuzzleState;
  PuzzleState get nextPuzzleState => _nextPuzzleState;

  /// get info about current level state
  int get currentLevel => _currentPuzzleState.level.id;
  int get currentMoves => _currentPuzzleState.numberOfMoves;
  int get currentResets => _currentPuzzleState.numberOfResets;

  /// get and set current puzzle status
  PuzzleStatus get currentStatus => _currentPuzzleState.puzzleStatus;
  set puzzleStatus(PuzzleStatus status) {
    _currentPuzzleState = _currentPuzzleState.copyWith(puzzleStatus: status);
  }

  /// start time of current level
  DateTime _startTimeLevel = DateTime.now();
  DateTime get startTime => _startTimeLevel;

  /// animation values
  double rotationAngle = 0;

  /// copy blueprint list
  List<Blueprint> _copyBlueprintList(List<Blueprint> listToCopy) {
    return List.generate(listToCopy.length, (index) => listToCopy[index].copyWith());
  }

  /// update the puzzle state from the current changes
  void _updatePuzzleState() {
    _currentPuzzleState = _currentPuzzleState.copyWith(
        level: _currentPuzzleState.level.copyWith(blueprints: _copyBlueprintList(_blueprintList)));
  }

  // void _changePuzzleStatus(PuzzleStatus puzzleStatus) {
  //   _currentPuzzleState = _currentPuzzleState.copyWith(puzzleStatus: puzzleStatus);
  // }

  /// move to next level
  void moveToNextLevel() async {
    // otherwise initialize next level
    initializeLevel(lvl: _currentPuzzleState.level.id + 1, update: true);
    // save current level locally
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("level", currentLevel);
    // log level progress in analytics
    await FirebaseAnalytics.instance.logLevelUp(level: currentLevel);
    // set start time of current level
    _startTimeLevel = DateTime.now();
  }

  /// initialize the current level
  void initializeLevel({required int lvl, bool update = false}) {
    // todo: load from file or saved progress
    _previousPuzzleState = PuzzleState(level: levels[lvl - 1], puzzleStatus: PuzzleStatus.complete);
    _currentPuzzleState = PuzzleState(level: levels[lvl], puzzleStatus: PuzzleStatus.active);
    _nextPuzzleState = PuzzleState(level: levels[lvl + 1], puzzleStatus: PuzzleStatus.inactive);

    // save a copy of the original puzzle state
    _lastSavedPuzzleState = _currentPuzzleState.copyWith();
    // save a copy of the list of blueprints
    _blueprintList = _currentPuzzleState.level.copyWith().blueprints;
    // save the current state as first saved turn
    _lastTurns = [_lastSavedPuzzleState.level.copyWith().blueprints];

    if (update == true) {
      // update puzzle state and UI
      _updatePuzzleState();
      notifyListeners();
    }
  }

  /// increase and decrease move counter
  void _increaseMoveCounter() {
    // increase move counter in current puzzle state
    _currentPuzzleState = _currentPuzzleState.copyWith(
      numberOfMoves: _currentPuzzleState.numberOfMoves + 1,
    );
  }

  void _decreaseMoveCounter() {
    // decrease move counter in current puzzle state
    _currentPuzzleState = _currentPuzzleState.copyWith(
      numberOfMoves: max(_currentPuzzleState.numberOfMoves - 1, 0),
    );
  }

  void _increaseResetCounter() {
    // increase reset counter in current puzzle state
    _currentPuzzleState = _currentPuzzleState.copyWith(
      numberOfResets: _currentPuzzleState.numberOfResets + 1,
    );
  }

  /// restart current game
  void restart() {
    if (currentMoves > 0) {
      print("restart");
      // reset memory of last turns and go back attempts
      _lastTurns = [_lastSavedPuzzleState.level.copyWith().blueprints];
      _currentPuzzleState = _currentPuzzleState.copyWith(goBackAttempts: kMaxGoBackPerPuzzle);

      // reset move counter to 0 moves in current puzzle state
      _currentPuzzleState = _currentPuzzleState.copyWith(numberOfMoves: 0);

      // increase reset counter by one
      _increaseResetCounter();

      // load saved ship list
      _blueprintList = _lastSavedPuzzleState.level.copyWith().blueprints;

      // update puzzle state and UI
      _updatePuzzleState();
      notifyListeners();
    }
  }

  /// go one move back
  void oneMoveBack() {
    print("go back: ${_currentPuzzleState.goBackAttempts}");
    print("last turns: ${_lastTurns.length}");
    // check player has attempts left and there is data from previous moves
    if (_currentPuzzleState.goBackAttempts > 0 && _lastTurns.length > 1) {
      // decrease number of attempts left by one
      _currentPuzzleState =
          _currentPuzzleState.copyWith(goBackAttempts: _currentPuzzleState.goBackAttempts - 1);

      // load ship list from one move before and remove entry from memory
      _lastTurns.removeLast();
      _blueprintList = _copyBlueprintList(_lastTurns.last);

      // decrease number of moves by one
      _decreaseMoveCounter();

      // update puzzle state and UI
      _updatePuzzleState();
      notifyListeners();
    }
  }

  /// handle user selection of any ship
  void clickOnPosition(int position) {
    // do not allow interactions with inactive or empty puzzles
    if (currentPuzzleState.puzzleStatus != PuzzleStatus.active ||
        currentPuzzleState.level.blueprints.isEmpty) {
      return;
    }

    // if nothing was selected before
    if (_selectedContent == null) {
      print("no selection");
      // do nothing on empty ships or warehouses
      if (_blueprintList[position].containerContents.isNotEmpty) {
        // otherwise select ship and content
        print("select ship/warehouse and content");
        _selectShipAndContent(position);
        notifyListeners();
      }
      return;
    }

    // deselect ship if it is the already selected ship
    if (position == _selectedContent!.selectionIdx) {
      print("deselect ship and content");
      _deselectShipAndContent(position);
      notifyListeners();
      return;
    }

    // transfer content if possible, otherwise deselect
    print("check space and transfer");
    _checkSpaceAndTransfer(position: position);
  }

  _selectShipAndContent(int position) {
    // abbreviated name to point to list of contents
    List<ContainerContent> contentsAtPosition = _blueprintList[position].containerContents;
    // find all adjacent containers with same color
    int selectedColorNo = contentsAtPosition.last.colorNumber;
    int lengthOfSelection = 0;

    _blueprintList[position].isSelected = true;
    // go backwards through content list
    for (int i = contentsAtPosition.length - 1; i >= 0; i--) {
      if (selectedColorNo != contentsAtPosition[i].colorNumber) {
        break;
      }
      lengthOfSelection = lengthOfSelection + 1;
      // mark all adjacent content that has same color as selected
      contentsAtPosition[i] = contentsAtPosition[i].copyWith(isSelected: true);
    }

    // save selected item data
    _selectedContent = Selection(
      selectionIdx: position,
      lengthOfSelectedContent: lengthOfSelection,
      //colorOfSelectedContent: selectedColorNo,
      colorNoOfSelection: selectedColorNo,
    );

    // update puzzle state with selected items
    _updatePuzzleState();
  }

  _deselectShipAndContent(int position) {
    // reset selected content
    _selectedContent = null;
    // reset content at position
    _blueprintList[position].isSelected = false;
    // unselect all contents
    for (int i = 0; i < _blueprintList[position].containerContents.length; i++) {
      _blueprintList[position].containerContents[i] =
          _blueprintList[position].containerContents[i].copyWith(isSelected: false);
    }
    // update puzzle state with selected items
    _updatePuzzleState();
  }

  _checkSpaceAndTransfer({required int position}) {
    print("checking ${_selectedContent!.selectionIdx}");
    // do nothing if same ship was selected
    if (position == _selectedContent!.selectionIdx) {
      return;
    }

    // check if target ship can accept content
    int availableSpace =
        _blueprintList[position].size - _blueprintList[position].containerContents.length;

    if (_blueprintList[position].containerContents.isEmpty
        ? availableSpace >= _selectedContent!.lengthOfSelectedContent
        : _selectedContent!.colorNoOfSelection ==
                _blueprintList[position].containerContents.last.colorNumber &&
            availableSpace >= _selectedContent!.lengthOfSelectedContent) {
      print("transfer");
      _transferContent(idxFrom: _selectedContent!.selectionIdx!, idxTo: position);
      _deselectShipAndContent(_selectedContent!.selectionIdx!);
      _checkIfShipIsComplete(position);
      _checkIfPuzzleIsSolved();

      if (currentPuzzleState.puzzleStatus == PuzzleStatus.complete) {
        _lastTurns = [_copyBlueprintList(_blueprintList)];
      } else {
        // remove oldest entry if list contains 5 moves or more
        if (_lastTurns.length > kMaxGoBackPerPuzzle) {
          _lastTurns.removeAt(0);
        }
        // add current list
        _lastTurns.add(_copyBlueprintList(_blueprintList));
      }

      notifyListeners();
      return;
    }
    // otherwise deselect current ship
    else {
      print("deselect ship");
      _deselectShipAndContent(_selectedContent!.selectionIdx!);
      notifyListeners();
      return;
    }
  }

  void _transferContent({required int idxFrom, required int idxTo}) {
    if (idxFrom == idxTo) {
      return;
    }

    // save content that should be moved in temporary lists
    List<ContainerContent> toRemove = [];
    List<ContainerContent> toAdd = [];
    bool selectionIsHazardous = false;
    for (ContainerContent content in _blueprintList[idxFrom].containerContents.reversed) {
      if (content.isSelected) {
        selectionIsHazardous = content.isHazardous;
        toRemove.add(content);
        toAdd.add(ContainerContent(
          colorNumber: content.colorNumber,
          isSelected: false,
          isDiscovered: true,
          isHazardous: content.isHazardous,
        ));
      }
    }

    // don't allow hazardous content be transferred into warehouse
    if (selectionIsHazardous && _blueprintList[idxTo].isWarehouse) {
      print("DO NOT TRANSFER!");
      return;
    }
    // increase move counter
    _increaseMoveCounter();

    // remove contents from ship in original list
    _blueprintList[idxFrom].containerContents.removeWhere((e) => toRemove.contains(e));
    // add contents to ship in original list
    _blueprintList[idxTo] = _blueprintList[idxTo].copyWith(
      containerContents: _blueprintList[idxTo].containerContents + toAdd,
      isSelected: false,
    );
  }

  bool _checkIfShipIsComplete(int position) {
    // check if ship that received content is complete
    if (_blueprintList[position].containerContents.length == _blueprintList[position].size) {
      //print("ship $position is full!");
      bool hasSameColor = _blueprintList[position].containerContents.every((content) =>
          content.colorNumber == _blueprintList[position].containerContents.first.colorNumber);
      bool isInRightSpot = _blueprintList[position].containerContents.first.colorNumber ==
          _blueprintList[position].shipColorNumber;
      if (hasSameColor && isInRightSpot) {
        print("ship $position is completed!");
        return true;
      }
    }
    return false;
  }

  bool _checkIfPuzzleIsSolved() {
    bool _solved = true;
    for (Blueprint bp in _blueprintList) {
      // only check non empty ships
      if (bp.containerContents.isNotEmpty) {
        // check if ship is incomplete
        if (!_checkIfShipIsComplete(bp.position)) {
          _solved = false;
          break;
        }
      }
    }

    if (_solved) {
      print("PUZZLE WAS SOLVED - MOVE TO NEXT ONE");
      // set current puzzle status as completed
      puzzleStatus = PuzzleStatus.complete;
    }
    return _solved;
  }
}
