import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Accueil.dart';
import 'Produits.dart';
import '../Models/HistoCommande.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'PanierPage.dart';
import '../Controllers/auth_controller.dart';

class Profil extends StatefulWidget {
  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final AuthController _authController = AuthController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchUserData();
  }

  File? _image;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  TextEditingController? nomController;

  bool isEditing = false;





  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>;
        _emailController.text = userData?['email'] ?? '';
        _nameController.text = userData?['name'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'email': _emailController.text,
      'name': _nameController.text,
    });

    setState(() {
      userData?['email'] = _emailController.text;
      userData?['name'] = _nameController.text;
    });
  }

  void _toggleEdit() async {
    if (isEditing) {
      await _updateUserData();
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    // Naviguer vers la page de login si nécessaire
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        setState(() {
          _image = file;
        });
        final uid = _auth.currentUser!.uid;
        final ref = _storage.ref().child('profile_photos/$uid.jpg');
        print('Début de l\'upload vers Firebase Storage...');

        // Upload de l'image
        await ref.putFile(file);
        print('Upload réussi ');

        // Récupération de l'URL publique
        final url = await ref.getDownloadURL();
        print('URL obtenue : $url');

        // Mise à jour Firestore
        await _firestore.collection('users').doc(uid).update({'photoUrl': url});
        print('Firestore mis à jour');
        fetchUserData();
      }
    } catch(e) {
      print('erreur:$e');



      //setState(() {
      // userData?['photoUrl'] = url;
      //});

    }
  }
  Future<void> fetchUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }



  // index bar de navigation
  /*int _selectedIndex = 3;
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
*/

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profil")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        automaticallyImplyLeading: true,
        title: Text('Mon Profil', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
      ),
      body: isLoading
       ? Center(child: CircularProgressIndicator())
       : SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.only(top:20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 66,
                          backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (userData?['photoUrl'] != null
                          ? NetworkImage(userData!['photoUrl']!)
                          : AssetImage('assets/images/avatar.png')) as ImageProvider,
            ),
               Positioned(
                bottom: 0,
                right: 0,
                 child: InkWell(
                   onTap: _pickImage,
                   child: Container(
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.blue,
    ),
                   padding: EdgeInsets.all(8),
                   child: Icon(Icons.edit, color: Colors.white, size: 20),
           ),
          ),
        ),
      ],
    ),

            SizedBox(height: 20),
            Text(userData?['name'] ?? 'Nom inconnu', style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),

             Container(
               margin: EdgeInsets.all(20),
               child: Column(
                 children: [
                   Card(
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
         ),
                     elevation: 6,
                      color: Colors.blue.shade600,
                      child: Padding(
                       padding: EdgeInsets.all(10),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Informations personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                              color: Colors.white,),),
                             SizedBox(height: 10),
                                // Nom
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: isEditing
                                        ? TextFormField(
                                        controller: _nameController, style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Nom',
                                          hintStyle: TextStyle(color: Colors.white60),
                                          border: InputBorder.none,
                             ),
                   )
                                        : Text('Nom: ${userData?['name'] ?? ''}', style: TextStyle(color: Colors.white),
                           ),
                      ),
                   ],
            ),
                             SizedBox(height: 12),
                                  // Email
                             Row(
                               children: [
                                 Icon(Icons.email, color: Colors.white),
                                 SizedBox(width: 10),
                                 Expanded(
                                   child: isEditing
                                   ? TextFormField(
                                   controller: _emailController,
                                   style: TextStyle(color: Colors.white),
                                   decoration: InputDecoration(
                                     hintText: 'Email',
                                     hintStyle: TextStyle(color: Colors.white60),
                                     border: InputBorder.none,
                            ),
                  )
                                   : Text('Email: ${userData?['email'] ?? ''}',
                                      style: TextStyle(color: Colors.white),
                       ),
                    ),
                 ],
              ),
            // add
                                   SizedBox(height: 12),
                                     Row(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Icon(Icons.location_on, color: Colors.white),
                                   SizedBox(width: 10),
                                   Expanded(
                                     child: Text('Adresse de livraison : ${userData?['adresse']} ', style: TextStyle(color: Colors.white)),
                    ),
                 ],
                 ),
                                   SizedBox(height: 12),
                                   Row(
                                     children: [
                                       Icon(Icons.phone, color: Colors.white),
                                       SizedBox(width: 10),
                                       Expanded(
                                         child: Text('Numéro: ${userData?['telephone']}', style: TextStyle(color: Colors.white)),
                        ),
                     ],
               ),


       ],
      ),
    )
    ),
                                      SizedBox(height: 24),

                                          // histo commande
                                       SizedBox(height: 20),
                                       ListTile(
                                         leading: Icon(Icons.history),
                                          title: Text("Historique de commandes"),
                                          trailing: Icon(Icons.arrow_forward_ios),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => HistoCommande() ),
                                  );
                           },
                     ),

                   ],
             )
      ),

                                                   // Boutons
                                          Row(
                                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                               Padding(
                                                 padding: EdgeInsets.only(left: 85),
                                                 child: ElevatedButton.icon(
                                                        onPressed: _toggleEdit,
                                                        icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
                                                        label: Text(isEditing ? 'Enregistrer' : 'Éditer', style: TextStyle(color: Colors.white)),

                                                        style: ElevatedButton.styleFrom(
                                                          elevation: 4,
                                                          backgroundColor: Colors.green.shade600,
                                                          side: BorderSide(color: Colors.white),
                                                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                   ),
                              ),
                 ),
                                                      ),
                                                  SizedBox(width: 8),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 20),
                                                    child: OutlinedButton.icon(
                                                    onPressed: () => _authController.logout(context),
                                                    icon: Icon(Icons.logout),
                                                    label: Text('Déconnecter', style: TextStyle(color: Colors.green)),

                                                    style: OutlinedButton.styleFrom(
                                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                                      elevation: 4,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                     ),
                                                      side: BorderSide(color: Colors.green.shade600),
                                                      foregroundColor: Colors.green.shade600,
                                                    ),
                                    ),
                                                  )

                                ]



                                          )

    ]
                                          )
          )
           )
         ),

            /*   bottomNavigationBar: BottomNavigationBar(
                 type: BottomNavigationBarType.fixed,
                 elevation: 6,
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
                       Navigator.push(context, MaterialPageRoute (builder: (context) => Produits()),);

                  } else if (index == 2) {
                      Navigator.push(context, MaterialPageRoute (builder: (context) => PanierPage()),);
                  } else if (index == 3) {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Profil()),);
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
      */

      );


  }
}


/*

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Accueil.dart';
//import 'Produits.dart';
import 'Models/HistoCommande.dart';

import 'PanierPage.dart';
class Profil extends StatefulWidget {
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {







/*
  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          nomController = TextEditingController(text: userData?['nom']);
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateNom() async {
    final user = _auth.currentUser;
    if (user != null && nomController != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'nom': nomController!.text,
      });
      fetchUserProfile();   // pour rafraichir le profil
    }
  }
  Future<void> updatePhoto() async {
    final picker = ImagePicker();
    final user = _auth.currentUser;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && user != null) {
      final ref = _storage.ref().child('profile_photos').child('${user.uid}.jpg');

      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': url,
      });

      fetchUserProfile();
    }
  } */



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar( ),
      body:

                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(child: Text('Email: ${userData?['email'] ?? '' }', style: TextStyle(color: Colors.white),)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Adresse de livraison : ${userData?['adresse']} ', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                           SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Numéro: ${userData?['telephone']}', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),

                        ],
                      ),
                    )
                  ),


                  SizedBox(height: 30),

                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 45),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Action édition
                          },
                          icon:  Icon(Icons.edit, color: Colors.white),
                          label: Text("Éditer", style: TextStyle(color: Colors.white),),

                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                            backgroundColor: Colors.green.shade600,
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Action déconnexion
                          },
                          icon: Icon(Icons.logout, color: Colors.green,),
                          label: Text('Se déconnecter', style: TextStyle(color: Colors.green),),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.green.shade600),
                            foregroundColor: Colors.green.shade600,
                          ),
                        ),
                      ),

                    ],

                  ),


                ],
              ),
            )



          ],
        ),
      ),
          ),


    );
  }
}
*/