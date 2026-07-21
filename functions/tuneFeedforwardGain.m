function k1 = tuneFeedforwardGain(perfIndex, x0)
%TUNEFEEDFORWARDGAIN Tune the static feedforward gain (closeloop_PI_FF).
%   k1 = TUNEFEEDFORWARDGAIN(perfIndex, x0)
%
%   perfIndex - 'ISE', 'ITSE', or 'IAE'
%   x0        - optional initial guess for the FF gain (default: -4)

if nargin < 2
    x0 = -4;
end

switch perfIndex
    case 'ISE'
        costFcn = @(x) simCost(x, 'ISE');
    case 'ITSE'
        costFcn = @(x) simCost(x, 'ITSE');
    case 'IAE'
        costFcn = @(x) simCost(x, 'IAE');
    otherwise
        error('tuneFeedforwardGain:perfIndex', 'perfIndex must be ''ISE'', ''ITSE'', or ''IAE''.');
end

k1 = fminunc(costFcn, x0);
end

function res = simCost(x, perfIndex)
k1 = x; %#ok<NASGU>
options = simset('SrcWorkspace','current');
sim('closeloop_PI_FF',[],options);
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
