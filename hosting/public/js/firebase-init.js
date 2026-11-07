// Firebase for the Mindo Kids website (Hosting + Analytics).
// The web API key is not a secret — access is controlled by Firestore/Storage rules.
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js';
import { initializeAnalytics, isSupported, logEvent } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-analytics.js';

const firebaseConfig = {
  apiKey: 'AIzaSyDgsMJo_sl8R3BUiyfwLy5KZdza4tNIrR4',
  authDomain: 'bitm-project-6f459.firebaseapp.com',
  projectId: 'bitm-project-6f459',
  storageBucket: 'bitm-project-6f459.firebasestorage.app',
  messagingSenderId: '726383361842',
  appId: '1:726383361842:web:e4fa1339491bdba448612b',
  measurementId: 'G-HQM3W5PGGX',
};

const app = initializeApp(firebaseConfig);

// Family/kids product: anonymous visit counts only — no Google Signals,
// no ad-personalisation.
isSupported()
  .then((ok) => {
    if (!ok) return;
    const analytics = initializeAnalytics(app, {
      config: { allow_google_signals: false, allow_ad_personalization_signals: false },
    });

    // Count taps on any Google Play link (hero badge, nav button, CTA, footer).
    document.addEventListener('click', (e) => {
      const a = e.target.closest('a[href*="play.google.com/store/apps"]');
      if (!a) return;
      logEvent(analytics, 'download_click', {
        location: a.closest('header, footer, section, main')?.id || a.className || 'page',
        page: location.pathname,
      });
    });
  })
  .catch(() => {});
