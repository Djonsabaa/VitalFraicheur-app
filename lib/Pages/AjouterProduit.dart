import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterProduit extends StatefulWidget {
  @override
  State <AjouterProduit> createState()  => _AjouterProduitState();
}
class _AjouterProduitState extends State <AjouterProduit> {
  final TextEditingController categorieController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController prixDetailController = TextEditingController();
  final TextEditingController prixEngrosController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool utiliserPrixDetailEtGros = false;

  void ajouterProduit() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'categorie': categorieController.text,
        'nom': nomController.text,
        'image': imageController.text,
        'description': descriptionController.text,
      };
      if (utiliserPrixDetailEtGros) {
        if (prixDetailController.text.isNotEmpty) {
          data['prixDetail'] = double.tryParse(prixDetailController.text);
        }
        if (prixEngrosController.text.isNotEmpty) {
          data['prixEngros'] = double.tryParse(prixEngrosController.text);
        }
      } else {
        if (prixController.text.isNotEmpty) {
          data['prix'] = double.tryParse(prixController.text);
        }
      }
      await FirebaseFirestore.instance.collection('produits').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit ajouté avec succès' ),
            backgroundColor: Colors.green,
          )
      );
      Navigator.pop(context); // retour à la liste

    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 2,
        title: Text('Ajouter un produit', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: categorieController,
                cursorColor: Colors.green.shade700,
                decoration: InputDecoration(
                    labelText: 'Catégorie produit', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        )
                    )
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Categorie requise' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: nomController,
                cursorColor: Colors.green.shade700,
                decoration: InputDecoration(
                    labelText: 'Nom du produit', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        )
                    )
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nom requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                cursorColor: Colors.green.shade700,
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'Description du produit', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        )
                    )
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Description requise' : null,
              ),
              SizedBox(height: 16),

              CheckboxListTile(
                title: Text("Produit avec prix en détail et prix en gros", style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.bold)),
                value: utiliserPrixDetailEtGros,
                activeColor:  Colors.green,
                onChanged: (value) {
                  setState(() {
                    utiliserPrixDetailEtGros = value ?? false;
                  });
                },
              ),
              SizedBox(height: 10),
              if (utiliserPrixDetailEtGros) ...[
                TextFormField(
                  controller: prixDetailController,
                  cursorColor: Colors.green.shade700,
                  decoration: InputDecoration(
                      labelText: 'Prix détail (MAD)', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )
                      )
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: prixEngrosController,
                  cursorColor: Colors.green.shade700,
                  decoration: InputDecoration(
                      labelText: 'Prix en gros (MAD)', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )
                      )
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else
                TextFormField(
                  controller: prixController,
                  cursorColor: Colors.green.shade700,
                  decoration: InputDecoration(
                      labelText: 'Prix (MAD)', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                     filled: true,
                    fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )
                      )
                  ),
                  keyboardType: TextInputType.number,

                ),
              SizedBox(height: 16),
              TextFormField(
                controller: imageController,
                cursorColor: Colors.green.shade700,
                decoration: InputDecoration(
                  labelText: 'Chemin de l’image', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        )
                    )
                ),
              ),


              SizedBox(height: 34),
              ElevatedButton(
                onPressed: ajouterProduit,
                child: Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 18, ),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  side: BorderSide(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
              )
    );
  }
}