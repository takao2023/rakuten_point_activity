self.addEventListener('push', function(event) {
  let title = '楽天ポイ活のお知らせ';
  let body = 'ポイ活のタスクが残っています！';
  // PWA/Web Push 用のプレースホルダーアイコン
  let icon = 'https://cdn-icons-png.flaticon.com/512/3665/3665961.png';

  if (event.data) {
    try {
      const payload = event.data.json();
      title = payload.title || title;
      body = payload.body || body;
    } catch (e) {
      body = event.data.text();
    }
  }

  event.waitUntil(
    self.registration.showNotification(title, {
      body: body,
      icon: icon,
      vibrate: [200, 100, 200, 100, 200, 100, 200],
      tag: 'rakuten-point-remind'
    })
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(windowClients) {
      // 既にアプリのタブが開いていればフォーカスする
      for (let i = 0; i < windowClients.length; i++) {
        let client = windowClients[i];
        if (client.url.includes(self.registration.scope) && 'focus' in client) {
          return client.focus();
        }
      }
      // なければトップページを新しく開く
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
