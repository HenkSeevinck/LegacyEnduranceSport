/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * Send notification to athlete when a new workout is loaded
 * Triggers when a new document is created in LoadedWorkouts collection
 */
exports.notifyAthleteWorkoutLoaded = onDocumentCreated(
  "LoadedWorkouts/{docId}",
  async (event) => {
    try {
      const loadedWorkout = event.data.data();
      const athleteUID = loadedWorkout.athleteUID;

      if (!athleteUID) {
        logger.warn("No athleteUID found in LoadedWorkout document");
        return;
      }

      // Fetch the athlete's FCM tokens from AppUsers/{athleteUID}
      const appUserDoc = await admin
        .firestore()
        .collection("AppUsers")
        .doc(athleteUID)
        .get();

      if (!appUserDoc.exists) {
        logger.warn(`AppUser document not found for athlete ${athleteUID}`);
        return;
      }

      const fcmTokens = appUserDoc.data()?.fcmTokens;

      if (!Array.isArray(fcmTokens) || fcmTokens.length === 0) {
        logger.warn(`No FCM tokens found for athlete ${athleteUID}`);
        return;
      }

      // Send notification to all FCM tokens (all devices)
      const sendPromises = fcmTokens.map(async (tokenObj) => {
        const token = tokenObj.token;
        if (!token) {
          logger.warn(`Empty FCM token found for athlete ${athleteUID}`);
          return null;
        }

        const message = {
          notification: {
            title: "Time to Move! 🏃‍♂️",
            body: "Your new workout is ready. Tap to see the details and get started!",
            image: "https://firebasestorage.googleapis.com/v0/b/legacyendurancesport.firebasestorage.app/o/logos%2Ffavicon.png?alt=media&token=75944005-8223-4fd5-b661-02b8eef52113"
          },
          token: token,
        };

        try {
          const response = await admin.messaging().send(message);
          logger.info(`Notification sent to athlete ${athleteUID} on device ${tokenObj.device}:`, response);
          return response;
        } catch (error) {
          logger.warn(`Failed to send notification to device ${tokenObj.device} for athlete ${athleteUID}:`, error);
          return null;
        }
      });

      await Promise.all(sendPromises);
    } catch (error) {
      logger.error("Error sending notification:", error);
      throw error;
    }
  }
);

/**
 * When a new AppUsers document is created, generate a unique 5-character
 * alphanumeric referral code and atomically claim it by creating a document
 * in `ReferralCodes/{code}`. This prevents race conditions under concurrency.
 */
exports.assignReferralCodeOnSignup = onDocumentCreated(
  "AppUsers/{docId}",
  async (event) => {
    try {
      const userDoc = event.data.data();
      const userUid = (userDoc && userDoc.uid) ? userDoc.uid : (event.data && event.data.ref ? event.data.ref.id : null);

      if (!userUid) {
        logger.warn('AppUsers document created but no UID found; skipping referral assignment.');
        return;
      }

      // If the client already provided a referralCode, respect it and do nothing.
      if (userDoc && userDoc.referralCode) {
        logger.info(`User ${userUid} already has referralCode; skipping server assignment.`);
        return;
      }

      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // avoid I,O,1,0
      const maxAttempts = 8;
      const db = admin.firestore();

      function generateCode() {
        let out = '';
        for (let i = 0; i < 5; i++) {
          out += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return out;
      }

      for (let attempt = 0; attempt < maxAttempts; attempt++) {
        const code = generateCode();
        const codeRef = db.collection('ReferralCodes').doc(code);
        const userRef = db.collection('AppUsers').doc(userUid);

        try {
          await db.runTransaction(async (tx) => {
            const codeSnap = await tx.get(codeRef);
            if (codeSnap.exists) {
              throw new Error('code-exists');
            }
            tx.set(codeRef, { uid: userUid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
            tx.update(userRef, { referralCode: code });
          });
          logger.info(`Assigned referral code ${code} to user ${userUid}`);
          return; // success
        } catch (err) {
          if (err.message === 'code-exists') {
            // collision: try again
            logger.warn(`Referral code collision for ${code}, retrying...`);
            continue;
          }
          // Other errors: rethrow
          throw err;
        }
      }

      // Fallback: use a timestamp-derived code (last 5 chars)
      const fallback = Date.now().toString();
      const fallbackCode = fallback.substring(fallback.length - 5);
      await db.collection('ReferralCodes').doc(fallbackCode).set({ uid: userUid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
      await db.collection('AppUsers').doc(userUid).update({ referralCode: fallbackCode });
      logger.info(`Assigned fallback referral code ${fallbackCode} to user ${userUid}`);

    } catch (error) {
      logger.error('Error assigning referral code:', error);
      throw error;
    }
  }
);
