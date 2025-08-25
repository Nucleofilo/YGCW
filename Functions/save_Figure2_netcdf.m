function save_Figure2_netcdf(F2, ncfile)
% save_Figure2_netcdf  Write CF-compliant NetCDF for Figure 2 data.
%
% Usage:
%   save_Figure2_netcdf(F2, 'YGCW_Figure2_data.nc')
%
% Notes:
% - Skips variables that are not present in F2.
% - Uses CF standard_names and units where applicable.
% - time stored as seconds since 1970-01-01 00:00:00 UTC, calendar=gregorian.
%
% Required minimal fields:
%   F2.time (datetime), F2.depth (m, positive), F2.lon_yuc4, F2.lat_yuc4

% ---------- helpers
has = @(f) isfield(F2,f) && ~isempty(F2.(f));
epoch = datetime(1970,1,1,0,0,0,'TimeZone','UTC');
assert(has('time') && isdatetime(F2.time), 'F2.time must be a datetime vector');
assert(has('depth'), 'F2.depth (m) is required');
if ~has('lon_yuc4') || ~has('lat_yuc4')
    warning('lon_yuc4/lat_yuc4 not provided; writing NaN');
    F2.lon_yuc4 = NaN; F2.lat_yuc4 = NaN;
end

% make/overwrite file
if exist(ncfile,'file'); delete(ncfile); end

% ---------- dimensions
nt  = numel(F2.time);
nz  = numel(F2.depth);
nccreate(ncfile,'time','Dimensions',{'time',nt},'Format','netcdf4');
nccreate(ncfile,'depth','Dimensions',{'depth',nz});

% optional profile & section dims
if has('depth_prof'); nccreate(ncfile,'depth_prof','Dimensions',{'depth_prof',numel(F2.depth_prof)}); end
if has('x_section');   nccreate(ncfile,'x_section','Dimensions',{'x_section',numel(F2.x_section)}); end
if has('z_section');   nccreate(ncfile,'z_section','Dimensions',{'z_section',numel(F2.z_section)}); end

% ---------- coordinate vars & attributes (CF)
% time
time_sec = seconds(F2.time - epoch);
ncwrite(ncfile,'time',time_sec(:));
ncwriteatt(ncfile,'time','standard_name','time');
ncwriteatt(ncfile,'time','long_name','time');
ncwriteatt(ncfile,'time','units','seconds since 1970-01-01 00:00:00 UTC');
ncwriteatt(ncfile,'time','calendar','gregorian');

% depth
ncwrite(ncfile,'depth',F2.depth(:));
ncwriteatt(ncfile,'depth','standard_name','depth');
ncwriteatt(ncfile,'depth','long_name','depth');
ncwriteatt(ncfile,'depth','units','m');
ncwriteatt(ncfile,'depth','positive','down');
ncwriteatt(ncfile,'depth','axis','Z');

% station location (YUC4)
nccreate(ncfile,'lon_yuc4','Dimensions',{'scalar',1});
nccreate(ncfile,'lat_yuc4','Dimensions',{'scalar',1});
ncwrite(ncfile,'lon_yuc4',F2.lon_yuc4);
ncwrite(ncfile,'lat_yuc4',F2.lat_yuc4);
ncwriteatt(ncfile,'lon_yuc4','standard_name','longitude');
ncwriteatt(ncfile,'lon_yuc4','units','degrees_east');
ncwriteatt(ncfile,'lat_yuc4','standard_name','latitude');
ncwriteatt(ncfile,'lat_yuc4','units','degrees_north');

% optional coordinate vectors
if has('depth_prof')
    ncwrite(ncfile,'depth_prof',F2.depth_prof(:));
    ncwriteatt(ncfile,'depth_prof','standard_name','depth');
    ncwriteatt(ncfile,'depth_prof','units','m'); ncwriteatt(ncfile,'depth_prof','positive','down');
end
if has('x_section')
    ncwrite(ncfile,'x_section',F2.x_section(:));
    ncwriteatt(ncfile,'x_section','long_name','along-section coordinate');
    % set appropriate units:
    units = 'km';
    if max(abs(F2.x_section))<=360, units='degrees_east'; end
    ncwriteatt(ncfile,'x_section','units',units);
end
if has('z_section')
    ncwrite(ncfile,'z_section',F2.z_section(:));
    ncwriteatt(ncfile,'z_section','standard_name','depth');
    ncwriteatt(ncfile,'z_section','units','m'); ncwriteatt(ncfile,'z_section','positive','down');
end
if has('lon_section')
    nccreate(ncfile,'lon_section','Dimensions',{'x_section',numel(F2.lon_section)});
    ncwrite(ncfile,'lon_section',F2.lon_section(:));
    ncwriteatt(ncfile,'lon_section','standard_name','longitude');
    ncwriteatt(ncfile,'lon_section','units','degrees_east');
end
if has('lat_section')
    nccreate(ncfile,'lat_section','Dimensions',{'x_section',numel(F2.lat_section)});
    ncwrite(ncfile,'lat_section',F2.lat_section(:));
    ncwriteatt(ncfile,'lat_section','standard_name','latitude');
    ncwriteatt(ncfile,'lat_section','units','degrees_north');
end

% ---------- time–depth variables at YUC4 (nt x nz)
write_td(ncfile,'v_yuc4','northward_sea_water_velocity','m s-1','Meridional velocity at YUC4',{'time','depth'});
write_td(ncfile,'u_yuc4','eastward_sea_water_velocity','m s-1','Zonal velocity at YUC4',{'time','depth'});
write_td(ncfile,'ro_yuc4','sea_water_vorticity','s-1','Relative vorticity at YUC4',{'time','depth'});
write_td(ncfile,'dTdz_yuc4','','degC m-1','Vertical temperature gradient at YUC4',{'time','depth'});

% ---------- index time series
if has('sal_index')
    nccreate(ncfile,'sal_index','Dimensions',{'time',nt});
    ncwrite(ncfile,'sal_index',F2.sal_index(:));
    ncwriteatt(ncfile,'sal_index','standard_name','sea_water_absolute_salinity');
    ncwriteatt(ncfile,'sal_index','long_name','Salinity index at sigma_theta ≈ 25.35±0.3');
    ncwriteatt(ncfile,'sal_index','units','g kg-1');
    ncwriteatt(ncfile,'sal_index','cell_methods','mean over potential_density range');
    ncwriteatt(ncfile,'sal_index','coordinates','lon_yuc4 lat_yuc4');
end

% ---------- composite vertical PROFILES (depth_prof)
write_prof(ncfile,'v_prof_ygcw','northward_sea_water_velocity','m s-1','Composite meridional velocity (YGCW)');
write_prof(ncfile,'v_prof_suw' ,'northward_sea_water_velocity','m s-1','Composite meridional velocity (SUW)');
write_prof(ncfile,'v_prof_all' ,'northward_sea_water_velocity','m s-1','Meridional velocity (full record)');

write_prof(ncfile,'u_prof_ygcw','eastward_sea_water_velocity','m s-1','Composite zonal velocity (YGCW)');
write_prof(ncfile,'u_prof_suw' ,'eastward_sea_water_velocity','m s-1','Composite zonal velocity (SUW)');
write_prof(ncfile,'u_prof_all' ,'eastward_sea_water_velocity','m s-1','Zonal velocity (full record)');

write_prof(ncfile,'ro_prof_ygcw','sea_water_vorticity','s-1','Composite relative vorticity (YGCW)');
write_prof(ncfile,'ro_prof_suw' ,'sea_water_vorticity','s-1','Composite relative vorticity (SUW)');
write_prof(ncfile,'ro_prof_all' ,'sea_water_vorticity','s-1','Relative vorticity (full record)');

write_prof(ncfile,'dTdz_prof_ygcw','','degC m-1','Composite vertical temperature gradient (YGCW)');
write_prof(ncfile,'dTdz_prof_suw' ,'','degC m-1','Composite vertical temperature gradient (SUW)');
write_prof(ncfile,'dTdz_prof_all' ,'','degC m-1','Vertical temperature gradient (full record)');

% ---------- along-section COMPOSITES (z_section x x_section)
write_sec(ncfile,'v_sec_ygcw','northward_sea_water_velocity','m s-1','Mapped meridional velocity section (YGCW)');
write_sec(ncfile,'v_sec_suw' ,'northward_sea_water_velocity','m s-1','Mapped meridional velocity section (SUW)');

write_sec(ncfile,'dTdz_sec_ygcw','','degC m-1','Mapped vertical temperature gradient section (YGCW)');
write_sec(ncfile,'dTdz_sec_suw' ,'','degC m-1','Mapped vertical temperature gradient section (SUW)');

write_sec(ncfile,'T_sec_ygcw','sea_water_temperature','degC','Mapped potential/Conservative temperature (YGCW)');
write_sec(ncfile,'T_sec_suw' ,'sea_water_temperature','degC','Mapped potential/Conservative temperature (SUW)');

% ---------- global attributes (edit to taste)
ncwriteatt(ncfile,'/','title','Frontal Dynamics & YGCW – Figure 2 data package');
ncwriteatt(ncfile,'/','summary',['Data underlying Figure 2: YUC4 time–depth sections, ', ...
    'salinity index, composite vertical profiles, and along-section composites (YGCW vs SUW).']);
ncwriteatt(ncfile,'/','Conventions','CF-1.10');
ncwriteatt(ncfile,'/','institution','CICESE, LEGOS, COAPS, University of Iceland');
ncwriteatt(ncfile,'/','source','Canek moorings (YUC4/YUC5), Canek L4 gridded velocities');
ncwriteatt(ncfile,'/','history',[datestr(now,'yyyy-mm-dd HH:MM:SS'),' : created by save_Figure2_netcdf.m']);
ncwriteatt(ncfile,'/','references','Durante et al., GRL (submitted) + CANEK database (Zenodo: 10.5281/zenodo.7865542)');
ncwriteatt(ncfile,'/','license','CC-BY 4.0 for processed products; raw restricted per project policies');
ncwriteatt(ncfile,'/','project','Local formation of GCW-type waters in the Yucatan Channel');
ncwriteatt(ncfile,'/','geospatial_lat_min',F2.lat_yuc4);
ncwriteatt(ncfile,'/','geospatial_lat_max',F2.lat_yuc4);
ncwriteatt(ncfile,'/','geospatial_lon_min',F2.lon_yuc4);
ncwriteatt(ncfile,'/','geospatial_lon_max',F2.lon_yuc4);
ncwriteatt(ncfile,'/','time_coverage_start',datestr(min(F2.time),'yyyy-mm-ddTHH:MM:SSZ'));
ncwriteatt(ncfile,'/','time_coverage_end',datestr(max(F2.time),'yyyy-mm-ddTHH:MM:SSZ'));

fprintf('Wrote %s (CF-1.10 compliant; optional vars skipped if absent)\n', ncfile);

% ===== nested writers =====

    function write_td(nc,varname,standard_name,units,long_name,dimorder)
        if ~has(varname), return; end
        v = F2.(varname);
        assert(isequal(size(v),[nt nz]), '%s must be nt x nz', varname);
        nccreate(nc,varname,'Dimensions',{dimorder{1},nt,dimorder{2},nz},'DeflateLevel',4);
        ncwrite(nc,varname,v);
        if ~isempty(standard_name), ncwriteatt(nc,varname,'standard_name',standard_name); end
        ncwriteatt(nc,varname,'long_name',long_name);
        ncwriteatt(nc,varname,'units',units);
        ncwriteatt(nc,varname,'coordinates','lon_yuc4 lat_yuc4');
    end

    function write_prof(nc,varname,standard_name,units,long_name)
        if ~has('depth_prof') || ~has(varname), return; end
        vp = F2.(varname);
        nprofz = numel(F2.depth_prof);
        assert(isvector(vp) && numel(vp)==nprofz, '%s must be length(depth_prof)', varname);
        nccreate(nc,varname,'Dimensions',{'depth_prof',nprofz},'DeflateLevel',4);
        ncwrite(nc,varname,vp(:));
        if ~isempty(standard_name), ncwriteatt(nc,varname,'standard_name',standard_name); end
        ncwriteatt(nc,varname,'long_name',long_name);
        ncwriteatt(nc,varname,'units',units);
        ncwriteatt(nc,varname,'coordinates','lon_yuc4 lat_yuc4');
        ncwriteatt(nc,varname,'cell_methods','time: mean within composite group');
    end

    function write_sec(nc,varname,standard_name,units,long_name)
        if ~has('z_section') || ~has('x_section') || ~has(varname), return; end
        A = F2.(varname);
        assert(isequal(size(A),[numel(F2.z_section) numel(F2.x_section)]), ...
            '%s must be [length(z_section) x length(x_section)]', varname);
        nccreate(nc,varname,'Dimensions',{'z_section',numel(F2.z_section),'x_section',numel(F2.x_section)},'DeflateLevel',4);
        ncwrite(nc,varname,A);
        if ~isempty(standard_name), ncwriteatt(nc,varname,'standard_name',standard_name); end
        ncwriteatt(nc,varname,'long_name',long_name);
        ncwriteatt(nc,varname,'units',units);
        coords = 'z_section x_section';
        if has('lon_section') && has('lat_section')
            coords = [coords ' lon_section lat_section'];
        end
        ncwriteatt(nc,varname,'coordinates',coords);
        ncwriteatt(nc,varname,'cell_methods','time: mean within composite group');
    end
end
