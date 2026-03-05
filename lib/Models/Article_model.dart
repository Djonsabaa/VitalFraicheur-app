import 'package:flutter/material.dart';
class Article{
  final String nom;
  final String image;
  final double prix; // prix simple pour les produit qui n'ont ni detail ni engros
  final String description;
  final double prixDetail;
  final double prixEngros;
  final String categorie;
  double prixED;     // prix choisi par user
  int quantite;
  String? id;     // id doc firestore

  Article({
    required this.nom,
    required this.image,
    required this.prix,
    required this.description,
    required this.prixDetail,
    required this.prixEngros,
    required this.categorie,
    required this.prixED,
    this.quantite = 1,
    this.id,
  });
  double getPrixEDActuel(bool isRetail) {
    if (prixDetail > 0 || prixEngros > 0) {
      return isRetail ? prixDetail : prixEngros;
    }
    return prix;
  }

  // converti depuis firestore
  factory Article.fromMap(Map<String, dynamic> map, String id) {
    return Article(
      id : id,
      nom: map['nom'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      prix: _toDouble(map['prix']),
      prixDetail: _toDouble(map['prixDetail']),
      prixEngros: _toDouble(map['prixEngros'] ),
      prixED: _toDouble(map['prixED']),
      //quantite: map['quantite'] ?? 1,
      quantite: (map['quantite'] ?? 1) is int
            ? map['quantite']
            : int.tryParse(map['quantite'].toString()) ?? 1,
      categorie: map['categorie'] ?? '',
    );
  }
      // convertir vers map pr firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'image': image,
      'prix': prix,
      'description': description,
      'prixDetail': prixDetail,
      'prixEngros': prixEngros,
      'prixED': prixED,
      'quantite': quantite,
      'categorie': categorie,
    };
  }
// fonction d'aide
  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

 /* static double _parsePrix(String prix) {
    // Nettoie les caractères non numériques
    final cleaned = prix.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }*/


}
