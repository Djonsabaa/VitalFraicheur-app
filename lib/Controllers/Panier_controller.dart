import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Article_model.dart';

class PanierController{
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  Future<List<Article>> getArticles() async {
    print('Chargement des articles pour $userId');
    final snapshot = await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .get();
    print('Nombre d\'articles récupérés : ${snapshot.docs.length}');

    return snapshot.docs.map((doc) => Article.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateQuantite(Article article) async {
    if (userId == null || article.id == null) return;

    await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .doc(article.id)
        .update(article.toMap());
  }

  Future<void> supprimerArticle(String id) async {
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .doc(id)
        .delete();
  }

  Future<void> viderPanier() async {
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  double calculerTotal(List<Article> articles) {
    return articles.fold(0.0, (sum, article) => sum + (article.prixED * article.quantite));
  }

}