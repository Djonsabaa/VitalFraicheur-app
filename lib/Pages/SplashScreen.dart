import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/connexion');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 100),

                      SizedBox(height: 20),
                      Text('VitalFraîcheur', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Des produits frais, naturels et durables pour votre santé et votre bien-être !',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                  //  Align(
                     // alignment: Alignment.bottomCenter,
                        //child:  Image.asset('assets/images/leg.png', height: 300, width: double.infinity, fit: BoxFit.cover,),
                          Image.asset('assets/images/panier_leg.png', height: 400, width: double.infinity, fit: BoxFit.cover,
                        )
                     // ),
                  ],
                ),
                ),
              ),
            ),
            ),
        );
    }
}



/*import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo.png',
                height: 120,
              ),
              SizedBox(height: 24),
              Text('VitalFresh',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              // Slogan
              Text('Produits frais et naturels pour votre santé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              // Spinner
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
