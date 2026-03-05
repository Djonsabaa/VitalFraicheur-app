import 'package:flutter/material.dart';

class EvaluerCommandePage extends StatefulWidget {
  @override
  _EvaluerCommandePageState createState() => _EvaluerCommandePageState();
}

class _EvaluerCommandePageState extends State<EvaluerCommandePage> {
  int _rating = 4;
  String _commentaire = '';
  bool? _livraisonATemps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Évaluez votre commande"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte produit avec étoiles
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/tomates.jpg', // Remplacez par le chemin de votre image
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tomates", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),

            // Champ commentaire
            TextField(
              decoration: InputDecoration(
                hintText: "Ajouter un commentaire",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _commentaire = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Livraison à temps
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Livraison à temps ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text("Oui"),
                    value: true,
                    groupValue: _livraisonATemps,
                    onChanged: (value) {
                      setState(() {
                        _livraisonATemps = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text("Non"),
                    value: false,
                    groupValue: _livraisonATemps,
                    onChanged: (value) {
                      setState(() {
                        _livraisonATemps = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Bouton envoyer l’avis
            ElevatedButton(
              onPressed: () {
                // À implémenter : envoi de l'avis
                print("Note: $_rating");
                print("Commentaire: $_commentaire");
                print("Livraison à temps: $_livraisonATemps");
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Center(
                child: Text("Envoyer l’avis", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
