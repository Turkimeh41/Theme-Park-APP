/* eslint-disable camelcase */
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


exports.onDeleteUserData = functions.region("europe-west1").firestore.document("Users/{userID}").onDelete(async (snapshot, context) => {
  const data = snapshot.data();
  const id = snapshot.id;
  console.log("context parameters: "+context.params.userID);
  console.log("id of the document: "+id);

  if (data["imguser_link"] != "null") {
    await Promise.all([
      admin.storage().bucket().deleteFiles({prefix: "users/qr-codes/" + id + "/"}),
      admin.storage().bucket().deleteFiles({prefix: "users/profile_images/" + id + "/"}),
    ]);
    await Promise.all([
      admin.storage().bucket().delete({prefix: "users/qr-codes/" + id + "/"}),
      admin.storage().bucket().delete({prefix: "users/profile_images/" + id + "/"}),
    ]);
  } else {
    await admin.storage().bucket().deleteFiles({prefix: "users/qr-codes/" + id + "/"});
    admin.storage().bucket().delete({prefix: "users/qr-codes/" + id + "/"});
  }
});


exports.addUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const QRCode = require("qrcode");
      const {v4: uuidv4} = require("uuid");

      const username = data.username;
      const number = data.number;
      const emailAddress = data.emailAddress;
      const encryptedpass = hash(data.password).toString();
      const firstName = data.first_name;
      const lastName = data.last_name;
      const status = true;
      const balance = 0.0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = data.gender;
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName, status: status,
            gender: gender, balance: balance, registered: registerDate,
            phone_number: number, email_address: emailAddress, imguser_link: "null"});
      const customtoken = await admin.auth().createCustomToken(response.id);
      await admin.firestore().collection("User_Engaged").doc(response.id).set({engaged: false,
      });

      const uuidname = uuidv4();
      const filename = uuidname + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL("USER-"+response.id, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("users/qr_codes/"+response.id+"/"+filename);


      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });

      const fileURL = await file.getSignedUrl({action: "read", expires: "03-17-2025"});
      const link = fileURL[0];
      admin.firestore().collection("Users").doc(response.id).set({qr_link: link}, {merge: true});
      return {success: true, token: customtoken};
    });


exports.restAddUser = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const hash = require("crypto-js/sha256");
      const QRCode = require("qrcode");
      const {v4: uuidv4} = require("uuid");

      const username = req.body.username;
      const number = req.body.number;
      const emailAddress = req.body.emailAddress;
      const encryptedpass = hash(req.body.password).toString();
      const firstName = req.body.first_name;
      const lastName = req.body.last_name;
      const balance = 0.0;
      const status = true;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = parseInt(req.body.gender);
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName, status: status,
            gender: gender, balance: balance, registered: registerDate,
            phone_number: number, email_address: emailAddress, imguser_link: "null"});
      await admin.firestore().collection("User_Engaged").doc(response.id).set({engaged: false});

      const filename = uuidv4() + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL("USER-"+response.id, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("users/qr_codes/"+response.id+"/"+filename);


      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });


      const fileURL = await file.getSignedUrl({action: "read", expires: "03-17-2025"});
      const link = fileURL[0];
      admin.firestore().collection("Users").doc(response.id).set({qr_link: link}, {merge: true});
      res.status(200).send({success: true, id: response.id});
    });


exports.loginUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const username = data.username;
      const password = data.password;

      const document = await admin.firestore()
          .collection("Users").where("username", "==", username).get();
      if (document.empty) {
        throw new functions.https
            .HttpsError("not-found", "Username doesn't exists.");
      }
      const userDoc = document.docs[0].data();
      const encryptedpass = hash(password).toString();
      if (userDoc["password"] != encryptedpass) {
        throw new functions.https.
            HttpsError("invalid-argument",
                "Password incorrect.");
      }

      if (userDoc["status"] == false) {
        throw new functions.https.
            HttpsError("permission-denied",
                "Permission denied, user's has been timedout.");
      }

      const customtoken = await admin.auth()
          .createCustomToken(document.docs[0].id);
      return {sucess: true, token: customtoken};
    },
    );


exports.adminLogin = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const hash = require("crypto-js/sha256");
      const username = req.body.username;
      const password = req.body.password;

      const documents = await admin.firestore()
          .collection("Admin").where("username", "==", username).get();
      if (documents.empty) {
        res.status(400).send({"invalid": "username incorrect."});
      }

      const encryptedpass = hash(password).toString();
      const passDoc = await admin.firestore().collection("Admin").where("password", "==", encryptedpass).get();

      if (passDoc.empty) {
        res.status(400).send({"invalid": "password incorrect."});
      }
      const customtoken = await admin.auth()
          .createCustomToken(documents.docs[0].id);
      console.log("the id of the admin doc: "+documents.docs[0].id);
      res.status(200).send({"token": customtoken, "uid": documents.docs[0].id});
    },
    );


exports.setgetTime = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const response = await admin.firestore().collection("Admin").doc("lewIwHv31DkxgOvzdb1i").get();
      const newTime = admin.firestore.FieldValue.serverTimestamp();
      admin.firestore().collection("Admin").doc("lewIwHv31DkxgOvzdb1i").set({last_login: newTime}, {merge: true});
      const data = response.data();
      const last_login = data.last_login;
      res.status(200).send({"last_login": last_login});
    });


exports.addActivity = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const QRCode = require("qrcode");
      const {v4: uuidv4} = require("uuid");
      const request = JSON.parse(req.body);

      const base64Image = request["image_bytes"];
      const image_bytes = Buffer.from(base64Image, "base64");
      const name = request["name"];
      const duration = request["duration"];
      const price = request["price"];
      const type = request["type"];
      const createdAt = admin.firestore.FieldValue.serverTimestamp();
      const response = await admin.firestore().collection("Activites")
          .add({name: name, duration: duration, price: price, createdAt: createdAt, type: type});


      // i'll create a collection data that is realtime, which shows which users are engaged at that point of time
      await admin.firestore().collection("Activites").doc(response.id).collection("Current_Users").doc().set({});


      // create a qr code that is encrypted with, stream Cipher, which is fast to execute, but not safer compared to other algorithms like CBC Block cipher
      let filename = uuidv4() + ".png";
      // generate the QR code image as a buffer of data bytes
      const qrdata = await QRCode.toDataURL("ACTV-"+response.id, {margin: 2});
      // create a qrcode buffer data
      const qrCodebuffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const qrFile = bucket.file("activites/qr_codes/"+response.id+"/"+filename);
      filename = uuidv4() + ".png";
      const qrwriteStream = qrFile.createWriteStream({metadata: metadata});
      qrwriteStream.end(qrCodebuffer);

      const imageFile = bucket.file("activites/activity_images/" +response.id +"/" + filename);
      const writeStream = imageFile.createWriteStream({metadata: metadata});
      writeStream.end(image_bytes);
      // Upload the image picture
      await Promise.all([new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      }), new Promise((resolve, reject) => {
        qrwriteStream.on("finish", resolve);
        qrwriteStream.on("error", reject);
      })]);

      const results = await Promise.all([qrFile.getSignedUrl({action: "read", expires: "03-17-2025"}),
        imageFile.getSignedUrl({action: "read", expires: "03-17-2025"})]);

      const qrURL = results[0][0];
      const imgURL = results[1][0];

      admin.firestore().collection("Activites").doc(response.id).set({qr_link: qrURL, img_link: imgURL}, {merge: true});
      res.status(200).send({success: true, id: response.id, img_link: imgURL});
    });


exports.editActivity = functions.region("europe-west1").https.onRequest(async (req, res) => {
  const {v4: uuidv4} = require("uuid");
  const data = JSON.parse(req.body);
  const id = data["id"];
  const name = data["name"];
  const type = data["type"];
  const price = data["price"];
  const duration = data["duration"];
  await admin.firestore().collection("Activites").doc(id).
      update({"name": name, "price": price, "type": type, "duration": duration});


  if (data["base64Image"] == "null") {
    console.log("base64 is null, there will be no image upload");
    res.status(200).send({success: true});
  } else {
    console.log("deleting old image uploading a new one...");
    const img_bytes = Buffer.from(data["base64Image"], "base64");
    await Promise.all(
        admin.storage().bucket().deleteFiles({prefix: "users/profile_images/" + id + "/"}),
        admin.storage().bucket().delete({prefix: "users/profile_images/" + id + "/"}));
    const bucket = admin.storage().bucket();
    const filename = uuidv4() + ".png";
    const file = bucket.file("activites/activity_images/"+id+"/"+filename);
    const metadata = {contentType: "image/png"};
    const writeStream = file.createWriteStream({metadata: metadata});
    writeStream.end(img_bytes);
    await new Promise((resolve, reject) =>{
      writeStream.on("finish", resolve);
      writeStream.on("error", reject);
    });
    const imgURL = await file.getSignedUrl({expires: "01-16-2026", action: "read"});
    await admin.firestore().collection("Activites").doc(id).update({img_link: imgURL});
    res.status(200).send({imgURL: imgURL});
  }
});


