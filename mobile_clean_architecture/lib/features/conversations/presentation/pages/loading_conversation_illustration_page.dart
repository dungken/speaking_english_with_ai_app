import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'conversation_page.dart';

/// A loading page with custom illustrated character similar to the provided image
class LoadingConversationIllustrationPage extends StatefulWidget {
  final Conversation conversation;
  final Message? initialMessage;

  const LoadingConversationIllustrationPage({
    Key? key,
    required this.conversation,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<LoadingConversationIllustrationPage> createState() =>
      _LoadingConversationIllustrationPageState();
}

class _LoadingConversationIllustrationPageState
    extends State<LoadingConversationIllustrationPage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _objectsController;
  late AnimationController _loadingController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTransition();
  }

  void _setupAnimations() {
    // Float animation for the character
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for floating objects
    _objectsController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_objectsController);

    // Loading progress animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _loadingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
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
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _objectsController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom illustration
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: _buildIllustration(),
                  ),

                  const SizedBox(height: 40),

                  // Loading text
                  Text(
                    'Đang tạo tình huống của bạn ...',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),

                  const SizedBox(height: 24),

                  // Loading bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _loadingAnimation.value,
                          backgroundColor: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cloud background
          Positioned(
            bottom: 40,
            child: Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),

          // Main character
          Positioned(
            bottom: 60,
            child: _buildCharacter(),
          ),

          // Floating educational objects
          ..._buildFloatingObjects(),
        ],
      ),
    );
  }

  Widget _buildCharacter() {
    return CustomPaint(
      size: const Size(120, 180),
      painter: CharacterPainter(),
    );
  }

  List<Widget> _buildFloatingObjects() {
    final objects = [
      {'icon': Icons.menu_book, 'color': const Color(0xFFFFD700), 'angle': 0.0},
      {'icon': Icons.lightbulb_outline, 'color': Colors.orange, 'angle': math.pi / 3},
      {'icon': Icons.favorite, 'color': Colors.red, 'angle': 2 * math.pi / 3},
      {'icon': Icons.check_circle_outline, 'color': Colors.green, 'angle': math.pi},
      {'icon': Icons.chat_bubble_outline, 'color': Colors.blue, 'angle': 4 * math.pi / 3},
      {'icon': Icons.school, 'color': Colors.purple, 'angle': 5 * math.pi / 3},
    ];

    return objects.map((obj) {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          final angle = _rotationAnimation.value + (obj['angle'] as double);
          final radius = 120.0;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius * 0.5;

          return Positioned(
            left: 150 + x,
            top: 150 + y,
            child: Transform.scale(
              scale: 0.8 + 0.2 * math.sin(angle * 2),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (obj['color'] as Color).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  obj['icon'] as IconData,
                  color: obj['color'] as Color,
                  size: 24,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class CharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Hair (afro style)
    paint.color = const Color(0xFF4A2C2A);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.35,
      paint,
    );
    
    // Additional hair puffs
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.25),
      size.width * 0.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      size.width * 0.2,
      paint,
    );

    // Face
    paint.color = const Color(0xFF8B4513);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      size.width * 0.25,
      paint,
    );

    // Eyes
    paint.color = Colors.white;
    // Left eye
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.28),
      size.width * 0.05,
      paint,
    );
    // Right eye
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.28),
      size.width * 0.05,
      paint,
    );

    // Pupils
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.28),
      size.width * 0.02,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.28),
      size.width * 0.02,
      paint,
    );

    // Smile
    paint.color = Colors.pink;
    final smilePath = Path();
    smilePath.moveTo(size.width * 0.4, size.height * 0.35);
    smilePath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.35,
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawPath(smilePath, paint);

    // Body (T-shirt)
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue;
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.3, size.height * 0.45);
    bodyPath.lineTo(size.width * 0.7, size.height * 0.45);
    bodyPath.lineTo(size.width * 0.75, size.height * 0.65);
    bodyPath.lineTo(size.width * 0.25, size.height * 0.65);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Arms
    // Left arm
    paint.color = const Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height * 0.45,
        size.width * 0.1,
        size.height * 0.25,
      ),
      paint,
    );
    // Right arm
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.75,
        size.height * 0.45,
        size.width * 0.1,
        size.height * 0.25,
      ),
      paint,
    );

    // Book
    paint.color = Colors.red;
    final bookPath = Path();
    bookPath.moveTo(size.width * 0.3, size.height * 0.6);
    bookPath.lineTo(size.width * 0.7, size.height * 0.6);
    bookPath.lineTo(size.width * 0.7, size.height * 0.75);
    bookPath.lineTo(size.width * 0.3, size.height * 0.75);
    bookPath.close();
    canvas.drawPath(bookPath, paint);

    // Book pages
    paint.color = Colors.white;
    final pagesPath = Path();
    pagesPath.moveTo(size.width * 0.35, size.height * 0.62);
    pagesPath.lineTo(size.width * 0.65, size.height * 0.62);
    pagesPath.lineTo(size.width * 0.65, size.height * 0.73);
    pagesPath.lineTo(size.width * 0.35, size.height * 0.73);
    pagesPath.close();
    canvas.drawPath(pagesPath, paint);

    // Book center line
    paint.color = Colors.red;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );

    // Pants
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF2C5F2D);
    final pantsPath = Path();
    pantsPath.moveTo(size.width * 0.3, size.height * 0.65);
    pantsPath.lineTo(size.width * 0.7, size.height * 0.65);
    pantsPath.lineTo(size.width * 0.7, size.height * 0.85);
    pantsPath.lineTo(size.width * 0.55, size.height * 0.85);
    pantsPath.lineTo(size.width * 0.5, size.height * 0.75);
    pantsPath.lineTo(size.width * 0.45, size.height * 0.85);
    pantsPath.lineTo(size.width * 0.3, size.height * 0.85);
    pantsPath.close();
    canvas.drawPath(pantsPath, paint);

    // Shoes
    paint.color = Colors.pink;
    // Left shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.25,
          size.height * 0.85,
          size.width * 0.2,
          size.height * 0.1,
        ),
        const Radius.circular(10),
      ),
      paint,
    );
    // Right shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.55,
          size.height * 0.85,
          size.width * 0.2,
          size.height * 0.1,
        ),
        const Radius.circular(10),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
