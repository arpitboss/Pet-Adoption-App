import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'blocs/adoption_bloc.dart';
import 'blocs/favorite_bloc.dart';
import 'blocs/pet_list_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'models/adopted_pet.dart';
import 'models/pet.dart';
import 'repositories/pet_repository.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(PetAdapter());
  Hive.registerAdapter(AdoptedPetAdapter());
  await Hive.openBox<Pet>('favorite_pets');
  await Hive.openBox<AdoptedPet>('adopted_pets');
  await Hive.openBox('settings');
  await Hive.openBox('pets');

  await dotenv.load(fileName: ".env");

  runApp(PetAdoptionApp());
}

class PetAdoptionApp extends StatelessWidget {
  final petRepository = PetRepository(httpClient: http.Client());

  PetAdoptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()..add(const LoadTheme())),
        BlocProvider(
            create: (_) => PetListBloc(petRepository)..add(LoadPets())),
        BlocProvider(create: (_) => AdoptionBloc()),
        BlocProvider(create: (_) => FavoriteBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final themeMode = themeState is ThemeChanged
              ? themeState.themeMode
              : ThemeMode.system;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pet Adoption',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              primaryColor: Colors.teal,
              useMaterial3: true,
              scaffoldBackgroundColor:
                  const Color(0xFFF8FAFC), // A gentle off-white
              cardTheme: CardTheme(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                backgroundColor: Color(0xFFF8FAFC),
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontWeight: FontWeight.bold),
                displayMedium: TextStyle(fontWeight: FontWeight.bold),
                displaySmall: TextStyle(fontWeight: FontWeight.bold),
                headlineLarge: TextStyle(fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontWeight: FontWeight.bold),
              ).apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.white60,
                brightness: Brightness.dark,
              ),
              primaryColor: Colors.white60,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardTheme: CardTheme(
                elevation: 0,
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                backgroundColor: Colors.white60,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontWeight: FontWeight.bold),
                displayMedium: TextStyle(fontWeight: FontWeight.bold),
                displaySmall: TextStyle(fontWeight: FontWeight.bold),
                headlineLarge: TextStyle(fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontWeight: FontWeight.bold),
              ).apply(
                bodyColor: Colors.white.withOpacity(0.87),
                displayColor: Colors.white.withOpacity(0.87),
              ),
            ),
            themeMode: themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
