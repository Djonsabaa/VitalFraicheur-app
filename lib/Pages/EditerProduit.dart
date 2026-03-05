import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditerProduit extends StatefulWidget {
  final DocumentSnapshot produit;

  EditerProduit({required this.produit});

  @override
  State<EditerProduit> createState() => _EditerProduitState();
}

class _EditerProduitState extends State<EditerProduit> {
  late TextEditingController nomController;
  TextEditingController? prixDetailController;
  TextEditingController? prixEngrosController;
  TextEditingController? prixController;

  bool hasPrixDetail = false;
  bool hasPrixEngros = false;
  bool hasPrix = false;

  @override
  void initState() {
    super.initState();
    final data = widget.produit.data() as Map<String, dynamic>;

    nomController = TextEditingController(text: data['nom'] ?? '');

    hasPrixDetail = data.containsKey('prixDetail');
    hasPrixEngros = data.containsKey('prixEngros');
    hasPrix = data.containsKey('prix');

    if (hasPrixDetail) {
      prixDetailController =
          TextEditingController(text: data['prixDetail'].toString());
    }
    if (hasPrixEngros) {
      prixEngrosController =
          TextEditingController(text: data['prixEngros'].toString());
    }
    if (!hasPrixDetail && !hasPrixEngros && hasPrix) {
      prixController =
          TextEditingController(text: data['prix'].toString());
    }
  }

  void modifierProduit() async {
    Map<String, dynamic> updatedData = {
      'nom': nomController.text,
    };

    if (hasPrixDetail && prixDetailController != null) {
      updatedData['prixDetail'] =
          double.tryParse(prixDetailController!.text.replaceAll(RegExp(r'[^\d.]'), ''));
    }

    if (hasPrixEngros && prixEngrosController != null) {
      updatedData['prixEngros'] =
          double.tryParse(prixEngrosController!.text.replaceAll(RegExp(r'[^\d.]'), ''));
    }

    if (!hasPrixDetail && !hasPrixEngros && prixController != null) {
      updatedData['prix'] =
          double.tryParse(prixController!.text.replaceAll(RegExp(r'[^\d.]'), ''));
    }

    await FirebaseFirestore.instance
        .collection('produits')
        .doc(widget.produit.id)
        .update(updatedData);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        title: Text("Modifier produit", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'Nom du produit'),
            ),
            SizedBox(height: 16),
            if (hasPrixDetail)
              TextField(
                controller: prixDetailController,
                decoration: InputDecoration(
                  labelText: 'Prix détail',
                  //suffixText: 'MAD',
                ),
                keyboardType: TextInputType.text,
              ),
            if (hasPrixEngros)
              SizedBox(height: 16),
            if (hasPrixEngros)
              TextField(
                controller: prixEngrosController,
                decoration: InputDecoration(
                  labelText: 'Prix en gros',
                  //suffixText: 'MAD',
                ),
                keyboardType: TextInputType.text,
              ),
            if (!hasPrixDetail && !hasPrixEngros)
              TextField(
                controller: prixController,
                decoration: InputDecoration(
                  labelText: 'Prix',
                 // suffixText: 'MAD',
                ),
                keyboardType: TextInputType.text,
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: modifierProduit,
              child: Text("Modifier", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation:4,
                side: BorderSide(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditerProduit extends StatefulWidget {
  final DocumentSnapshot produit;

  EditerProduit({required this.produit});

  @override
  State<EditerProduit> createState() => _EditerProduitState();
}

class _EditerProduitState extends State<EditerProduit> {
  late TextEditingController nomController;
  TextEditingController? prixDetailController;
  TextEditingController? prixEngrosController;
  TextEditingController? prixController;

  bool hasPrixDetail = false;
  bool hasPrixEngros = false;
  bool hasPrix = false;

  @override
  void initState() {
    super.initState();
    final data = widget.produit.data() as Map<String, dynamic>;

    nomController = TextEditingController(text: data['nom'] ?? '');

    hasPrixDetail = data.containsKey('prixDetail');
    hasPrixEngros = data.containsKey('prixEngros');
    hasPrix = data.containsKey('prix');

    if (hasPrixDetail) {
      prixDetailController =
          TextEditingController(text: data['prixDetail'].toString());
    }
    if (hasPrixEngros) {
      prixEngrosController =
          TextEditingController(text: data['prixEngros'].toString());
    }
    if (!hasPrixDetail && !hasPrixEngros && hasPrix) {
      prixController =
          TextEditingController(text: data['prix'].toString());
    }
  }

  void modifierProduit() async {
    Map<String, dynamic> updatedData = {
      'nom': nomController.text,
    };

    if (hasPrixDetail && prixDetailController != null) {
      updatedData['prixDetail'] =
         double.tryParse(prixDetailController!.text);

    }

    if (hasPrixEngros && prixEngrosController != null) {
      updatedData['prixEngros'] =
          double.tryParse(prixEngrosController!.text);

    }

    if (!hasPrixDetail && !hasPrixEngros && prixController != null) {
      updatedData['prix'] =
          double.tryParse(prixController!.text);
    }

    await FirebaseFirestore.instance
        .collection('produits')
        .doc(widget.produit.id)
        .update(updatedData);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        title: Text("Modifier produit", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'Nom du produit'),
            ),
            SizedBox(height: 16),
            if (hasPrixDetail)
              TextField(
                controller: prixDetailController,
                decoration: InputDecoration(labelText: 'Prix détail'),
                keyboardType: TextInputType.number,
              ),
            if (hasPrixEngros)
              SizedBox(height: 16),
            if (hasPrixEngros)
              TextField(
                controller: prixEngrosController,
                decoration: InputDecoration(labelText: 'Prix en gros'),
                keyboardType: TextInputType.text,
              ),
            if (!hasPrixDetail && !hasPrixEngros)
              TextField(
                controller: prixController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.text,
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: modifierProduit,
              child: Text("Modifier"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

*/