import 'package:appli_produit/Models/Article_model.dart';
import 'package:appli_produit/Pages/DetailsProduits.dart';
import 'package:flutter/material.dart';
import 'Accueil.dart';
import 'Profil.dart';
import 'PanierPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/commandeProduit_model.dart';
import '../Controllers/commandeProduit_controller.dart';


class Produits extends StatefulWidget {
  @override
  _ProduitsState createState() => _ProduitsState();
}
class _ProduitsState extends State<Produits> {
  final controller = ProduitController();

  List<Produit> produitsAffiches = [];
  bool isLoading = true;
  int selectedCategoryIndex = 0;
  // controller et liste filtrée
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chargerProduits();
  }

  Future<void> chargerProduits() async {
    setState(() => isLoading = true);
    await controller.chargerProduits();
    setState(() {
      produitsAffiches = controller.getProduitsParCategorie(controller.categories[selectedCategoryIndex]);
      isLoading = false;
    });
  }

  void rechercher(String query) {
    setState(() {
      produitsAffiches = query.isEmpty
          ? controller.getProduitsParCategorie(controller.categories[selectedCategoryIndex])
          : controller.rechercherProduits(query);
    });
  }
  // convertir chaine de caracteres
  double parsePrix(String? prixStr) {
    if(prixStr == null) return 0.0;
    final number = RegExp(r'\d+(\.\d+)?').firstMatch(prixStr);
    return number != null ? double.parse(number.group(0)!) : 0.0;
  }

  // index bar de navigation
  int _selectedIndex = 1;
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
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white70),
          backgroundColor: Colors.green.shade200,
          elevation: 2,
          centerTitle: true,
          title: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
          actions: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: () async {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => PanierPage()),
              );
            }),

            IconButton(icon: Icon(Icons.person), onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Profil()),
              );
            }),
          ],
        ),

        body: Column(
         children: [
           Container(
             width: double.infinity,
             padding: EdgeInsets.all(20),
      // color: Colors.blue.shade300,
              child: Text('Commandez en un clic, livraison rapide',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                 textAlign: TextAlign.center,
      ),
    ),

           // zone de recherche
             Padding(
             padding: EdgeInsets.all(16.0),
             child: TextField(
               controller: searchController,
               onChanged: rechercher,
               cursorColor: Colors.green.shade700,
               decoration: InputDecoration(
                 prefixIcon: Icon(Icons.search),
                 hintText: 'Rechercher...',
                 filled: true,
                 fillColor: Colors.green.shade50,

                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(30),
                 ),
               ),
             ),
           ),


           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: List.generate(controller.categories.length, (index) {
               return Padding(
                 padding: EdgeInsets.symmetric(horizontal: 6.0),
                 child: ChoiceChip(
                   label: Text(controller.categories[index]),
                   selected: selectedCategoryIndex == index,
                   side: BorderSide(color: Colors.green, width: 2),
                   onSelected: (_) {
                     setState(() {
                       selectedCategoryIndex = index;
                       searchController.clear();
                       produitsAffiches = controller.getProduitsParCategorie(
                           controller.categories[selectedCategoryIndex]);
                     });
                   },
                   selectedColor: Colors.green.shade200,
                 ),
               );
             }),
           ),


          Expanded(
            child: isLoading
            ? Center(child: CircularProgressIndicator())
            : produitsAffiches.isEmpty
            ? Center(child: Text('Aucun produit trouvé'),)
            : GridView.builder(
                padding: EdgeInsets.all(12),
                itemCount: produitsAffiches.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
    ),
             itemBuilder: (context, index) {
               final produit = produitsAffiches[index];
               return GestureDetector(
                   child: AnimatedContainer(
                     duration: Duration(milliseconds: 150),
                     curve: Curves.easeInOut,
                     decoration: BoxDecoration(
                       color: Colors.green,
                       borderRadius: BorderRadius.circular(16),
                       boxShadow: [
                         BoxShadow(color: Colors.blue.shade200, blurRadius: 8, offset: Offset(0, 4),),
               ],
               ),

                     child: Card(
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                     side: BorderSide(color: Colors.green.shade200, width: 2),
                   ),

                   elevation: 6,
                   shadowColor: Colors.green.withAlpha(25),
                   color: Colors.white,
                   child: Padding(
                       padding: EdgeInsets.all(8.0),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           Expanded(
                               child: Image.asset(produit.image, fit: BoxFit.contain)),
                               SizedBox(height: 8),
                               Text(produit.nom, style: TextStyle(
                                   fontWeight: FontWeight.bold),
                                   textAlign: TextAlign.center),
                           if (produit.prixDetail.isNotEmpty)

                             Text("Prix de détail: ${produit.prixDetail}",
                                 style: TextStyle(color: Colors.blue, fontSize: 12)),
                           if (produit.prixEngros.isNotEmpty)
                             Text("Prix de gros: ${produit.prixEngros}",
                                 style: TextStyle(color: Colors.blue, fontSize: 12)),
                           if (produit.prix.isNotEmpty)
                             Text("Prix: ${produit.prix}", style: TextStyle(color: Colors.blue, fontSize: 12) ),
                           Align(
                             alignment: Alignment.bottomRight,
                               child: IconButton(
                                   icon: Icon(Icons.add_circle, color: Colors.blue,size: 30),
                                    onPressed: ()  {
                                      try {
                                        final article = Article(
                                          nom: produit.nom,
                                          image: produit.image,
                                          description: produit.description,
                                          prixDetail: parsePrix(produit.prixDetail),
                                          prixEngros: parsePrix(produit.prixEngros),
                                          prixED: parsePrix(produit.prix),
                                          prix: parsePrix(produit.prix),
                                          quantite: 1,
                                          categorie: produit.categorie,
                          );


                                           Navigator.push(context, MaterialPageRoute(
                                           builder: (context) => DetailsProduits(produit: article),
               ),
               );
                                       } catch (e) {
                                       print('Erreur navigation ou parsing : $e');
                                       ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text('Erreur : Impossible d’afficher le détail')),
               );
               }
               },

            )
               )
               ]

               )

               )
               )
                   )
               );

             }

            )


          )
        ]
    ),

      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: Colors.green.shade200,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if ( index == 0) {
          Navigator.pushReplacement(context,
            MaterialPageRoute (builder: (context) => Accueil()),);

        } else if (index == 1) {
          Navigator.push(context,
            MaterialPageRoute (builder: (context) => Produits()),);

        } else if (index == 2) {
          Navigator.push(context,
            MaterialPageRoute (builder: (context) => PanierPage()),);
        } else if (index == 3) {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => Profil()),);
        }
        //_selectedIndex = index;
      },
      items: [
        BottomNavigationBarItem(icon: _buildIcon(0, Icons.home ), label: 'Accueil'),
        BottomNavigationBarItem(icon: _buildIcon(1, Icons.shopping_bag ), label: 'Produits'),
        BottomNavigationBarItem(icon: _buildIcon(2, Icons.shopping_cart), label: "Panier"),
        BottomNavigationBarItem(icon: _buildIcon(3, Icons.person), label: "Profil"),
      ],
    ),


    );
  }
}






/*
import 'package:appli_produit/Models/Article_model.dart';
import 'package:appli_produit/Pages/DetailsProduits.dart';
import 'package:flutter/material.dart';
import 'Accueil.dart';
import 'Profil.dart';
import 'PanierPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Produits extends StatefulWidget {
  @override
  _ProduitsState createState() => _ProduitsState();
}
class _ProduitsState extends State<Produits> {
  //final int currentIndex = 0;
  bool isLoading = true;
  // controller et liste filtrée
  TextEditingController searchController = TextEditingController();
  int selectedCategoryIndex = 0;
  List<Map<String, String>> currentProducts = [];
  List<Map<String, String>> filteredProducts = [];

   // declaration categorie
  final List<String> categories = ['Légumes', 'Poissons', 'Fruits'];

    // modifier map
  Map<String, List<Map<String, String>>> product = {
    'Légumes': [],
    'Poissons': [],
    'Fruits': [],
  };

  // mjr avc firebase
  Future <List<Map<String, String>>> fetchProductsFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('produits').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'nom': data['nom']?.toString() ?? '',
        'prixDetail': data['prixDetail']?.toString() ?? '',
        'prixEngros': data['prixEngros']?.toString() ?? '',
        'prix': data['prix']?.toString() ?? '',
        'image': data['image']?.toString() ?? '',
        'description': data['description']?.toString() ?? '',
        'categorie': data['categorie']?.toString() ?? '',
      };
      }).toList();
  }
// chrger les prod depuis firestore
  void initState() {
    super.initState();
    loadProductsFromFirestore();
    // filtre
    //filteredProducts = getAllProducts();
  }
  List<Map<String, String>> getAllProducts() {
    return product.values.expand((list) => list).toList();
  }
  Future<void> loadProductsFromFirestore() async {
    setState(() {
      isLoading = true;
    });
    final allProducts = await fetchProductsFromFirestore();
    setState(() {
      product.clear();
      for (var categorie in categories) {
        product[categorie] =
            allProducts.where((p) => p['categorie'] == categorie).toList();
      }
      filteredProducts = getAllProducts();
      currentProducts = product[categories[selectedCategoryIndex]] ?? [];
      isLoading = false;
    });
  }

// filtre selon le text entré

void filterSearch(String query) {
  final all = getAllProducts();
  if(query.isEmpty) {
    setState(() => filteredProducts = all );
  }
  else{
    setState(() {
      filteredProducts = all.where((item) =>
          item['nom']!.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
}

List<Map<String, String>> get visibleProducts {
  if (searchController.text.isNotEmpty) {
    return filteredProducts;
  }
  return currentProducts;
}

  // convertir chaine de caracteres
double parsePrix(String? prixStr) {
    if(prixStr == null) return 0.0;
    final number = RegExp(r'\d+(\.\d+)?').firstMatch(prixStr);
    return number != null ? double.parse(number.group(0)!) : 0.0;
}




  @override
  Widget build(BuildContext context) {
     currentProducts = product[categories[selectedCategoryIndex]] ?? [];

    return Scaffold(
      backgroundColor: Color(0xFFF1FDF4),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green.shade200,
        elevation: 2,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PanierPage()),
            );
          }),

          IconButton(icon: Icon(Icons.person), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profil()),
            );
          }),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Arrier.jpg'),
            fit: BoxFit.cover,
            opacity: 0.05,
      ),
      ),
        child: Column(
          children: [
            Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
           // color: Colors.blue.shade300,
            child: Text('Commandez en un clic, livraison rapide',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
              textAlign: TextAlign.center,
            ),
          ),
                   // zone de recherche
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(categories.length, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: selectedCategoryIndex == index,
                    side: BorderSide(color: Colors.green, width: 2),
                    onSelected: (_) {
                      setState(() {
                        selectedCategoryIndex = index;
                        currentProducts = product[categories[index]] ?? [];
                        searchController.clear();
                        });
                    },
                    selectedColor: Colors.green.shade200,
                  ),
                );
              }),
            ),

          // chargement depuis firebase
        if(isLoading)
          Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
          else

          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              itemCount: visibleProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),

              itemBuilder: (context, index) {
                final product = visibleProducts[index];
                return GestureDetector(

                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                ),
                ],
                ),


                  child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.green.shade200, width: 2),
                  ),
                  elevation: 6,
                  shadowColor: Colors.green.withAlpha(25),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (product.containsKey('image'))
                          Expanded(
                            child: Image.asset(product['image']!, width: 300, height: 300, fit: BoxFit.contain),
                          ),
                        SizedBox(height: 13),
                        Text( product['nom']!, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                        SizedBox(height: 10),
                        if (product.containsKey('prixDetail') && product['prixDetail']!.isNotEmpty)
                         // Text( product['prixDetail']!, style: TextStyle(color: Colors.blue, fontSize: 12),),
                          Text("Prix en détail : ${product['prixDetail']!}",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                        if (product.containsKey('prixEngros') && product['prixEngros']!.isNotEmpty)
                          Text('Prix en engros: ${product['prixEngros']!}', style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),

                        if (product.containsKey('prix') && product['prix']!.isNotEmpty)
                          Text('Prix: ${product['prix']!}', style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                icon: Icon(Icons.add_circle, color: Colors.blue,size: 30),
                                onPressed: () async {
                                  print("Produit sélectionné: ${product['nom']}");
                                  final article = Article(
                                    nom: product['nom']?.toString() ?? '',
                                    image: product['image'] ?? '',
                                    description: product['description']?.toString() ?? '',
                                    prixDetail: parsePrix(product['prixDetail']),
                                    prixEngros: parsePrix(product['prixEngros']),
                                    prixED: parsePrix(product['prixED']),
                                    prix: parsePrix(product['prix']),
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DetailsProduits(produit: article)),
                                  );
                                },
                            )
                        )

                      ],
                    ),
                  )
                ),
                    ),
                );
              },
            ),
          ),
        ],
      ),

      ),

    );
  }
}


*/