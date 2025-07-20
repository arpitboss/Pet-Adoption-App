import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/adoption_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../models/pet.dart';
import '../screens/details_page.dart';

class PetCard extends StatefulWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  _PetCardState createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;
  late Animation<double> _favoriteRotationAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.elasticOut,
    ));

    _favoriteRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.easeInOut,
    ));

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _favoriteAnimationController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeChanged
            ? themeState.themeMode == ThemeMode.dark
            : Theme.of(context).brightness == Brightness.dark;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: AnimatedBuilder(
                      animation: _hoverAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -4 * _hoverAnimation.value),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.08),
                                  blurRadius: 20 + (10 * _hoverAnimation.value),
                                  offset: Offset(
                                      0, 8 + (4 * _hoverAnimation.value)),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  blurRadius: 30 + (10 * _hoverAnimation.value),
                                  offset: const Offset(0, 4),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Material(
                              elevation: 0,
                              borderRadius: BorderRadius.circular(32),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(pet: widget.pet),
                                    ),
                                  );
                                },
                                onHover: (hovering) {
                                  if (hovering) {
                                    _hoverController.forward();
                                  } else {
                                    _hoverController.reverse();
                                  }
                                },
                                child: Container(
                                  height: 380, // Increased height slightly
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDarkMode
                                          ? [
                                              Colors.grey.shade900,
                                              Colors.grey.shade800,
                                            ]
                                          : [
                                              Colors.white,
                                              Colors.grey.shade50,
                                            ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(32),
                                            gradient: RadialGradient(
                                              center: Alignment.topRight,
                                              radius: 1.5,
                                              colors: [
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.03),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(32),
                                                      ),
                                                      child: Hero(
                                                        tag:
                                                            'pet_image_${widget.pet.id}',
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: widget
                                                              .pet.imageUrl,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        32),
                                                              ),
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.1),
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.05),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.9),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      3,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        32),
                                                              ),
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Colors.grey
                                                                      .shade300,
                                                                  Colors.grey
                                                                      .shade100,
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                ),
                                                                child: Icon(
                                                                  Icons.pets,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Floating Favorite Button
                                                  Positioned(
                                                    top: 20,
                                                    right: 20,
                                                    child: AnimatedBuilder(
                                                      animation:
                                                          _favoriteAnimationController,
                                                      builder:
                                                          (context, child) {
                                                        return Transform.scale(
                                                          scale:
                                                              _favoriteScaleAnimation
                                                                  .value,
                                                          child:
                                                              Transform.rotate(
                                                            angle:
                                                                _favoriteRotationAnimation
                                                                    .value,
                                                            child: BlocBuilder<
                                                                FavoriteBloc,
                                                                FavoriteState>(
                                                              builder: (context,
                                                                  state) {
                                                                final isFavorited = context
                                                                    .read<
                                                                        FavoriteBloc>()
                                                                    .isPetFavorite(
                                                                        widget
                                                                            .pet
                                                                            .id);
                                                                return Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: isFavorited
                                                                          ? [
                                                                              Colors.red.shade400,
                                                                              Colors.red.shade600,
                                                                            ]
                                                                          : [
                                                                              Colors.white,
                                                                              Colors.grey.shade50,
                                                                            ],
                                                                    ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: isFavorited
                                                                            ? Colors.red.withOpacity(0.4)
                                                                            : Colors.black.withOpacity(0.15),
                                                                        blurRadius:
                                                                            15,
                                                                        offset: const Offset(
                                                                            0,
                                                                            6),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        InkWell(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                      onTap:
                                                                          () {
                                                                        _favoriteAnimationController
                                                                            .forward()
                                                                            .then((_) =>
                                                                                _favoriteAnimationController.reverse());
                                                                        context
                                                                            .read<FavoriteBloc>()
                                                                            .add(ToggleFavorite(widget.pet));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12),
                                                                        child:
                                                                            AnimatedSwitcher(
                                                                          duration:
                                                                              const Duration(milliseconds: 300),
                                                                          transitionBuilder:
                                                                              (child, animation) {
                                                                            return ScaleTransition(
                                                                              scale: animation,
                                                                              child: child,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            isFavorited
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            key:
                                                                                ValueKey(isFavorited),
                                                                            color: isFavorited
                                                                                ? Colors.white
                                                                                : Colors.grey.shade600,
                                                                            size:
                                                                                24,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 20,
                                                    left: 20,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors:
                                                              widget.pet.type ==
                                                                      'dog'
                                                                  ? [
                                                                      Colors
                                                                          .indigo
                                                                          .shade400,
                                                                      Colors
                                                                          .indigo
                                                                          .shade600
                                                                    ]
                                                                  : [
                                                                      Colors
                                                                          .amber
                                                                          .shade400,
                                                                      Colors
                                                                          .amber
                                                                          .shade600
                                                                    ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: (widget.pet
                                                                            .type ==
                                                                        'dog'
                                                                    ? Colors
                                                                        .indigo
                                                                    : Colors
                                                                        .amber)
                                                                .withOpacity(
                                                                    0.4),
                                                            blurRadius: 12,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            widget.pet.type ==
                                                                    'dog'
                                                                ? Icons.pets
                                                                : Icons.pets,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            widget.pet.type
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                widget.pet.name,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headlineSmall
                                                                      ?.color,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              Text(
                                                                '${widget.pet.age} year${widget.pet.age == 1 ? '' : 's'} old',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.color
                                                                      ?.withOpacity(
                                                                          0.7),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Price Badge
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.teal
                                                                    .shade400,
                                                                Colors.teal
                                                                    .shade600,
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .green
                                                                    .withOpacity(
                                                                        0.3),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                        0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            '\$${widget.pet.price.toStringAsFixed(0)}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize:
                                                                  16, // Slightly smaller
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Adopt Button
                                                  BlocBuilder<AdoptionBloc,
                                                      AdoptionState>(
                                                    builder: (context, state) {
                                                      final isAdopted = state
                                                              is AdoptionSuccess &&
                                                          state.adoptedPets.any(
                                                              (p) =>
                                                                  p.pet.id ==
                                                                  widget
                                                                      .pet.id);
                                                      return AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                        child: isAdopted
                                                            ? Container(
                                                                key: const ValueKey(
                                                                    'adopted'),
                                                                width: double
                                                                    .infinity,
                                                                height: 48,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .shade300,
                                                                      Colors
                                                                          .grey
                                                                          .shade400,
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              24),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      blurRadius:
                                                                          6,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              3),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            3),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .check,
                                                                          color: Colors
                                                                              .green
                                                                              .shade600,
                                                                          size:
                                                                              18,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Text(
                                                                        'Already Adopted',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                key: const ValueKey(
                                                                    'adopt'),
                                                                width: double
                                                                    .infinity,
                                                                height: 48,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              0.45),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              24),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              0.4),
                                                                      blurRadius:
                                                                          12,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              4),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24),
                                                                    onTap: () => context
                                                                        .read<
                                                                            AdoptionBloc>()
                                                                        .add(AdoptPet(
                                                                            widget.pet)),
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(5),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.white.withOpacity(0.2),
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            child:
                                                                                const Icon(
                                                                              Icons.favorite,
                                                                              color: Colors.white,
                                                                              size: 18,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Flexible(
                                                                            child:
                                                                                Text(
                                                                              'Adopt ${widget.pet.name}',
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
