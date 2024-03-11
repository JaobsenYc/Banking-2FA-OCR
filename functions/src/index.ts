/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as CryptoJS from "crypto-js";
// import firstore
import * as admin from "firebase-admin";

admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
// TODO : REMOOVE THIS KEYS FROM HERE
// secretKey : W2U5fiDQL4G59vsKjlVfiQglPWr0hWe7
// hmac_key : b2341989afb992ad2af2be3fabe16ab2ce65dfe1917725ef8cfb4c92f5878f6e
const secretKey = functions.config().crypto.key;
const secretKeyForHMAC = functions.config().crypto.hmac_key;

exports.encryptData = functions.https.onCall((data) => {
  const jsonData = data;
  const iv = CryptoJS.lib.WordArray.random(128 / 8);
  const ciphertext = CryptoJS.AES.encrypt( // eslint-disable-line new-cap
    JSON.stringify(jsonData),
    CryptoJS.enc.Hex.parse(secretKey), // eslint-disable-line new-cap
    {iv: iv},
  ).toString();
  // Generate HMAC using ciphertext and IV
  const hmac = CryptoJS.HmacSHA256( // eslint-disable-line new-cap
    ciphertext +
      CryptoJS.enc.Hex.stringify(iv), // eslint-disable-line new-cap
    CryptoJS.enc.Hex.parse(secretKeyForHMAC),
  ) // eslint-disable-line new-cap
    .toString();
  const encryptedData = hmac +
    CryptoJS.enc.Hex.stringify(iv) + // eslint-disable-line new-cap
    ciphertext; // eslint-disable-line new-cap
  return encryptedData;
});

exports.decryptData = functions.https.onCall((data) => {
  const hmacPlusIvPlusCiphertext = data;
  const hmac = hmacPlusIvPlusCiphertext.substr(0, 64);
  const iv = CryptoJS.enc.Hex.parse(
    hmacPlusIvPlusCiphertext.substr(64, 32),
  ); // eslint-disable-line new-cap
  const ciphertext = hmacPlusIvPlusCiphertext.substr(96);
  // Regenerate HMAC using ciphertext and IV for validation
  const currentHmac = CryptoJS.HmacSHA256( // eslint-disable-line new-cap
    ciphertext + CryptoJS.enc.Hex.stringify(iv), // eslint-disable-line new-cap
    CryptoJS.enc.Hex.parse(secretKeyForHMAC),
  ) // eslint-disable-line new-cap
    .toString();
  if (currentHmac !== hmac) {
    return "Integrity check failed";
  }
  const bytes = CryptoJS.AES.decrypt( // eslint-disable-line new-cap
    ciphertext,
    CryptoJS.enc.Hex.parse(secretKey), // eslint-disable-line new-cap
    {iv: iv},
  );
  const decryptedData = JSON.parse(bytes.toString(CryptoJS.enc.Utf8));
  return decryptedData;
});

// just a normal function to create a transaction in firestore
exports.createTransaction = functions.https.onCall(async (data) => {
  try {
    const db = admin.firestore();
    const refTransfers = db.collection("transfers").doc(data.id);
    const dataTransfers = await refTransfers.get();
    const user = db.collection("users").doc(data.userId);
    const userData = await user.get();
    if (data.status == "created") {
      data.status = "initiated";
      user.update({
        balance: (userData.data()?.balance - data.amount),
      });
      await refTransfers.set(data);
      return {
        message: "Transaction created successfully",
        status: "initiated",
      };
    }
    if (dataTransfers.data()?.status != "initiated") {
      return {
        message: "Transaction already " + dataTransfers.data()?.status,
        status: dataTransfers.data()?.status,
      };
    }
    const now = new Date();
    const created = new Date(dataTransfers.data()?.createdAt);
    const diff = now.getTime() - created.getTime();
    // in minutes
    const minutes = Math.floor(diff / 60000);
    if (minutes > 10) {
      user.update({
        balance: (userData.data()?.balance + data.amount),
      });
      await refTransfers.update({status: "expired"});
      return {
        message: "Transaction expired",
        status: "expired",
      };
    }
    if (data.status == "accepted") {
      const account = await db.collection("users")
        .where("accountNumber", "==", data.accountNumber)
        .where("sortCode", "==", data.sortCode).limit(1).get();
      if (!account.empty) {
        const accountData = account.docs[0];
        const accountUser = db.collection("users").doc(accountData.id);
        await refTransfers.update(
          {receiverId: accountData.id, status: "accepted"});
        await accountUser.update({
          balance: (accountData.data()?.balance + data.amount),
        });
      } else {
        await refTransfers.update({status: "accepted"});
      }
      return {
        message: "Transaction accepted successfully",
        status: "accepted",
      };
    }
    if (data.status == "rejected") {
      user.update({
        balance: (userData.data()?.balance + data.amount),
      });
      await refTransfers.update({status: "rejected"});
      return {
        message: "Transaction rejected successfully",
        status: "rejected",
      };
    }
    return {
      message: "Transaction status not valid",
      status: "error",
    };
  } catch (error) {
    return {
      message: "Error creating transaction =>" + error,
      status: "error",
    };
  }
});
