function write_grl_fig2_cf(F2, ncfile)
% write_grl_fig2_cf  CF-compliant NetCDF writer for GRL Figure 2 data.
% - Uses one vertical coordinate 'depth' (positive down) for BOTH hovmöllers and sections.
% - Accepts flexible input orientations and converts to:
%       time-depth vars:     [time x depth]
%       section 3-D vars:    [time x depth x section]
% - Adds useful CF metadata.
%
% Minimal required fields in F2:
%   time (datetime or datenum), depth (m; +/- sign ok), lon_yuc4, lat_yuc4, sal_index
%
% Optional YUC4 time–depth variables (2-D): v_yuc4, u_yuc4, ro_yuc4, dTdz_yuc4
% Optional section axis (1-D): longitude (nx), latitude (nx)
% Optional section fields (3-D): Vgrd, Tgrd, dTdz  (each size accepted; auto-permuted)

% ---------- checks
req = {'time','depth','lon_yuc4','lat_yuc4','sal_index'};
for k = 1:numel(req)
    assert(isfield(F2,req{k}), 'Missing required field F2.%s', req{k});
end
if exist(ncfile,'file'); delete(ncfile); end

% ---------- time handling (CF units)
epoch = datetime(1970,1,1,0,0,0,'TimeZone','UTC');
if isdatetime(F2.time)
    tUTC = F2.time; if isempty(tUTC.TimeZone), tUTC.TimeZone='UTC'; end
elseif isnumeric(F2.time)
    tUTC = datetime(F2.time,'ConvertFrom','datenum','TimeZone','UTC');
else
    error('F2.time must be datetime or datenum numeric');
end
time_sec = seconds(tUTC - epoch);
nt = numel(time_sec);

% ---------- depth (make positive down)
depth_raw = F2.depth(:);
if all(depth_raw <= 0), depth_cf = abs(depth_raw); else, depth_cf = depth_raw; end
nz = numel(depth_cf);

% ---------- write dimensions & coordinates
nccreate(ncfile,'time','Dimensions',{'time',nt},'Format','netcdf4');
ncwrite(ncfile,'time',time_sec(:));
ncwriteatt(ncfile,'time','standard_name','time');
ncwriteatt(ncfile,'time','units','seconds since 1970-01-01 00:00:00 UTC');
ncwriteatt(ncfile,'time','calendar','gregorian');

nccreate(ncfile,'depth','Dimensions',{'depth',nz});
ncwrite(ncfile,'depth',depth_cf(:));
ncwriteatt(ncfile,'depth','standard_name','depth');
ncwriteatt(ncfile,'depth','units','m');
ncwriteatt(ncfile,'depth','positive','down');
ncwriteatt(ncfile,'depth','axis','Z');

% station coords
nccreate(ncfile,'lon_yuc4','Dimensions',{'scalar',1});
nccreate(ncfile,'lat_yuc4','Dimensions',{'scalar',1});
ncwrite(ncfile,'lon_yuc4',F2.lon_yuc4);
ncwrite(ncfile,'lat_yuc4',F2.lat_yuc4);
ncwriteatt(ncfile,'lon_yuc4','standard_name','longitude');
ncwriteatt(ncfile,'lon_yuc4','units','degrees_east');
ncwriteatt(ncfile,'lat_yuc4','standard_name','latitude');
ncwriteatt(ncfile,'lat_yuc4','units','degrees_north');

% optional section axis
has_section = isfield(F2,'longitude') && ~isempty(F2.longitude);
if has_section
    nx = numel(F2.longitude);
    nccreate(ncfile,'section','Dimensions',{'section',nx}); % dimension only
    % section lon/lat
    nccreate(ncfile,'section_longitude','Dimensions',{'section',nx},'DeflateLevel',4,'Shuffle',true);
    nccreate(ncfile,'section_latitude' ,'Dimensions',{'section',nx},'DeflateLevel',4,'Shuffle',true);
    ncwrite(ncfile,'section_longitude',F2.longitude(:));
    ncwrite(ncfile,'section_latitude' ,F2.latitude(:));
    ncwriteatt(ncfile,'section_longitude','standard_name','longitude');
    ncwriteatt(ncfile,'section_longitude','units','degrees_east');
    ncwriteatt(ncfile,'section_latitude' ,'standard_name','latitude');
    ncwriteatt(ncfile,'section_latitude' ,'units','degrees_north');
end

% ---------- 1-D time series: salinity index
nccreate(ncfile,'sal_index','Dimensions',{'time',nt},'DeflateLevel',4,'Shuffle',true);
ncwrite(ncfile,'sal_index',F2.sal_index(:));
ncwriteatt(ncfile,'sal_index','standard_name','sea_water_absolute_salinity');
ncwriteatt(ncfile,'sal_index','long_name','Salinity index at \sigma_\theta \approx 25.35 \pm 0.3 kg m-3');
ncwriteatt(ncfile,'sal_index','units','g kg-1');
ncwriteatt(ncfile,'sal_index','coordinates','lon_yuc4 lat_yuc4');

% ---------- YUC4 time–depth variables (CF dims: time x depth)
write_td(ncfile,'v_yuc4',F2,'northward_sea_water_velocity','m s-1','Meridional velocity at YUC4',nt,nz);
write_td(ncfile,'u_yuc4',F2,'eastward_sea_water_velocity' ,'m s-1','Zonal velocity at YUC4',nt,nz);
write_td(ncfile,'ro_yuc4',F2,'sea_water_vorticity'        ,'s-1'  ,'Relative vorticity at YUC4',nt,nz);
write_td(ncfile,'dTdz_yuc4',F2,''                         ,'degree_Celsius m-1','Vertical temperature gradient at YUC4',nt,nz);

% ---------- Section 3-D variables (CF dims: time x depth x section)
if has_section
    write_sec3d(ncfile,'Vgrd',F2,'northward_sea_water_velocity','m s-1','Meridional velocity section',nt,nz,nx);
    % If your Tgrd is Conservative Temperature, swap the standard_name below:
    %  'sea_water_conservative_temperature'
    write_sec3d(ncfile,'Tgrd',F2,'sea_water_temperature','degree_Celsius','Temperature section',nt,nz,nx);
    % Optional: section dT/dz if present in F2.dTdz (same shape as Vgrd/Tgrd)
    if isfield(F2,'dTdz') && ~isempty(F2.dTdz)
        write_sec3d(ncfile,'dTdz',F2,'','degree_Celsius m-1','Vertical temperature gradient section',nt,nz,nx);
    end
end

% ---------- global attributes
ncwriteatt(ncfile,'/','title','Yucatan Channel – Figure 2 data package');
ncwriteatt(ncfile,'/','summary',['Data for GRL Fig. 2: YUC4 time–depth fields (u, v, vorticity, dT/dz), ', ...
    'salinity index time series, and gridded section variables (Vgrd, Tgrd) using the same depth axis.']);
ncwriteatt(ncfile,'/','Conventions','CF-1.10');
ncwriteatt(ncfile,'/','institution','CICESE; LEGOS; COAPS; Univ. of Iceland');
ncwriteatt(ncfile,'/','source','Canek moorings processed products; objective mapping');
ncwriteatt(ncfile,'/','history',[datestr(now,'yyyy-mm-dd HH:MM:SS'),' : created by write_grl_fig2_cf.m']);
ncwriteatt(ncfile,'/','license','CC-BY 4.0 for processed products; raw data restricted per project policies');
ncwriteatt(ncfile,'/','project','Frontogenetic origin of GCW-type waters in the Yucatan Channel');
ncwriteatt(ncfile,'/','references','CANEK L4 dataset (Zenodo: 10.5281/zenodo.7865542); GRL submission');
ncwriteatt(ncfile,'/','geospatial_lon_min',F2.lon_yuc4);
ncwriteatt(ncfile,'/','geospatial_lon_max',F2.lon_yuc4);
ncwriteatt(ncfile,'/','geospatial_lat_min',F2.lat_yuc4);
ncwriteatt(ncfile,'/','geospatial_lat_max',F2.lat_yuc4);
ncwriteatt(ncfile,'/','time_coverage_start',datestr(min(tUTC),'yyyy-mm-ddTHH:MM:SSZ'));
ncwriteatt(ncfile,'/','time_coverage_end'  ,datestr(max(tUTC),'yyyy-mm-ddTHH:MM:SSZ'));

fprintf('Wrote %s (CF-1.10; sections share "depth" with hovmöllers)\n', ncfile);

% =================== nested helpers ===================

    function write_td(nc,varname,S,standard_name,units,long_name,NT,NZ)
        if ~isfield(S,varname) || isempty(S.(varname)), return; end
        A = double(S.(varname));
        A = orient_td(A,NT,NZ);      % -> [time x depth]
        nccreate(nc,varname,'Dimensions',{'time',NT,'depth',NZ},'DeflateLevel',4,'Shuffle',true);
        ncwrite(nc,varname,A);
        if ~isempty(standard_name), ncwriteatt(nc,varname,'standard_name',standard_name); end
        ncwriteatt(nc,varname,'long_name',long_name);
        ncwriteatt(nc,varname,'units',units);
        ncwriteatt(nc,varname,'coordinates','lon_yuc4 lat_yuc4');
    end

    function write_sec3d(nc,varname,S,standard_name,units,long_name,NT,NZ,NX)
        if ~isfield(S,varname) || isempty(S.(varname)), return; end
        A = double(S.(varname));
        A = orient_tdz(A,NT,NZ,NX);  % -> [time x depth x section]
        nccreate(nc,varname,'Dimensions',{'time',NT,'depth',NZ,'section',NX},'DeflateLevel',4,'Shuffle',true);
        ncwrite(nc,varname,A);
        if ~isempty(standard_name), ncwriteatt(nc,varname,'standard_name',standard_name); end
        ncwriteatt(nc,varname,'long_name',long_name);
        ncwriteatt(nc,varname,'units',units);
        ncwriteatt(nc,varname,'coordinates','section_longitude section_latitude');
    end

    function B = orient_td(A,NT,NZ)
        % Accept [NZ x NT] or [NT x NZ]; return [NT x NZ]
        sz = size(A);
        assert(ndims(A)==2,'time–depth variable must be 2-D');
        if     isequal(sz,[NT NZ]), B = A;
        elseif isequal(sz,[NZ NT]), B = A.';    % transpose
        else
            % lenient: figure out by matching dims
            [~,perm] = ismatch(sz,[NT NZ]);
            assert(~isempty(perm),'Unexpected size for time–depth variable');
            B = permute(A,perm);  % to [NT x NZ]
        end
    end

    function B = orient_tdz(A,NT,NZ,NX)
        % Accept any permutation of [NT NZ NX]; return [NT x NZ x NX]
        assert(ndims(A)==3,'section variable must be 3-D');
        sz = size(A);
        % pad to 3
        if numel(sz)<3, sz(3)=1; end
        % build candidate mapping by comparing sizes
        dims_in  = sz;
        dims_ref = [NT NZ NX];
        perm = zeros(1,3);
        used = false(1,3);
        for i = 1:3
            idx = find(dims_in(i)==dims_ref & ~used,1,'first');
            if ~isempty(idx)
                perm(i) = idx; used(idx)=true;
            else
                perm = 0; break
            end
        end
        if any(perm==0)
            % try common raw: [NZ x NX x NT]
            if isequal(sz,[NZ NX NT]), B = permute(A,[3 1 2]); return; end
            % or [NX x NZ x NT]
            if isequal(sz,[NX NZ NT]), B = permute(A,[3 2 1]); return; end
            error('F2 section var has unexpected size; need combos of [nt nz nx]');
        end
        % permute from current order to [NT NZ NX]
        invperm = zeros(1,3);
        invperm(perm) = 1:3;
        B = permute(A,invperm);
    end

    function [found,perm] = ismatch(sz,ref)
        % tiny helper: match 2-D sizes ignoring order
        found = false; perm = [];
        if numel(sz)~=2, return; end
        if isequal(sz,ref), found=true; perm=[1 2]; return; end
        if isequal(sz,[ref(2) ref(1)]), found=true; perm=[2 1]; return; end
    end
end
