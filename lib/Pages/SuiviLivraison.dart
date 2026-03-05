import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuiviLivraison extends StatefulWidget {
  final String adresseLivraison; // Transmet depuis DetailCommandeFirestore

  SuiviLivraison({required this.adresseLivraison});

  @override
  State<SuiviLivraison> createState() => _SuiviLivraisonState();
}

class _SuiviLivraisonState extends State<SuiviLivraison> {
  GoogleMapController? _mapController;
  Marker? _livreurMarker;
  Marker? _clientMarker;
  LatLng? _currentPosition;
  LatLng? _clientPosition;
  List<LatLng> _polylinePoints = [];
  String apiKey = '';

  @override
  void initState() {
    super.initState();
    _initialiserSuivi();
  }

  Future<void> _initialiserSuivi() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    await _geocoderAdresseClient();

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      final pos = LatLng(position.latitude, position.longitude);
      _currentPosition = pos;

      _livreurMarker = Marker(
        markerId: MarkerId('livreur'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Livreur'),
      );

      if (_clientPosition != null) {
        _chargerTrajet(pos, _clientPosition!);
      }

      setState(() {});
      _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  Future<void> _geocoderAdresseClient() async {
    try {
      final locations = await locationFromAddress(widget.adresseLivraison);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _clientPosition = LatLng(loc.latitude, loc.longitude);
        _clientMarker = Marker(
          markerId: MarkerId('client'),
          position: _clientPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Client'),
        );
      }
    } catch (e) {
      print("Erreur géocodage : $e");
    }
  }

  Future<void> _chargerTrajet(LatLng start, LatLng end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = PolylinePoints().decodePolyline(
          data['routes'][0]['overview_polyline']['points']);
      _polylinePoints = points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {});
    } else {
      print("Erreur Directions API: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        centerTitle: true,
        elevation: 4,
        title: Text("Suivi en temps réel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
      body: _currentPosition == null || _clientPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
            children:[
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: {
                    if (_livreurMarker != null) _livreurMarker!,
                    if (_clientMarker != null) _clientMarker!,
                  },
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("itineraire"),
                      points: _polylinePoints,
                      color: Colors.blueAccent,
                      width: 5,
                    ),
                  },
                ),

              ),
                  // info livreur
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Livreur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.green.shade400,
                      padding: const EdgeInsets.all(16),
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                         Text('Nom : Ahmed', style: TextStyle(color: Colors.white),),
                         Text('Téléphone : +212 6 55 44 33 22', style: TextStyle(color: Colors.white)),
                         Text('N° de suivi : LIV-120056709', style: TextStyle(color: Colors.white)),
    ],
    )
    ),
    ],
              )


            ]
      )

    );
  }
}



/*import 'package:flutter/material.dart';
import 'Models/commandeProduit_model.dart';
import 'Models/string_extension.dart';
import 'GPSLivreur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/Evaluation.dart';

class SuiviLivraison extends StatefulWidget {
  final Commande commande;
  final String livraisonEtat;
  SuiviLivraison({required this.commande, required this.livraisonEtat});

  @override
  _SuiviLivraisonState createState() => _SuiviLivraisonState();
}
class _SuiviLivraisonState extends State<SuiviLivraison> {

  List<QueryDocumentSnapshot> commandes = [];
  @override
  void initState() {
    super.initState();
    fetchCommandes();
  }
  Future<void> fetchCommandes() async {
    final snapshot = await FirebaseFirestore.instance.collection('commandes').get();
    setState(() {
      commandes = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Commande reçue : ${widget.commande}');
    final currentStatus = widget.commande.livraisonEtat ?? 'en_livraison';
    final steps = ['en_livraison', 'en_cours', 'livrée'];
    final currentIndex = steps.indexOf(currentStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de livraison', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimeline(currentIndex, steps),
          const SizedBox(height: 24),
          _buildLivreurInfo(),
          const SizedBox(height: 24),
          _buildAdresse(widget.commande),
          const SizedBox(height: 24),
          _buildProduitResume(widget.commande),
          const SizedBox(height: 32),
          if (currentStatus == 'livrée') _buildConfirmationBtn(context),
          //_buildCommandesSuivantes(),
        ],
      ),
    );
  }

  Widget _buildTimeline(int currentIndex, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statut de livraison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(steps.length, (index) {

            final step = steps[index];
            final isDelivered = step == 'livrée';

            final active = index <= currentIndex;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
              children: [
                Icon( isDelivered && currentIndex == index
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
                  color: isDelivered && currentIndex == index ? Colors.green : Colors.grey,
                ),
                 SizedBox(width: 8),
                Text(steps[index].replaceAll('_', ' ').capitalize(),
                    style: TextStyle(fontSize: 16,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? Colors.green[700] : Colors.grey[700],
                    )),
              ],
            ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLivreurInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Livreur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          color: Colors.green.shade400,
            padding: const EdgeInsets.all(16),
            width: 500,
       child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
       children: [

    Text('Nom : Ahmed', style: TextStyle(color: Colors.white),),
    Text('Téléphone : +212 6 55 44 33 22', style: TextStyle(color: Colors.white)),
    Text('N° de suivi : LIV-120056709', style: TextStyle(color: Colors.white)),
    ],
        )
        ),
      ],
    );

  }

  Widget _buildAdresse(Commande commande) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adresse de livraison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          color: Colors.green.shade400,
          padding: const EdgeInsets.all(16),
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(commande.client, style: TextStyle(color: Colors.white)),
              Text(commande.adresseLivraison, style: TextStyle(color: Colors.white)),
              Text(commande.telephone, style: TextStyle(color: Colors.white)),
            ],
          ),
        )

      ],
    );
  }

  Widget _buildProduitResume(Commande commande) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produits livrés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...commande.produits.map((p) {
            return ListTile(
              leading: Image.asset(p.imageUrl, width: 50, height: 50),
              title: Text(p.nom),
              subtitle: Text('${p.quantite} x ${p.prixUnitaire} '),
              trailing: Text('${p.total} '),
            );
          }).toList(),
        ],
      );
    } catch(e) {
      return Text('Erreur dans l\' affichage produits: $e');
    }
  }

  Widget _buildConfirmationBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
        onPressed: () {},
    icon: const Icon(Icons.check),
    label: Text('Commande reçue', style: TextStyle(color: Colors.white),),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    ),

   //bouton evaluation
       /* ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => EvaluerCommandePage())
            );
          },
          icon: const Icon(Icons.check),
          label: Text('Evaluer', style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ), */

   /* SizedBox(width: 10),
     ListView.builder(
       itemCount: commandes.length,
       itemBuilder: (context, index) {
         final commande = commandes[index];
         final id = commande.id ; // id du doc firestore

         return ListTile(
           title: Text('commande #${index + 1}'),
           subtitle: Text('Client : ${commande['clientName']}'),
           trailing: ElevatedButton(
             child: Text('suivre client'),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => GPSLivreur(commandeId: id)),
               );
             },

           ),
         );
       },
     )
*/
      ],
    );

  }


/*  Widget _buildCommandesSuivantes() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final commande = commandes[index];
        final id = commande.id;

        return ListTile(
          title: Text('Commande #${index + 1}'),
          subtitle: Text('Client : ${commande['clientName']}'),
          trailing: ElevatedButton(
            child: const Text('Suivre client'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GPSLivreur(commandeId: id),
                ),
              );
            },
          ),
        );
      },
    );
  }
*/



}

*/