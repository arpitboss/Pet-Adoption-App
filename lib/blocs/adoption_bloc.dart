import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/adopted_pet.dart';
import '../models/pet.dart';

abstract class AdoptionEvent {}

class GetAdoptedPets extends AdoptionEvent {}

class CheckIfAdopted extends AdoptionEvent {
  final String petId;
  CheckIfAdopted(this.petId);
}

class AdoptPet extends AdoptionEvent {
  final Pet pet;
  AdoptPet(this.pet);
}

abstract class AdoptionState {}

class AdoptionInitial extends AdoptionState {}

class AdoptionSuccess extends AdoptionState {
  final List<AdoptedPet> adoptedPets;
  AdoptionSuccess(this.adoptedPets);
}

class AdoptionLoading extends AdoptionState {}

class AdoptionError extends AdoptionState {
  final String message;
  AdoptionError(this.message);
}

class PetAdoptionStatus extends AdoptionState {
  final bool isAdopted;
  PetAdoptionStatus(this.isAdopted);
}

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  AdoptionBloc() : super(AdoptionInitial()) {
    on<AdoptPet>((event, emit) async {
      try {
        emit(AdoptionLoading());
        final box = Hive.box<AdoptedPet>('adopted_pets');

        if (box.containsKey(event.pet.id)) {
          emit(AdoptionError('Pet already adopted'));
          return;
        }

        final petCopy = Pet(
          id: event.pet.id,
          name: event.pet.name,
          imageUrl: event.pet.imageUrl,
          type: event.pet.type,
          age: event.pet.age,
          price: event.pet.price,
          breed: event.pet.breed,
          location: event.pet.location,
        );

        final adoptedPet =
            AdoptedPet(pet: petCopy, adoptionTime: DateTime.now());
        await box.put(event.pet.id, adoptedPet);

        final adoptedPets = box.values.toList()
          ..sort((a, b) => b.adoptionTime.compareTo(a.adoptionTime));
        if (kDebugMode) {
          print(
              'Adopted pet: ${event.pet.id}, Total adopted: ${adoptedPets.length}');
        }
        emit(AdoptionSuccess(adoptedPets));
      } catch (e) {
        if (kDebugMode) {
          print('Error adopting pet: $e');
        }
        emit(AdoptionError('Failed to adopt pet: ${e.toString()}'));
      }
    });

    on<GetAdoptedPets>((event, emit) async {
      try {
        emit(AdoptionLoading());
        final box = Hive.box<AdoptedPet>('adopted_pets');
        final adoptedPets = box.values.toList()
          ..sort((a, b) => b.adoptionTime.compareTo(a.adoptionTime));
        if (kDebugMode) {
          print('Loaded adopted pets: ${adoptedPets.length}');
        }
        emit(AdoptionSuccess(adoptedPets));
      } catch (e) {
        if (kDebugMode) {
          print('Error loading adopted pets: $e');
        }
        emit(AdoptionError('Failed to load adopted pets: ${e.toString()}'));
      }
    });

    on<CheckIfAdopted>((event, emit) async {
      try {
        final box = Hive.box<AdoptedPet>('adopted_pets');
        final isAdopted = box.containsKey(event.petId);
        if (kDebugMode) {
          print('Checked adoption status for pet ${event.petId}: $isAdopted');
        }
        emit(PetAdoptionStatus(isAdopted));
      } catch (e) {
        if (kDebugMode) {
          print('Error checking adoption status: $e');
        }
        emit(AdoptionError('Failed to check adoption status: ${e.toString()}'));
      }
    });

    _initializeAdoptedPets();
  }

  void _initializeAdoptedPets() {
    final box = Hive.box<AdoptedPet>('adopted_pets');
    if (box.isNotEmpty) {
      final adoptedPets = box.values.toList()
        ..sort((a, b) => b.adoptionTime.compareTo(a.adoptionTime));
      if (kDebugMode) {
        print('Initialized with ${adoptedPets.length} adopted pets');
      }
      emit(AdoptionSuccess(adoptedPets));
    }
  }

  bool isPetAdopted(String petId) {
    final box = Hive.box<AdoptedPet>('adopted_pets');
    return box.containsKey(petId);
  }
}
