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
            title: "New Workout",
            body: "New workout loaded",
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
