import 'package:flutter/material.dart';
import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  double _opacityLogo = 0.0;
  double _opacityTitle = 0.0;
  double _opacityTagline = 0.0;
  bool _showLoadingIndicator = false;

  // Particles state
  List<Map<String, dynamic>> particles = [];
  late AnimationController _particleController;

  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      if (await firebaseAuth.currentUser != null) {
        AssistantsMethods.readCurrantOnlineUserInfo();
        Navigator.pushReplacement(
          context, 
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      particles.add({
        'position': Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          random.nextDouble() * MediaQuery.of(context).size.height,
        ),
        'size': random.nextDouble() * 4 + 2,
        'speed': random.nextDouble() * 2 + 1,
      });
    }
  }

  void _updateParticles(double delta) {
    for (var particle in particles) {
      double newY = (particle['position'] as Offset).dy - (particle['speed'] as double) * delta;
      if (newY < 0) {
        newY = MediaQuery.of(context).size.height;
      }
      particle['position'] = Offset((particle['position'] as Offset).dx, newY);
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
    
    // Logo animations
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define animations
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 50),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Start animations sequence
    _startAnimationSequence();
    startTimer();
  }

  void _startAnimationSequence() {
    // Initial particles
    Future.delayed(Duration.zero, () {
      setState(() {
        _initializeParticles();
      });
    });

    // Logo animation
    Future.delayed(Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
      setState(() {
        _opacityLogo = 1.0;
      });
    });

    // Rotate and pulse animations
    Future.delayed(Duration(milliseconds: 800), () {
      _rotateController.repeat();
      _pulseController.repeat(reverse: true);
      setState(() {
        _opacityTitle = 1.0;
      });
      _slideController.forward();
    });

    // Tagline and loading indicator
    Future.delayed(Duration(milliseconds: 1300), () {
      setState(() {
        _opacityTagline = 1.0;
        _showLoadingIndicator = true;
      });
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: darkTheme
                    ? [
                        Colors.black,
                        Color(0xFF1a1a1a),
                        Color(0xFF262626),
                      ]
                    : [
                        Colors.blue.shade400,
                        Colors.blue.shade800,
                        Colors.indigo.shade900,
                      ],
              ),
            ),
          ),

          // Animated Particles
          CustomPaint(
            painter: ParticlesPainter(
              particles: particles,
              progress: _particleController.value,
            ),
            size: Size.infinite,
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.car_repair,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 40),

                // Animated Title
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.white, Colors.white.withOpacity(0.8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            'CareRide',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 800),
                          opacity: _opacityTitle,
                          child: Text(
                            'HelperAssist',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Animated Tagline
                AnimatedOpacity(
                  duration: Duration(milliseconds: 800),
                  opacity: _opacityTagline,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Empowering Helpers on the Ride',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_showLoadingIndicator)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 800),
                  opacity: _opacityTagline,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Particle Painter
class ParticlesPainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double progress;

  ParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final position = particle['position'] as Offset;
      final particleSize = particle['size'] as double;
      canvas.drawCircle(position, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}



