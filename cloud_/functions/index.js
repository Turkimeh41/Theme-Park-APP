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
  const number = data.number;
  const emailAddress = data.emailAddress;
  const docUsers = admin.firestore()
      .collection("Users").where("username", "==", username).limit(1).get();

  const docPhonenumber = admin.firestore()
      .collection("Users").where("phone_number", "==", number).limit(1).get();

  const docEmail = admin.firestore()
      .collection("Users").where("email_address", "==", emailAddress).limit(1).get();

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
  return {success: true};
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
            phone_number: number, email_address: emailAddress, imguser_link: "null", points: 0});
      const customtoken = await admin.auth().createCustomToken(response.id);
      await admin.firestore().collection("User_Engaged").doc(response.id).set({engaged: false,
      });

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

      admin.firestore().collection("Users").doc(response.id).set({qr_link: qrURL}, {merge: true});
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
            phone_number: number, email_address: emailAddress, imguser_link: "null", points: 0});
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


      // we make the URL first public, then return that URL,
      await file.makePublic();
      const qrURL = file.publicUrl();
      admin.firestore().collection("Users").doc(response.id).set({qr_link: qrURL}, {merge: true});
      res.status(200).send({success: true, id: response.id});
    });

exports.loginUser = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const hash = require("crypto-js/sha256");
      const username = data.username;
      const password = data.password;

      const document = await admin.firestore()
          .collection("Users").where("username", "==", username).limit(1).get();
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
                "Permission denied, user's has been banned.");
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
      res.status(200).send({"token": customtoken, "uid": documents.docs[0].id});
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
          .add({name: name, duration: duration, price: price, createdAt: createdAt, type: type, multiplier: 1, played: 0});


      // i'll create a collection data that is realtime, which shows which users are engaged at that point of time
      await admin.firestore().collection("Activites").doc(response.id).collection("Current_Users").doc().set({});


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
      await admin.firestore().collection("Activites").doc(response.id).set({qr_link: qrURL, img_link: imgURL}, {merge: true});
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
    await file.makePublic();
    const imgURL = file.publicUrl();
    await admin.firestore().collection("Activites").doc(id).update({img_link: imgURL});
    res.status(200).send({imgURL: imgURL});
  }
});

exports.sendEmailForgetHTML = functions.region("europe-west1").https.onCall(async (data, context) =>{
  const nodeMailer = require("nodemailer");
  const sendgridTransport = require("nodemailer-sendgrid-transport");
  const handlebars = require("handlebars");

  const fs = require("fs");

  const documentRef = await admin.firestore().collection("Users").where("email_address", "==", data["email_address"]).limit(1).get();
  if (documentRef.empty) {
    console.log("email doesn't exists");
    throw new functions.https
        .HttpsError("not-found", "Email doesn't exists.");
  }
  const documentSnap = documentRef.docs[0].data();
  const id = documentRef.docs[0].id;
  const email = documentSnap["email_address"];

  const template = handlebars.compile(fs.readFileSync("html/email_forget_password.hbs", "utf-8"));
  const html = template({id: id});
  const transporter = nodeMailer.createTransport(sendgridTransport({auth: {api_key: "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"}}));

  const mailOptions = {from: "Themepark@forget-password.com", to: email, subject: "Testing an email send", html: html};

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log(error);
    } else {
      console.log("email sent: "+info.response);
    }
  });
  return {success: true};
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


exports.addManager = functions.region("europe-west1").https.onRequest(async (req, res) => {


});


