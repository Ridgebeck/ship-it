import 'package:equatable/equatable.dart';
import 'package:ship_it/models/models.dart';

class Level extends Equatable {
  const Level({
    required this.id,
    required this.blueprints,
    this.isRotatingMode = false,
    this.isCoveredMode = false,
    this.isHazardMode = false,
  });

  final int id;
  final List<Blueprint> blueprints;
  final bool isRotatingMode;
  final bool isCoveredMode;
  final bool isHazardMode;

  // get length of all ships + warehouses and ships
  int get allLocationsLength => blueprints.length;
  int get numberOfShips => blueprints.where((element) => element.isWarehouse == false).length;

  // implement copyWith method
  Level copyWith({
    List<Blueprint>? blueprints,
    bool? isRotatingMode,
    bool? isCoveredMode,
    bool? isHazardMode,
  }) {
    return Level(
      id: id,
      blueprints: blueprints ??
          List.generate(this.blueprints.length, (index) => this.blueprints[index].copyWith()),
      isRotatingMode: isRotatingMode ?? this.isRotatingMode,
      isCoveredMode: isCoveredMode ?? this.isCoveredMode,
      isHazardMode: isHazardMode ?? this.isHazardMode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        blueprints,
        isRotatingMode,
        isCoveredMode,
        isHazardMode,
      ];
}
