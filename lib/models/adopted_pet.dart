import 'package:hive/hive.dart';
import 'pet.dart';

part 'adopted_pet.g.dart';

@HiveType(typeId: 1)
class AdoptedPet {
  @HiveField(0)
  final Pet pet;

  @HiveField(1)
  final DateTime adoptionTime;

  AdoptedPet({required this.pet, required this.adoptionTime});
}