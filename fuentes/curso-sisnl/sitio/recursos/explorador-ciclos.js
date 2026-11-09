// Explorador de órbitas, osciladores y ciclos límite (parte 5). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-ciclos"></div>
//       <script src="../recursos/explorador-ciclos.js"></script>
// Cuatro pestañas: oscilador de fase, plano de fase, Kuramoto e índice.
// Los modelos son los mismos de codigo/cap05_orbitas_ciclos (C5_Ej3, Ej4, Ej5, Ej6, Ej7, Ej9, Ej10).
(function () {
  const raiz = document.getElementById('explorador-ciclos');
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

  montarPestanas([['fase', 'Oscilador de fase'], ['plano', 'Plano de fase'], ['kuramoto', 'Kuramoto'], ['indice', 'Índice']]);

  // ===== 1. Oscilador de fase: θ̇ = ω − a sin θ (C5_Ej4, Ej5) =====
  (function () {
    const p = panel('fase'), e = {};
    const dib = () => {
      const {w, a} = e, F = th => w - a * Math.sin(th);
      const ths = Array.from({length: 361}, (_, i) => 2 * Math.PI * i / 360);
      const lim = Math.max(Math.abs(w) + a, 1) * 1.15;
      const {X, Y} = ejes(svg1, 370, 280, {l: 44, r: 10, t: 12, b: 34}, [0, 2 * Math.PI], [-lim, lim], 'θ', 'θ̇ = ω − a sin θ');
      linea(svg1, ths.map(t => [X(t), Y(F(t))]), C.azul, 2.6);
      let txt;
      if (a > Math.abs(w)) {
        const s = Math.asin(w / a), est = Math.PI - s, ine = (s + 2 * Math.PI) % (2 * Math.PI);
        [[est, C.noche, 'black'], [ine, 'white', C.noche]].forEach(([th, fill, st]) =>
          svg1.insertAdjacentHTML('beforeend', `<circle cx="${X(((th % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI))}" cy="${Y(0)}" r="6" fill="${fill}" stroke="${C.noche}" stroke-width="2"/>`));
        txt = `<b style="color:#2A9D8F">a &gt; |ω|: la fase se engancha</b> en θ* = π − arcsin(ω/a) = ${f(est, 4)} (estable); el otro equilibrio es inestable.`;
      } else if (Math.abs(a - Math.abs(w)) < 1e-9) {
        txt = '<b style="color:#E09F3E">a = |ω|: un equilibrio semiestable</b> (bifurcación silla-nodo en el círculo).';
      } else {
        txt = `<b style="color:#D1495B">a &lt; |ω|: deriva</b>, período T = 2π/√(ω² − a²) = ${f(2 * Math.PI / Math.sqrt(w * w - a * a), 4)}`;
      }
      const {t, X: Th} = rk4((tt, x) => [F(x[0])], [0], 40, 0.01);
      const tmax = Math.max(...Th.map(v => v[0])), tmin = Math.min(...Th.map(v => v[0]));
      const {X: X2, Y: Y2} = ejes(svg2, 370, 280, {l: 44, r: 10, t: 12, b: 34}, [0, 40], [Math.min(0, tmin), Math.max(tmax, 2 * Math.PI)], 't', 'θ(t) (sin módulo 2π)');
      linea(svg2, t.map((tt, i) => [X2(tt), Y2(Th[i][0])]), C.coral, 2.4);
      res_.innerHTML = txt + ' Es también la diferencia de fase de dos osciladores acoplados (ω = Δω, a = a₁₂ + a₂₁) y la de una luciérnaga frente a su linterna (ω = Ω − ω₀, a = A).';
    };
    p.insertAdjacentHTML('beforeend', '<p>El oscilador no uniforme de la §5.4. Acerque a a ω desde abajo y mire cómo se demora la fase cerca de θ = π/2.</p>');
    controles(p, [['w', 'ω', -3, 3, 2, 0.01], ['a', 'a', 0, 4, 1, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 370 280"></svg><svg viewBox="0 0 370 280"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. Plano de fase (C5_Ej3, Ej9, Ej10) =====
  (function () {
    const p = panel('plano'), e = {};
    const sistemas = {
      vdp: {nom: 'van der Pol: ẍ + μ(x² − 1)ẋ + x = 0', par: 'μ', rango: [-2, 6, 1], caja: [-4.5, 4.5, -6, 6],
            f: (x, m) => [x[1], -x[0] - m * (x[0] ** 2 - 1) * x[1]], x0: [[0.1, 0], [3, 4], [-3, -4], [4, 0]], T: 40,
            nota: m => (m > 0 ? 'μ > 0: Liénard garantiza un único ciclo límite estable.' : m < 0 ? 'μ < 0: el mismo ciclo, recorrido hacia atrás: ahora es inestable y el origen es un foco estable.' : 'μ = 0: oscilador armónico, una familia de órbitas.')},
      polar: {nom: 'ṙ = r(c − r²), θ̇ = 1 (en cartesianas)', par: 'c', rango: [-1, 2, 1], caja: [-2, 2, -2, 2],
            f: (x, c) => { const r2 = x[0] ** 2 + x[1] ** 2; return [-x[1] + x[0] * (c - r2), x[0] + x[1] * (c - r2)]; },
            x0: [[0.05, 0], [1.9, 0], [0, -1.9]], T: 25,
            nota: c => (c > 0 ? `c > 0: ciclo límite estable de radio √c = ${f(Math.sqrt(c), 3)}.` : 'c ≤ 0: el origen es estable y no hay ciclo (bifurcación de Hopf en c = 0).')},
      duffing: {nom: 'Duffing: ẍ + δẋ + x³ − x = 0', par: 'δ', rango: [-0.3, 0.6, 0], caja: [-2, 2, -1.6, 1.6],
            f: (x, d) => [x[1], x[0] - x[0] ** 3 - d * x[1]], x0: [[1.3, 0], [0.5, 0], [-1.6, 0], [0.05, 1.1], [1.9, 0.6]], T: 30,
            nota: d => (Math.abs(d) < 1e-9 ? 'δ = 0: H se conserva; centros en (±1, 0) y órbitas homoclínicas.' : `δ ≠ 0: div f = −δ, Bendixson descarta todas las órbitas cerradas.`)},
      khalil: {nom: 'ẋ₁ = x₁ + x₂ − x₁r², ẋ₂ = −2x₁ + x₂ − x₂r² (Khalil, ej. 2.8)', par: 'c (frontera V = c)', rango: [0.5, 3, 1.5], caja: [-1.8, 1.8, -1.8, 1.8],
            f: (x) => { const r2 = x[0] ** 2 + x[1] ** 2; return [x[0] + x[1] - x[0] * r2, -2 * x[0] + x[1] - x[1] * r2]; },
            x0: [[0.02, 0], [1.7, 0]], T: 20, frontera: true,
            nota: c => `En V = ${f(c, 2)}: máx V̇ = 3c − 2c² = ${f(3 * c - 2 * c * c, 3)} ${3 * c - 2 * c * c <= 1e-9 ? '≤ 0: {V ≤ c} atrapa las trayectorias.' : '> 0: esta frontera no sirve.'}`},
      rm: {nom: 'Rosenzweig–MacArthur: v̇ = v(1 − v/K) − vp/(1+v), ṗ = p(2v/(1+v) − 1)', par: 'K', rango: [1.5, 6, 2.5], caja: [0, 6, 0, 3.5],
            f: (x, K) => [x[0] * (1 - x[0] / K) - x[0] * x[1] / (1 + x[0]), x[1] * (2 * x[0] / (1 + x[0]) - 1)], x0: [[1.1, 1.2], [3, 2.5], [0.5, 0.5]], T: 200,
            nota: K => (K < 3 ? 'K < K_H = 3: el equilibrio (1, (1−1/K)·2) es un foco estable.' : 'K > 3: foco inestable y un ciclo límite (paradoja del enriquecimiento).')}
    };
    const dib = () => {
      const S = sistemas[e.sis], m = e.m;
      const [x0a, x1a, y0a, y1a] = S.caja;
      const {X, Y} = ejes(svg, 560, 440, {l: 44, r: 10, t: 10, b: 32}, [x0a, x1a], [y0a, y1a], S.par === 'K' ? 'v' : 'x₁', S.par === 'K' ? 'p' : 'x₂');
      for (let i = 0; i <= 16; i++) for (let j = 0; j <= 13; j++) {
        const x = x0a + (x1a - x0a) * i / 16, y = y0a + (y1a - y0a) * j / 13, v = S.f([x, y], m), n = Math.hypot(v[0] * 560 / (x1a - x0a), v[1] * 440 / (y1a - y0a)) || 1;
        const dx = 11 * v[0] * 560 / (x1a - x0a) / n, dy = 11 * v[1] * 440 / (y1a - y0a) / n;
        svg.insertAdjacentHTML('beforeend', `<line x1="${X(x)}" y1="${Y(y)}" x2="${X(x) + dx}" y2="${Y(y) - dy}" stroke="#C9D1DE" stroke-width="1.2"/>`);
      }
      if (S.frontera) { const pts = []; for (let k = 0; k <= 200; k++) { const t = 2 * Math.PI * k / 200; pts.push([X(Math.sqrt(m) * Math.cos(t)), Y(Math.sqrt(m) * Math.sin(t))]); }
        linea(svg, pts, 3 * m - 2 * m * m <= 1e-9 ? C.verde : C.ambar, 2, '6 4'); }
      const cols = [C.azul, C.coral, C.violeta, C.ambar, C.verde];
      S.x0.forEach((x0, k) => { const {X: Z} = rk4((t, x) => S.f(x, m), x0, S.T, 0.01);
        linea(svg, Z.map(z => [X(dentro(z[0], x0a, x1a)), Y(dentro(z[1], y0a, y1a))]), cols[k % cols.length], 1.8); });
      res_.innerHTML = `<b>${S.nom}</b> · ${S.nota(m)}`;
    };
    p.insertAdjacentHTML('beforeend', '<p>Campo vectorial (gris) y varias trayectorias. Escoja el sistema y mueva su parámetro.</p>');
    selector(p, 'sis', 'Sistema', [['vdp', 'van der Pol'], ['polar', 'ciclo en polares'], ['duffing', 'Duffing'], ['khalil', 'Poincaré–Bendixson (Khalil)'], ['rm', 'Rosenzweig–MacArthur']], e, () => { const S = sistemas[e.sis];
      const r = p.querySelector('[data-id=m]'), n = p.querySelector('[data-num=m]'); r.min = n.min = S.rango[0]; r.max = n.max = S.rango[1]; e.m = S.rango[2]; r.value = n.value = S.rango[2];
      p.querySelector('.etq-par').textContent = S.par; dib(); });
    controles(p, [['m', '<span class="etq-par">μ</span>', -2, 6, 1, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 560 440" style="max-width:640px"></svg>');
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 3. Kuramoto (C5_Ej6) =====
  (function () {
    const p = panel('kuramoto'), e = {};
    const dib = () => {
      const N = Math.round(e.N), g = e.g, K = e.K;
      const w = Array.from({length: N}, (_, i) => g * Math.tan(Math.PI * (i + 0.5) / N - Math.PI / 2));
      const th0 = Array.from({length: N}, (_, i) => 2 * Math.PI * (((i + 1) * 0.6180339887) % 1));
      const F = (t, th) => { let c = 0, s = 0; for (const v of th) { c += Math.cos(v); s += Math.sin(v); }
        const r = Math.hypot(c, s) / N, ps = Math.atan2(s, c); return th.map((v, i) => w[i] + K * r * Math.sin(ps - v)); };
      const {t, X} = rk4(F, th0, 60, 0.05);
      const R = X.map(th => { let c = 0, s = 0; for (const v of th) { c += Math.cos(v); s += Math.sin(v); } return Math.hypot(c, s) / N; });
      const {X: X1, Y: Y1} = ejes(svg1, 460, 280, {l: 44, r: 10, t: 12, b: 34}, [0, 60], [0, 1], 't', 'r(t)');
      linea(svg1, t.map((tt, i) => [X1(tt), Y1(R[i])]), C.azul, 2.4);
      const teo = K > 2 * g ? Math.sqrt(1 - 2 * g / K) : 0;
      linea(svg1, [[X1(0), Y1(teo)], [X1(60), Y1(teo)]], C.noche, 1.4, '6 4');
      const fin = X[X.length - 1];
      let s2 = `<circle cx="140" cy="140" r="110" fill="none" stroke="#C9D1DE" stroke-width="2"/>`;
      fin.forEach((v, i) => { const col = w[i] < 0 ? C.azul : C.coral; s2 += `<circle cx="${140 + 110 * Math.cos(v)}" cy="${140 - 110 * Math.sin(v)}" r="3.5" fill="${col}" opacity=".75"/>`; });
      let c = 0, s = 0; for (const v of fin) { c += Math.cos(v); s += Math.sin(v); } c /= N; s /= N;
      s2 += `<line x1="140" y1="140" x2="${140 + 110 * c}" y2="${140 - 110 * s}" stroke="${C.noche}" stroke-width="3"/>`;
      svg2.innerHTML = s2;
      const rfin = R.slice(-200).reduce((a, b) => a + b, 0) / 200;
      res_.innerHTML = `K<sub>c</sub> = 2γ = ${f(2 * g, 3)} · r promedio en t ∈ [50, 60] = <b>${f(rfin, 3)}</b> · teoría (N → ∞): ${K > 2 * g ? f(teo, 3) : '0'}` +
        (K <= 2 * g ? ' · por debajo del umbral, r solo tiene ruido de tamaño finito ~ 1/√N.' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Kuramoto con frecuencias de Lorentz (cuantiles, ancho γ). A la derecha, las fases en t = 60 (azul: ω<sub>i</sub> &lt; 0, coral: ω<sub>i</sub> &gt; 0) y la flecha r e<sup>jΨ</sup>. La línea discontinua es √(1 − K<sub>c</sub>/K).</p>');
    controles(p, [['K', 'Acoplamiento K', 0, 4, 2, 0.01], ['g', 'Ancho γ', 0.1, 1.5, 0.5, 0.01], ['N', 'N osciladores', 10, 300, 120, 1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.6fr 1fr;gap:.5rem"><svg viewBox="0 0 460 280"></svg><svg viewBox="0 0 280 280"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 4. Índice (C5_Ej7) =====
  (function () {
    const p = panel('indice'), e = {};
    const campos = {nodo: [x => [-x[0], -x[1]], 'nodo estable (0,0)'], silla: [x => [x[0], -x[1]], 'silla (0,0)'],
      foco: [x => [x[0] - x[1], x[0] + x[1]], 'foco inestable (0,0)'], z2: [x => [x[0] ** 2 - x[1] ** 2, 2 * x[0] * x[1]], 'z² (índice 2 en 0)'],
      zb2: [x => [x[0] ** 2 - x[1] ** 2, -2 * x[0] * x[1]], 'z̄² (índice −2 en 0)'],
      khalil: [x => [-x[0] + x[0] * x[1], x[0] + x[1] - 2 * x[0] * x[1]], 'silla (0,0) y foco (1,1)'],
      dege: [x => [x[0] ** 2 * x[1], x[0] ** 2 - x[1] ** 2], 'degenerado: (x₁²x₂, x₁² − x₂²)'],
      duff: [x => [x[1], x[0] - x[0] ** 3], 'Duffing: silla (0,0), centros (±1,0)']};
    const dib = () => {
      const [F, nom] = campos[e.campo], cx = e.cx, cy = e.cy, R = e.R;
      const {X, Y} = ejes(svg1, 400, 380, {l: 40, r: 10, t: 10, b: 30}, [-2.5, 2.5], [-2.5, 2.5], 'x₁', 'x₂');
      const circ = []; for (let k = 0; k <= 200; k++) { const t = 2 * Math.PI * k / 200; circ.push([X(cx + R * Math.cos(t)), Y(cy + R * Math.sin(t))]); }
      linea(svg1, circ, C.gris, 1.6);
      let ang0 = null, acumul = 0, prev = null, minN = Infinity; const n = 2000;
      for (let k = 0; k <= n; k++) { const t = 2 * Math.PI * k / n, v = F([cx + R * Math.cos(t), cy + R * Math.sin(t)]);
        minN = Math.min(minN, Math.hypot(v[0], v[1])); const a = Math.atan2(v[1], v[0]);
        if (prev !== null) { let d = a - prev; while (d > Math.PI) d -= 2 * Math.PI; while (d < -Math.PI) d += 2 * Math.PI; acumul += d; } prev = a; }
      const I = acumul / (2 * Math.PI);
      const colsPts = [C.azul, C.violeta, C.verde, C.ambar, C.coral, C.noche];
      let s2 = '<circle cx="140" cy="140" r="100" fill="none" stroke="#C9D1DE" stroke-width="2"/>';
      for (let k = 0; k < 16; k++) { const t = 2 * Math.PI * k / 16, x = [cx + R * Math.cos(t), cy + R * Math.sin(t)], v = F(x), nv = Math.hypot(v[0], v[1]) || 1;
        const col = `hsl(${220 - 200 * k / 16},60%,45%)`;
        svg1.insertAdjacentHTML('beforeend', `<line x1="${X(x[0])}" y1="${Y(x[1])}" x2="${X(x[0]) + 22 * v[0] / nv}" y2="${Y(x[1]) - 22 * v[1] / nv}" stroke="${col}" stroke-width="2.2"/><circle cx="${X(x[0])}" cy="${Y(x[1])}" r="2.5" fill="${col}"/>`);
        s2 += `<line x1="140" y1="140" x2="${140 + 100 * v[0] / nv}" y2="${140 - 100 * v[1] / nv}" stroke="${col}" stroke-width="2.2"/><text x="${140 + 116 * v[0] / nv}" y="${144 - 116 * v[1] / nv}" font-size="11" text-anchor="middle" fill="${col}">${k + 1}</text>`; }
      svg2.innerHTML = s2;
      res_.innerHTML = minN < 1e-3 ? '<b style="color:#D1495B">La curva pasa (casi) por un equilibrio: el índice no está definido. Muévala.</b>' :
        `<b>${nom}</b> · índice de la circunferencia = <b>${Math.round(I) === 0 ? '0' : (I > 0 ? '+' : '') + Math.round(I)}</b> (cálculo: ${f(I, 4)})` +
        (Math.round(I) === 1 ? ' · podría ser una órbita (necesario, no suficiente).' : ' · <b style="color:#D1495B">no puede ser una órbita cerrada.</b>');
    };
    p.insertAdjacentHTML('beforeend', '<p>Mueva y agrande la circunferencia. Los vectores numerados (izquierda) se trasladan al origen (derecha); el índice es el número neto de vueltas. Mientras la curva no cruce un equilibrio, el índice no cambia.</p>');
    selector(p, 'campo', 'Campo', [['nodo', 'nodo'], ['silla', 'silla'], ['foco', 'foco'], ['z2', 'z²'], ['zb2', 'z̄²'], ['khalil', 'silla + foco (ej. 5.11)'], ['dege', 'degenerado (ej. 5.12)'], ['duff', 'Duffing']], e, () => dib());
    controles(p, [['cx', 'centro x₁', -2, 2, 0, 0.01], ['cy', 'centro x₂', -2, 2, 0, 0.01], ['R', 'radio', 0.1, 2.4, 1, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1.4fr 1fr;gap:.5rem"><svg viewBox="0 0 400 380"></svg><svg viewBox="0 0 280 280"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();
})();
