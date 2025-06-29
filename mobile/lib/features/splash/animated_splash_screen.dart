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
    
    // Icon fill animation controller (outline to filled) - even faster
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 900), // Faster transition
      vsync: this,
    );
    
    // Fade out animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600), // Faster fade
      vsync: this,
    );
    
    // Fill animation (0.0 = outline only, 1.0 = filled only)
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutExpo), // Smoother curve
    ));
    
    // Scale animation for a subtle bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));
    
    // Fade out animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic, // Smoother fade curve
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    // Start with a shorter delay to show the outline version first
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Start the fill animation (faster, smoother transition)
    await _iconController.forward();
    
    // Wait a bit after fill completes, then start fade out
    await Future.delayed(const Duration(milliseconds: 300));
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
                          strokeWidth: 2.5 * (1.0 - _fillAnimation.value * 0.6), // Stroke gets thinner more gradually
                          opacity: 1.0 - _fillAnimation.value * 0.4, // Fades more gradually
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
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final scale = size.width / 960; // Scale from 960x960 viewBox to our size
    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(0, 960); // Translate to handle the -960 offset in viewBox

    // Material Symbols view_object_track outline path (exact from SVG)
    final path = Path();
    // Top track (outline)
    path.moveTo(291, -160);
    path.cubicTo(236, -160, 198, -199.55, 198, -255);
    path.cubicTo(198, -310.95, 236, -350.45, 291, -350.45);
    path.lineTo(749, -350.45);
    path.cubicTo(804, -350.45, 842, -310.95, 842, -255);
    path.cubicTo(842, -199.05, 804, -159.55, 749, -160);
    path.lineTo(291, -160);
    path.close();
    
    // Top inner track (outline)
    path.moveTo(291, -220);
    path.lineTo(749, -220);
    path.cubicTo(778.58, -220, 799.29, -241.82, 799.29, -273);
    path.cubicTo(799.29, -304.18, 778.58, -326, 749, -326);
    path.lineTo(291, -326);
    path.cubicTo(261.42, -326, 240.71, -304.18, 240.71, -273);
    path.cubicTo(240.71, -241.82, 261.42, -220, 291, -220);
    path.close();
    
    // Bottom track (outline)
    path.moveTo(211, -530);
    path.cubicTo(156, -530, 118, -569.55, 118, -625);
    path.cubicTo(118, -680.95, 156, -720.45, 211, -720.45);
    path.lineTo(669, -720.45);
    path.cubicTo(724, -720.45, 762, -680.95, 762, -625);
    path.cubicTo(762, -569.05, 724, -529.55, 669, -530);
    path.lineTo(211, -530);
    path.close();
    
    // Bottom inner track (outline)
    path.moveTo(211, -590);
    path.lineTo(669, -590);
    path.cubicTo(698.58, -590, 719.29, -611.82, 719.29, -643);
    path.cubicTo(719.29, -674.18, 698.58, -696, 669, -696);
    path.lineTo(211, -696);
    path.cubicTo(181.42, -696, 160.71, -674.18, 160.71, -643);
    path.cubicTo(160.71, -611.82, 181.42, -590, 211, -590);
    path.close();

    canvas.drawPath(path, paint);
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
    canvas.translate(0, 960); // Translate to handle the -960 offset in viewBox

    // Create smooth filling effect with animated reveal from bottom to top
    final fillHeight = 960 * fillProgress;
    final clipRect = Rect.fromLTWH(0, -fillHeight, 960, fillHeight);
    canvas.clipRect(clipRect);

    // Material Symbols view_object_track filled path (exact from SVG)
    final path = Path();
    // Filled path from the actual Material Symbols SVG
    path.moveTo(291, -160);
    path.cubicTo(236, -160, 198, -199.55, 198, -255);
    path.cubicTo(198, -310.95, 236, -350.45, 291, -350.45);
    path.lineTo(749, -350.45);
    path.cubicTo(804, -350.45, 842, -310.95, 842, -255);
    path.cubicTo(842, -199.05, 804, -159.55, 749, -160);
    path.lineTo(291, -160);
    path.close();
    
    // Bottom track
    path.moveTo(211, -530);
    path.cubicTo(156, -530, 118, -569.55, 118, -625);
    path.cubicTo(118, -680.95, 156, -720.45, 211, -720.45);
    path.lineTo(669, -720.45);
    path.cubicTo(724, -720.45, 762, -680.95, 762, -625);
    path.cubicTo(762, -569.05, 724, -529.55, 669, -530);
    path.lineTo(211, -530);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FilledIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.fillProgress != fillProgress;
  }
}
