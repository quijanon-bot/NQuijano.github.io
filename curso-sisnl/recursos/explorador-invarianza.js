// Explorador del principio de invarianza y de la construcción de funciones de Lyapunov (parte 8). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-invarianza"></div>
//       <script src="../recursos/explorador-invarianza.js"></script>
// Tres pestañas: LaSalle (E, M y las componentes de {V <= c}), gradiente variable (barrido de a11)
// y Zubov (la región de atracción exacta de x1' = -x1 + 2x1²x2, x2' = -x2).
// Los modelos son los de codigo/cap08_invarianza.
(function () {
  const raiz = document.getElementById('explorador-invarianza');
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
  montarPestanas([['lasalle', 'LaSalle: E, M y Ω_c'], ['grad', 'Gradiente variable'], ['zubov', 'Zubov']]);

  // Rejilla de celdas: pinta {V <= c}; la componente del origen (relleno por inundación) en azul.
  function pintarNivel(svg, T, xr, yr, V, c, n, soloOrigen, extra) {
    const dx = (xr[1] - xr[0]) / n, dy = (yr[1] - yr[0]) / n, M = [];
    for (let i = 0; i < n; i++) { M.push([]); for (let j = 0; j < n; j++) M[i].push(V(xr[0] + (i + 0.5) * dx, yr[0] + (j + 0.5) * dy) <= c ? 1 : 0); }
    if (soloOrigen) {   // inundación desde la celda del origen
      const i0 = Math.floor((0 - xr[0]) / dx), j0 = Math.floor((0 - yr[0]) / dy), pila = [[i0, j0]];
      if (M[i0] && M[i0][j0] === 1) { M[i0][j0] = 2;
        while (pila.length) { const [i, j] = pila.pop();
          for (const [a, b] of [[i + 1, j], [i - 1, j], [i, j + 1], [i, j - 1]])
            if (a >= 0 && b >= 0 && a < n && b < n && M[a][b] === 1) { M[a][b] = 2; pila.push([a, b]); } } }
    }
    let s = '';
    const w = T.X(xr[0] + dx) - T.X(xr[0]) + 0.6, h = T.Y(yr[0]) - T.Y(yr[0] + dy) + 0.6;
    for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) {
      const v = M[i][j]; if (!v) continue;
      const col = soloOrigen ? (v === 2 ? C.azul : C.gris) : C.azul;
      s += `<rect x="${T.X(xr[0] + i * dx)}" y="${T.Y(yr[0] + (j + 1) * dy)}" width="${w}" height="${h}" fill="${col}" fill-opacity="${extra || 0.18}" shape-rendering="crispEdges"/>`;
    }
    svg.insertAdjacentHTML('beforeend', s);
    return (x, y) => { const i = Math.floor((x - xr[0]) / dx), j = Math.floor((y - yr[0]) / dy);
      return (i >= 0 && j >= 0 && i < n && j < n) ? M[i][j] : 0; };
  }
  function simT(F, x0, T, h) {     // RK4 invariante en el tiempo, guarda t
    let x = x0.slice(); const out = [[0, ...x]]; const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(x), k2 = F(x.map((v, j) => v + h / 2 * k1[j])), k3 = F(x.map((v, j) => v + h / 2 * k2[j])), k4 = F(x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
      if (!x.every(isFinite) || Math.hypot(...x) > 60) { out.escape = (i + 1) * h; break; }
      out.push([(i + 1) * h, ...x]);
    }
    return out;
  }

  // ---------------------------------------------------------------- 1. LaSalle
  (function () {
    const p = panel('lasalle'), e = {};
    const sis = {
      pend: {t: 'Péndulo con fricción: x₁′ = x₂, x₂′ = −sen x₁ − b x₂, V = 1 − cos x₁ + x₂²/2, V̇ = −b x₂², E = {x₂ = 0}',
             par: [['b', 'fricción b', 0.05, 1.5, 0.3, 0.05], ['c', 'nivel c', 0.1, 3, 1.8, 0.05]], xr: [-8, 8], yr: [-3, 3], x0: [2, 0.8], comp: true,
             F: e => x => [x[1], -Math.sin(x[0]) - e.b * x[1]], V: e => (a, b) => 1 - Math.cos(a) + b * b / 2, Vd: e => x => -e.b * x[1] ** 2,
             E: (e, T) => [[T.X(-8), T.Y(0)], [T.X(8), T.Y(0)]], M: 'M = {0} en |x₁| < π (si c < 2)', eq: [[0, 0, 1], [Math.PI, 0, 0], [-Math.PI, 0, 0], [2 * Math.PI, 0, 1], [-2 * Math.PI, 0, 1]]},
      duf: {t: 'Resorte blando: x₂′ = −(x₁ − x₁³) − β x₂|x₂|, V = x₁²/2 − x₁⁴/4 + x₂²/2, V̇ = −β|x₂|³; sillas en V = 1/4',
            par: [['b', 'β', 0.05, 1.5, 0.4, 0.05], ['c', 'nivel c', 0.02, 0.4, 0.24, 0.01]], xr: [-2.5, 2.5], yr: [-1.6, 1.6], x0: [1.2, 0], comp: true,
            F: e => x => [x[1], -(x[0] - x[0] ** 3) - e.b * x[1] * Math.abs(x[1])], V: e => (a, b) => a * a / 2 - a ** 4 / 4 + b * b / 2, Vd: e => x => -e.b * Math.abs(x[1]) ** 3,
            E: (e, T) => [[T.X(-1), T.Y(0)], [T.X(1), T.Y(0)]], M: 'M = {0} en la componente del origen (si c < 1/4)', eq: [[0, 0, 1], [1, 0, 0], [-1, 0, 0]]},
      ciclo: {t: 'Ciclo límite: r′ = r(1 − r²), θ′ = 1, V = (r² − 1)²/4 (no es definida positiva), V̇ = −r²(1 − r²)²',
              par: [['c', 'nivel c', 0.02, 0.4, 0.2, 0.01]], xr: [-1.8, 1.8], yr: [-1.8, 1.8], x0: [1.4, 0.3], comp: false,
              F: e => x => { const q = 1 - x[0] ** 2 - x[1] ** 2; return [x[0] * q - x[1], x[1] * q + x[0]]; }, V: e => (a, b) => (a * a + b * b - 1) ** 2 / 4,
              Vd: e => x => { const r2 = x[0] ** 2 + x[1] ** 2; return -r2 * (1 - r2) ** 2; },
              E: (e, T) => Array.from({length: 121}, (_, i) => [T.X(Math.cos(i * Math.PI / 60)), T.Y(Math.sin(i * Math.PI / 60))]), M: 'M = E = el círculo (una órbita periódica)', eq: [[0, 0, 0]]},
      ines: {t: 'Atractivo pero inestable: r′ = r(1 − r), θ′ = 1 − cos θ, V = (1 − r)², V̇ = −2r(1 − r)²',
             par: [['c', 'nivel c', 0.02, 0.24, 0.24, 0.01]], xr: [-1.8, 1.8], yr: [-1.8, 1.8], x0: [Math.cos(0.15), Math.sin(0.15)], comp: false,
             F: e => x => { const r = Math.hypot(x[0], x[1]), th = 1 - x[0] / r; return [x[0] * (1 - r) - x[1] * th, x[1] * (1 - r) + x[0] * th]; },
             V: e => (a, b) => (1 - Math.hypot(a, b)) ** 2, Vd: e => x => { const r = Math.hypot(x[0], x[1]); return -2 * r * (1 - r) ** 2; },
             E: (e, T) => Array.from({length: 121}, (_, i) => [T.X(Math.cos(i * Math.PI / 60)), T.Y(Math.sin(i * Math.PI / 60))]), M: 'M = E = el círculo, pero todas van a (1, 0), que es inestable', eq: [[1, 0, 0]]},
    };
    p.insertAdjacentHTML('beforeend', '<p>Azul: la componente de {V ≤ c} que contiene al origen (en el ciclo, todo {V ≤ c}); gris: las otras componentes. Coral: E = {V̇ = 0}. <b>Haga clic</b> en el plano para lanzar una solución; a la derecha, V(x(t)) y V̇(x(t)).</p>');
    selector(p, 'sis', 'Sistema', [['pend', 'Péndulo con fricción'], ['duf', 'Resorte blando'], ['ciclo', 'Ciclo límite (V no d.p.)'], ['ines', 'Atractivo pero inestable']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.15fr 1fr;gap:.5rem"><svg viewBox="0 0 420 330" style="cursor:crosshair"></svg><svg viewBox="0 0 380 330"></svg></div>');
    const ctl = p.querySelector('.exp-ctl'), [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    let T1, enComp;
    function dib(cambio) {
      const s = sis[e.sis];
      if (cambio === true || !e.x0) { ctl.innerHTML = ''; s.par.forEach(q => delete e[q[0]]); controles(ctl, s.par, e, () => dib()); e.x0 = s.x0.slice(); }
      const F = s.F(e), V = s.V(e), Vd = s.Vd(e);
      T1 = ejes(s1, 420, 330, {l: 38, r: 8, t: 10, b: 32}, s.xr, s.yr, 'x₁', 'x₂');
      flechas(s1, F, s.xr, s.yr, T1, 15);
      enComp = pintarNivel(s1, T1, s.xr, s.yr, V, e.c, 110, s.comp);
      linea(s1, s.E(e, T1), C.coral, 3);
      const tr = simT(F, e.x0, 40, 0.01);
      linea(s1, tr.map(z => [T1.X(z[1]), T1.Y(z[2])]), C.noche, 1.3);
      s.eq.forEach(q => punto(s1, T1, q, q[2]));
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4.5" fill="${C.ambar}"/>`);
      const Vt = tr.map(z => V(z[1], z[2])), Vdt = tr.map(z => Vd([z[1], z[2]]));
      const tf = tr[tr.length - 1][0], vmax = Math.max(...Vt.filter(isFinite), 0.1), vmin = Math.min(...Vdt.filter(isFinite), -0.05);
      const T2 = ejes(s2, 380, 330, {l: 42, r: 8, t: 10, b: 32}, [0, Math.max(tf, 1)], [Math.max(vmin, -3) * 1.05, Math.min(vmax, 10) * 1.05], 't', 'V, V̇');
      linea(s2, tr.map((z, i) => [T2.X(z[0]), T2.Y(Math.min(Vt[i], 10))]), C.azul, 2);
      linea(s2, tr.map((z, i) => [T2.X(z[0]), T2.Y(Math.max(Vdt[i], -3))]), C.coral, 1.6);
      let cruces = 0; for (let i = 1; i < tr.length; i++) if (Math.sign(Vdt[i] + 1e-12) !== Math.sign(Vdt[i - 1] + 1e-12) || (Math.abs(Vdt[i]) < 1e-9 && Math.abs(Vdt[i - 1]) > 1e-9)) cruces++;
      const fin = tr[tr.length - 1], k = enComp(e.x0[0], e.x0[1]);
      const donde = s.comp ? (k === 2 ? '<b style="color:#1E5AA8">x₀ está en Ω_c</b>' : (k === 1 ? '<b style="color:#D1495B">V(x₀) ≤ c, pero x₀ está en OTRA componente</b>' : 'V(x₀) > c')) : (V(...e.x0) <= e.c ? 'x₀ está en Ω_c' : 'V(x₀) > c');
      res.innerHTML = `<b>${s.t}</b><br>${s.M}. V(x₀) = ${f(V(...e.x0))}: ${donde}. ` +
        (tr.escape ? `<b style="color:#D1495B">La solución escapa (t ≈ ${f(tr.escape, 2)}).</b>` : `x(40) = (${f(fin[1])}, ${f(fin[2])}), V(x(40)) = ${f(V(fin[1], fin[2]), 4)}.`);
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 420, py = (ev.clientY - r.top) / r.height * 330;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib(true);
  })();

  // ---------------------------------------------------------------- 2. Gradiente variable
  (function () {
    const p = panel('grad'), e = {x0: [6, -2]};
    p.insertAdjacentHTML('beforeend', '<p>x₁′ = x₂, x₂′ = −(x₁ + x₂) − sen(x₁ + x₂). Con g = (a₁₁x₁ + x₂, x₁ + x₂): V = a₁₁x₁²/2 + x₁x₂ + x₂²/2 y V̇ = (a₁₁ − 2)x₁x₂ − x₁² − y sen y, y = x₁ + x₂. Coral: V̇ &gt; 0. Azul: el mayor {V ≤ c} que no toca la zona coral. <b>Haga clic</b> para lanzar soluciones (también fuera del estimado).</p>');
    controles(p, [['a', 'a₁₁', 1.05, 6, 2, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 360 360" style="cursor:crosshair"></svg><svg viewBox="0 0 380 360"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    const L = 8, F = x => [x[1], -(x[0] + x[1]) - Math.sin(x[0] + x[1])];
    function cstar(a) {    // mínimo de V sobre {V̇ >= 0}, por rayos
      let best = Infinity;
      for (let k = 0; k < 720; k++) { const th = k * Math.PI / 720, c = Math.cos(th), s = Math.sin(th);
        for (let r = 0.01; r < 14; r += 0.01) { const x1 = r * c, x2 = r * s, y = x1 + x2;
          if ((a - 2) * x1 * x2 - x1 * x1 - y * Math.sin(y) >= 0) { best = Math.min(best, a * x1 * x1 / 2 + x1 * x2 + x2 * x2 / 2); break; } } }
      return best;
    }
    const curva = []; for (let a = 1.05; a <= 6.001; a += 0.05) { const c = cstar(a); curva.push([a, Math.PI * c / Math.sqrt(a / 4 - 1 / 4)]); }
    let T1;
    function dib() {
      const a = e.a, cs = cstar(a), area = Math.PI * cs / Math.sqrt(a / 4 - 1 / 4);
      T1 = ejes(s1, 360, 360, {l: 34, r: 8, t: 10, b: 30}, [-L, L], [-L, L], 'x₁', 'x₂');
      let q = ''; const n = 120, d = 2 * L / n;
      for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) { const x1 = -L + (i + 0.5) * d, x2 = -L + (j + 0.5) * d, y = x1 + x2;
        if ((a - 2) * x1 * x2 - x1 * x1 - y * Math.sin(y) > 0) q += `<rect x="${T1.X(-L + i * d)}" y="${T1.Y(-L + (j + 1) * d)}" width="${T1.X(d) - T1.X(0) + 0.5}" height="${T1.Y(0) - T1.Y(d) + 0.5}" fill="${C.coral}" fill-opacity="0.22" shape-rendering="crispEdges"/>`; }
      s1.insertAdjacentHTML('beforeend', q);
      if (isFinite(cs) && cs > 1e-4) {   // elipse a x1²/2 + x1 x2 + x2²/2 = cs
        linea(s1, Array.from({length: 181}, (_, i) => { const u = [Math.cos(i * Math.PI / 90), Math.sin(i * Math.PI / 90)];
          const r = Math.sqrt(cs / (a * u[0] ** 2 / 2 + u[0] * u[1] + u[1] ** 2 / 2)); return [T1.X(r * u[0]), T1.Y(r * u[1])]; }), C.azul, 2.4);
      }
      const tr = simT(F, e.x0, 30, 0.01); linea(s1, tr.map(z => [T1.X(z[1]), T1.Y(z[2])]), C.noche, 1.3);
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4.5" fill="${C.ambar}"/>`);
      const T2 = ejes(s2, 380, 360, {l: 40, r: 8, t: 10, b: 30}, [1, 6], [0, 42], 'a₁₁', 'área del estimado');
      linea(s2, curva.map(z => [T2.X(z[0]), T2.Y(z[1])]), C.azul, 2);
      s2.insertAdjacentHTML('beforeend', `<circle cx="${T2.X(2)}" cy="${T2.Y(Math.PI ** 3)}" r="4" fill="${C.coral}"/><circle cx="${T2.X(a)}" cy="${T2.Y(Math.min(area, 41))}" r="6" fill="${C.ambar}"/>`);
      const Vx0 = a * e.x0[0] ** 2 / 2 + e.x0[0] * e.x0[1] + e.x0[1] ** 2 / 2, fin = tr[tr.length - 1];
      res.innerHTML = `a₁₁ = ${f(a, 2)}: V ${a > 1 ? 'es' : '<b>no</b> es'} definida positiva; V̇ ${(a - 4) ** 2 < 8 ? 'es' : '<b>no</b> es'} definida negativa cerca del origen (hace falta 1.17 &lt; a₁₁ &lt; 6.83). ` +
        `c* = <b>${f(cs)}</b>, área del estimado = <b>${f(area, 1)}</b> (con a₁₁ = 2: π³ = 31.0; máximo ≈ 37.4 en a₁₁ ≈ 1.48).<br>` +
        `x₀ ${Vx0 < cs ? 'está' : '<b>no</b> está'} en el estimado; x(30) = (${f(fin[1])}, ${f(fin[2])})` + (Vx0 >= cs && Math.hypot(fin[1], fin[2]) < 0.01 ? ': <b style="color:#2A9D8F">converge aunque arrancó fuera: el estimado es conservador.</b>' : '.');
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 360, py = (ev.clientY - r.top) / r.height * 360;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib();
  })();

  // ---------------------------------------------------------------- 3. Zubov
  (function () {
    const p = panel('zubov'), e = {x0: [1.9, 0.5]};
    p.insertAdjacentHTML('beforeend', '<p>x₁′ = −x₁ + 2x₁²x₂, x₂′ = −x₂. La solución de Zubov es W = x₂²/2 + x₁²/(2(1 − x₁x₂)), V = 1 − e<sup>−W</sup>. Azul: {V ≤ c}; coral: la hipérbola x₁x₂ = 1, frontera exacta de la región de atracción. Suba c hacia 1 y vea cómo el nivel se pega a la hipérbola. <b>Haga clic</b> a ambos lados de la hipérbola.</p>');
    controles(p, [['c', 'nivel c', 0.05, 0.999, 0.9, 0.001]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 420 420" style="cursor:crosshair;max-width:520px;margin:auto"></svg>');
    const s1 = p.querySelector('svg'), res = p.querySelector('.exp-resumen'), L = 3;
    const F = x => [-x[0] + 2 * x[0] ** 2 * x[1], -x[1]];
    const Vz = (a, b) => (a * b < 1 ? 1 - Math.exp(-(b * b / 2 + a * a / (2 * (1 - a * b)))) : 1);
    let T1;
    function dib() {
      T1 = ejes(s1, 420, 420, {l: 34, r: 8, t: 10, b: 30}, [-L, L], [-L, L], 'x₁', 'x₂');
      flechas(s1, F, [-L, L], [-L, L], T1, 15);
      pintarNivel(s1, T1, [-L, L], [-L, L], Vz, e.c, 140, false, 0.25);
      linea(s1, Array.from({length: 200}, (_, i) => { const x = 1 / L + i * (L - 1 / L) / 199; return [T1.X(x), T1.Y(1 / x)]; }), C.coral, 2.4);
      linea(s1, Array.from({length: 200}, (_, i) => { const x = 1 / L + i * (L - 1 / L) / 199; return [T1.X(-x), T1.Y(-1 / x)]; }), C.coral, 2.4);
      const tr = simT(F, e.x0, 15, 0.005); linea(s1, tr.map(z => [T1.X(z[1]), T1.Y(z[2])]), C.noche, 1.4);
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4.5" fill="${C.ambar}"/>`);
      const w = e.x0[0] * e.x0[1];
      res.innerHTML = `x₀ = (${f(e.x0[0], 2)}, ${f(e.x0[1], 2)}): w = x₁x₂ = <b>${f(w, 3)}</b>, ${w < 1 ? `W(x₀) = ${f(e.x0[1] ** 2 / 2 + e.x0[0] ** 2 / (2 * (1 - w)), 3)}, V(x₀) = 1 − e<sup>−W</sup> = ${f(Vz(...e.x0), 6)}` : 'W = ∞ (fuera de la región)'}. ` +
        (tr.escape ? '<b style="color:#D1495B">Escapa en tiempo finito</b> (w′ = −2w(1 − w) &gt; 0).' : '<b style="color:#2A9D8F">Converge al origen.</b>');
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 420, py = (ev.clientY - r.top) / r.height * 420;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib();
  })();
})();
