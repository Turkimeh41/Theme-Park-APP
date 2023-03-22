/* eslint max-len: ["error", { "code": 120 }]*/

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const hash = require("crypto-js/sha256");

admin.initializeApp();

exports.addMessage = functions.region("europe-west1").https.onRequest(
    async (req, res) => {
      const original = req.query.text;
      const writeResult = await admin.firestore().collection("messages")
          .add({original: original});
      res.json({result: `Message with ID: ${writeResult.id} added.`});
    });
exports.helloWorld = functions.region("europe-west1").https.onRequest(
    async (request, respone)=> {
      respone.send("Hello from Firebase");
    });


exports.addUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const username = data.username;
      const number = data.number;
      const emailAddress = data.emailAddress;
      const docUsers = admin.firestore()
          .collection("Users").where("username", "==", username).get();

      const docPhonenumber = admin.firestore()
          .collection("Users").where("phone_number", "==", number).get();

      const docEmail = admin.firestore()
          .collection("Users").where("email_address", "==", emailAddress).get();

      const promises = await Promise.all([docUsers, docPhonenumber, docEmail]);

      let uError = "F";
      let pError = "F";
      let eError = "F";
      // ERROR HANDLING TO SHOW MULTIPLE ERRORS

      if (!promises[0].empty) {
        uError = "T";
      }
      if (!promises[1].empty) {
        pError = "T";
      }
      if (!promises[2].empty) {
        eError = "T";
      }
      if (uError == "T" || pError == "T"|| eError == "T") {
        throw new functions.https
            .HttpsError("already-exists", uError+" "+pError+" "+eError);
      }
      const encryptedpass = hash(data.password).toString();
      const firstName = data.first_name;
      const lastName = data.last_name;
      const balance = 0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = data.gender;

      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName,
            gender: gender, balance: balance, registered: registerDate,
            phone_number: number, email_address: emailAddress});
      const customtoken = await admin.auth().createCustomToken(response.id);
      return {sucess: true, token: customtoken};
    });

exports.loginUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const username = data.username;
      const password = data.password;

      const documents = await admin.firestore()
          .collection("Users").where("username", "==", username).get();
      if (documents.empty) {
        throw new functions.https
            .HttpsError("not-found", "Username doesn't exists.");
      }

      const encryptedpass = hash(password).toString();
      const passDoc = await admin.firestore().collection("Users").where("password", "==", encryptedpass).get();

      if (passDoc.empty) {
        throw new functions.https.
            HttpsError("invalid-argument",
                "password incorrect");
      }
      const customtoken = await admin.auth()
          .createCustomToken(documents.docs[0].id);
      return {sucess: true, token: customtoken};
    },

    )
;
