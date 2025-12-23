const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendMessageNotification = functions.firestore
  .document("messages/{messageId}")
  .onCreate(async (snap) => {
    const message = snap.data();
    const chatId = message.chatId;
    const senderId = message.senderId;

    const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return null;

    const members = chatDoc.data().members;

    const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Mensaje";

    const tokens = [];

    for (const uid of members) {
      if (uid === senderId) continue;
      const userDoc = await admin.firestore().collection("users").doc(uid).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        tokens.push(userDoc.data().fcmToken);
      }
    }

    if (tokens.length === 0) return null;

    await admin.messaging().sendToDevice(tokens, {
      notification: {
        title: senderName,
        body: message.text ? message.text : "📷 Imagen",
      },
      data: {
        chatId: chatId,
      },
    });

    return null;
  });
