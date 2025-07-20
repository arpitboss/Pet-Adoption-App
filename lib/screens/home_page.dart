import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/pet_list_bloc.dart';
import '../widgets/pet_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _searchOpacityAnimation;
  late Animation<double> _floatingAnimation;

  String _selectedFilter = 'all';
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _searchScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.elasticOut,
    ));

    _searchOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchAnimationController.forward();
    });

    _floatingAnimationController.repeat(reverse: true);

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    context.read<PetListBloc>().add(LoadPets());
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _floatingAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF4E4E4E),
                    const Color(0xFF1C1C1C),
                    const Color(0xFF020202),
                  ]
                : [
                    const Color(0xFFFAFBFF),
                    const Color(0xFFF0F4FF),
                    const Color(0xFFE3F2FD),
                  ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PetListBloc>().add(LoadPets());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: theme.primaryColor,
            backgroundColor:
                isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _headerSlideAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            isDarkMode
                                                ? const Color(0xFFA151DA)
                                                : const Color(0xFF1976D2),
                                            isDarkMode
                                                ? const Color(0xFFA3A3A3)
                                                : const Color(0xFF7B1FA2),
                                          ],
                                        ).createShader(bounds),
                                        child: const Text(
                                          'Discover Your',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Perfect ',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: AnimatedBuilder(
                                                animation: _floatingAnimation,
                                                builder: (context, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                        0,
                                                        _floatingAnimation
                                                                .value *
                                                            4),
                                                    child: const Text(
                                                      '🐾',
                                                      style: TextStyle(
                                                          color: Colors.white38,
                                                          fontSize: 24),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' Companion',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: theme.primaryColor
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: theme.primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Find loving homes nearby',
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: 20,
                                    child: AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            _floatingAnimation.value * 8,
                                            _floatingAnimation.value * 6,
                                          ),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.pink.withOpacity(0.3),
                                                  Colors.white60
                                                      .withOpacity(0.2),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 15,
                                    right: -15,
                                    child: AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            -_floatingAnimation.value * 6,
                                            _floatingAnimation.value * 4,
                                          ),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.withOpacity(0.2),
                                                  Colors.cyan.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _searchAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _searchScaleAnimation.value,
                                    child: Opacity(
                                      opacity: _searchOpacityAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primaryColor
                                                  .withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.15)
                                                    : Colors.white
                                                        .withOpacity(0.95),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: _isSearchFocused
                                                      ? theme.primaryColor
                                                          .withOpacity(0.45)
                                                      : (isDarkMode
                                                          ? Colors.white
                                                              .withOpacity(0.4)
                                                          : Colors.black
                                                              .withOpacity(
                                                                  0.08)),
                                                  width: _isSearchFocused
                                                      ? 2.5
                                                      : 1.5, // Dynamic width
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                focusNode: _searchFocusNode,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search for your next best friend...',
                                                  hintStyle: TextStyle(
                                                    color: isDarkMode
                                                        ? Colors.white
                                                            .withOpacity(0.6)
                                                        : Colors.black
                                                            .withOpacity(0.5),
                                                    fontSize: 15,
                                                  ),
                                                  prefixIcon: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Icon(
                                                      Icons.search_rounded,
                                                      color: _isSearchFocused
                                                          ? theme.primaryColor
                                                          : Colors
                                                              .grey.shade400,
                                                      size: 22,
                                                    ),
                                                  ),
                                                  suffixIcon: _searchController
                                                          .text.isNotEmpty
                                                      ? IconButton(
                                                          icon: Icon(
                                                            Icons.close_rounded,
                                                            color: Colors
                                                                .grey.shade400,
                                                          ),
                                                          onPressed: () {
                                                            _searchController
                                                                .clear();
                                                            context
                                                                .read<
                                                                    PetListBloc>()
                                                                .add(SearchPets(
                                                                    ''));
                                                          },
                                                        )
                                                      : null,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 20,
                                                    vertical: 14,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {});
                                                  context
                                                      .read<PetListBloc>()
                                                      .add(SearchPets(value));
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                opacity: _searchOpacityAnimation.value,
                                duration: const Duration(milliseconds: 800),
                                child: SizedBox(
                                  height: 40,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _buildModernFilterChip(
                                          'all', 'All Pets', '🐾'),
                                      const SizedBox(width: 10),
                                      _buildModernFilterChip(
                                          'dog', 'Dogs', '🐕'),
                                      const SizedBox(width: 10),
                                      _buildModernFilterChip(
                                          'cat', 'Cats', '🐱'),
                                      const SizedBox(width: 10),
                                      _buildModernFilterChip(
                                          'young', 'Puppies', '🐶'),
                                      const SizedBox(width: 10),
                                      _buildModernFilterChip(
                                          'adult', 'Adults', '🦮'),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<PetListBloc, PetListState>(
                  buildWhen: (previous, current) =>
                      previous != current &&
                      (current is PetListLoading ||
                          current is PetListLoaded ||
                          current is PetListError ||
                          current is PetListRefreshing ||
                          current is PetListFiltered),
                  builder: (context, state) {
                    if (state is PetListLoading || state is PetListRefreshing) {
                      return SliverToBoxAdapter(
                        child: _buildModernLoadingState(),
                      );
                    } else if (state is PetListLoaded ||
                        state is PetListFiltered) {
                      final pets = state is PetListLoaded
                          ? state.pets
                          : (state as PetListFiltered).pets;
                      final hasMore = state is PetListLoaded
                          ? state.hasMore
                          : (state as PetListFiltered).hasMore;
                      if (pets.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildModernEmptyState(),
                        );
                      }
                      return _buildModernPetsSliver(pets, hasMore, context);
                    } else if (state is PetListError) {
                      return SliverToBoxAdapter(
                        child: _buildModernErrorState(state.message),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: _buildModernEmptyState(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(String value, String label, String emoji) {
    final isSelected = _selectedFilter == value;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFilter = value;
          if (value != 'all') {
            _searchController.clear();
          }
        });

        final bloc = context.read<PetListBloc>();

        if (value == 'all') {
          bloc.add(ClearFilters());
        } else if (value == 'dog' || value == 'cat') {
          bloc.add(FilterPets(type: value));
        } else if (value == 'young') {
          bloc.add(FilterPets(age: 'young'));
        } else if (value == 'adult') {
          bloc.add(FilterPets(age: 'adult'));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    const Color(0xFF4B4850),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isDarkMode
                  ? const Color(0xFF2A2A3E).withOpacity(0.8)
                  : const Color(0xFFF8F9FF).withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.3)
                : isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.15),
                      const Color(0xFF4B4850),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Text(
                '🐾',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your perfect companion...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching the most adorable pets',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: Icon(
              Icons.pets_rounded,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No furry friends found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search or filters\nto discover more amazing pets',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '💡 Tip: Try searching for "dog" or "cat"',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade100,
                  Colors.red.shade50,
                ],
              ),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.read<PetListBloc>().add(LoadPets());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPetsSliver(List pets, bool hasMore, BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == pets.length) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.3),
                    ],
                  ),
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          }

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: math.max(0.0, math.min(1.0, value)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: PetCard(pet: pets[index]),
                ),
              );
            },
          );
        },
        childCount: pets.length + (hasMore ? 1 : 0),
      ),
    );
  }
}
