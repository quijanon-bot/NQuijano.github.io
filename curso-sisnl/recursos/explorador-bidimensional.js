// Explorador de sistemas bidimensionales (parte 4). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-bidimensional"></div>
//       <script src="../recursos/explorador-bidimensional.js"></script>
// Tres pestañas: retratos lineales (traza y determinante), linealización de sistemas
// no lineales (con clic para lanzar trayectorias) y variedad central. Los modelos son
// los de codigo/cap04_bidimensionales.
(function () {
  const raiz = document.getElementById('explorador-bidimensional');
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

  // ---------- álgebra 2x2 ----------
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

  montarPestanas([['lineal', 'Retratos lineales'], ['nolineal', 'Linealizar un sistema no lineal'], ['central', 'Variedad central']]);

  // ===== 1. Retratos lineales (C4_Ej4, C4_Ej5) =====
  (function () {
    const p = panel('lineal'), e = {};
    const dib = () => {
      const A = [[e.a11, e.a12], [e.a21, e.a22]], F = x => [A[0][0] * x[0] + A[0][1] * x[1], A[1][0] * x[0] + A[1][1] * x[1]];
      const c = clasificar(A, 1e-6);
      const T = ejes(svg1, 300, 300, {l: 36, r: 8, t: 10, b: 32}, [-4, 4], [-3, 5], 'τ = tr A', 'δ = det A');
      linea(svg1, Array.from({length: 161}, (_, i) => { const t = -4 + 8 * i / 160; return [T.X(t), T.Y(Math.min(5, t * t / 4))]; }), C.noche, 1.6);
      linea(svg1, [[T.X(0), T.Y(0)], [T.X(0), T.Y(5)]], C.verde, 2.6);
      svg1.insertAdjacentHTML('beforeend', `<text x="${T.X(-2.6)}" y="${T.Y(3.3)}" font-size="11" fill="${C.gris}">focos</text><text x="${T.X(1.6)}" y="${T.Y(3.3)}" font-size="11" fill="${C.gris}">focos</text>` +
        `<text x="${T.X(-3.8)}" y="${T.Y(1.2)}" font-size="11" fill="${C.gris}">nodos</text><text x="${T.X(2.7)}" y="${T.Y(1.2)}" font-size="11" fill="${C.gris}">nodos</text><text x="${T.X(-0.6)}" y="${T.Y(-1.8)}" font-size="11" fill="${C.gris}">sillas</text>` +
        `<circle cx="${T.X(Math.max(-4, Math.min(4, c.tau)))}" cy="${T.Y(Math.max(-3, Math.min(5, c.de)))}" r="6" fill="${C.coral}"/>`);
      const T2 = ejes(svg2, 360, 340, {l: 36, r: 8, t: 10, b: 32}, [-1, 1], [-1, 1], 'x₁', 'x₂');
      flechas(svg2, F, [-1, 1], [-1, 1], T2, 15);
      const caja = [-1.05, 1.05, -1.05, 1.05];
      for (let k = 0; k < 16; k++) { const th = 2 * Math.PI * k / 16, x0 = [0.98 * Math.cos(th), 0.98 * Math.sin(th)];
        for (const s of [1, -1]) linea(svg2, rk4(F, x0, 12 * s, 0.02, caja).map(x => (Math.abs(x[0]) > 1 || Math.abs(x[1]) > 1 ? [NaN, NaN] : [T2.X(x[0]), T2.Y(x[1])])), C.azul, 1.3); }
      if (c.ev.every(([, im]) => Math.abs(im) < 1e-9) && Math.abs(c.de) > 1e-9) {           // rectas propias
        for (const [l] of c.ev) { let v = Math.abs(A[0][1]) > 1e-9 ? [A[0][1], l - A[0][0]] : (Math.abs(A[1][0]) > 1e-9 ? [l - A[1][1], A[1][0]] : null);
          if (!v) continue; const n = Math.hypot(...v); v = [v[0] / n, v[1] / n];
          linea(svg2, [[T2.X(-1.4 * v[0]), T2.Y(-1.4 * v[1])], [T2.X(1.4 * v[0]), T2.Y(1.4 * v[1])]].map(([a, b]) => [Math.max(36, Math.min(352, a)), Math.max(10, Math.min(308, b))]), C.verde, 2.2); }
      }
      punto(svg2, T2, [0, 0], c.ev.every(([re]) => re < -1e-9));
      res.innerHTML = `τ = ${f(c.tau)}, δ = ${f(c.de)}, τ² − 4δ = ${f(c.disc)}. λ = ${txtEig(c.ev)}. ` +
        `<b style="color:${C.azul}">${c.tipo}</b>${c.giro ? ` (giro ${c.giro}: a₂₁ ${A[1][0] > 0 ? '&gt;' : '&lt;'} 0)` : ''}. ` +
        (c.hip ? 'Hiperbólico: robusto ante perturbaciones pequeñas.' : '<b style="color:#D1495B">No hiperbólico: una perturbación pequeña cambia el retrato.</b>');
    };
    p.insertAdjacentHTML('beforeend', '<p>Escoja los cuatro elementos de A. A la izquierda, el punto (τ, δ) en el plano traza–determinante; a la derecha, el retrato de x′ = Ax (en verde, las rectas de vectores propios reales).</p>');
    const presets = [['', 'Ejemplos…'], ['-6,0,0,-2', 'nodo diag(−6,−2)'], ['-1,0,0,2', 'silla'], ['-1,1,0,-1', 'nodo impropio'], ['-0.5,-2,2,-0.5', 'foco estable'],
      ['0,1,-4,0', 'masa–resorte (centro horario)'], ['1,-5,1,-1', 'centro antihorario'], ['-1,-3,0,2', 'ejemplo 4.2'], ['0,0,0,-1', 'a = 0: recta de equilibrios']];
    p.insertAdjacentHTML('beforeend', `<div class="exp-controles"><label>Ejemplos<select style="width:auto" data-pre>${presets.map(([v, t]) => `<option value="${v}">${t}</option>`).join('')}</select></label></div>`);
    controles(p, [['a11', 'a₁₁', -4, 4, -0.5, 0.05], ['a12', 'a₁₂', -4, 4, -2, 0.05], ['a21', 'a₂₁', -4, 4, 2, 0.05], ['a22', 'a₂₂', -4, 4, -0.5, 0.05]], e, () => dib());
    p.querySelector('[data-pre]').addEventListener('change', ev => { if (!ev.target.value) return;
      ev.target.value.split(',').map(Number).forEach((v, i) => { const id = ['a11', 'a12', 'a21', 'a22'][i]; e[id] = v;
        p.querySelector(`[data-id=${id}]`).value = v; p.querySelector(`[data-num=${id}]`).value = v; }); dib(); });
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1.2fr;gap:.5rem"><svg viewBox="0 0 300 300"></svg><svg viewBox="0 0 360 340"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. Linealizar (C4_Ej2, C4_Ej7, C4_Ej8, C4_Ej9, C4_Ej10) =====
  (function () {
    const p = panel('nolineal'), e = {};
    const hD = v => 17.76 * v - 103.79 * v ** 2 + 229.62 * v ** 3 - 226.31 * v ** 4 + 83.72 * v ** 5;
    const sis = {
      cuaderno: {t: 'x₁′ = −x₁ + x₁x₂, x₂′ = x₁ + x₂ − 2x₁x₂ (clase del 19 de agosto)', F: () => x => [-x[0] + x[0] * x[1], x[0] + x[1] - 2 * x[0] * x[1]],
                 xr: [-2, 3], yr: [-2, 3], sem: [[0.1, -0.1], [0.9, 1.1]], T: 15, lab: ['x₁', 'x₂']},
      tres: {t: 'x₁′ = x₁ + x₁x₂, x₂′ = −x₂ + x₂² + x₁x₂ − x₁³ (ejemplo 4.5)', F: () => x => [x[0] + x[0] * x[1], -x[1] + x[1] ** 2 + x[0] * x[1] - x[0] ** 3],
             xr: [-2, 2.5], yr: [-3, 2.5], sem: [[0.05, 0.05], [0.05, 0.95], [0.9, -0.9]], T: 12, lab: ['x₁', 'x₂']},
      duffing: {t: 'Duffing: x₁′ = x₂, x₂′ = x₁ − x₁³ − δx₂ (δ con el control)', F: () => x => [x[1], x[0] - x[0] ** 3 - e.par * x[1]],
                xr: [-2.5, 2.5], yr: [-2.5, 2.5], sem: [[0, 0], [1, 0], [-1, 0]], T: 40, par: ['δ', 0, 3.5, 0.5, 0.05], lab: ['x₁', 'x₂']},
      diodo: {t: 'Diodo túnel con inductancia (E = 1.2 V, R = 1.5 kΩ, C = 2 pF, L con el control, t en ns)',
              F: () => x => [(-hD(x[0]) + x[1]) / 2, (-x[0] - 1.5 * x[1] + 1.2) / e.par], xr: [-0.4, 1.6], yr: [-0.4, 1.5],
              sem: [[0.06, 0.76], [0.285, 0.61], [0.88, 0.21]], T: 120, par: ['L (μH)', 0.5, 50, 5, 0.5], lab: ['v_C (V)', 'i_L (mA)']},
      centro: {t: 'x₁′ = x₂, x₂′ = −x₁ − ε x₁² x₂ (la linealización es un centro para todo ε)', F: () => x => [x[1], -x[0] - e.par * x[0] ** 2 * x[1]],
               xr: [-1.5, 1.5], yr: [-1.5, 1.5], sem: [[0, 0]], T: 40, par: ['ε', -1, 1, 1, 0.05], lab: ['x₁', 'x₂']},
    };
    let clics = [];
    const dib = (cambio) => {
      const s = sis[e.sis];
      if (cambio === true) { clics = []; ctl.innerHTML = '';
        if (s.par) { delete e.par; controles(ctl, [['par', s.par[0], s.par[1], s.par[2], s.par[3], s.par[4]]], e, () => dib()); } }
      const F = s.F(), caja = [s.xr[0] - 0.05, s.xr[1] + 0.05, s.yr[0] - 0.05, s.yr[1] + 0.05];
      const T = ejes(svg, 460, 400, {l: 40, r: 10, t: 10, b: 34}, s.xr, s.yr, s.lab[0], s.lab[1]);
      flechas(svg, F, s.xr, s.yr, T, 19);
      const cl = (x, y) => (x < s.xr[0] || x > s.xr[1] || y < s.yr[0] || y > s.yr[1] ? [NaN, NaN] : [T.X(x), T.Y(y)]);
      const u = [0.1, 0.3, 0.5, 0.7, 0.9], bx = s.xr[1] - s.xr[0], by = s.yr[1] - s.yr[0];
      const borde = [...u.map(t => [s.xr[0] + t * bx, s.yr[0]]), ...u.map(t => [s.xr[0] + t * bx, s.yr[1]]), ...u.map(t => [s.xr[0], s.yr[0] + t * by]), ...u.map(t => [s.xr[1], s.yr[0] + t * by])];
      const h = e.sis === 'diodo' ? 0.05 : 0.02;
      for (const x0 of borde) linea(svg, rk4(F, x0, s.T, h, caja).map(x => cl(x[0], x[1])), C.azul, 1.1);
      // equilibrios
      const eqs = []; let txt = '';
      for (const x0 of s.sem) { const xe = newton(F, x0); if (Math.hypot(...F(xe)) > 1e-8 || eqs.some(q => Math.hypot(q[0] - xe[0], q[1] - xe[1]) < 1e-6)) continue;
        eqs.push(xe); const c = clasificar(jacNum(F, xe), 1e-6);
        punto(svg, T, xe, c.ev.every(([re]) => re < -1e-9));
        if (c.tipo === 'silla') {             // variedad estable: hacia atrás desde xe ± eps v
          const J = jacNum(F, xe), l = Math.min(c.ev[0][0], c.ev[1][0]);
          let v = Math.abs(J[0][1]) > 1e-9 ? [J[0][1], l - J[0][0]] : [l - J[1][1], J[1][0]]; const nv = Math.hypot(...v); v = [v[0] / nv, v[1] / nv];
          for (const sg of [1, -1]) linea(svg, rk4(F, [xe[0] + sg * 1e-5 * v[0], xe[1] + sg * 1e-5 * v[1]], -s.T, h / 2, caja).map(x => cl(x[0], x[1])), C.noche, 2.6);
        }
        txt += `(${f(xe[0], 3)}, ${f(xe[1], 3)}): λ = ${txtEig(c.ev)} → <b>${c.tipo}</b>${c.giro ? ' ' + c.giro : ''}${c.hip ? '' : ' <b style="color:#D1495B">(no hiperbólico: Hartman–Grobman no decide)</b>'}<br>`; }
      for (const x0 of clics) { linea(svg, rk4(F, x0, s.T, h, caja).map(x => cl(x[0], x[1])), C.coral, 2.2);
        svg.insertAdjacentHTML('beforeend', `<circle cx="${T.X(x0[0])}" cy="${T.Y(x0[1])}" r="4" fill="${C.coral}"/>`); }
      res.innerHTML = s.t + '<br>' + txt + (txt.includes('silla') ? 'En negro, la variedad estable de la silla. ' : '') + (clics.length ? '' : '<i>Haga clic en el plano para lanzar trayectorias (en coral).</i>');
      svg._T = T;
    };
    p.insertAdjacentHTML('beforeend', '<p>Escoja un sistema. El explorador busca los equilibrios (Newton), calcula la jacobiana numérica y los clasifica con traza y determinante. Haga clic en el plano para lanzar trayectorias.</p>');
    selector(p, 'sis', 'Sistema', [['cuaderno', 'Sistema de la clase (nulclinas)'], ['tres', 'Tres equilibrios'], ['duffing', 'Duffing amortiguado'], ['diodo', 'Diodo túnel de segundo orden'], ['centro', 'Un centro que no lo es']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><svg viewBox="0 0 460 400" style="cursor:crosshair;max-width:640px"></svg><div class="exp-controles"><label><button type="button" data-borrar>Borrar trayectorias</button></label></div>');
    const ctl = p.querySelector('.exp-ctl'), svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    svg.addEventListener('click', ev => { const r = svg.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 460, py = (ev.clientY - r.top) / r.height * 400;
      clics.push([svg._T.Xi(px), svg._T.Yi(py)]); dib(); });
    p.querySelector('[data-borrar]').addEventListener('click', () => { clics = []; dib(); });
    dib(true);
  })();

  // ===== 3. Variedad central (C4_Ej12) =====
  (function () {
    const p = panel('central'), e = {};
    const dib = () => {
      const a = e.a, F = x => [x[0] * x[1], -x[1] + a * x[0] ** 2], caja = [-1.2, 1.2, -1, 1];
      const T = ejes(svg1, 360, 320, {l: 40, r: 8, t: 10, b: 34}, [-1, 1], [-0.8, 0.8], 'y', 'z');
      flechas(svg1, F, [-1, 1], [-0.8, 0.8], T, 15);
      const hf = y => a * y * y - 2 * a * a * y ** 4;
      linea(svg1, Array.from({length: 121}, (_, i) => { const y = -0.65 + 1.3 * i / 120, z = hf(y); return [T.X(y), Math.abs(z) <= 0.8 ? T.Y(z) : NaN]; }), C.verde, 3);
      linea(svg1, [[T.X(-1), T.Y(0)], [T.X(1), T.Y(0)]], C.gris, 1.2, '3 3');
      const R = rk4(F, [e.y0, e.z0], e.T, 0.01, caja);
      linea(svg1, R.map(x => [T.X(Math.max(-1, Math.min(1, x[0]))), T.Y(Math.max(-0.8, Math.min(0.8, x[1])))]), C.coral, 2.2);
      svg1.insertAdjacentHTML('beforeend', `<circle cx="${T.X(e.y0)}" cy="${T.Y(e.z0)}" r="4" fill="${C.coral}"/>`);
      punto(svg1, T, [0, 0], a < 0);
      const Rr = rk4(x => [a * x[0] ** 3 - 2 * a * a * x[0] ** 5, 0], [e.y0, 0], e.T, 0.01, [-5, 5, -5, 5]);
      const t = R.map((_, i) => i * 0.01), tr = Rr.map((_, i) => i * 0.01);
      const ymax = Math.max(0.05, ...R.map(x => Math.abs(x[0])), ...Rr.map(x => Math.abs(x[0]))) * 1.1;
      const T2 = ejes(svg2, 320, 320, {l: 44, r: 8, t: 10, b: 34}, [0, e.T], [-Math.min(ymax, 2), Math.min(ymax, 2)], 't', 'y(t)');
      const cy = v => T2.Y(Math.max(-2, Math.min(2, v)));
      linea(svg2, t.map((tt, i) => [T2.X(tt), cy(R[i][0])]), C.coral, 2.2);
      linea(svg2, tr.map((tt, i) => [T2.X(tt), cy(Rr[i][0])]), C.verde, 1.8, '6 4');
      const yf = R[R.length - 1], dist = Math.abs(yf[1] - hf(yf[0]));
      const pol = (c1, p1, c2, p2) => (a === 0 ? '0' : `${f(c1, 3)} ${p1} − ${f(c2, 3)} ${p2}`).replace('-', '−');
      res.innerHTML = `h(y) ≈ ${pol(a, 'y²', 2 * a * a, 'y⁴')}; sistema reducido y′ = ${pol(a, 'y³', 2 * a * a, 'y⁵')}. ` +
        (a < 0 ? '<b style="color:#2A9D8F">a &lt; 0: el origen es asintóticamente estable (lentamente).</b>' : a > 0 ? '<b style="color:#D1495B">a &gt; 0: inestable.</b>' : '<b>a = 0: estable, no asintóticamente (y → y₀ e^{z₀}).</b>') +
        ` Al final, |z − h(y)| = ${dist.toExponential(1)}: la solución vive sobre la variedad. Si se pusiera z = 0, el reducido sería y′ = 0 para cualquier a.`;
    };
    p.insertAdjacentHTML('beforeend', '<p>y′ = yz, z′ = −z + a y². A la izquierda, la solución (coral) cae sobre la variedad central z ≈ ay² − 2a²y⁴ (verde), no sobre E<sup>c</sup> = {z = 0} (punteada). A la derecha, y(t) del sistema completo (coral) y del reducido (verde, a trazos).</p>');
    controles(p, [['a', 'a', -2, 2, -1, 0.05], ['y0', 'y(0)', -0.9, 0.9, 0.5, 0.05], ['z0', 'z(0)', -0.75, 0.75, 0.6, 0.05], ['T', 'Tiempo final', 5, 80, 40, 5]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.1fr 1fr;gap:.5rem"><svg viewBox="0 0 360 320"></svg><svg viewBox="0 0 320 320"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();
})();
