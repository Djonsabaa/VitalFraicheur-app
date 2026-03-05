import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AjouterProduit.dart';
import 'ListeProduits.dart';
import 'NouvelleCommande.dart';
import 'Livreur.dart';
import 'SuiviLivraisonCmd.dart';
//import 'Models/SaveCommande.dart';
import 'Profil.dart';
import '../Models/GradientBouton.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  int ventesDuJour = 0;
  int produitsActifs = 0;
  Map<int, int> ventesParMois = {};
  //Map<int, int> ventesParJour = {};
  int totalProduits = 0;
  int totalCommandes = 0;
  int totalUtilisateurs = 0;


  @override
  void initState() {
    super.initState();
    chargerStats();
  }
  Future<void> chargerStats() async {
    final today = DateTime.now();
    final debutJour = DateTime(today.year, today.month, today.day);

    // Ventes du jour
    final snapshotVentes = await FirebaseFirestore.instance
        .collection('commandes')
        .where('date', isGreaterThanOrEqualTo: debutJour)
        .get();
    ventesDuJour = snapshotVentes.docs.length;

    // Produits actifs
    /*final produits = await FirebaseFirestore.instance
        .collection('produits')
        .get();
    produitsActifs = produits.docs.length;
   */

    // Ventes par mois
   /* final allVentes = await FirebaseFirestore.instance
        .collection('commandes')
        .get();

    final Map<String, int> tempJours = {};
    for (var doc in allVentes.docs) {
      final date = (doc['date'] as Timestamp).toDate();
      final jour = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      tempJours[jour] = (tempJours[jour] ?? 0) + 1;
    }*/



   final allVentes = await FirebaseFirestore.instance
        .collection('commandes')
        .get();

    final Map<int, int> tempMois = {};
    for (var doc in allVentes.docs) {
      final date = (doc['date'] as Timestamp).toDate();
      final mois = date.month;
      tempMois[mois] = (tempMois[mois] ?? 0) + 1;
    }

    final produitsSnapshot = await FirebaseFirestore.instance.collection('produits').get();
    final commandesSnapshot = await FirebaseFirestore.instance.collection('commandes').get();
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      ventesParMois =tempMois;

      totalProduits = produitsSnapshot.docs.length;
      totalCommandes = commandesSnapshot.docs.length;
      totalUtilisateurs = usersSnapshot.docs.length;
    });
  }

  Widget buildStatCard(String titre, int valeur, IconData icone, Color couleur) {
    return SizedBox(
      width: 186,
      height: 120,
        child: Container(
        decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3),)],
    borderRadius: BorderRadius.circular(16),
    ),
      child: Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
      child: Padding(
        padding: EdgeInsets.all(16),
        //width: double.infinity,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withOpacity(0.2),
              child: Icon(icone, color: couleur),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(valeur.toString(), style: TextStyle(fontSize: 20, color: couleur)),
              ],
            )



          ],
        ),
      ),
    )
    )
    );
  }

  // index bar de navigation
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget _buildIcon(int index, IconData iconData) {
    bool isSelected = _selectedIndex == index;
    return Container(
      padding: EdgeInsets.all(10 ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: isSelected ? Colors.white : Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF5FAFA),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green.shade200,
        elevation: 4,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        ),

      body: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
             child: Text('Tableau de bord administrateur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
               color: Colors.green),
            ),
            ),
            SizedBox(height: 36),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                buildStatCard('Produits', totalProduits, Icons.shopping_basket, Colors.green),
                SizedBox(width: 8),
                buildStatCard('Commandes', totalCommandes, Icons.receipt_long, Colors.blue),
                SizedBox(width: 8),
                buildStatCard('Utilisateurs', totalUtilisateurs, Icons.people, Colors.blue),
                SizedBox(width: 8),
               // _StatCard(title: 'Produits actifs', value: '$produitsActifs', icon: Icons.inventory),
                SizedBox(width: 8),
                // _StatCard(title: 'Ventes du jour', value: '$ventesDuJour', icon: Icons.calendar_today),
                SizedBox(width: 8),
                _StatCard(title: 'Graphique', value: '${ventesParMois.length} mois', icon: Icons.show_chart),
                //_StatCard(title: 'Graphique', value: '${ventesParJours.length} mois', icon: Icons.show_chart),





              ],
            ),
    ),

             SizedBox(height: 60),
             Text('Ventes par mois', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: Colors.green)),
            SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: 100,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const mois = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
                          return Text(mois[value.toInt()], style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                   leftTitles: AxisTitles(
                     sideTitles: SideTitles(
                       showTitles: true,
                       interval: 10,
                       getTitlesWidget: (value, meta) {
                         return Text(
                           value.toInt().toString(), style: TextStyle(fontSize: 10, color: Colors.black),
                        );
                       },
                       reservedSize: 32,
                     ),
              ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: List.generate(12, (i) => FlSpot(i.toDouble(), (ventesParMois[i + 1] ?? 0).toDouble())),
                      color: Colors.green.shade400,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 84),

        Row(
          children: [
            Expanded(
              child: GradientBouton(
              text: 'Ajouter produit',
              icon: Icons.add,
              gradientColors: [Colors.blue.shade700, Colors.green.shade700],
              onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AjouterProduit()));
                },
              )
            ),

            SizedBox(width: 6),
            Expanded(
              child: GradientBouton(
              text: 'Commandes',
              icon: Icons.mail,
              gradientColors: [Colors.blue.shade700, Colors.green.shade700],
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NouvelleCommande()));
              },
            ),
            )
          ],
        )



    /* Row(
             // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,

              children: [
                //  1 er btn
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ListeProduits()));
                  },

                child: Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.green], // Deg de la bordure
                    ),
                    borderRadius: BorderRadius.circular(20),

                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white, // couleur fond
                      borderRadius: BorderRadius.circular(20),
                    ),

                  child: Row(
                      children: [
                    Icon(Icons.add, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Ajouter produit', ),
                ]
                  ),
                  )
                )
                ),


                  //2 eme btn
                GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NouvelleCommande()));
                    },

                    child: Container(
                        padding: EdgeInsets.all(2),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.green], // Deg de la bordure
                          ),
                          borderRadius: BorderRadius.circular(20),

                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white, // couleur fond
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                              children: [
                                Icon(Icons.mail, color: Colors.green, size: 16),
                                SizedBox(width: 8),
                                Text('Commandes reçues', ),
                              ]
                          ),
                        )
                    )
                )

                    ]
                  )*/

                 /* child: _ActionButton(
                  icon: Icons.add,
                  label: 'Ajouter un produit',
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AjouterProduit()),
                  );
                },
            ),*/

               /*  SizedBox(width: 16),
                _ActionButton(
                    icon: Icons.mail,
                    label: 'Commandes reçues',
                    onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NouvelleCommande()));
                  },
                  ),*/

                // btn deg

               /* GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NouvelleCommande()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(2), // épaisseur de la bordure
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green], // Deg de la bordure
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white, // couleur fond
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                       // mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mail, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('Commandes reçues', ),
                        ],
                      ),
                    ),
                  ),
                )*/




              ],
            ),

        ),



    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation:6,
      backgroundColor: Colors.green.shade200,
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    onTap: (index) {

      if ( index == 0) {
        Navigator.pushReplacement(context,
          MaterialPageRoute (builder: (context) => AdminDashboard()),
        );
      } else if (index == 1) {
        Navigator.push(context,
          MaterialPageRoute (builder: (context) => ListeProduits()),
        );
      } else if (index == 2) {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => Profil()),
        );
      }
      _selectedIndex = index;
    },
      items: [
        BottomNavigationBarItem(icon: _buildIcon(0, Icons.home ), label: "Dashboard"),
        BottomNavigationBarItem(icon: _buildIcon(1, Icons.shopping_basket), label: "Liste produits"),
        BottomNavigationBarItem(icon: _buildIcon(2, Icons.person), label: "Profil"),
      ],
    ),

     /* bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green.shade100,
        elevation: 8,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistiques'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ), */
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 186,
      height: 120,
      child: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3),)],
              borderRadius: BorderRadius.circular(16),
          ),
          child: Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),

            child: Padding(
              padding:  EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.blueAccent),
                  SizedBox(height: 8),
                  Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
      ),
    )
    )
    )
    );


  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: Icon(icon, color: Colors.green.shade400),
        label: Text(label, style: TextStyle(fontSize: 14)),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ListeProduits.dart';
class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int totalProduits = 0;
  int totalCommandes = 0;
  int totalUtilisateurs = 0;

  @override
  void initState() {
    super.initState();
    chargerStats();
  }

  Future<void> chargerStats() async {
    final produitsSnapshot = await FirebaseFirestore.instance.collection('produits').get();
    final commandesSnapshot = await FirebaseFirestore.instance.collection('commandes').get();
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      totalProduits = produitsSnapshot.docs.length;
      totalCommandes = commandesSnapshot.docs.length;
      totalUtilisateurs = usersSnapshot.docs.length;
    });
  }

  Widget buildStatCard(String titre, int valeur, IconData icone, Color couleur) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withOpacity(0.2),
              child: Icon(icone, color: couleur),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(valeur.toString(), style: TextStyle(fontSize: 20, color: couleur)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 2,
        title: Text('Tableau de bord', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: chargerStats,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStatCard('Produits', totalProduits, Icons.shopping_basket, Colors.green),
            buildStatCard('Commandes', totalCommandes, Icons.receipt_long, Colors.blue),
            buildStatCard('Utilisateurs', totalUtilisateurs, Icons.people, Colors.deepPurple),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.view_list),
              label: Text('Voir la liste des produits'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListeProduits()),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
*/