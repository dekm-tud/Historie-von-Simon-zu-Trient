
(function () {
  // ----- Expansion toogle -----
  const btnExpansion = document.getElementById('btn-expansion');
  function setExpansion(on) {
    document.body.classList.remove('mode-expan', 'mode-abbr');
    document.body.classList.add(on ? 'mode-expan' : 'mode-abbr');
    btnExpansion?.setAttribute('aria-pressed', String(on));
  }
  setExpansion(document.body.classList.contains('mode-expan'));
  btnExpansion?.addEventListener('click', () => {
    const next = !document.body.classList.contains('mode-expan');
    setExpansion(next);
  });

  // ----- Lesefassung toogle -----
  const btnReading = document.getElementById('btn-reading');
  function setReading(on) {
    document.body.classList.remove('layout-reading', 'layout-original');
    document.body.classList.add(on ? 'layout-reading' : 'layout-original');
    btnReading?.setAttribute('aria-pressed', String(on));
  }
  setReading(document.body.classList.contains('layout-reading'));
  btnReading?.addEventListener('click', () => {
    const next = !document.body.classList.contains('layout-reading');
    setReading(next);
  });

  // ----- Normalisierung toogle -----
  const btnNorm = document.getElementById('btn-normalize');
  let normalizeOn = false;

  function applyNormalization(state, scope=document) {
    scope.querySelectorAll('.glyph').forEach(g => {
      if (!g.dataset.orig) g.dataset.orig = g.textContent;
      const norm = g.getAttribute('data-norm');
      if (state && norm) {
        g.textContent = norm;
        g.classList.add('is-normalized');
      } else {
        g.textContent = g.dataset.orig || g.textContent;
        g.classList.remove('is-normalized');
      }
    });
  }
  function setNormalize(state) {
    normalizeOn = state;
    document.body.classList.toggle('norm-on', state); // <-- drives sic/corr CSS
    applyNormalization(state, document.getElementById('text-body') || document);
    btnNorm?.setAttribute('aria-pressed', String(state));
  }
  setNormalize(false);
  btnNorm?.addEventListener('click', () => setNormalize(!normalizeOn));

  // ----- Mirador init -----
  const manifestUri = document.getElementById('mirador')?.getAttribute('data-manifest')
    || document.documentElement.getAttribute('data-manifest')
    || 'https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00027835/manifest';

  const miradorConfig = {
    id: 'mirador',
    windows: [{ loadedManifest: manifestUri, canvasIndex: 0 }],
    window: {
      defaultView: 'single',
      views: [{ key: 'single', behaviors: ['individuals'] }, { key: 'book' }],
    },
    workspaceControlPanel: { enabled: false },
    theme: { palette: { type: 'dark' } },
  };
  window.miradorInstance = Mirador.viewer(miradorConfig);
  const actions = Mirador.actions;
  const store   = window.miradorInstance.store;

  // ----- Click-to-change -----
  function getWindowId() {
    const st  = store.getState();
    const ids = Object.keys(st.windows || {});
    return ids.length ? ids[0] : null;
  }
  function getCanvasIdByIndex(idx) {
    const st = store.getState();
    const winId = getWindowId();
    if (!winId) return null;
    const win = st.windows[winId] || {};
    const manifestId = win.manifestId || win.loadedManifest;
    const manifest = st.manifests?.[manifestId]?.json;
    const canvases = manifest?.sequences?.[0]?.canvases;
    if (!Array.isArray(canvases) || !canvases[idx]) return null;
    return canvases[idx]['@id'] || canvases[idx].id || null;
  }
  function activatePb(pbEl) {
    document.querySelectorAll('.pb').forEach(n => n.classList.remove('active-pb'));
    pbEl.classList.add('active-pb');
    const idx   = parseInt(pbEl.getAttribute('data-canvas-index'), 10) || 0;
    const winId = getWindowId();
    if (!winId) return;
    if (actions?.updateWindow) { store.dispatch(actions.updateWindow(winId, { canvasIndex: idx })); }
    const canvasId = getCanvasIdByIndex(idx);
    if (canvasId && actions?.setCanvas) { store.dispatch(actions.setCanvas(winId, canvasId)); }
  }
  document.addEventListener('click', (ev) => {
    const pb = ev.target.closest('.pb[data-canvas-index]');
    if (pb) activatePb(pb);
  });
  document.addEventListener('keydown', (ev) => {
    if (ev.key !== 'Enter' && ev.key !== ' ') return;
    const pb = ev.target.closest('.pb[data-canvas-index]');
    if (pb) { ev.preventDefault(); activatePb(pb); }
  });

  // ----- Auto scroll toggle -----
  const rootEl  = document.getElementById('text-body') || null;
  const btnSync = document.getElementById('btn-sync');
  let autoSyncOn = true;
  let io = null;

  function createObserver() {
    if (!rootEl || io) return;
    io = new IntersectionObserver((entries) => {
      if (!autoSyncOn) return;
      const visible = entries.filter(e => e.isIntersecting)
        .sort((a, b) => Math.abs(a.boundingClientRect.top) - Math.abs(b.boundingClientRect.top));
      if (!visible.length) return;
      const el  = visible[0].target;
      const idx = parseInt(el.getAttribute('data-canvas-index'), 10) || 0;
      document.querySelectorAll('.pb').forEach(n => n.classList.remove('active-pb'));
      el.classList.add('active-pb');
      const winId = getWindowId();
      if (!winId) return;
      const canvasId = getCanvasIdByIndex(idx);
      if (actions?.setCanvas && canvasId) {
        store.dispatch(actions.setCanvas(winId, canvasId));
      } else if (actions?.updateWindow) {
        store.dispatch(actions.updateWindow(winId, { canvasIndex: idx }));
      }
    }, { root: rootEl, rootMargin: '0px 0px -70% 0px', threshold: 0 });
    document.querySelectorAll('.pb[data-canvas-index]').forEach(pb => io.observe(pb));
  }
  function destroyObserver() { if (!io) return; io.disconnect(); io = null; }
  function setAutoSync(state) {
    autoSyncOn = state;
    btnSync?.setAttribute('aria-pressed', String(state));
    if (state) { createObserver(); }
    else {
      destroyObserver();
      document.querySelectorAll('.pb').forEach(n => n.classList.remove('active-pb'));
    }
  }
  if (rootEl) setAutoSync(true);
  btnSync?.addEventListener('click', () => setAutoSync(!autoSyncOn));
})();

// ----- Outer width resize (drag left/right outer edges) -----
(function(){
  const grid = document.querySelector('.edition-grid');
  const leftHandle  = document.getElementById('outer-left');
  const rightHandle = document.getElementById('outer-right');
  if (!grid || !leftHandle || !rightHandle) return;

  const MIN = 700;                          // minimal grid width in px
  const MAX = () => Math.max(700, window.innerWidth - 16); // safety cap

  function getMainWidth() {
    const v = getComputedStyle(document.documentElement).getPropertyValue('--main-width').trim();
    // v might be "1200px" or "96vw" resolved; try to parse px
    const px = grid.getBoundingClientRect().width; // robust actual px width
    return Math.max(MIN, Math.round(px));
  }

  function setMainWidth(px) {
    const clamped = Math.max(MIN, Math.min(MAX(), Math.round(px)));
    document.documentElement.style.setProperty('--main-width', clamped + 'px');
    try { localStorage.setItem('editionMainWidthPx', String(clamped)); } catch(_) {}
  }

  // Init from storage
  try {
    const saved = parseInt(localStorage.getItem('editionMainWidthPx'), 10);
    if (!Number.isNaN(saved)) setMainWidth(saved);
  } catch(_) {}

  function startDrag(which, startX) {
    const startW = getMainWidth();
    function onMove(e) {
      const dx = e.clientX - startX;
      const next = which === 'left' ? (startW - dx) : (startW + dx);
      setMainWidth(next);
      e.preventDefault();
    }
    function onUp(e) {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
    }
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup',   onUp);
  }

  leftHandle.addEventListener('pointerdown',  (e) => { e.preventDefault(); startDrag('left',  e.clientX); });
  rightHandle.addEventListener('pointerdown', (e) => { e.preventDefault(); startDrag('right', e.clientX); });

  // Keyboard for accessibility
  function keyResize(which, e) {
    const step = e.shiftKey ? 50 : 10;
    const cur  = getMainWidth();
    if (which === 'left') {
      if (e.key === 'ArrowLeft')  { setMainWidth(cur + step); e.preventDefault(); }
      if (e.key === 'ArrowRight') { setMainWidth(cur - step); e.preventDefault(); }
    } else {
      if (e.key === 'ArrowLeft')  { setMainWidth(cur - step); e.preventDefault(); }
      if (e.key === 'ArrowRight') { setMainWidth(cur + step); e.preventDefault(); }
    }
    if (e.key === 'Home') { setMainWidth(MIN); e.preventDefault(); }
    if (e.key === 'End')  { setMainWidth(MAX()); e.preventDefault(); }
  }
  leftHandle.addEventListener('keydown',  (e) => keyResize('left',  e));
  rightHandle.addEventListener('keydown', (e) => keyResize('right', e));

  // Re-clamp on resize to avoid overshooting viewport after window gets smaller
  window.addEventListener('resize', () => setMainWidth(getMainWidth()));
})();


      