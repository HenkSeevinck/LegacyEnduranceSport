importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
firebase.initializeApp({
  apiKey: 'AIzaSyCh_wrXHlO1vUcnK_782F873LBDIdnypj0',
  authDomain: 'legacyendurancesport.firebaseapp.com',
  projectId: 'legacyendurancesport',
  storageBucket: 'legacyendurancesport.firebasestorage.app',
  messagingSenderId: '897385819686',
  appId: '1:897385819686:web:a95808a87c6664eb7340e7',
  measurementId: 'G-HK26J2B2DP'
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    tag: payload.data?.tag || 'default',
    requireInteraction: false,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('Notification clicked:', event);
  event.notification.close();

  // Open the app or focus existing window
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        // If app is already open, focus it
        for (let i = 0; i < clientList.length; i++) {
          const client = clientList[i];
          if (client.url === '/' && 'focus' in client) {
            return client.focus();
          }
        }
        // Otherwise open new window
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      })
  );
});
