/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Cloud Function to set custom user claims based on roles in Firestore
exports.setCustomUserClaims = onDocumentWritten("users/{userId}", async (event) => {
  const userId = event.params.userId;


  // If the document is deleted, remove the custom claims for the user
  if (!event.data.after.exists) {
    logger.info(`Removing custom claims for user ${userId}`);
    try {
      await admin.auth().setCustomUserClaims(userId, null); // Clears custom claims
      // Revoke all refresh tokens for the user
      await admin.auth().revokeRefreshTokens(userId);
      logger.info(`Custom claims removed for user ${userId}`);
      return null;
    } catch (error) {
      logger.error(`Error removing custom claims for user ${userId}:`, error);
      return null;
    }
  }

  // Document created or updated
  const userData = event.data.after.data();
  const rolesFromDoc = userData?.roles; // Get the 'roles' map from the document

  if (!rolesFromDoc || Object.keys(rolesFromDoc).length === 0) {
    logger.info(`No roles found for user ${userId}, removing custom claims`);
    try {
      await admin.auth().setCustomUserClaims(userId, { roles: {} });
      logger.info(`Setting empty roles for user ${userId}`);
      return null;
    } catch (error) {
      logger.error(`Error removing custom claims for user ${userId}:`, error);
      return null;
    }
  }

  // Nest all roles under a 'roles' key in the custom claims
  const customClaims = { roles: rolesFromDoc };
  logger.info(`Setting custom claims for user ${userId}`, customClaims);

  try {
    await admin.auth().setCustomUserClaims(userId, customClaims);
    // Revoke all refresh tokens for the user to ensure they get the new claims
    await admin.auth().revokeRefreshTokens(userId);
    logger.info(`Custom claims set for user ${userId}`);
    return null;
  } catch (error) {
    logger.error(`Error setting custom claims for user ${userId}:`, error);
    return null;
  }
});
