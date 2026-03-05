import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Profil.dart';
//import 'package:lucide_icons/lucide_icons.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class Livreur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardLivreur();
  }
}

class DashboardLivreur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        elevation:4,
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        title: Text("Tableau de bord Livreur", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.person_outline, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profil()),
                );
          })
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(" Commandes reçues", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
            SizedBox(height: 16),
            Expanded(child: ListeCommandes()),
          ],
        ),
      ),
     /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
         /* Navigator.push(
              context, MaterialPageRoute(builder: (_) => CarteLivraison())); */
        },
        icon: Icon(Icons.map_outlined),
        label: Text("Carte"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      */

    );
  }
}




class ListeCommandes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('commandes')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune commande disponible'));
        }

        final commandesDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: commandesDocs.length,
          itemBuilder: (context, index) {
            final doc = commandesDocs[index];
            final data = doc.data()! as Map<String, dynamic>;

            final client = data['client'] ?? {};
            final nomClient = client['nom'] ?? 'Client inconnu';
            final adresse = client['adresseLivraison']?.toString() ??  'Adresse non renseignée';
            final produits = data['produits'] ?? [];
            final total = data['total'] ?? 0;
            //final date = Timestamp.now();
            //final date = client['date'] ?? 'date non enregistree' ;
            final dateCommande = data['date'] != null
                ? (data['date'] as Timestamp).toDate()
                : null;

            //  texte  nom x quantité - prix
            final produitsText = (produits as List).map((p) {
              final nom = p['nom'] ?? 'Produit';
              final date = p['date'] ?? '';
              final qte = p['quantite'] ?? 1;
              final prix = p['prixUnitaire'] ?? 0;
              return '$nom x$qte - ${prix} DHS';
              //final total = p['total'];
              //Total : ${total.toStringAsFixed(2)} DH',
            }).join('\n');
            final detailsAvecTotal = produitsText + '\n\nTotal : ${total.toStringAsFixed(2)} DH';

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.delivery_dining, color: Colors.green.shade800),
                ),
                title: Text("Client :$nomClient", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.green.shade600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    //Text("Date: ${DateFormat('dd/MM/yyyy – HH:mm').format(date.toDate())}",
                  Text('Date: ${dateCommande != null ? DateFormat('dd/MM/yyyy HH:mm').format(dateCommande) :
                  'Date non enregistrée'}',

                  style: TextStyle(color: Colors.green.shade600, fontSize: 16)),

                    SizedBox(height: 4),
                    Text("Produits", style: TextStyle(color: Colors.blue.shade600, fontSize: 16)),
                    SizedBox(height: 4),
                    //Text("$produitsText", style: TextStyle(color: Colors.blue.shade600, fontSize: 18)),
                    SizedBox(height: 2),
                    Text("$detailsAvecTotal",style: TextStyle(color: Colors.blue.shade600, fontSize: 16) ),
                    SizedBox(height: 4),
                    Text("Adresse: $adresse", style: TextStyle(color: Colors.blue.shade600,fontSize: 16)),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailCommandeFirestore(doc: doc)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


 // dtailCommande avec carte


class DetailCommandeFirestore extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  DetailCommandeFirestore({required this.doc});

  @override
  State<DetailCommandeFirestore> createState() => _DetailCommandeFirestoreState();
}

class _DetailCommandeFirestoreState extends State<DetailCommandeFirestore> {
  LatLng? _clientLocation;
  bool _loadingMap = true;

  @override
  void initState() {
    super.initState();
    _loadClientLocation();
  }
  Future<void> _loadClientLocation() async {
    final data = widget.doc.data()! as Map<String, dynamic>;
    final adresse = data['client']?['adresseLivraison'];

    if (adresse != null && adresse.toString().isNotEmpty) {
      try {
        final locations = await locationFromAddress(adresse);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          setState(() {
            _clientLocation = LatLng(loc.latitude, loc.longitude);
            _loadingMap = false;
          });
        }
      } catch (e) {
        print("Erreur de géocodage : $e");
        setState(() => _loadingMap = false);
      }
    } else {
      _loadingMap = false;
    }
  }
   // fnction pour ouvvrir Map
  Future<void> _ouvrirGoogleMaps(LatLng location) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’ouvrir Google Maps.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data()! as Map<String, dynamic>;

    final client = data['client'] ?? {};
    final nomClient = client['nom'] ?? 'Client inconnu';
    final adresse = client['adresseLivraison'] ?? 'Adresse non renseignée';

    final produits = data['produits'] ?? [];
    final produitsText = (produits is List)
        ? produits.map((p) {
      final nom = p['nom'] ?? 'Produit';
      final qte = p['quantite'] ?? 1;
      final prix = p['prixUnitaire'] ?? 0;
      return '$nom x$qte - ${prix} DHS';
    }).join('\n')
        : 'Produits non renseignés';

    final total = data['total'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       elevation: 2,
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text("Détails de la commande", style: TextStyle(color: Colors.blue)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading:Icon(Icons.person, color: Colors.blue),
              title: Text("Client"),
              subtitle: Text("$nomClient", style: TextStyle(color: Colors.blue)),
            ),
            Divider(),
            ListTile(
              leading:Icon(Icons.location_on_outlined, color: Colors.blue),
              title: Text("Adresse"),
              subtitle: Text("$adresse", style: TextStyle(color: Colors.blue)),
            ),
            Divider(),
            _loadingMap
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
                : (_clientLocation == null
                ? Text("Impossible d'afficher la carte.")
                : SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _clientLocation!,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('client'),
                    position: _clientLocation!,
                    infoWindow: InfoWindow(title: nomClient),
                  ),
                },
              ),
            )),

            // bouton ouvrir map
            if (_clientLocation != null) ...[
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _ouvrirGoogleMaps(_clientLocation!),
                icon: Icon(Icons.navigation_outlined),
                label: Text("Ouvrir dans Google Maps"), style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],


            Divider(),
            ListTile(
              leading:Icon(Icons.shopping_bag,  color: Colors.blue),
              title: Text("Produits", style: TextStyle(color: Colors.blue)),
              subtitle: Text(produitsText),
            ),
            Divider(),
            ListTile(
              title: Text("Total ${total.toStringAsFixed(2)} Dhs", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                widget.doc.reference.update({'etat': 'livré'});
                Navigator.pop(context);
              },
              icon: Icon(Icons.check_circle_outline),
              label: Text("Marquer comme livré"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







/*
class DetailCommandeFirestore extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  DetailCommandeFirestore({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data()! as Map<String, dynamic>;

    // Accès client
    final client = data['client'] ?? {};
    final nomClient = client['nom'] ?? 'Client inconnu';
    final adresse = client['adresseLivraison'] ?? 'Adresse non renseignée';

    // Produits
    final produits = data['produits'] ?? [];
    final produitsText = (produits is List)
        ? produits.map((p) {
      final nom = p['nom'] ?? 'Produit';
      final qte = p['quantite'] ?? 1;
      final prix = p['prixUnitaire'] ?? 0;
      return '$nom x$qte - ${prix} DH';
    }).join('\n')
        : 'Produits non renseignés';

    // Total
    final total = data['total'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        title: Text("Détail commande", style: TextStyle(color: Colors.blue)),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("👤 Client"),
              subtitle: Text(nomClient),
            ),
            Divider(),
            ListTile(
              title: Text(" Adresse"),
              subtitle: Text(adresse),
              trailing: Icon(Icons.location_on_outlined),
            ),
            Divider(),
            ListTile(
              title: Text(" Produits"),
              subtitle: Text(produitsText),
            ),
            Divider(),
            ListTile(
              title: Text(" Total"),
              subtitle: Text('${total.toStringAsFixed(2)} DH',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Met à jour l'état de la commande en "livré"
                doc.reference.update({'etat': 'livré'});
                Navigator.pop(context);
              },
              icon: Icon(Icons.check_circle_outline),
              label: Text("Marquer comme livré"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} */

/*
class CarteLivraison extends StatefulWidget {
  @override
  _CarteLivraisonState createState() => _CarteLivraisonState();
}

class _CarteLivraisonState extends State<CarteLivraison> {
  Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerCommandes();
  }

  Future<void> _chargerCommandes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('commandes')
        .orderBy('date', descending: true)
        .get();

    Set<Marker> newMarkers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final client = data['client'] ?? {};
      final nomClient = client['nom'] ?? 'Client';
      final adresse = client['adresseLivraison'];

      if (adresse != null && adresse.toString().isNotEmpty) {
        try {
          List<Location> locations = await locationFromAddress(adresse);
          if (locations.isNotEmpty) {
            final location = locations.first;
            newMarkers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(title: nomClient, snippet: adresse),
              ),
            );
          }
        } catch (e) {
          print("Erreur de géocodage pour l’adresse '$adresse' : $e");
        }
      }
    }

    setState(() {
      _markers = newMarkers;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des livraisons"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(30.4279, -9.5980), // Agadir par défaut
          zoom: 12,
        ),
        markers: _markers,
      ),
    );
  }
}
*/



/*
class CarteLivraison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des livraisons"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(30.42796133580664, -9.598015831389904),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId("client1"),
            position: LatLng(30.42796133580664, -9.598015831389904),
            infoWindow: InfoWindow(title: "Zahra Ben Ali"),
          ),
        },
      ),
    );
  }
} */




/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class Livreur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livreur ',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: DashboardLivreur(),
    );
  }
}

class DashboardLivreur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        title: const Text("Tableau de bord"),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.person_outline), onPressed: () {})
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Commandes du jour", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Expanded(child: ListeCommandes()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => CarteLivraison()));
        },
        icon: Icon(Icons.map_outlined),
        label: Text("Carte"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ListeCommandes extends StatelessWidget {
  final List<Map<String, String>> commandes = [
    {
      "nom": "Zahra Ben Ali",
      "adresse": "Rue 45, Agadir",
      "produits": "Panier légumes bio",
    },
    {
      "nom": "Ahmed Tazi",
      "adresse": "Av. Hassan II, Rabat",
      "produits": "Filet de tilapia, salade mixte",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final commande = commandes[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.delivery_dining, color: Colors.green.shade800),
            ),
            title: Text(commande['nom']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(commande['produits']!),
                Text(commande['adresse']!, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailCommande(commande: commande)),
            ),
          ),
        );
      },
    );
  }
}

class DetailCommande extends StatelessWidget {
  final Map<String, String> commande;

  DetailCommande({required this.commande});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Détail commande"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Client"),
              subtitle: Text(commande['nom']!),
            ),
            Divider(),
            ListTile(
              title: Text("Adresse"),
              subtitle: Text(commande['adresse']!),
              trailing: Icon(Icons.location_on_outlined),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Text("🛒 Produits"),
              subtitle: Text(commande['produits']!),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.check_circle_outline),
              label: Text("Marquer comme livré"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarteLivraison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des livraisons"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(30.42796133580664, -9.598015831389904),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId("client1"),
            position: LatLng(30.42796133580664, -9.598015831389904),
            infoWindow: InfoWindow(title: "Zahra Ben Ali"),
          ),
        },
      ),
    );
  }
}
*/