// Explorador de la introducción (parte 1). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-introduccion"></div>
//       <script src="../recursos/explorador-introduccion.js"></script>
// Cuatro pestañas: mapa logístico (telaraña), la planta x' = x + u^3, el doble integrador con
// estructura variable y la sensibilidad del sistema de Lorenz.
// Los modelos son los mismos de codigo/cap01_introduccion (C1_Ej1, Ej2, Ej3, Ej6, Ej7).
(function () {
  const raiz = document.getElementById('explorador-introduccion');
  if (!raiz) return;
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', ambar: '#E09F3E',
             violeta: '#6C4AB6', gris: '#5C677D', rejilla: '#DDE2EA'};
  const f = (x, d = 3) => (+x.toFixed(d)).toString();

  // ---------- dibujo ----------
  function ejes(svg, W, H, m, xr, yr, xl, yl, log) {
    const lx = v => (log ? Math.log10(v) : v);
    const X = x => m.l + (lx(x) - lx(xr[0])) / (lx(xr[1]) - lx(xr[0])) * (W - m.l - m.r);
    const Y = y => H - m.b - (y - yr[0]) / (yr[1] - yr[0]) * (H - m.t - m.b);
    const paso = (a, b) => { const r = (b - a) / 5, p = 10 ** Math.floor(Math.log10(r)), n = r / p;
      return (n < 1.5 ? 1 : n < 3.5 ? 2 : n < 7.5 ? 5 : 10) * p; };
    let s = '';
    if (log) {
      for (let e = Math.ceil(Math.log10(xr[0])); e <= Math.log10(xr[1]); e++) {
        const x = 10 ** e;
        s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${C.rejilla}"/>` +
             `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">10^${e}</text>`;
      }
    } else {
      const dx = paso(...xr);
      for (let k = Math.ceil(xr[0] / dx); k * dx <= xr[1] + 1e-9; k++) { const x = k * dx;
        s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${C.rejilla}"/>` +
             `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">${+x.toPrecision(3)}</text>`; }
    }
    const dy = paso(...yr);
    for (let k = Math.ceil(yr[0] / dy); k * dy <= yr[1] + 1e-9; k++) { const y = Math.abs(k * dy) < 1e-12 ? 0 : k * dy;
      s += `<line x1="${m.l}" x2="${W - m.r}" y1="${Y(y)}" y2="${Y(y)}" stroke="${y === 0 ? C.gris : C.rejilla}"/>` +
           `<text x="${m.l - 5}" y="${Y(y) + 4}" font-size="11" text-anchor="end" fill="${C.gris}">${+y.toPrecision(3)}</text>`; }
    s += `<text x="${(W + m.l - m.r) / 2}" y="${H - 3}" font-size="12" text-anchor="middle" fill="${C.noche}">${xl}</text>` +
         `<text x="12" y="${(H - m.b + m.t) / 2}" font-size="12" text-anchor="middle" fill="${C.noche}" transform="rotate(-90 12 ${(H - m.b + m.t) / 2})">${yl}</text>`;
    svg.innerHTML = s;
    return {X, Y};
  }
  function linea(svg, pts, col, ancho = 2.2, guiones = '') {
    // los puntos no finitos (NaN) cortan la curva: así no se dibuja fuera de la ventana
    let d = '', nuevo = true;
    for (const p of pts) {
      if (!isFinite(p[0]) || !isFinite(p[1])) { nuevo = true; continue; }
      d += (nuevo ? 'M' : 'L') + p[0].toFixed(1) + ',' + p[1].toFixed(1); nuevo = false;
    }
    svg.insertAdjacentHTML('beforeend', `<path d="${d}" fill="none" stroke="${col}" stroke-width="${ancho}" stroke-dasharray="${guiones}"/>`);
  }
  const dentro = (v, lo, hi) => (v >= lo && v <= hi ? v : NaN);
  function rk4(F, x0, T, h, t0 = 0) {
    const t = [t0], X = [x0.slice()];
    let x = x0.slice(), tt = t0;
    const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(tt, x), k2 = F(tt + h / 2, x.map((v, j) => v + h / 2 * k1[j]));
      const k3 = F(tt + h / 2, x.map((v, j) => v + h / 2 * k2[j])), k4 = F(tt + h, x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
      tt += h; t.push(tt); X.push(x.slice());
    }
    return {t, X};
  }
  const acum = (t, s) => { const S = [0]; for (let i = 1; i < t.length; i++) S.push(S[i - 1] + 0.5 * (s[i] + s[i - 1]) * (t[i] - t[i - 1])); return S; };
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
  const leyenda = items => `<div class="exp-leyenda">${items.map(([c, t]) => `<span style="color:${c}">━ ${t}</span>`).join('')}</div>`;


  function montarPestanas(pestanas) {
    raiz.innerHTML = `<div class="exp-pestanas">${pestanas.map(([id, t], i) => `<button data-p="${id}" class="${i ? '' : 'activa'}">${t}</button>`).join('')}</div>` +
      pestanas.map(([id], i) => `<div class="exp-panel" data-panel="${id}" style="display:${i ? 'none' : 'block'}"></div>`).join('');
    raiz.querySelectorAll('.exp-pestanas button').forEach(b => b.addEventListener('click', () => {
      raiz.querySelectorAll('.exp-pestanas button').forEach(x => x.classList.toggle('activa', x === b));
      raiz.querySelectorAll('.exp-panel').forEach(p => { p.style.display = p.dataset.panel === b.dataset.p ? 'block' : 'none'; });
    }));
  }
  const panel = id => raiz.querySelector(`[data-panel=${id}]`);
  // un selector (lista desplegable) que guarda su valor en e[id]
  function selector(p, id, lab, opciones, e, dib) {
    if (e[id] === undefined) e[id] = opciones[0][0];
    p.insertAdjacentHTML('beforeend', `<div class="exp-controles"><label>${lab}<select data-sel="${id}" style="width:auto">` +
      opciones.map(([v, t]) => `<option value="${v}">${t}</option>`).join('') + '</select></label></div>');
    p.querySelector(`[data-sel=${id}]`).addEventListener('change', ev => { e[id] = ev.target.value; dib(); });
  }

  const paleta = [C.azul, C.coral, C.violeta, C.ambar, C.verde, C.noche];
  montarPestanas([['mapa', 'Mapa logístico'], ['cubico', 'ẋ = x + u³'], ['vsc', 'Doble integrador'], ['lorenz', 'Lorenz']]);

  // ===== 1. Mapa logístico (C1_Ej1, C1_Ej2) =====
  (function () {
    const p = panel('mapa'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>P[k+1] = R P[k] (1 − P[k]/K) con K = 32. Izquierda: diagrama de telaraña (cada escalón es un año). Derecha: P[k]. Suba R desde 1.6 y busque dónde nace el ciclo de período 2 (R = 3), el de período 4 y el caos.</p>');
    controles(p, [['R', 'R', 0.5, 4, 1.6, 0.005], ['P0', 'P[0]', 0.1, 31.9, 1, 0.1], ['N', 'años', 10, 200, 50, 1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 420 340"></svg><svg viewBox="0 0 460 340"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen'), K = 32;
    const dib = () => {
      const {R, P0, N} = e, F = q => R * q * (1 - q / K);
      const {X, Y} = ejes(s1, 420, 340, {l: 44, r: 10, t: 10, b: 32}, [0, K], [0, K], 'P[k]', 'P[k+1]');
      linea(s1, Array.from({length: 201}, (_, i) => { const q = K * i / 200; return [X(q), Y(F(q))]; }), C.azul, 2.4);
      linea(s1, [[X(0), Y(0)], [X(K), Y(K)]], C.gris, 1.2);
      const P = [P0]; for (let k = 0; k < N; k++) P.push(F(P[k]));
      const tela = [[X(P0), Y(0)]];
      for (let k = 0; k < Math.min(N, 80); k++) { if (!isFinite(P[k + 1]) || P[k + 1] < 0 || P[k + 1] > K) break; tela.push([X(P[k]), Y(P[k + 1])], [X(P[k + 1]), Y(P[k + 1])]); }
      linea(s1, tela, C.coral, 1.2);
      const B = ejes(s2, 460, 340, {l: 44, r: 10, t: 10, b: 32}, [0, N], [0, K], 'k', 'P[k]');
      linea(s2, P.map((q, k) => [B.X(k), B.Y(dentro(q, 0, K))]), C.violeta, 1, '');
      P.forEach((q, k) => { if (q >= 0 && q <= K) s2.insertAdjacentHTML('beforeend', `<circle cx="${B.X(k)}" cy="${B.Y(q)}" r="2.6" fill="${C.violeta}"/>`); });
      const pf = K * (1 - 1 / R), dF = 2 - R;
      const ult = P.slice(-8).map(q => f(q, 3)).join(', ');
      res_.innerHTML = `punto fijo K(1 − 1/R) = ${f(pf, 3)} con F′(P*) = 2 − R = ${f(dF, 3)} → ${Math.abs(dF) < 1 ? '<b>estable</b>' : '<b style="color:#D1495B">inestable</b>'} · últimos valores: ${ult}` +
        (P.some(q => q < 0 || !isFinite(q)) ? ' · <b style="color:#D1495B">la población salió de [0, K]: el modelo dejó de tener sentido</b>' : '') +
        ` · conejos: una isla con 20 → ${f(F(20), 2)}; dos islas con 10 → ${f(2 * F(10), 2)}`;
    };
    dib();
  })();

  // ===== 2. x' = x + u^3 (C1_Ej6) =====
  (function () {
    const p = panel('cubico'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>Planta ẋ = x + u³. Compare la ley lineal u = −k x con la no lineal u = −(k x)^(1/3). Con la lineal, mire dónde termina la solución y cuántos equilibrios tiene el lazo cerrado. ¿Hay algún k que estabilice el origen?</p>');
    selector(p, 'ley', 'Ley de control', [['lin', 'u = −k x'], ['nolin', 'u = −(k x)^(1/3)'], ['cero', 'u = 0']], e, () => dib());
    controles(p, [['k', 'k', 0, 10, 5, 0.05], ['x0', 'x(0)', -1.5, 1.5, 1, 0.01], ['T', 'tiempo', 1, 10, 5, 0.5]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 460 300"></svg><svg viewBox="0 0 460 300"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    const dib = () => {
      const {k, x0, T} = e;
      const u = e.ley === 'lin' ? x => -k * x : e.ley === 'nolin' ? x => -Math.cbrt(k * x) : () => 0;
      const F = (t, x) => [x[0] + u(x[0]) ** 3];
      const {t, X: Xs} = rk4(F, [x0], T, T / 2000);
      const lim = 1.6;
      const A = ejes(s1, 460, 300, {l: 48, r: 12, t: 10, b: 34}, [0, T], [-lim, lim], 't', 'x(t)');
      linea(s1, t.map((tt, i) => [A.X(tt), A.Y(dentro(Xs[i][0], -lim, lim))]), C.azul, 2.4);
      const xs = Array.from({length: 401}, (_, i) => -0.4 + 0.8 * i / 400), ys = xs.map(x => F(0, [x])[0]);
      const ym = Math.max(...ys.map(Math.abs)) * 1.1 + 0.01;
      const B = ejes(s2, 460, 300, {l: 48, r: 12, t: 10, b: 34}, [-0.4, 0.4], [-ym, ym], 'x', 'ẋ en lazo cerrado');
      linea(s2, xs.map((x, i) => [B.X(x), B.Y(ys[i])]), C.coral, 2.4);
      let txt;
      if (e.ley === 'lin' && k > 0) { const xe = k ** -1.5;
        txt = `lazo cerrado ẋ = x − k³x³: equilibrios 0 (f′ = 1, <b style="color:#D1495B">inestable</b>) y ±k^(−3/2) = ±${f(xe, 4)} (estables)`;
        [-xe, 0, xe].forEach((x, i) => s2.insertAdjacentHTML('beforeend', `<circle cx="${B.X(x)}" cy="${B.Y(0)}" r="6" stroke="${C.noche}" stroke-width="1.6" fill="${i === 1 ? '#fff' : C.noche}"/>`)); }
      else if (e.ley === 'nolin') txt = `lazo cerrado ẋ = (1 − k) x: ${k > 1 ? '<b>exponencialmente estable</b>' : '<b style="color:#D1495B">inestable</b> (hace falta k > 1)'}`;
      else txt = 'sin control: ẋ = x, inestable';
      res_.innerHTML = txt + ` · x(${f(T, 1)}) = ${f(Xs[Xs.length - 1][0], 5)}`;
    };
    dib();
  })();

  // ===== 3. Doble integrador (C1_Ej7) =====
  (function () {
    const p = panel('vsc'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>ẋ₁ = x₂, ẋ₂ = u. La ley de estructura variable u = k₃x₁, con k₃ = +1 si x₁s &lt; 0 y −1 si x₁s &gt; 0 (s = x₁ + x₂), alterna un centro y una silla y desliza por la recta s = 0. Compárela con el PD u = −k₁x₁ − k₂x₂ y cambie las ganancias: ¿siempre es más rápida?</p>');
    controles(p, [['k1', 'k₁ (PD)', 0.1, 5, 1, 0.05], ['k2', 'k₂ (PD)', 0, 5, 1, 0.05], ['a', 'x₁(0)', -1.5, 1.5, 1, 0.05], ['b', 'x₂(0)', -1.5, 1.5, 1, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 400 360"></svg><svg viewBox="0 0 460 360"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    const t2 = (t, X) => { const n0 = Math.hypot(...X[0]); let i = X.length - 1; while (i > 0 && Math.hypot(...X[i]) <= 0.02 * n0) i--; return t[Math.min(i + 1, t.length - 1)]; };
    const dib = () => {
      const {k1, k2, a, b} = e, T = 12, h = 1e-3;
      const vsc = rk4((t, x) => { const k3 = x[0] * (x[0] + x[1]) < 0 ? 1 : -1; return [x[1], k3 * x[0]]; }, [a, b], T, h);
      const pd = rk4((t, x) => [x[1], -k1 * x[0] - k2 * x[1]], [a, b], T, h);
      const A = ejes(s1, 400, 360, {l: 44, r: 10, t: 10, b: 32}, [-2, 2], [-2, 2], 'x₁', 'x₂');
      linea(s1, [[A.X(-2), A.Y(2)], [A.X(2), A.Y(-2)]], C.gris, 1.2, '6 4');
      linea(s1, pd.X.map(x => [A.X(dentro(x[0], -2, 2)), A.Y(dentro(x[1], -2, 2))]), C.coral, 2);
      linea(s1, vsc.X.map(x => [A.X(dentro(x[0], -2, 2)), A.Y(dentro(x[1], -2, 2))]), C.azul, 2);
      const B = ejes(s2, 460, 360, {l: 44, r: 10, t: 10, b: 32}, [0, T], [-1.6, 1.6], 't', 'x₁(t)');
      linea(s2, pd.t.map((t, i) => [B.X(t), B.Y(dentro(pd.X[i][0], -1.6, 1.6))]), C.coral, 2);
      linea(s2, vsc.t.map((t, i) => [B.X(t), B.Y(dentro(vsc.X[i][0], -1.6, 1.6))]), C.azul, 2);
      res_.innerHTML = `tiempo al 2 % de la norma inicial: estructura variable ${f(t2(vsc.t, vsc.X), 2)}, PD ${f(t2(pd.t, pd.X), 2)} · polos del PD: ` +
        (k2 * k2 - 4 * k1 >= 0 ? `${f((-k2 + Math.sqrt(k2 * k2 - 4 * k1)) / 2, 3)} y ${f((-k2 - Math.sqrt(k2 * k2 - 4 * k1)) / 2, 3)}` : `${f(-k2 / 2, 3)} ± ${f(Math.sqrt(4 * k1 - k2 * k2) / 2, 3)} j`);
    };
    dib();
    p.insertAdjacentHTML('beforeend', leyenda([[C.azul, 'estructura variable'], [C.coral, 'PD'], [C.gris, 'recta s = 0']]));
  })();

  // ===== 4. Lorenz (C1_Ej3) =====
  (function () {
    const p = panel('lorenz'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>Dos soluciones del sistema de Lorenz (σ = 10, ρ = 28, β = 8/3) que empiezan en (1, 1, 1) y en (1 + δ, 1, 1). Arriba, x(t) de las dos; abajo, la distancia en escala logarítmica. Cambie δ y el paso del integrador: el instante en que se separan cambia.</p>');
    controles(p, [['ld', 'log₁₀ δ', -12, -1, -9, 1], ['h', 'paso de RK4', 0.001, 0.02, 0.005, 0.001]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 240"></svg><svg viewBox="0 0 760 200"></svg>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    const L = (t, x) => [10 * (x[1] - x[0]), x[0] * (28 - x[2]) - x[1], x[0] * x[1] - 8 / 3 * x[2]];
    const dib = () => {
      const T = 40, d = 10 ** e.ld;
      const A = rk4(L, [1, 1, 1], T, e.h), Bq = rk4(L, [1 + d, 1, 1], T, e.h);
      const P = ejes(s1, 760, 240, {l: 44, r: 10, t: 10, b: 30}, [0, T], [-22, 22], 't', 'x(t)');
      linea(s1, A.t.map((t, i) => [P.X(t), P.Y(A.X[i][0])]), C.azul, 1.4);
      linea(s1, Bq.t.map((t, i) => [P.X(t), P.Y(Bq.X[i][0])]), C.coral, 1.4, '5 3');
      const dist = A.X.map((x, i) => Math.hypot(x[0] - Bq.X[i][0], x[1] - Bq.X[i][1], x[2] - Bq.X[i][2]));
      const Q = ejes(s2, 760, 200, {l: 44, r: 10, t: 10, b: 30}, [0, T], [-14, 2], 't', 'log₁₀ ‖Δx‖');
      linea(s2, A.t.map((t, i) => [Q.X(t), Q.Y(Math.max(-14, Math.log10(dist[i] + 1e-16)))]), C.violeta, 1.6);
      const i1 = dist.findIndex(v => v > 1);
      res_.innerHTML = `δ = 10^${e.ld}: la diferencia pasa de 1 en t ≈ ${i1 > 0 ? f(A.t[i1], 1) : '—'} · regla práctica: crece como e^(0.9 t), así que tarda unos ln(1/δ)/0.9 ≈ ${f(Math.log(1 / d) / 0.906, 1)} más el transitorio`;
    };
    dib();
  })();
})();
