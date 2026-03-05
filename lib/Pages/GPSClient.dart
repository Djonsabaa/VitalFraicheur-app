/*import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SuiviLivraison.dart';
import 'Models/commandeProduit_model.dart';
class GPSClient extends StatefulWidget {
  final String userId;
  final Commande commande;
  GPSClient({required this.userId, required this.commande});


  @override
  _GPSClientState createState () => _GPSClientState();
}
class _GPSClientState extends State<GPSClient> {


  double? latitude;
  double? longitude;
  bool loading = false;

  Future<void> detectPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activez les services de localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission GPS refusée')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission refusée définitivement')),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position detectée: $latitude, $longitude')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  void validerCommande() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez détecter votre position')),
      );
      return;
    }
    setState(() => loading = true );
    await Future.delayed(Duration(seconds: 2));
    //setState(() => loading = false );
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('commandes').add({
      //'produits': ['Tomates', 'Carottes'], // À adapter
     // 'etat': 'en cours',
      'clientId': currentUserId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      loading = false;
    });
    //Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('confirmée avec votre position')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commande = widget.commande;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Position GPS', style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 2,
        backgroundColor: Colors.green.shade300,
      ),

      body: Center(
        child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Adresse GPS :', style: TextStyle(color: Colors.green)),
            Text(latitude != null ? '$latitude, $longitude'  : 'Non détectée', style: TextStyle(color: Colors.green)),
            SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                backgroundColor: Colors.green,
                elevation: 4,
              ),
              onPressed: detectPosition,

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(' Utiliser ma position actuelle', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.green),
                elevation: 4,
              ),
              onPressed: loading ? null : validerCommande,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Envoyer ma position'),
                ],
              ),
            ),

            SizedBox(height: 16),
            ElevatedButton(

              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                backgroundColor: Colors.green,
                elevation: 4,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => SuiviLivraison(commande: commande, livraisonEtat: commande.livraisonEtat)),
                );
              },

                child: Text('Suivre la livraison', style: TextStyle(color: Colors.white)),



            ),

          ],
        ),
    ),
      ),
    );
  }
}*/