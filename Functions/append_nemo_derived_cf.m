function append_nemo_derived_cf(ncfile, abs_dudz, dTdz_CT, Ro, varargin)
% append_nemo_derived_cf  Append derived 3-D fields to an existing CF NetCDF.
%
% INPUTS:
%   ncfile   : existing NetCDF written with dims (time, depth, section)
%   abs_dudz : |∂u/∂z|, size nz×nx×nt (s^-1). Use [] to skip.
%   dTdz_CT  : ∂T/∂z (Conservative T), size nz×nx×nt (°C m^-1). [] to skip.
%   Ro       : Rossby number ζ/f, size nz×nx×nt (1). [] to skip.
%
% OPTIONS (name/value):
%   'precision' : 'single' (default) or 'double'  – for the 3-D vars
%   'deflate'   : compression level 0..9 (default 4)
%   'stream'    : true (default) to write in time-slices (low RAM),
%                 false to write whole arrays at once (faster, needs RAM)
%
% NOTES:
%   - Expects the NetCDF to already have 'time','depth','section',
%     and 'section_longitude','section_latitude'.
%   - Input arrays are assumed nz×nx×nt (depth × section × time).

% ---- options
p = inputParser;
p.addParameter('precision','single',@(s)ischar(s)||isstring(s));
p.addParameter('deflate',4,@(x)isnumeric(x)&&isscalar(x)&&x>=0&&x<=9);
p.addParameter('stream',true,@(x)islogical(x)||ismember(x,[0 1]));
p.parse(varargin{:});
prec    = lower(strtrim(char(p.Results.precision)));
if strcmpi(prec,'double'), dtype3d = 'double'; else, dtype3d = 'single'; end
defl    = p.Results.deflate;
doStream= p.Results.stream;

% ---- infer dims from file
nt = length(ncread(ncfile,'time'));
nz = length(ncread(ncfile,'depth'));
nx = length(ncread(ncfile,'section_longitude'));

% ---- default chunking optimized for time-window access
chunks = [min(30,nt) min(64,nz) nx];  % [time depth section]

% ---- write each variable if provided
write3d(ncfile,'abs_dudz',abs_dudz, ...
    'vertical_shear_of_eastward_sea_water_velocity','s-1', ...
    '|∂u/∂z| (vertical shear magnitude, eastward)', ...
    dtype3d, defl, chunks, doStream);

% CF doesn’t (yet) have a widely-used name for CT gradient; keep long_name clear.
write3d(ncfile,'dTdz_CT',dTdz_CT, ...
    '', 'degree_Celsius m-1', ...
    'Vertical gradient of conservative temperature (∂T/∂z)', ...
    dtype3d, defl, chunks, doStream);

write3d(ncfile,'Ro',Ro, ...
    '', '1', ...
    'Rossby number (ζ/f)', ...
    dtype3d, defl, chunks, doStream);

fprintf('Appended derived fields to %s\n', ncfile);

% ================= inner helper =================
function write3d(nc,varname,A,stdname,units,longname,dtype,defl_,chunksz,streamMode)
    if isempty(A), return; end
    assert(ndims(A)==3, '%s must be nz×nx×nt', varname);
    sz = size(A);
    nz_ = sz(1); nx_ = sz(2); nt_ = sz(3);
    assert(nz_==nz && nx_==nx && nt_==nt, ...
        '%s has size [%d %d %d], expected [%d %d %d] (nz nx nt)', ...
        varname, nz_, nx_, nt_, nz, nx, nt);

    % define var (time × depth × section)
    args = {'Dimensions',{'time',nt,'depth',nz,'section',nx}, ...
            'DeflateLevel',defl_,'Shuffle',true,'Chunksize',chunksz};
    if strcmp(dtype,'single'), args = [args {'Datatype','single'}]; end
    nccreate(nc,varname, args{:});

    % attributes
    if ~isempty(stdname), ncwriteatt(nc,varname,'standard_name',stdname); end
    ncwriteatt(nc,varname,'long_name',longname);
    ncwriteatt(nc,varname,'units',units);
    ncwriteatt(nc,varname,'coordinates','section_longitude section_latitude');

    if streamMode
        % memory-safe write: one time-slice at a time
        for it = 1:nt
            slab = A(:,:,it);                % nz × nx
            if strcmp(dtype,'single'), slab = single(slab); end
            ncwrite(nc, varname, slab, [it 1 1], [1 nz nx]);  % start/count
        end
    else
        % fast write (needs RAM): permute to [time depth section] and write once
        B = permute(A,[3 1 2]);             % nt × nz × nx
        if strcmp(dtype,'single'), B = single(B); end
        ncwrite(nc, varname, B);
    end
end
end
