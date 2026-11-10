// Explorador de estabilidad de Lyapunov (parte 7). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-lyapunov"></div>
//       <script src="../recursos/explorador-lyapunov.js"></script>
// Cuatro pestañas: péndulo (energía y término cruzado), formas cuadráticas,
// ecuación de Lyapunov y región de atracción. Los modelos son los de codigo/cap07_lyapunov.
(function () {
  const raiz = document.getElementById('explorador-lyapunov');
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
  const eig2s = (a, b, d) => { const m = (a + d) / 2, r = Math.sqrt(((a - d) / 2) ** 2 + b * b); return [m - r, m + r]; };   // simétrica [a b; b d]
  const lyap2 = (A, Q) => {   // A'P + PA = -Q, 2x2; devuelve [p1, p2, p3] o null
    const [[a, b], [c, d]] = A;
    const M = [[2 * a, 2 * c, 0], [b, a + d, c], [0, 2 * b, 2 * d]], r = [-Q[0][0], -Q[0][1], -Q[1][1]];
    const det3 = m => m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
    const D = det3(M); if (Math.abs(D) < 1e-9) return null;
    return [0, 1, 2].map(j => det3(M.map((fila, i) => fila.map((v, k) => (k === j ? r[i] : v)))) / D);
  };
  const eigA = A => { const tr = A[0][0] + A[1][1], de = A[0][0] * A[1][1] - A[0][1] * A[1][0], di = tr * tr / 4 - de;
    return di >= 0 ? [[tr / 2 - Math.sqrt(di), 0], [tr / 2 + Math.sqrt(di), 0]] : [[tr / 2, -Math.sqrt(-di)], [tr / 2, Math.sqrt(-di)]]; };
  const txtEig = ev => ev.map(([re, im]) => (Math.abs(im) < 1e-9 ? f(re, 3) : `${f(re, 3)} ${im < 0 ? '−' : '+'} ${f(Math.abs(im), 3)}j`)).join(', ');
  // elipse {x'Px = c} con P = [p1 p2; p2 p3] > 0
  const elipse = (p1, p2, p3, c, n = 160) => { const [l1, l2] = eig2s(p1, p2, p3);
    const th = Math.abs(p2) < 1e-12 ? (p1 <= p3 ? 0 : Math.PI / 2) : Math.atan2(l1 - p1, p2);
    const pts = []; for (let i = 0; i <= n; i++) { const t = 2 * Math.PI * i / n, z1 = Math.sqrt(c / l1) * Math.cos(t), z2 = Math.sqrt(c / l2) * Math.sin(t);
      pts.push([Math.cos(th) * z1 - Math.sin(th) * z2, Math.sin(th) * z1 + Math.cos(th) * z2]); } return pts; };

  montarPestanas([['pendulo', 'Péndulo: energía y término cruzado'], ['formas', 'Formas cuadráticas'], ['lineal', 'Ecuación de Lyapunov'], ['region', 'Región de atracción']]);

  // ===== 1. Péndulo (C7_Ej3, C7_Ej6) =====
  (function () {
    const p = panel('pendulo'), e = {};
    const dib = () => {
      const a = 1, b = e.b, q = e.p12 * b;
      const V = x => 0.5 * (b * q * x[0] ** 2 + 2 * q * x[0] * x[1] + x[1] ** 2) + a * (1 - Math.cos(x[0]));
      const Vd = x => -a * q * x[0] * Math.sin(x[0]) - (b - q) * x[1] ** 2;
      const cst = 2 * a + Math.PI ** 2 / 2 * q * (b - q);
      const R = rk4((t, x) => [x[1], -a * Math.sin(x[0]) - b * x[1]], [e.x1, e.x2], 40, 0.01);
      const {X, Y} = ejes(svg1, 420, 300, {l: 40, r: 10, t: 12, b: 34}, [-5, 10], [-4, 4], 'x₁', 'x₂');
      svg1.insertAdjacentHTML('beforeend', `<rect x="${X(-Math.PI)}" y="${Y(4)}" width="${X(Math.PI) - X(-Math.PI)}" height="${Y(-4) - Y(4)}" fill="#2A9D8F" fill-opacity="0.06"/>`);
      // nivel c* de V: por rayos desde el origen dentro de |x1| < pi
      const nivel = c => { const pts = []; for (let i = 0; i <= 240; i++) { const t = 2 * Math.PI * i / 240, d = [Math.cos(t), Math.sin(t)];
        let lo = 0, hi = 6; if (V([hi * d[0], hi * d[1]]) < c && Math.abs(hi * d[0]) < Math.PI) { pts.push([NaN, NaN]); continue; }
        for (let k = 0; k < 50; k++) { const m = (lo + hi) / 2, x = [m * d[0], m * d[1]]; if (V(x) < c && Math.abs(x[0]) <= Math.PI) lo = m; else hi = m; }
        pts.push([X(lo * d[0]), Y(lo * d[1])]); } return pts; };
      linea(svg1, nivel(cst * 0.999), C.verde, 2.6);
      for (const xv of [-Math.PI, Math.PI]) linea(svg1, [[X(xv), Y(-4)], [X(xv), Y(4)]], C.gris, 1, '3 3');
      linea(svg1, sub(R.X.map(x => [X(dentro(x[0], -5, 10)), Y(dentro(x[1], -4, 4))]), 800), C.coral, 2);
      svg1.insertAdjacentHTML('beforeend', `<circle cx="${X(e.x1)}" cy="${Y(e.x2)}" r="4" fill="${C.coral}"/>`);
      const VV = R.X.map(V), VD = R.X.map(Vd);
      const {X: X2, Y: Y2} = ejes(svg2, 320, 300, {l: 46, r: 8, t: 12, b: 34}, [0, 40], [Math.min(0, ...VD) * 1.05 - 0.05, Math.max(...VV) * 1.05 + 0.05], 't', 'V y V̇');
      linea(svg2, sub(R.t.map((t, i) => [X2(t), Y2(VV[i])]), 600), C.verde, 2.2);
      linea(svg2, sub(R.t.map((t, i) => [X2(t), Y2(VD[i])]), 600), C.violeta, 1.6);
      const xf = R.X[R.X.length - 1][0], n = Math.round(xf / (2 * Math.PI)), V0 = V([e.x1, e.x2]);
      const sale = R.X.some(x => Math.abs(x[0]) >= Math.PI);
      res.innerHTML = `p₁₂ = ${f(q, 3)}: c* = ${f(cst, 3)} (energía: ${f(2 * a, 3)}). V(x₀) = ${f(V0, 3)} ${V0 < cst && Math.abs(e.x1) < Math.PI ? '<b style="color:#2A9D8F">&lt; c*: x₀ ∈ Ω<sub>c*</sub>, convergencia garantizada</b>' : '≥ c* o fuera de D: sin garantía'}. ` +
        `Termina en (${n === 0 ? '0' : n === 1 ? '2π' : n === -1 ? '−2π' : n + '·2π'}, 0).` + (sale && Math.abs(e.x1) < Math.PI ? ' <b style="color:#D1495B">Arrancó en D y salió de D: D no es una estimación de la región de atracción.</b>' : '') +
        (q === 0 ? ' Con p₁₂ = 0 (la energía), V̇ = −b x₂² se anula cada vez que x₂ = 0: vea los escalones.' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>x₁′ = x₂, x₂′ = −sin x₁ − b x₂ con V = ½ x′[b p₁₂ p₁₂; p₁₂ 1]x + (1 − cos x₁). El término cruzado se da como fracción de b (0 = energía). En verde, el mayor nivel Ω<sub>c*</sub> dentro de D = {|x₁| &lt; π} (sombreado); a la derecha, V (verde) y V̇ (violeta) a lo largo de la solución.</p>');
    controles(p, [['p12', 'p₁₂ / b', 0, 0.95, 0.5, 0.05], ['b', 'Fricción b', 0.05, 1.5, 0.5, 0.05], ['x1', 'x₁(0)', -3.1, 3.1, 1.5, 0.05], ['x2', 'x₂(0)', -3.5, 3.5, 3, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.3fr 1fr;gap:.5rem"><svg viewBox="0 0 420 300"></svg><svg viewBox="0 0 320 300"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. Formas cuadráticas (C7_Ej5, C7_Video_FormasCuadraticas) =====
  (function () {
    const p = panel('formas'), e = {};
    const curvas = (l1, l2, c) => {          // {l1 z1² + l2 z2² = c} en coordenadas propias
      const out = [], S = s => Array.from({length: 121}, (_, i) => -2.5 + 5 * i / 120).map(s), eps = 0.02;
      if (l1 * c > 0 && l2 * c > 0) out.push(Array.from({length: 161}, (_, i) => { const t = 2 * Math.PI * i / 160; return [Math.sqrt(c / l1) * Math.cos(t), Math.sqrt(c / l2) * Math.sin(t)]; }));
      else if (Math.abs(l2) < eps && l1 * c > 0) for (const sg of [-1, 1]) out.push([[sg * Math.sqrt(c / l1), -9], [sg * Math.sqrt(c / l1), 9]]);
      else if (Math.abs(l1) < eps && l2 * c > 0) for (const sg of [-1, 1]) out.push([[-9, sg * Math.sqrt(c / l2)], [9, sg * Math.sqrt(c / l2)]]);
      else if (l1 * c > 0 && l2 * c < 0) for (const sg of [-1, 1]) out.push(S(s => [sg * Math.sqrt(c / l1) * Math.cosh(s), Math.sqrt(-c / l2) * Math.sinh(s)]));
      else if (l1 * c < 0 && l2 * c > 0) for (const sg of [-1, 1]) out.push(S(s => [Math.sqrt(-c / l1) * Math.sinh(s), sg * Math.sqrt(c / l2) * Math.cosh(s)]));
      return out;
    };
    const dib = () => {
      const th = e.th * Math.PI / 180, ct = Math.cos(th), st = Math.sin(th), l1 = e.l1, l2 = e.l2;
      const p1 = l1 * ct * ct + l2 * st * st, p2 = (l1 - l2) * ct * st, p3 = l1 * st * st + l2 * ct * ct;
      const {X, Y} = ejes(svg, 420, 380, {l: 40, r: 10, t: 12, b: 34}, [-2.5, 2.5], [-2.2, 2.2], 'x₁', 'x₂');
      const rot = z => [X(ct * z[0] - st * z[1]), Y(st * z[0] + ct * z[1])];
      for (const sg of [1, -1]) for (const c of [0.25, 0.5, 1, 2, 3]) for (const cur of curvas(l1, l2, sg * c))
        linea(svg, cur.map(z => { const w = rot(z); return [w[0], w[1]]; }).map(([a, b]) => [a < 40 || a > 410 ? NaN : a, b < 12 || b > 346 ? NaN : b]), sg > 0 ? C.azul : C.coral, 1.4);
      for (const [v, col] of [[[ct, st], C.noche], [[-st, ct], C.verde]]) linea(svg, [[X(-2.2 * v[0]), Y(-2.2 * v[1])], [X(2.2 * v[0]), Y(2.2 * v[1])]], col, 1, '3 3');
      const D1 = p1, D2 = p1 * p3 - p2 * p2, mn = Math.min(l1, l2), mx = Math.max(l1, l2);
      const clase = mn > 1e-9 ? 'definida positiva' : mx < -1e-9 ? 'definida negativa' : Math.abs(mn) <= 1e-9 && mx > 0 ? 'semidefinida positiva' : Math.abs(mx) <= 1e-9 && mn < 0 ? 'semidefinida negativa' : mx === 0 && mn === 0 ? 'nula' : 'indefinida';
      res.innerHTML = `P = [${f(p1)} ${f(p2)}; ${f(p2)} ${f(p3)}]. Menores líderes: Δ₁ = ${f(D1)}, Δ₂ = ${f(D2)}. Valores propios: ${f(l1)}, ${f(l2)}. <b>P es ${clase}.</b>` +
        (D1 >= -1e-9 && D2 >= -1e-9 && mn < -1e-9 ? ' <b style="color:#D1495B">Trampa: menores líderes ≥ 0 y P no es semidefinida positiva (mire p₂₂).</b>' : '') +
        ' Azul: niveles positivos; rojo: negativos; punteados: los vectores propios.';
    };
    p.insertAdjacentHTML('beforeend', '<p>V(x) = x′Px con P = R(θ) diag(λ₁, λ₂) R(θ)′. Baje λ₂ por cero y vea las elipses abrirse en franjas y luego en hipérbolas. Para ver la trampa de Sylvester, ponga θ = 0, λ₁ = 0 y λ₂ negativo.</p>');
    controles(p, [['l1', 'λ₁', -3, 3, 2, 0.05], ['l2', 'λ₂', -3, 3, 0.5, 0.05], ['th', 'θ [grados]', 0, 180, 30, 1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 420 380" style="max-width:520px"></svg>');
    const svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 3. Ecuación de Lyapunov (C7_Ej8, C7_Ej9) =====
  (function () {
    const p = panel('lineal'), e = {};
    const casos = {hurwitz: [0, -1, 1, -1], nonormal: [-1, 10, 0, -2], inestable: [-1, 2, 0, 0.5], centro: [0, 1, -1, 0]};
    const dib = () => {
      const A = [[e.a11, e.a12], [e.a21, e.a22]], Q = [[1, 0], [0, e.q]], ev = eigA(A), hur = ev.every(([re]) => re < 0);
      const sol = lyap2(A, Q);
      const R = rk4((t, x) => [A[0][0] * x[0] + A[0][1] * x[1], A[1][0] * x[0] + A[1][1] * x[1]], [e.x01, e.x02], 10, 0.01);
      const nx = R.X.map(x => Math.hypot(x[0], x[1])), lim = Math.min(8, Math.max(1.5, ...nx.map(v => (isFinite(v) ? v : 0))) * 1.1);
      const {X, Y} = ejes(svg1, 340, 320, {l: 40, r: 10, t: 12, b: 34}, [-lim, lim], [-lim, lim], 'x₁', 'x₂');
      let txt = `Valores propios de A: ${txtEig(ev)} (${hur ? 'Hurwitz' : 'no Hurwitz'}). `;
      let VV = null;
      if (!sol) txt += '<b style="color:#D1495B">A′P + PA = −Q no tiene solución única (λᵢ + λⱼ = 0 para algún par).</b>';
      else {
        const [p1, p2, p3] = sol, lp = eig2s(p1, p2, p3);
        txt += `P = [${f(p1)} ${f(p2)}; ${f(p2)} ${f(p3)}], valores propios ${f(lp[0])} y ${f(lp[1])}: `;
        if (lp[0] > 0) {
          txt += '<b style="color:#2A9D8F">P &gt; 0</b>.';
          VV = R.X.map(x => p1 * x[0] ** 2 + 2 * p2 * x[0] * x[1] + p3 * x[1] ** 2);
          for (const k of [0, 40, 120]) if (k < VV.length && VV[k] > 1e-12) { linea(svg1, elipse(p1, p2, p3, VV[k]).map(([a, b]) => [X(a), Y(b)]), C.verde, 1.6);
            linea(svg1, Array.from({length: 121}, (_, i) => [X(nx[k] * Math.cos(2 * Math.PI * i / 120)), Y(nx[k] * Math.sin(2 * Math.PI * i / 120))]), C.coral, 1); }
          const M = Math.sqrt(lp[1] / lp[0]);
          txt += ` x₀′Px₀ = ${f(VV[0])} = ∫ x′Qx dt. Cota: ‖x(t)‖ ≤ ${f(M, 2)}‖x₀‖e^(−${f(Math.min(1, e.q) / (2 * lp[1]), 3)}t).`;
        } else txt += `<b style="color:#D1495B">P no es definida positiva</b> (${lp[0] < 0 ? 'tiene ' + (lp[1] < 0 ? 'dos valores propios negativos' : 'un valor propio negativo') : 'es singular'}): ${hur ? '' : 'tantos valores propios negativos como valores propios inestables de A.'}`;
      }
      const crece = nx.some((v, i) => i > 0 && v > nx[0] * 1.001);
      if (hur && crece) txt += ' <b style="color:#D1495B">A es Hurwitz y aun así ‖x(t)‖ crece al principio.</b>';
      linea(svg1, sub(R.X.map(x => [X(dentro(x[0], -lim, lim)), Y(dentro(x[1], -lim, lim))]), 500), C.azul, 2);
      svg1.insertAdjacentHTML('beforeend', `<circle cx="${X(e.x01)}" cy="${Y(e.x02)}" r="4" fill="${C.azul}"/>`);
      const top = Math.min(10, Math.max(1.2, ...nx.map(v => v / nx[0]).filter(isFinite)) * 1.1);
      const {X: X2, Y: Y2} = ejes(svg2, 340, 320, {l: 40, r: 8, t: 12, b: 34}, [0, 10], [0, top], 't', 'normalizadas');
      linea(svg2, sub(R.t.map((t, i) => [X2(t), Y2(dentro(nx[i] / nx[0], 0, top))]), 500), C.coral, 2);
      if (VV) linea(svg2, sub(R.t.map((t, i) => [X2(t), Y2(Math.sqrt(VV[i] / VV[0]))]), 500), C.verde, 2);
      res.innerHTML = txt;
    };
    p.insertAdjacentHTML('beforeend', '<p>ẋ = Ax con Q = diag(1, q). Izquierda: la trayectoria (azul), círculos por x(t) (rojo) y elipses de P (verde) en tres instantes. Derecha: ‖x(t)‖/‖x₀‖ (rojo) y √(V/V₀) (verde).</p>');
    selector(p, 'caso', 'Casos', [['hurwitz', 'van der Pol linealizado [0 −1; 1 −1]'], ['nonormal', 'no normal [−1 10; 0 −2]'], ['inestable', 'inestable [−1 2; 0 0.5]'], ['centro', 'centro [0 1; −1 0]']], e, () => {
      const c = casos[e.caso]; ['a11', 'a12', 'a21', 'a22'].forEach((k, i) => { e[k] = c[i]; p.querySelector(`[data-id=${k}]`).value = c[i]; p.querySelector(`[data-num=${k}]`).value = c[i]; });
      if (e.caso === 'nonormal') { e.x01 = 0; e.x02 = 1; p.querySelector('[data-id=x01]').value = 0; p.querySelector('[data-num=x01]').value = 0; p.querySelector('[data-id=x02]').value = 1; p.querySelector('[data-num=x02]').value = 1; }
      dib(); });
    controles(p, [['a11', 'a₁₁', -3, 3, 0, 0.1], ['a12', 'a₁₂', -12, 12, -1, 0.1], ['a21', 'a₂₁', -12, 12, 1, 0.1], ['a22', 'a₂₂', -3, 3, -1, 0.1], ['q', 'q (Q = diag(1, q))', 0.1, 5, 1, 0.1], ['x01', 'x₁(0)', -2, 2, 1.2, 0.1], ['x02', 'x₂(0)', -2, 2, 1, 0.1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 340 320"></svg><svg viewBox="0 0 340 320"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 4. Región de atracción: van der Pol invertido (C7_Ej10) =====
  (function () {
    const p = panel('region'), e = {};
    const F = (t, x) => [-x[1], x[0] + (x[0] ** 2 - 1) * x[1]];
    const cic = rk4((t, x) => F(t, x).map(v => -v), [2, 0], 30, 0.01).X.slice(1500);
    const A = [[0, -1], [1, -1]];
    const dib = () => {
      const q = e.q, [p1, p2, p3] = lyap2(A, [[1, 0], [0, q]]);
      let cst = Infinity, xt = null;
      for (let i = 0; i < 3600; i++) { const t = 2 * Math.PI * i / 3600, c = Math.cos(t), s = Math.sin(t);
        const N = 2 * (p2 * c + p3 * s) * c * c * s; if (N <= 0) continue;
        const r2 = (c * c + q * s * s) / N, v = r2 * (p1 * c * c + 2 * p2 * c * s + p3 * s * s); if (v < cst) { cst = v; xt = [Math.sqrt(r2) * c, Math.sqrt(r2) * s]; } }
      const c = e.frac * cst, lp = eig2s(p1, p2, p3);
      const {X, Y} = ejes(svg, 440, 400, {l: 40, r: 10, t: 12, b: 34}, [-3, 3], [-3, 3], 'x₁', 'x₂');
      linea(svg, cic.map(x => [X(x[0]), Y(x[1])]), C.noche, 1.4);
      const cur = [];   // curva Vdot = 0 por rayos
      for (let i = 0; i <= 720; i++) { const t = 2 * Math.PI * i / 720, cc = Math.cos(t), s = Math.sin(t), N = 2 * (p2 * cc + p3 * s) * cc * cc * s;
        const r = N > 0 ? Math.sqrt((cc * cc + q * s * s) / N) : NaN; cur.push(r < 4.3 ? [X(dentro(r * cc, -3, 3)), Y(dentro(r * s, -3, 3))] : [NaN, NaN]); }
      linea(svg, cur, C.coral, 1.3);
      linea(svg, elipse(p1, p2, p3, c).map(([a, b]) => [X(a), Y(b)]), C.verde, 2.6);
      let conv = 0;
      for (let k = 0; k < 8; k++) { const d = elipse(p1, p2, p3, c, 8)[k];
        const R = rk4(F, d, 15, 0.01); const fin = R.X[R.X.length - 1], ok = Math.hypot(...fin) < 0.05; conv += ok;
        linea(svg, sub(R.X.map(x => [X(dentro(x[0], -3, 3)), Y(dentro(x[1], -3, 3))]), 400), ok ? C.azul : C.ambar, 1.2); }
      if (xt) svg.insertAdjacentHTML('beforeend', `<circle cx="${X(xt[0])}" cy="${Y(xt[1])}" r="4" fill="${C.coral}"/>`);
      const area = Math.PI * c / Math.sqrt(p1 * p3 - p2 * p2);
      res.innerHTML = `Q = diag(1, ${f(q, 2)}): P = [${f(p1)} ${f(p2)}; ${f(p2)} ${f(p3)}]. c* = ${f(cst, 3)} (tangencia en el punto rojo); con bolas, c &lt; ${f(lp[0] * 2 / Math.sqrt(5), 3)} (solo para Q = I). ` +
        `Nivel dibujado: c = ${f(c, 3)} (${f(e.frac, 2)} c*), área ${f(area, 2)}. Desde 8 puntos de su frontera, convergen ${conv}.` +
        (e.frac > 1 ? ' <b style="color:#D1495B">Con c &gt; c*, Ω<sub>c</sub> sale de la región donde V̇ &lt; 0: deja de ser una estimación certificada (aunque algunos puntos todavía converjan).</b>' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>x₁′ = −x₂, x₂′ = x₁ + (x₁² − 1)x₂. V = x′Px con A′P + PA = −Q, A la linealización. Negro: el ciclo límite (frontera real de la región de atracción); rojo: V̇ = 0; verde: Ω<sub>c</sub>; azul o ámbar: soluciones desde su frontera (convergen o no).</p>');
    controles(p, [['frac', 'c / c*', 0.1, 1.6, 1, 0.01], ['q', 'q (Q = diag(1, q))', 0.2, 5, 1, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 440 400" style="max-width:560px"></svg>');
    const svg = p.querySelector('svg'), res = p.querySelector('.exp-resumen');
    dib();
  })();
})();
