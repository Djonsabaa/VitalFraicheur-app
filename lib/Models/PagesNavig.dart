import 'package:flutter/material.dart';
import '../Pages/Accueil.dart';
import '../Pages/Produits.dart';
import '../Pages/Profil.dart';
class PagesNavig extends StatefulWidget {
  @override
  _PagesNavigState createState() => _PagesNavigState();
}
class _PagesNavigState extends State<PagesNavig> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Accueil(),
    Produits(),
    Profil(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Panier"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}