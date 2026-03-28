importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js"
);

const firebaseConfig = {
  apiKey: "AIzaSyAizp2ZGAAQxGfq4KMDWB3y8clHk9N5sfw",
  authDomain: "playcrypto365app.firebaseapp.com",
  projectId: "playcrypto365app",
  storageBucket: "playcrypto365app.firebasestorage.app",
  messagingSenderId: "827793044377",
  appId: "1:827793044377:web:46059e79b8dcb44e695908",
  measurementId: "G-V3SJWTFTSM"
};

firebase.initializeApp(firebaseConfig);
// Necessary to receive background messages:
const messaging = firebase.messaging();

messaging.onBackgroundMessage(messaging, ({ notification: notification }) => {
  const { title, body, image } = notification ?? {};

  if (!title) {
    return;
  }

  self.registration.showNotification(title, {
    body,
    icon: image || "/assets/icons/icon-192.png",
  });
});
