
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'ISI_API_KEY',
  authDomain: 'ISI_AUTH_DOMAIN',
  projectId: 'ISI_PROJECT_ID',
  storageBucket: 'ISI_STORAGE_BUCKET',
  messagingSenderId: 'ISI_MESSAGING_SENDER_ID',
  appId: 'ISI_APP_ID',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Pesan diterima saat background:', payload);

  const notificationTitle =
    payload.notification?.title || 'Learning Dashboard';

  const notificationOptions = {
    body: payload.notification?.body || 'Ada notifikasi baru.',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
