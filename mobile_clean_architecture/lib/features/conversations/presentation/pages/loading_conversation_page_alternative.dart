import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'conversation_page.dart';

/// A more animated loading page with floating education elements
class LoadingConversationPageAlternative extends StatefulWidget {
  final Conversation conversation;
  final Message? initialMessage;

  const LoadingConversationPageAlternative({
    Key? key,
    required this.conversation,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<LoadingConversationPageAlternative> createState() =>
      _LoadingConversationPageAlternativeState();
}

class _LoadingConversationPageAlternativeState
    extends State<LoadingConversationPageAlternative>
    with TickerProviderStateMixin {
  late AnimationController _characterController;
  late AnimationController _objectsController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textFadeAnimation;

  // Animated objects
  final List<AnimatedEducationObject> _animatedObjects = [];

  // Animated loading text
  final List<String> _loadingSteps = [
    'Đang tạo tình huống của bạn...',
    'Chuẩn bị nội dung học...',
    'Sẵn sàng bắt đầu!',
  ];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _createAnimatedObjects();
    _startTransition();
  }

  void _setupAnimations() {
    // Character scale and bounce animation
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_characterController);

    // Objects floating animation
    _objectsController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_objectsController);

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _characterController.forward();
    _textController.forward();

    // Animate loading text steps
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_currentStep < _loadingSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _textController.reset();
        _textController.forward();
      } else {
        timer.cancel();
      }
    });
  }

  void _createAnimatedObjects() {
    final objects = [
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.book, AppColors.accent),
        radius: 120,
        angle: 0,
        speed: 1.0,
      ),
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.chat_bubble_outline, AppColors.primary),
        radius: 140,
        angle: math.pi / 3,
        speed: 0.8,
      ),
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.emoji_objects_outlined, Colors.orange),
        radius: 100,
        angle: 2 * math.pi / 3,
        speed: 1.2,
      ),
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.mic, AppColors.primary),
        radius: 130,
        angle: math.pi,
        speed: 0.9,
      ),
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.headphones, AppColors.accent),
        radius: 110,
        angle: 4 * math.pi / 3,
        speed: 1.1,
      ),
      AnimatedEducationObject(
        child: _buildEducationIcon(Icons.translate, Colors.blue),
        radius: 150,
        angle: 5 * math.pi / 3,
        speed: 0.7,
      ),
    ];

    _animatedObjects.addAll(objects);
  }

  Widget _buildEducationIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 24,
        color: color,
      ),
    );
  }

  void _startTransition() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ConversationPage(
              conversation: widget.conversation,
              initialMessage: widget.initialMessage,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _characterController.dispose();
    _objectsController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated character with floating objects
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floating education objects
                    ...List.generate(_animatedObjects.length, (index) {
                      return AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          final object = _animatedObjects[index];
                          final angle = _rotationAnimation.value * object.speed + object.angle;
                          final x = math.cos(angle) * object.radius;
                          final y = math.sin(angle) * object.radius * 0.6;

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Transform.scale(
                              scale: 0.8 + 0.2 * math.sin(angle * 2),
                              child: child,
                            ),
                          );
                        },
                        child: _animatedObjects[index].child,
                      );
                    }),

                    // Reading character
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildCharacter(isDarkMode),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Animated loading text
              FadeTransition(
                opacity: _textFadeAnimation,
                child: Text(
                  _loadingSteps[_currentStep],
                  style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Animated progress dots
              _buildProgressDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacter(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cloud base
        Container(
          width: 160,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        // Character body and head (simplified)
        Positioned(
          bottom: 30,
          child: Column(
            children: [
              // Head
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: AppColors.primaryDark,
                    width: 3,
                  ),
                ),
              ),
              // Body
              Container(
                width: 70,
                height: 60,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Book
        Positioned(
          bottom: 45,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Book pages
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Center line
                  Positioned(
                    top: 4,
                    bottom: 4,
                    left: 28,
                    width: 4,
                    child: Container(
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentStep ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= _currentStep
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class AnimatedEducationObject {
  final Widget child;
  final double radius;
  final double angle;
  final double speed;

  AnimatedEducationObject({
    required this.child,
    required this.radius,
    required this.angle,
    required this.speed,
  });
}
