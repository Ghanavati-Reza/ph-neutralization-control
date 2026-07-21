function out = simulateClosedLoop(model, k1, k2)
%SIMULATECLOSEDLOOP Run a closed-loop pH model with given PI gains.
%   out = SIMULATECLOSEDLOOP(model, k1, k2)
%
%   model - one of 'closeloop_PI', 'closeloop_PI_q1_change',
%           'closeloop_PI_q2_change' (robustness tests: q1 or q2
%           disturbed instead of held at nominal)
%
%   Returns a struct with time series pulled from the model's logged
%   "To Workspace" signals (h and pH), plus the ISE/ITSE/IAE of the
%   control error.

options = simset('SrcWorkspace','current');
sim(model,[],options);

out.t = tout;
out.Out1 = Out1;
out.ISE = trapz(tout, Out1.^2);
out.ITSE = trapz(tout, Out1.^2 .* tout);
out.IAE = trapz(tout, abs(Out1));
end
