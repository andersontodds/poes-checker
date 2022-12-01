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

% % display contents of single file
% n18_file = "data/poes_n18_20221018_proc.nc";
% n19_file = "data/poes_n19_20221018_proc.nc";
% ncdisp(poesfile);

% substorms from Bland et al 2022 (https://doi.org/10.3389/fspas.2022.978371)
%   2019 10 25
%   2018 12 10
%   2018 06 18

% notable events in Sfile data period
%   2022 11 07: M5 flare (00:11 UT), and greatly increased 0-degree flux at
%   midlatitude-subauroral L shell -- stronger effect than 2019 10 25
%   substorm

year = 2022;
month = 11;
day = 07;

datafields = ["time"; "lat"; "lon"; "alt"; "geod_lat_foot"; "geod_lon_foot"; ...
    "L_IGRF"; "MLT"; ...
    "mep_ele_tel0_flux_e2"; "mep_ele_tel0_flux_e3" ;"mep_ele_tel0_flux_e4"; ...
    "mep_ele_tel90_flux_e2"; "mep_ele_tel90_flux_e3"; "mep_ele_tel90_flux_e4"];

m01 = poesimport(year, month, day, "m01", datafields);
m03 = poesimport(year, month, day, "m03", datafields); % change to "m02" for 2018 and earlier
n15 = poesimport(year, month, day, "n15", datafields);
n18 = poesimport(year, month, day, "n18", datafields);
n19 = poesimport(year, month, day, "n19", datafields);

% % time
% n18_time_ms = cast(ncread(n18_file, "time"), "double"); % milliseconds since January 1, 1970 00:00 UTC
% n18_time_dn = n18_time_ms/(1000*60*60*24) + datenum(1970,01,01);
% n18_time_dt = datetime(n18_time_dn, "ConvertFrom", "datenum");
% 
% n19_time_ms = cast(ncread(n19_file, "time"), "double"); % milliseconds since January 1, 1970 00:00 UTC
% n19_time_dn = n19_time_ms/(1000*60*60*24) + datenum(1970,01,01);
% n19_time_dt = datetime(n19_time_dn, "ConvertFrom", "datenum");
% 
% % latitude, longitude, altitude
% n19_lat = cast(ncread(n19_file, "lat"), "double");      % degrees
% n19_lon = cast(ncread(n19_file, "lon"), "double");      % degrees    
% n19_alt = cast(ncread(n19_file, "alt"), "double");      % km
% 
% % magnetic field/magnetic coordinates
% % POES data come with many different magnetic field components and
% % coordinates, including coordinates of the magnetic foot point, magnetic
% % field components at both the satellite and satellite foot point, and the
% % familiar L-shell and MLT.  For now, let's only import the geodetic
% % coordinates of the footpoint.
% n19_foot_lat = cast(ncread(n19_file, "geod_lat_foot"), "double");
% n19_foot_lon = cast(ncread(n19_file, "geod_lon_foot"), "double");
% 
% % electron channels
% % MEPED has two electron telescopes, oriented approximately 0 degrees and
% % 90 degrees to the local vertical.  Each telescope has a 13-degree field
% % of view. At middle and high latitudes, the 0 degree telescope measures
% % precipitating flux, and the 90 degree telescope measures trapped flux.
% %
% % TODO: check electron energy levels: documentation in PDF does not match
% % NC file channel descriptions
% % Each telescope measures electrons in three energy bands:
% %   E1:  30 keV to 2500 keV
% %   E2: 100 keV to 2500 keV
% %   E3: 300 keV to 2500 keV
% % Flux of lower-energy electrons (e.g. 30-100 keV) can be obtained by
% % subtracting the E2 flux from the E1 flux.  We are mainly concerned with
% % electrons in the 100 keV-1 MeV range, and will be using these data
% % qualitatively, so the unmodified E2 and E3 channels should suffice.
% 
% % all electron fluxes have units of (counts cm^-2 sr^-1 s^-1)
% 
% n19_tel0_flux_e2 = cast(ncread(n19_file, "mep_ele_tel0_flux_e2"), "double");
% n19_tel0_flux_e3 = cast(ncread(n19_file, "mep_ele_tel0_flux_e3"), "double");
% n19_tel0_flux_e4 = cast(ncread(n19_file, "mep_ele_tel0_flux_e4"), "double");
% 
% n19_tel90_flux_e2 = cast(ncread(n19_file, "mep_ele_tel90_flux_e2"), "double");
% n19_tel90_flux_e3 = cast(ncread(n19_file, "mep_ele_tel90_flux_e3"), "double");
% n19_tel90_flux_e4 = cast(ncread(n19_file, "mep_ele_tel90_flux_e4"), "double");

%% plot electron flux on each channel as a function of time
figure(1)

% colormap
colors = crameri('-lajolla', 5);
colors = colors(2:end, :);

tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
ax1 = nexttile;
hold off
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel0_flux_e2, '.');
hold on
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel0_flux_e3, '.');
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel0_flux_e4, '.');
ylim([1E2 1E6]);
colororder(ax1, colors);
legend("E2", "E3", "E4");
title("MEPED 0\circ telescope");

ax2 = nexttile;
hold off
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel90_flux_e2, '.');
hold on
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel90_flux_e3, '.');
semilogy(datetime(m03.time,"ConvertFrom", "datenum"), m03.mep_ele_tel90_flux_e4, '.');
ylim([1E2 1E6]);
colororder(ax2, colors);
legend("E2", "E3", "E4");
title("MEPED 90\circ telescope");

%% plot electron flux filtered by L-shell as a function of time

Lbounds = ...[ 0, 2;
            [2, 3; 
            3, 4; 
            4, 5; 
            5, 20];

% colormap
colors = crameri('-lajolla', size(Lbounds,1)+2);
colors = colors(2:end-1, :);

close(figure(2))
f2 = figure(2);
set(gca, 'YScale', 'log');
hold on;

for L = 1:size(Lbounds,1)
    m01_inL = m01.L_IGRF > Lbounds(L,1) & m01.L_IGRF < Lbounds(L,2);
    m01_time_inL = m01.time(m01_inL);
    m01_e3_0_inL = m01.mep_ele_tel0_flux_e3(m01_inL);
    m01_e3_90_inL = m01.mep_ele_tel90_flux_e3(m01_inL);

    m03_inL = m03.L_IGRF > Lbounds(L,1) & m03.L_IGRF < Lbounds(L,2);
    m03_time_inL = m03.time(m03_inL);
    m03_e3_0_inL = m03.mep_ele_tel0_flux_e3(m03_inL);
    m03_e3_90_inL = m03.mep_ele_tel90_flux_e3(m03_inL);

    n15_inL = n15.L_IGRF > Lbounds(L,1) & n15.L_IGRF < Lbounds(L,2);
    n15_time_inL = n15.time(n15_inL);
    n15_e3_0_inL = n15.mep_ele_tel0_flux_e3(n15_inL);
    n15_e3_90_inL = n15.mep_ele_tel90_flux_e3(n15_inL);

    n18_inL = n18.L_IGRF > Lbounds(L,1) & n18.L_IGRF < Lbounds(L,2);
    n18_time_inL = n18.time(n18_inL);
    n18_e3_0_inL = n18.mep_ele_tel0_flux_e3(n18_inL);
    n18_e3_90_inL = n18.mep_ele_tel90_flux_e3(n18_inL);

    n19_inL = n19.L_IGRF > Lbounds(L,1) & n19.L_IGRF < Lbounds(L,2);
    n19_time_inL = n19.time(n19_inL);
    n19_e3_0_inL = n19.mep_ele_tel0_flux_e3(n19_inL);
    n19_e3_90_inL = n19.mep_ele_tel90_flux_e3(n19_inL);

    sat_time = [m01_time_inL; m03_time_inL; n15_time_inL; n18_time_inL; n19_time_inL];
    sat_e3_0 = [m01_e3_0_inL; m03_e3_0_inL; n15_e3_0_inL; n18_e3_0_inL; n19_e3_0_inL];
    sat_e3_90 = [m01_e3_90_inL; m03_e3_90_inL; n15_e3_90_inL; n18_e3_90_inL; n19_e3_90_inL];

    dispname = sprintf("L = [%g, %g]", Lbounds(L,1), Lbounds(L,2));
    semilogy(f2,datetime(sat_time, "ConvertFrom", "datenum"), sat_e3_0, '.', 'Color', colors(L,:), "DisplayName", dispname);
%     semilogy(f2,datetime(sat_time, "ConvertFrom", "datenum"), sat_e3_90, '.', 'Color', colors(L,:), "DisplayName", dispname);
    
end

ylim([1E3 1E6])
ylabel("electron flux (cm^{-2} sr^{-1} keV^{-1} s^{-1})")
legend;
title("E3 0-degree flux at different L shells, all satellites")

% %% plot electron flux on map
% load coastlines;
% 
% figure(2)
% hold off
% tl = tiledlayout(3,2,"TileSpacing","tight","Padding","compact");
% ax1 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax1, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel0_flux_e2);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel0_flux_e2);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel0_flux_e2);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel0_flux_e2);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel0_flux_e2);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% y1 = ylabel("E2      ");
% y1.FontSize = 15;
% y1.FontWeight = "bold";
% y1.Rotation = 0;
% t1 = title("0\circ telescope");
% t1.FontSize = 15;
% tightmap
% 
% set(ax1,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% ax2 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax2, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel90_flux_e2);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel90_flux_e2);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel90_flux_e2);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel90_flux_e2);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel90_flux_e2);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% % ylabel("Longitude");
% t2 = title("90\circ telescope");
% t2.FontSize = 15;
% tightmap
% 
% set(ax2,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% ax3 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax3, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel0_flux_e3);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel0_flux_e3);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel0_flux_e3);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel0_flux_e3);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel0_flux_e3);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% y3 = ylabel("E3      ");
% y3.FontSize = 15;
% y3.FontWeight = "bold";
% y3.Rotation = 0;
% % t3 = title("MEPED 0\circ telescope E3 flux");
% % t3.FontSize = 15;
% tightmap
% 
% set(ax3,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% ax4 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax4, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel90_flux_e3);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel90_flux_e3);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel90_flux_e3);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel90_flux_e3);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel90_flux_e3);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% % ylabel("Longitude");
% % t4 = title("MEPED 90\circ telescope E3 flux");
% % t4.FontSize = 15;
% tightmap
% 
% set(ax4,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% ax5 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax3, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel0_flux_e4);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel0_flux_e4);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel0_flux_e4);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel0_flux_e4);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel0_flux_e4);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% y3 = ylabel("E4      ");
% y3.FontSize = 15;
% y3.FontWeight = "bold";
% y3.Rotation = 0;
% % t3 = title("MEPED 0\circ telescope E3 flux");
% % t3.FontSize = 15;
% tightmap
% 
% set(ax5,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% ax6 = nexttile;
% hold off
% % worldmap('World');
% % setm(ax4, "MapProjection","pcarree");
% axesm("MapProjection","pcarree", "MapLatLimit",[-90 90], "MapLonLimit",[-180 180]);
% framem;
% gridm;
% % mlabel;
% % plabel;
% hold on
% % scatterm(m01.lat, m01.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m01.lat, m01.lon, 5, m01.mep_ele_tel90_flux_e4);
% % scatterm(m03.lat, m03.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(m03.lat, m03.lon, 5, m03.mep_ele_tel90_flux_e4);
% % scatterm(n15.lat, n15.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n15.lat, n15.lon, 5, n15.mep_ele_tel90_flux_e4);
% % scatterm(n18.lat, n18.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n18.lat, n18.lon, 5, n18.mep_ele_tel90_flux_e4);
% % scatterm(n19.lat, n19.lon, 0.5, [0.5 0.5 0.5]); % ground track
% scatterm(n19.lat, n19.lon, 5, n19.mep_ele_tel90_flux_e4);
% geoshow(coastlat, coastlon, "Color", [1 0.25 0.25], "LineWidth", 1.5);
% % xlabel("Latitude");
% % ylabel("Longitude");
% % t4 = title("MEPED 90\circ telescope E3 flux");
% % t4.FontSize = 15;
% tightmap
% 
% set(ax6,'ColorScale','log');
% crameri('devon'); % requires "crameri" colormap toolbox
% caxis([10 100000]);
% 
% 
% cb = colorbar;
% cb.Layout.Tile = "east";
% cb.Label.String = "counts cm^{-2} sr^{-1} s^{-1}";
% cb.Label.FontSize = 15;
% cb.FontSize = 12;
% 
% titlestr = sprintf("MEPED fluxes %d-%d-%d\nNOAA-15, -18, -19 and MetOp-01, -03", year, month, day);
% t = title(tl, titlestr);
% t.FontSize = 15;
% t.FontWeight = "bold";

%% satellite orbit information

%colormap
% colors = crameri('-buda', 5);
% colors = colors(2:end, :);

figure(3)

tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
ax1 = nexttile;
hold off
plot(datetime(m01.time,"ConvertFrom", "datenum"), m01.MLT, '.');
hold on
plot(datetime(m03.time,"ConvertFrom", "datenum"), m03.MLT, '.');
plot(datetime(n15.time,"ConvertFrom", "datenum"), n15.MLT, '.');
plot(datetime(n18.time,"ConvertFrom", "datenum"), n18.MLT, '.');
plot(datetime(n19.time,"ConvertFrom", "datenum"), n19.MLT, '.');
ylim([0 24])
ylabel("MLT (hour)")
legend("MetOp-01", "MetOp-03", "NOAA-15", "NOAA-18", "NOAA-19")
title("Magnetic local time (MLT) of POES satellites")

ax2 = nexttile;
hold off
plot(m01.lat, m01.MLT, '.');
hold on
plot(m03.lat, m03.MLT, '.');
plot(n15.lat, n15.MLT, '.');
plot(n18.lat, n18.MLT, '.');
plot(n19.lat, n19.MLT, '.');
xlim([-90 90])
ylim([0 24])
xlabel("latitude (\circ)")
ylabel("MLT (hour)")
legend("MetOp-01", "MetOp-03", "NOAA-15", "NOAA-18", "NOAA-19")
% title("Magnetic local time (MLT) of POES satellites")

%% particle counts vs. L shell


recent = m03.time(end) - m03.time < 12/24;
highL = m03.L_IGRF > 3;

time_filtered = m03.time(recent & highL);

e3_0_mm = movmean(m03.mep_ele_tel0_flux_e3(recent & highL), 1*60/2); % 1-minute moving mean of 2-second cadence data
e3_90_mm = movmean(m03.mep_ele_tel90_flux_e3(recent & highL), 1*60/2); % 1-minute moving mean of 2-second cadence data

flag = e3_0_mm > 1E3 & e3_90_mm > 1E5;

flagtimes = time_filtered(flag);

if any(flag) 
    flagstr = sprintf("E3 flux exceeded at %s, start saving Sfiles!", datestr(flagtimes(1), "yyyymmdd HH:MM:SS"));
    disp(flagstr)
end


figure(4)
% colormap
colors = crameri('-lajolla', 5);
colors = colors(2:end, :);

tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
ax1 = nexttile;
hold off
semilogy(m03.L_IGRF, m03.mep_ele_tel0_flux_e2, '.');
hold on
semilogy(m03.L_IGRF, m03.mep_ele_tel0_flux_e3, '.');
semilogy(m03.L_IGRF, m03.mep_ele_tel0_flux_e4, '.');
semilogy(m03.L_IGRF(recent & highL), e3_0_mm, 'm*');
ylim([1E2 1E6]);
xlim([0 20]);
colororder(ax1, colors);
legend("E2", "E3", "E4");
title("MEPED 0\circ telescope");

ax2 = nexttile;
hold off
semilogy(m03.L_IGRF, m03.mep_ele_tel90_flux_e2, '.');
hold on
semilogy(m03.L_IGRF, m03.mep_ele_tel90_flux_e3, '.');
semilogy(m03.L_IGRF, m03.mep_ele_tel90_flux_e4, '.');
semilogy(m03.L_IGRF(recent & highL), e3_90_mm, 'm*');
ylim([1E2 1E6]);
xlim([0 20]);
colororder(ax2, colors);
legend("E2", "E3", "E4");
title("MEPED 90\circ telescope");

