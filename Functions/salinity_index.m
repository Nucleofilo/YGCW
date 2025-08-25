function [SI, t_daily, diag] = salinity_index(SP, T, P, lon, lat, time_dnum, sigma0_center, sigma0_halfwin, method)
% SALINITY_INDEX  Daily salinity index on a target sigma0 band.
%
%   [SI, t_daily, diag] = salinity_index(SP,T,P,lon,lat,time_dnum, ...
%                                        sigma0_center, sigma0_halfwin, method)
%
% INPUTS
%   SP          Practical Salinity (PSU)    [N x M or vector]
%   T           In-situ temperature (°C)    [same size]
%   P           Pressure (dbar)             [same size]
%   lon, lat    Longitude, Latitude         [scalar or same size]
%   time_dnum   MATLAB datenum              [same size or vector]
%   sigma0_center   (optional) default 25.35
%   sigma0_halfwin  (optional) default 0.30   % band is center ± halfwin
%   method          (optional) 'mean' (default) or 'minmax_mean'
%
% OUTPUTS
%   SI        [K x 1] daily salinity index (Absolute Salinity, g/kg)
%   t_daily   [K x 1] datenum (day stamps, floor())
%   diag      struct with fields:
%               .n_in_band
%               .SAmin, .SAmax, .T_at_min, .T_at_max, .P_at_min, .P_at_max
%
% NOTES
%   - 'mean'      : average SA over the sigma0 band (matches manuscript).
%   - 'minmax_mean': mean of min & max SA in the band (legacy style).
%
% DEPENDS ON: GSW toolbox (gsw_*).
%
% Giovanni Durante / cleaned simple version

    if nargin < 7, error('Need SP, T, P, lon, lat, time_dnum.'); end
    if nargin < 8 || isempty(sigma0_center),  sigma0_center  = 25.35; end
    if nargin < 9 || isempty(sigma0_halfwin), sigma0_halfwin = 0.30;  end
    if nargin < 10 || isempty(method),        method = 'mean';        end

    % --- reshape inputs to column vectors
    SP   = SP(:);   T = T(:);   P = P(:);
    if isscalar(lon), lon = repmat(lon, size(SP)); else, lon = lon(:); end
    if isscalar(lat), lat = repmat(lat, size(SP)); else, lat = lat(:); end
    time = time_dnum(:);

    % --- TEOS-10 conversions
    SA = gsw_SA_from_SP(SP, P, lon, lat);         % g/kg
    CT = gsw_CT_from_t(SA, T, P);                 % deg C
    SG = gsw_sigma0(SA, CT);                      % kg/m^3 - 1000

    % --- group by day (floor safer than round)
    days = floor(time);
    uDays = unique(days);
    K = numel(uDays);

    % --- outputs
    SI      = nan(K,1);
    n_in    = zeros(K,1);
    SAmin   = nan(K,1); SAmax = nan(K,1);
    T_atMin = nan(K,1); T_atMax = nan(K,1);
    P_atMin = nan(K,1); P_atMax = nan(K,1);

    lo = sigma0_center - sigma0_halfwin;
    hi = sigma0_center + sigma0_halfwin;

    for k = 1:K
        idx  = (days == uDays(k));
        SAk  = SA(idx);
        CTk  = CT(idx);
        SGk  = SG(idx);
        Pk   = P(idx);

        inb = SGk >= lo & SGk <= hi & isfinite(SAk) & isfinite(CTk);
        n_in(k) = sum(inb);

        if n_in(k) == 0
            SI(k) = NaN;
            continue
        end

        switch lower(method)
            case 'mean'
                SI(k) = mean(SAk(inb), 'omitnan');

            case 'minmax_mean'
                [SAmin(k), iMin] = min(SAk(inb));
                [SAmax(k), iMax] = max(SAk(inb));
                ind = find(inb);
                T_atMin(k) = CTk(ind(iMin));  T_atMax(k) = CTk(ind(iMax));
                P_atMin(k) = Pk(ind(iMin));   P_atMax(k) = Pk(ind(iMax));
                SI(k) = mean([SAmin(k), SAmax(k)], 'omitnan');

            otherwise
                error('Unknown method: %s (use ''mean'' or ''minmax_mean'')', method);
        end
    end

    t_daily = uDays(:);

    % diagnostics struct
    diag = struct('n_in_band', n_in, ...
                  'SAmin', SAmin, 'SAmax', SAmax, ...
                  'T_at_min', T_atMin, 'T_at_max', T_atMax, ...
                  'P_at_min', P_atMin, 'P_at_max', P_atMax, ...
                  'sigma0_center', sigma0_center, ...
                  'sigma0_halfwin', sigma0_halfwin, ...
                  'method', method);
end
