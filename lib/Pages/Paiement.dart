import 'package:appli_produit/Models/NumeroCommande.dart';
import 'package:flutter/material.dart';
//import 'Models/Panier_model.dart';
import 'ConfirmationCommande.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../Models/commandeProduit_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../Services/servicePaiement.dart';
import '../Models/commandeProduit_model.dart';

class Paiement extends StatefulWidget {
  final double total;
  final List<Produit> produits;
  Paiement({Key? key, required this.total, required this.produits}) : super(key: key);

  @override
  _PaiementState createState() => _PaiementState();
}
class _PaiementState extends State<Paiement> {
  String _modePaiement = 'carte' ;
 // String _modSelection = 'carte';
  final TextEditingController _numeroCarteController = TextEditingController();
  final TextEditingController _dateExpController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final _formKey = GlobalKey<FormState>();  // encapsuler TextFormField
    // comportement de label lorsqu il est selectionné
 // late FocusNode _focusNode;
  //bool _isFocused = false;
 // @override
  /*void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
  });
  });
  } */

  @override
  void dispose() {
    _numeroCarteController.dispose();
    _dateExpController.dispose();
    _cvvController.dispose();
   // _focusNode.dispose();
    super.dispose();
  }

  double getLivraison() {
    if (widget.total >= 300) {
      return 50.0;
    } else if (widget.total >= 50 ) {
      return 10.0;
    } else {
      return 20.0;
    }
    //return Panier.isNotEmpty ? 20.0 : 0.0;
  }
  double getTotalPrix() {
    return widget.total + getLivraison();
  }

  // masque format MM/YY
  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  //convertir les donnees en un objet stripe
 Future<void> effectuerPaiement() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: FirebaseAuth.instance.currentUser?.email,
            ),
          ),
        ),
      );
      print('Methode de paiement créée: ${paymentMethod.id}');
    } catch (e) {
      print('Erreur lors de la creation de la methode: $e');
    }

  }
     // formatter l entree d'un champs
  TextInputFormatter numeroCarteInputFormatter() {
    return FilteringTextInputFormatter.digitsOnly;
  }
  TextInputFormatter dateExpInputFormatter() {
    return FilteringTextInputFormatter.digitsOnly;
  }

       // validation numero carte avec algo de Luhn
  bool isValidCardNumber(String number) {
    number = number.replaceAll('', '');
    if (number.length != 16) return false;

    int sum = 0;
    for (int i = 0; i < number.length; i++) {
      int digit = int.parse(number[number.length - i - 1]);
      if (i % 2 == 1) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0;
  }
    // validation date exp
  bool isValidExpiryDate(String date) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(date)) return false;

    final parts = date.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final fullYear = 2000 + year;
    final expiration = DateTime(fullYear, month + 1, 0 );
    return expiration.isAfter(now);
  }

     // validation cvv
  bool isValidCVV(String cvv) {
     return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

void verificationCarte(String numero, String expiration, String cvv) {
    if( !isValidCardNumber(numero)) {
      print('Numero de carte invalide');

    } else if (!isValidExpiryDate(expiration)) {
      print('Date expiration invalide');

    } else if (!isValidCVV(cvv)) {
      print('CVV invalide');

    } else {
      print('Touts les infos sont valides');
    }

}
    // cal prix total des prod
 /* double getPrixProduits () {
    Panier.forEach((article) {
      print('${article.nom} x${article.quantite} = ${article.prix * article.quantite}');
    });
    return Panier.fold(0.0, (total, article) {
      return total + (article.prix * article.quantite);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    double prixProduits = widget.total;
    double livaison  = getLivraison();
    double totalPrix = getTotalPrix();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFF1FDF4),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white70),
        elevation: 4,
        centerTitle: true,
        title: Text('Paiement', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
       body: SafeArea(
         child: SingleChildScrollView(
           padding: EdgeInsets.all(20),
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.green.shade500, blurRadius: 18, offset: Offset(0, 4),)],
                ),
                child: Column(children: [
                  _buildPrixRow('Prix total', widget.total),
                  _buildPrixRow('Frais de livraison', livaison),
                  Divider(height: 25),
                  _buildPrixRow('Montant à payer', totalPrix, isTotal: true),
                  ],
                ),
              ),
             SizedBox(height: 10),
             Text('Mode de paiement', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
             SizedBox(height: 10),
             _buildPaiementOption(icon: Icons.credit_card,
               label: 'Paiement par carte',
               value: 'carte',
             ),
             _buildPaiementOption(icon: Icons.local_shipping,
               label: 'Paiement à la livraison',value: 'livraison',),

          // formulaire de paiement par carte

            if (_modePaiement == 'carte') ...[
              SizedBox(height: 26),
              Text('Paiement par carte:', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // numero carte

                    TextFormField(
                      controller: _numeroCarteController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      cursorColor: Colors.green.shade700,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                        numeroCarteInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Numero de la carte', labelStyle: TextStyle(fontSize: 16,color: Colors.green ),
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green, // couleur de la bordure au focus
                              width: 2.0,
                        )
                        )
                      ),

                      validator: (value) {
                        if (value == null || !isValidCardNumber(value)) {
                          return 'Numero de carte invalide';
                        };
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        // date exp
                        Expanded(
                          child: TextFormField(
                            controller: _dateExpController,
                            keyboardType: TextInputType.datetime,
                            cursorColor: Colors.green.shade700,
                            inputFormatters: [maskFormatter],  // formatter le texte saisi par user par le mask def
                            decoration: InputDecoration(
                              labelText: 'Date d\'expiration', labelStyle: TextStyle(fontSize: 14,color: Colors.green ),
                              //labelText: _isFocused ? 'Code de sécurité (CVV)' : 'CVV',
                              hintText: 'MM/YY',
                              prefixIcon: Icon(Icons.date_range, size: 16),
                              filled: true,
                              fillColor: Colors.green.shade50,
                                //floatingLabelBehavior: FloatingLabelBehavior.always,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal:10 ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),

                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green, // couleur de la bordure au focus
                                      width: 2.0,
                                    )
                                )
                            ),

                            validator: (value) {
                              if (value == null || !isValidExpiryDate(value)) {
                                return 'Date invalide';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            maxLength: 4,     // compteur (0/4)
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            cursorColor: Colors.green.shade700,
                           inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              labelText: 'CVV', labelStyle: TextStyle(fontSize: 14,color: Colors.green),
                                //hintStyle: TextStyle(color: Colors.green),
                              counterText: '',  // cache le compteur (0/4) pr eviter une hauteur supplém
                              filled: true,
                              fillColor: Colors.green.shade50,
                              prefixIcon: Icon(Icons.lock, size: 16),
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal:10 ),
                             border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 2.0,
                                    )
                                )
                            ),

                            validator: (value) {
                              if (value == null || !isValidCVV(value)) {
                                return 'cvv invalide';
                              }
                              return null;
                            },
                          ),
                        )

                      ]
                    ),

                  ]
                )
              ),

       ],
              SizedBox(height: 30),

              // bouton
             /* ElevatedButton(
                onPressed: () async {
                  if (_modePaiement == 'carte') {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if(!isValid)     {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text ('Vueillez saisir tous les champs', style: TextStyle(color: Colors.redAccent)),
                            backgroundColor: Colors.white,
                          ));

                      return;
                     }
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text ('Les champs sont valides', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.green[400],
                        ));

                        try {
                          final totalPrix = widget.total + getLivraison();
                          print("widget.total : ${widget.total}");
                          print(" Frais livraison : ${getLivraison()}");
                          print("Total prix envoyé à Stripe : $totalPrix");

                          await PaiementService.makePayment(totalPrix);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Paiement réussi ! Merci pour votre commande.', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.push(
                           context,
                             MaterialPageRoute(
                              builder: (_) => ConfirmCommande(total: totalPrix,modePaiement: _modePaiement,produits: widget.produits, commandeId: genereNumCommande(),),
           ),
            );
                       } catch (e) {
                         //print(" Erreur inattendue : $e");
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors du paiement', style: TextStyle(color: Colors.redAccent)),
                          backgroundColor: Colors.white,
                 ),
              );
         }

    } else if (_modePaiement == 'livraison') {
        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (_) => ConfirmCommande(total: totalPrix,modePaiement: _modePaiement,produits: widget.produits, commandeId: genereNumCommande(),),
                  ));
                  }

         },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  backgroundColor: Colors.green,
                  elevation: 4,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Payer maintenant', style: TextStyle(fontSize: 18, color: Colors.white)),
              ), */

             ElevatedButton(
               onPressed: ()  {
                 if (_modePaiement == 'carte') {
                   if (_numeroCarteController.text.isEmpty ||
                       _dateExpController.text.isEmpty
                       || _cvvController.text.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Veuillez entrer un numero de carte valide'),
                         ));
                     return;
                   }
                 }
                 Navigator.push(context,
                     //MaterialPageRoute(builder: (_) => ConfirmCommande(total: totalPrix, modePaiement: _modePaiement, produits: widget.produits)),
                     MaterialPageRoute( builder: (_) => ConfirmCommande(total: totalPrix,modePaiement: _modePaiement,produits: widget.produits, commandeId: genereNumCommande())),
                 );
               },
             style: ElevatedButton.styleFrom(
               side: BorderSide(color: Colors.white),
               backgroundColor: Colors.green,
               elevation: 2,
               minimumSize: Size(double.infinity, 50),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10)),
           ),
           child: Text('Payer maintenant', style: TextStyle(fontSize: 18, color: Colors.white)),
             ),
           ],
         ),
       ),
       ),
    );
  }

  Widget _buildPrixRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text( label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ?
            FontWeight.bold : FontWeight.normal, color: Colors.blue)),

          Text('${value.toStringAsFixed(0)} Dhs', style: TextStyle(fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildPaiementOption(
      {required IconData icon, required String label, required String value}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _modePaiement = value;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _modePaiement == value ? Colors.green[200] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _modePaiement == value ? Colors.green : Colors.blue),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Radio(
              value: value,
              groupValue: _modePaiement,
              onChanged: (val) {
                setState(() {
                  _modePaiement = val!;
                });
              },
              activeColor: Colors.green,
            )
          ],
        ),
      ),
    );
  }
}



