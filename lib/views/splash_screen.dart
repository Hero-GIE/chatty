import 'package:chatty/constant/app_color.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
      _navigateToCheckUserSession();
  }

  _navigateToCheckUserSession() async {
    await Future.delayed(Duration(seconds: 4), () {});
      Navigator.pushReplacementNamed(context, '/session');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors
                        .transparent, 
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.2, 
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: CurvedLeftClipper(),
                child: Container(
                  color: AppColors.backgroundColor,
                ),
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/just.png', 
                width: 300, 
                height: 300, 
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(0, size.height / 2, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
