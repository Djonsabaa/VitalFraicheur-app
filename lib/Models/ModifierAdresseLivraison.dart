import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierAdresseLivraison extends StatefulWidget {
  final String commandeId;
  final String adresseActuelle;

  const ModifierAdresseLivraison({
    Key? key,
    required this.commandeId,
    required this.adresseActuelle,
  }) : super(key: key);

  @override
  _ModifierAdresseLivraisonState createState() => _ModifierAdresseLivraisonState();
}

class _ModifierAdresseLivraisonState extends State<ModifierAdresseLivraison> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.adresseActuelle);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier l\'adresse'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Nouvelle adresse',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('commandes')
                .doc(widget.commandeId)
                .update({'adresseLivraison': _controller.text});
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Adresse mise à jour')),
            );
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
