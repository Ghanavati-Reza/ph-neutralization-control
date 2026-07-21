%RUN_DEMO Reproduce the results in this project's README.
%   Solves the steady state, tunes the PI controller (fminunc and GA),
%   tunes the feedforward gain, and runs the robustness tests.

addpath(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'models'));

fprintf('=== Steady state (pH = 7) ===\n');
StStsolver();

fprintf('\n=== PI tuning, fminunc, closeloop_PI ===\n');
for perfIndex = {'ISE','ITSE'}
    [k1,k2] = tunePI(perfIndex{1});
    fprintf('%-6s k1=%.4f k2=%.4f\n', perfIndex{1}, k1, k2);
end

fprintf('\n=== Feedforward gain, fminunc, closeloop_PI_FF ===\n');
k1_ff = tuneFeedforwardGain('ISE');
fprintf('ISE k1=%.4f\n', k1_ff);

fprintf('\n=== Robustness test: q1 disturbance, ISE-tuned PI ===\n');
[k1,k2] = tunePI('ISE');
out = simulateClosedLoop('closeloop_PI_q1_change', k1, k2);
fprintf('ISE=%.4f ITSE=%.4f IAE=%.4f\n', out.ISE, out.ITSE, out.IAE);

fprintf('\n=== GA-based PI tuning, closeloop_PI_Ga (several minutes) ===\n');
[k1,k2] = tunePIGA();
fprintf('k1=%.4f k2=%.4f\n', k1, k2);
