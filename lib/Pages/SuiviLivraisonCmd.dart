/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuiviLivraisonPage extends StatefulWidget {
  final String adresseLivraison; // Transmet depuis DetailCommandeFirestore

  SuiviLivraisonPage({required this.adresseLivraison});

  @override
  State<SuiviLivraisonPage> createState() => _SuiviLivraisonPageState();
}

class _SuiviLivraisonPageState extends State<SuiviLivraisonPage> {
  GoogleMapController? _mapController;
  Marker? _livreurMarker;
  Marker? _clientMarker;
  LatLng? _currentPosition;
  LatLng? _clientPosition;
  List<LatLng> _polylinePoints = [];
  String apiKey = 'TON_API_KEY_ICI';

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
        title: Text("Suivi du trajet"),
        backgroundColor: Colors.teal,
      ),
      body: _currentPosition == null || _clientPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
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
    );
  }
}*/





/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SuiviLivraisonPage extends StatefulWidget {
  @override
  _SuiviLivraisonPageState createState() => _SuiviLivraisonPageState();
}

class _SuiviLivraisonPageState extends State<SuiviLivraisonPage> {
  GoogleMapController? _mapController;
  Marker? _livreurMarker;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _demarrerSuivi();
  }

  Future<void> _demarrerSuivi() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission localisation refusée')),
      );
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // mise à jour tous les 5 mètres
      ),
    ).listen((Position position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPosition;
        _livreurMarker = Marker(
          markerId: MarkerId('livreur'),
          position: newPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Livreur'),
        );
      });

      // Optionnel : faire suivre la caméra
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 2,
        centerTitle: true,
        title: Text('Suivi en temps réel', style: TextStyle(color :Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 16,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _livreurMarker != null ? {_livreurMarker!} : {},
      ),
    );
  }
}
*/