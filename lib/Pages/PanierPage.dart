import 'package:flutter/material.dart';
import '../Models/Panier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Paiement.dart';
import '../Models/commandeProduit_model.dart';
import 'Produits.dart';
import '../main.dart';
import '../Controllers/Panier_controller.dart';
import '../Models/Article_model.dart';


class PanierPage extends StatefulWidget {

  @override
  _PanierPageState createState() => _PanierPageState();
}
class _PanierPageState extends State<PanierPage>  {
  final PanierController _controller = PanierController();
  List<Article> _articles = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    chargerPanier();
    }

  Future<void> chargerPanier() async {
    setState(() => isLoading = true);
    _articles = await _controller.getArticles();
    setState(() => isLoading = false);
  }

  Future<void> modifierQuantite(int index, int delta) async {
    final article = _articles[index];
    if (article.quantite + delta >= 1) {
      setState(() => article.quantite += delta);
      await _controller.updateQuantite(article);
    }
  }

  Future<void> supprimerArticle(int index) async {
    final id = _articles[index].id;
    if (id != null) {
      await _controller.supprimerArticle(id);
      setState(() => _articles.removeAt(index));
    }
  }

  Future<void> viderPanier() async {
    await _controller.viderPanier();
    setState(() => _articles.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Panier vidé"), backgroundColor: Colors.green),
    );
  }

  // conversion
  List<Produit> convertirArticlesEnProduits(List<Article> articles) {
    return articles.map((article) {
      return Produit(
        nom: article.nom,
        quantite: article.quantite.toString(),
        prixUnitaire: article.prixED.toStringAsFixed(2),
        total: (article.prixED * article.quantite).toStringAsFixed(2),
        imageUrl: article.image,
        livraisonEtat: null,

        categorie: article.categorie,
        description: article.description,
        image: article.image,
        prixEngros: article.prixEngros.toString(),
        prix: article.prix.toString(),
        prixDetail: article.prixDetail.toString(),

      );
    }).toList();
  }


  //print("Nombre de produits chargés : ${produits.length}");

  @override
  Widget build(BuildContext context) {
    final total = _controller.calculerTotal(_articles);
    return Scaffold(
        //backgroundColor: Color(0xFFF1FDF5),
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white70),
           automaticallyImplyLeading: true,
        backgroundColor: Colors.green.shade300,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_shopping_cart),
            SizedBox(width: 8,),
            Text('Panier', style: TextStyle(color: Colors.white)),
    ]
    ),

    ),

    body: isLoading
      ? Center(child: CircularProgressIndicator())
       : _articles.isEmpty
      ? Center(child: Text('Votre panier est vide'))
      : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];

                return SizedBox(
                    height: 150,
                    child: Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                padding: EdgeInsets.only(top: 24),

                  child: ListTile(
                leading: Container(
                decoration :BoxDecoration(
                color: Colors.green.shade400,
                ),
                child: Image.asset(article.image, width: 62, height: 66, fit: BoxFit.contain),
                ),
                title: Text(article.nom),
                subtitle: Text('${article.prixED} Dhs'),
                trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                IconButton(icon: Icon(Icons.remove),
                onPressed: () => modifierQuantite(index, -1),
                ),
                Text('${article.quantite}'),
                IconButton(
                icon: Icon(Icons.add),
                onPressed: () => modifierQuantite(index, 1),
                ),
                IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => supprimerArticle(index),
                ),
        ],
      ),
                )
                )
                    )
    );
    },
    ),
    ),





    Divider(height: 10),
       Padding(
         padding: EdgeInsets.all(12),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
             Text('$total Dhs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),

      Padding(
        padding: EdgeInsets.only(right: 8, left: 8, bottom: 10, top: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text('Continuer les achats', style: TextStyle(color: Colors.white,  fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
    ),
    ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Produits())),
            ),
          ),

          SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: viderPanier,
              icon: Icon(Icons.clear, color: Colors.redAccent),
              label: Text('Vider le panier', style: TextStyle(color: Colors.blue, fontSize: 14),),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white70,
                elevation: 4,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue),
                foregroundColor: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
      ),

      Container(
        margin: EdgeInsets.only(bottom: 30, top: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            side: BorderSide(color: Colors.white),
            elevation: 4,
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),),
    ),

          onPressed: _articles.isEmpty
              ? null
              : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Paiement(produits: convertirArticlesEnProduits(_articles), total: total,),
            ),
          ),
          child: Text('Passer la commande', style: TextStyle( color: Colors.white)),
        ),
      )
    ],
    ),
    );
  }
}













/*

import 'package:flutter/material.dart';
import '../Models/Article_model.dart';
import '../Models/Panier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Paiement.dart';
import '../Models/commandeProduit_model.dart';
import 'Produits.dart';
import '../main.dart';
import '../Controllers/Panier_controller.dart';



class PanierPage extends StatefulWidget {

  @override
  _PanierPageState createState() => _PanierPageState();
}
class _PanierPageState extends State<PanierPage>  {

  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  List<Article> produits = [];

  double get total =>
      produits.fold(0.0, (sum, p) => sum + (p.prixED * p.quantite));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
       fetchPanier();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //fetchPanier();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didPopNext() {
    // Quand on revient sur cette page, recharger les données
    Future.delayed(Duration(milliseconds: 300), () {
      fetchPanier();
    });

  }


  Future<void> fetchPanier() async {
    setState(() => isLoading= true);
    final snapshot = await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .get();
    setState(() {
      produits = snapshot.docs
          .map((doc) => Article.fromMap(doc.data(), doc.id))
          .toList();

      for (var p in produits) {
        print('Produit: ${p.nom}, prixED: ${p.prixED}, quantite: ${p.quantite}');
      }
      setState(() {
        isLoading = false;
      });


    });
    print("Nombre de produits chargés : ${produits.length}");
  }
// recharger le panier à chaque fois que panierPage est affiché

  Future<void> increment(int index) async {
    setState(() => produits[index].quantite++);
    await updateQuantite(produits[index]);
  }

  Future<void> decrement(int index) async {
    if (produits[index].quantite > 1) {
      setState(() => produits[index].quantite--);
      await updateQuantite(produits[index]);
    }
  }

  Future<void> remove (int index) async {
    final article = produits[index];
    final id = article.id;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if(userId == null || id == null ) return;
    try{
      await FirebaseFirestore.instance
          .collection('paniers')
          .doc(userId)
          .collection('articles')
          .doc(id)
          .delete();
      setState(() => produits.removeAt(index));
    } catch (e) {
      print('erreur lors de la suppression de l\'article: $e' );
    }
    return;
  }
  Future<void> updateQuantite(Article article) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || article.id == null) return;
    await FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .doc(article.id)
        .update({'quantite': article.quantite,
      'prixED': article.prixED,
    });
    return;
  }

  // conversion
  List<Produit> convertirArticlesEnProduits(List<Article> articles) {
    return articles.map((article) {
      return Produit(
        nom: article.nom,
        quantite: article.quantite.toString(),
        prixUnitaire: article.prixED.toStringAsFixed(2),
        total: (article.prixED * article.quantite).toStringAsFixed(2),
        imageUrl: article.image,
        livraisonEtat: null,

        categorie: article.categorie,

      );
    }).toList();
  }

  void continuerAchat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Produits()),
    );
  }
  void viderPanier() async {
    if (userId == null ) return;
    final panierRef = FirebaseFirestore.instance.collection('paniers').doc(userId).collection('articles');
    final snapshot = await panierRef.get();

    // supp les article du panier
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {
      produits.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Panier vidé'),
        backgroundColor: Colors.green,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF1FDF5),
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white70),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.green.shade300,
        elevation: 2,
        centerTitle: true,
        title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_shopping_cart),
                SizedBox(width: 8,),
                Text('Panier', style: TextStyle(color: Colors.white)),
              ]
          ),

      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('paniers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('articles')
            .snapshots(),
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Votre panier est vide'));
          }
          final  produits = snapshot.data!.docs.map((doc){
            final data = doc.data() as Map<String, dynamic>;
            return Article.fromMap(data,doc.id);
          }).toList();
          return Column(
              children: [
                SizedBox(height: 20.0),
                Expanded(
                    child: ListView.builder(
                      itemCount: produits.length,
                      itemBuilder: (context, index) {
                        final produit = produits[index];
                        return SizedBox(
                            height: 150,
                            child: Card(
                              color: Colors.white,
                                  margin: EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: ListTile(
                                  leading: Container(
                                    decoration :BoxDecoration(
                                      color: Colors.green.shade400,
                                    ),
                                    child: Image.asset(produit.image, width: 62, height: 66, fit: BoxFit.contain),
                                  ),
                                  title: Text(produit.nom),
                                  subtitle: Text('${produit.prixED} Dhs'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: Icon(Icons.remove),
                                        onPressed: () async {
                                        await decrement (index);
                                      },
                                 ),
                                      Text('${produit.quantite}'),
                                      IconButton(icon: Icon(Icons.add), onPressed: () async {
                                        await increment (index);
                                      })  ,
                                      IconButton(icon: Icon(Icons.delete_forever),
                                        onPressed: () async {
                                          await remove (index);
                                   })
                                ]

                                )
                              )
                            )
                        )
                        );
                      }
                    )
                ),

                   // bouton  continuer achat et vidage panier
                if (produits.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 8, left: 8, bottom: 10, top: 16),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: ElevatedButton.icon(
                                  icon: Icon(Icons.arrow_back, color: Colors.white),
                                  label: Text('Continuer les achats', style: TextStyle(color: Colors.white,  fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    elevation: 4,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    side: BorderSide(color: Colors.white),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                  ),
                                  onPressed: continuerAchat,
                              )
                          ),

                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: viderPanier,
                              icon: Icon(Icons.clear, color: Colors.redAccent),
                              label: Text('Vider le panier', style: TextStyle(color: Colors.blue, fontSize: 14),),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                elevation: 4,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.blue),
                                foregroundColor: Colors.green.shade600,
                              ),
                            ),
                          ),

                        ]
                    )
                  ),

                Divider(height: 10),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('$total Dhs'),
                      //Text('${total.toStringAsFixed(2)} Dhs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 30, top: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      side: BorderSide(color: Colors.white),
                      elevation: 4,
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),),
                    ),
                    onPressed: produits.isEmpty ? null : () {
                      final produitsConvertis = convertirArticlesEnProduits(produits);
                      Navigator.push(context,
                        MaterialPageRoute(builder:
                            (context) => Paiement(total: total, produits: produitsConvertis,) ),
                      );
                    },
                    child: Text('Passer commande', style: TextStyle( color: Colors.white)),
                  ),
                )


              ]
          );

        },
      )
    );
  }
}
 */







