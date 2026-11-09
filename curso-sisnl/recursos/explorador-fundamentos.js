// Explorador de fundamentos matemáticos (parte 3). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-fundamentos"></div>
//       <script src="../recursos/explorador-fundamentos.js"></script>
// Tres pestañas: normas-p y su equivalencia, constantes de Lipschitz e iteraciones de Picard.
// Los modelos son los mismos de codigo/cap03_preliminares (C3_Ej2, Ej5, Ej7).
(function () {
  const raiz = document.getElementById('explorador-fundamentos');
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

  montarPestanas([['normas', 'Normas-p'], ['lipschitz', 'Lipschitz'], ['picard', 'Picard']]);

  // ===== 1. Normas-p (C3_Ej2) =====
  (function () {
    const p = panel('normas'), e = {};
    const np = (v, q) => (q >= 60 ? Math.max(...v.map(Math.abs)) : Math.pow(v.reduce((s, x) => s + Math.abs(x) ** q, 0), 1 / q));
    const dib = () => {
      const {q, x1, x2} = e, qq = q >= 60 ? Infinity : q;
      const {X, Y} = ejes(svg, 420, 400, {l: 40, r: 10, t: 10, b: 30}, [-2.2, 2.2], [-2.2, 2.2], 'x₁', 'x₂');
      const bola = r => { const pts = []; for (let i = 0; i <= 720; i++) { const t = 2 * Math.PI * i / 720, c = Math.cos(t), s = Math.sin(t);
        const n = np([c, s], q); pts.push([X(r * c / n), Y(r * s / n)]); } return pts; };
      linea(svg, bola(1), q < 1 ? C.gris : C.azul, 2.6, q < 1 ? '6 4' : '');
      const n = np([x1, x2], q);
      linea(svg, bola(n), C.claro || '#C9D1DE', 1.2, '3 3');
      svg.insertAdjacentHTML('beforeend', `<circle cx="${X(x1)}" cy="${Y(x2)}" r="5" fill="${C.coral}"/>`);
      const n1 = np([x1, x2], 1), n2 = np([x1, x2], 2), ni = np([x1, x2], 99);
      let txt = `<b>‖x‖<sub>${qq === Infinity ? '∞' : f(q, 2)}</sub> = ${f(n, 4)}</b> · ‖x‖₁ = ${f(n1, 4)}, ‖x‖₂ = ${f(n2, 4)}, ‖x‖<sub>∞</sub> = ${f(ni, 4)} ·
        ‖x‖₂ ≤ ‖x‖₁ ≤ √2‖x‖₂: ${f(n2, 3)} ≤ ${f(n1, 3)} ≤ ${f(Math.SQRT2 * n2, 3)}`;
      if (q < 1) txt += ` · <b style="color:#D1495B">p &lt; 1: no es una norma. Con a = (1,0), b = (0,1): ‖a+b‖ = ${f(np([1, 1], q), 3)} &gt; ‖a‖ + ‖b‖ = 2</b>`;
      res_.innerHTML = txt;
    };
    p.insertAdjacentHTML('beforeend', '<p>La curva azul es la “esfera unitaria” {x : ‖x‖<sub>p</sub> = 1}; la punteada pasa por el punto x. Mueva p por debajo de 1 y mire qué pasa con la convexidad (trampa 3.2). Con p = 60 o más se toma p = ∞.</p>');
    controles(p, [['q', 'p', 0.3, 60, 2, 0.05], ['x1', 'x₁', -2, 2, 1.2, 0.05], ['x2', 'x₂', -2, 2, 0.7, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 420 400" style="max-width:460px"></svg>');
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. Lipschitz (C3_Ej5) =====
  (function () {
    const p = panel('lipschitz'), e = {};
    const funs = {cubo: [x => x ** 3, 'x³'], sat: [x => Math.max(-1, Math.min(1, x)), 'sat(x)'],
                  raiz: [x => Math.cbrt(x), 'x^(1/3)'], seno: [x => Math.sin(x), 'sin x'], abs: [x => Math.abs(x), '|x|']};
    const dib = () => {
      const [F, nom] = funs[e.fun], a = e.a, x0 = e.x0;
      const xs = Array.from({length: 401}, (_, i) => -a + 2 * a * i / 400), ys = xs.map(F);
      let L = 0;
      for (let i = 0; i < xs.length; i += 2) for (let j = i + 1; j < xs.length; j += 2) L = Math.max(L, Math.abs(ys[i] - ys[j]) / (xs[j] - xs[i]));
      const ymax = Math.max(...ys.map(Math.abs)) * 1.15 + 0.1;
      const {X, Y} = ejes(svg, 760, 320, {l: 48, r: 14, t: 12, b: 34}, [-a, a], [-ymax, ymax], 'x', nom);
      const y0 = F(x0);
      svg.insertAdjacentHTML('beforeend', `<path d="M${X(-a)},${Y(y0 - L * (-a - x0))} L${X(a)},${Y(y0 - L * (a - x0))} L${X(a)},${Y(y0 + L * (a - x0))} L${X(-a)},${Y(y0 + L * (-a - x0))} Z" fill="${C.verde}" opacity=".12"/>`);
      linea(svg, xs.map((x, i) => [X(x), Y(ys[i])]), C.azul, 2.6);
      svg.insertAdjacentHTML('beforeend', `<circle cx="${X(x0)}" cy="${Y(y0)}" r="5" fill="${C.coral}"/>`);
      res_.innerHTML = `<b>Mayor pendiente de las secantes en [−${f(a, 2)}, ${f(a, 2)}]: L ≈ ${f(L, 3)}</b>. El cono verde (pendientes ±L) contiene toda la gráfica.` +
        (e.fun === 'raiz' ? ' · Achique a: L crece sin cota (no es Lipschitz en 0).' : e.fun === 'cubo' ? ' · Agrande a: L = 3a² crece (local, no global).' : ' · L no depende de a: es globalmente Lipschitz.');
    };
    p.insertAdjacentHTML('beforeend', '<p>Escoja una función y el intervalo [−a, a]. El número L es la mayor pendiente de las secantes que se encontró; el punto rojo es el vértice del cono.</p>');
    selector(p, 'fun', 'Función', [['cubo', 'x³'], ['sat', 'sat(x)'], ['raiz', 'x^(1/3)'], ['seno', 'sin x'], ['abs', '|x|']], e, () => dib());
    controles(p, [['a', 'a (semiancho)', 0.01, 5, 1.5, 0.01], ['x0', 'vértice x₀', -1.5, 1.5, 0.5, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 320"></svg>');
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 3. Picard (C3_Ej7) =====
  (function () {
    const p = panel('picard'), e = {};
    const sist = {lin: [x => x, 1, 'ẋ = x, x(0) = 1'], cuad: [x => x * x, 1, 'ẋ = x², x(0) = 1 (escapa en t = 1)'],
                  tan: [x => 1 + x * x, 0, 'ẋ = 1 + x², x(0) = 0 (escapa en t = π/2)'], cubo: [x => -(x ** 3), 2, 'ẋ = −x³, x(0) = 2']};
    const dib = () => {
      const [F, x0, nom] = sist[e.sis], T = e.T, K = Math.round(e.k);
      const n = 600, t = Array.from({length: n + 1}, (_, i) => T * i / n), h = T / n;
      const ref = rk4((tt, x) => [F(x[0])], [x0], T, h / 4).X.filter((_, i) => i % 4 === 0).map(v => v[0]);
      let x = t.map(() => x0); const its = [x];
      for (let k = 0; k < K; k++) { const fx = x.map(F), nx = [x0];
        for (let i = 1; i <= n; i++) nx.push(nx[i - 1] + 0.5 * h * (fx[i] + fx[i - 1])); x = nx; its.push(x); }
      const top = Math.min(Math.max(...ref.filter(isFinite), ...x.filter(isFinite)) * 1.1, 50), bot = Math.min(0, ...ref, ...x.filter(isFinite));
      const {X, Y} = ejes(svg, 760, 320, {l: 48, r: 14, t: 12, b: 34}, [0, T], [bot, top], 't', 'x');
      const cols = [C.gris, C.violeta, C.azul, C.verde, C.ambar, C.coral];
      its.forEach((v, k) => linea(svg, t.map((tt, i) => [X(tt), Y(dentro(v[i], bot, top))]), cols[k % cols.length], k === its.length - 1 ? 2.6 : 1.2));
      linea(svg, t.map((tt, i) => [X(tt), Y(dentro(ref[i], bot, top))]), C.noche, 2, '6 4');
      const err = Math.max(...x.map((v, i) => Math.abs(v - ref[i])));
      res_.innerHTML = `<b>${nom}</b> · iteración ${K}: ‖x<sub>${K}</sub> − x‖<sub>C</sub> en [0, ${f(T, 2)}] = ${isFinite(err) ? err.toExponential(2) : '∞'}` +
        (e.sis === 'cuad' ? ` · el teorema garantiza [0, 0.207]; ${T >= 1 ? '<b style="color:#D1495B">T ≥ 1: la solución no existe en todo el intervalo</b>' : 'pruebe T cerca de 1'}` : '') +
        (e.sis === 'tan' && T >= Math.PI / 2 ? ' · <b style="color:#D1495B">T ≥ π/2: la solución escapa antes del final del intervalo</b>' : '') +
        (e.sis === 'cubo' && !(err < 1) ? ' · la solución existe para todo t ≥ 0, pero cerca de x₀ = 2 la constante de Lipschitz es 12: en un intervalo largo las iteraciones no se contraen y divergen. Existencia global y convergencia de Picard en todo [0, T] no son lo mismo.' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Iteraciones de Picard, x<sub>k+1</sub>(t) = x₀ + ∫₀ᵗ f(x<sub>k</sub>(s)) ds, empezando en x₀(t) = x₀. La línea negra discontinua es la solución (Runge–Kutta).</p>');
    selector(p, 'sis', 'Ecuación', [['lin', 'ẋ = x'], ['cuad', 'ẋ = x²'], ['tan', 'ẋ = 1 + x²'], ['cubo', 'ẋ = −x³']], e, () => dib());
    controles(p, [['T', 'Intervalo T', 0.1, 3, 1, 0.01], ['k', 'Iteraciones k', 0, 12, 4, 1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 320"></svg>');
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();
})();
