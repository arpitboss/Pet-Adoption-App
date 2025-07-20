import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../repositories/pet_repository.dart';

// Events
abstract class PetListEvent {}

class LoadPets extends PetListEvent {
  final int page;
  final int limit;
  LoadPets({this.page = 1, this.limit = 10});
}

class LoadMorePets extends PetListEvent {
  final int limit;
  LoadMorePets({this.limit = 10});
}

class SearchPets extends PetListEvent {
  final String query;
  SearchPets(this.query);
}

class RefreshPets extends PetListEvent {
  final int limit;
  RefreshPets({this.limit = 10});
}

class FilterPets extends PetListEvent {
  final String? type;
  final String? age;
  final String? price;
  final String? location;
  FilterPets({this.type, this.age, this.price, this.location});
}

class ClearFilters extends PetListEvent {}

class ResetPetList extends PetListEvent {}

// States
abstract class PetListState {}

class PetListInitial extends PetListState {}

class PetListLoading extends PetListState {}

class PetListLoaded extends PetListState {
  final List<Pet> pets;
  final bool hasMore;
  PetListLoaded(this.pets, {this.hasMore = true});
}

class PetListError extends PetListState {
  final String message;
  PetListError(this.message);
}

class PetListRefreshing extends PetListState {}

class PetListFiltered extends PetListState {
  final List<Pet> pets;
  final Map<String, String> activeFilters;
  final bool hasMore;
  PetListFiltered(this.pets, this.activeFilters, {this.hasMore = true});
}

class PetListBloc extends Bloc<PetListEvent, PetListState> {
  final PetRepository petRepository;
  int currentPage = 0;
  List<Pet> allPets = [];
  List<Pet> originalPets = [];
  Map<String, String> activeFilters = {};
  String currentSearchQuery = '';

  PetListBloc(this.petRepository) : super(PetListInitial()) {
    on<LoadPets>((event, emit) async {
      emit(PetListLoading());
      try {
        final pets = await petRepository.getPets(event.page, event.limit);
        currentPage = event.page;
        allPets = pets;
        originalPets = List.from(pets);
        print('Loaded ${pets.length} pets');
        emit(PetListLoaded(pets, hasMore: pets.length >= event.limit));
      } catch (e) {
        emit(PetListError(e.toString()));
      }
    });

    on<LoadMorePets>((event, emit) async {
      if ((state is PetListLoaded || state is PetListFiltered) &&
          (state as dynamic).hasMore) {
        try {
          final pets =
              await petRepository.getPets(currentPage + 1, event.limit);
          currentPage++;
          allPets.addAll(pets);
          originalPets.addAll(pets);

          List<Pet> filteredPets = _applyFiltersAndSearch(allPets);
          if (kDebugMode) {
            print(
                'Loaded more: ${pets.length}, Total: ${allPets.length}, Filtered: ${filteredPets.length}');
          }
          emit(
              PetListLoaded(filteredPets, hasMore: pets.length >= event.limit));
        } catch (e) {
          emit(PetListError(e.toString()));
        }
      }
    });

    on<SearchPets>((event, emit) {
      currentSearchQuery = event.query;
      final filteredPets = _applyFiltersAndSearch(allPets);
      if (kDebugMode) {
        print(
            'Search query: "$currentSearchQuery", Filtered: ${filteredPets.length}');
      }
      emit(PetListLoaded(filteredPets, hasMore: false));
    });

    on<RefreshPets>((event, emit) async {
      emit(PetListRefreshing());
      try {
        final pets = await petRepository.getPets(1, event.limit);
        currentPage = 1;
        allPets = pets;
        originalPets = List.from(pets);
        activeFilters.clear();
        currentSearchQuery = '';
        if (kDebugMode) {
          print('Refreshed ${pets.length} pets');
        }
        emit(PetListLoaded(pets, hasMore: pets.length >= event.limit));
      } catch (e) {
        emit(PetListError(e.toString()));
      }
    });

    on<FilterPets>((event, emit) {
      currentSearchQuery = '';
      activeFilters.clear(); // Clear previous filters
      if (event.type != null) activeFilters['type'] = event.type!;
      if (event.age != null) activeFilters['age'] = event.age!;
      if (event.price != null) activeFilters['price'] = event.price!;
      if (event.location != null) activeFilters['location'] = event.location!;

      final filteredPets = _applyFiltersAndSearch(allPets);
      if (kDebugMode) {
        print(
            'Applied filters: $activeFilters, Filtered: ${filteredPets.length}');
      }
      emit(PetListFiltered(filteredPets, Map.from(activeFilters),
          hasMore: false));
    });

    on<ClearFilters>((event, emit) {
      activeFilters.clear();
      currentSearchQuery = '';
      if (kDebugMode) {
        print('Cleared filters, showing ${allPets.length} pets');
      }
      emit(PetListLoaded(allPets, hasMore: true));
    });

    on<ResetPetList>((event, emit) {
      currentPage = 0;
      allPets.clear();
      originalPets.clear();
      activeFilters.clear();
      currentSearchQuery = '';
      emit(PetListInitial());
    });
  }

  List<Pet> _applyFiltersAndSearch(List<Pet> pets) {
    List<Pet> filteredPets = List.from(pets);

    if (currentSearchQuery.isNotEmpty) {
      filteredPets = filteredPets
          .where((pet) =>
              pet.name
                  .toLowerCase()
                  .contains(currentSearchQuery.toLowerCase()) ||
              (pet.breed
                      ?.toLowerCase()
                      .contains(currentSearchQuery.toLowerCase()) ??
                  false) ||
              (pet.location
                      ?.toLowerCase()
                      .contains(currentSearchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    if (activeFilters.containsKey('type')) {
      filteredPets = filteredPets
          .where((pet) =>
              pet.type.toLowerCase() == activeFilters['type']?.toLowerCase())
          .toList();
    }

    if (activeFilters.containsKey('age')) {
      final ageFilter = activeFilters['age'];
      filteredPets = filteredPets.where((pet) {
        if (ageFilter == 'young') return pet.age <= 3;
        if (ageFilter == 'adult') return pet.age > 3;
        return true;
      }).toList();
    }

    if (activeFilters.containsKey('price')) {
      final priceFilter = activeFilters['price'];
      filteredPets = filteredPets.where((pet) {
        if (priceFilter == 'low') return pet.price < 500;
        if (priceFilter == 'medium') {
          return pet.price >= 500 && pet.price < 1000;
        }
        if (priceFilter == 'high') return pet.price >= 1000;
        return true;
      }).toList();
    }

    if (activeFilters.containsKey('location')) {
      filteredPets = filteredPets
          .where((pet) =>
              pet.location?.toLowerCase() ==
              activeFilters['location']?.toLowerCase())
          .toList();
    }

    return filteredPets;
  }

  Map<String, String> getCurrentFilters() => Map.from(activeFilters);

  bool hasActiveFilters() =>
      activeFilters.isNotEmpty || currentSearchQuery.isNotEmpty;
}
