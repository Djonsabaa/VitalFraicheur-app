import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'EditerProduit.dart';
import 'AdminDashboard.dart';
import 'Profil.dart';

class ListeProduits extends StatefulWidget {
  @override
  State<ListeProduits> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<ListeProduits> {
  String getPrix(Map<String, dynamic> data) {
    List<String> prixAffiches = [];

    if (data.containsKey('prixDetail')) {
      prixAffiches.add('Prix en détail : ${data['prixDetail']} ');
    }
    if (data.containsKey('prixEngros')) {
      prixAffiches.add('Prix en engros : ${data['prixEngros']}');
    }
    if (data.containsKey('prix') && prixAffiches.isEmpty) {
      prixAffiches.add('${data['prix']} ');
    }

    return prixAffiches.isNotEmpty
        ? prixAffiches.join('\n')
        : 'Prix non disponible';
  }

  // index bar de navigation
  int _selectedIndex = 1;
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
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        title: Text('Liste des produits', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produits').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erreur Firestore'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // ou autre indicateur
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucun produit disponible"));
          }

          final produits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              final data = produit.data() as Map<String, dynamic>;
              final imagePath = data['image'];
              return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imagePath != null && imagePath.toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(imagePath, //
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,

                                ),
                              ),
                 SizedBox(height: 10),


                 ListTile(
                  title: Text(data['nom'] ?? 'Produit'),
                  subtitle: Text(getPrix(data)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditerProduit(produit: produit),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.green),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('produits')
                              .doc(produit.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                 )
              ],

              ),
                ),
              );
            },
          );
        },
      ),


    bottomNavigationBar: BottomNavigationBar(
      elevation: 6,
      backgroundColor: Colors.green.shade200,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {

        if ( index == 0) {
          Navigator.pushReplacement(context,
            MaterialPageRoute (builder: (context) => AdminDashboard()),
          );
        } else if (index == 1) {
          Navigator.push(context,
            MaterialPageRoute (builder: (context) => ListeProduits()),
          );
        } else if (index == 2) {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => Profil()),
          );
        }

        _selectedIndex = index;
      },
      items: [
        BottomNavigationBarItem(icon: _buildIcon(0, Icons.home ), label: "Dashboard"),
        BottomNavigationBarItem(icon: _buildIcon(1, Icons.shopping_basket), label: "Produits"),
        BottomNavigationBarItem(icon: _buildIcon(2, Icons.bar_chart), label: "Profil"),

      ],
    ),
    );
  }
}

