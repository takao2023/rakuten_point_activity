import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { vapidKey: String }
  static targets = ["button"]

  connect() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      if (this.hasButtonTarget) {
        this.buttonTarget.disabled = true;
        this.buttonTarget.textContent = 'Chrome等対応ブラウザをご利用ください';
      }
      return;
    }

    navigator.serviceWorker.register('/serviceworker.js')
      .then(registration => {
        console.log('ServiceWorker registered with scope:', registration.scope);
      })
      .catch(error => {
        console.warn('ServiceWorker registration failed:', error);
      });
  }

  async subscribe(event) {
    event.preventDefault();
    try {
      // ユーザーへプッシュ許可ダイアログを出す
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        alert('プッシュ通知がブロックされているか、拒否されました。プッシュを受け取るにはブラウザの設定から許可してください。');
        return;
      }

      // 許可された場合、PushManagerでVAPIDキーを用いて購読処理
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidKeyValue)
      });

      // DB(controller)へ投げる
      const response = await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
          subscription: subscription.toJSON()
        })
      });

      if (response.ok) {
        if (this.hasButtonTarget) {
          this.buttonTarget.textContent = '✔ 通知がブラウザに届きます';
          this.buttonTarget.classList.remove('btn-outline-info');
          this.buttonTarget.classList.add('btn-info', 'text-white');
          this.buttonTarget.disabled = true;
        }
        alert('ブラウザでの通知設定が完了しました！');
      } else {
        throw new Error('サーバーでの保存に失敗しました');
      }
    } catch (error) {
      console.error('Push Subscription failed:', error);
      alert('エラーが発生しました。時間を置いて再度お試しください。');
    }
  }

  // base64 エンコードされた VAPID公開鍵 をバイナリ配列に復元するユーティリティ
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }
}
