import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _fadeController;
  late Animation<double> _fillAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Icon fill animation controller (outline to filled)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Fade out animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Fill animation (0.0 = outline only, 1.0 = filled only)
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
    ));
    
    // Scale animation for a subtle bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
    
    // Fade out animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    // Start with a small delay to show the outline version first
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start the fill animation
    await _iconController.forward();
    
    // Wait a bit after fill completes, then start fade out
    await Future.delayed(const Duration(milliseconds: 600));
    await _fadeController.forward();
    
    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final iconColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fillAnimation, _fadeAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    children: [
                      // Outline version (always visible, but stroke gets thinner as fill increases)
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: OutlineIconPainter(
                          color: iconColor,
                          strokeWidth: 3.0 * (1.0 - _fillAnimation.value * 0.7), // Stroke gets thinner
                          opacity: 1.0 - _fillAnimation.value * 0.3, // Slightly fades but stays visible
                        ),
                      ),
                      // Filled version (animated fill effect)
                      AnimatedBuilder(
                        animation: _fillAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(140, 140),
                            painter: FilledIconPainter(
                              color: iconColor,
                              fillProgress: _fillAnimation.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OutlineIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double opacity;

  OutlineIconPainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final scale = size.width / 960; // Scale from 960x960 viewBox to our size
    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(0, 960); // Flip coordinate system
    canvas.scale(1, -1);

    // Top rounded rectangle (outline)
    final topRect = RRect.fromLTRBR(211, 530, 669, 670, const Radius.circular(70));
    canvas.drawRRect(topRect, paint);

    // Bottom rounded rectangle (outline)  
    final bottomRect = RRect.fromLTRBR(291, 160, 749, 300, const Radius.circular(70));
    canvas.drawRRect(bottomRect, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(OutlineIconPainter oldDelegate) {
    return oldDelegate.color != color || 
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.opacity != opacity;
  }
}

class FilledIconPainter extends CustomPainter {
  final Color color;
  final double fillProgress;

  FilledIconPainter({
    required this.color,
    this.fillProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillProgress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 960; // Scale from 960x960 viewBox to our size
    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(0, 960); // Flip coordinate system
    canvas.scale(1, -1);

    // Create smooth filling effect from bottom to top
    final fillHeight = 960 * fillProgress;
    final clipRect = Rect.fromLTWH(0, 960 - fillHeight, 960, fillHeight);
    canvas.clipRect(clipRect);

    // Top rounded rectangle (filled)
    final topRect = RRect.fromLTRBR(211, 530, 669, 670, const Radius.circular(70));
    canvas.drawRRect(topRect, paint);

    // Bottom rounded rectangle (filled)
    final bottomRect = RRect.fromLTRBR(291, 160, 749, 300, const Radius.circular(70));
    canvas.drawRRect(bottomRect, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(FilledIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.fillProgress != fillProgress;
  }
}
