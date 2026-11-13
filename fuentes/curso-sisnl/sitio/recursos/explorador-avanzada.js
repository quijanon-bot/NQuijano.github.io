// Explorador de estabilidad avanzada (parte 10). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-avanzada"></div>
//       <script src="../recursos/explorador-avanzada.js"></script>
// Cuatro pestañas: acotamiento último (conjuntos de nivel y cota), la fórmula de Sontag,
// estabilizar contra robustecer (ISS) e interconexiones (cascadas y pequeña ganancia).
// Los modelos son los de codigo/cap10_avanzada.
(function () {
  const raiz = document.getElementById('explorador-avanzada');
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
  montarPestanas([['uub', 'Acotamiento último'], ['sontag', 'Fórmula de Sontag'], ['iss', 'Estabilizar o robustecer'], ['inter', 'Interconexiones']]);

  // RK4 escalar o vectorial con t explícito; se detiene si |x| > lim
  function sim(F, x0, T, h, lim = 1e6) {
    let x = x0.slice(), t = 0; const out = [[0, ...x]];
    const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(t, x), k2 = F(t + h / 2, x.map((v, j) => v + h / 2 * k1[j])), k3 = F(t + h / 2, x.map((v, j) => v + h / 2 * k2[j])), k4 = F(t + h, x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j])); t += h;
      if (!x.every(isFinite) || Math.max(...x.map(Math.abs)) > lim) { out.push([t, ...x.map(v => Math.sign(v) * lim)]); out.escape = t; break; }
      out.push([t, ...x]);
    }
    return out;
  }
  const sontag = (lf, lg, kappa = 0) => (Math.abs(lg) < 1e-300 ? 0 : -(kappa + (lf + Math.sqrt(lf * lf + lg ** 4)) / (lg * lg)) * lg);
  // A'P + PA = -I para A de 2x2 (P = [p q; q r])
  function lyap2(A) {
    const [[a, b], [c, d]] = A;
    const M = [[2 * a, 2 * c, 0], [b, a + d, c], [0, 2 * b, 2 * d]], v = [-1, 0, -1];
    const det3 = m => m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
    const D = det3(M), s = [0, 1, 2].map(k => det3(M.map((fila, i) => fila.map((x, j) => (j === k ? v[i] : x)))) / D);
    return [[s[0], s[1]], [s[1], s[2]]];
  }

  // ---------------------------------------------------------------- 1. UUB
  (function () {
    const p = panel('uub'), e = {x0: [2.45, 0]};
    p.insertAdjacentHTML('beforeend', '<p>Oscilador x₁′ = x₂, x₂′ = −k x₁ − c x₂ + w(t), con w = W sen(ωt). Con V = xᵀPx (AᵀP + PA = −I), V decrece fuera de la bola B<sub>μ</sub>, μ = 2‖PB‖W/θ (coral). Las trayectorias quedan en Ω<sub>η</sub> = {V ≤ λ<sub>max</sub>μ²} (azul), y la cota garantizada es b = μ√(λ<sub>max</sub>/λ<sub>min</sub>) (verde). <b>Haga clic</b> en el plano para cambiar la condición inicial.</p>');
    controles(p, [['k', 'rigidez k', 0.5, 9, 4, 0.1], ['c', 'amortiguamiento c', 0.05, 3, 0.2, 0.05], ['W', 'amplitud W', 0, 1, 0.2, 0.01],
                  ['om', 'frecuencia ω', 0.2, 4, 1.3, 0.05], ['th', 'fracción θ', 0.05, 0.95, 0.5, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1.2fr;gap:.5rem"><svg viewBox="0 0 360 360" style="cursor:crosshair"></svg><svg viewBox="0 0 420 360"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    let T1, L = 6;
    function dib() {
      const A = [[0, 1], [-e.k, -e.c]], P = lyap2(A), tr = P[0][0] + P[1][1], de = P[0][0] * P[1][1] - P[0][1] ** 2;
      const lM = tr / 2 + Math.sqrt(tr * tr / 4 - de), lm = tr / 2 - Math.sqrt(tr * tr / 4 - de);
      const nPB = Math.hypot(P[0][1], P[1][1]), mu = 2 * nPB * e.W / e.th, eta = lM * mu * mu, b = mu * Math.sqrt(lM / lm);
      L = Math.max(1.3 * Math.max(b, Math.hypot(...e.x0)), 0.5);
      const tray = sim((t, x) => [x[1], -e.k * x[0] - e.c * x[1] + e.W * Math.sin(e.om * t)], e.x0, 40, 0.01);
      T1 = ejes(s1, 360, 360, {l: 38, r: 8, t: 10, b: 32}, [-L, L], [-L, L], 'x₁', 'x₂');
      const circ = r => Array.from({length: 121}, (_, i) => [T1.X(r * Math.cos(i * Math.PI / 60)), T1.Y(r * Math.sin(i * Math.PI / 60))]);
      const elip = c => Array.from({length: 121}, (_, i) => { const u = [Math.cos(i * Math.PI / 60), Math.sin(i * Math.PI / 60)];
        const q = P[0][0] * u[0] ** 2 + 2 * P[0][1] * u[0] * u[1] + P[1][1] * u[1] ** 2, r = Math.sqrt(c / q); return [T1.X(r * u[0]), T1.Y(r * u[1])]; });
      if (mu > 0) { linea(s1, circ(mu), C.coral, 1.8); linea(s1, elip(eta), C.azul, 2.6); linea(s1, circ(b), C.verde, 1.6, '5 4'); }
      linea(s1, tray.map(z => [T1.X(z[1]), T1.Y(z[2])]), C.noche, 1);
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4" fill="${C.ambar}"/>`);
      const nx = tray.map(z => Math.hypot(z[1], z[2])), V = tray.map(z => P[0][0] * z[1] ** 2 + 2 * P[0][1] * z[1] * z[2] + P[1][1] * z[2] ** 2);
      const ym = Math.max(1.15 * Math.max(...nx), 1.1 * b, 0.1);
      const T2 = ejes(s2, 420, 360, {l: 40, r: 8, t: 10, b: 32}, [0, 40], [0, ym], 't', '‖x(t)‖');
      linea(s2, tray.map((z, i) => [T2.X(z[0]), T2.Y(nx[i])]), C.noche, 1.6);
      linea(s2, [[T2.X(0), T2.Y(mu)], [T2.X(40), T2.Y(mu)]], C.coral, 1.4, '5 4');
      linea(s2, [[T2.X(0), T2.Y(b)], [T2.X(40), T2.Y(b)]], C.verde, 1.4, '5 4');
      const sale = nx.some(v => v > mu * 1.0001) && Math.hypot(...e.x0) <= mu, maxV = Math.max(...V.slice(Math.floor(V.length / 2)));
      const lim = Math.max(...nx.slice(Math.floor(nx.length * 3 / 4)));
      res.innerHTML = `P = [${f(P[0][0])} ${f(P[0][1])}; ${f(P[1][0])} ${f(P[1][1])}], λ = ${f(lm)}, ${f(lM)}; μ = <b>${f(mu)}</b>, b = <b>${f(b)}</b> (b/μ = ${f(b / (mu || 1), 2)}).<br>` +
        `max ‖x‖ = ${f(Math.max(...nx))}; ‖x‖ en el último cuarto ≤ ${f(lim)}. ` + (sale ? '<b style="color:#D1495B">La trayectoria nació dentro de B<sub>μ</sub> y salió de ella.</b> ' : '') +
        (eta > 0 && V[0] <= eta ? (Math.max(...V) <= eta * 1.0001 ? '<b style="color:#2A9D8F">Nunca salió de Ω<sub>η</sub>.</b>' : '') : `V(x₀)/η = ${f(V[0] / (eta || 1), 2)}: empieza fuera de Ω<sub>η</sub>; en la segunda mitad, max V/η = ${f(maxV / (eta || 1), 2)}.`);
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 360, py = (ev.clientY - r.top) / r.height * 360;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib();
  })();

  // ---------------------------------------------------------------- 2. Sontag
  (function () {
    const p = panel('sontag'), e = {};
    const ej = {
      lin: {t: 'x′ = f₀x + g₀u, V = x²/2', par: [['f0', 'f₀', -5, 5, 1, 0.1], ['g0', 'g₀', 0.1, 3, 1, 0.05], ['x0', 'x(0)', -3, 3, 2, 0.1]],
            F: e => (x, u) => e.f0 * x + e.g0 * u, uS: e => x => sontag(e.f0 * x * x, e.g0 * x), uA: e => x => -(e.f0 + 1) * x / e.g0, A: 'cancelar y poner −x', T: 6},
      cos: {t: 'x′ = cos x − x³ + u (Sontag sobre x′ = −x³ + uₛ)', par: [['x0', 'x(0)', -3, 3, 2, 0.1]],
            F: e => (x, u) => Math.cos(x) - x ** 3 + u, uS: e => x => -Math.cos(x) + sontag(-(x ** 4), x), uA: e => x => -Math.cos(x) + x ** 3 - x, A: 'linealización exacta', T: 6},
      peq: {t: 'x′ = x + x²u: falla el control pequeño', par: [['x0', 'x(0)', 0.2, 2, 1, 0.05]],
            F: e => (x, u) => x + x * x * u, uS: e => x => sontag(x * x, x ** 3), uA: null, T: 8},
      cub: {t: 'x′ = x − x³ + u', par: [['x0', 'x(0)', -4, 4, 3, 0.1]],
            F: e => (x, u) => x - x ** 3 + u, uS: e => x => sontag(x * x - x ** 4, x), uA: e => x => -2 * x + x ** 3, A: 'cancelar −x³ (u = −2x + x³)', T: 8},
    };
    const dib = (cambio) => {
      const s = ej[e.ej];
      if (cambio === true) { ctl.innerHTML = ''; s.par.forEach(q => delete e[q[0]]); controles(ctl, s.par, e, () => dib()); }
      const F = s.F(e), uS = s.uS(e), uA = s.uA ? s.uA(e) : null;
      const corr = u => { const r = sim((t, z) => [F(z[0], u(z[0])), u(z[0]) ** 2], [e.x0, 0], s.T, 0.002, 1e5);
        return r.map(z => [z[0], z[1], u(z[1]), z[2]]); };
      const rS = corr(uS), rA = uA ? corr(uA) : null;
      const xs = rS.concat(rA || []).map(z => z[1]), us = rS.concat(rA || []).map(z => z[2]).filter(isFinite);
      const xr = [Math.min(0, ...xs) * 1.1 - 0.05, Math.max(0, ...xs) * 1.1 + 0.05];
      let ur = [Math.min(0, ...us), Math.max(0, ...us)]; ur = [ur[0] - 0.1 * (ur[1] - ur[0]) - 0.05, ur[1] + 0.1 * (ur[1] - ur[0]) + 0.05];
      if (e.ej === 'peq') ur = [Math.max(ur[0], -60), 1];
      const T1 = ejes(s1, 380, 300, {l: 42, r: 8, t: 10, b: 32}, [0, s.T], xr, 't', 'x');
      const T2 = ejes(s2, 380, 300, {l: 42, r: 8, t: 10, b: 32}, [0, s.T], ur, 't', 'u');
      const cl = (T, y, r) => (y < r[0] || y > r[1] ? NaN : T.Y(y));
      [[rS, C.azul], [rA, C.coral]].forEach(([r, c]) => { if (!r) return;
        linea(s1, r.map(z => [T1.X(z[0]), T1.Y(z[1])]), c, 2); linea(s2, r.map(z => [T2.X(z[0]), cl(T2, z[2], ur)]), c, 2); });
      const fin = r => r[r.length - 1], t01 = r => { const z = r.find(z => Math.abs(z[1]) < 0.01); return z ? f(z[0], 2) : '—'; };
      res.innerHTML = `<b>${s.t}</b>. <span style="color:${C.azul}">Sontag</span>: u(0) = ${f(uS(e.x0))}, u(${s.T}) = ${f(fin(rS)[2])}, ∫u² = ${f(fin(rS)[3], 2)}, |x| &lt; 0.01 en t = ${t01(rS)}.` +
        (rA ? `<br><span style="color:${C.coral}">${s.A}</span>: u(0) = ${f(uA(e.x0))}, u(${s.T}) = ${f(fin(rA)[2])}, ∫u² = ${f(fin(rA)[3], 2)}, |x| &lt; 0.01 en t = ${t01(rA)}.` : '<br>No existe ley continua: |u| crece sin cota cuando x → 0 (Artstein).');
    };
    p.insertAdjacentHTML('beforeend', '<p>La fórmula universal u = −(L<sub>f</sub>V + √((L<sub>f</sub>V)² + (L<sub>g</sub>V)⁴))/L<sub>g</sub>V (azul) contra una ley que cancela (coral). Compare el esfuerzo inicial, el control en régimen y la energía ∫u² dt.</p>');
    selector(p, 'ej', 'Ejemplo', [['lin', 'Planta lineal escalar'], ['cos', 'cos x − x³ + u'], ['peq', 'x + x²u (control pequeño)'], ['cub', 'x − x³ + u']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 380 300"></svg><svg viewBox="0 0 380 300"></svg></div>');
    const ctl = p.querySelector('.exp-ctl'), [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib(true);
  })();

  // ---------------------------------------------------------------- 3. ISS
  (function () {
    const p = panel('iss'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>Planta x′ = x + (x² + 1)(u + w), con w un error constante en el actuador. Tres leyes que estabilizan cuando w = 0: <span style="color:#D1495B">cancelación exacta</span> k = −2x/(x²+1), <span style="color:#1E5AA8">con amortiguamiento</span> k − L<sub>g</sub>V y <span style="color:#2A9D8F">Sontag con κ</span>.</p>');
    controles(p, [['w', 'error w', 0, 1.5, 1, 0.01], ['x0', 'x(0)', -2, 15, 0, 0.1], ['ka', 'κ (Sontag)', 0, 3, 1, 0.1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 380 300"></svg><svg viewBox="0 0 380 300"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    function dib() {
      const k = x => -2 * x / (x * x + 1), leyes = [[k, C.coral, 'cancelación'], [x => k(x) - x * (x * x + 1), C.azul, 'con −L_gV'],
        [x => sontag(x * x, x * (x * x + 1), e.ka), C.verde, 'Sontag']];
      const T1 = ejes(s1, 380, 300, {l: 42, r: 8, t: 10, b: 32}, [0, 10], [-2, 16], 't', 'x'); let txt = [];
      for (const [u, c, nom] of leyes) {
        const r = sim((t, z) => [z[0] + (z[0] ** 2 + 1) * (u(z[0]) + e.w)], [e.x0], 10, 0.002, 1e4);
        linea(s1, r.map(z => [T1.X(z[0]), z[1] > 16 ? NaN : T1.Y(z[1])]), c, 2);
        txt.push(`<span style="color:${c}">${nom}</span>: ` + (r.escape ? `<b>escapa en t ≈ ${f(r.escape, 2)}</b>` : `x(10) = ${f(r[r.length - 1][1], 4)}`));
      }
      const xx = Array.from({length: 241}, (_, i) => -2 + 18 * i / 240);
      const T2 = ejes(s2, 380, 300, {l: 42, r: 8, t: 10, b: 32}, [-2, 16], [-6, 10], 'x', 'ẋ (cancelación)');
      linea(s2, xx.map(x => [T2.X(x), Math.abs(-x + (x * x + 1) * e.w) > 10 ? NaN : T2.Y(-x + (x * x + 1) * e.w)]), C.coral, 2);
      linea(s2, [[T2.X(e.x0), T2.Y(-6)], [T2.X(e.x0), T2.Y(10)]], C.ambar, 1, '3 3');
      let umb = '';
      if (e.w > 0 && e.w <= 0.5) { const d = Math.sqrt(1 - 4 * e.w * e.w), xm = (1 - d) / (2 * e.w), xp = (1 + d) / (2 * e.w);
        umb = `Con la cancelación, x₋ = ${f(xm)} atrae y toda condición inicial por encima de x₊ = ${f(xp)} ≈ 1/w escapa.`;
        punto(s2, T2, [xm, 0], true); if (xp < 16) punto(s2, T2, [xp, 0], false); }
      else if (e.w > 0.5) umb = 'Con w &gt; 1/2 el campo de la cancelación no tiene ceros: escapa desde cualquier x(0).';
      res.innerHTML = txt.join(' · ') + '<br>' + umb;
    }
    dib();
  })();

  // ---------------------------------------------------------------- 4. Interconexiones
  (function () {
    const p = panel('inter'), e = {pts: []};
    const sis = {
      ret: {t: 'x₁′ = −x₁ + a x₂,  x₂′ = −x₂ + b sen x₁', par: [['a', 'a', -3, 3, 1, 0.05], ['b', 'b', -3, 3, 1.2, 0.05]], L: 3.5,
            F: e => x => [-x[0] + e.a * x[1], -x[1] + e.b * Math.sin(x[0])]},
      c1: {t: 'cascada x₁′ = −x₁ + x₁²x₂,  x₂′ = −x₂', par: [], L: 4, F: e => x => [-x[0] + x[0] ** 2 * x[1], -x[1]]},
      c2: {t: 'cascada x₁′ = −x₁ + x₁x₂²,  x₂′ = −x₂', par: [], L: 4, F: e => x => [-x[0] + x[0] * x[1] ** 2, -x[1]]},
    };
    let T;
    const dib = (cambio) => {
      const s = sis[e.sis];
      if (cambio === true) { ctl.innerHTML = ''; e.pts = []; controles(ctl, s.par, e, () => dib()); }
      const F = s.F(e), L = s.L;
      T = ejes(svg, 420, 380, {l: 38, r: 8, t: 10, b: 32}, [-L, L], [-L, L], 'x₁', 'x₂'); flechas(svg, F, [-L, L], [-L, L], T, 17);
      const cl = x => (Math.abs(x[0]) > L || Math.abs(x[1]) > L ? [NaN, NaN] : [T.X(x[0]), T.Y(x[1])]);
      if (e.sis === 'c1') { const hh = Array.from({length: 200}, (_, i) => 0.55 + (L - 0.55) * i / 199);
        linea(svg, hh.map(x => cl([x, 2 / x])), C.coral, 1.5, '6 4'); linea(svg, hh.map(x => cl([-x, -2 / x])), C.coral, 1.5, '6 4'); }
      const ini = e.pts.length ? e.pts : [[-3, 2.8], [3, -2.8], [3, 2.8], [-3, -2.8], [0.3, 0.05], [-0.3, -0.05], [1, 1.5], [2, 1.5]];
      let txtEsc = '';
      for (const x0 of ini) {
        const r = rk4(F, x0, 25, 0.005, [-50 * L, 50 * L, -50 * L, 50 * L]);
        linea(svg, r.map(cl), C.azul, 1.4);
        svg.insertAdjacentHTML('beforeend', `<circle cx="${T.X(x0[0])}" cy="${T.Y(x0[1])}" r="3" fill="${C.ambar}"/>`);
        if (e.sis === 'c1' && e.pts.length && x0 === ini[ini.length - 1]) txtEsc = x0[0] * x0[1] > 2 ? ` Último punto: x₁₀x₂₀ = ${f(x0[0] * x0[1], 2)} &gt; 2, escapa en t = ${f(0.5 * Math.log(x0[0] * x0[1] / (x0[0] * x0[1] - 2)), 3)}.` : ` Último punto: x₁₀x₂₀ = ${f(x0[0] * x0[1], 2)} ≤ 2, no escapa.`;
      }
      let txt = `<b>${s.t}</b>. `;
      if (e.sis === 'ret') {
        const ab = e.a * e.b, eqs = [[0, 0]];
        if (ab > 1) { let x = 2; for (let k = 0; k < 80; k++) x -= (x - ab * Math.sin(x)) / (1 - ab * Math.cos(x)); if (Math.abs(x) > 1e-6) { eqs.push([x, x / e.a], [-x, -x / e.a]); } }
        eqs.forEach(x => punto(svg, T, x, clasificar(jacNum(F, x)).tipo.includes('estable') && !clasificar(jacNum(F, x)).tipo.includes('inestable')));
        txt += `γ₁γ₂ = |ab| = ${f(Math.abs(ab))}: ` + (Math.abs(ab) < 1 ? '<b style="color:#2A9D8F">pequeña ganancia: GAS</b>.' : '<b style="color:#D1495B">la pequeña ganancia no se cumple</b>.') +
          ` Origen: ${clasificar(jacNum(F, [0, 0])).tipo} (λ = ${txtEig(clasificar(jacNum(F, [0, 0])).ev)}).` + (eqs.length > 1 ? ` Otros equilibrios en x₁ = ±${f(eqs[1][0])}, ${clasificar(jacNum(F, eqs[1])).tipo}.` : '');
      } else if (e.sis === 'c1') txt += 'Las dos partes son GAS por separado; la hipérbola x₁x₂ = 2 (coral) separa las condiciones iniciales que escapan.' + txtEsc;
      else txt += 'No escapa: x₁(t) = x₁₀ exp(−t + x₂₀²(1 − e^{−2t})/2). El transitorio puede ser grande, pero el origen es GAS. Sin embargo, x₁ no es ISS respecto a x₂.';
      res.innerHTML = txt + ' <i>Haga clic para lanzar trayectorias.</i>';
    };
    p.insertAdjacentHTML('beforeend', '<p>Cascadas y retroalimentaciones. En la retroalimentación, cada subsistema es ISS con ganancias |a| y |b|: la condición de pequeña ganancia es |ab| &lt; 1. Pruebe ab = 1.2 y ab = −3.</p>');
    selector(p, 'sis', 'Sistema', [['ret', 'Retroalimentación con sen x₁'], ['c1', 'Cascada que escapa'], ['c2', 'Cascada con transitorio grande']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><svg viewBox="0 0 420 380" style="max-width:520px;cursor:crosshair"></svg>');
    const ctl = p.querySelector('.exp-ctl'), svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    svg.addEventListener('click', ev => { const r = svg.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 420, py = (ev.clientY - r.top) / r.height * 380;
      e.pts.push([T.Xi(px), T.Yi(py)]); dib(); });
    dib(true);
  })();
})();
