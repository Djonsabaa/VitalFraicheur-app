import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PaiementService {
  static Future<void> makePayment(double totalPrix) async {
    try {
      print("makePayment() appelé avec totalPrix: $totalPrix");

      final int amountInCents = (totalPrix * 100).round();
      print('Amount en cents envoyé à la fonction : $amountInCents');
      print('Type de amountInCents : ${amountInCents.runtimeType}');
      final result = await FirebaseFunctions.instance
          .httpsCallable('createPaymentIntent')
          .call({'amount': amountInCents});

      final clientSecret = result.data['clientSecret'];
      final paymentIntentId = result.data['paymentIntentId'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VitalFresh',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      //verif  statut avec Cloud Function
      final verification = await FirebaseFunctions.instance
          .httpsCallable('getPaymentIntentStatus')
          .call({'paymentIntentId': paymentIntentId});

      if (verification.data['status'] == 'succeeded') {
        print(' Paiement confirmé côté serveur');
      } else {
        print('Paiement échoué côté serveur, statut : ${verification
            .data['status']}');
        throw Exception('Paiement non confirmé');
      }
    } on StripeException catch (e) {
      print(" StripeException : ${e.error.localizedMessage}");
      throw Exception("Paiement annulé ou refusé");
    } catch (e) {
      print("Erreur inattendue : $e");
      rethrow;
    }
  }
  }

/*import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PaiementService {
  static Future<void> makePayment() async {
    try {
      print("debut paiement");
      final result = await FirebaseFunctions.instance
          .httpsCallable('createPaymentIntent')
          .call({'amount': 5000});

      final clientSecret = result.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VitalFresh',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      print('paiement réussi');
    } catch (e) {
      print("Erreur de paiement : $e");
    }
  }
}*/
