import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Pages/Connexion.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> register({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role,
    required BuildContext context,
  }) async {
    if (nom.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(context, "Tous les champs sont requis");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email)) {
      _showError(context, "Veuillez entrer un email valide @gmail.com");
      return;
    }

    try {
      await _authService.registerUser(
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        adresse: adresse,
        role: role,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !'), backgroundColor: Colors.green),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.pushNamed(context, '/accueil');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'email-already-in-use':
          message = 'Email déjà utilisé';
          break;
        case 'weak-password':
          message = 'Mot de passe trop faible (minimum 7 caractères)';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, "Erreur lors de l'inscription : $e");
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showError(context, "Veuillez saisir tous les champs !");
      return;
    }

    try {
      await _authService.loginUser(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie !'), backgroundColor: Colors.green),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _checkAnRedirectUser(user, context);
      }
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase : ${e.code}');

      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'Utilisateur non trouvé';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, "Erreur inattendue !");
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Connexion()),
          (route) => false,
    );
  }

  Future<void> _checkAnRedirectUser(User user, BuildContext context) async {
    String? role = await _authService.getUserRole(user.uid);
    if (role != null) {
      _redirectUser(role, context);
    } else {
      _showError(context, "Impossible de récupérer le rôle utilisateur");
    }
  }

  void _redirectUser(String role, BuildContext context) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (role == 'client') {
      Navigator.pushReplacementNamed(context, '/accueil');
    } else if (role == 'livreur') {
      Navigator.pushReplacementNamed(context, '/livreur');
    }
  }

  void _showError(BuildContext context, String message) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.redAccent)),
        backgroundColor: Colors.white,
        duration: Duration(seconds: 3),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Pages/Connexion.dart';
class AuthController {
  final AuthService _authService = AuthService();


  Future<void> register({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role,
    required BuildContext context,
  }) async {
    if (nom.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(context, "Tous les champs sont requis");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email)) {
      _showError(context, "Veuillez entrer un email valide @gmail.com");
      return;
    }

    try {
      await _authService.registerUser(
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        adresse: adresse,
        role: role,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !'), backgroundColor: Colors.green),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.pushNamed(context, '/accueil');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'email-already-in-use':
          message = 'Email déjà utilisé';
          break;
        case 'weak-password':
          message = 'Mot de passe trop faible (minimum 7 caractères)';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, "Erreur lors de l'inscription : $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.redAccent)), backgroundColor: Colors.white),
    );
  }

  // methode connexion
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showError(context, "Veuillez saisir tous les champs !");
      return;
    }

    try {
      await _authService.loginUser(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie !'), backgroundColor: Colors.green),
      );

      //await Future.delayed(Duration(seconds: 1));
      //Navigator.pushNamed(context, '/accueil');
      User? user = FirebaseAuth.instance.currentUser;
      if (user !=null) {
        await _checkAnRedirectUser(user, context);
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'Utilisateur non trouvé';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, "Erreur inattendue !");
    }
  }

  // deconnexion
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Connexion()),
          (route) => false,
    );
  }


  /*void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.redAccent)), backgroundColor: Colors.white),
    );
  }*/
      // redirection des users
  Future<void> _checkAnRedirectUser(User user, BuildContext context) async {
    String? role = await _authService.getUserRole(user.uid);

    if (role != null) {
      _redirectUser(role, context);
    } else{
      _showError(context, "impossible de recupérer le role utilisateur");
    }
  }
  void _redirectUser (String role, BuildContext context) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (role == 'client') {
      Navigator.pushReplacementNamed(context, '/accueil');
    } else if (role == 'livreur') {
      Navigator.pushReplacementNamed(context, '/livreur');
    }
  }

/*void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.redAccent)), backgroundColor: Colors.white),
    );
  }*/


}*/



