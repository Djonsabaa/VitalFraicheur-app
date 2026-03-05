import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class GPSLivreur extends StatelessWidget {
  final String commandeId;
  GPSLivreur({required this.commandeId});

  Future<void> openMap(double lat, double long) async {
    final googleMapsUrl ="https://www.google.com/maps/dir/?api=1&destination=$lat,$long";
    final Uri uri = Uri.parse(googleMapsUrl);
    if(await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }else {
      throw "impo d'ouvrir google Maps";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sv liv'),
      ),
      body: FutureBuilder<DocumentSnapshot> (
        future: FirebaseFirestore.instance
            .collection('commandes')
            .doc(commandeId)
            .get(),
        builder: (context, snapshot ) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final lat = data['latitude'];
          final long = data['longitude'];

          return Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                Text('Livrer à la position:'),
                Text('Latitude: $lat'),
                Text('Longitude: $long'),
                SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => openMap(lat, long),
                  child: Text('ouvrir dans Google Maps'),
                ),


              ],
            ),
          );
        }
      ),
    );
  }


}