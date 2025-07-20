import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

part 'pet.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final int age;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final String type;
  @HiveField(6)
  final String? breed;
  @HiveField(7)
  final String? location;

  Pet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.age,
    required this.price,
    required this.type,
    this.breed,
    this.location,
  });

  factory Pet.fromJson(Map<String, dynamic> json, String type) {
    return Pet(
      id: json['id'] as String,
      name: _generateRandomName(),
      imageUrl: json['url'] as String,
      age: _generateRandomAge(),
      price: _generateRandomPrice(),
      type: type,
      breed: _generateRandomBreed(type),
      location: _generateRandomLocation(),
    );
  }

  static String _generateRandomName() {
    final names = [
      'Whiskers',
      'Spot',
      'Fluffy',
      'Max',
      'Bella',
      'Charlie',
      'Luna',
      'Simba',
      'Milo',
      'Oliver'
    ];
    return names[Random().nextInt(names.length)];
  }

  static int _generateRandomAge() => Random().nextInt(10) + 1;

  static double _generateRandomPrice() => (Random().nextDouble() * 450) + 50;

  static String? _generateRandomBreed(String type) {
    final catBreeds = [
      'Persian',
      'Siamese',
      'Maine Coon',
      'Ragdoll',
      'Bengal',
    ];
    final dogBreeds = [
      'Labrador',
      'German Shepherd',
      'Golden Retriever',
      'Bulldog',
      'Poodle',
    ];
    final breeds = type == 'cat' ? catBreeds : dogBreeds;
    return breeds[Random().nextInt(breeds.length)];
  }

  static String? _generateRandomLocation() {
    final locations = [
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Miami, FL',
    ];
    return locations[Random().nextInt(locations.length)];
  }
}
