import 'package:flutter/material.dart';
import '../Models/commandeProduit_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProduitController{
  final List<String> categories = ['Légumes', 'Poissons', 'Fruits'];

  Map<String, List<Produit>> produitsParCategorie = {};

  Future<List<Produit>> fetchProduits() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('produits').get();
    return querySnapshot.docs.map((doc) => Produit.fromMap(doc.data())).toList();

}

Future <void> chargerProduits() async {
  produitsParCategorie.clear();
  for (var categorie in categories) {
    produitsParCategorie[categorie] = []; }

  final produits = await fetchProduits();
  print('Produits récupérés total : ${produits.length}');
  for (var p in produits) {
   produitsParCategorie[p.categorie]?.add(p);
  }
  }


  List<Produit> getProduitsParCategorie(String categorie) {
    return produitsParCategorie[categorie] ?? [];
  }

  List<Produit> rechercherProduits(String query) {
    final tousProduits = produitsParCategorie.values.expand((list) => list).toList();
    return tousProduits.where((p) =>
        p.nom.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

}
