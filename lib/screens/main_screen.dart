import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/adoption_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/theme_bloc.dart';
import 'favorites_page.dart';
import 'history_page.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _appBarAnimationController;
  late AnimationController _navBarAnimationController;
  late Animation<double> _appBarSlideAnimation;
  late Animation<double> _navBarSlideAnimation;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconRotationAnimation;

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const FavoritesPage(),
  ];

  final List<String> _titles = [
    'Pet Adoption',
    'Adoption History',
    'Favorite Pets',
  ];

  final List<IconData> _icons = [
    Icons.pets_rounded,
    Icons.history_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _navBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.elasticOut,
    ));

    _navBarSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navBarAnimationController,
      curve: Curves.elasticOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      _appBarAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _navBarAnimationController.forward();
    });

    _initializeBLOCs();
  }

  void _initializeBLOCs() {
    context.read<FavoriteBloc>().add(GetFavorites());
    context.read<AdoptionBloc>().add(GetAdoptedPets());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _appBarAnimationController.dispose();
    _navBarAnimationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeChanged
            ? themeState.themeMode == ThemeMode.dark
            : Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          extendBody: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedBuilder(
              animation: _appBarAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _appBarSlideAnimation.value),
                  child: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [
                                  Colors.grey.shade900.withOpacity(0.95),
                                  Colors.grey.shade800.withOpacity(0.95),
                                ]
                              : [
                                  Colors.white.withOpacity(0.95),
                                  Colors.grey.shade50.withOpacity(0.95),
                                ],
                        ),
                      ),
                    ),
                    title: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey(_currentIndex),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[_currentIndex],
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _titles[_currentIndex],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ClipRect(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Notifications Badge (if on home page)
                            if (_currentIndex == 0)
                              BlocBuilder<AdoptionBloc, AdoptionState>(
                                builder: (context, state) {
                                  final adoptionCount = state is AdoptionSuccess
                                      ? state.adoptedPets.length
                                      : 0;

                                  return Flexible(
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 60),
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.notifications_outlined,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '$adoptionCount pets adopted!'),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          if (adoptionCount > 0)
                                            Positioned(
                                              right: 6,
                                              top: 6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red
                                                          .withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 18,
                                                  minHeight: 18,
                                                ),
                                                child: Text(
                                                  adoptionCount > 99
                                                      ? '99+'
                                                      : adoptionCount
                                                          .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, state) {
                                final isAnimating =
                                    state is ThemeChanged && state.isAnimating;

                                return Flexible(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 60),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.orange.shade500
                                          : Colors.teal.shade500,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDarkMode
                                                  ? Colors.orange
                                                  : Colors.teal)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: AnimatedBuilder(
                                        animation: _iconAnimationController,
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: isAnimating
                                                ? _iconRotationAnimation.value *
                                                    2 *
                                                    3.14159
                                                : 0,
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              transitionBuilder: (Widget child,
                                                  Animation<double> animation) {
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                );
                                              },
                                              child: Icon(
                                                isDarkMode
                                                    ? Icons.light_mode_rounded
                                                    : Icons.dark_mode_rounded,
                                                key: ValueKey(isDarkMode),
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      onPressed: () {
                                        _iconAnimationController
                                            .forward()
                                            .then((_) {
                                          _iconAnimationController.reset();
                                        });
                                        context
                                            .read<ThemeBloc>()
                                            .add(const ToggleTheme());
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _navBarAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _navBarSlideAnimation.value),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: _onNavBarTap,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: Theme.of(context).primaryColor,
                      unselectedItemColor: Colors.grey.shade500,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      items: [
                        _buildNavItem(Icons.home_rounded, 'Home', 0),
                        _buildNavItem(Icons.history_rounded, 'History', 1),
                        _buildNavItem(Icons.favorite_rounded, 'Favorites', 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
            ),
          ),
          if (index == 2)
            BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                final favCount =
                    state is FavoriteUpdated ? state.favorites.length : 0;

                if (favCount == 0) return const SizedBox.shrink();

                return Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      favCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          // Badge for adoption history count
          if (index == 1)
            BlocBuilder<AdoptionBloc, AdoptionState>(
              builder: (context, state) {
                final adoptionCount =
                    state is AdoptionSuccess ? state.adoptedPets.length : 0;

                if (adoptionCount == 0) return const SizedBox.shrink();

                return Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade600],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      adoptionCount > 99 ? '99+' : adoptionCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      label: label,
    );
  }
}
