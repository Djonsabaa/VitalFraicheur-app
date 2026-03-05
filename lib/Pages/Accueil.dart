import 'package:flutter/material.dart';
import 'package:appli_produit/Pages/Profil.dart';
import 'Produits.dart';
import 'CreerCompte.dart';
import 'dart:ui';
import 'PanierPage.dart';

class Accueil extends StatefulWidget {
  @override
  State<Accueil> createState() => _AccueilState();
}
class _AccueilState extends State<Accueil> with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;

  /*void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });

  }*/


//final int currentIndex = 0;

// index bar de navigation
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget _buildIcon(int index, IconData iconData) {
    bool isSelected = _selectedIndex == index;
    return Container(
      padding: EdgeInsets.all(10 ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: isSelected ? Colors.white : Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      endDrawer: Drawer(
        elevation: 0,
        child: Stack(
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Color.fromRGBO(255, 255, 255, 0.0 ),
              ),
            ),

            ListView(
              children: <Widget>[
                Container(
                  height: 55.0,
                  child: DrawerHeader(
                    padding: EdgeInsets.all(6.0),
                    margin: EdgeInsets.all(6.0),
                    child: Text('VitalFraîcheur', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, color: Colors.white)),
                    decoration: BoxDecoration(color: Colors.blue),
                  ),
                ),
                SizedBox(height: 40.0),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.blue,),
                  title: Text('Accueil', style: TextStyle(fontSize: 18),),
                  onTap: () => Navigator.pushNamed(context, '/accueil'),
                ),

                ListTile(
                  leading: Icon(Icons.shopping_basket,
                    color: Colors.blue,),
                  title: Text('Produits', style: TextStyle(fontSize: 18)),
                  onTap: () => Navigator.pushNamed(context, '/produits'),
                ),

                ListTile(
                  leading: Icon(Icons.shopping_bag,
                    color: Colors.blue,),
                  title: Text('Commandes', style: TextStyle(fontSize: 18)),
                  onTap: () => Navigator.pushNamed(context, '/commandes'),
                ),

                ListTile(
                  leading: Icon(Icons.person,
                    color: Colors.blue,),
                  title: Text('Profil', style: TextStyle(fontSize: 18)),
                  onTap: () => Navigator.pushNamed(context, '/profil'),
                ),

              ],
            ),
          ],
        ),
      ),


      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green.shade200,
        elevation: 2,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        ),

      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text("VitalFraîcheur",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue),
            ),
          ),
          SizedBox(height: 70),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Image.asset('assets/images/imgAcc.png', height: 300, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 40),
          Text("Mangez bio", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:[Colors.blue, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.all(2),
            child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/produits');
            },
            style: ElevatedButton.styleFrom(
              elevation: 4,
              //backgroundColor: Colors.green,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text('Voir produits', style: TextStyle(fontSize: 18, color: Colors.green)),
          ),
    ),
        ],
      ),
         ),
              ],

            ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.green.shade200,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if ( index == 0) {
            Navigator.pushReplacement(context,
            MaterialPageRoute (builder: (context) => Accueil()),);

          } else if (index == 1) {
            Navigator.push(context,
              MaterialPageRoute (builder: (context) => Produits()),);

          }
          else if (index == 2) {
            Navigator.push(context,
              MaterialPageRoute (builder: (context) => PanierPage()),);
          }
          else if (index == 3) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => Profil()),);
          }
          //_selectedIndex = index;
        },
        items: [
          BottomNavigationBarItem(icon: _buildIcon(0, Icons.home ), label: 'Accueil'),
          BottomNavigationBarItem(icon: _buildIcon(1, Icons.shopping_bag ), label: 'Produits'),
          BottomNavigationBarItem(icon: _buildIcon(2, Icons.shopping_cart), label: "Panier"),
          BottomNavigationBarItem(icon: _buildIcon(3, Icons.person), label: "Profil"),
        ],
      ),

    );
  }
}