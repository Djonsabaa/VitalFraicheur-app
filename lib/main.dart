//import 'package:appli_produit/PagesNavig.dart';
//import 'package:appli_produit/PanierPage.dart';
//import 'package:appli_produit/Profil.dart';
import 'package:appli_produit/Models/NumeroCommande.dart';
import 'package:appli_produit/Pages/Paiement.dart';
import 'package:appli_produit/Pages/SuiviCommande.dart';
import 'package:appli_produit/Pages/SuiviLivraison.dart';
import 'package:appli_produit/Pages/donneeCommande.dart';
import 'package:appli_produit/Models/commandeProduit_model.dart';
import 'Models/commandeProduit_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/SplashScreen.dart';
import 'Pages/Accueil.dart';
import 'Pages/CreerCompte.dart';
import 'Pages/Produits.dart';
import 'Pages/MpassOublie.dart';
import 'Pages/Profil.dart';
import 'Pages/PanierPage.dart';
import 'Pages/ConfirmationCommande.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'Models/HistoCommande.dart';
import 'Pages/Connexion.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'Pages/ListeProduits.dart';
import 'Pages/AdminDashboard.dart';
import 'Pages/AjouterProduit.dart';
import '/Models/SuiviCommandeArgs.dart';
import 'Pages/SuiviLivraison.dart';
import 'Pages/Livreur.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // charger le fichier .env
  await dotenv.load();
  // initialiser Firebase
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  // initialiser stripe
  await initializeDateFormatting('fr_FR', null);
  Stripe.publishableKey = "pk_test_51RXWHQQMEV4tCoiEBPYuG8IiL7CvQe1qRz9o0zJKXjv6asThZ5XjbKDQWHt5imhYq4S5gQGsROEphIpuHXg2aUHf005q5hpZEG";
  await Stripe.instance.applySettings();

// debuger
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print(details.exceptionAsString());
  };
  // activer App Check
 /* await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, //  ️utilise Debug seulement en développement
    appleProvider: AppleProvider.debug,
  ); */

  // Utilise l'émulateur Firebase Functions (localhost:5001)
  //FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'VitalFraîcheur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name){
          case '/':
            //return MaterialPageRoute(builder: (_) => Accueil());
            return MaterialPageRoute(builder: (_) => SplashScreen());

          case '/connexion':
            return MaterialPageRoute(builder: (_) => Connexion());

          case '/accueil':
            return MaterialPageRoute(builder: (_) => Accueil());

          case '/inscrire':
            return MaterialPageRoute(builder: (_) => CreerCompte());
          case '/mpass':
            return MaterialPageRoute(builder: (_) => MpassOublie());
          case  '/produits':
            return MaterialPageRoute(builder: (_) => Produits());
        //  case  '/panierpage':
            //return MaterialPageRoute(builder: (_) => PanierPage());
          case '/profil':
            return MaterialPageRoute(builder: (_) => Profil());
          case '/paiement':
          //final total = settings.arguments as double;
            /*final  args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => Paiement(total: args['total'], produits: args['produits']),);

            case '/facture':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => ConfirmCommande(total: args['total'], modePaiement: args['modePaiement'], produits: args['produits'], commandeId: genereNumCommande(),));
         */
            // case '/suivicommande':
          //  final commande = settings.arguments as Commande;
          //  return MaterialPageRoute(
                //builder: (_) => SuiviCommande(commande: commande, commandeId: genereNumCommande(), ));

          case '/suivicommande':
            final args = settings.arguments as SuiviCommandeArgs;
            return MaterialPageRoute(
              builder: (_) => SuiviCommande(
                commande: args.commande,
                commandeId: args.commandeId,
              ),
            );
         // case '/suiviLivraison':
          //  final args = settings.arguments as Map<String, dynamic>;
           // return MaterialPageRoute(
              //builder: (_) => SuiviLivraison(commande: args['commande'], livraisonEtat: args['livraisonEtat'],),);
        case '/suiviLivraison':
          final adresseLivraison = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => SuiviLivraison(adresseLivraison: adresseLivraison));

           /* case '/gps_client':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (_) => GPSClient(userId: args['userId'], commande: args['commande'],)); */

          case '/commandes':
            return MaterialPageRoute(builder: (_) => HistoCommande());
         // case '/dashboard':
          //  return MaterialPageRoute(builder: (_) => ListeProduits());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => AdminDashboard());
          case '/livreur':
           return MaterialPageRoute(builder: (_) => Livreur());

          default:
            return MaterialPageRoute(
                builder: (_) => Scaffold(body: Center(child: Text('Page non trouvée'))));
        }
      },
    );
  }
}






//import 'package:appli_produit/PagesNavig.dart';
//import 'package:appli_produit/PanierPage.dart';
//import 'package:appli_produit/Profil.dart';
/*
import 'package:appli_produit/Paiement.dart';
import 'package:appli_produit/SuiviCommande.dart';
import 'package:appli_produit/SuiviLivraison.dart';
import 'package:appli_produit/donneeCommande.dart';
import 'package:appli_produit/Models/commandeProduit_model.dart';
import 'Models/commandeProduit_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SplashScreen.dart';
import 'Connexion.dart';
import 'Accueil.dart';
import 'CreerCompte.dart';
import 'Produits.dart';
import 'MpassOublie.dart';
import 'Profil.dart';
import 'PanierPage.dart';
import 'ConfirmationCommande.dart';
import 'GPSClient.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  // initialiser stripe
  await initializeDateFormatting('fr_FR', null);
  Stripe.publishableKey = 'pk_test_51RXWHQQMEV4tCoiEBPYuG8IiL7CvQe1qRz9o0zJKXjv6asThZ5XjbKDQWHt5imhYq4S5gQGsROEphIpuHXg2aUHf005q5hpZEG';
  await Stripe.instance.applySettings();

// debuger
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print(details.exceptionAsString());
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalFraîcheur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name){
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/connexion':
            return MaterialPageRoute(builder: (_) => Connexion());
          case '/accueil':
            return MaterialPageRoute(builder: (_) => Accueil());
          case '/inscrire':
            return MaterialPageRoute(builder: (_) => CreerCompte());
          case '/mpass':
            return MaterialPageRoute(builder: (_) => MpassOublie());
          case  '/produits':
            return MaterialPageRoute(builder: (_) => Produits());
          case  '/panierpage':
            return MaterialPageRoute(builder: (_) => PanierPage());
          case '/profil':
            return MaterialPageRoute(builder: (_) => Profil());
          case '/paiement':
            //final total = settings.arguments as double;
          final  args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => Paiement(total: args['total'], produits: args['produits']),);
          case '/facture':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => ConfirmCommande(total: args['total'], modePaiement: args['modePaiement'], produits: args['produits']));
            case '/suivicommande':
              final commande = settings.arguments as Commande;
            return MaterialPageRoute(
            builder: (_) => SuiviCommande(commande: commande ));

          case '/suiviLivraison':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
             builder: (_) => SuiviLivraison(commande: args['commande'], livraisonEtat: args['livraisonEtat'],),);
          case '/gps_client':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (_) => GPSClient(userId: args['userId'], commande: args['commande'],));



            default:
            return MaterialPageRoute(
                builder: (_) => Scaffold(body: Center(child: Text('Page non trouvée'))));
        }
      },
    );
  }
}

 */