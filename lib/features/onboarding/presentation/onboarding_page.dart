import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'TRUST NO ONE',
      'description': 'In a city of shadows, your best friend could be your worst enemy. Deception is the name of the game.',
    },
    {
      'title': 'FIND THE KILLER',
      'description': 'Use your wits, gather clues, and discuss with others to identify the Mafia before they eliminate everyone.',
    },
    {
      'title': 'SURVIVE THE NIGHT',
      'description': 'As night falls, danger awakes. Make your move carefully. Will you see the next sunrise?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background: Animated Columns of Avatars
          const Positioned.fill(child: AnimatedAvatarBackground()),
          
          // Gradient Overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, // "Light" / Clear at top to see avatars
                    AppColors.primary.withOpacity(0.5),
                    AppColors.primary, // Dark at bottom for text readability
                  ],
                  stops: const [0.0, 0.2, 0.5],
                ),
              ),
            ),
          ),

          // Foreground Content
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // Push text to bottom
                        children: [
                          Text(
                            data['title']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Gap(20),
                          Text(
                            data['description']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                  fontFamily: 'Roboto', // Fallback to readable font
                                ),
                          ),
                          const Gap(100), // Space for buttons/dots
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Controls
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 10,
                          width: _currentPage == index ? 20 : 10,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.accent
                                : AppColors.highlightLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const Gap(30),
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_currentPage < _onboardingData.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.go('/home');
                          }
                        },
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'START GAME'
                              : 'NEXT',
                          style: const TextStyle(
                            fontFamily: 'BlackOpsOne',
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedAvatarBackground extends StatefulWidget {
  const AnimatedAvatarBackground({super.key});

  @override
  State<AnimatedAvatarBackground> createState() => AnimatedAvatarBackgroundState();
}

class AnimatedAvatarBackgroundState extends State<AnimatedAvatarBackground> {
  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  late final ScrollController _scrollController3;
  late Timer _timer;

  final List<String> _avatars = [
    'assets/images/avatars/mafia.png',
    'assets/images/avatars/detective.png',
    'assets/images/avatars/doctor.png',
    'assets/images/avatars/villager.png',
    'assets/images/avatars/godfather.png',
    'assets/images/avatars/serial_killer.png',
    'assets/images/avatars/joker.png',
    'assets/images/avatars/witch.png',
    'assets/images/avatars/bodyguard.png',
    'assets/images/avatars/vigilante.png',
    'assets/images/avatars/mayor.png',
    'assets/images/avatars/civilian.png',
    'assets/images/avatars/granny_gun.png',
    'assets/images/avatars/cupid.png',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController(initialScrollOffset: 200); // Offset start
    _scrollController3 = ScrollController(initialScrollOffset: 400); // Larger offset start

    // Start Auto Scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    // Extremely slow speed
    const double scrollSpeed = 0.1; 
    const duration = Duration(milliseconds: 50);

    _timer = Timer.periodic(duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _scroll(_scrollController1, scrollSpeed);
      _scroll(_scrollController2, scrollSpeed); // Same speed
      _scroll(_scrollController3, scrollSpeed); // Same speed
    });
  }

  void _scroll(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;

    if (currentScroll >= maxScroll - 50) {
      controller.jumpTo(0);
    } else {
      controller.jumpTo(currentScroll + offset);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate a long list by repeating avatars to allow scrolling
    final displayList = [..._avatars, ..._avatars, ..._avatars, ..._avatars];

    return Row(
      children: [
        Expanded(
          child: _AvatarColumn(
            controller: _scrollController1,
            images: displayList,
            reverse: false, // Down
          ),
        ),
        Expanded(
          child: Transform.translate(
             offset: const Offset(0, -50),
             child: _AvatarColumn(
              controller: _scrollController2,
              images: displayList, // Use same list order, reverse scroll handles direction
              reverse: true, // Up (Opposite)
            ),
          ),
        ),
        Expanded(
          child: _AvatarColumn(
            controller: _scrollController3,
            images: displayList,
            reverse: false, // Down
          ),
        ),
      ],
    );
  }
}

class _AvatarColumn extends StatelessWidget {
  final ScrollController controller;
  final List<String> images;
  final bool reverse;

  const _AvatarColumn({
    required this.controller, 
    required this.images,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      reverse: reverse, // Controls direction
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColorFiltered(
               colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
