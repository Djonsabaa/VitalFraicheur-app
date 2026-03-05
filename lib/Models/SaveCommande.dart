import 'package:appli_produit/Models/RecupereAdd.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
      // fonction enregistrer commande
Future<void> SaveCommande(List<Map<String, dynamic>> produits, double total) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final commande = {
    'date': Timestamp.now(),
    'total': total,
    'statut': 'en cours',
    'produits': produits,


  };

  final commandesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('commandes');

  await commandesRef.add(commande);
}

// enreg dans firestore

Future<String?> saveCommandeGlobale(List<dynamic> produits, double total) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final nom = userDoc.data()?['name'] ?? 'inconnu';

  //final nom = userData?['name'] ?? 'inconnu';
  final adresse = userDoc.data()?['adresse'] ?? 'Adresse non renseignée';
  final modePaiement = userDoc.data()?['modePaiement'] ?? 'modePaiement non renseignée';
  final telephone = userDoc.data()?['telephone'] ?? 'Numero telephone non renseignée';
  final livraisonEtat = userDoc.data()?['livraisonEtat'] ?? 'livraisonEtat non renseignée';
  //final date = userDoc.data()?['date']  ?? 'date non enregistrée';
  final date = Timestamp.now();

  final commandeData = {
    'uid': user.uid,
    'date': date,
    'total': total,
    'etat': 'en_attente',

    'produits': produits,
    'client': {
      'nom': nom,
      'email': user.email ?? '',
      'adresseLivraison': adresse,
      'telephone': telephone,
      'modePaiement':modePaiement,
      'livraisonEtat':livraisonEtat,
      'date' : date,
    }

  };
  final docRef = await FirebaseFirestore.instance.collection('commandes').add(commandeData);

  return docRef.id;
}

/*
Future<void> saveCommandeGlobale(List<dynamic> produits, double total) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
     // recuperé le doc de user
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
     final nom = userDoc.data()?['name'] ?? 'inconnu';

  final commandeData = {
    'uid': user.uid,
    'date': Timestamp.now(),
    'total': total,
    'etat': 'en_attente',
    'produits': produits,
    'client': {
      'nom': nom ?? '',
      'email': user.email ?? '',
    }
  };
  await FirebaseFirestore.instance.collection('commandes').add(commandeData);
} */