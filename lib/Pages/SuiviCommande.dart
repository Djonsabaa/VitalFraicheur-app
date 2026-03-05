import 'package:appli_produit/Pages/SuiviLivraison.dart';
import 'package:flutter/material.dart';
import '../Models/commandeProduit_model.dart';
import '../Models/string_extension.dart';
import 'GPSClient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/SaveCommande.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../Models/ModifierAdresseLivraison.dart';


class SuiviCommande extends  StatelessWidget {
  final String commandeId;
  final Commande commande;
  SuiviCommande({super.key, required this.commande, required this.commandeId});

  Future<void> mettreAJourEtatCommande(String commandeId, String nouvelEtat) async {
    final docRef = FirebaseFirestore.instance.collection('commandes').doc(commandeId);
    await docRef.update({'etat': nouvelEtat});
  }
    //recuperation coordonnees GPS avec API géocodage
  Future<LatLng> getLatLngFromPlusCode(String plusCode) async {
    List<Location> locations = await locationFromAddress(plusCode);
    if (locations.isNotEmpty) {
      return LatLng(locations[0].latitude, locations[0].longitude);
    }
    throw Exception('PlusCode non trouvé');

  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 4,
        title: Text('Suivi de commande', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body:StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('commandes').doc(commandeId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            var doc = snapshot.data!;
            // Extraction sécurisée du champ etat avec valeur par défaut
            String etat = doc.get('etat') ?? 'en_attente';

            // Construire un objet commande à partir du doc (à adapter selon ta classe Commande)
            final commande = Commande(
              commandeId: doc.id,
              numero: commandeId,
              //date: doc.get('date'),
              date: (doc.get('date') as Timestamp).toDate(),
              total: doc.get('total'),
              etat: etat,
              client: doc.get('client')['nom']  ,
              adresseLivraison: doc.get('client')['adresseLivraison'],
              telephone: doc.get('client')['telephone'],
              modePaiement: doc.get('client')['modePaiement'],
              livraisonEtat: doc.get('client')['livraisonEtat'],
              produits: (doc.get('produits') as List<dynamic>).map((p) =>
                  Produit.fromMap(p)).toList(),
              // et autres champs selon ta classe
            );


            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                //_buildCommandeInfo(),
                _buildAdresse(context),
                SizedBox(height: 16),
                _buildEtapesSuivi(commande),
                SizedBox(height: 16),
                _buildDetailsProduit(context),
                SizedBox(height: 16),

              ],
            );
          }
            )
    );
  }

 /* Widget _buildCommandeInfo() {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: ListTile(
       title: Text('Numéro commande: ${commande.numero}'),
        leading: Text('Nom: ${commande.client}'),
        subtitle: Text('Date : ${DateFormat('dd MMM yyyy – HH:mm').format(commande.date)}\nTotal payé : ${commande.total} MAD',
        ),

      ),
    );
  }*/

  Widget _buildAdresse(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            width: 800,
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Nom: ${commande.client}\n'
                'Numéro commande: ${commande.numero}\n'
                'Date : ${DateFormat('dd MMM yyyy – HH:mm').format(commande.date)}\nTotal payé : ${commande.total} MAD\n'
                'Téléphone: ${commande.telephone}\n'
                'Adresse de livraison: ${commande.adresseLivraison}\n'
            ),
          ),


          FutureBuilder<LatLng>(
            future: getLatLngFromPlusCode(commande.adresseLivraison),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Adresse non trouvée');
              } else {
                return SizedBox(
                  height: 180,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: snapshot.data!,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('livraison'),
                        position: snapshot.data!,
                        infoWindow: InfoWindow(title: 'Adresse de livraison'),
                      ),
                    },
                    zoomControlsEnabled: false,
                  ),
                );
              }
            },
          ),
          Divider(),

          // bouton modifier add

          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) =>
                    ModifierAdresseLivraison(
                      commandeId: commandeId,
                      adresseActuelle: commande.adresseLivraison,
                    ),
              );
            },
            style: ElevatedButton.styleFrom(
              //side: BorderSide(color: Colors.white),
              // backgroundColor: Colors.white,
              elevation: 4,
            ),
            icon: Icon(Icons.edit_location_alt, color: Colors.green),
            label: Text(
                'Modifier l\'adresse', style: TextStyle(color: Colors.green)),
          ),
        ]
    );
  }

  Widget _buildEtapesSuivi(Commande commande) {
    final etapes = [
      {'key': 'en_attente', 'label': 'En attente', 'icon': Icons.hourglass_empty},
   //   {'key': 'confirmée', 'label': 'Confirmée', 'icon': Icons.check_circle_outline},
      {'key': 'en_preparation', 'label': 'Préparation', 'icon': Icons.kitchen},
    //  {'key': 'prete', 'label': 'Prête', 'icon': Icons.local_shipping},
      {'key': 'expediee', 'label': 'Expédiée', 'icon': Icons.airport_shuttle},
     // {'key': 'en_livraison', 'label': 'En livraison', 'icon': Icons.directions_bike},
     // {'key': 'livree', 'label': 'Livrée', 'icon': Icons.home},
    ];

    int currentIndex = etapes.indexWhere((e) => e['key'] == commande.etat);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: etapes.map((etape) {
          int etapeIndex = etapes.indexOf(etape);
          bool isActive = etapeIndex <= currentIndex && currentIndex != -1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
                  child: Icon(
                    etape['icon'] as IconData,
                    color: isActive ? Colors.white : Colors.grey,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  etape['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }




  Widget _buildDetailsProduit(BuildContext context) {
    //print('Produits dans commande : ${commande.produits.length}');
    final produits = commande.produits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produits commandés', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        //...commande.produits.map((produit) =>
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true, // pourque ListView fonctionne ds une column
          physics: NeverScrollableScrollPhysics(),
          itemCount: produits.length,
          itemBuilder: (context, index) {
            final produit = produits[index];
            return Card(
              elevation: 4,
              color: Colors.green.shade400,
              child: ListTile(
                leading: Image.asset(produit.imageUrl, width: 50),
                title: Text(
                  produit.nom, style: TextStyle(color: Colors.white),),
                subtitle: Text('${produit.quantite} | ${produit.prixUnitaire}',
                    style: TextStyle(color: Colors.white)),
                trailing: Text(
                    produit.total, style: TextStyle(color: Colors.white)),
              ),
            );
          },
        ),


        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            if (currentUserId != null) {
              final produits = commande.produits;
              final total = commande.total;
              final produitsMap = commande.produits.map((p) =>
              {
                'nom': p.nom,
                'prixUnitaire': p.prixUnitaire,
                'quantite': p.quantite,
                'total': p.total,
                'imageUrl': p.imageUrl,
              }).toList();

              await saveCommandeGlobale(produitsMap, commande.total);
              // enreg dans firestore

              Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      SuiviLivraison(
                          adresseLivraison: commande.adresseLivraison),
                    //MaterialPageRoute(builder: (_) => SuiviLivraison(commande: commande, livraisonEtat: commande.livraisonEtat,),),
                    // MaterialPageRoute(builder: (_) => GPSClient(userId: currentUserId!, commande: commande,)),
                  )
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Utilisateur non connecté')
                  ));
            }
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: Colors.white),
            backgroundColor: Colors.green,
            minimumSize: Size(double.infinity, 50),
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Suivi en temps réel',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        )

      ],
    );
  }
  }






/*import 'package:appli_produit/SuiviLivraison.dart';
import 'package:flutter/material.dart';
import 'Models/commandeProduit_model.dart';
import 'Models/string_extension.dart';
import 'GPSClient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/SaveCommande.dart';
import 'Models/ModifierAdd.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';



class SuiviCommande extends  StatelessWidget {
  final Commande commande;
  SuiviCommande({super.key, required this.commande});

  Future<void> mettreAJourEtatCommande(String commandeId, String nouvelEtat) async {
    final docRef = FirebaseFirestore.instance.collection('commandes').doc(commandeId);
    await docRef.update({'etat': nouvelEtat});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 2,
        title: Text('Suivi de commande', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCommandeInfo(),
          SizedBox(height: 16),
          _buildEtapesSuivi(commande),
          SizedBox(height: 16),
          _buildDetailsProduit(),
          SizedBox(height: 16),
          _buildAdresse(context),
        ],
      ),
    );
  }

  Widget _buildCommandeInfo() {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        title: Text('Numéro commande: ${commande.numero}'),
        subtitle: Text('Date: ${commande.date}\nTotal payé: ${commande.total}'),
      ),
    );
  }

  Widget _buildEtapesSuivi(Commande commande) {
    final etapes = [
      {'key': 'en_attente', 'label': 'En attente', 'icon': Icons.hourglass_empty},
      {'key': 'confirmée', 'label': 'Confirmée', 'icon': Icons.check_circle_outline},
      {'key': 'en_preparation', 'label': 'Préparation', 'icon': Icons.kitchen},
      {'key': 'prete', 'label': 'Prête', 'icon': Icons.local_shipping},
      {'key': 'expediee', 'label': 'Expédiée', 'icon': Icons.airport_shuttle},
      {'key': 'en_livraison', 'label': 'En livraison', 'icon': Icons.directions_bike},
      {'key': 'livree', 'label': 'Livrée', 'icon': Icons.home},
    ];

    int currentIndex = etapes.indexWhere((e) => e['key'] == commande.etat);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: etapes.map((etape) {
          int etapeIndex = etapes.indexOf(etape);
          bool isActive = etapeIndex <= currentIndex && currentIndex != -1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
                  child: Icon(
                    etape['icon'] as IconData,
                    color: isActive ? Colors.white : Colors.grey,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  etape['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }




  Widget _buildDetailsProduit() {
    //print('Produits dans commande : ${commande.produits.length}');
    final produits = commande.produits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produits commandés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        //...commande.produits.map((produit) =>
        SizedBox(height: 14,),
        ListView.builder(
          shrinkWrap: true,         // pourque ListView fonctionne ds une column
          physics:  NeverScrollableScrollPhysics(),
          itemCount: produits.length,
          itemBuilder: (context, index) {
            final produit = produits[index];
            return Card(
              color: Colors.green.shade400,
              child: ListTile(
                leading: Image.asset(produit.imageUrl, width: 50),
                title: Text(produit.nom, style: TextStyle(color: Colors.white),),
                subtitle: Text('${produit.quantite} | ${produit.prixUnitaire}', style: TextStyle(color: Colors.white)),
                trailing: Text(produit.total, style: TextStyle(color: Colors.white)),
              ),
            );
          },
        ),
      ],
    );

  }

  Widget _buildAdresse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          width: 500,
          margin: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Nom: ${commande.client}\nAdresse de livraison: ${commande.adresseLivraison}\n📞 ${commande.telephone}'),
        ),

        SizedBox(height: 30),


          // bouton modifier add
       /* ElevatedButton.icon(
          icon: Icon(Icons.location_on),
          label: Text("Modifier l'adresse de livraison"),
          onPressed: () {
            // Récupère les coordonnées actuelles depuis Firestore puis lance la page
            Navigator.push(context, MaterialPageRoute(builder: (context) => ModifierAddLivraison(commandeId: 'id_de_la_commande',
                positionInitiale: LatLng(lat, lng), // à récupérer depuis Firestore
              ),
            ));
          },
        ), */


        OutlinedButton.icon(
          //icon: Icon(Icons.my_location),
          label: Text("Utiliser ma position actuelle", style: TextStyle(fontSize: 18, color: Colors.green)),
          onPressed: () async {
            try {
              // Vérifie que la localisation est activée
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(" La localisation est désactivée."),
                ));
                return;
              }

              // Vérifie ou demande la permission
              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(" Permission de localisation refusée."),
                  ));
                  return;
                }
              }

              // Récupère la position GPS
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              // Convertit en adresse texte
              List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
              if (placemarks.isEmpty) throw Exception("Impossible de récupérer l'adresse.");

              Placemark place = placemarks.first;
              String adresse = "${place.street}, ${place.locality}, ${place.country}";

              // Met à jour Firestore
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'adresse': adresse,
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Adresse mise à jour avec succès : $adresse"),
                  backgroundColor: Colors.green,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(" Utilisateur non connecté."),
                ));
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Erreur : ${e.toString()}"),
              )
              );
            }
          },

          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.green),
            //backgroundColor: Colors.green,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            if (currentUserId != null){

              final produits = commande.produits;
              final total = commande.total;
              final produitsMap = commande.produits.map((p) => {
                'nom': p.nom,
                'prixUnitaire': p.prixUnitaire,
                'quantite': p.quantite,
                'total': p.total,
                'imageUrl': p.imageUrl,
              }).toList();

              await saveCommandeGlobale(produitsMap, commande.total);
              // enreg dans firestore

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SuiviLivraison(commande: commande, livraisonEtat: commande.livraisonEtat,),),
                // MaterialPageRoute(builder: (_) => GPSClient(userId: currentUserId!, commande: commande,)),

              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Utilisateur non connecté')
                  ));
            }
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: Colors.white),
            backgroundColor: Colors.green,
            minimumSize: Size(double.infinity, 50),
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Suivi en temps réel', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),

      ],

    );
  }


}
*/