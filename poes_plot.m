% poes_plot.m
% Todd Anderson
% October 19 2022
%
% Import and plot variables from small numbers of POES files.  Includes
% basic operations for interacting with NetCDF (.nc) files.
%
% This script will plot data from the Medium Energy Proton and Electron
% Detector (MEPED) instrument on board the POES series of satellites, as
% well as time and position information.  A description of MEPED can be
% found in section 3 of this document: 
% https://ngdc.noaa.gov/stp/satellite/poes/docs/SEM2Archive.pdf
%
% Spacecraft operating as of October 2022:
%   MetOp-01
%   MetOp-03
%   NOAA-15
%   NOAA-18
%   NOAA-19

% display contents of single file
poesfile = "data/poes_n19_20221018_proc.nc";
%ncdisp(poesfile);

% time
time_ms = cast(ncread(poesfile, "time"), "double"); % milliseconds since January 1, 1970 00:00 UTC
time_dn = time_ms/(1000*60*60*24) + datenum(1970,01,01);
time_dt = datetime(time_dn, "ConvertFrom", "datenum");

% latitude, longitude, altitude
lat = cast(ncread(poesfile, "lat"), "double");      % degrees
lon = cast(ncread(poesfile, "lon"), "double");      % degrees    
alt = cast(ncread(poesfile, "alt"), "double");      % km

% magnetic field/magnetic coordinates
% POES data come with many different magnetic field components and
% coordinates, including coordinates of the magnetic foot point, magnetic
% field components at both the satellite and satellite foot point, and the
% familiar L-shell and MLT.  For now, let's only import the geodetic
% coordinates of the footpoint.
foot_lat = cast(ncread(poesfile, "geod_lat_foot"), "double");
foot_lon = cast(ncread(poesfile, "geod_lon_foot"), "double");

% electron channels
% MEPED has two electron telescopes, oriented approximately 0 degrees and
% 90 degrees to the local vertical.  Each telescope has a 13-degree field
% of view. At middle and high latitudes, the 0 degree telescope measures
% precipitating flux, and the 90 degree telescope measures trapped flux.
%
% TODO: check electron energy levels: documentation in PDF does not match
% NC file channel descriptions
% Each telescope measures electrons in three energy bands:
%   E1:  30 keV to 2500 keV
%   E2: 100 keV to 2500 keV
%   E3: 300 keV to 2500 keV
% Flux of lower-energy electrons (e.g. 30-100 keV) can be obtained by
% subtracting the E2 flux from the E1 flux.  We are mainly concerned with
% electrons in the 100 keV-1 MeV range, and will be using these data
% qualitatively, so the unmodified E2 and E3 channels should suffice.

% all electron fluxes have units of (counts cm^-2 sr^-1 s^-1)

tel0_flux_e2 = cast(ncread(poesfile, "mep_ele_tel0_flux_e2"), "double");
tel0_flux_e3 = cast(ncread(poesfile, "mep_ele_tel0_flux_e3"), "double");
tel0_flux_e4 = cast(ncread(poesfile, "mep_ele_tel0_flux_e4"), "double");

tel90_flux_e2 = cast(ncread(poesfile, "mep_ele_tel90_flux_e2"), "double");
tel90_flux_e3 = cast(ncread(poesfile, "mep_ele_tel90_flux_e3"), "double");
tel90_flux_e4 = cast(ncread(poesfile, "mep_ele_tel90_flux_e4"), "double");


%% plot electron flux on each channel as a function of time
figure(1)

% colormap
colors = crameri('-lajolla', 5);
colors = colors(2:end, :);

tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
ax1 = nexttile;
hold off
semilogy(time_dt, tel0_flux_e2, '.');
hold on
semilogy(time_dt, tel0_flux_e3, '.');
semilogy(time_dt, tel0_flux_e4, '.');
ylim([1E2 1E6]);
colororder(ax1, colors);
legend("E2", "E3", "E4");
title("MEPED 0\circ telescope");

ax2 = nexttile;
hold off
semilogy(time_dt, tel90_flux_e2, '.');
hold on
semilogy(time_dt, tel90_flux_e3, '.');
semilogy(time_dt, tel90_flux_e4, '.');
ylim([1E2 1E6]);
colororder(ax2, colors);
legend("E2", "E3", "E4");
title("MEPED 90\circ telescope");

% plot electron flux on map
load coastlines;

figure(2)
tiledlayout(1,2,"TileSpacing","compact","Padding","compact")
ax1 = nexttile;
hold off
worldmap('World');
geoshow(coastlat, coastlon, "Color", "black");
hold on
scatterm(lat, lon, 0.5, [0.5 0.5 0.5]);
scatterm(lat, lon, 5, tel0_flux_e2);
% xlabel("Latitude");
% ylabel("Longitude");
t1 = title("MEPED 0\circ telescope E2 flux");
t1.FontSize = 15;

set(ax1,'ColorScale','log');
crameri('-hawaii');%,'pivot',1); % requires "crameri" colormap toolbox
caxis([10 100000]);

ax2 = nexttile;
hold off
worldmap('World');
geoshow(coastlat, coastlon, "Color", "black");
hold on
scatterm(lat, lon, 0.5, [0.5 0.5 0.5]);
scatterm(lat, lon, 5, tel90_flux_e2);
% xlabel("Latitude");
% ylabel("Longitude");
t2 = title("MEPED 90\circ telescope E2 flux");
t2.FontSize = 15;

set(ax2,'ColorScale','log');
crameri('-hawaii');%,'pivot',1); % requires "crameri" colormap toolbox
cb = colorbar;
cb.Layout.Tile = "south";
cb.Label.String = "counts cm^{-2} sr^{-1} s^{-1}";
cb.Label.FontSize = 15;
cb.FontSize = 12;
caxis([10 100000]);
