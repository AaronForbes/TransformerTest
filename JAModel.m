function [B,H,A,E,P] = JAModel(app)

t = (0:app.dt:0.2*2*pi)';
A = [1 1.4 2:5 7];
A = [A.*1e-1 A.*1e0 A.*1e1 1e2];

dH = 10000.*A.*cos(10.*t);
%dH = (max(H)).*cos(t);
H = app.dt.*cumsum(dH)+1e-30;
Ha = H./app.a;
Man = app.Ms.*(1./tanh(Ha)-1./Ha);
Mirr = Man .* 0;
dM = H.*0;

for i = 2:size(H,1)
    prev = Mirr(i-1,:);
    dM(i,:) = Man(i,:)-prev;
    Mirr(i,:) = prev + app.dt .* max(dM(i,:).*dH(i,:),0) ./ (app.kp.*sign(dH(i,:)) - app.alpha.*dM(i,:));
end

M = Mirr + app.cr*(Man-Mirr);
B = 4*pi*10^-7*(H+M);
dM = Mirr([2:end end],:)-Mirr([1 1:end-1],:);
P = H.*dM.*(1-app.cr).*4*pi*10^-7;
E = sum(P.*app.dt./2);
end