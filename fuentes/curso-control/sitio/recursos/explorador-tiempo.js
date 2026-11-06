// Exploradores de respuesta temporal del curso (partes 1, 2, 3 y 9). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-primer-orden"></div>
//       <div class="explorador" id="explorador-segundo-orden"></div>
//       <script src="../recursos/explorador-tiempo.js"></script>
(function () {
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', ambar: '#E09F3E',
             violeta: '#6C4AB6', gris: '#5C677D', rejilla: '#DDE2EA'};
  const f = (x, d = 2) => (Math.abs(x) >= 1e4 ? x.toExponential(2) : (+x.toFixed(d)).toString());

  // ---------- utilidades de dibujo ----------
  function ejes(svg, W, H, m, xr, yr, xl, yl) {
    const X = x => m.l + (x - xr[0]) / (xr[1] - xr[0]) * (W - m.l - m.r);
    const Y = y => H - m.b - (y - yr[0]) / (yr[1] - yr[0]) * (H - m.t - m.b);
    let s = '';
    const paso = (a, b) => { const r = (b - a) / 6, p = 10 ** Math.floor(Math.log10(r)), n = r / p;
      return (n < 1.5 ? 1 : n < 3.5 ? 2 : n < 7.5 ? 5 : 10) * p; };
    const dx = paso(...xr), dy = paso(...yr);
    const lim = (v, d) => (Math.abs(v) < d * 1e-6 ? 0 : v);
    for (let k = Math.ceil(xr[0] / dx); k * dx <= xr[1] + 1e-9; k++) { const x = lim(k * dx, dx);
      s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${C.rejilla}"/>` +
           `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">${+x.toPrecision(3)}</text>`; }
    for (let k = Math.ceil(yr[0] / dy); k * dy <= yr[1] + 1e-9; k++) { const y = lim(k * dy, dy);
      s += `<line x1="${m.l}" x2="${W - m.r}" y1="${Y(y)}" y2="${Y(y)}" stroke="${C.rejilla}"/>` +
           `<text x="${m.l - 5}" y="${Y(y) + 4}" font-size="11" text-anchor="end" fill="${C.gris}">${+y.toPrecision(3)}</text>`; }
    s += `<text x="${(W + m.l - m.r) / 2}" y="${H - 3}" font-size="12" text-anchor="middle" fill="${C.noche}">${xl}</text>` +
         `<text x="12" y="${(H - m.b + m.t) / 2}" font-size="12" text-anchor="middle" fill="${C.noche}" transform="rotate(-90 12 ${(H - m.b + m.t) / 2})">${yl}</text>`;
    svg.innerHTML = s;
    return {X, Y};
  }
  function linea(svg, pts, col, ancho = 2.2, guiones = '') {
    const d = pts.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ',' + p[1].toFixed(1)).join('');
    svg.insertAdjacentHTML('beforeend', `<path d="${d}" fill="none" stroke="${col}" stroke-width="${ancho}" stroke-dasharray="${guiones}"/>`);
  }
  function deslizadores(raiz, ctrls, estado, alCambiar) {
    let html = '<div class="exp-controles">';
    for (const [id, lab, mn, mx, v, paso] of ctrls) {
      estado[id] = v;
      html += `<label>${lab}<input type="range" min="${mn}" max="${mx}" step="${paso}" value="${v}" data-id="${id}">
               <input type="number" value="${v}" data-num="${id}" step="${paso}" min="${mn}" max="${mx}"></label>`;
    }
    return html + '</div>';
  }
  function conectar(raiz, estado, dibujar) {
    raiz.querySelectorAll('input[type=range]').forEach(el => el.addEventListener('input', () => {
      estado[el.dataset.id] = +el.value; raiz.querySelector(`[data-num=${el.dataset.id}]`).value = el.value; dibujar(); }));
    raiz.querySelectorAll('input[type=number]').forEach(el => el.addEventListener('change', () => {
      estado[el.dataset.num] = +el.value; raiz.querySelector(`[data-id=${el.dataset.num}]`).value = el.value; dibujar(); }));
    raiz.querySelectorAll('select').forEach(el => el.addEventListener('change', () => { estado[el.dataset.id] = el.value; dibujar(); }));
  }

  // ======================= primer orden =======================
  const r1 = document.getElementById('explorador-primer-orden');
  if (r1) {
    const e = {entrada: 'escalon'};
    r1.innerHTML = deslizadores(r1, [['K1', 'Ganancia K₁', 0.1, 10, 2, 0.1], ['tau', 'Constante de tiempo τ (s)', 0.2, 20, 5, 0.1]], e) +
      `<div class="exp-controles"><label>Entrada <select data-id="entrada" style="width:auto"><option value="escalon">escalón unitario</option>
       <option value="rampa">rampa u(t) = t</option></select></label></div>
       <div class="exp-resumen"></div><svg viewBox="0 0 760 300"></svg>
       <div class="exp-leyenda"><span style="color:${C.azul}">━ entrada (×K₁ en la rampa)</span><span style="color:${C.coral}">━ salida y(t)</span>
       <span style="color:${C.gris}">┅ tangente en t = 0 / referencias</span></div>`;
    const svg = r1.querySelector('svg'), res = r1.querySelector('.exp-resumen');
    function dib() {
      const {K1, tau, entrada} = e, T = 6 * tau, n = 400;
      const t = Array.from({length: n + 1}, (_, i) => i * T / n);
      if (entrada === 'escalon') {
        const y = t.map(x => K1 * (1 - Math.exp(-x / tau)));
        const {X, Y} = ejes(svg, 760, 300, {l: 52, r: 14, t: 12, b: 34}, [0, T], [0, 1.15 * K1], 't (s)', 'y(t)');
        linea(svg, t.map(x => [X(x), Y(K1)]), C.azul, 1.6, '6 4');
        linea(svg, [[X(0), Y(0)], [X(tau), Y(K1)]], C.gris, 1.4, '3 3');
        for (const k of [1, 2, 3, 4]) {
          const yk = K1 * (1 - Math.exp(-k));
          svg.insertAdjacentHTML('beforeend', `<circle cx="${X(k * tau)}" cy="${Y(yk)}" r="4" fill="${C.ambar}"/>
            <text x="${X(k * tau) + 6}" y="${Y(yk) + 16}" font-size="11" fill="${C.gris}">${(100 * (1 - Math.exp(-k))).toFixed(1)} % en ${k}τ</text>`);
        }
        linea(svg, t.map((x, i) => [X(x), Y(y[i])]), C.coral, 2.6);
        res.innerHTML = `<b>G(s) = ${f(K1)}/(${f(tau)}s + 1)</b> · polo en s = −${f(1 / tau, 3)} · valor final K₁ = ${f(K1)} ·
          63.2 % en t = τ = ${f(tau)} s · t<sub>s</sub>(2 %) ≈ 4τ = ${f(4 * tau)} s (exacto τ ln 50 = ${f(tau * Math.log(50))} s) · pendiente inicial K₁/τ = ${f(K1 / tau, 3)}`;
      } else {
        const y = t.map(x => K1 * (x - tau + tau * Math.exp(-x / tau)));
        const {X, Y} = ejes(svg, 760, 300, {l: 52, r: 14, t: 12, b: 34}, [0, T], [0, 1.05 * K1 * T], 't (s)', 'y(t)');
        linea(svg, t.map(x => [X(x), Y(K1 * x)]), C.azul, 1.6, '6 4');
        linea(svg, t.map((x, i) => [X(x), Y(y[i])]), C.coral, 2.6);
        const tm = 0.85 * T;
        svg.insertAdjacentHTML('beforeend', `<line x1="${X(tm)}" x2="${X(tm)}" y1="${Y(K1 * tm)}" y2="${Y(K1 * (tm - tau + tau * Math.exp(-tm / tau)))}" stroke="${C.noche}" stroke-width="2"/>
          <text x="${X(tm) + 6}" y="${Y(K1 * (tm - tau / 2))}" font-size="12" fill="${C.noche}">e → K₁τ = ${f(K1 * tau)}</text>`);
        res.innerHTML = `<b>Rampa:</b> y(t) = K₁(t − τ + τe<sup>−t/τ</sup>). La salida sigue con la misma pendiente pero <b>τ = ${f(tau)} s atrasada</b>;
          el error e(t) = K₁u(t) − y(t) tiende a <b>K₁τ = ${f(K1 * tau)}</b>.`;
      }
    }
    conectar(r1, e, dib); dib();
  }

  // ======================= segundo orden =======================
  const r2 = document.getElementById('explorador-segundo-orden');
  if (r2) {
    const e = {};
    r2.innerHTML = deslizadores(r2, [['zeta', 'Amortiguamiento ζ', 0, 2.5, 0.4, 0.01], ['wn', 'Frecuencia natural ωₙ (rad/s)', 0.2, 10, 1, 0.05],
                                     ['K', 'Ganancia K', 0.1, 5, 1, 0.1]], e) +
      `<div class="exp-resumen"></div>
       <div style="display:grid;grid-template-columns:1fr 2.2fr;gap:.6rem;align-items:start">
       <svg class="exp-polos" viewBox="0 0 300 300"></svg><svg class="exp-paso" viewBox="0 0 660 300"></svg></div>
       <div class="exp-leyenda"><span style="color:${C.coral}">━ y(t)</span><span style="color:${C.gris}">┅ envolventes</span>
       <span style="color:${C.verde}">▬ banda ±2 %</span><span style="color:${C.violeta}">● t<sub>p</sub></span><span style="color:${C.ambar}">● t<sub>s</sub></span></div>`;
    const sp = r2.querySelector('.exp-polos'), sy = r2.querySelector('.exp-paso'), res = r2.querySelector('.exp-resumen');
    function y2(t, z, w) {
      if (z < 1) { const wd = w * Math.sqrt(1 - z * z), b = Math.acos(z);
        return 1 - Math.exp(-z * w * t) / Math.sqrt(1 - z * z) * Math.sin(wd * t + b); }
      if (z === 1) return 1 - Math.exp(-w * t) * (1 + w * t);
      const r = Math.sqrt(z * z - 1), s1 = w * (z + r), s2 = w * (z - r);
      return 1 + w / (2 * r) * (Math.exp(-s1 * t) / s1 - Math.exp(-s2 * t) / s2);
    }
    function dib() {
      const z = e.zeta, w = e.wn, K = e.K;
      const sig = z * w, T = z > 0.02 ? Math.min(Math.max(9 / Math.max(sig, w * (z - Math.sqrt(Math.max(z * z - 1, 0)))), 6 / w), 60 / w) : 25 / w;
      const n = 800, t = Array.from({length: n + 1}, (_, i) => i * T / n), y = t.map(x => K * y2(x, z, w));
      const ymax = Math.max(...y), ymin = Math.min(...y, 0);
      // --- plano s
      const R = Math.max(w * (z + Math.sqrt(Math.max(z * z - 1, 0))), w) * 1.15;
      const P = ejes(sp, 300, 300, {l: 40, r: 10, t: 10, b: 32}, [-R, 0.25 * R], [-R, R], 'Re s', 'Im s');
      sp.insertAdjacentHTML('beforeend', `<line x1="${P.X(0)}" x2="${P.X(0)}" y1="10" y2="268" stroke="${C.gris}"/>
        <line x1="40" x2="290" y1="${P.Y(0)}" y2="${P.Y(0)}" stroke="${C.gris}"/>
        <circle cx="${P.X(0)}" cy="${P.Y(0)}" r="${P.X(w) - P.X(0)}" fill="none" stroke="${C.rejilla}" stroke-dasharray="4 3"/>`);
      let polos;
      if (z < 1) { const wd = w * Math.sqrt(1 - z * z); polos = [[-sig, wd], [-sig, -wd]];
        sp.insertAdjacentHTML('beforeend', `<line x1="${P.X(0)}" y1="${P.Y(0)}" x2="${P.X(-sig)}" y2="${P.Y(wd)}" stroke="${C.azul}" stroke-width="1.4"/>`); }
      else { const r = w * Math.sqrt(z * z - 1); polos = [[-sig + r, 0], [-sig - r, 0]]; }
      for (const [a, b] of polos) sp.insertAdjacentHTML('beforeend',
        `<text x="${P.X(a)}" y="${P.Y(b) + 6}" font-size="20" font-weight="700" text-anchor="middle" fill="${C.coral}">×</text>`);
      // --- escalón
      const Q = ejes(sy, 660, 300, {l: 48, r: 12, t: 12, b: 34}, [0, T], [Math.min(ymin, 0), Math.max(1.1 * K, 1.05 * ymax)], 't (s)', 'y(t)');
      sy.insertAdjacentHTML('beforeend', `<rect x="${Q.X(0)}" y="${Q.Y(1.02 * K)}" width="${Q.X(T) - Q.X(0)}" height="${Q.Y(0.98 * K) - Q.Y(1.02 * K)}" fill="${C.verde}" opacity=".18"/>`);
      if (z > 0 && z < 1) {
        const env = s => t.map(x => [Q.X(x), Q.Y(K * (1 + s * Math.exp(-sig * x) / Math.sqrt(1 - z * z)))]);
        linea(sy, env(1).filter(p => p[1] > 10), C.gris, 1.2, '4 3'); linea(sy, env(-1).filter(p => p[1] < 268), C.gris, 1.2, '4 3');
      }
      linea(sy, t.map((x, i) => [Q.X(x), Q.Y(y[i])]), C.coral, 2.6);
      // métricas medidas sobre la curva
      const yf = K; let ip = 0; y.forEach((v, i) => { if (v > y[ip]) ip = i; });
      let iu = -1; y.forEach((v, i) => { if (Math.abs(v - yf) > 0.02 * yf) iu = i; });
      const tsMed = iu + 1 <= n ? t[iu + 1] : NaN;
      const i10 = y.findIndex(v => v >= 0.1 * yf), i90 = y.findIndex(v => v >= 0.9 * yf);
      const osMed = Math.max(0, (y[ip] - yf) / yf * 100);
      if (osMed > 0.05) sy.insertAdjacentHTML('beforeend', `<circle cx="${Q.X(t[ip])}" cy="${Q.Y(y[ip])}" r="5" fill="${C.violeta}"/>`);
      if (isFinite(tsMed) && z > 0) sy.insertAdjacentHTML('beforeend', `<circle cx="${Q.X(tsMed)}" cy="${Q.Y(y[iu + 1])}" r="5" fill="${C.ambar}"/>`);
      let txt;
      if (z === 0) txt = `<b>ζ = 0:</b> polos en ±j${f(w)}: oscilación sostenida a ωₙ = ${f(w)} rad/s, sin establecimiento.`;
      else if (z < 1) {
        const wd = w * Math.sqrt(1 - z * z), b = Math.acos(z);
        txt = `<b>Subamortiguado</b> · polos −${f(sig, 3)} ± j${f(wd, 3)} · β = ${f(b * 180 / Math.PI, 1)}° ·
          <b>%OS</b> = ${f(100 * Math.exp(-z * Math.PI / Math.sqrt(1 - z * z)), 1)} % ·
          <b>t<sub>p</sub></b> = π/ω<sub>d</sub> = ${f(Math.PI / wd)} s ·
          <b>t<sub>s</sub></b> ≈ 4/(ζωₙ) = ${f(4 / sig)} s (medido ${f(tsMed)} s) ·
          <b>t<sub>r</sub></b> 0–100 % = ${f((Math.PI - b) / wd)} s, 10–90 % = ${i10 >= 0 && i90 >= 0 ? f(t[i90] - t[i10]) : '—'} s`;
      } else {
        txt = `<b>${z === 1 ? 'Críticamente amortiguado' : 'Sobreamortiguado'}</b> · polos ${polos.map(p => f(p[0], 3)).join(' y ')} ·
          sin sobrepico · t<sub>r</sub> 10–90 % = ${i10 >= 0 && i90 >= 0 ? f(t[i90] - t[i10]) : '—'} s · t<sub>s</sub> (2 %) medido = ${f(tsMed)} s`;
      }
      res.innerHTML = `<b>T(s) = ${f(K)}·${f(w * w, 3)}/(s² + ${f(2 * sig, 3)}s + ${f(w * w, 3)})</b><br>` + txt;
    }
    conectar(r2, e, dib); dib();
  }
  // ======================= retroalimentación de estado =======================
  const r3 = document.getElementById('explorador-estado');
  if (r3) {
    const e = {integ: 'si'};
    r3.innerHTML = deslizadores(r3, [['a0', 'Planta: a₀ (s² + a₁s + a₀)', -4, 10, 3, 0.5], ['a1', 'Planta: a₁', -4, 10, 5, 0.5],
                                     ['OS', '%OS deseado', 1, 40, 10, 1], ['ts', 'tₛ deseado (s)', 0.2, 5, 0.5, 0.05],
                                     ['m', 'Tercer polo: veces ζωₙ', 2, 20, 5, 0.5]], e) +
      `<div class="exp-controles"><label>Acción integral <select data-id="integ" style="width:auto">
       <option value="si">sí: u = −Kx + Kₑz</option><option value="no">no: u = r − Kx</option></select></label></div>
       <div class="exp-resumen"></div>
       <div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg class="exp-y" viewBox="0 0 380 260"></svg><svg class="exp-u" viewBox="0 0 380 260"></svg></div>
       <div class="exp-leyenda"><span style="color:${C.azul}">━ y(t)</span><span style="color:${C.gris}">┅ referencia</span><span style="color:${C.violeta}">━ u(t)</span></div>`;
    const sy = r3.querySelector('.exp-y'), su = r3.querySelector('.exp-u'), res = r3.querySelector('.exp-resumen');
    function dib() {
      const {a0, a1, OS, ts, m, integ} = e;
      const L = Math.log(OS / 100), z = -L / Math.sqrt(Math.PI ** 2 + L * L), wn = 4 / (z * ts), sg = z * wn;
      let K1, K2, Ke = 0, p3 = m * sg;
      if (integ === 'si') { K2 = 2 * sg + p3 - a1; K1 = wn * wn + 2 * sg * p3 - a0; Ke = p3 * wn * wn; }
      else { K2 = 2 * sg - a1; K1 = wn * wn - a0; }
      const T = Math.max(3 * ts, 1.5), n = 3000, h = T / n;
      let x = [0, 0, 0]; const t = [], y = [], u = [];
      const f = (x) => { const uu = integ === 'si' ? -K1 * x[0] - K2 * x[1] + Ke * x[2] : 1 - K1 * x[0] - K2 * x[1];
        return [[x[1], -a0 * x[0] - a1 * x[1] + uu, 1 - x[0]], uu]; };
      for (let i = 0; i <= n; i++) {
        const [k1, uu] = f(x); t.push(i * h); y.push(x[0]); u.push(uu);
        const k2 = f(x.map((v, j) => v + h / 2 * k1[j]))[0], k3 = f(x.map((v, j) => v + h / 2 * k2[j]))[0], k4 = f(x.map((v, j) => v + h * k3[j]))[0];
        x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
      }
      const ymax = Math.max(1.2, ...y.map(v => v * 1.05)), ymin = Math.min(0, ...y);
      const Q = ejes(sy, 380, 260, {l: 46, r: 10, t: 10, b: 32}, [0, T], [ymin, ymax], 't (s)', 'y(t)');
      linea(sy, [[Q.X(0), Q.Y(1)], [Q.X(T), Q.Y(1)]], C.gris, 1.2, '5 4');
      linea(sy, t.map((v, i) => [Q.X(v), Q.Y(y[i])]), C.azul, 2.4);
      const umax = Math.max(...u), umin = Math.min(...u, 0);
      const U = ejes(su, 380, 260, {l: 52, r: 10, t: 10, b: 32}, [0, T], [umin - 0.05 * (umax - umin + 1e-9), umax * 1.05 + 1e-9], 't (s)', 'u(t)');
      linea(su, t.map((v, i) => [U.X(v), U.Y(u[i])]), C.violeta, 2.2);
      const yf = y[n], plantaPolos = (() => { const d = a1 * a1 - 4 * a0; return d >= 0 ? `${f2((-a1 + Math.sqrt(d)) / 2)} y ${f2((-a1 - Math.sqrt(d)) / 2)}`
        : `${f2(-a1 / 2)} ± j${f2(Math.sqrt(-d) / 2)}`; })();
      res.innerHTML = `Planta 1/(s² + ${f2(a1)}s + ${f2(a0)}), polos ${plantaPolos} · deseados: ζ = ${f2(z)}, ωₙ = ${f2(wn)} → −${f2(sg)} ± j${f2(wn * Math.sqrt(1 - z * z))}` +
        (integ === 'si' ? ` y −${f2(p3)}` : '') + `<br><b>K = [${f2(K1)}  ${f2(K2)}]</b>` + (integ === 'si' ? ` · <b>Kₑ = ${f2(Ke)}</b>` : '') +
        ` · valor final y(${f2(T)}) = ${f2(yf)} · pico de |u| = ${f2(Math.max(Math.abs(umax), Math.abs(umin)))}`;
    }
    const f2 = v => (+v.toFixed(2)).toString();
    conectar(r3, e, dib); dib();
  }
  // ======================= lazo abierto vs lazo cerrado (parte 1) =======================
  const r4 = document.getElementById('explorador-tanque');
  if (r4) {
    const e = {};
    r4.innerHTML = deslizadores(r4, [['Kc', 'Ganancia del controlador K_c', 0, 30, 5, 0.5],
        ['d', 'Lluvia d desde t = 5 min (m³/min)', 0, 0.5, 0.2, 0.01],
        ['R', 'Resistencia real de salida R (nominal 2)', 1, 4, 2, 0.1],
        ['umax', 'Caudal máximo de la válvula (m³/min)', 0.6, 40, 40, 0.1]], e) +
      `<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 380 260"></svg><svg viewBox="0 0 380 260"></svg></div>
       <div class="exp-leyenda"><span style="color:${C.gris}">┅ nivel deseado h_r</span><span style="color:${C.coral}">━ lazo abierto (calibrado)</span>
       <span style="color:${C.azul}">━ lazo cerrado</span></div>`;
    const [sh, su] = r4.querySelectorAll('svg'), res = r4.querySelector('.exp-resumen');
    function dib() {
      const {Kc, d, R, umax} = e, Area = 0.5, Kn = 2, T = 10, n = 4000, dt = T / n;
      const t = [], ha = [0], hc = [0], ua = [], uc = [];
      for (let k = 0; k <= n; k++) {
        const tk = k * dt, hr = tk >= 1 ? 1 : 0, dk = tk >= 5 ? d : 0;
        t.push(tk);
        const a = Math.min(Math.max(hr / Kn, 0), umax);
        const c = Math.min(Math.max(hr / Kn + Kc * (hr - hc[k]), 0), umax);
        ua.push(a); uc.push(c);
        if (k < n) { ha.push(ha[k] + dt * (a + dk - ha[k] / R) / Area); hc.push(hc[k] + dt * (c + dk - hc[k] / R) / Area); }
      }
      const ymax = Math.max(1.5, ...ha, ...hc) * 1.05;
      const H = ejes(sh, 380, 260, {l: 46, r: 10, t: 10, b: 32}, [0, T], [0, ymax], 't (min)', 'h (m)');
      linea(sh, t.map(v => [H.X(v), H.Y(v >= 1 ? 1 : 0)]), C.gris, 1.4, '5 4');
      linea(sh, t.map((v, i) => [H.X(v), H.Y(ha[i])]), C.coral, 2.4);
      linea(sh, t.map((v, i) => [H.X(v), H.Y(hc[i])]), C.azul, 2.4);
      const um = Math.max(...uc, ...ua) * 1.08 + 0.1;
      const U = ejes(su, 380, 260, {l: 46, r: 10, t: 10, b: 32}, [0, T], [0, um], 't (min)', 'u (m³/min)');
      linea(su, t.map((v, i) => [U.X(v), U.Y(ua[i])]), C.coral, 2.2);
      linea(su, t.map((v, i) => [U.X(v), U.Y(uc[i])]), C.azul, 2.2);
      const sat = uc.some(v => v >= umax - 1e-9);
      res.innerHTML = `Tanque 0.5 ḣ = u + d − h/R, calibrado con K = 2 · lazo cerrado u = h_r/2 + K_c(h_r − h) · ` +
        `ganancia de lazo K·K_c = <b>${f(R * Kc)}</b><br>Nivel final: lazo abierto <b>${f(ha[n], 3)} m</b>, lazo cerrado <b>${f(hc[n], 3)} m</b>` +
        ` · τ del lazo cerrado ≈ ${f(60 * Area * R / (1 + R * Kc), 1)} s (abierto ${f(60 * Area * R, 0)} s) · pico de u: ${f(Math.max(...uc))} m³/min` +
        (sat ? ` · <b style="color:${C.coral}">¡la válvula se satura!</b>` : '');
    }
    conectar(r4, e, dib); dib();
  }
})();
