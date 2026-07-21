function result = StStsolver()
%STSTSOLVER Solve for the steady state of the pH process at pH = 7.
%   Returns [Wa4_ss, Wb4_ss, h_ss, q3_ss].
X0 = [-4.32e-4, 5.28e-4, 14, 15.6];
result = fsolve(@equations, X0, optimoptions('fsolve','Display','off'));
fprintf('%10s  %11s %10s %13s\n','Wa4_ss','Wb4_ss','h_ss','q3_ss')
fprintf('%12.8f %12.8f %12.8f %12.8f\n', result)
end

function y = equations(X)
Wa4_ss = X(1); Wb4_ss = X(2); h_ss = X(3); q3_ss = X(4);
A = 207;
Wa1 = 0.003;  q1 = 16.6;
Wa2 = -0.03;  q2 = 0.55;
Wa3 = -3.05e-3;
Wb1 = 0; Wb2 = 0.03; Wb3 = 5e-5;
pH = 7;
% Standard chemistry convention, pK = -log10(Ka); matches plant_simu.m.
pK1 = -log10(4.47e-7);
pK2 = -log10(5.62e-11);
Cv = 4.581; z = 11.5; n = 0.607;

y(1) = ((1/(A*h_ss))*(Wa1-Wa4_ss))*q1 + ((1/(A*h_ss))*(Wa2-Wa4_ss))*q2 + ((1/(A*h_ss))*(Wa3-Wa4_ss))*q3_ss;
y(2) = ((1/(A*h_ss))*(Wb1-Wb4_ss))*q1 + ((1/(A*h_ss))*(Wb2-Wb4_ss))*q2 + ((1/(A*h_ss))*(Wb3-Wb4_ss))*q3_ss;
y(3) = Wa4_ss + 10^(pH-14) - 10^(-pH) + Wb4_ss*((1+2*10^(pH-pK2))/(1+(10^(pK1-pH))+(10^(pH-pK2))));
y(4) = (1/A)*(q1+q2+q3_ss-Cv*((h_ss+z)^n));
end
