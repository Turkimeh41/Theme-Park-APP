/* eslint max-len: ["error", { "code": 160 }]*/

const functions = require("firebase-functions");
const admin = require("firebase-admin");
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

exports.sendSMSTwilio = functions.region("europe-west1").https.onCall(async (data, context)=>{
  const smsCode = (Math.floor(Math.random() * 9000) + 1000).toString();
  const accountSid = "AC488a4c5e74b1ceee7ebbe9a473aad978";
  const authToken = "14ab54a39b27322d91b8539de2407228";
  const client = require("twilio")(accountSid, authToken);
  await client.messages.create({body: "Verification Code: "+smsCode, from: "+15856327558", to: data.phone_number});
  return {smscode: smsCode};
});

exports.sandboxCreatenumber = functions.region("europe-west1").https.onCall(async (data, context)=>{
  const {SNSClient, CreateSMSSandboxPhoneNumberCommand} = require("@aws-sdk/client-sns"); // CommonJS import
  const config = {region: "me-south-1", credentials: {accessKeyId: "AKIATWWETFD5IWZ2NVKT", secretAccessKey: "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"}};
  const client = new SNSClient(config);
  console.log(data.phone_number);
  const input = { // CreateSMSSandboxPhoneNumberInput
    PhoneNumber: data.phone_number, // required
    LanguageCode: "en-US",
  };
  const command = new CreateSMSSandboxPhoneNumberCommand(input);
  await client.send(command);
});

exports.sandboxVerifynumber = functions.region("europe-west1").https.onCall(async (data, context)=>{
  const {SNSClient, VerifySMSSandboxPhoneNumberCommand} = require("@aws-sdk/client-sns");
  const config = {region: "me-south-1", credentials: {accessKeyId: "AKIATWWETFD5IWZ2NVKT", secretAccessKey: "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"}};
  const client = new SNSClient(config);
  const input = { // VerifySMSSandboxPhoneNumberInput
    PhoneNumber: data.phone_number, // required
    OneTimePassword: data.smsCode, // required
  };
  const command = new VerifySMSSandboxPhoneNumberCommand(input);
  try {
    await client.send(command);
    return {success: true};
  } catch (error) {
    if (error.name === "VerificationException") {
      throw new functions.https
          .HttpsError("invalid-argument", "The Code for the phone verification you provided is wrong");
    }
  }
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
      const balance = 0;
      const registerDate = admin.firestore.FieldValue.serverTimestamp();
      const gender = data.gender;
      const response = await admin.firestore().collection("Users")
          .add({username: username, password: encryptedpass, first_name: firstName, last_name: lastName,
            gender: gender, balance: balance, registered: registerDate,
            phone_number: number, email_address: emailAddress});
      const customtoken = await admin.auth().createCustomToken(response.id);
      // Encrypt a random String, to AES, Advanced Encryption Standard, the cipher we will use is Block cipher
      // a random key, that is used to encrypt and decrypt the qr code message, with block cipher cryptosystem

      // key should be in raw binray form, but when stored as string, it should be in string with hex format
      const key = crypto.randomBytes(32);
      const iv = crypto.randomBytes(16);

      const cipher = crypto.createCipheriv("aes-256-cbc", key, iv);
      let encryptedQR = cipher.update(response.id, "utf8", "hex");
      encryptedQR += cipher.final("hex");
      encryptedQR += iv.toString("hex");
      // the key will be stored as string to hex, then when retrieved we will convert it back from hex
      const storedKEY = key.toString("hex");

      const filename = uuidv4() + ".png";
      // generate the QR code image as a buffer
      const qrdata = await QRCode.toDataURL(encryptedQR, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {contentType: "image/png"};
      const bucket = admin.storage().bucket();
      const file = bucket.file("qr-codes/users/"+response.id.toString()+"/"+filename);

      const writeStream = file.createWriteStream({metadata: metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });
      console.log("encrypted qr is : "+encryptedQR);
      console.log("key is : "+storedKEY);
      console.log("key is : "+ iv);
      return {success: true, token: customtoken, key: storedKEY, iv: iv};
    });


exports.addActivity = functions.region("europe-west1")
    .https.onCall(async (data, context) => {
      const QRCode = require("qrcode");
      const crypto = require("crypto");
      const {v4: uuidv4} = require("uuid");

      const name = data.name;
      const description = data.description;
      // in seconds duration
      const duration = data.duration;
      const price = data.price;
      const createdAt = admin.firestore.FieldValue.serverTimestamp();
      const response = await admin.firestore().collection("Activites")
          .add({username: name, duration: duration, description: description, price: price, createdAt: createdAt});

      // Encrypt response id, for the qr code, so when user scans it, it's 256 length, and it will be decrypted with a key for CBC Block Cipher

      // key should be in raw binray form, but when stored as string, it should be in string with hex format
      const key = crypto.randomBytes(32);
      const iv = crypto.randomBytes(16);

      const cipher = crypto.createCipheriv("aes-256-cbc", key, iv);
      let encryptedQR = cipher.update(response.id, "utf8", "hex");
      encryptedQR += cipher.final("hex");
      encryptedQR += iv.toString("hex");
      // the key will be stored as string to hex, then when retrieved we will convert it back from hex
      const storedKEY = key.toString("hex");

      const filename = uuidv4() + ".jpg";
      // generate the QR code image as a buffer
      console.log(encryptedQR);
      const qrdata = QRCode.toDataURL(encryptedQR, {margin: 2});
      const buffer = Buffer.from(qrdata.split(",")[1], "base64");
      const metadata = {
        contentType: "image/jpg",
        customMetaData: {key: storedKEY, createdAt: admin.firestore().FieldValue.serverTimestamp()}};

      const bucket = admin.storage().bucket();
      const file = bucket.file("qr-codes/activites/"+response.id.toString()+"/"+filename);
      const writeStream = file.createWriteStream({metadata});
      writeStream.end(buffer);

      await new Promise((resolve, reject) => {
        writeStream.on("finish", resolve);
        writeStream.on("error", reject);
      });
      return {success: true};
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
      console.log(customtoken);
      return {sucess: true, token: customtoken};
    },

    );

