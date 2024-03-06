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

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
// TODO : REMOOVE THIS KEYS FROM HERE
// secretKey : W2U5fiDQL4G59vsKjlVfiQglPWr0hWe7
// hmac_key : b2341989afb992ad2af2be3fabe16ab2ce65dfe1917725ef8cfb4c92f5878f6e
const secretKey = functions.config().crypto.key;
const secretKeyForHMAC = functions.config().crypto.hmac_key;

exports.encryptData = functions.https.onCall((data) => {
  // Function to "mimic" AES-GCM encryption
  const jsonData = data;
  const iv = CryptoJS.lib.WordArray.random(128 / 8);
  const ciphertext = CryptoJS.AES.encrypt(
    JSON.stringify(jsonData),
    CryptoJS.enc.Hex.parse(secretKey), // eslint-disable-line new-cap
    {iv: iv},
  ).toString(); // eslint-disable-line new-cap
  const hmac = CryptoJS.HmacSHA256( // eslint-disable-line new-cap
    CryptoJS.lib.WordArray.random(128 / 8), // eslint-disable-line new-cap
    CryptoJS.enc.Hex.parse(secretKeyForHMAC), // eslint-disable-line new-cap
  ).toString(); // eslint-disable-line new-cap
  const encryptedData = hmac + CryptoJS.enc.Hex.stringify(iv) + ciphertext;
  return encryptedData;
});

exports.decryptData = functions.https.onCall((data) => {
  const hmacPlusIvPlusCiphertext = data;
  const hmac = hmacPlusIvPlusCiphertext.substr(0, 64);
  const iv = CryptoJS.enc.Hex.parse(hmacPlusIvPlusCiphertext.substr(64, 32));
  const ciphertext = hmacPlusIvPlusCiphertext.substr(96);
  const currentHmac = CryptoJS.HmacSHA256( // eslint-disable-line new-cap
    iv.concat(CryptoJS.enc.Base64.parse(ciphertext)),
    CryptoJS.enc.Hex.parse(secretKeyForHMAC),
  ).toString();

  if (currentHmac !== hmac) {
    return "Integrity check failed";
  }

  const bytes = CryptoJS.AES.decrypt( // eslint-disable-line new-cap
    ciphertext,
    CryptoJS.enc.Hex.parse(secretKey), // eslint-disable-line new-cap
    {iv: iv},
  );
  const decryptedData = JSON.parse(
    bytes.toString(CryptoJS.enc.Utf8)); // eslint-disable-line new-cap
  return decryptedData;
});
