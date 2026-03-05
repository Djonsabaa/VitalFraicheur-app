const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const Stripe = require('stripe');
const stripe = Stripe(functions.config().stripe.secret);

console.log("Clé Stripe chargée :", functions.config().stripe.secret);

// Fonction pour créer un PaymentIntent
exports.createPaymentIntent = functions.https.onCall(
 { enforceAppCheck: false }, //  désactivé App Check temporairement
  async (data, context) => {

  console.log("Données reçues :", data);

  const amount = data.amount;
  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Montant invalide');
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: "MAD",
      payment_method_types: ["card"],
    });
     console.log("PaymentIntent créé avec ID :", paymentIntent.id);

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error("Erreur lors de la création du PaymentIntent :", error.message);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Fonction pour récupérer le statut du PaymentIntent
exports.getPaymentIntentStatus = functions.https.onCall(async (data, context) => {
  const paymentIntentId = data.paymentIntentId;
  if (!paymentIntentId) {
    throw new functions.https.HttpsError('invalid-argument', 'PaymentIntentId manquant');
  }

  try {
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    return { status: paymentIntent.status };
  } catch (error) {
    console.error("Erreur lors de la récupération du PaymentIntent :", error.message);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
