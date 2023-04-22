function out = mpeimport(varargin)
% Import specified data from MPE NetCDF files.
% 
% INPUTS: a MPE data file must be specified with either an exact filename,
% or date and satellite identifier.  An example filename is:
%   "data/mpe/POES_combinedSpectrum_m01_BLC_v3_20221101.nc"
% where       m01:        satellite identifier
%             20221101:   date - yyyymmdd
% Alternatively, the date and satellite IDs can be specified as four
% inputs, e.g. 
%   2022, 11, 01, "m01"
% After specifying either the filename or the date and satellite, the
% fields to be imported from the NetCDF file must be specified.  Fields can
% be listed as individual char or string arguments, or in a single vector
% of strings, e.g.:
%   "time", "lat", "lon", ...
% or
%   fields = ["time"; "lat"; "lon; ...]
%
% OUTPUTS:
%   out:  struct of data from NetCDF file
%
% Usage examples:
% 1: filename and field list
% filename = "data/mpe/POES_combinedSpectrum_m01_BLC_v3_20221101.nc";
% fields = ["time"; "foflLat"; "foflLon"; "MLT"; "lValue"; ...
%   "energy"; "BLC_Flux"; "BLC_Angle"];
% 
% mpedata = mpeimport(filename, fields);
%
% 2. date, satellite identifier, and individual fields
% mpedata = mpeimport(2022,11,01,"m01", "time","foflLat","foflLon");
%

% check whether first inputs are a filename, or yyyy mm dd sat.

if ischar(varargin{1}) || isstring(varargin{1}) % first input is filename
    file = string(varargin{1});
    filename = sprintf("data/%s", file);
    field_start_ind = 2;

elseif varargin{1} > 2011 && varargin{1} < 2100 % first input is year
    year = varargin{1};
    month = varargin{2};
    day = varargin{3};
    sat = string(varargin{4});

    switch sat
        case {"n15", "noaa15"}
            sat = "n15";
        case {"n18", "noaa18"}
            sat = "n18";
        case {"n19", "noaa19"}
            sat = "n19";
        case {"m01", "metop01"}
            sat = "m01";
        case {"m02", "metop02"}
            sat = "m02";    
        case {"m03", "metop03"}
            sat = "m03";
        otherwise
            disp(varargin)
            error("Invalid satellite specifier! Options are n15, n18, n19, m01, m02, m03.");
    end
    
    filename = sprintf("data/mpe/POES_combinedSpectrum_%s_BLC_v3_%04d%02d%02d.nc", sat, year, month, day);
    field_start_ind = 5;
else 
    error("Invalid input! Specify either a filename or year, month, day and satellite ID.\nType 'help mpeimport' for more info.");
end

% check whether fields to import are listed individually or in vector of
% strings

if length(string(varargin{field_start_ind})) == 1   % fields listed individually
%     disp(["field start ind = ", field_start_ind])
%     disp(varargin)
    fieldnames = string(varargin(field_start_ind:end));
    fieldnames = fieldnames';
else    % fields listed in single vector of strings
    fieldnames = varargin{field_start_ind};
end
out = struct();

% generate struct of outputs
for i = 1:length(fieldnames)
    fielddata = cast(ncread(filename, fieldnames{i}), "double");
    % convert time to datenum format
    if fieldnames{i} == "time"
        fielddata = fielddata./(1000*60*60*24) + datenum(1970, 01, 01);
    end
    
    out.(fieldnames{i}) = fielddata;
end

end