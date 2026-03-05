import 'package:flutter/material.dart';
class Produit{
  final String nom;
  final String quantite;
  final String prixUnitaire;
  final String total;
  final String imageUrl;
  final String? livraisonEtat;

  final String prixEngros;
  final String prix;
  final String image;
  final String  description;
  final String  categorie;
  final String prixDetail;

  Produit({
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
    required this.total,
    required this.imageUrl,
    required this.livraisonEtat,

    required this.image,
    required this.description,
    required this.prixEngros,
    required this.prixDetail,
    required this.prix,
    required this.categorie,
});

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      nom: map['nom'] ?.toString() ?? '',
     // prixUnitaire: (map['prixUnitaire'] is int)
      //    ? (map['prixUnitaire'] as int).toDouble()
      //    : (map['prixUnitaire'] ?? 0.0),

      prixUnitaire: map['prixUnitaire']?.toString() ?? '',
      quantite: map['quantite']?.toString() ?? '',

      //quantite: map['quantite'] ?? 0,
     total: map['total'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      livraisonEtat: map['livraisonEtat'] ?? '',

      image: map['image']?.toString() ?? '',
      prix: map['prix']?.toString() ?? '',
      prixDetail: map['prixDetail']?.toString() ?? '',
      categorie: map['categorie']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      prixEngros: map['prixEngros']?.toString() ?? '',

    );
  }

  Map<String, String> toMap() => {
    'nom': nom,
    //'prixUnitaire': prixUnitaire,
    'prixEngros': prixEngros,
    'prix': prix,
    'prixDetail': prixDetail,
    'image': image,
    'description': description,
    'categorie': categorie,
  };

}

class Commande{
  final String numero;
  final DateTime date;
  final double total;
  final String etat;
  final String client;
  final String adresseLivraison;
  final String modePaiement;
  final String telephone;
  final List<Produit> produits;
  final String livraisonEtat;
  //final List<Article> articles;
  final String commandeId;

  Commande({
    required this.numero,
    required this.date,
    required this.total,
    required this.etat,
    required this.client,
    required this.adresseLivraison,
    required this.modePaiement,
    required this.telephone,
    required this.produits,
    required this.livraisonEtat,
    //required this.articles,
    required this.commandeId
});

  static  String genereNumCommande(){
    final now = DateTime.now();
    return 'A${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

}