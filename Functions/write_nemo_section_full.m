function write_nemo_section_full(Xnemo, Ynemo, Znemo, tinemo, SAi, ...
    CTnemo, Gnemo, Rinemo, SAnemo, Unemo, Vnemo, Wnemo, ...
    dvdz, dTdz, Ro, ncfile, varargin)
% write_nemo_section_full
% Write NEMO-G108 section time series (base + derived) to one CF NetCDF.
%
% INPUT SHAPES:
%   Xnemo(1×nx), Ynemo(1×nx)      : section lon/lat (degE/degN)
%   Znemo(nz×1)                    : depth (m; any sign, will be positive-down)
%   tinemo(1×nt)                   : MATLAB datenum
%   SAi(1×nt)                      : salinity index time series (g kg-1)
%   CTnemo, Gnemo, Rinemo, SAnemo,
%   Unemo, Vnemo, Wnemo            : nz×nx×nt (3-D base fields)
%   dvdz, dTdz, Ro                 : nz×nx×nt (3-D derived; pass [] to skip any)
%
% OPTIONS (name/value):
%   'precision_base'    : 'single' (default) or 'double' for base 3-D vars
%   'precision_derived' : 'single' or 'double' (default 'single')
%   'deflate'           : compression level 0..9 (default 4)
%   'time_name'         : name for time variable (default 'time')
%
% DISK LAYOUT: variables stored as [time × depth × section].
% NOTE: Writing whole arrays in one go requires plenty of RAM.

% ---- options
p = inputParser;
p.addParameter('precision_base','single',@(s)ischar(s)||isstring(s));
p.addParameter('precision_derived','single',@(s)ischar(s)||isstring(s));
p.addParameter('deflate',4,@(x)isnumeric(x)&&isscalar(x)&&x>=0&&x<=9);
p.addParameter('time_name','time',@(s)ischar(s)||isstring(s));
p.parse(varargin{:});
dtype_base    = i_dtype(p.Results.precision_base);
dtype_derived = i_dtype(p.Results.precision_derived);
defl          = p.Results.deflate;
tvar          = char(p.Results.time_name);

% ---- basic sizes
nx = numel(Xnemo);  nz = numel(Znemo);  nt = numel(tinemo);

% sanity on 3-D sizes (only for non-empty arrays)
chk3d(CTnemo,'CTnemo',nz,nx,nt);
chk3d(Gnemo ,'Gnemo' ,nz,nx,nt);
chk3d(Rinemo,'Rinemo',nz,nx,nt);
chk3d(SAnemo,'SAnemo',nz,nx,nt);
chk3d(Unemo ,'Unemo' ,nz,nx,nt);
chk3d(Vnemo ,'Vnemo' ,nz,nx,nt);
chk3d(Wnemo ,'Wnemo' ,nz,nx,nt);
chk3d(dvdz  ,'dvdz'  ,nz,nx,nt, true);
chk3d(dTdz  ,'dTdz'  ,nz,nx,nt, true);
chk3d(Ro    ,'Ro'    ,nz,nx,nt, true);

% ---- build coords
if exist(ncfile,'file'); delete(ncfile); end
epoch = datenum('1970-01-01 00:00:00');
time_sec = (tinemo(:) - epoch) * 86400;   % CF time (seconds since epoch)
depth_cf = abs(Znemo(:));                 % CF depth positive down

% ---- create dimensions & coordinate vars
nccreate(ncfile, tvar,  'Dimensions',{'time',nt}, 'Format','netcdf4');
nccreate(ncfile,'depth','Dimensions',{'depth',nz});
nccreate(ncfile,'section','Dimensions',{'section',nx}); % dim only
nccreate(ncfile,'section_longitude','Dimensions',{'section',nx});
nccreate(ncfile,'section_latitude' ,'Dimensions',{'section',nx});

ncwrite(ncfile, tvar,  time_sec);
ncwrite(ncfile,'depth',depth_cf);
ncwrite(ncfile,'section_longitude',Xnemo(:));
ncwrite(ncfile,'section_latitude' ,Ynemo(:));

% CF attrs for coords
ncwriteatt(ncfile, tvar, 'standard_name','time');
ncwriteatt(ncfile, tvar, 'units','seconds since 1970-01-01 00:00:00 UTC');
ncwriteatt(ncfile, tvar, 'calendar','gregorian');
ncwriteatt(ncfile,'depth','standard_name','depth');
ncwriteatt(ncfile,'depth','units','m'); ncwriteatt(ncfile,'depth','positive','down'); ncwriteatt(ncfile,'depth','axis','Z');
ncwriteatt(ncfile,'section_longitude','standard_name','longitude'); ncwriteatt(ncfile,'section_longitude','units','degrees_east');
ncwriteatt(ncfile,'section_latitude' ,'standard_name','latitude');  ncwriteatt(ncfile,'section_latitude' ,'units','degrees_north');

% ---- 1-D salinity index
nccreate(ncfile,'sal_index','Dimensions',{'time',nt},'DeflateLevel',defl,'Shuffle',true);
ncwrite(ncfile,'sal_index',SAi(:));
ncwriteatt(ncfile,'sal_index','standard_name','sea_water_absolute_salinity');
ncwriteatt(ncfile,'sal_index','long_name','Salinity index at \sigma_\theta \approx 25.3 \pm 0.3 kg m^{-3}');
ncwriteatt(ncfile,'sal_index','units','g kg-1');

% ---- default chunking (good for time-window access)
chunks = [min(30,nt)  min(64,nz)  nx];   % [time depth section]

% ---- BASE 3-D variables (permute nz×nx×nt -> nt×nz×nx)
w3d(ncfile,'CT',   CTnemo, 'sea_water_conservative_temperature','degree_Celsius', ...
    'Conservative temperature',           tvar, defl, dtype_base, chunks);
w3d(ncfile,'G',    Gnemo,  'sea_water_potential_density','kg m-3', ...
    'Potential density (ref p=0 dbar)',   tvar, defl, dtype_base, chunks, 'reference_pressure','0 dbar');
w3d(ncfile,'Ri',   Rinemo, 'gradient_Richardson_number','1', ...
    'Gradient Richardson number',         tvar, defl, dtype_base, chunks);
w3d(ncfile,'SA',   SAnemo, 'sea_water_absolute_salinity','g kg-1', ...
    'Absolute salinity',                  tvar, defl, dtype_base, chunks);
w3d(ncfile,'u',    Unemo,  'eastward_sea_water_velocity','m s-1', ...
    'Zonal velocity',                     tvar, defl, dtype_base, chunks);
w3d(ncfile,'v',    Vnemo,  'northward_sea_water_velocity','m s-1', ...
    'Meridional velocity',                tvar, defl, dtype_base, chunks);
w3d(ncfile,'w',    Wnemo,  'upward_sea_water_velocity','m s-1', ...
    'Vertical velocity',                  tvar, defl, dtype_base, chunks);

% ---- DERIVED 3-D variables (optional)
w3d(ncfile,'dvdz', dvdz, '', 's-1', ...
    'Magnitude of the vertical shear of the horizontal velocity ([∂v/∂z]^2 + ∂u/∂z]^2)^(1/2)', tvar, defl, dtype_derived, chunks);
w3d(ncfile,'dTdz', dTdz, '', 'degree_Celsius m-1', ...
    'Vertical gradient of conservative temperature (∂T/∂z)', tvar, defl, dtype_derived, chunks);
w3d(ncfile,'Ro',   Ro,   '', '1', ...
    'Rossby number (ζ/f)', tvar, defl, dtype_derived, chunks);

% ---- global attributes
ncwriteatt(ncfile,'/','title','NEMO-G108 Yucatan Channel section time series (2010–2022)');
ncwriteatt(ncfile,'/','summary',['Section-aligned time series (time × depth × section): CT, potential density, ', ...
    'Ri, SA, u, v, w; plus derived dvdz, dTdz, Ro and salinity index.']);
ncwriteatt(ncfile,'/','Conventions','CF-1.10');
ncwriteatt(ncfile,'/','institution','Project CANEK / NEMO-G108');
ncwriteatt(ncfile,'/','source','NEMO v4 output extracted along Yucatan Channel section');
ncwriteatt(ncfile,'/','featureType','timeSeriesProfile');
ncwriteatt(ncfile,'/','history',[datestr(now,'yyyy-mm-dd HH:MM:SS'),' : created by write_nemo_section_full.m']);
ncwriteatt(ncfile,'/','geospatial_lon_min',min(Xnemo)); ncwriteatt(ncfile,'/','geospatial_lon_max',max(Xnemo));
ncwriteatt(ncfile,'/','geospatial_lat_min',min(Ynemo)); ncwriteatt(ncfile,'/','geospatial_lat_max',max(Ynemo));
ncwriteatt(ncfile,'/','geospatial_vertical_min',min(depth_cf)); ncwriteatt(ncfile,'/','geospatial_vertical_max',max(depth_cf));
ncwriteatt(ncfile,'/','time_coverage_start',datestr(min(tinemo),'yyyy-mm-ddTHH:MM:SSZ'));
ncwriteatt(ncfile,'/','time_coverage_end'  ,datestr(max(tinemo),'yyyy-mm-ddTHH:MM:SSZ'));

fprintf('Wrote %s (CF-1.10; dims: time × depth × section)\n', ncfile);

% ================= helpers =================
function dtype = i_dtype(s)
    if strcmpi(s,'double'), dtype='double'; else, dtype='single'; end
end

function chk3d(A,name,nz_,nx_,nt_,allowEmpty)
    if nargin<6, allowEmpty=false; end
    if isempty(A) && allowEmpty, return; end
    assert(ndims(A)==3 && all(size(A)==[nz_ nx_ nt_]), ...
        '%s must be size [%d %d %d] (nz×nx×nt).', name, nz_, nx_, nt_);
end

function w3d(nc,varname,A,stdname,units,longname,tname,defl_,dtype_,chunksz,varargin)
    if isempty(A), return; end
    B = permute(A,[3 1 2]);                     % nt×nz×nx
    args = {'Dimensions',{'time',size(B,1),'depth',size(B,2),'section',size(B,3)}, ...
            'DeflateLevel',defl_,'Shuffle',true,'Chunksize',chunksz};
    if strcmp(dtype_,'single'), args = [args {'Datatype','single'}]; end
    nccreate(nc,varname,args{:});
    if strcmp(dtype_,'single'), B = single(B); end
    ncwrite(nc,varname,B);
    if ~isempty(stdname), ncwriteatt(nc,varname,'standard_name',stdname); end
    ncwriteatt(nc,varname,'long_name',longname);
    ncwriteatt(nc,varname,'units',units);
    ncwriteatt(nc,varname,'coordinates','section_longitude section_latitude');
    for ii=1:2:numel(varargin)                      % extra var attributes
        ncwriteatt(nc,varname,varargin{ii},varargin{ii+1});
    end
end
end
