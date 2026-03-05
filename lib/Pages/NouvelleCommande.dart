import 'package:appli_produit/Pages/DetailsCommandes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DetailsCommandes.dart';

class NouvelleCommande extends StatelessWidget {
  const NouvelleCommande ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        elevation:4,
        iconTheme: IconThemeData(color: Colors.white70),
        title: const Text("Commandes récentes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commandes')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erreur de chargement"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final commandes = snapshot.data!.docs;

          if (commandes.isEmpty) {
            return const Center(child: Text("Aucune commande trouvée"));
          }

          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              final date = (commande['date'] as Timestamp).toDate();
              final dateFormat = DateFormat('dd MMM yyyy à HH:mm');
              final total = commande['total'] ?? 0;

              //final utilisateur= commande['nom'] ?? 'Inconnu';
             /* final utilisateur = commande.data().toString().contains('nom')
                  ? commande['nom']
                  : 'Inconnu';
              */
              final Map<String, dynamic> data = commande.data() as Map<String, dynamic>;

              final nom = data.containsKey('nom') && data['nom'] != null
                  ? data['nom']
                  : 'Client inconnu';
              print("Commande data: ${commande.data()}");

              final produits = commande['produits'] ?? [];

              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.green),

                  title: Text("Commande de $nom"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date : ${dateFormat.format(date)}"),
                      Text("Total : ${total.toString()} MAD"),
                      if (produits is List && produits.isNotEmpty)
                        Text("Produits : ${produits.length} article(s)"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DetailsCommandePage(commande: commande)),
                        );

                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
