/**
 * Nawa Cloud Functions — a deliberately small proof-of-concept.
 *
 * Two Firestore-triggered functions only:
 *   1. onLoginEvent          -> sends a "welcome back" push on login.
 *   2. onExplorationCompleted -> sends a "great job" push when a child
 *                                 completes an experience.
 *
 * The Flutter app never sends notifications itself — it only writes the
 * Firestore documents these functions react to.
 */

const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Mirrors the stable category ids in lib/features/interests/domain/interest_category.dart —
// the notification body can't use the app's localized labels (this runs
// server-side), so it uses the same plain English names already used
// elsewhere as the non-localized fallback.
const CATEGORY_LABELS = {
  gaming: "Gaming",
  sports: "Sports",
  art: "Art & Drawing",
  technology: "Technology",
  science: "Science & Discovery",
};

/**
 * Sends `notification` to every FCM token registered for `uid`
 * (users/{uid}/fcmTokens). A parent can have multiple devices, so this
 * always sends to all of them. Best-effort cleanup: tokens the platform
 * reports as dead/unregistered are removed so the list doesn't grow
 * unboundedly with stale devices.
 */
async function sendToUser(uid, notification) {
  const db = getFirestore();
  const tokensSnapshot = await db.collection("users").doc(uid).collection("fcmTokens").get();
  const tokens = tokensSnapshot.docs.map((doc) => doc.id).filter(Boolean);
  if (tokens.length === 0) return;

  const response = await getMessaging().sendEachForMulticast({tokens, notification});

  const staleTokens = [];
  response.responses.forEach((result, index) => {
    if (result.success) return;
    const code = result.error && result.error.code;
    if (code === "messaging/registration-token-not-registered" || code === "messaging/invalid-registration-token") {
      staleTokens.push(tokens[index]);
    }
  });
  await Promise.all(
    staleTokens.map((token) => db.collection("users").doc(uid).collection("fcmTokens").doc(token).delete())
  );
}

// 1. LOGIN NOTIFICATION
// Triggered by AuthController.login() writing exactly one event document
// per successful login — never by an auth-state listener, so this fires
// exactly once per real login.
exports.onLoginEvent = onDocumentCreated("users/{uid}/notificationEvents/{eventId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const data = snapshot.data();
  if (!data || data.type !== "login") return;

  await sendToUser(event.params.uid, {
    title: "Welcome back 👋",
    body: "Welcome back to Nawa!",
  });
});

// 2. EXPERIENCE COMPLETION NOTIFICATION
// Triggered on every write to an exploration document. Fires on the
// initial (incomplete) create too, but exits immediately since
// completed !== true then. Idempotent via the `notificationSent` flag
// (Option A) so re-triggering on a later update to the same completed
// document never sends a second notification.
exports.onExplorationCompleted = onDocumentWritten(
  "users/{uid}/children/{childId}/explorations/{explorationId}",
  async (event) => {
    const after = event.data && event.data.after;
    if (!after || !after.exists) return;

    const afterData = after.data();
    if (!afterData || afterData.completed !== true) return;
    if (afterData.notificationSent === true) return;

    const categoryLabel = CATEGORY_LABELS[afterData.categoryId] || "a new category";

    await sendToUser(event.params.uid, {
      title: "Great job! 🎉",
      body: `You completed a new experience in ${categoryLabel}.`,
    });

    await after.ref.set({notificationSent: true}, {merge: true});
  }
);
