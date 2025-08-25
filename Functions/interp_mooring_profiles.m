function [Umat, Vmat, Wmat, tvec] = interp_mooring_profiles(anchor, Zn, gap_max, method)
% INTERP_MOORING_PROFILES
% Build U,V,W time–depth matrices on a common vertical grid (Zn) from one
% mooring deployment ("anchor" struct array as saved in your CNK files).
%
% INPUT
%   anchor : struct array with fields (one per instrument)
%            .time [Nt x 1], .z [Nt x Nz_i], .u .v .w [Nt x Nz_i], .znom (depth)
%   Zn     : target depth grid (column vector, NEGATIVE down, e.g., -20:-8:-2100)
%   gap_max: max allowed vertical distance (m) from a target level to the nearest
%            observed level at that time; larger gaps are masked as NaN (e.g., 250)
%   method : 'makima' (default), 'pchip', 'linear' — vertical interpolation scheme
%
% OUTPUT
%   Umat, Vmat, Wmat : [numel(Zn) x Nt] matrices
%   tvec             : [1 x Nt] datenum vector (copy of anchor(1).time)
%
% NOTES
%  - No temporal interpolation is done here; each column uses the raw time slice.
%  - We average duplicate depths, remove empty/NaN rows, and mask extrapolations
%    (outside observed min/max) and large vertical gaps (>gap_max).
%
% Giovanni Durante — vertical interpolation, 2025-08
warning off
    if nargin < 4 || isempty(method),  method = 'makima'; end

    tvec = anchor(1).time(:)';                 % use the first instrument's time stamps
    Nt   = numel(tvec);
    Nz   = numel(Zn);

    Umat = nan(Nz, Nt);
    Vmat = nan(Nz, Nt);
    Wmat = nan(Nz, Nt);

    for it = 1:Nt
        % --- gather all valid (z,u,v,w) across instruments at this time
        z_all = []; u_all = []; v_all = []; w_all = [];

        for ii = 1:numel(anchor)
            % pull row "it" for instrument ii
            z = anchor(ii).z(it, :).';    % depth array (negative down expected)
            u = anchor(ii).u(it, :).';
            v = anchor(ii).v(it, :).';
            w = anchor(ii).w(it, :).';

            % OPTIONAL: drop the bin closest to the surface if it's a known bad bin
            % (keeps behavior close to your original "if i==1, z==min(abs(z)) -> NaN")
            if ii == 1 && ~all(isnan(z))
                [~, iz0] = min(abs(z));   % closest to zero depth
                z(iz0) = NaN; u(iz0) = NaN; v(iz0) = NaN; w(iz0) = NaN;
            end

            good = isfinite(z + u + v);   % keep rows with z,u,v (w may be NaN)
            z_all = [z_all; z(good)];
            u_all = [u_all; u(good)];
            v_all = [v_all; v(good)];
            w_all = [w_all; w(good)];
        end

        if isempty(z_all)
            % nothing valid at this time
            continue
        end

        % --- make depth positive for sorting/interp convenience
        Zobs = abs(z_all(:));    % meters positive downward
        Uobs = u_all(:);
        Vobs = v_all(:);
        Wobs = w_all(:);

        % --- average duplicates at identical depths
        [Zu, ~, idx] = unique(Zobs, 'rows');      % unique depth levels
        Uu = accumarray(idx, Uobs, [], @mean);
        Vu = accumarray(idx, Vobs, [], @mean);
        Wu = accumarray(idx, Wobs, [], @mean);

        % require at least 4 unique levels to interpolate smoothly
        if numel(Zu) < 4
            continue
        end

        % sort by depth increasing
        [Zu, ord] = sort(Zu, 'ascend');
        Uu = Uu(ord);  Vu = Vu(ord);  Wu = Wu(ord);

        % --- interpolate to target levels (positive depth for interp)
        Zt = abs(Zn);                 % target depths, positive
        Ui = interp1(Zu, Uu, Zt, method, 'extrap');
        Vi = interp1(Zu, Vu, Zt, method, 'extrap');
        Wi = interp1(Zu, Wu, Zt, method, 'extrap');

        % --- mask extrapolated regions (outside data range) and big gaps
        out_range = (Zt < min(Zu)) | (Zt > max(Zu));
        % nearest observed level distance at each target level:
        dmin = arrayfun(@(zz) min(abs(zz - Zu)), Zt);
        big_gap = dmin > gap_max;

        bad = out_range | big_gap;
        Ui(bad) = NaN; Vi(bad) = NaN; Wi(bad) = NaN;

        % --- store the column
        Umat(:, it) = Ui;
        Vmat(:, it) = Vi;
        Wmat(:, it) = Wi;
    end
end
