import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pet_adoption_app/blocs/pet_list_bloc.dart';
import 'package:pet_adoption_app/models/pet.dart';
import 'package:pet_adoption_app/repositories/pet_repository.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late PetListBloc petListBloc;
  late MockPetRepository mockPetRepository;

  setUp(() {
    mockPetRepository = MockPetRepository();
    petListBloc = PetListBloc(mockPetRepository);
  });

  blocTest<PetListBloc, PetListState>(
    'emits [PetListLoading, PetListLoaded] when LoadPets succeeds',
    build: () {
      when(mockPetRepository.getPets(1, 10)).thenAnswer((_) async => [
            Pet(
                id: '1',
                name: 'Test',
                imageUrl: 'url',
                age: 2,
                price: 100,
                type: 'cat')
          ]);
      return petListBloc;
    },
    act: (bloc) => bloc.add(LoadPets()),
    expect: () => [
      PetListLoading(),
      PetListLoaded([
        Pet(
            id: '1',
            name: 'Test',
            imageUrl: 'url',
            age: 2,
            price: 100,
            type: 'cat')
      ]),
    ],
  );
}
