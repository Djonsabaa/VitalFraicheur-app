import 'package:flutter/material.dart';
import 'package:appli_produit/Pages/SuiviCommande.dart';
import 'donneeCommande.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../Models/NumeroCommande.dart';
import '../Models/commandeProduit_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Paiement.dart';
import '../Models/SaveCommande.dart';
//import 'PanierPage.dart';
import '../Models/SuiviCommandeArgs.dart';
import '../Models/commandeProduit_model.dart';

class ConfirmCommande extends StatefulWidget {
  final double total;
  final String modePaiement;
  final List<Produit> produits;
  final String commandeId;

  ConfirmCommande({Key? key, required this.total, required this.modePaiement, required this.produits, required this.commandeId}) : super(key: key);

  final User? user = FirebaseAuth.instance.currentUser;

  //final String client = user?.displayName ?? user?.email ?? 'client inconnu';

  @override
  _ConfirmCommandeState createState() => _ConfirmCommandeState();
}
class _ConfirmCommandeState extends State<ConfirmCommande> {
  //final  List<Article> produits ;
 // ConfirmationCommande({required this.produits})

  double getTotalPrix() {
    return widget.total ;
  }
  String clientNom = '';
  String adresseLivraison = '';
  String telephone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientNom();
  }

  Future<void> _loadClientNom() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      setState(() {
        if (data != null ) {
          clientNom = data['name']?? user.email ?? 'Client inconnu';
          adresseLivraison = data['adresse']  ?? 'Adresse inconnu';
          telephone = data['telephone'] ?? 'Numero inconnu';
        } else {
          clientNom = user.email ?? 'Client inconnu';
          adresseLivraison = 'Adresse inconnu';
          telephone = 'Numero inconnu';
        }
        isLoading = false;
      });
    }
  }

  //final Commande commande;
  //double totalCommande = getTotalPrix();

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Facture')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double total = getTotalPrix();

    final donneeCommande = Commande(
      commandeId: genereNumCommande(),

      numero: genereNumCommande(),
      date: DateTime.now(),
      total: total,
      etat: 'en cours',
      client: clientNom,
      adresseLivraison: adresseLivraison,
      modePaiement: widget.modePaiement,
      telephone: telephone,
      livraisonEtat: 'livrée',
      produits: widget.produits,

    );

      return Scaffold(
      backgroundColor: Color(0xFFF1FDF4),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 2,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        backgroundColor: Colors.green.shade200,
      ),

      body: SingleChildScrollView (
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.5, -0.5),
                    radius: 1.5,
                    colors: [Colors.white, Color(0xFFb3f5c4)],
                  )
              ),
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        //colors: [Color(0xFFb3f5c4), Color(0xFFa5dcf8)],
                        colors: [Colors.white, Colors.blueAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Container(
                        width: 320,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green,),
                                  SizedBox(height: 10,),
                                  Text('Paiement effectuee avec succes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),

                            ),

                            Divider(height: 30, thickness: 1.5,),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green,),
                                SizedBox(width: 10,),
                                Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            ),

                            SizedBox(height: 10),
                            Text('Numero commande : ${donneeCommande.numero}'),
                            SizedBox(height: 12),
                            Text('Date: ${DateFormat('d MMMM y à HH :mm', 'fr_FR').format(donneeCommande.date)}'),
                            SizedBox(height: 12),
                            Text('Client : ${donneeCommande.client}'),
                            SizedBox(height: 12),
                            Text('Adresse : ${donneeCommande.adresseLivraison}'),
                            SizedBox(height: 12),
                            Text('Total payé : ${donneeCommande.total.toStringAsFixed(2)} Dhs'),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text('Mode de paiement: ' ),
                                  SizedBox(height: 10),
                                  //Text('VISA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontStyle: FontStyle.italic)),
                                    Text('${widget.modePaiement}'),
                              ],
                            ),

                          ],
                        )

                    ),
                  ),
                 // SizedBox(height: 40)

                  //Opacity(
                  // opacity: 0.5,

                 /* ElevatedButton(
                    //onPressed: null,
                    onPressed: () async {
                      // commande à enregistrer
                      final listeProduits = widget.produits.map((produit) => {

                        'nom': produit.nom,
                        'quantite': produit.quantite,
                        'prixUnitaire': produit.prixUnitaire,
                      }).toList();

                      //final total listeProduits.fold(0.0, (sum, item) => sum + item['prix'] * item['quantite']);
                      // appel à la fonction enregistrer Commande

                      await SaveCommande(listeProduits, total);

                      Navigator.push(context,
                          //MaterialPageRoute(builder: (_) => SuiviCommande(commande: donneeCommande, ),)
                          MaterialPageRoute(builder: (_) => SuiviCommande(commande: donneeCommande ),)
                      );
                    }, */




                ],
              )

          ),
            ),
              SizedBox(height: 40),
                // bouton suivre commande
              ElevatedButton(
                onPressed: () async {
                  final produitsMap = widget.produits.map((produit) => {
                    'nom': produit.nom,
                    'quantite': produit.quantite,
                    'prixUnitaire': produit.prixUnitaire,
                    'total': produit.total,
                    'imageUrl': produit.imageUrl,
                  }).toList();

                  final commandeId = await saveCommandeGlobale(produitsMap, widget.total);

                  if (commandeId != null) {
                    final donneeCommande = Commande(
                      commandeId: commandeId, // ← maintenant réel
                      numero: commandeId,
                      date: DateTime.now(),
                      total: widget.total,
                      etat: 'en_attente',
                      client: clientNom,
                      adresseLivraison: adresseLivraison,
                      modePaiement: widget.modePaiement,
                      telephone: telephone,
                      livraisonEtat: 'livrée',
                      produits: widget.produits,
                    );

                    Navigator.pushNamed(context,
                      '/suivicommande',
                      arguments: SuiviCommandeArgs(commande:donneeCommande,   commandeId: donneeCommande.commandeId,),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : utilisateur non connecté')),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Suivre ma commande', style: TextStyle(color: Colors.white, fontSize: 18),),
              ),


    ]
    )
      ),

    );

  }
}



/*import 'package:flutter/material.dart';
import 'package:appli_produit/SuiviCommande.dart';
import 'donneeCommande.dart';
class Facture extends StatefulWidget {
  @override
  _FactureState createState() => _FactureState();
}
class _FactureState extends State<Facture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF1FDF4),
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('images/logo.png', height: 50,),
        backgroundColor: Colors.green.shade200,
    ),
      body: SingleChildScrollView (
        child: Center(
        child: Container(
            padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.5, -0.5),
              radius: 1.5,
              colors: [Colors.white, Color(0xFFb3f5c4)],
              //colors: [Colors.red.shade500, Colors.yellowAccent],
              //colors: [Color(0xFFc7f3ce), Color(0xFFb3e5fc)],
            )
          ),
          child: Column(
            children: [
              SizedBox(height: 40,),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    //colors: [Color(0xFFb3f5c4), Color(0xFFa5dcf8)],
                    colors: [Colors.white, Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Container(
                  width: 320,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green,),
                          SizedBox(height: 10,),
                          Text('Paiement effectuee avec succes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),

                    ),

                    Divider(height: 30),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green,),
                        SizedBox(width: 10,),
                        Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      ],
                    ),

                    SizedBox(height: 10),
                    Text("Date: 28 Mai 2025 à 17h 00 mn"),
                    SizedBox(height: 16),
                    Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('VISA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontStyle: FontStyle.italic)),
                        SizedBox(width: 10,),
                        Text('Paiement par carte'),
                      ],
                    ),

                  ],
                )

                ),
              ),
              SizedBox(height: 40,),
              //Opacity(
               // opacity: 0.5,
                 ElevatedButton(
                     //onPressed: null,
                   onPressed: (){
                     Navigator.push(context,
                     MaterialPageRoute(builder: (_) => SuiviCommande(commande: donneeCommande),)
                     );
                   },
                     style: ElevatedButton.styleFrom(
                       side: BorderSide(color: Colors.white),
                       backgroundColor: Colors.green,
                       minimumSize: Size(double.infinity, 50),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10)),
                     ),
                   child: Text('Suivre ma commande', style: TextStyle(color: Colors.white),),
                   ),

              //),


            ],
          )

        ),

      ),
      ),
      
    );
  }
} */