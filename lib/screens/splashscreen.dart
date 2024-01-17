import 'package:flutter/material.dart';
import 'package:textextractorpro/screens/Strartscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyStartScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/splash.png',
                scale: 2,
              ),
              const SizedBox(height: 40.0),
              Text(
                "Text Extractor Pro",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineIndicator(
                  animation: _animation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class AnimatedLineIndicator extends StatelessWidget {
  final Animation<double> animation;

  AnimatedLineIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 2,
          color: Colors.white.withOpacity(0.3),
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * animation.value,
                height: 2,
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
