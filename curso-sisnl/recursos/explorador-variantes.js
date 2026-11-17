// Explorador de sistemas variantes en el tiempo (parte 9). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-variantes"></div>
//       <script src="../recursos/explorador-variantes.js"></script>
// Tres pestañas: la hora de arranque (uniformidad), sistemas lineales periódicos (Mathieu,
// Markus--Yamabe, ganancia variable: valores propios congelados contra multiplicadores de Floquet)
// e inestabilidad (Cetaev, los dos teoremas, la silla y van der Pol).
// Los modelos son los de codigo/cap09_variantes.
(function () {
  const raiz = document.getElementById('explorador-variantes');
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
  // RK4 variante en el tiempo: F(t, x); se detiene si ||x|| > lim
  function simTV(F, t0, x0, T, h, lim = 1e6) {
    let x = x0.slice(), t = t0; const out = [[t, ...x]]; const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(t, x), k2 = F(t + h / 2, x.map((v, j) => v + h / 2 * k1[j])), k3 = F(t + h / 2, x.map((v, j) => v + h / 2 * k2[j])), k4 = F(t + h, x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j])); t += h;
      if (!x.every(isFinite) || Math.hypot(...x) > lim) { out.escape = t; break; }
      out.push([t, ...x]);
    }
    return out;
  }
  const eig2 = A => { const tr = A[0][0] + A[1][1], de = A[0][0] * A[1][1] - A[0][1] * A[1][0], di = tr * tr / 4 - de;
    return di >= 0 ? [[tr / 2 - Math.sqrt(di), 0], [tr / 2 + Math.sqrt(di), 0]] : [[tr / 2, -Math.sqrt(-di)], [tr / 2, Math.sqrt(-di)]]; };
  const txtEig = ev => ev.map(([re, im]) => (Math.abs(im) < 1e-9 ? f(re, 4) : `${f(re, 4)} ${im < 0 ? '−' : '+'} ${f(Math.abs(im), 4)}j`)).join(', ');
  montarPestanas([['arranque', 'La hora de arranque'], ['periodicos', 'Lineales periódicos'], ['inestab', 'Inestabilidad']]);

  // ---------------------------------------------------------------- 1. La hora de arranque
  (function () {
    const p = panel('arranque'), e = {};
    const tasas = {
      inv: ['a(t) = 1/(1 + t)', t => 1 / (1 + t), t0 => 9 * (1 + t0), () => 0, 'US y AS, no UAS: T(0.1) = 9(1 + t₀) crece sin cota'],
      raiz: ['a(t) = 1/√(1 + t)', t => 1 / Math.sqrt(1 + t), t0 => Math.log(10) * Math.sqrt(1 + t0) + Math.log(10) ** 2 / 4, () => 0, 'US y AS, no UAS: T crece como √t₀'],
      cuad: ['a(t) = 1/(1 + t)²', t => 1 / (1 + t) ** 2, () => Infinity, t0 => Math.exp(-1 / (1 + t0)), 'US, pero NO AS: x → x₀e^(−1/(1+t₀)) aunque V̇ < 0'],
      sen: ['a(t) = 2 + sen t', t => 2 + Math.sin(t), null, () => 0, 'GES: 1 ≤ a(t) ≤ 3, la tasa no se apaga'],
    };
    p.insertAdjacentHTML('beforeend', '<p>ẋ = −a(t)x con x(t₀) = 1. Las dos curvas usan la misma condición inicial; solo cambia la hora de arranque. Se grafican contra el tiempo transcurrido s = t − t₀. La línea punteada es 0.1.</p>');
    selector(p, 'a', 'Tasa', Object.entries(tasas).map(([k, v]) => [k, v[0]]), e, () => dib());
    controles(p, [['t0', 't₀ (azul)', 0, 300, 100, 1], ['S', 'ventana en s', 10, 2000, 1000, 10]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 330"></svg>');
    const s1 = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    function dib() {
      const [nom, a, Tf, lim, txt] = tasas[e.a], S = e.S;
      const T = ejes(s1, 760, 330, {l: 42, r: 10, t: 10, b: 32}, [0, S], [0, 1.05], 's = t − t₀', 'x');
      linea(s1, [[T.X(0), T.Y(0.1)], [T.X(S), T.Y(0.1)]], C.gris, 1, '5 4');
      const tr0 = simTV((t, x) => [-a(t) * x[0]], 0, [1], S, S / 20000), tr1 = simTV((t, x) => [-a(t) * x[0]], e.t0, [1], S, S / 20000);
      linea(s1, tr0.map(z => [T.X(z[0]), T.Y(z[1])]), C.coral, 2);
      linea(s1, tr1.map(z => [T.X(z[0] - e.t0), T.Y(z[1])]), C.azul, 2.4);
      const cruce = tr => { const k = tr.findIndex(z => z[1] < 0.1); return k < 0 ? null : tr[k][0] - tr[0][0]; };
      const c0 = cruce(tr0), c1 = cruce(tr1);
      res.innerHTML = `<b>${nom}</b>: ${txt}.<br><span style="color:#D1495B">t₀ = 0</span>: ${c0 === null ? 'no baja de 0.1 en la ventana' : 'baja de 0.1 en s = ' + f(c0, 2)}` +
        (Tf ? ` (fórmula ${f(Tf(0), 2)})` : '') + `; <span style="color:#1E5AA8">t₀ = ${e.t0}</span>: ${c1 === null ? 'no baja de 0.1 en la ventana' : 'baja de 0.1 en s = ' + f(c1, 2)}` +
        (Tf && isFinite(Tf(e.t0)) ? ` (fórmula ${f(Tf(e.t0), 2)})` : '') + (e.a === 'cuad' ? `. Límite: ${f(lim(e.t0), 4)}.` : '.');
    }
    dib();
  })();

  // ---------------------------------------------------------------- 2. Lineales periódicos
  (function () {
    const p = panel('periodicos'), e = {x0: [1, 0]};
    const sis = {
      math: {t: 'Mathieu amortiguada: ẋ₁ = x₂, ẋ₂ = −b x₂ − (k₀ + k₁ sen t) x₁', par: [['b', 'amortiguamiento b', 0, 2, 1, 0.05], ['k0', 'k₀', 0.5, 4, 2, 0.05], ['k1', 'k₁', 0, 3, 1, 0.05]],
             A: (e, t) => [[0, 1], [-(e.k0 + e.k1 * Math.sin(t)), -e.b]], P: () => 2 * Math.PI, L: 2.5},
      my: {t: 'Markus–Yamabe: A(t) con valores propios −1/4 ± j√7/4 para todo t (a = 1.5 es el ejemplo)', par: [['aa', 'a', 0, 2, 1.5, 0.05]],
           A: (e, t) => { const c = Math.cos(t), s = Math.sin(t), a = e.aa; return [[-1 + a * c * c, 1 - a * s * c], [-1 - a * s * c, -1 + a * s * s]]; }, P: () => Math.PI, L: 20},
      gan: {t: 'Ganancia variable: ẋ₁ = −x₁ − g(t) x₂, ẋ₂ = x₁ − x₂ con g = (1 + sen ωt)/2', par: [['w', 'ω', 0.1, 12, 10, 0.1]],
            A: (e, t) => [[-1, -(1 + Math.sin(e.w * t)) / 2], [1, -1]], P: e => 2 * Math.PI / e.w, L: 1.5},
    };
    p.insertAdjacentHTML('beforeend', '<p>Izquierda: la solución desde x₀ (<b>haga clic</b> para cambiarla). Derecha: ‖x(t)‖ en escala logarítmica. El resumen compara los valores propios “congelados” de A(t) con los <b>multiplicadores de Floquet</b> (valores propios de la matriz de monodromía Φ(τ, 0)), que son los que deciden.</p>');
    selector(p, 'sis', 'Sistema', [['math', 'Mathieu amortiguada'], ['my', 'Markus–Yamabe'], ['gan', 'Ganancia variable']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-ctl"></div><div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1.2fr;gap:.5rem"><svg viewBox="0 0 360 330" style="cursor:crosshair"></svg><svg viewBox="0 0 420 330"></svg></div>');
    const ctl = p.querySelector('.exp-ctl'), [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    let T1;
    function dib(cambio) {
      const s = sis[e.sis];
      if (cambio === true || !ctl.innerHTML) { ctl.innerHTML = ''; s.par.forEach(q => delete e[q[0]]); controles(ctl, s.par, e, () => dib()); e.x0 = [1, 0]; }
      const F = (t, x) => { const A = s.A(e, t); return [A[0][0] * x[0] + A[0][1] * x[1], A[1][0] * x[0] + A[1][1] * x[1]]; };
      const tau = s.P(e), h = tau / Math.max(200, Math.ceil(tau / 0.01));
      const c1 = simTV(F, 0, [1, 0], tau, h), c2 = simTV(F, 0, [0, 1], tau, h);
      const M = [[c1[c1.length - 1][1], c2[c2.length - 1][1]], [c1[c1.length - 1][2], c2[c2.length - 1][2]]];
      const mu = eig2(M), modmu = Math.max(...mu.map(([r, i]) => Math.hypot(r, i)));
      let remin = Infinity, remax = -Infinity;
      for (let k = 0; k < 200; k++) { const ev = eig2(s.A(e, k * tau / 200)); ev.forEach(([r]) => { remin = Math.min(remin, r); remax = Math.max(remax, r); }); }
      const L = s.L, TT = 20, tr = simTV(F, 0, e.x0, TT, 0.005, 1e8);
      T1 = ejes(s1, 360, 330, {l: 36, r: 8, t: 10, b: 30}, [-L, L], [-L, L], 'x₁', 'x₂');
      linea(s1, tr.map(z => [T1.X(Math.max(-5 * L, Math.min(5 * L, z[1]))), T1.Y(Math.max(-5 * L, Math.min(5 * L, z[2])))]), C.coral, 1.6);
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4.5" fill="${C.ambar}"/>`);
      const lg = tr.map(z => Math.log10(Math.max(Math.hypot(z[1], z[2]), 1e-12)));
      const ymin = Math.max(Math.min(...lg), -10), ymax = Math.max(...lg, 0.5);
      const T2 = ejes(s2, 420, 330, {l: 40, r: 8, t: 10, b: 30}, [0, TT], [ymin - 0.2, ymax + 0.2], 't', 'log₁₀ ‖x‖');
      linea(s2, tr.map((z, i) => [T2.X(z[0]), T2.Y(lg[i])]), C.coral, 2);
      const tasa = Math.log(modmu) / tau, n0 = Math.hypot(...e.x0);
      linea(s2, [[T2.X(0), T2.Y(Math.log10(n0))], [T2.X(TT), T2.Y(Math.log10(n0) + tasa * TT / Math.LN10)]], C.noche, 1, '5 4');
      res.innerHTML = `<b>${s.t}</b>. Periodo τ = ${f(tau, 4)}.<br>Valores propios congelados: Re λ entre <b>${f(remin, 4)}</b> y <b>${f(remax, 4)}</b> ` +
        `(${remax < 0 ? 'A(t) es Hurwitz para todo t' : 'A(t) no es Hurwitz en algunos instantes'}). ` +
        `Multiplicadores de Floquet: ${txtEig(mu)}, máx |μ| = <b>${f(modmu, 4)}</b> → ` +
        (modmu < 1 ? '<b style="color:#2A9D8F">exponencialmente estable</b>' : '<b style="color:#D1495B">inestable</b>') +
        `, tasa ln|μ|/τ = ${f(tasa, 4)} (línea punteada).`;
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 360, py = (ev.clientY - r.top) / r.height * 330;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib(true);
  })();

  // ---------------------------------------------------------------- 3. Inestabilidad
  (function () {
    const p = panel('inestab'), e = {};
    const sis = {
      cet: {t: 'Cetaev: ẋ₁ = x₁² + x₂³, ẋ₂ = −x₂ + x₁³ con V = x₁ − x₂²/2', L: 0.6, x0: [0.02, 0.1],
            F: x => [x[0] ** 2 + x[1] ** 3, -x[1] + x[0] ** 3], V: x => x[0] - x[1] ** 2 / 2, Vd: x => x[0] ** 2 + x[1] ** 2 + x[1] ** 3 - x[0] ** 3 * x[1], bola: 0.5},
      cetx1: {t: 'La trampa: el mismo sistema con V = x₁', L: 0.6, x0: [0.01, -0.1],
              F: x => [x[0] ** 2 + x[1] ** 3, -x[1] + x[0] ** 3], V: x => x[0], Vd: x => x[0] ** 2 + x[1] ** 3, bola: 0.5},
      t1: {t: 'Primer teorema: ẋ₁ = 2x₂ + x₁(x₁² + 2x₂⁴), ẋ₂ = −2x₁ + x₂(x₁² + x₂⁴), V = ‖x‖²/2', L: 1.2, x0: [0.25, 0],
           F: x => [2 * x[1] + x[0] * (x[0] ** 2 + 2 * x[1] ** 4), -2 * x[0] + x[1] * (x[0] ** 2 + x[1] ** 4)], V: x => (x[0] ** 2 + x[1] ** 2) / 2,
           Vd: x => x[0] ** 4 + x[0] ** 2 * x[1] ** 2 + 2 * x[0] ** 2 * x[1] ** 4 + x[1] ** 6, bola: 1},
      t2: {t: 'Segundo teorema: V = (x₁² − x₂²)/2, V̇ = 2V + 5x₁²x₂² (V̇ puede ser negativa)', L: 1, x0: [0.05, 0.02],
           F: x => [x[0] + 3 * x[1] * Math.sin(x[1]) ** 2 + 5 * x[0] * x[1] ** 2 * Math.sin(x[0]) ** 2, 3 * x[0] * Math.sin(x[1]) ** 2 + x[1] - 5 * x[0] ** 2 * x[1] * Math.cos(x[0]) ** 2],
           V: x => (x[0] ** 2 - x[1] ** 2) / 2, Vd: x => (x[0] ** 2 - x[1] ** 2) + 5 * x[0] ** 2 * x[1] ** 2, bola: 0.8},
      silla: {t: 'Silla: ẋ₁ = x₁, ẋ₂ = −x₂ con V = (x₁² − x₂²)/2 (indefinida) y V̇ = ‖x‖²', L: 1, x0: [0.05, 0.03],
              F: x => [x[0], -x[1]], V: x => (x[0] ** 2 - x[1] ** 2) / 2, Vd: x => x[0] ** 2 + x[1] ** 2, bola: 0.8},
      vdp: {t: 'Van der Pol (μ = 1): inestable y acotado; V = ‖x‖²/2, V̇ = (1 − x₁²)x₂² solo semidefinida', L: 3, x0: [0.01, 0],
            F: x => [x[1], -x[0] + (1 - x[0] ** 2) * x[1]], V: x => (x[0] ** 2 + x[1] ** 2) / 2, Vd: x => (1 - x[0] ** 2) * x[1] ** 2, bola: 1, semi: 'V̇ ≥ 0 en la bola, pero se anula en todo el eje x₂ = 0: no es definida positiva y el primer teorema no aplica (la inestabilidad sale del método indirecto). '},
    };
    p.insertAdjacentHTML('beforeend', '<p>Verde: la región U = {V &gt; 0} dentro de la bola (punteada). Coral: puntos de U donde V̇ ≤ 0 (si los hay, el teorema no aplica con esa V). <b>Haga clic</b> para lanzar una solución; a la derecha, V(x(t)).</p>');
    selector(p, 'sis', 'Sistema', [['cet', 'Cetaev'], ['cetx1', 'Cetaev con V = x₁ (trampa)'], ['t1', 'Primer teorema'], ['t2', 'Segundo teorema'], ['silla', 'Silla'], ['vdp', 'Van der Pol']], e, dib);
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1.15fr;gap:.5rem"><svg viewBox="0 0 360 340" style="cursor:crosshair"></svg><svg viewBox="0 0 400 340"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    let T1;
    function dib(cambio) {
      const s = sis[e.sis];
      if (cambio === true || !e.x0) e.x0 = s.x0.slice();
      const L = s.L, n = 120, d = 2 * L / n;
      T1 = ejes(s1, 360, 340, {l: 38, r: 8, t: 10, b: 30}, [-L, L], [-L, L], 'x₁', 'x₂');
      let q = '', malos = 0;
      for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) {
        const x = [-L + (i + 0.5) * d, -L + (j + 0.5) * d]; if (Math.hypot(...x) > s.bola || s.V(x) <= 0) continue;
        const malo = s.Vd(x) <= 0; if (malo) malos++;
        q += `<rect x="${T1.X(-L + i * d)}" y="${T1.Y(-L + (j + 1) * d)}" width="${T1.X(d) - T1.X(0) + 0.5}" height="${T1.Y(0) - T1.Y(d) + 0.5}" fill="${malo ? C.coral : C.verde}" fill-opacity="${malo ? 0.55 : 0.22}" shape-rendering="crispEdges"/>`;
      }
      s1.insertAdjacentHTML('beforeend', q);
      linea(s1, Array.from({length: 121}, (_, k) => [T1.X(s.bola * Math.cos(k * Math.PI / 60)), T1.Y(s.bola * Math.sin(k * Math.PI / 60))]), C.noche, 1, '3 3');
      const tr = simTV((t, x) => s.F(x), 0, e.x0, 60, 0.005, 4 * L);
      linea(s1, tr.map(z => [T1.X(z[1]), T1.Y(z[2])]), C.noche, 1.4);
      s1.insertAdjacentHTML('beforeend', `<circle cx="${T1.X(e.x0[0])}" cy="${T1.Y(e.x0[1])}" r="4.5" fill="${C.ambar}"/>`);
      const Vt = tr.map(z => s.V([z[1], z[2]])), tf = tr[tr.length - 1][0];
      const T2 = ejes(s2, 400, 340, {l: 44, r: 8, t: 10, b: 30}, [0, Math.max(tf, 1)], [Math.min(...Vt, 0) * 1.05, Math.max(...Vt, 0.01) * 1.05], 't', 'V(x(t))');
      linea(s2, tr.map((z, k) => [T2.X(z[0]), T2.Y(Vt[k])]), C.azul, 2);
      const kb = tr.findIndex(z => Math.hypot(z[1], z[2]) > s.bola);
      res.innerHTML = `<b>${s.t}</b>. ` + (s.semi ? `<b style="color:#D1495B">${s.semi}</b>` : '') + (malos ? `<b style="color:#D1495B">Hay puntos de U con V̇ ≤ 0</b> (${malos} celdas): Cetaev no aplica con esta V en esta bola. ` : (s.semi ? '' : 'V̇ > 0 en toda U. ')) +
        `V(x₀) = ${f(s.V(e.x0), 5)}. ` + (kb > 0 ? `La solución sale de la bola en t ≈ ${f(tr[kb][0], 2)}.` : 'La solución no sale de la bola en [0, 60].');
    }
    s1.addEventListener('click', ev => { const r = s1.getBoundingClientRect(), px = (ev.clientX - r.left) / r.width * 360, py = (ev.clientY - r.top) / r.height * 340;
      e.x0 = [T1.Xi(px), T1.Yi(py)]; dib(); });
    dib(true);
  })();
})();
