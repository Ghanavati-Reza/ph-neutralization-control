function [sys,x0,str,ts,simStateCompliance] = plant_simu(t,x,u,flag)
%PLANT_SIMU Nonlinear pH-neutralization process S-function.
%   States:  x(1)=Wa4, x(2)=Wb4 (ionic balances), x(3)=h (tank level)
%   Inputs:  u(1)=q1 (acid stream), u(2)=q2 (buffer stream), u(3)=q3 (base stream)
%   Outputs: sys(1)=pH (solved via Newton-Raphson), sys(2)=h, sys(3)=q4 (effluent flow)
%
%   Flow inputs are scaled by 60 internally to set the model's dynamic
%   timescale. This does not affect the steady state (a constant factor
%   on every derivative does not move the equilibrium), only how fast
%   the model approaches it.
switch flag
    case 0
        [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;
    case 1
        sys=mdlDerivatives(t,x,u);
    case 2
        sys=[];
    case 3
        sys=mdlOutputs(t,x,u);
    case 4
        sys=[];
    case 9
        sys=[];
end
end

function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 3;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 3;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = [-4.32e-4, 5.28e-4, 14];
str = [];
ts  = [0 0];
simStateCompliance = 'UnknownSimState';
end

function sys=mdlDerivatives(t,x,u)
A  = 207;
z  = 11.5;
n  = 0.607;
Cv = 4.58*60;
wa1 = 0.003;  wa2 = -0.03;   wa3 = -3.05e-3;
wb1 = 0;      wb2 = 0.03;    wb3 = 5e-5;

wa4 = x(1); wb4 = x(2); h = x(3);
q1 = u(1)*60; q2 = u(2)*60; q3 = u(3)*60;

dwa4 = (1/(A*h))*((wa1-wa4)*q1+(wa2-wa4)*q2+(wa3-wa4)*q3);
dwb4 = (1/(A*h))*((wb1-wb4)*q1+(wb2-wb4)*q2+(wb3-wb4)*q3);
dh   = (1/A)*(q1+q2+q3-(Cv*((h+z)^n)));

sys(1)=dwa4;
sys(2)=dwb4;
sys(3)=dh;
end

function sys=mdlOutputs(t,x,u)
z  = 11.5;
n  = 0.607;
Cv = 4.58*60;
wa4 = x(1); wb4 = x(2); h = x(3);
pH = solvePH(wa4, wb4);
sys(1)=pH;
sys(2)=h;
sys(3)=Cv*((h+z)^n);
end

function pH = solvePH(wa4, wb4)
%SOLVEPH Newton-Raphson solve of the ionic charge balance for pH.
pH = 7;
pK1 = -log10(4.47e-7);
pK2 = -log10(5.62e-11);
EPS = 1e-10;

f = @(pH) wa4 + 10^(pH-14) - 10^(-pH) + wb4*((1+2*10^(pH-pK2))/(1+10^(pK1-pH)+10^(pH-pK2)));
dfdpH = @(pH) log(10)*(10^(pH-14)+10^(-pH)+wb4*((2*10^(pH-pK2)*(1+10^(pK1-pH)+10^(pH-pK2))-(10^(pH-pK2)-10^(pK1-pH))*(1+2*10^(pH-pK2)))/(1+10^(pK1-pH)+10^(pH-pK2))^2));

pHj = pH - f(pH)/dfdpH(pH);
while abs(pHj-pH) > EPS
    pH = pHj;
    pHj = pH - f(pH)/dfdpH(pH);
end
pH = pHj;
end
