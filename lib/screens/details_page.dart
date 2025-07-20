import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/adoption_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../models/pet.dart';

class DetailsPage extends StatefulWidget {
  final Pet pet;
  const DetailsPage({super.key, required this.pet});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with TickerProviderStateMixin {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeChanged
            ? themeState.themeMode == ThemeMode.dark
            : Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor ??
              (isDarkMode ? Colors.grey[900] : Colors.grey[50]),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    backgroundColor: Theme.of(context).cardColor ??
                        (isDarkMode ? Colors.grey[800] : Colors.white),
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor ??
                            (isDarkMode ? Colors.grey[800] : Colors.white),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.color ??
                                (isDarkMode ? Colors.white : Colors.black87)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor ??
                              (isDarkMode ? Colors.grey[800] : Colors.white),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _favoriteAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _favoriteScaleAnimation.value,
                              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                                buildWhen: (previous, current) =>
                                    current is FavoriteUpdated &&
                                    (previous is! FavoriteUpdated ||
                                        previous.favorites !=
                                            current.favorites ||
                                        previous.isFavorite !=
                                            current.isFavorite),
                                builder: (context, state) {
                                  final isFavorited =
                                      state is FavoriteUpdated &&
                                          state.isFavorite &&
                                          context
                                              .read<FavoriteBloc>()
                                              .isPetFavorite(widget.pet.id);
                                  return IconButton(
                                    icon: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey(isFavorited),
                                        color: isFavorited
                                            ? Colors.red
                                            : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color ??
                                                (isDarkMode
                                                    ? Colors.grey[300]
                                                    : Colors.black54),
                                      ),
                                    ),
                                    onPressed: () {
                                      final petCopy = Pet(
                                        id: widget.pet.id,
                                        name: widget.pet.name,
                                        imageUrl: widget.pet.imageUrl,
                                        type: widget.pet.type,
                                        age: widget.pet.age,
                                        price: widget.pet.price,
                                        breed: widget.pet.breed,
                                        location: widget.pet.location,
                                      );
                                      _favoriteAnimationController
                                          .forward()
                                          .then((_) =>
                                              _favoriteAnimationController
                                                  .reverse());
                                      context
                                          .read<FavoriteBloc>()
                                          .add(ToggleFavorite(petCopy));
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black87,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(20),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.pet.imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor ??
                                              (isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.white),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.close,
                                            color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.color ??
                                                (isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'pet_image_${widget.pet.id}',
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.pet.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context).cardColor ??
                                      (isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.pet.name,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.color ??
                                        (isDarkMode
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.pet.type,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildInfoCard(
                                icon: Icons.cake,
                                label: 'Age',
                                value: '${widget.pet.age} years',
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 16),
                              _buildInfoCard(
                                icon: Icons.attach_money,
                                label: 'Price',
                                value:
                                    '\$${widget.pet.price.toStringAsFixed(2)}',
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'About ${widget.pet.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'This adorable ${widget.pet.type.toLowerCase()} is looking for a loving home. ${widget.pet.name} is ${widget.pet.age} years old and full of energy and love to give. Ready to bring joy and companionship to your life!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  (isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.black54),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                          BlocBuilder<AdoptionBloc, AdoptionState>(
                            builder: (context, state) {
                              final isAdopted = context
                                  .read<AdoptionBloc>()
                                  .isPetAdopted(widget.pet.id);
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isAdopted
                                    ? Container(
                                        key: const ValueKey('adopted'),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).disabledColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color ??
                                                  (isDarkMode
                                                      ? Colors.grey[300]
                                                      : Colors.black54),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Already Adopted',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color ??
                                                    (isDarkMode
                                                        ? Colors.grey[300]
                                                        : Colors.black54),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: GestureDetector(
                                          key: const ValueKey('adopt'),
                                          onTapDown: (_) =>
                                              _scaleController.forward(),
                                          onTapUp: (_) =>
                                              _scaleController.reverse(),
                                          onTapCancel: () =>
                                              _scaleController.reverse(),
                                          onTap: () {
                                            final petCopy = Pet(
                                              id: widget.pet.id,
                                              name: widget.pet.name,
                                              imageUrl: widget.pet.imageUrl,
                                              type: widget.pet.type,
                                              age: widget.pet.age,
                                              price: widget.pet.price,
                                              breed: widget.pet.breed,
                                              location: widget.pet.location,
                                            );
                                            context
                                                .read<AdoptionBloc>()
                                                .add(AdoptPet(petCopy));
                                            _showAdoptionDialog(context);
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.45),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.favorite,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Adopt Me',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
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
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.purple,
                  ],
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.05,
                  shouldLoop: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.black54),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineSmall?.color ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve successfully adopted ${widget.pet.name}!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.black54),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _confettiController.stop();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
