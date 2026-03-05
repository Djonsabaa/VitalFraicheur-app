import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'PanierPage.dart';
import '../Models/Article_model.dart';
import '../Models/Panier_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsProduits extends StatefulWidget {

  final Article produit;
  DetailsProduits ({required this.produit});
  @override
  State<DetailsProduits> createState() => _DetailsProduitsState();
}
class _DetailsProduitsState extends State<DetailsProduits> {
  int quantity = 1;
  bool isRetail= true;
  final int seuilEngros = 10;  // prix engros à partir de 10 kg

  List<Article> panier = [];

  void ajouterAuPanier (Article article) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final prixChoisi = widget.produit.getPrixEDActuel(isRetail);
    // ID unique basé sur le nom + prix
    final articleId = '${widget.produit.nom}_${prixChoisi.toString()}';
    final docRef = FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .doc(articleId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.produit.nom} déjà ajouté dans votre panier. '
            'Veuillez cliquer sur + pour augmenter la quantité'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green ),
      );
    } else {
      // ajout dans firestore
      final articleData = {
        'nom': widget.produit.nom,
        'image': widget.produit.image,
        'description': widget.produit.description,
        'prixDetail': widget.produit.prixDetail,
        'prixEngros': widget.produit.prixEngros,
        'prixED': prixChoisi,
        'prix': widget.produit.prix,
        'quantite': quantity,
      };
      await docRef.set(articleData);

      //await fetchPanier();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.produit.nom} ajouté au panier'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        //leading: BackButton(color: Colors.black),
        elevation: 4,
        centerTitle: true,
        //title: Text(widget.produit.nom ?? 'Produit', style: TextStyle(color: Colors.white),),
        title: Text(widget.produit.nom, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade400,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child:Column(
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:Colors.black26,
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: Offset(0, 10),
                        )
                      ]
                    ),
                  ),
                  Image.asset(produit.image, height: 200, fit: BoxFit.cover,),
                ],
              ),
              //Center(child: Image.asset(produit.image, height: 200, fit: BoxFit.cover,),),
              SizedBox(height: 16),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.lightBlueAccent, width: 1,)
                ),
               // color: Colors.blue.shade200,
                  color: Colors.blue.shade500.withAlpha(22),
                  //shadowColor: Colors.white.withOpacity(0.2),
                  shadowColor: Colors.blue.withAlpha(22),

                child: Padding(
                  padding: EdgeInsets.all(16),

            /*Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200.withAlpha(25),
                      //color: Colors.blue.shade100.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    //border: Border.all(color: Colors.blue.shade500),
                    border: Border.all(color: Colors.lightBlueAccent,
                    //width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        //color: Colors.blue.withAlpha(25),
                        //blurRadius: 16,
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ), */


                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(widget.produit.nom, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                            color: Colors.blue),),
    ),
                      SizedBox(height: 14),
                    //  Align(
                        //alignment: Alignment.topLeft,
                        Text(produit.description, style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
         //   ),
                      SizedBox(height: 18),
                      if(produit.prixDetail > 0 || produit.prixEngros > 0) ...[
                        Text("Choisissez un type de prix :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                        if(produit.prixDetail > 0)
                          RadioListTile<bool>(
                            title: Text("Prix de détail: ${produit.prixDetail} Dhs /kg", style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),),
                            value: true,
                            groupValue: isRetail,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                            setState(() => isRetail = true);
                  }
         ),

                        if(produit.prixEngros > 0)
                          RadioListTile<bool>(
                            title: Text("Prix en gros: ${produit.prixEngros} Dhs /kg".toString(), style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),),
                            value: false,
                            groupValue: isRetail,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {

                        if ( quantity < seuilEngros) {
                          quantity = seuilEngros;
                          isRetail = false;
                         ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Prix en engros à partir de 10 kg',
                           style: TextStyle(fontSize: 18, color: Colors.green)),
                          backgroundColor: Colors.white,
    ),
    );
                        } else {
                          isRetail = false;
                        }
    });},
                        //secondary: Icon(Icons.shopping_bag, color: Colors.green),
    ),

                         SizedBox(height:10),
                         if(quantity < seuilEngros && !isRetail)
                           Container(
                            //padding: EdgeInsets.all(10),
                             decoration: BoxDecoration(
                             color: Colors.orange.shade50,
                             border: Border.all(color: Colors.orange),
                             borderRadius: BorderRadius.circular(12),
                ),
                             child: Row(
                               children: [
                                 Icon(Icons.info, color: Colors.green),
                                 //SizedBox(width: 10),
                                 Expanded(
                                   child: Text('le prix en gros disponible à partir de $seuilEngros kg',
                                     style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),)
                               ],
                      ),
                   ),
            ],


                          if (produit.prix > 0) ...[
                          //(produit.prixDetail <= 0 && produit.prixEngros <= 0 && produit.prix > 0)  ...[
                            ListTile(
                              title: Text('${produit.prix} Dhs /unité', style: TextStyle(fontSize: 15, color: Colors.blue),),
                             //leading: Icon(Icons.price_change, color: Colors.blue),
                              tileColor: Colors.blue.shade100,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                         ],
                          SizedBox(height: 12),
                            Row(
                              children: [
                                Text('Quantité'),
                                SizedBox(height: 8),
                                IconButton(icon: Icon(Icons.remove, color: Colors.redAccent),
                                onPressed: () {
                                  if( quantity > 1 ) {
                                    setState(() {
                                      quantity--;
                                      if (isRetail == false && quantity < seuilEngros ) {
                                        isRetail = true; // retour en detail
                                  }
                              });
                         }
                       }
          ),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.shade100,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  child: Text('$quantity'),
                                ),
                                IconButton(icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() => quantity++); },
                                ),
                              ],
                            ),

                    ]
                  ),
              )
              ),

              SizedBox(height: 22),
              Container(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    ajouterAuPanier(widget.produit) ;
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => PanierPage()),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text('Ajouter au panier', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size(double.infinity, 44),
                  ),
                ),
              )
                ]
              ),
              )
    )

    );
  }
}



/*
    Image.asset(produit.image, height: 150),
               SizedBox(height: 18),
               Text(produit.nom, style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
               Text(produit.description, style: TextStyle(fontSize: 16)),
               SizedBox(height: 20),
               if (produit.prixDetail > 0)

                 Text('Prix Détail: ${produit.prixDetail} Dhs', style: TextStyle(color: Colors.blue)),
               if (produit.prixEngros > 0)
                 Text('Prix Engros: ${produit.prixEngros} Dhs', style: TextStyle(color: Colors.blue)),
               if (produit.prix > 0)
                 Text('Prix: ${produit.prix} Dhs', style: TextStyle(color: Colors.blue)),
               ElevatedButton(
                 onPressed: () {
           //  convertir Produit => Article et appeler ajouterAuPanier
    },
                 child: Text('Ajouter au panier'),
    ),
    ],
    ),
    )
      )
    );
  }
}*/




/*
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'PanierPage.dart';
import '../Models/Article_model.dart';
import '../Models/Panier_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsProduits extends StatefulWidget {

  final Article produit;
  DetailsProduits ({required this.produit});
  @override
  State<DetailsProduits> createState() => _DetailsProduitsState();
}
class _DetailsProduitsState extends State<DetailsProduits> {
  int quantity = 1;
  bool isRetail= true;
  final int seuilEngros = 10;  // prix engros à partir de 10 kg

  List<Article> panier = [];

  void ajouterAuPanier (Article article) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final prixChoisi = widget.produit.getPrixEDActuel(isRetail);
    // ID unique basé sur le nom + prix
    final articleId = '${widget.produit.nom}_${prixChoisi.toString()}';
    final docRef = FirebaseFirestore.instance
        .collection('paniers')
        .doc(userId)
        .collection('articles')
        .doc(articleId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez déjà ajouté ${widget.produit.nom} dans votre panier. '
            'Veuillez cliquer sur le plus pour augmenter la quantité'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green ),
      );
    } else {
      // ajout dans firestore
      final articleData = {
        'nom': widget.produit.nom,
        'image': widget.produit.image,
        'description': widget.produit.description,
        'prixDetail': widget.produit.prixDetail,
        'prixEngros': widget.produit.prixEngros,
        'prixED': prixChoisi,
        'prix': widget.produit.prix,
        'quantite': quantity,
      };
      await docRef.set(articleData);

      //await fetchPanier();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.produit.nom} ajouté au panier'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green ),
      );
    }
  }
 /* void ajouterAuPanier (Article article) async {
    final prixChoisi = widget.produit.getPrixEDActuel(isRetail);

    final existingIndex = Panier.indexWhere((item) =>
    item.nom == widget.produit.nom && item.prixED == prixChoisi);
    if (existingIndex != -1) {  // produit existe => aug la quantite
      //Panier[existingIndex].quantite += quantity;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez déjà ajouté ${widget.produit.nom} dans votre panier. '
            'Veuillez cliquer sur le plus pour augmenter la quantité'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green ),
      );
    }

    else{
      Panier.add(Article(
        nom: widget.produit.nom,
        image: widget.produit.image,
        description: widget.produit.description,
        prixDetail: widget.produit.prixDetail,
        prixEngros: widget.produit.prixEngros,
        prixED: prixChoisi,
        prix: widget.produit.prix,
        quantite: quantity,
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.produit.nom} ajouté au panier'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green ),
    );
  } */
  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        //leading: BackButton(color: Colors.black),
        elevation: 2,
        centerTitle: true,
        title: Text(widget.produit.nom ?? 'Produit', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Center(
                child: Image.asset(produit.image, height: 200, fit: BoxFit.cover,),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.blue.shade200.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade500),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(25),
                        blurRadius: 16,
              ),
            ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(widget.produit.nom, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(height: 18),
                      Text(produit.description, style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,),
                      SizedBox(height: 20),

                      if(produit.prixDetail > 0 || produit.prixEngros > 0) ...[
                        Text("Choisissez un type de prix :", style: TextStyle(fontWeight: FontWeight.bold)),
                        if(produit.prixDetail > 0)
                          RadioListTile<bool>(
                              title: Text('${produit.prixDetail} Dhs / kg', style: TextStyle(fontSize: 18, color: Colors.blue),),
                              value: true,
                              groupValue: isRetail,
                              activeColor: Colors.blue,
                              onChanged: (value) {
                                setState(() => isRetail = true);
                              }
                          ),
                        if(produit.prixEngros > 0)
                          RadioListTile<bool>(
                            title: Text('${produit.prixEngros} Dhs / kg'.toString(), style: TextStyle(fontSize: 18, color: Colors.blue),),
                            value: false,
                            groupValue: isRetail,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {

                        if ( quantity < seuilEngros) {
                                  quantity = seuilEngros;
                                  isRetail = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('La quantité doit etre supérieure ou égale à 10', style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                                    backgroundColor: Colors.white,
                                    ),
                                  );
                                }   else {
                                  isRetail = false; }
                              });},
                            secondary: Icon(Icons.shopping_bag, color: Colors.green),
                          ),
                          SizedBox(height:10),
                        if(quantity < seuilEngros && !isRetail)
                            Container(
                              //padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.green),
                                  //SizedBox(width: 10),
                                  Expanded(
                                    child: Text('le prix engros disponible à partir de $seuilEngros kg', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),),)
                                ],
                              ),
                            ),
                      ],
                        if (produit.prix > 0) ...[
                        //(produit.prixDetail <= 0 && produit.prixEngros <= 0 && produit.prix > 0)  ...[
                          ListTile(
                            title: Text('${produit.prix} Dhs / unité', style: TextStyle(fontSize: 18, color: Colors.blue),),
                            //leading: Icon(Icons.price_change, color: Colors.blue),
                            tileColor: Colors.blue.shade100,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ],
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Text('Quantité'),
                            SizedBox(height: 10),
                            IconButton(icon: Icon(Icons.remove, color: Colors.redAccent),
                                onPressed: () {
                                  if( quantity > 1 ) {
                                    setState(() {
                                      quantity--;
                                      if (isRetail == false &&
                                          quantity < seuilEngros ) {
                                        isRetail = true; // retour en detail
                                      }
                                    });
                                  }
                                }
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey.shade100,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Text('$quantity'),
                            ),
                            IconButton(icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => quantity++); },
                            ),
                          ],
                        ),

                    ]
                ),
              ),


              SizedBox(height: 22),
              Container(

                child: ElevatedButton.icon(
                  onPressed: () async {
                     ajouterAuPanier(widget.produit) ;
                  /*  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => PanierPage()),
                    ); */
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text('Ajouter au panier', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size(double.infinity, 44),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
 */

