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
      const password = data.password;
      const SHA256 = hash(password);
      const encryptedpass = SHA256.toString();
      try {
        return admin.firestore().collection("users").
            add({username: username, password: encryptedpass})
            .then(async (response) => {
              try {
                const customToken = admin.auth().createCustomToken(response.id);
                return {success: true, token: customToken};
              } catch (error) {
                return {error: error + "hello"};
              }
            });
      } catch (error) {
        throw new functions.https.HttpsError("Failed", "Error");
      }
    });

exports.loginUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const username = data.username;
      const password = data.password;
      try {
        return admin.firestore()
            .collection("users").where("username", "==", username)
            .get().then(async (document) =>{
              if (document.empty) {
                throw new functions.https
                    .HttpsError("invalid-username", "username doesn't exists");
              }
              const encryptedpass = hash(password).toString();
              if (document.docs[0]["password"] != encryptedpass) {
                throw new functions.https
                    .HttpsError("invalid-password", "password incorrent");
              }

              admin.auth().createCustomToken(document.docs[0].id)
                  .then((customtoken)=>{
                    return {sucess: true, token: customtoken};
                  })
                  .catch((error)=>{
                    throw error;
                  });
            }).catch((error)=> {
              throw error;
            });
      } catch (error) {
        console.log(error);
        throw error;
      }
    },
    )
;
