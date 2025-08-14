function JAModelws(params, dt) {
    // params: [cr, Ms, a, kp, alpha]
    const p = {
        cr: params[0],
        Ms: params[1],
        a: params[2],
        kp: params[3],
        alpha: params[4]
    };

    // Time vector: t = (0:dt:0.2*2*pi)';
    const t = [];
    const tMax = 0.2 * 2 * Math.PI;
    for (let ti = 0; ti <= tMax; ti += dt) {
        t.push(ti);
    }

    // A = [0.1 0.15 0.2:0.1:0.5 0.7 1. 1.5 2:1:6 8 10 15 20];
    const A = [0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.7, 1, 1.5, 2, 3, 4, 5, 6, 8, 10, 15, 20];

    // dH = 10000.*A.*cos(10.*t);
    const dH = t.map(ti => A.map(Aj => 10000 * Aj * Math.cos(10 * ti)));

    // H = dt.*cumsum(dH)+1e-30;
    let H = [];
    for (let i = 0; i < t.length; i++) {
        H[i] = [];
        for (let j = 0; j < A.length; j++) {
            if (i === 0) {
                H[i][j] = dt * dH[i][j] + 1e-30;
            } else {
                H[i][j] = H[i - 1][j] + dt * dH[i][j];
            }
        }
    }

    // Ha = H./p.a;
    const Ha = H.map(row => row.map(Hij => Hij / p.a));

    // Man = p.Ms.*(1./tanh(Ha)-1./Ha);
    const Man = Ha.map(row => row.map(Haij => {
        return p.Ms * (1 / Math.tanh(Haij) - 1 / (Haij === 0 ? 1e-12 : Haij));
    }));

    // Mirr = Man .* 0;
    const Mirr = Man.map(row => row.map(() => 0));

    // for i = 2:size(H,1)
    for (let i = 1; i < t.length; i++) {
        for (let j = 0; j < A.length; j++) {
            const prev = Mirr[i - 1][j];
            const dHi = dH[i][j];
            const dM = Man[i][j] - prev;
            const denom = p.kp * Math.sign(dHi) - p.alpha * dM;
            Mirr[i][j] = prev + dt * Math.max(dM * dHi, 0) / (denom !== 0 ? denom : 1e-12);
        }
    }

    // M = Mirr + p.cr*(Man-Mirr);
    const M = Mirr.map((row, i) => row.map((Mirrij, j) => Mirrij + p.cr * (Man[i][j] - Mirrij)));

    // B = 4*pi*10^-7*(H+M);
    const B = H.map((row, i) => row.map((Hij, j) => 4 * Math.PI * 1e-7 * (Hij + M[i][j])));

    // E = sum(dH.*Mirr.*(1-p.cr).*4*pi*10^-7);
    let E = new Array(A.length).fill(0);
    for (let i = 0; i < t.length; i++) {
        for (let j = 0; j < A.length; j++) {
            E[j] += dH[i][j] * Mirr[i][j] * (1 - p.cr) * 4 * Math.PI * 1e-7;
        }
    }

    // concatenate B and H
    const Bcat = [];
    const Hcat = [];
    for (let j = 0; j < A.length; j++) {
        for (let i = 0; i < t.length; i++) {
            Bcat.push(B[i][j]);
            Hcat.push(H[i][j] / 1000);
        }
    }

    return { B: Bcat, H: Hcat, E, A };
}