import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/RecupereAdd.dart';
import '../../controllers/auth_controller.dart';

class CreerCompte extends StatefulWidget {
  @override
  State<CreerCompte> createState() => _CreerCompteState();
}
class _CreerCompteState extends State <CreerCompte> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final _controller = AuthController();
  String _selectedRole = 'client'; // Valeur par défaut
  final List<String> _roles = ['client', 'livreur', 'admin'];

  bool _obscurePassword = true;
  bool adresseAutoDetectee = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _roleController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green.shade200,
        elevation: 4,
        centerTitle: true,
        title: Center(
          child: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        width: double.infinity,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Inscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 500,
               // width: double.infinity,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.white],
                  ),
                ),

                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      // champs nom
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        cursorColor: Colors.green.shade700,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                          labelText: 'Nom',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Nom complet',
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Colors.green.shade700, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),

                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        cursorColor: Colors.green.shade700,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email,
                              color: Colors.green.shade700),
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'E-mail',
                          filled: true,
                          fillColor: Colors.green.shade50,
                          contentPadding: EdgeInsets.symmetric(vertical: 16,
                              horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Colors.green.shade700, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              // champs mot de pass
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                cursorColor: Colors.green.shade700,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                      Icons.lock, color: Colors.green.shade700),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),

                                  hintText: 'Mot de passe',
                                  labelText: 'Mot de pass',
                                  labelStyle: TextStyle(color: Colors.black87),
                                  filled: true,
                                  fillColor: Colors.green.shade50,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide(
                                        color: Colors.green.shade700, width: 2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                              controller: _telephoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                              cursorColor: Colors.green.shade700,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                                labelText: 'Téléphone',
                                labelStyle: TextStyle(color: Colors.black87),
                                hintText: 'Téléphone',
                                filled: true,
                                fillColor: Colors.green.shade50,
                                contentPadding: EdgeInsets.symmetric(vertical: 16,
                                    horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: BorderSide(
                                      color: Colors.green.shade700, width: 2),
                                ),
                              ),

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le numereo de telephone est requis.';
                                }
                                // regex numero marocain
                                if (!RegExp(r'^(?:\+212|0)([5-7]\d{8})$').hasMatch(value.trim())) {
                                  return 'Numéro de téléphone invalide';
                                }
                                return null;
                              }
                          ),
                        ),
                        SizedBox(height: 20),

                                  // bouton position
                                  /*OutlinedButton(
                                    child: Text("Utiliser ma position actuelle", style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                       onPressed: () async {
                                      String? adresse = await getAdresse();
                                      if (adresse != null) {
                                        setState(() {
                                          _adresseController.text = adresse;
                                          adresseAutoDetectee = true; // bloque la saisie, active la lecture seule
                                        });

                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Vueillez activer la localisation' )),
                                        );
                                      }
                                    },
                                  ), */
                                  SizedBox(height: 8),
                                  // champs address
                                   Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),

                                    child:TextFormField(
                                      controller: _adresseController,
                                      readOnly: true,
                                      keyboardType: TextInputType.streetAddress,
                                      //maxLines: 2,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(fontSize: 16, color: Colors.black87),
                                      cursorColor: Colors.green.shade700,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.location_on, color: Colors.green.shade700),
                                        labelText: 'Adresse de livraison',
                                        labelStyle: TextStyle(color: Colors.black87),
                                        hintText: 'Adresse complet',
                                        filled: true,
                                        fillColor: Colors.green.shade50,
                                        contentPadding: EdgeInsets.symmetric(vertical: 16,
                                            horizontal: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.green.shade700, width: 2),
                                        ),
                                      ),
                                      onTap: () async{
                                        if (_adresseController.text.isEmpty || !adresseAutoDetectee) {
                                          String? adresse = await getAdresse();
                                          if (adresse != null) {
                                            setState(() {
                                              _adresseController.text = adresse;
                                              adresseAutoDetectee = true; // bloque la saisie, active la lecture seule
                                            });

                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Vueillez activer la localisation' )),
                                            );
                                          }

                                        }
                                      },

                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Adresse requise';
                                        }
                                        return null;
                                      }
                                  ),
                                  ),
                                  SizedBox(height: 20),
                                  // role
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRole,
                                      decoration: InputDecoration(
                                        labelText: "Rôle",
                                        prefixIcon: Icon(Icons.person_outline, color: Colors.green.shade700),
                                        filled: true,
                                        fillColor: Colors.green.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      items: _roles.map((role) {
                                        return DropdownMenuItem(
                                          value: role,
                                          child: Text(role[0].toUpperCase() + role.substring(1)), // majuscule
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRole = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),






                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(
                elevation: 4,
                side: BorderSide(color: Colors.white),
                backgroundColor: Colors.blue.shade700,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
                icon: Icon(Icons.person_add, color: Colors.white),
                label: Text("S'inscrire", style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () async {
                  _controller.register(
                    nom : _nameController.text.trim(),
                    email : _emailController.text.trim(),
                    password : _passwordController.text.trim(),
                    telephone : _telephoneController.text.trim(),
                    adresse : _adresseController.text.trim(),
                    role: _selectedRole,
                    context : context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  // ancien
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/RecupereAdd.dart';

class CreerCompte extends StatefulWidget {
  @override
  State<CreerCompte> createState() => _CreerCompteState();
}
class _CreerCompteState extends State <CreerCompte> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  bool _obscurePassword = true;
  bool adresseAutoDetectee = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String telephone = _telephoneController.text.trim();
    String adresse = _adresseController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('tous les champs sont requis', style: TextStyle(color: Colors.redAccent)),
          backgroundColor: Colors.white ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un email valide @gmail.com',
            style: TextStyle(color: Colors.redAccent)),
            backgroundColor: Colors.white),
      );
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'telephone': telephone,
          'adresse': adresse,
          'createdAt': FieldValue.serverTimestamp(),
          //'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !'),
        backgroundColor: Colors.green,),
      );
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushNamed(context, '/accueil');

    } on FirebaseAuthException catch (e) {
      String message ='';
      switch (e.code) {
        case 'invalid-email':
          message = 'email invalide';
          break;
        case 'email-already-in-use':
          message = 'email deja utilisé';
          break;
        case 'weak-password':
          message = 'pass faible (minimum 7 caracteres';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message,  style: TextStyle(color: Colors.redAccent)),
      backgroundColor: Colors.white ),
    );
    } catch (e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de l\'inscription : $e')),
    );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        backgroundColor: Colors.green.shade200,
        elevation: 2,
        title: Center(
          child: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        width: double.infinity,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Inscription',
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 520,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.white],
                  ),
                ),

                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                            // champs nom
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        cursorColor: Colors.green.shade700,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                          labelText: 'Nom',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Nom complet',
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Colors.green.shade700, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),

                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        cursorColor: Colors.green.shade700,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email,
                              color: Colors.green.shade700),
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'E-mail',
                          filled: true,
                          fillColor: Colors.green.shade50,
                          contentPadding: EdgeInsets.symmetric(vertical: 16,
                              horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Colors.green.shade700, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                                    // champs mot de pass
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                cursorColor: Colors.green.shade700,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                      Icons.lock, color: Colors.green.shade700),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),

                                  hintText: 'Mot de passe',
                                  labelText: 'Mot de pass',
                                  labelStyle: TextStyle(color: Colors.black87),
                                  filled: true,
                                  fillColor: Colors.green.shade50,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide(
                                        color: Colors.green.shade700, width: 2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          cursorColor: Colors.green.shade700,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                            labelText: 'Téléphone',
                            labelStyle: TextStyle(color: Colors.black87),
                            hintText: 'Téléphone',
                            filled: true,
                            fillColor: Colors.green.shade50,
                            contentPadding: EdgeInsets.symmetric(vertical: 16,
                                horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                              borderSide: BorderSide(
                                  color: Colors.green.shade700, width: 2),
                            ),
                          ),

                            validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le numereo de telephone est requis.';
                            }
                            // regex numero marocain
                            if (!RegExp(r'^(?:\+212|0)([5-7]\d{8})$').hasMatch(value.trim())) {
                              return 'Numéro de téléphone invalide';
                            }
                            return null;
                          }
                        ),
               ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [

                                // bouton position
                                OutlinedButton(
                                  child: Text("Utiliser ma position actuelle"),
                                  onPressed: () async {
                                    String? adresse = await getAdresse();
                                    if (adresse != null) {
                                      setState(() {
                                        _adresseController.text = adresse;
                                        adresseAutoDetectee = true; // bloque la saisie, active la lecture seule
                                      });

                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Vueillez activer la localisation' )),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 8),
                                // champs address
                                    TextFormField(
                                    controller: _adresseController,
                                    readOnly: true,
                                    keyboardType: TextInputType.streetAddress,
                                    maxLines: 2,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                    cursorColor: Colors.green.shade700,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.location_on, color: Colors.green.shade700),
                                      labelText: 'Adresse de livraison',
                                      labelStyle: TextStyle(color: Colors.black87),
                                      hintText: 'Adresse complet',
                                      filled: true,
                                      fillColor: Colors.green.shade50,
                                      contentPadding: EdgeInsets.symmetric(vertical: 16,
                                          horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(17),
                                        borderSide: BorderSide(
                                            color: Colors.green.shade700, width: 2),
                                      ),
                                    ),

                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Adresse requise';
                                      }
                                      return null;
                                    }
                                ),


                              ]
                            )




              ),



                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
                icon: Icon(Icons.person_add, color: Colors.white),
                label: Text("S'inscrire", style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () async {
                await _registerUser();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/