function [test_results] = validate_sim_results(sim, coursename)
    % --- Define L4 Urban ODD Thresholds ---
    thresholds.max_xterr = 0.25;       % meters
    thresholds.max_verr  = 0.50;       % m/s
    thresholds.max_jerk  = 2.50;       % m/s^3 (Comfort limit)
    thresholds.max_alat  = 3.00;       % m/s^2 (Stability limit)
    thresholds.tta_limit = 0.10;       % 100ms Time-to-Alert for Jamming

    % --- 1. Basic Motion Calculations ---
    v_error = abs(sim.vdes - sim.vcar);
    max_xt_err = max(abs(sim.xterr));
    max_v_err  = max(v_error);
    max_j_long = max(abs(sim.jlat));
    max_a_lat  = max(abs(sim.alat));

    % --- 2. Advanced Scenario Logic ---
    % Lane Change Detection (High Lateral Velocity or Curvature Change)
    is_lane_change = max(abs(diff(sim.psi))) > 0.05; % Simplified heuristic
    
    % GPS Jamming Detection (Identify when VC_state exits 'Run Hot' unexpectedly)
    % Assuming fault is injected when wpt_status_change is toggled or simulated
    jamming_status = 'N/A';
    if any(sim.wpt_status_change == 1)
        fault_idx = find(sim.wpt_status_change == 1, 1);
        reaction_idx = find(sim.VC_state(fault_idx:end) ~= 4, 1) + fault_idx - 1;
        
        if ~isempty(reaction_idx)
            reaction_time = sim.t(reaction_idx) - sim.t(fault_idx);
            jamming_pass = reaction_time <= thresholds.tta_limit;
            jamming_status = sprintf('%.3fs', reaction_time);
        else
            jamming_pass = false;
            jamming_status = 'NO REACTION';
        end
    else
        jamming_pass = true; % Test not triggered
    end

    % --- 3. Evaluate Pass/Fail Matrix ---
    results = {
        'Cross Track Error', max_xt_err, thresholds.max_xterr, max_xt_err <= thresholds.max_xterr;
        'Velocity Tracking', max_v_err,  thresholds.max_verr,  max_v_err <= thresholds.max_verr;
        'Longitudinal Jerk', max_j_long, thresholds.max_jerk,  max_j_long <= thresholds.max_jerk;
        'Lateral Accel',     max_a_lat,  thresholds.max_alat,  max_a_lat <= thresholds.max_alat;
    };

    % Append Scenario Specifics
    if is_lane_change
        results(end+1,:) = {'Lane Change Stability', max_a_lat, thresholds.max_alat, max_a_lat <= thresholds.max_alat};
    end
    if strcmp(jamming_status, 'N/A') == 0
        results(end+1,:) = {'Jamming TTA', reaction_time, thresholds.tta_limit, jamming_pass};
    end

    % --- 4. Display Report ---
    fprintf('\n--- VALIDATION REPORT: %s ---\n', coursename);
    fprintf('%-25s | %-10s | %-10s | %-8s\n', 'Metric', 'Value', 'Limit', 'Status');
    fprintf('%s\n', repmat('-', 1, 65));
    
    for i = 1:size(results, 1)
        status = 'FAIL';
        if results{i, 4}, status = 'PASS'; end
        fprintf('%-25s | %-10.3f | %-10.3f | %-8s\n', ...
            results{i, 1}, results{i, 2}, results{i, 3}, status);
    end

    % --- 5. Final Verdict ---
    if all([results{:, 4}])
        fprintf('\nVERDICT: [SAFE] System meets L4 Requirements.\n');
    else
        fprintf('\nVERDICT: [UNSAFE] Failure detected in safety gate.\n');
    end
    
    test_results = results;
end