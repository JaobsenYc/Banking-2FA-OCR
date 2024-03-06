import * as functions from "firebase-functions";
//import * as CryptoJS from "crypto-js";

// TODO : REMOOVE THIS KEYS FROM HERE
// secretKey : W2U5fiDQL4G59vsKjlVfiQglPWr0hWe7
// hmac_key : b2341989afb992ad2af2be3fabe16ab2ce65dfe1917725ef8cfb4c92f5878f6e
/* const secretKey = functions.config().crypto.key;
const secretKeyForHMAC = functions.config().crypto.hmac_key; */

exports.encrypt = functions.https.onCall((data, context) => {
  return {text: `Hello from Firebase, ${data.name}`};
});
// Function to "mimic" AES-GCM encryption
//exports.encrypt = functions.https.onCall((data, context) => {
/*   const jsonData = data;
  const iv = CryptoJS.lib.WordArray.random(128 / 8);
  const ciphertext = CryptoJS.AES.encrypt(
    JSON.stringify(jsonData),
    CryptoJS.enc.Hex.parse(secretKey),
    { iv: iv },
  ).toString();
  const hmac = CryptoJS.HmacSHA256(
    CryptoJS.lib.WordArray.random(128 / 8),
    CryptoJS.enc.Hex.parse(secretKeyForHMAC),
  ).toString();
  const encryptedData = hmac + CryptoJS.enc.Hex.stringify(iv) + ciphertext;
  return encryptedData; */
//});

// Function to "mimic" AES-GCM decryption
//exports.decrypt = functions.https.onCall((data, context) => {
/*   const hmacPlusIvPlusCiphertext = data;
  const hmac = hmacPlusIvPlusCiphertext.substr(0, 64);
  const iv = CryptoJS.enc.Hex.parse(hmacPlusIvPlusCiphertext.substr(64, 32));
  const ciphertext = hmacPlusIvPlusCiphertext.substr(96);
  const currentHmac = CryptoJS.HmacSHA256(
    iv.concat(CryptoJS.enc.Base64.parse(ciphertext)),
    CryptoJS.enc.Hex.parse(secretKeyForHMAC),
  ).toString();

  if (currentHmac !== hmac) {
    return "Integrity check failed";
  }

  const bytes = CryptoJS.AES.decrypt(
    ciphertext,
    CryptoJS.enc.Hex.parse(secretKey),
    { iv: iv },
  );
  const decryptedData = JSON.parse(bytes.toString(CryptoJS.enc.Utf8));
  return decryptedData; */
//});
