// Explorador de bifurcaciones (parte 6). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-bifurcaciones"></div>
//       <script src="../recursos/explorador-bifurcaciones.js"></script>
// Tres pestañas: el catálogo en la recta (con imperfección), bifurcaciones en el plano
// (silla-nodo, horquilla escondida, interruptor genético, Hopf super/sub, histéresis de
// ciclos) y el mapa de Poincaré. Los modelos son los de codigo/cap06_bifurcaciones.
(function () {
  const raiz = document.getElementById('explorador-bifurcaciones');
  if (!raiz) return;
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', ambar: '#E09F3E',
             violeta: '#6C4AB6', gris: '#5C677D', claro: '#C9D1DE', rejilla: '#DDE2EA'};
  const f = (x, d = 3) => (+x.toFixed(d)).toString();

  // ---------- dibujo ----------
  function ejes(svg, W, H, m, xr, yr, xl, yl) {
    const X = x => m.l + (x - xr[0]) / (xr[1] - xr[0]) * (W - m.l - m.r);
    const Y = y => H - m.b - (y - yr[0]) / (yr[1] - yr[0]) * (H - m.t - m.b);
    const paso = (a, b) => { const r = (b - a) / 5, p = 10 ** Math.floor(Math.log10(r)), n = r / p;
      return (n < 1.5 ? 1 : n < 3.5 ? 2 : n < 7.5 ? 5 : 10) * p; };
    let s = '';
    const dx = paso(...xr);
    for (let k = Math.ceil(xr[0] / dx); k * dx <= xr[1] + 1e-9; k++) { const x = Math.abs(k * dx) < 1e-12 ? 0 : k * dx;
      s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${x === 0 ? C.gris : C.rejilla}"/>` +
           `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">${+x.toPrecision(3)}</text>`; }
    const dy = paso(...yr);
    for (let k = Math.ceil(yr[0] / dy); k * dy <= yr[1] + 1e-9; k++) { const y = Math.abs(k * dy) < 1e-12 ? 0 : k * dy;
      s += `<line x1="${m.l}" x2="${W - m.r}" y1="${Y(y)}" y2="${Y(y)}" stroke="${y === 0 ? C.gris : C.rejilla}"/>` +
           `<text x="${m.l - 5}" y="${Y(y) + 4}" font-size="11" text-anchor="end" fill="${C.gris}">${+y.toPrecision(3)}</text>`; }
    s += `<text x="${(W + m.l - m.r) / 2}" y="${H - 3}" font-size="12" text-anchor="middle" fill="${C.noche}">${xl}</text>` +
         `<text x="12" y="${(H - m.b + m.t) / 2}" font-size="12" text-anchor="middle" fill="${C.noche}" transform="rotate(-90 12 ${(H - m.b + m.t) / 2})">${yl}</text>`;
    svg.innerHTML = s;
    const Xi = px => xr[0] + (px - m.l) / (W - m.l - m.r) * (xr[1] - xr[0]);
    const Yi = py => yr[0] + (H - m.b - py) / (H - m.t - m.b) * (yr[1] - yr[0]);
    return {X, Y, Xi, Yi};
  }
  function linea(svg, pts, col, ancho = 2, guiones = '') {
    let d = '', nuevo = true;
    for (const p of pts) {
      if (!isFinite(p[0]) || !isFinite(p[1])) { nuevo = true; continue; }
      d += (nuevo ? 'M' : 'L') + p[0].toFixed(1) + ',' + p[1].toFixed(1); nuevo = false;
    }
    svg.insertAdjacentHTML('beforeend', `<path d="${d}" fill="none" stroke="${col}" stroke-width="${ancho}" stroke-dasharray="${guiones}"/>`);
  }
  // RK4 de paso fijo que se detiene al salir de la caja [x0,x1,y0,y1] (con margen)
  function rk4(F, x0, T, h, caja) {
    const X = [x0.slice()]; let x = x0.slice();
    const n = Math.round(Math.abs(T) / h), s = Math.sign(T);
    for (let i = 0; i < n; i++) {
      const G = z => F(z).map(v => s * v);
      const k1 = G(x), k2 = G(x.map((v, j) => v + h / 2 * k1[j])), k3 = G(x.map((v, j) => v + h / 2 * k2[j])), k4 = G(x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
      if (!isFinite(x[0]) || !isFinite(x[1])) break;
      X.push(x.slice());
      if (caja && (x[0] < caja[0] || x[0] > caja[1] || x[1] < caja[2] || x[1] > caja[3])) break;
    }
    return X;
  }
  function flechas(svg, F, xr, yr, T, n = 15) {
    let s = '';
    for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) {
      const x = xr[0] + (i + 0.5) / n * (xr[1] - xr[0]), y = yr[0] + (j + 0.5) / n * (yr[1] - yr[0]);
      const v = F([x, y]), nv = Math.hypot(v[0], v[1]); if (!(nv > 0)) continue;
      const px = T.X(x), py = T.Y(y), L = 7, ux = v[0] / nv, uy = v[1] / nv;
      const ax = T.X(x + ux) - px, ay = T.Y(y + uy) - py, na = Math.hypot(ax, ay), bx = ax / na * L, by = ay / na * L;
      s += `<line x1="${px - bx}" y1="${py - by}" x2="${px + bx}" y2="${py + by}" stroke="${C.claro}" stroke-width="1.2"/>` +
           `<circle cx="${px + bx}" cy="${py + by}" r="1.6" fill="${C.claro}"/>`;
    }
    svg.insertAdjacentHTML('beforeend', s);
  }
  const punto = (svg, T, x, estable) => svg.insertAdjacentHTML('beforeend',
    `<circle cx="${T.X(x[0])}" cy="${T.Y(x[1])}" r="5" fill="${estable ? C.noche : '#fff'}" stroke="${C.noche}" stroke-width="1.6"/>`);
  function controles(cont, lista, e, dib) {
    let html = '<div class="exp-controles">';
    for (const [id, lab, mn, mx, v, paso] of lista) {
      if (e[id] === undefined) e[id] = v;
      html += `<label>${lab}<input type="range" min="${mn}" max="${mx}" step="${paso}" value="${e[id]}" data-id="${id}">
               <input type="number" value="${e[id]}" data-num="${id}" step="${paso}" min="${mn}" max="${mx}"></label>`;
    }
    cont.insertAdjacentHTML('beforeend', html + '</div>');
    cont.querySelectorAll('input[type=range]').forEach(el => el.addEventListener('input', () => {
      e[el.dataset.id] = +el.value; cont.querySelector(`[data-num=${el.dataset.id}]`).value = el.value; dib(); }));
    cont.querySelectorAll('input[type=number]').forEach(el => el.addEventListener('change', () => {
      e[el.dataset.num] = +el.value; cont.querySelector(`[data-id=${el.dataset.num}]`).value = el.value; dib(); }));
  }
  function selector(p, id, lab, opciones, e, dib) {
    if (e[id] === undefined) e[id] = opciones[0][0];
    p.insertAdjacentHTML('beforeend', `<div class="exp-controles"><label>${lab}<select data-sel="${id}" style="width:auto">` +
      opciones.map(([v, t]) => `<option value="${v}">${t}</option>`).join('') + '</select></label></div>');
    p.querySelector(`[data-sel=${id}]`).addEventListener('change', ev => { e[id] = ev.target.value; dib(true); });
  }
  function montarPestanas(pestanas) {
    raiz.innerHTML = `<div class="exp-pestanas">${pestanas.map(([id, t], i) => `<button data-p="${id}" class="${i ? '' : 'activa'}">${t}</button>`).join('')}</div>` +
      pestanas.map(([id], i) => `<div class="exp-panel" data-panel="${id}" style="display:${i ? 'none' : 'block'}"></div>`).join('');
    raiz.querySelectorAll('.exp-pestanas button').forEach(b => b.addEventListener('click', () => {
      raiz.querySelectorAll('.exp-pestanas button').forEach(x => x.classList.toggle('activa', x === b));
      raiz.querySelectorAll('.exp-panel').forEach(p => { p.style.display = p.dataset.panel === b.dataset.p ? 'block' : 'none'; });
    }));
  }
  const panel = id => raiz.querySelector(`[data-panel=${id}]`);
  const eigA = A => { const tr = A[0][0] + A[1][1], de = A[0][0] * A[1][1] - A[0][1] * A[1][0], di = tr * tr / 4 - de;
    return di >= 0 ? [[tr / 2 - Math.sqrt(di), 0], [tr / 2 + Math.sqrt(di), 0]] : [[tr / 2, -Math.sqrt(-di)], [tr / 2, Math.sqrt(-di)]]; };
  const txtEig = ev => ev.map(([re, im]) => (Math.abs(im) < 1e-9 ? f(re, 3) : `${f(re, 3)} ${im < 0 ? '−' : '+'} ${f(Math.abs(im), 3)}j`)).join(', ');
  function clasificar(A, tol = 1e-9) {     // misma lógica que comun/clasificarEquilibrio.m
    const tau = A[0][0] + A[1][1], de = A[0][0] * A[1][1] - A[0][1] * A[1][0], disc = tau * tau - 4 * de;
    const est = tau < 0 ? 'estable' : 'inestable';
    let tipo;
    if (Math.abs(de) <= tol) tipo = 'no aislado (det A = 0)';
    else if (de < 0) tipo = 'silla';
    else if (Math.abs(tau) <= tol) tipo = 'centro';
    else if (disc < -tol) tipo = 'foco ' + est;
    else if (Math.abs(disc) <= tol) tipo = (Math.abs(A[0][1]) + Math.abs(A[1][0]) + Math.abs(A[0][0] - A[1][1]) <= tol ? 'estrella ' : 'nodo impropio ') + est;
    else tipo = 'nodo ' + est;
    const giro = (tipo.startsWith('foco') || tipo === 'centro') ? (A[1][0] > 0 ? 'antihorario' : 'horario') : '';
    const ev = eigA(A), hip = ev.every(([re]) => Math.abs(re) > tol);
    return {tau, de, disc, tipo, giro, ev, hip};
  }
  const jacNum = (F, x, h = 1e-6) => { const a = F([x[0] + h, x[1]]), b = F([x[0] - h, x[1]]), c = F([x[0], x[1] + h]), d = F([x[0], x[1] - h]);
    return [[(a[0] - b[0]) / (2 * h), (c[0] - d[0]) / (2 * h)], [(a[1] - b[1]) / (2 * h), (c[1] - d[1]) / (2 * h)]]; };
  function newton(F, x0) {
    let x = x0.slice();
    for (let k = 0; k < 60; k++) { const J = jacNum(F, x), v = F(x), D = J[0][0] * J[1][1] - J[0][1] * J[1][0];
      if (Math.abs(D) < 1e-14) break;
      const dx = [(J[1][1] * v[0] - J[0][1] * v[1]) / D, (-J[1][0] * v[0] + J[0][0] * v[1]) / D];
      x = [x[0] - dx[0], x[1] - dx[1]]; if (Math.hypot(...dx) < 1e-13) break; }
    return x;
  }

  montarPestanas([['recta', 'Catálogo en la recta'], ['plano', 'Bifurcaciones en el plano'], ['poincare', 'Mapa de Poincaré']]);

  // raíces reales de g en [a, b] por cambio de signo (+ bisección)
  function raices(g, a, b, n = 800) {
    const r = []; let x0 = a, g0 = g(a);
    for (let i = 1; i <= n; i++) {
      const x1 = a + (b - a) * i / n, g1 = g(x1);
      if (g0 === 0) r.push(x0);
      else if (g0 * g1 < 0) { let lo = x0, hi = x1, glo = g0;
        for (let k = 0; k < 60; k++) { const m = (lo + hi) / 2, gm = g(m); if (gm * glo <= 0) hi = m; else { lo = m; glo = gm; } }
        r.push((lo + hi) / 2); }
      x0 = x1; g0 = g1;
    }
    return r;
  }
  const tipo1 = (g, x) => { const h = 1e-4, l = g(x - h), r = g(x + h);
    return l > 0 && r < 0 ? 'estable' : (l < 0 && r > 0 ? 'inestable' : 'semiestable'); };

  // ===== 1. Catálogo en la recta (C6_Ej1, C6_Ej3, C6_Ej4, C6_Ej5) =====
  (function () {
    const p = panel('recta'), e = {};
    const formas = {
      sn: {t: 'silla-nodo: x′ = μ − x² + ε', f: (x, m, eps) => m - x * x + eps, nota: 'Genérica: con ε solo se corre a μ = −ε.'},
      tc: {t: 'transcrítica: x′ = μx − x² + ε', f: (x, m, eps) => m * x - x * x + eps, nota: 'Con ε ≠ 0 se deshace: dos ramas separadas (ε > 0) o dos sillas-nodo en μ = ±2√(−ε) (ε < 0).'},
      sup: {t: 'horquilla supercrítica: x′ = μx − x³ + ε', f: (x, m, eps) => m * x - x ** 3 + eps, nota: 'Con ε ≠ 0 se parte en una rama continua y una silla-nodo aislada en μ = 3(|ε|/2)^{2/3}.'},
      sub: {t: 'horquilla subcrítica: x′ = μx + x³ + ε', f: (x, m, eps) => m * x + x ** 3 + eps, nota: 'Peligrosa: pasado μ = 0 no queda atractor cerca y el estado escapa.'},
      qui: {t: 'subcrítica con término quíntico: x′ = μx + x³ − x⁵ + ε', f: (x, m, eps) => m * x + x ** 3 - x ** 5 + eps, nota: 'Biestable para −1/4 < μ < 0: histéresis entre el origen y las ramas grandes.'},
    };
    const XR = [-1.6, 1.6], MR = [-1, 1];
    const dib = () => {
      const fo = formas[e.forma], g = x => fo.f(x, e.mu, e.eps);
      // izquierda: f(x) y línea de fase
      let ymin = Infinity, ymax = -Infinity; const xs = Array.from({length: 241}, (_, i) => XR[0] + (XR[1] - XR[0]) * i / 240);
      xs.forEach(x => { const y = g(x); ymin = Math.min(ymin, y); ymax = Math.max(ymax, y); });
      ymin = Math.max(-3, Math.min(-0.5, ymin)); ymax = Math.min(3, Math.max(0.5, ymax));
      const T = ejes(svg1, 320, 300, {l: 38, r: 8, t: 10, b: 32}, XR, [ymin, ymax], 'x', 'x′');
      linea(svg1, xs.map(x => [T.X(x), g(x) < ymin || g(x) > ymax ? NaN : T.Y(g(x))]), C.azul, 2);
      const eqs = raices(g, XR[0], XR[1]);
      for (let i = 0; i < 9; i++) { const xm = XR[0] + (i + 0.5) * (XR[1] - XR[0]) / 9, s = Math.sign(g(xm));
        if (s && eqs.every(q => Math.abs(q - xm) > 0.08)) svg1.insertAdjacentHTML('beforeend',
          `<path d="M${T.X(xm) - 5 * s},${T.Y(0) - 4} L${T.X(xm) + 5 * s},${T.Y(0)} L${T.X(xm) - 5 * s},${T.Y(0) + 4} Z" fill="${C.azul}"/>`); }
      let txt = '';
      for (const q of eqs) { const tp = tipo1(g, q);
        svg1.insertAdjacentHTML('beforeend', `<circle cx="${T.X(q)}" cy="${T.Y(0)}" r="5" fill="${tp === 'estable' ? C.noche : tp === 'inestable' ? '#fff' : '#AAAAAA'}" stroke="${C.noche}" stroke-width="1.5"/>`);
        txt += `x* = ${f(q, 3)} (${tp}); `; }
      // derecha: diagrama
      const T2 = ejes(svg2, 340, 300, {l: 38, r: 8, t: 10, b: 32}, MR, XR, 'μ', 'x*');
      let pts = '';
      for (let i = 0; i <= 200; i++) { const m = MR[0] + (MR[1] - MR[0]) * i / 200, gm = x => fo.f(x, m, e.eps);
        for (const q of raices(gm, XR[0], XR[1], 300)) { const tp = tipo1(gm, q);
          pts += `<circle cx="${T2.X(m)}" cy="${T2.Y(q)}" r="1.4" fill="${tp === 'estable' ? C.noche : C.coral}"/>`; } }
      svg2.insertAdjacentHTML('beforeend', pts + `<line x1="${T2.X(e.mu)}" x2="${T2.X(e.mu)}" y1="10" y2="268" stroke="${C.verde}" stroke-width="2" stroke-dasharray="5 4"/>`);
      res.innerHTML = `<b>${fo.t}</b>, μ = ${f(e.mu)}, ε = ${f(e.eps)}. ${eqs.length ? txt : 'No hay equilibrios en la ventana. '}<br>${fo.nota}`;
    };
    p.insertAdjacentHTML('beforeend', '<p>Escoja una forma normal y mueva μ (línea verde en el diagrama) y la imperfección ε. A la izquierda, el campo y la línea de fase (lleno: estable; vacío: inestable; gris: semiestable); a la derecha, el diagrama de bifurcación (negro: estable; coral: inestable).</p>');
    selector(p, 'forma', 'Forma normal', [['sn', 'Silla-nodo'], ['tc', 'Transcrítica'], ['sup', 'Horquilla supercrítica'], ['sub', 'Horquilla subcrítica'], ['qui', 'Subcrítica con −x⁵ (histéresis)']], e, dib);
    controles(p, [['mu', 'μ', -1, 1, -0.3, 0.01], ['eps', 'ε (imperfección)', -0.3, 0.3, 0, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1.06fr;gap:.5rem"><svg viewBox="0 0 320 300"></svg><svg viewBox="0 0 340 300"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. En el plano (C6_Ej6 a C6_Ej10) =====
  (function () {
    const p = panel('plano'), e = {};
    const sis = {
      sn2: {t: 'Silla-nodo: x₁′ = μ − x₁², x₂′ = −x₂', F: m => x => [m - x[0] ** 2, -x[1]], par: ['μ', -1, 1, 0.5, 0.01],
            xr: [-2, 2], yr: [-2, 2], sem: m => (m > 0 ? [[Math.sqrt(m), 0], [-Math.sqrt(m), 0]] : [[0, 0]]), T: 8, lab: ['x₁', 'x₂']},
      esc: {t: 'Horquilla escondida: x₁′ = μx₁ − x₁x₂, x₂′ = −x₂ + x₁²', F: m => x => [m * x[0] - x[0] * x[1], -x[1] + x[0] ** 2], par: ['μ', -0.3, 0.3, 0.1, 0.01],
            xr: [-0.8, 0.8], yr: [-0.4, 0.8], sem: m => [[0, 0], [Math.sqrt(Math.abs(m)), Math.abs(m)], [-Math.sqrt(Math.abs(m)), Math.abs(m)]], T: 60, lab: ['x₁', 'x₂'], extra: 'parabola'},
      gen: {t: 'Interruptor genético (b = 0.35): x′ = −ax + y, y′ = x²/(1+x²) − 0.35y', F: a => x => [-a * x[0] + x[1], x[0] ** 2 / (1 + x[0] ** 2) - 0.35 * x[1]], par: ['a', 0.6, 2, 1, 0.01],
            xr: [0, 3.5], yr: [0, 3.5], sem: () => [[0, 0], [0.4, 0.4], [1, 1], [2.5, 2.5]], T: 60, lab: ['x (proteína)', 'y (ARNm)']},
      cir: {t: 'Circuito (Hopf supercrítica): x₁′ = x₂ − (x₁³ − μx₁), x₂′ = −x₁', F: m => x => [x[1] - (x[0] ** 3 - m * x[0]), -x[0]], par: ['μ', -1, 1, 0.3, 0.01],
            xr: [-2, 2], yr: [-2, 2], sem: () => [[0, 0]], T: 50, lab: ['x₁', 'x₂']},
      sub: {t: 'Hopf subcrítica: r′ = r(μ + r²), θ′ = 1', F: m => x => { const r2 = x[0] ** 2 + x[1] ** 2; return [m * x[0] - x[1] + x[0] * r2, x[0] + m * x[1] + x[1] * r2]; }, par: ['μ', -0.5, 0.5, -0.2, 0.01],
            xr: [-1.2, 1.2], yr: [-1.2, 1.2], sem: () => [[0, 0]], T: 30, lab: ['x₁', 'x₂']},
      his: {t: 'Histéresis de ciclos: r′ = r(μ + r² − r⁴), θ′ = 1', F: m => x => { const r2 = x[0] ** 2 + x[1] ** 2, g = m + r2 - r2 * r2; return [-x[1] + x[0] * g, x[0] + x[1] * g]; }, par: ['μ', -0.4, 0.2, -0.1, 0.005],
            xr: [-1.4, 1.4], yr: [-1.4, 1.4], sem: () => [[0, 0]], T: 60, lab: ['x₁', 'x₂']},
    };
    let clics = [];
    const dib = (cambio) => {
      const s = sis[e.sis];
      if (cambio === true) { clics = []; ctl.innerHTML = ''; delete e.par; controles(ctl, [['par', ...s.par]], e, () => dib()); }
      const F = s.F(e.par), caja = [s.xr[0] - 0.05, s.xr[1] + 0.05, s.yr[0] - 0.05, s.yr[1] + 0.05];
      const T = ejes(svg, 420, 380, {l: 40, r: 10, t: 10, b: 34}, s.xr, s.yr, s.lab[0], s.lab[1]);
      flechas(svg, F, s.xr, s.yr, T, 17);
      const cl = (x, y) => (x < s.xr[0] || x > s.xr[1] || y < s.yr[0] || y > s.yr[1] ? [NaN, NaN] : [T.X(x), T.Y(y)]);
      const u = [0.15, 0.4, 0.6, 0.85], bx = s.xr[1] - s.xr[0], by = s.yr[1] - s.yr[0];
      const borde = [...u.map(t => [s.xr[0] + t * bx, s.yr[0]]), ...u.map(t => [s.xr[0] + t * bx, s.yr[1]]), ...u.map(t => [s.xr[0], s.yr[0] + t * by]), ...u.map(t => [s.xr[1], s.yr[0] + t * by])];
      for (const x0 of borde) linea(svg, rk4(F, x0, s.T, 0.02, caja).map(x => cl(x[0], x[1])), C.azul, 1);
      if (s.extra === 'parabola') linea(svg, Array.from({length: 81}, (_, i) => { const x = -0.8 + 1.6 * i / 80; return cl(x, x * x); }), C.verde, 2.4);
      const eqs = []; let txt = ''; const pts = [];
      for (const x0 of s.sem(e.par)) { const xe = newton(F, x0); if (Math.hypot(...F(xe)) > 1e-8 || eqs.some(q => Math.hypot(q[0] - xe[0], q[1] - xe[1]) < 1e-5)) continue;
        if (xe[0] < s.xr[0] || xe[0] > s.xr[1] || xe[1] < s.yr[0] || xe[1] > s.yr[1]) continue;
        eqs.push(xe); const c = clasificar(jacNum(F, xe), 1e-6); pts.push(c);
        punto(svg, T, xe, c.ev.every(([re]) => re < -1e-9));
        txt += `(${f(xe[0], 3)}, ${f(xe[1], 3)}): τ = ${f(c.tau, 3)}, δ = ${f(c.de, 3)} → <b>${c.tipo}</b>${c.hip ? '' : ' <b style="color:#D1495B">(no hiperbólico)</b>'}<br>`; }
      for (const x0 of clics) { linea(svg, rk4(F, x0, 3 * s.T, 0.01, caja).map(x => cl(x[0], x[1])), C.coral, 2);
        svg.insertAdjacentHTML('beforeend', `<circle cx="${T.X(x0[0])}" cy="${T.Y(x0[1])}" r="4" fill="${C.coral}"/>`); }
      // plano tau-delta
      const T2 = ejes(svg2, 240, 240, {l: 34, r: 6, t: 8, b: 30}, [-3, 3], [-2, 3], 'τ', 'δ');
      linea(svg2, Array.from({length: 121}, (_, i) => { const t = -3 + 6 * i / 120; return [T2.X(t), T2.Y(Math.min(3, t * t / 4))]; }), C.gris, 1.2, '3 3');
      linea(svg2, [[T2.X(0), T2.Y(0)], [T2.X(0), T2.Y(3)]], C.verde, 2.6); linea(svg2, [[T2.X(-3), T2.Y(0)], [T2.X(3), T2.Y(0)]], C.noche, 2.2);
      for (const c of pts) svg2.insertAdjacentHTML('beforeend', `<circle cx="${T2.X(Math.max(-3, Math.min(3, c.tau)))}" cy="${T2.Y(Math.max(-2, Math.min(3, c.de)))}" r="5" fill="${C.coral}"/>`);
      res.innerHTML = s.t + `, ${s.par[0]} = ${f(e.par)}.<br>` + txt + (clics.length ? '' : '<i>Haga clic en el plano para lanzar trayectorias largas (coral): así se ven los ciclos.</i>');
      svg._T = T;
    };
    p.insertAdjacentHTML('beforeend', '<p>Escoja un sistema y mueva el parámetro. Los equilibrios se encuentran con Newton y se clasifican con la jacobiana numérica; a la derecha, su punto (τ, δ): la Ruta 1 cruza el eje δ = 0 (negro) y la Ruta 2 la semirrecta τ = 0, δ &gt; 0 (verde). Haga clic en el plano para lanzar trayectorias.</p>');
    selector(p, 'sis', 'Sistema', [['sn2', 'Silla-nodo en el plano'], ['esc', 'Horquilla escondida'], ['gen', 'Interruptor genético'], ['cir', 'Circuito: Hopf supercrítica'], ['sub', 'Hopf subcrítica'], ['his', 'Histéresis de ciclos']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.75fr 1fr;gap:.5rem;align-items:start"><svg viewBox="0 0 420 380" style="cursor:crosshair"></svg><svg viewBox="0 0 240 240"></svg></div><div class="exp-controles"><label><button type="button" data-borrar>Borrar trayectorias</button></label></div>');
    const ctl = p.querySelector('.exp-ctl'), [svg, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    svg.addEventListener('click', ev => { const r = svg.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 420, py = (ev.clientY - r.top) / r.height * 380;
      clics.push([svg._T.Xi(px), svg._T.Yi(py)]); dib(); });
    p.querySelector('[data-borrar]').addEventListener('click', () => { clics = []; dib(); });
    dib(true);
  })();

  // ===== 3. Mapa de Poincaré (C6_Ej11, C6_Ej12) =====
  (function () {
    const p = panel('poincare'), e = {};
    const sis = {
      log: {t: 'r′ = r(μ − r), θ′ = −1 (ejemplo 6.9): x₁′ = μx₁ + x₂ − x₁r, x₂′ = −x₁ + μx₂ − x₂r', F: m => x => { const r = Math.hypot(x[0], x[1]); return [m * x[0] + x[1] - x[0] * r, -x[0] + m * x[1] - x[1] * r]; },
            par: ['μ', 0.02, 1, 0.2, 0.01], qmax: m => Math.max(0.4, 1.8 * m), lim: m => Math.max(0.45, 1.9 * m)},
      cir: {t: 'Circuito: x₁′ = x₂ − (x₁³ − μx₁), x₂′ = −x₁ (μ = 1: van der Pol)', F: m => x => [x[1] - (x[0] ** 3 - m * x[0]), -x[0]],
            par: ['μ', 0.05, 1, 1, 0.01], qmax: () => 2.6, lim: () => 2.6},
    };
    // primer retorno a Sigma = {x2 = 0, x1 > 0}, cruzando hacia abajo
    function retorno(F, q, h = 0.005, Tmax = 60) {
      let x = [q, 0], t = 0, tray = [x.slice()];
      const paso = (z, hh = h) => { const k1 = F(z), k2 = F(z.map((v, j) => v + hh / 2 * k1[j])), k3 = F(z.map((v, j) => v + hh / 2 * k2[j])), k4 = F(z.map((v, j) => v + hh * k3[j]));
        return z.map((v, j) => v + hh / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j])); };
      for (let i = 0; i < Tmax / h; i++) {
        const y = paso(x); t += h; tray.push(y);
        if (t > 0.05 && x[1] > 0 && y[1] <= 0 && y[0] > 0) {      // refinar el cruce: Newton sobre x2(t) = 0
          let dt = h * x[1] / (x[1] - y[1]), z = paso(x, dt);
          for (let k = 0; k < 5; k++) { dt -= z[1] / F(z)[1]; z = paso(x, dt); }
          return {P: z[0], tau: t - h + dt, tray}; }
        x = y; if (!isFinite(x[0])) break;
      }
      return {P: NaN, tau: NaN, tray};
    }
    const dib = (cambio) => {
      const s = sis[e.sis];
      if (cambio === true) { ctl.innerHTML = ''; delete e.par; controles(ctl, [['par', ...s.par], ['q0', 'q₀ (inicio en Σ)', 0.02, 2.5, 0.1, 0.01], ['N', 'vueltas', 1, 12, 5, 1]], e, () => dib()); }
      const F = s.F(e.par), L = s.lim(e.par), qm = s.qmax(e.par);
      const q0 = Math.min(e.q0, qm);
      // sucesión
      const q = [q0], taus = []; let tray = [];
      for (let k = 0; k < e.N; k++) { const r = retorno(F, q[q.length - 1]); if (!isFinite(r.P)) break; q.push(r.P); taus.push(r.tau); tray = tray.concat(r.tray); }
      const T = ejes(svg1, 320, 320, {l: 38, r: 8, t: 10, b: 32}, [-L, L], [-L, L], 'x₁', 'x₂');
      linea(svg1, tray.map(x => (Math.abs(x[0]) > L || Math.abs(x[1]) > L ? [NaN, NaN] : [T.X(x[0]), T.Y(x[1])])), C.azul, 1.2);
      linea(svg1, [[T.X(0), T.Y(0)], [T.X(L), T.Y(0)]], C.ambar, 3);
      q.forEach(v => svg1.insertAdjacentHTML('beforeend', `<circle cx="${T.X(v)}" cy="${T.Y(0)}" r="4" fill="${C.coral}"/>`));
      // gráfica de P y telaraña
      const T2 = ejes(svg2, 320, 320, {l: 38, r: 8, t: 10, b: 32}, [0, qm], [0, qm], 'q', 'P(q)');
      const qq = Array.from({length: 41}, (_, i) => 0.01 + (qm - 0.01) * i / 40), PP = qq.map(v => retorno(F, v).P);
      linea(svg2, qq.map((v, i) => [T2.X(v), PP[i] > qm ? NaN : T2.Y(PP[i])]), C.noche, 2);
      linea(svg2, [[T2.X(0), T2.Y(0)], [T2.X(qm), T2.Y(qm)]], C.gris, 1, '3 3');
      const cw = [[T2.X(q[0]), T2.Y(0)]];
      for (let k = 0; k + 1 < q.length; k++) { cw.push([T2.X(q[k]), T2.Y(q[k + 1])]); cw.push([T2.X(q[k + 1]), T2.Y(q[k + 1])]); }
      linea(svg2, cw, C.coral, 1.6);
      // punto fijo y multiplicador
      let qs = q[q.length - 1];
      for (let k = 0; k < 40; k++) { const r = retorno(F, qs); if (!isFinite(r.P)) break; if (Math.abs(r.P - qs) < 1e-10) { qs = r.P; break; } qs = r.P; }
      const d = 1e-4, mult = (retorno(F, qs + d).P - retorno(F, qs - d).P) / (2 * d), per = retorno(F, qs).tau;
      res.innerHTML = s.t + `, μ = ${f(e.par)}.<br>Sucesión de Poincaré: ${q.map(v => f(v, 4)).join(' → ')}. Tiempos de retorno: ${taus.map(v => f(v, 3)).join(', ')}.<br>` +
        `Punto fijo q* ≈ ${f(qs, 4)}, período ≈ ${f(per, 3)}, multiplicador P′(q*) ≈ ${mult.toPrecision(3)}` +
        (e.sis === 'log' ? ` (exacto: e^{−2πμ} = ${Math.exp(-2 * Math.PI * e.par).toPrecision(3)})` : '') + '. ' + (Math.abs(mult) < 1 ? '<b style="color:#2A9D8F">|P′| &lt; 1: ciclo estable.</b>' : '<b style="color:#D1495B">|P′| ≥ 1</b>');
    };
    p.insertAdjacentHTML('beforeend', '<p>La sección es Σ = {x₂ = 0, x₁ &gt; 0} (ámbar). Se integra con Runge–Kutta desde q₀ hasta el siguiente cruce de Σ: eso es P(q₀). A la derecha, la gráfica de P y la telaraña de la sucesión. El tiempo de retorno se calcula en cada vuelta: ¿es constante?</p>');
    selector(p, 'sis', 'Sistema', [['log', 'Ejemplo con fórmula (Jordan y Smith)'], ['cir', 'Circuito / van der Pol']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 320 320"></svg><svg viewBox="0 0 320 320"></svg></div>');
    const ctl = p.querySelector('.exp-ctl'), [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib(true);
  })();
})();
