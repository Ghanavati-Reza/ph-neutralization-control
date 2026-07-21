function [k1, k2] = tunePIGA()
%TUNEPIGA Tune the pH-loop PI controller (closeloop_PI_Ga) with a genetic
%   algorithm, minimizing the model's internally-integrated ISE signal.
%   Used as a fallback for the ISE/IAE performance indices, which did not
%   reliably converge under fminunc (see tunePI.m).
%
%   Bounds of [0, 30] are enforced on both gains: an unbounded search
%   reliably samples candidates that drive the tank level negative and
%   crash the pH solve (Newton-Raphson on a complex/undefined argument).

lb = [0 0];
ub = [30 30];
result = ga(@gaFitness, 2, [],[],[],[], lb, ub);
k1 = result(1);
k2 = result(2);
end

function err = gaFitness(k)
assignin('base','k1',k(1));
assignin('base','k2',k(2));
try
    sim('closeloop_PI_Ga');
    err = ISE(end); %#ok<NODEF> % logged by the model's "To Workspace" block
catch
    % This gain combination drove the tank level negative (or otherwise
    % destabilized the loop), which the pH Newton-Raphson solve cannot
    % handle. Penalize instead of aborting the whole GA run.
    err = 1e6;
end
end
