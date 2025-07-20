import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/pet.dart';

class PetRepository {
  final http.Client httpClient;

  PetRepository({required this.httpClient});

  Future<List<Pet>> getPets(int page, int limit) async {
    try {
      final catResponse = await httpClient.get(
        Uri.parse('${dotenv.env['CAT_API_URL']}?limit=$limit&page=$page'),
      );
      final dogResponse = await httpClient.get(
        Uri.parse('${dotenv.env['DOG_API_URL']}?limit=$limit&page=$page'),
      );

      if (catResponse.statusCode != 200 || dogResponse.statusCode != 200) {
        throw Exception('Failed to load pets');
      }

      final cats = (jsonDecode(catResponse.body) as List)
          .map((item) => Pet.fromJson(item, 'cat'))
          .toList();
      final dogs = (jsonDecode(dogResponse.body) as List)
          .map((item) => Pet.fromJson(item, 'dog'))
          .toList();
      final pets = [...cats, ...dogs];

      final box = await Hive.openBox('pets');
      await box.clear();
      await box.addAll(pets);

      return pets;
    } catch (e) {
      final box = await Hive.openBox('pets');
      if (box.isNotEmpty) {
        return box.values.cast<Pet>().toList();
      } else {
        throw Exception('No pets available offline');
      }
    }
  }
}
