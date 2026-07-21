function [k1, k2] = tunePI(perfIndex, x0)
%TUNEPI Tune the pH-loop PI controller (closeloop_PI) via fminunc.
%   [k1, k2] = TUNEPI(perfIndex, x0)
%
%   perfIndex - 'ISE', 'ITSE', or 'IAE'
%   x0        - optional initial guess [k1 k2] (default: designer's
%               nominal point, k1=2.4 ml/s, k2=4 min)

if nargin < 2
    x0 = [2.4 4];
end

switch perfIndex
    case 'ISE'
        costFcn = @(x) simCost(x, 'ISE');
    case 'ITSE'
        costFcn = @(x) simCost(x, 'ITSE');
    case 'IAE'
        costFcn = @(x) simCost(x, 'IAE');
    otherwise
        error('tunePI:perfIndex', 'perfIndex must be ''ISE'', ''ITSE'', or ''IAE''.');
end

result = fminunc(costFcn, x0);
k1 = result(1);
k2 = result(2);
end

function res = simCost(x, perfIndex)
k1 = x(1); %#ok<NASGU>
k2 = x(2); %#ok<NASGU>
options = simset('SrcWorkspace','current');
sim('closeloop_PI',[],options);
switch perfIndex
    case 'ISE'
        e2 = Out1.^2;
        res = trapz(tout, e2);
    case 'ITSE'
        e2 = Out1.^2 .* tout;
        res = trapz(tout, e2);
    case 'IAE'
        e2 = abs(Out1);
        res = trapz(tout, e2);
end
end
