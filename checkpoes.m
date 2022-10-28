function checkpoes(year, month, day, sat)
% Todd Anderson
% 26 October 2022
%
% Check whether POES MEPED electron fluxes exceed preset thresholds.
% Intended to be called by bash script poes-curl or similar.
%
% Script form:
% for each satellite:
%   determine most recent data file
%   load MEPED data of interest from file
%   filter data:
%       L > 3
%       time: only data since last update (how to record this?) or last 2
%       orbits
%   check whether filtered data outputs exceed thresholds
%       threshold: E3 90-degree = 10^5 && E3 0-degree = 10^4
%       movmean(filtered data, 10 minutes) > threshold?
%           true: send some kind of notification to WWLLN stations
%           else: do nothing
%
% Function form: same as above, but take data file as input

% convert numerical YYYY MM DD inputs from char to double
if ischar(year)
    year = sscanf(year, '%f');
end

if ischar(month)
    month = sscanf(month, '%f');
end

if ischar(day)
    day = sscanf(day, '%f');
end

datafields = ["time"; "lat"; "lon"; "alt"; "L_IGRF"; "MLT"; ...
    "mep_ele_tel0_flux_e2"; "mep_ele_tel0_flux_e3" ;"mep_ele_tel0_flux_e4"; ...
    "mep_ele_tel90_flux_e2"; "mep_ele_tel90_flux_e3"; "mep_ele_tel90_flux_e4"];

satdat = poesimport(year, month, day, sat, datafields);

% set time and L-shell limits
recent = satdat.time(end) - satdat.time < 2/24; % most recent 2 hours
highL = satdat.L_IGRF > 3;

time_filtered = satdat.time(recent & highL);

e3_0_mm = movmean(satdat.mep_ele_tel0_flux_e3(recent & highL), 1*60/2); % 1-minute moving mean of 2-second cadence data
e3_90_mm = movmean(satdat.mep_ele_tel90_flux_e3(recent & highL), 1*60/2); % 1-minute moving mean of 2-second cadence data

flag = e3_0_mm > 1E3 & e3_90_mm > 1E5;

flagtimes = time_filtered(flag);

% open log file
fid = fopen('checkpoesLog.txt', 'a');
if fid == -1
    error('Cannot open log file.');
end

if any(flag) 
    msg = sprintf("%s, %s: E3 flux exceeded threshold at %s, start saving Sfiles!", string(sat), datestr(now, 0), datestr(flagtimes(1), "yyyymmdd HH:MM:SS"));
    disp(msg)
    fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
else
    msg = sprintf("%s, %s: E3 flux below threshold.",string(sat), datestr(now, 0));
    disp(msg)
    fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
end

fclose(fid);

end