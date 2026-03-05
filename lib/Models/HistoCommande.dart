import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'Models/SaveCommande.dart';
class HistoCommande extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Non connecté'));
    }
    final commandesRef = FirebaseFirestore.instance
      .collection('users').doc(user.uid).collection('commandes').orderBy('date', descending: true);

    return Scaffold(
      backgroundColor: Colors.green[400],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green[300],

        elevation: 4,
        title: Text('Mes commandes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body:StreamBuilder<QuerySnapshot>(
        stream: commandesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erreur'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final commandes = snapshot.data!.docs;

          if (commandes.isEmpty) return const Center(child: Text('Aucune commande.'));

          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              final data = commande.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final total = data['total'];
              final statut = data['statut'];

              return Card(
                margin: EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    child: Column(
                      children: [
                        Text('Commande du ${date.day}/${date.month}/${date.year}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Statut : $statut', style: TextStyle(color: Colors.white)),
                      ]
                    )
                    ),

                  children: [
                    ...List<Widget>.from((data['produits'] as List).map((produit) {
                      return ListTile(
                        title: Text(produit['nom'], style: TextStyle(color: Colors.green)),
                        subtitle: Text('Quantité : ${produit['quantite']}' , style: TextStyle(color: Colors.green)),
                        trailing: Text('${produit['prixUnitaire']} Dhs', style: TextStyle(color: Colors.green)),
                        tileColor: Colors.white,
                      );
                    })),
                     Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Total : ${total.toStringAsFixed(2)} Dhs',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    )
                  ],
                ),


              );
            },
          );
        },
      ),

    );
  }
}

