import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsCommandePage extends StatefulWidget {
  final DocumentSnapshot commande;

  const DetailsCommandePage({super.key, required this.commande});

  @override
  State<DetailsCommandePage> createState() => _DetailsCommandePageState();
}

class _DetailsCommandePageState extends State<DetailsCommandePage> {
  late Map<String, dynamic> data;
  late String statut;

  @override
  void initState() {
    super.initState();
    data = widget.commande.data() as Map<String, dynamic>;
    statut = data['statut'] ?? 'En attente';
  }

  Future<void> updateStatut(String newStatut) async {
    await FirebaseFirestore.instance
        .collection('commandes')
        .doc(widget.commande.id)
        .update({'statut': newStatut});

    setState(() {
      statut = newStatut;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statut mis à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = (data['date'] as Timestamp).toDate();
    final produits = List<Map<String, dynamic>>.from(data['produits'] ?? []);
    final total = data['total'] ?? 0;
    final nomClient = data['client']?['nom'] ?? 'Inconnu';

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4,
        title: Text('Détails de la commande', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade300,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Client : $nomClient', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Date : ${DateFormat('dd MMM yyyy – HH:mm').format(date)}'),
            SizedBox(height: 8),
            Text('Total : $total MAD', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Statut de la commande :', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: statut,
              items: ['En attente', 'En cours', 'Livrée'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newVal) {
                if (newVal != null) updateStatut(newVal);
              },
            ),
            Divider(height: 32),
            Text('Produits commandés :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...produits.map((produit) {
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(produit['nom'] ?? 'Produit inconnu'),
                  subtitle: Text('Quantité : ${produit['quantite']}'),
                  trailing: Text('${produit['prixUnitaire']} MAD'),
                ),
              );
            }).toList(),
            Divider(height: 30),
            Row(
              children: [
              Text("Total de la commande: ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                SizedBox(width: 20),
                Text("$total Dhs", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
          ]
            )

          ],
        ),
      ),
    );
  }
}
