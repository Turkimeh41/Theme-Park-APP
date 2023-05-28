/* eslint-disable camelcase */
/* eslint max-len: ["error", { "code": 160 }]*/

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
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
  const phone = data.phone;
  const email = data.email;
  const docUsers = admin.firestore()
      .collection("Users").where("username", "==", username).limit(1).get();

  const docPhone = admin.firestore()
      .collection("Users").where("phone", "==", phone).limit(1).get();

  const docEmail = admin.firestore()
      .collection("Users").where("email", "==", email).limit(1).get();

  const promises = await Promise.all([docUsers, docPhone, docEmail]);
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
  return {success: true};
});


exports.addUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const QRCode = require("qrcode");
      const {v4: uuidv4} = require("uuid");

      const username = data.username;
      const phone = data.phone;
      const emailAddress = data.email;
      const encryptedpass = hash(data.password).toString();
      const firstName = capitalizeFirstLetter(data.first_name);
      const lastName = capitalizeFirstLetter(data.last_name);
      const balance = 0.0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = data.gender;
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName,
            gender: gender, balance: balance, registered: registerDate,
            phone: phone, email: emailAddress, imgURL: null, points: 0});

      await Promise.all([admin.firestore().collection("User_Engaged").doc(response.id).set({engaged: false, activityID: null}),
        admin.firestore().collection("User_Enabled").doc(response.id).set({enabled: true})]);

      const uuidname = uuidv4();
      const filename = uuidname + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL("USER-"+response.id, {margin: 2, scale: 10});
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
      await file.makePublic();
      const qrURL = file.publicUrl();

      admin.firestore().collection("Users").doc(response.id).set({qrURL: qrURL}, {merge: true});
      const customtoken = await admin.auth().createCustomToken(response.id);
      return {success: true, token: customtoken};
    });


exports.restAddUser = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const hash = require("crypto-js/sha256");
      const QRCode = require("qrcode");
      const {v4: uuidv4} = require("uuid");

      const username = req.body.username;
      const phone = req.body.phone;
      const email = req.body.email;
      const encryptedpass = hash(req.body.password).toString();
      const firstName = capitalizeFirstLetter(req.body.first_name);
      const lastName = capitalizeFirstLetter(req.body.last_name);
      const balance = 0.0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = parseInt(req.body.gender);
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName,
            gender: gender, balance: balance, registered: registerDate,
            phone: phone, email: email, imgURL: null, points: 0});
      await Promise.all([admin.firestore().collection("User_Engaged").doc(response.id).set({engaged: false, activityID: null}),
        admin.firestore().collection("User_Enabled").doc(response.id).set({enabled: true})]);

      const filename = uuidv4() + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL("USER-"+response.id, {margin: 2, scale: 10});
      const qrBuffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("users/qr_codes/"+response.id+"/"+filename);


      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(qrBuffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });


      // we make the URL first public, then return that URL,
      await file.makePublic();
      const qrURL = file.publicUrl();
      admin.firestore().collection("Users").doc(response.id).set({qrURL: qrURL}, {merge: true});
      res.status(200).send({success: true, id: response.id});
    });

exports.login = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const username = data.username;
      const password = data.password;
      const userDocument = await admin.firestore()
          .collection("Users").where("username", "==", username).limit(1).get();

      if (userDocument.empty) {
        const managerDocument = await admin.firestore()
            .collection("Managers").where("username", "==", username).limit(1).get();
        if (managerDocument.empty) {
          throw new functions.https
              .HttpsError("not-found", "Username doesn't exists.");
        }
        const managerID = managerDocument.docs[0].id;
        const managerData = managerDocument.docs[0].data();
        const encryptedpass = hash(password).toString();
        if (managerData["password"] != encryptedpass) {
          throw new functions.https.
              HttpsError("invalid-argument",
                  "Password incorrect.");
        }
        const snapshot = await admin.firestore()
            .collection("Manager_Enabled").doc(managerID).get();
        const enabledData = snapshot.data();
        if (enabledData["enabled"] == false) {
          throw new functions.https.
              HttpsError("permission-denied",
                  "You're currently disabled.");
        }

        const customtoken = await admin.auth()
            .createCustomToken(managerID);
        return {type: "manager", token: customtoken};
      }
      const userData = userDocument.docs[0].data();
      const encryptedpass = hash(password).toString();
      if (userData["password"] != encryptedpass) {
        throw new functions.https.
            HttpsError("invalid-argument",
                "Password incorrect.");
      }
      const snapshot = await admin.firestore()
          .collection("User_Enabled").doc(userDocument.docs[0].id).get();
      const enabledData = snapshot.data();
      if (enabledData["enabled"] == false) {
        throw new functions.https.
            HttpsError("permission-denied",
                "You're currently disabled, contact a manager for more information.");
      }
      const customtoken = await admin.auth()
          .createCustomToken(userDocument.docs[0].id);
      return {type: "user", token: customtoken};
    },
    );


exports.onDeleteUserData = functions.region("europe-west1").firestore.document("Users/{userID}").onDelete(async (snapshot, context) => {
  const data = snapshot.data();
  const id = snapshot.id;
  console.log("context parameters: "+context.params.userID);
  console.log("id of the document: "+id);
  await Promise.all([admin.firestore().collection("User_Enabled").doc(context.params.userID).delete(),
    admin.firestore().collection("User_Engaged").doc(context.params.userID).delete()]);

  if (data["qrURL"] != "null") {
    await Promise.all([
      admin.storage().bucket().deleteFiles({prefix: "users/qr_codes/" + id + "/"}),
      admin.storage().bucket().deleteFiles({prefix: "users/profile_images/" + id + "/"}),
    ]);
    await Promise.all([
      admin.storage().bucket().delete({prefix: "users/qr_codes/" + id + "/"}),
      admin.storage().bucket().delete({prefix: "users/profile_images/" + id + "/"}),
    ]);
  } else {
    await admin.storage().bucket().deleteFiles({prefix: "users/qr_codes/" + id + "/"});
    admin.storage().bucket().delete({prefix: "users/qr_codes/" + id + "/"});
  }
});

exports.onDeleteManagerData = functions.region("europe-west1").firestore.document("Managers/{managerID}").onDelete(async (snapshot, context) => {
  const data = snapshot.data();
  const id = snapshot.id;
  console.log("context parameters: "+context.params.managerID);
  console.log("id of the document: "+id);
  await admin.firestore().collection("Manager_Enabled").doc(context.params.managerID).delete();
  if (data["imgURL"] != "null") {
    await admin.storage().bucket().deleteFiles({prefix: "managers/managers_images/" + id + "/"});
  }
});


exports.addManager = functions.region("europe-west1").https.onRequest(async (req, res) => {
  const hash = require("crypto-js/sha256");
  const {v4: uuidv4} = require("uuid");
  const request = JSON.parse(req.body);

  const username = request["username"];
  const first_name = capitalizeFirstLetter(request["first_name"]);
  const last_name = capitalizeFirstLetter(request["last_name"]);
  const email = request["email"];
  const password = hash(request["password"]).toString();
  const phone = request["phone"];
  const imgname = uuidv4() + ".png";

  const added = admin.firestore.FieldValue.serverTimestamp();
  const response = await admin.firestore().collection("Managers").
      add({first_name: first_name, username: username, last_name: last_name,
        email: email, password: password, phone: phone, added: added});
  await admin.firestore().collection("Manager_Enabled").doc(response.id).set({enabled: true});
  let imgURL = null;
  if (request["imgURL"] != null) {
    const imgBytes = Buffer.from(request["imgURL"], "base64");
    const file = admin.storage().bucket().file("managers/managers_images/"+response.id+"/"+imgname);

    const writestream = file.createWriteStream({metadata: {contentType: "image/png"}});
    writestream.end(imgBytes);
    await new Promise((resolve, reject) => {
      writestream.on("finish", resolve);
      writestream.on("error", reject);
    });
    await file.makePublic();
    imgURL = file.publicUrl();
  }
  await admin.firestore().collection("Managers").doc(response.id).set({imgURL: imgURL}, {merge: true});
  res.status(200).send({success: true, id: response.id, imgURL: imgURL});
});


exports.adminLogin = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const hash = require("crypto-js/sha256");
      const username = req.body.username;
      const password = req.body.password;

      const documents = await admin.firestore()
          .collection("Admin").where("username", "==", username).limit(1).get();
      if (documents.empty) {
        res.status(400).send({"invalid": "username incorrect."});
      }

      const encryptedpass = hash(password).toString();
      const adminData = documents.docs[0].data();

      if (adminData["password"] != encryptedpass) {
        res.status(400).send({"invalid": "password incorrect."});
      }
      const customtoken = await admin.auth()
          .createCustomToken(documents.docs[0].id);
      console.log("the id of the admin doc: "+documents.docs[0].id);
      const body = JSON.stringify({customToken: customtoken, adminID: documents.docs[0].id});
      res.status(200).send(body);
    },
    );


exports.setgetTime = functions.region("europe-west1")
    .https.onRequest(async (req, res) => {
      const response = await admin.firestore().collection("Admin").doc("lewIwHv31DkxgOvzdb1i").get();
      const newTime = admin.firestore.FieldValue.serverTimestamp();
      await admin.firestore().collection("Admin").doc("lewIwHv31DkxgOvzdb1i").set({last_login: newTime}, {merge: true});
      const data = response.data();
      const last_login = data["last_login"];
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
          .add({name: name, duration: duration, price: price, createdAt: createdAt, type: type, multiplier: 1, played: 0, enabled: true});


      // i'll create a collection data that is realtime, which shows which users are engaged at that point of time

      // create a qr code that is encrypted with, stream Cipher, which is fast to execute, but not safer compared to other algorithms like CBC Block cipher
      let filename = uuidv4() + ".png";
      // generate the QR code image as a buffer of data bytes
      const qrdata = await QRCode.toDataURL("ACTV-"+response.id, {margin: 2, scale: 10});
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
      // making both URLs public
      await qrFile.makePublic();
      await imageFile.makePublic();
      const qrURL = qrFile.publicUrl();
      const imgURL = imageFile.publicUrl();
      await Promise.all([admin.firestore().collection("Activites").doc(response.id).set({qrURL: qrURL, imgURL: imgURL}, {merge: true}),
        admin.firestore().collection("Activity_Started").doc(response.id).set({started: false})]);
      await admin.firestore().collection("Activites").doc(response.id).set({qrURL: qrURL, imgURL: imgURL}, {merge: true});
      res.status(200).send({success: true, id: response.id, imgURL: imgURL});
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


  if (data["base64Image"] == null) {
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
    await file.makePublic();
    const imgURL = file.publicUrl();
    await admin.firestore().collection("Activites").doc(id).update({imgURL: imgURL});
    res.status(200).send({imgURL: imgURL});
  }
});


exports.sendEmailForgetHTML = functions.region("europe-west1").https.onCall(async (data, context) =>{
  const nodeMailer = require("nodemailer");
  const sendgridTransport = require("nodemailer-sendgrid-transport");
  const handlebars = require("handlebars");

  const fs = require("fs");

  const documentRef = await admin.firestore().collection("Users").where("email", "==", data["email"]).limit(1).get();
  if (documentRef.empty) {
    console.log("email doesn't exists");
    throw new functions.https.HttpsError("not-found", "Email doesn't exists.");
  }

  const documentSnap = documentRef.docs[0].data();
  const id = documentRef.docs[0].id;
  const email = documentSnap["email"];

  const template = handlebars.compile(fs.readFileSync("html/email_forget_password.hbs", "utf-8"));
  const html = template({id: id});
  const transporter = nodeMailer.createTransport(sendgridTransport({auth: {api_key: "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"}}));

  const mailOptions = {from: "trky-almhini@hotmail.com", to: email, subject: "Testing an email send", html: html};

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log(error);
    } else {
      console.log("email sent: "+info.response);
    }
  });
  return {success: true};
});


exports.generateAnonyQR = functions.region("europe-west1").https.onRequest(async (req, res) => {
  const {v4: uuidv4} = require("uuid");
  const QRCode = require("qrcode");
  const response = await admin.firestore().collection("Anonymous_Users").add({label: null,
    providerAccountID: null, balance: null, assignedDate: null});
  const qrdata = await QRCode.toDataURL("ANONY-"+response.id, {margin: 2, scale: 10});
  const qrCodebuffer = Buffer.from(qrdata.split(",")[1], "base64");
  const filename = uuidv4() + ".png";
  const file = admin.storage().bucket().file("anony_users/qr_codes/"+response.id+"/"+filename);
  const writestream = file.createWriteStream({metadata: {contentType: "image/png"}});
  writestream.end(qrCodebuffer);
  await new Promise((resolve, reject) => {
    writestream.on("finish", resolve);
    writestream.on("error", reject);
  });
  await file.makePublic();
  const qrURL = file.publicUrl();
  await admin.firestore().collection("Anonymous_Users").doc(response.id).set({qrURL: qrURL}, {merge: true});
  res.status(200).send({"success": true, "anonyID": response.id, "qrURL": qrURL});
});


exports.resetPasswordHTML = functions.region("europe-west1").https.onRequest(async (req, res) =>{
  const handlebars = require("handlebars");

  const fs = require("fs");

  const id = req.query.id;

  const template = handlebars.compile(fs.readFileSync("html/reset_password.hbs", "utf-8"));
  const html = template({id: id});
  res.set("Content-Type", "text/html");
  res.status(200).send(html);
});

exports.resetPassword = functions.region("europe-west1").https.onRequest(async (req, res) =>{
  const hash = require("crypto-js/sha256");
  const id = req.query.id;
  const password = req.query.password;
  const encryptedpass = hash(password).toString();
  await admin.firestore().collection("Users").doc(id).update({password: encryptedpass});
  res.status(200).send({success: true});
});
/**
 * Capitalizes the first letter of a string.
 * @param {string} str - The input string.
 * @return {string} The capitalized string.
 */
function capitalizeFirstLetter(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}


