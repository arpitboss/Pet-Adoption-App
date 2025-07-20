// theme_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class LoadTheme extends ThemeEvent {
  const LoadTheme();

  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();

  @override
  List<Object> get props => [];
}

class SetTheme extends ThemeEvent {
  final ThemeMode themeMode;
  const SetTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class GetCurrentTheme extends ThemeEvent {
  const GetCurrentTheme();

  @override
  List<Object> get props => [];
}

abstract class ThemeState extends Equatable {
  const ThemeState();
}

class ThemeInitial extends ThemeState {
  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeState {
  final ThemeMode themeMode;
  final bool isAnimating;

  const ThemeChanged(this.themeMode, {this.isAnimating = false});

  @override
  List<Object> get props => [themeMode, isAnimating];
}

class ThemeLoading extends ThemeState {
  @override
  List<Object> get props => [];
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeMode';

  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
    on<GetCurrentTheme>(_onGetCurrentTheme);

    // Load saved theme on initialization
    add(const LoadTheme());
  }

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final box = await Hive.openBox(_boxName);
      final savedMode =
          box.get(_themeKey, defaultValue: ThemeMode.system.index);
      emit(ThemeChanged(ThemeMode.values[savedMode]));
    } catch (e) {
      emit(const ThemeChanged(ThemeMode.system));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ThemeChanged) {
        emit(ThemeChanged(currentState.themeMode, isAnimating: true));

        final newMode = currentState.themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;

        final box = await Hive.openBox(_boxName);
        await box.put(_themeKey, newMode.index);

        // Small delay for smooth animation
        await Future.delayed(const Duration(milliseconds: 100));

        emit(ThemeChanged(newMode, isAnimating: false));
      }
    } catch (e) {
      if (state is ThemeChanged) {
        emit(ThemeChanged((state as ThemeChanged).themeMode,
            isAnimating: false));
      }
    }
  }

  Future<void> _onSetTheme(
    SetTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, event.themeMode.index);
      emit(ThemeChanged(event.themeMode));
    } catch (e) {
      if (state is ThemeChanged) {
        emit(state as ThemeChanged);
      }
    }
  }

  Future<void> _onGetCurrentTheme(
    GetCurrentTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(ThemeLoading());
      final box = await Hive.openBox(_boxName);
      final savedMode =
          box.get(_themeKey, defaultValue: ThemeMode.system.index);
      emit(ThemeChanged(ThemeMode.values[savedMode]));
    } catch (e) {
      emit(const ThemeChanged(ThemeMode.system));
    }
  }

  ThemeMode getCurrentTheme() {
    if (state is ThemeChanged) {
      return (state as ThemeChanged).themeMode;
    }
    return ThemeMode.system;
  }

  bool isThemeAnimating() {
    if (state is ThemeChanged) {
      return (state as ThemeChanged).isAnimating;
    }
    return false;
  }

  bool get isDarkMode {
    if (state is ThemeChanged) {
      return (state as ThemeChanged).themeMode == ThemeMode.dark;
    }
    return false; // Default to light mode
  }
}
