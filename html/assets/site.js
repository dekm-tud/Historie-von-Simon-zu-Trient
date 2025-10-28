(function () {
  // ----- Expansion (mode-expan / mode-abbr) -----
  const btnExpansion = document.getElementById("btn-expansion");
  function setExpansion(on) {
    document.body.classList.remove("mode-expan", "mode-abbr");
    document.body.classList.add(on ? "mode-expan" : "mode-abbr");
    btnExpansion?.setAttribute("aria-pressed", String(on));
  }
  setExpansion(document.body.classList.contains("mode-expan"));
  btnExpansion?.addEventListener("click", () => {
    const next = !document.body.classList.contains("mode-expan");
    setExpansion(next);
  });

  // ----- Lesefassung (layout-reading / layout-original) -----
  const btnReading = document.getElementById("btn-reading");
  function setReading(on) {
    document.body.classList.remove("layout-reading", "layout-original");
    document.body.classList.add(on ? "layout-reading" : "layout-original");
    btnReading?.setAttribute("aria-pressed", String(on));
  }
  setReading(document.body.classList.contains("layout-reading"));
  btnReading?.addEventListener("click", () => {
    const next = !document.body.classList.contains("layout-reading");
    setReading(next);
  });

  // ----- Normalisierung (glyph toggle) -----
  const btnNorm = document.getElementById("btn-normalize");
  let normalizeOn = false;

  function applyNormalization(state, scope = document) {
    scope.querySelectorAll(".glyph").forEach((g) => {
      if (!g.dataset.orig) g.dataset.orig = g.textContent;
      const norm = g.getAttribute("data-norm");
      if (state && norm) {
        g.textContent = norm;
        g.classList.add("is-normalized");
      } else {
        g.textContent = g.dataset.orig || g.textContent;
        g.classList.remove("is-normalized");
      }
    });
  }
  function setNormalize(state) {
    normalizeOn = state;
    document.body.classList.toggle("norm-on", state);
    applyNormalization(state, document.getElementById("text-body") || document);
    btnNorm?.setAttribute("aria-pressed", String(state));
  }
  setNormalize(false);
  btnNorm?.addEventListener("click", () => setNormalize(!normalizeOn));
})();

// ----- Mirador init -----
(function () {
  const miradorEl = document.getElementById("mirador");
  if (!miradorEl || !window.Mirador) {
    // Mirador ggf. überspringen
    return;
  }

  const manifestUri =
    miradorEl.getAttribute("data-manifest") ||
    document.documentElement.getAttribute("data-manifest") ||
    "https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00027835/manifest";

  try {
    const miradorConfig = {
      id: "mirador",
      windows: [{ loadedManifest: manifestUri, canvasIndex: 0 }],
      window: {
        defaultView: "single",
        views: [{ key: "single", behaviors: ["individuals"] }, { key: "book" }],
      },
      workspaceControlPanel: { enabled: false },
      theme: { palette: { type: "dark" } },
    };
    window.miradorInstance = Mirador.viewer(miradorConfig);
    const actions = Mirador.actions;
    const store = window.miradorInstance.store;

    // Nur wenn Mirador existiert, auch Scroll/Click-Sync aktivieren:
    function getWindowId() {
      const st = store.getState();
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
      return canvases[idx]["@id"] || canvases[idx].id || null;
    }
    function activatePb(pbEl) {
      document
        .querySelectorAll(".pb")
        .forEach((n) => n.classList.remove("active-pb"));
      pbEl.classList.add("active-pb");
      const idx = parseInt(pbEl.getAttribute("data-canvas-index"), 10) || 0;
      const winId = getWindowId();
      if (!winId) return;
      if (actions?.updateWindow) {
        store.dispatch(actions.updateWindow(winId, { canvasIndex: idx }));
      }
      const canvasId = getCanvasIdByIndex(idx);
      if (canvasId && actions?.setCanvas) {
        store.dispatch(actions.setCanvas(winId, canvasId));
      }
    }
    document.addEventListener("click", (ev) => {
      const pb = ev.target.closest(".pb[data-canvas-index]");
      if (pb) activatePb(pb);
    });
    document.addEventListener("keydown", (ev) => {
      if (ev.key !== "Enter" && ev.key !== " ") return;
      const pb = ev.target.closest(".pb[data-canvas-index]");
      if (pb) {
        ev.preventDefault();
        activatePb(pb);
      }
    });

    // Auto-Scroll-Sync nur aktivieren, wenn es das Layout gibt:
    const rootEl = document.getElementById("text-body") || null;
    const btnSync = document.getElementById("btn-sync");
    let autoSyncOn = true;
    let io = null;
    function createObserver() {
      if (!rootEl || io) return;
      io = new IntersectionObserver(
        (entries) => {
          if (!autoSyncOn) return;
          const visible = entries
            .filter((e) => e.isIntersecting)
            .sort(
              (a, b) =>
                Math.abs(a.boundingClientRect.top) -
                Math.abs(b.boundingClientRect.top)
            );
          if (!visible.length) return;
          const el = visible[0].target;
          const idx = parseInt(el.getAttribute("data-canvas-index"), 10) || 0;
          document
            .querySelectorAll(".pb")
            .forEach((n) => n.classList.remove("active-pb"));
          el.classList.add("active-pb");
          const winId = getWindowId();
          if (!winId) return;
          const canvasId = getCanvasIdByIndex(idx);
          if (actions?.setCanvas && canvasId) {
            store.dispatch(actions.setCanvas(winId, canvasId));
          } else if (actions?.updateWindow) {
            store.dispatch(actions.updateWindow(winId, { canvasIndex: idx }));
          }
        },
        { root: rootEl, rootMargin: "0px 0px -70% 0px", threshold: 0 }
      );
      document
        .querySelectorAll(".pb[data-canvas-index]")
        .forEach((pb) => io.observe(pb));
    }
    function destroyObserver() {
      if (!io) return;
      io.disconnect();
      io = null;
    }
    function setAutoSync(state) {
      autoSyncOn = state;
      btnSync?.setAttribute("aria-pressed", String(state));
      if (state) {
        createObserver();
      } else {
        destroyObserver();
        document
          .querySelectorAll(".pb")
          .forEach((n) => n.classList.remove("active-pb"));
      }
    }
    if (rootEl) setAutoSync(true);
    btnSync?.addEventListener("click", () => setAutoSync(!autoSyncOn));
  } catch (e) {
    console.warn("Mirador init übersprungen:", e);
  }
})();

(function () {
  const grid = document.querySelector(".edition-grid");
  const leftHandle = document.getElementById("outer-left");
  const rightHandle = document.getElementById("outer-right");
  if (!grid || !leftHandle || !rightHandle) return;

  const MIN = 700;
  const MAX = () => Math.max(700, window.innerWidth - 16);

  function getMainWidth() {
    const px = grid.getBoundingClientRect().width;
    return Math.max(MIN, Math.round(px));
  }

  function setMainWidth(px) {
    const clamped = Math.max(MIN, Math.min(MAX(), Math.round(px)));
    document.documentElement.style.setProperty("--main-width", clamped + "px");
    try {
      localStorage.setItem("editionMainWidthPx", String(clamped));
    } catch (_) {}
  }

  try {
    const saved = parseInt(localStorage.getItem("editionMainWidthPx"), 10);
    if (!Number.isNaN(saved)) setMainWidth(saved);
  } catch (_) {}

  function startDrag(which, startX) {
    const startW = getMainWidth();
    function onMove(e) {
      const dx = e.clientX - startX;
      const next = which === "left" ? startW - dx : startW + dx;
      setMainWidth(next);
      e.preventDefault();
    }
    function onUp() {
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerup", onUp);
    }
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp);
  }

  leftHandle.addEventListener("pointerdown", (e) => {
    e.preventDefault();
    startDrag("left", e.clientX);
  });
  rightHandle.addEventListener("pointerdown", (e) => {
    e.preventDefault();
    startDrag("right", e.clientX);
  });

  function keyResize(which, e) {
    const step = e.shiftKey ? 50 : 10;
    const cur = getMainWidth();
    if (which === "left") {
      if (e.key === "ArrowLeft") {
        setMainWidth(cur + step);
        e.preventDefault();
      }
      if (e.key === "ArrowRight") {
        setMainWidth(cur - step);
        e.preventDefault();
      }
    } else {
      if (e.key === "ArrowLeft") {
        setMainWidth(cur - step);
        e.preventDefault();
      }
      if (e.key === "ArrowRight") {
        setMainWidth(cur + step);
        e.preventDefault();
      }
    }
    if (e.key === "Home") {
      setMainWidth(MIN);
      e.preventDefault();
    }
    if (e.key === "End") {
      setMainWidth(MAX());
      e.preventDefault();
    }
  }
  leftHandle.addEventListener("keydown", (e) => keyResize("left", e));
  rightHandle.addEventListener("keydown", (e) => keyResize("right", e));

  window.addEventListener("resize", () => setMainWidth(getMainWidth()));
})();

// ----- Leaflet Map init -----
(function () {
  const MAP_ID = "map";
  const ATTR = "© OpenStreetMap";

  const TILE_URL = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

  const PLACES = {
    type: "FeatureCollection",
    features: [
      {
        type: "Feature",
        properties: {
          label: "Kloster Aldersbach (Zisterzienser)",
          detail:
            "Schreibort der Handschrift <a href='https://handschriftencensus.de/2380'>München, Staatsbibl., Cgm 4358</a>",
        },
        geometry: { type: "Point", coordinates: [13.086425, 48.588647] },
      },
      {
        type: "Feature",
        properties: {
          label: "Kloster Altenhohenaus (Dominikanerinnen)",
          detail:
            "Schreibort von <a href='https://handschriftencensus.de/9988'>München, Staatsbibl., Cgm 1109</a>",
        },
        geometry: { type: "Point", coordinates: [12.17776, 48.007441] },
      },
      {
        type: "Feature",
        properties: {
          label: "Kloster Tegernsee (Benediktiner)",
          detail: "Provenienz von BSB 2 Inc.s.a. 62",
        },
        geometry: { type: "Point", coordinates: [11.75683, 47.707711] },
      },
      {
        type: "Feature",
        properties: {
          label: "Nürnberg",
          detail:
            "Schreibort der Abschrift <a href='https://handschriftencensus.de/5045'>Karlsruhe, Badische Landesbibliothek, Cod. Donaueschingen 245</a>",
        },
        geometry: { type: "Point", coordinates: [11.07718, 49.454289] },
      },
      {
        type: "Feature",
        properties: { label: "Trient", detail: "Druckort" },
        geometry: { type: "Point", coordinates: [11.125546, 46.066383] },
      },
    ],
  };

  function ensureLeaflet(ready) {
    if (window.L) return ready();
    const css = document.createElement("link");
    css.rel = "stylesheet";
    css.href = "assets/leaflet-1.9.4/leaflet.css";
    document.head.appendChild(css);

    const s = document.createElement("script");
    s.src = "assets/leaflet-1.9.4/leaflet.js";
    s.defer = true;
    s.onload = ready;
    s.onerror = function () {
      const css2 = document.createElement("link");
      css2.rel = "stylesheet";
      css2.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css";
      document.head.appendChild(css2);

      const s2 = document.createElement("script");
      s2.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js";
      s2.defer = true;
      s2.onload = ready;
      document.head.appendChild(s2);
    };
    document.head.appendChild(s);
  }

  function initMap() {
    const el = document.getElementById(MAP_ID);
    if (!el) return;
    if (!el.style.height) el.style.height = "65vh";

    const map = L.map(el, { scrollWheelZoom: false });
    L.tileLayer(TILE_URL, { maxZoom: 19, attribution: ATTR }).addTo(map);

    const layer = L.geoJSON(PLACES, {
      pointToLayer: (f, latlng) =>
        L.circleMarker(latlng, {
          radius: 8,
          weight: 2,
          color: "#b10000",
          fillColor: "#ff3b30",
          fillOpacity: 0.95,
          className: "poi",
        }),
      onEachFeature: (f, l) => {
        const p = f.properties || {};
        const title = p.label || "Ort";
        const detail = p.detail ? `<br><small>${p.detail}</small>` : "";
        l.bindPopup(`<strong>${title}</strong>${detail}`);
        l.bindTooltip(title);
      },
    }).addTo(map);

    const b = layer.getBounds();
    b.isValid()
      ? map.fitBounds(b, { padding: [20, 20] })
      : map.setView([48.5, 11.5], 6);
  }

  document.addEventListener("DOMContentLoaded", () => ensureLeaflet(initMap));
})();
