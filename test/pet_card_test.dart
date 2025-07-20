import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/models/pet.dart';
import 'package:pet_adoption_app/widgets/pet_card.dart';

void main() {
  testWidgets('PetCard displays pet name and image',
      (WidgetTester tester) async {
    final pet = Pet(
      id: '1',
      name: 'Fluffy',
      imageUrl: 'https://example.com/image.jpg',
      age: 2,
      price: 100,
      type: 'cat',
    );

    await tester.pumpWidget(MaterialApp(home: PetCard(pet: pet)));

    expect(find.text('Fluffy'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
