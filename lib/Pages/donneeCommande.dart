/* import 'package:flutter/material.dart';
import 'commandeProduit_model.dart';
import 'NumeroCommande.dart';
import 'package:appli_produit/ConfirmationCommande.dart';


double total = getTotalPrix();

final donneeCommande = Commande(
  numero: genereNumCommande(),
  date: DateTime.now(),
  total: total,
  etat: 'en cours',
  client: 'oumou',
  adresseLivraison: 'rue1',
  modePaiement: 'Carte',
  telephone: 'telephone',
  livraisonEtat: 'livrée',

  produits: [
    Produit(
      nom: 'Tomate fraîche',
      quantite: 'x8',
      prixUnitaire: '8 Dhs',
      total: '64 Dhs',
      imageUrl: 'images/tomate.png',
        livraisonEtat: 'En cours'
    ),

    Produit(
      nom: 'Carotte',
      quantite: 'x10',
      prixUnitaire: '7 Dhs',
      total: '70 Dhs',
      imageUrl: 'images/carottes.png',
      livraisonEtat: 'Commande reçue'
    ),

    Produit(
      nom: 'Laitue',
      quantite: 'x3',
      prixUnitaire: '2 Dhs',
      total: '6 Dhs',
      imageUrl: 'images/laitue-fresh.png',
      livraisonEtat: 'En livraison'
    ),


  ],
);
 */