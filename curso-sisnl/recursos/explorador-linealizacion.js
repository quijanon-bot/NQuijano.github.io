// Explorador de linealización por retroalimentación (parte 12). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-linealizacion"></div>
//       <script src="../recursos/explorador-linealizacion.js"></script>
// Cuatro pestañas: péndulo, levitador, dinámica cero y "no cancelar".
// Los modelos son los de codigo/cap12_linealizacion (C12_Ej3, Ej9, Ej10, Ej11, Ej12).
(function () {
  const raiz = document.getElementById('explorador-linealizacion');
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

  const sub = (arr, n) => { const k = Math.max(1, Math.floor(arr.length / n)); return arr.filter((_, i) => i % k === 0); };
  montarPestanas([['pendulo', 'Péndulo'], ['levitador', 'Levitador'], ['cero', 'Dinámica cero'], ['cancelar', 'No cancelar']]);

  // ===== 1. Péndulo: exacta contra jacobiana (C12_Ej3) =====
  (function () {
    const p = panel('pendulo'), e = {};
    const dib = () => {
      const a = 10, b = 1, c = 10, d = e.ref * Math.PI / 180, ah = e.ah, wn = e.wn, k1 = wn * wn, k2 = 2 * wn - b;
      const uE = x => (ah * Math.sin(x[0]) - k1 * (x[0] - d) - k2 * x[1]) / c;
      const uJ = x => (a * Math.sin(d) + (a * Math.cos(d) - k1) * (x[0] - d) - k2 * x[1]) / c;   // linealización en la meta
      const F = u => (t, x) => [x[1], -a * Math.sin(x[0]) - b * x[1] + c * u(x)];
      const T = 8, h = 0.002;
      const RE = rk4(F(uE), [e.x0 * Math.PI / 180, 0], T, h), RJ = rk4(F(uJ), [e.x0 * Math.PI / 180, 0], T, h);
      const RD = rk4((t, z) => [z[1], -k1 * z[0] - (b + k2) * z[1]], [e.x0 * Math.PI / 180 - d, 0], T, h);
      const deg = v => v * 180 / Math.PI;
      const todos = [...RE.X, ...RJ.X].map(x => deg(x[0])).filter(isFinite);
      const lo = Math.min(-10, ...todos), hi = Math.max(200, ...todos);
      const {X, Y} = ejes(svg, 640, 300, {l: 50, r: 10, t: 12, b: 34}, [0, T], [Math.max(lo, -400), Math.min(hi, 600)], 't [s]', 'x₁ [grados]');
      linea(svg, sub(RD.t.map((t, i) => [X(t), Y(deg(RD.X[i][0] + d))]), 600), C.noche, 1.4, '6 4');
      linea(svg, sub(RJ.t.map((t, i) => [X(t), Y(dentro(deg(RJ.X[i][0]), -400, 600))]), 600), C.coral, 2.2);
      linea(svg, sub(RE.t.map((t, i) => [X(t), Y(dentro(deg(RE.X[i][0]), -400, 600))]), 600), C.azul, 2.4);
      const fin = deg(RE.X[RE.X.length - 1][0]);
      const errE = Math.max(...RE.X.map((x, i) => Math.abs(x[0] - RD.X[i][0] - d)));
      const errJ = Math.max(...RJ.X.map((x, i) => Math.abs(x[0] - RD.X[i][0] - d)));
      res.innerHTML = `Polos del diseño en −${f(wn, 2)} (doble). Diferencia máxima con el diseño: <b style="color:#1E5AA8">exacta ${errE < 1e-6 ? '&lt; 10⁻⁶' : f(deg(errE), 2) + '°'}</b>, <b style="color:#D1495B">jacobiana ${f(deg(errJ), 2)}°</b>. ` +
        `Posición final de la exacta: ${f(fin, 2)}° (meta ${f(e.ref, 1)}°)` +
        (Math.abs(ah - a) > 1e-9 && Math.abs(Math.sin(d)) > 1e-6 ? ' · <b style="color:#D1495B">con â ≠ a queda un error permanente: el término (â − a) sin x₁ no se cancela</b>' : '') +
        (Math.abs(ah - a) > 1e-9 && Math.abs(Math.sin(d)) <= 1e-6 ? ' · con la meta en 0° o 180°, sin x₁ = 0 en el equilibrio: el error de modelo solo afecta el transitorio' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>x₁′ = x₂, x₂′ = −a sin x₁ − b x₂ + c u con a = 10, b = 1, c = 10. La ley <b style="color:#1E5AA8">exacta</b> cancela â sin x₁; la <b style="color:#D1495B">jacobiana</b> usa la linealización en la meta. La discontinua es la respuesta que se diseñó.</p>');
    controles(p, [['ref', 'Meta [grados]', 0, 180, 180, 1], ['x0', 'x₁(0) [grados]', -90, 180, 0, 1], ['wn', 'Polo doble −ω', 0.8, 6, 2, 0.1], ['ah', 'â (el modelo cree)', 5, 15, 10, 0.1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 640 300" style="max-width:720px"></svg>');
    const svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. Levitador (C12_Ej9) =====
  (function () {
    const p = panel('levitador'), e = {};
    const P = {m: 0.1, k: 0.001, g: 9.81, a: 0.05, L0: 0.01, L1: 0.02, R: 1};
    const L = y => P.L1 + P.L0 / (1 + y / P.a);
    const fl = (x, u, m) => [x[1], P.g - P.k / m * x[1] - P.L0 * P.a * x[2] ** 2 / (2 * m * (P.a + x[0]) ** 2),
                             (u - P.R * x[2] + P.L0 * P.a * x[1] * x[2] / (P.a + x[0]) ** 2) / L(x[0])];
    const c3 = Math.sqrt(2 * P.g * P.m / (P.L0 * P.a));
    const K = [-237.16607, -16.01334, 0.87475], KFL = [6000, 1100, 60];
    const ley = (x, yd) => {   // linealización exacta (usa la masa del modelo)
      const c = P.L0 * P.a / (2 * P.m), xi3 = P.g - P.k / P.m * x[1] - c * x[2] ** 2 / (P.a + x[0]) ** 2;
      const f3 = (-P.R * x[2] + P.L0 * P.a * x[1] * x[2] / (P.a + x[0]) ** 2) / L(x[0]);
      const Lf3 = 2 * c * x[2] ** 2 / (P.a + x[0]) ** 3 * x[1] - P.k / P.m * xi3 - 2 * c * x[2] / (P.a + x[0]) ** 2 * f3;
      const b = -P.L0 * P.a * x[2] / (P.m * (P.a + x[0]) ** 2 * L(x[0]));
      const v = yd[3] - KFL[0] * (x[0] - yd[0]) - KFL[1] * (x[1] - yd[1]) - KFL[2] * (xi3 - yd[2]);
      return (v - Lf3) / b;
    };
    const dib = () => {
      const A = e.A / 100, w = 2 * Math.PI * e.fr, y0 = e.y0 / 100, m = e.m;
      const yd = t => [y0 + A * Math.sin(w * t), A * w * Math.cos(w * t), -A * w * w * Math.sin(w * t), -A * w ** 3 * Math.cos(w * t)];
      const uJ = (t, x) => { const y = yd(t)[0], xs = [y, 0, c3 * (P.a + y)];
        return P.R * xs[2] - (K[0] * (x[0] - xs[0]) + K[1] * (x[1] - xs[1]) + K[2] * (x[2] - xs[2])); };
      const x0 = [y0, 0, c3 * (P.a + y0)], T = 3, h = 2e-4;
      let roto = null;
      const RE = rk4((t, x) => { if (x[2] <= 0.01 || !isFinite(x[0])) { roto = roto ?? t; return [0, 0, 0]; } return fl(x, ley(x, yd(t)), m); }, x0, T, h);
      const RJ = rk4((t, x) => (isFinite(x[0]) && x[0] > -0.05 && x[0] < 0.5 ? fl(x, uJ(t, x), m) : [0, 0, 0]), x0, T, h);
      const {X, Y} = ejes(svg1, 640, 260, {l: 50, r: 10, t: 12, b: 34}, [0, T], [Math.max(0, 100 * (y0 - A) - 4), Math.min(25, 100 * (y0 + A) + 4)], 't [s]', 'y [cm] (medida hacia abajo)');
      linea(svg1, sub(RE.t.map(t => [X(t), Y(100 * yd(t)[0])]), 500), C.noche, 1.3, '6 4');
      linea(svg1, sub(RJ.t.map((t, i) => [X(t), Y(dentro(100 * RJ.X[i][0], -5, 30))]), 700), C.coral, 2.2);
      linea(svg1, sub(RE.t.map((t, i) => [X(t), Y(roto !== null && t > roto ? NaN : 100 * RE.X[i][0])]), 700), C.azul, 2.4);
      const imax = Math.max(...RE.X.map(x => x[2]), ...RJ.X.map(x => isFinite(x[2]) ? x[2] : 0));
      const {X: X2, Y: Y2} = ejes(svg2, 640, 200, {l: 50, r: 10, t: 12, b: 34}, [0, T], [0, Math.max(10, imax * 1.1)], 't [s]', 'i [A]');
      linea(svg2, sub(RJ.t.map((t, i) => [X2(t), Y2(dentro(RJ.X[i][2], 0, 100))]), 700), C.coral, 2);
      linea(svg2, sub(RE.t.map((t, i) => [X2(t), Y2(roto !== null && t > roto ? NaN : RE.X[i][2])]), 700), C.azul, 2.2);
      const k = RE.t.map((t, i) => i).filter(i => RE.t[i] > 1);
      const err = arr => Math.max(...k.map(i => Math.abs(arr[i][0] - yd(RE.t[i])[0])));
      const accMax = A * w * w;
      res.innerHTML = (roto !== null ? `<b style="color:#D1495B">La corriente de la ley exacta llegó a cero en t = ${f(roto, 3)} s: b(x) = L_gL_f²h ∝ i se anula y la ley explota.</b> ` : '') +
        `Aceleración máxima que pide la referencia: ${f(accMax, 2)} m/s² ${accMax > P.g ? '<b style="color:#D1495B">&gt; g: el imán no puede empujar hacia abajo</b>' : '(&lt; g)'}. ` +
        (roto === null ? `Error máximo para t &gt; 1 s: <b style="color:#1E5AA8">exacta ${err(RE.X) < 1e-4 ? f(1e6 * err(RE.X), 1) + ' μm' : f(100 * err(RE.X), 2) + ' cm'}</b>, ` : '') +
        `<b style="color:#D1495B">jacobiana ${isFinite(err(RJ.X)) ? f(100 * err(RJ.X), 2) + ' cm' : 'diverge'}</b>.` +
        (Math.abs(m - P.m) > 1e-9 ? ` Con m ≠ 0.1 kg, la cancelación usa la masa equivocada (sección 12.8).` : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Seguimiento de y_d = y₀ + A sin(2π f t) con la <b style="color:#1E5AA8">linealización exacta</b> (polos −10, −20, −30) y con la <b style="color:#D1495B">jacobiana</b> de ganancia fija (diseñada en 5 cm) más la prealimentación u*(y_d). Suba la amplitud o la frecuencia hasta pedir una aceleración mayor que g.</p>');
    controles(p, [['y0', 'y₀ [cm]', 3, 15, 8, 0.5], ['A', 'Amplitud A [cm]', 0, 6, 3, 0.1], ['fr', 'Frecuencia f [Hz]', 0.2, 4, 1, 0.05], ['m', 'Masa real [kg]', 0.08, 0.14, 0.1, 0.005]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 640 260" style="max-width:720px"></svg><svg viewBox="0 0 640 200" style="max-width:720px"></svg>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 3. Dinámica cero (C12_Ej10, Ej11, Ej12) =====
  (function () {
    const p = panel('cero'), e = {};
    const dib = () => {
      let T, R, nombres, txt, yl;
      if (e.sis === 'nominima') {
        const k = e.k;
        const F = (t, x) => (!(Math.abs(x[0]) <= 3) ? [NaN, NaN] : [x[0] + x[1], 3 * x[0] ** 2 * x[1] + x[0] + (-x[0] + 3 * x[0] ** 3 - k * (-(x[0] ** 3) + x[1]))]);
        T = 4; R = rk4(F, [e.a0, e.b0], T, 0.001);
        const ys = R.X.map(x => -(x[0] ** 3) + x[1]), es = R.X.map(x => x[0]);
        const iesc = es.findIndex(v => !(Math.abs(v) <= 2.9));
        nombres = [[ys, 'y = ξ', C.azul], [es, 'η = x₁', C.coral]]; yl = 'y, η';
        txt = `Dinámica cero η′ = η + η³ (fase no mínima). ${iesc > 0 ? `<b style="color:#D1495B">|η| pasa de 2.9 en t = ${f(R.t[iesc - 1], 3)} s</b>, mientras y ya vale ${f(ys[iesc - 1], 3)}.` : 'Con η(0) = 0 exacto, la solución se queda en el origen: cualquier perturbación la saca.'}`;
      } else if (e.sis === 'lineal') {
        const al = e.a0 * 2, be = e.b0 * 2 - 2;   // α y β a partir de los deslizadores
        const u = x => -al * x[2] - 4 * x[0] - 4 * x[1];
        T = 6; R = rk4((t, x) => [x[1], al * x[2] + u(x), be * x[2] - u(x)], [1, 0, 0], T, 0.002);
        nombres = [[R.X.map(x => x[0]), 'y', C.azul], [R.X.map(x => x[2]), 'x₃', C.coral], [R.X.map(u), 'u', C.violeta]]; yl = 'y, x₃, u';
        txt = `α = ${f(al, 2)}, β = ${f(be, 2)}: G(s) = (s − (${f(al + be, 2)}))/(s²(s − ${f(be, 2)})). Dinámica cero η′ = (α + β) η con η = x₂ + x₃: ` +
          (al + be < 0 ? '<b style="color:#2A9D8F">cero en el semiplano izquierdo, fase mínima</b>.' : al + be > 0 ? '<b style="color:#D1495B">cero en el semiplano derecho, fase no mínima</b>: y es la misma, x₃ y u crecen.' : 'cero en el origen: fase mínima débil.');
      } else {
        const k = e.k, xi0 = e.a0 * 3, eta0 = e.b0 * 4;
        T = 4; R = rk4((t, z) => (!(z[1] <= 1e3) ? [NaN, NaN] : [-k * z[0], -z[1] + z[1] ** 2 * z[0]]), [xi0, eta0], T, 0.0005);
        nombres = [[R.X.map(z => z[0]), 'ξ', C.azul], [R.X.map(z => z[1]), 'η', C.coral]]; yl = 'ξ, η';
        const esc = eta0 * xi0 > k + 1, te = Math.log((xi0 / (k + 1)) / (xi0 / (k + 1) - 1 / eta0)) / (k + 1);
        txt = `ξ′ = −k ξ, η′ = −η + η² ξ con ξ₀ = ${f(xi0, 2)}, η₀ = ${f(eta0, 2)}, k = ${f(k, 1)}. η₀ξ₀ = ${f(eta0 * xi0, 2)} ` +
          (esc ? `&gt; k + 1: <b style="color:#D1495B">escape en t = ${f(te, 4)} s</b> aunque la dinámica cero η′ = −η sea globalmente estable.` : `≤ k + 1: converge.`);
      }
      const vals = nombres.flatMap(n => n[0]).filter(v => isFinite(v) && Math.abs(v) < 12);
      const lo = Math.max(-12, Math.min(...vals, -0.2)), hi = Math.min(12, Math.max(...vals, 1));
      const {X, Y} = ejes(svg, 640, 300, {l: 50, r: 10, t: 12, b: 34}, [0, T], [lo, hi], 't', yl);
      nombres.forEach(([v, , col]) => linea(svg, sub(R.t.map((t, i) => [X(t), Y(dentro(v[i], lo, hi))]), 700), col, 2.2));
      res.innerHTML = txt + leyenda(nombres.map(([, n, c]) => [c, n]));
    };
    p.insertAdjacentHTML('beforeend', '<p>Tres sistemas con la ley linealizante ya aplicada. En los tres, la salida hace lo que se diseñó; lo que decide es lo que no se ve.</p>');
    selector(p, 'sis', 'Sistema', [['nominima', 'Fase no mínima (ejemplo 12.8)'], ['lineal', 'Lineal: α + β (ejemplo 12.9)'], ['iss', 'Escape sin ISS (trampa 12.12)']], e, () => dib());
    controles(p, [['k', 'Ganancia k', 0.5, 8, 2, 0.1], ['a0', 'Parámetro 1 (x₁(0) · α/2 · ξ₀/3)', 0, 1.5, 0.05, 0.01], ['b0', 'Parámetro 2 (x₂(0) · (β+2)/2 · η₀/4)', 0, 1.5, 0.6, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 640 300" style="max-width:720px"></svg>');
    const svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 4. No cancelar lo que ayuda (C12_Ej12) =====
  (function () {
    const p = panel('cancelar'), e = {};
    const dib = () => {
      const x0 = e.x0, kk = e.kk, T = 4, h = 0.0005;
      const uF = x => x ** 3 - x - kk * x, uC = x => -(1 + kk) * x;   // las dos dejan la misma parte lineal -kk x
      const RF = rk4((t, x) => [x[0] - x[0] ** 3 + uF(x[0])], [x0], T, h), RC = rk4((t, x) => [x[0] - x[0] ** 3 + uC(x[0])], [x0], T, h);
      const UF = RF.X.map(x => uF(x[0])), UC = RC.X.map(x => uC(x[0]));
      const EF = acum(RF.t, UF.map(u => u * u)), EC = acum(RC.t, UC.map(u => u * u));
      const {X, Y} = ejes(svg1, 320, 240, {l: 46, r: 8, t: 12, b: 34}, [0, T], [Math.min(0, x0), Math.max(0, x0) * 1.05 + 0.01], 't', 'x');
      linea(svg1, sub(RF.t.map((t, i) => [X(t), Y(RF.X[i][0])]), 500), C.coral); linea(svg1, sub(RC.t.map((t, i) => [X(t), Y(RC.X[i][0])]), 500), C.azul);
      const {X: X2, Y: Y2} = ejes(svg2, 320, 240, {l: 52, r: 8, t: 12, b: 34}, [0, T], [0, Math.max(EF[EF.length - 1], EC[EC.length - 1]) * 1.1 + 1e-9], 't', '∫u² dτ');
      linea(svg2, sub(RF.t.map((t, i) => [X2(t), Y2(EF[i])]), 500), C.coral); linea(svg2, sub(RC.t.map((t, i) => [X2(t), Y2(EC[i])]), 500), C.azul);
      res.innerHTML = `x′ = x − x³ + u. <b style="color:#D1495B">Cancela</b>: u = x³ − x − ${f(kk, 1)}x ⇒ x′ = −${f(kk, 1)}x. <b style="color:#1E5AA8">Conserva</b>: u = −${f(1 + kk, 1)}x ⇒ x′ = −${f(kk, 1)}x − x³. ` +
        `u(0): ${f(UF[0], 2)} contra ${f(UC[0], 2)}. Energía de control hasta t = 4: ${f(EF[EF.length - 1], 2)} contra ${f(EC[EC.length - 1], 2)} (${f(EF[EF.length - 1] / Math.max(EC[EC.length - 1], 1e-12), 1)} veces). x(1): ${f(RF.X[2000][0], 3)} contra ${f(RC.X[2000][0], 3)}.`;
    };
    p.insertAdjacentHTML('beforeend', '<p>Las dos leyes dejan la misma parte lineal; una cancela −x³ y la otra lo aprovecha. Pruebe condiciones iniciales pequeñas: ahí el término cúbico casi no importa y las dos leyes se parecen.</p>');
    controles(p, [['x0', 'x(0)', 0.1, 4, 3, 0.05], ['kk', 'Tasa lineal k', 0.2, 4, 1, 0.1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 320 240"></svg><svg viewBox="0 0 320 240"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();
})();
