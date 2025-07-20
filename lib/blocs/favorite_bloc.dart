import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/pet.dart';

abstract class FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final Pet pet;
  ToggleFavorite(this.pet);
}

class GetFavorites extends FavoriteEvent {}

class CheckIfFavorite extends FavoriteEvent {
  final String petId;
  CheckIfFavorite(this.petId);
}

class RemoveFavorite extends FavoriteEvent {
  final String petId;
  RemoveFavorite(this.petId);
}

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteUpdated extends FavoriteState {
  final List<Pet> favorites;
  final bool isFavorite;
  FavoriteUpdated(this.favorites, {this.isFavorite = false});
}

class FavoriteLoading extends FavoriteState {}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<ToggleFavorite>((event, emit) async {
      try {
        final box = Hive.box<Pet>('favorite_pets');

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

        if (box.containsKey(event.pet.id)) {
          await box.delete(event.pet.id);
          if (kDebugMode) {
            print('Removed favorite: ${event.pet.id}');
          }
        } else {
          await box.put(event.pet.id, petCopy);
          if (kDebugMode) {
            print('Added favorite: ${event.pet.id}');
          }
        }

        final favorites = box.values.toList();
        if (kDebugMode) {
          print('Favorites updated: ${favorites.length}');
        }
        emit(FavoriteUpdated(favorites,
            isFavorite: box.containsKey(event.pet.id)));
      } catch (e) {
        if (kDebugMode) {
          print('Error toggling favorite: $e');
        }
        emit(FavoriteError('Failed to toggle favorite: ${e.toString()}'));
      }
    });

    on<GetFavorites>((event, emit) async {
      try {
        final box = Hive.box<Pet>('favorite_pets');
        final favorites = box.values.toList();
        if (kDebugMode) {
          print('Loaded favorites: ${favorites.length}');
        }
        emit(FavoriteUpdated(favorites));
      } catch (e) {
        if (kDebugMode) {
          print('Error loading favorites: $e');
        }
        emit(FavoriteError('Failed to load favorites: ${e.toString()}'));
      }
    });

    on<CheckIfFavorite>((event, emit) async {
      try {
        final box = Hive.box<Pet>('favorite_pets');
        final isFavorite = box.containsKey(event.petId);
        if (kDebugMode) {
          print('Checked favorite status for pet ${event.petId}: $isFavorite');
        }
        final favorites = box.values.toList();
        emit(FavoriteUpdated(favorites, isFavorite: isFavorite));
      } catch (e) {
        if (kDebugMode) {
          print('Error checking favorite status: $e');
        }
        emit(FavoriteError('Failed to check favorite status: ${e.toString()}'));
      }
    });

    on<RemoveFavorite>((event, emit) async {
      try {
        final box = Hive.box<Pet>('favorite_pets');
        await box.delete(event.petId);
        final favorites = box.values.toList();
        if (kDebugMode) {
          print(
              'Removed favorite: ${event.petId}, Total favorites: ${favorites.length}');
        }
        emit(FavoriteUpdated(favorites));
      } catch (e) {
        if (kDebugMode) {
          print('Error removing favorite: $e');
        }
        emit(FavoriteError('Failed to remove favorite: ${e.toString()}'));
      }
    });

    _initializeFavorites();
  }

  void _initializeFavorites() {
    final box = Hive.box<Pet>('favorite_pets');
    if (box.isNotEmpty) {
      final favorites = box.values.toList();
      if (kDebugMode) {
        print('Initialized with ${favorites.length} favorites');
      }
      emit(FavoriteUpdated(favorites));
    }
  }

  bool isPetFavorite(String petId) {
    final box = Hive.box<Pet>('favorite_pets');
    return box.containsKey(petId);
  }
}
