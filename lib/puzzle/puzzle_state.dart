import 'package:equatable/equatable.dart';
import '../constants.dart';
import '../models/models.dart';

enum PuzzleStatus { inactive, active, complete }

class PuzzleState extends Equatable {
  const PuzzleState({
    this.level = const Level(id: 0, difficulty: 0, minimumMoves: 0, medianMoves: 0, blueprints: []),
    this.puzzleStatus = PuzzleStatus.inactive,
    this.numberOfMoves = 0,
    this.numberOfResets = 0,
    this.goBackAttempts = kMaxGoBackPerPuzzle,
    // this.lastTappedTile,
  });

  final Level level;
  final PuzzleStatus puzzleStatus;
  final int numberOfMoves;
  final int numberOfResets;
  final int goBackAttempts;

  // implement copyWith method
  PuzzleState copyWith({
    Level? level,
    PuzzleStatus? puzzleStatus,
    int? numberOfMoves,
    int? numberOfResets,
    int? goBackAttempts,
  }) {
    return PuzzleState(
      level: level ?? this.level.copyWith(),
      puzzleStatus: puzzleStatus ?? this.puzzleStatus,
      numberOfMoves: numberOfMoves ?? this.numberOfMoves,
      numberOfResets: numberOfResets ?? this.numberOfResets,
      goBackAttempts: goBackAttempts ?? this.goBackAttempts,
    );
  }

  @override
  List<Object?> get props => [
        level,
        puzzleStatus,
        numberOfMoves,
        numberOfResets,
        goBackAttempts,
      ];
}
