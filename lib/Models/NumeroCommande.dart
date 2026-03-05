import 'package:flutter/material.dart';

String genereNumCommande(){
  final now = DateTime.now();
  return 'A${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
}



/* double calculLivraison(double totalPanier) {
  if (totalPanier >= 500) {
    return 100.0;
  } else if (totalPanier >= 300) {
    return 50.0;
  } else {
    return 20.0;
  }
  //return Panier.isNotEmpty ? 20.0 : 0.0;
}
double calculTotalPrix(double totalPanier) {
  return totalPanier + calculLivraison(totalPanier);
} */