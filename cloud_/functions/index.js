/* eslint max-len: ["error", { "code": 160 }]*/

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.helloWorld = functions.region("europe-west1").https.onRequest(
    async (request, respone)=> {
      respone.send("Hello from Firebase");
    });

exports.sendSMSTwilio = functions.region("europe-west1").https.onCall(async (data, context)=>{
  const smsCode = (Math.floor(Math.random() * 9000) + 1000).toString();
  const accountSid = "AC488a4c5e74b1ceee7ebbe9a473aad978";
  const authToken = "14ab54a39b27322d91b8539de2407228";
  const client = require("twilio")(accountSid, authToken);
  await client.messages.create({body: "Verification Code: "+smsCode, from: "+15856327558", to: data.phone_number});
  return {smscode: smsCode};
});


exports.existsUser = functions.region("europe-west1").https.onCall(async (data, context) => {
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
  return {sucess: true};
});

exports.addUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const QRCode = require("qrcode");
      const crypto = require("crypto");
      const {v4: uuidv4} = require("uuid");

      const username = data.username;
      const number = data.number;
      const emailAddress = data.emailAddress;
      const encryptedpass = hash(data.password).toString();
      const firstName = data.first_name;
      const lastName = data.last_name;
      const balance = 0.0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = data.gender;
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName,
            gender: gender, balance: balance, registered: registerDate,
            phone_number: number, email_address: emailAddress});
      const customtoken = await admin.auth().createCustomToken(response.id);
      await admin.firestore().collection("User_Status").doc(response.id).set({engaged: false,
      });

      // Stream Cipher encryption cryptosystem, encrypting The qr code, then decrypting that qr code whenever user scans the scan to deduce balance.
      const key = crypto.randomBytes(32);
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv("aes-256-ctr", key, iv);
      let encryptedMessage = cipher.update(response.id, "utf8", "hex");
      encryptedMessage += cipher.final("hex");

      const filename = uuidv4() + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL("USER-"+encryptedMessage, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("qr-codes/users/"+response.id.toString()+"/"+filename);

      await admin.firestore().collection("User_Keys").doc("USER-"+encryptedMessage).set({key: key.toString("hex"), iv: iv.toString("hex")});

      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });
      return {success: true, token: customtoken};
    });

exports.loginUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
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
                "Password incorrect.");
      }
      const customtoken = await admin.auth()
          .createCustomToken(documents.docs[0].id);
      return {sucess: true, token: customtoken};
    },
    );


exports.addActivity = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const QRCode = require("qrcode");
      const crypto = require("crypto");
      const {v4: uuidv4} = require("uuid");

      const name = data.name;
      const description = data.description;
      // in minutes duration
      const duration = data.duration;
      const price = data.price;
      const type = data.type;
      const createdAt = admin.firestore.FieldValue.serverTimestamp();
      const response = await admin.firestore().collection("Activites")
          .add({name: name, duration: duration, description: description, price: price, createdAt: createdAt, type: type});

      // IMPORTANT: t remove this later and let the manager handle it, but just a refrence,
      // i'll create a collection data that is realtime, which shows which users are engaged at that point of time
      await admin.firestore().collection("Activites").doc(response.id).collection("Current_Users").doc().set({});


      // create a qr code that is encrypted with, stream Cipher, which is fast to execute, but not very safe, compared to other algorithms like CBC Block cipher
      const key = crypto.randomBytes(32);
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv("aes-256-ctr", key, iv);
      let encryptedMessage = cipher.update(response.id, "utf8", "hex");
      encryptedMessage += cipher.final("hex");

      const filename = uuidv4() + ".png";
      // generate the QR code image as a buffer of data bytes
      const qrdata = await QRCode.toDataURL("ACTV-"+encryptedMessage, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("qr-codes/activites/"+response.id.toString()+"/"+filename);
      await admin.firestore().collection("Activity_Keys").doc("ACTV-"+encryptedMessage).set({key: key.toString("hex"), iv: iv.toString("hex")});

      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });
      return {success: true};
    });

exports.getSecret = functions.region("europe-west1").https.onCall(async (data, context) => {
  if (data.id.includes("USER-")) {
    let result = await admin.firestore().collection("User_Keys").doc(data.id).get();
    result = result.data();
    return {key: result["key"], iv: result["iv"]};
  } else if (data.id.includes("ACTV-")) {
    let result = await admin.firestore().collection("Activity_Keys").doc(data.id).get();
    result = result.data();
    return {key: result["key"], iv: result["iv"]};
  } else {
    throw new functions.https.HttpsError("not-found", "Document not found!");
  }
});


