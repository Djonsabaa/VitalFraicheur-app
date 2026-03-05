import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Accueil.dart';
import 'CreerCompte.dart';
import 'MpassOublie.dart';
import '../Controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class Connexion extends StatefulWidget {
  @override
  State<Connexion> createState() => _ConnexionState();
}
class _ConnexionState extends State<Connexion> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // declaration de l instance authController
  final AuthController _authController = AuthController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _obscurePassword = true;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
 /* void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }*/

 /* void _loginUser() async{
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if(email.isEmpty || password.isEmpty){
     // _showMessage('Tous les champs sont obligatoire');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez saisir tous les champs!', style: TextStyle(color: Colors.redAccent)),
          backgroundColor: Colors.white,
        ),
      );
      //return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie !' ),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushNamed(context, '/accueil');
    }
    on FirebaseAuthException catch (e) {
      print('erreur dans la console:${e.code}');

      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('utilisateur non trouvé', style: TextStyle(color: Colors.redAccent))
          ),
        );
      }
      else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('mot de pass incorrect !', style: TextStyle(color: Colors.redAccent))
          ),
        );
      }
      else {
        //_showMessage("Erreur : ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('erreur !')),
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('erreur inattendue!')),
      );
    }
  } */

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        centerTitle: true,
        elevation: 4,
        title: Container(
          child: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
          /*decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade200,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ]
          ),*/
        ),

      ),
      body: Container(
        padding: EdgeInsets.only(top: 40.0),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Authentification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700,),
                ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.white],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text('Accédez à votre compte ou créez-en un nouveau',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      SizedBox(height:30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),

                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          cursorColor: Colors.green.shade700,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                            labelText: 'E-mail',
                            labelStyle: TextStyle(color: Colors.black87),
                            hintText: 'E-mail',
                            filled: true,
                            fillColor: Colors.green.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.green.shade700, width: 2),
                          ),
                        ),
                      ),
                      ),
                      SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),

                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                  cursorColor: Colors.green.shade700,
                                  decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
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
                                  labelText: 'Mot de pass',
                                  labelStyle: TextStyle(color: Colors.black87),
                                  hintText: 'Mot de passe',
                                  filled: true,
                                  fillColor: Colors.green.shade50,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.green.shade700, width: 2),
                                  ),
                                ),
                              ),
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 170.0, top:8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MpassOublie()),
                            );
                            },
                              child: Text('Mot de pass oublié ?',
                                style: TextStyle(fontSize: 16, color: Colors.blue,  decoration: TextDecoration.underline),),
                            ),
                          )

                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.white),
                    minimumSize: Size(double.infinity, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.login, color: Colors.white),
                  label:
                  Text('Se connecter', style: TextStyle(fontSize: 18, color: Colors.white)),
                  //onPressed: _loginUser,
                  onPressed: () {
                    _authController.loginUser(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                      context: context,
                    );
                  },
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.white),
                    minimumSize: Size(double.infinity, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.person_add, color: Colors.white),
                  label:
                  Text('Créer un compte', style: TextStyle(fontSize: 18, color: Colors.white)),
                  onPressed: () => Navigator.pushNamed(context, '/inscrire'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}



