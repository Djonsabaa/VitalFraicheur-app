import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'role' : role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // methode connexion
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  // fonction de recuperation role
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'];
    }
    return null;
  }




}


