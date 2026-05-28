/* coi-serviceworker v0.1.7 — github.com/gzuidhof/coi-serviceworker
 * Adds Cross-Origin-Opener-Policy and Cross-Origin-Embedder-Policy headers
 * so SharedArrayBuffer works on GitHub Pages (required by Godot 4 web export).
 */
if (typeof window === 'undefined') {
  /* ── Service worker scope ── */
  self.addEventListener('install', () => self.skipWaiting());
  self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));
  self.addEventListener('fetch', function (event) {
    if (event.request.cache === 'only-if-cached' && event.request.mode !== 'same-origin') return;
    event.respondWith(
      fetch(event.request).then(function (response) {
        if (response.status === 0) return response;
        const headers = new Headers(response.headers);
        headers.set('Cross-Origin-Opener-Policy', 'same-origin');
        headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
        headers.set('Cross-Origin-Resource-Policy', 'cross-origin');
        return new Response(response.body, {
          status: response.status,
          statusText: response.statusText,
          headers,
        });
      })
    );
  });
} else {
  /* ── Client scope ── */
  if (!window.crossOriginIsolated) {
    navigator.serviceWorker
      .register(window.document.currentScript.src)
      .then(reg => reg.addEventListener('updatefound', () => window.location.reload()));
    if (!navigator.serviceWorker.controller) {
      window.location.reload();
    }
  }
}
