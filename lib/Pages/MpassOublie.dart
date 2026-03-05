import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MpassOublie extends StatefulWidget{
  @override
  _MpassOublieState createState() => _MpassOublieState();
}
class _MpassOublieState extends State <MpassOublie> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    setState(() => isLoading = true);

    String email = _emailController.text.trim();
    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un email valide @gmail.com',
        style: TextStyle(color: Colors.redAccent)),
        backgroundColor: Colors.white),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le lien de réinitialisation a été envoyé par mail'),
          backgroundColor: Colors.green ),
      );
    }
    catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('adresse incorrect',  style: TextStyle(color: Colors.redAccent)),
                backgroundColor: Colors.white),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('erreur: ${e.message}',style: TextStyle(color: Colors.redAccent)),
                backgroundColor: Colors.green),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('erreur',  style: TextStyle(color: Colors.redAccent))),
        );
      }
    }finally {
      setState(() => isLoading = false);
    }
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

      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            ),
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
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
            SizedBox(height: 30),
            isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                 child: Text('Reinitialiser le mot de pass'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
                 onPressed: resetPassword,
            ) ,
          ],
        )
      ),

    );
  }

}