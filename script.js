/* Hide loading overlay once the iframe loads */
const frame = document.getElementById('game-frame');
const loading = document.getElementById('game-loading');

if (frame && loading) {
  frame.addEventListener('load', () => {
    setTimeout(() => loading.classList.add('hidden'), 600);
  });
}

/* Fullscreen button */
const fsBtn = document.getElementById('fullscreen-btn');
const wrap  = document.querySelector('.game-frame-wrap');

if (fsBtn && wrap) {
  fsBtn.addEventListener('click', () => {
    const el = wrap;
    if (!document.fullscreenElement) {
      el.requestFullscreen().catch(() => {});
    } else {
      document.exitFullscreen();
    }
  });

  document.addEventListener('fullscreenchange', () => {
    fsBtn.textContent = document.fullscreenElement ? '✖ Exit Fullscreen' : '⛶ Fullscreen';
  });
}
