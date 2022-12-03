% find_max_flux.m
% Todd Anderson
% December 2 2022
%
% For each POES satellite, find the maximum electron flux in each MEPED
% telescope and energy band every orbit, and the times and magnetic
% latitudes at which these maxima occur.

% load POES data files
year = 2022;
month = 11;
day = 07;
% sat = "n19";

datafields = ["time"; "lat"; "lon"; "alt"; "geod_lat_foot"; "geod_lon_foot"; ...
    "mag_lat_foot"; "L_IGRF"; "MLT"; ...
    "mep_ele_tel0_flux_e2"; "mep_ele_tel0_flux_e3" ;"mep_ele_tel0_flux_e4"; ...
    "mep_ele_tel90_flux_e2"; "mep_ele_tel90_flux_e3"; "mep_ele_tel90_flux_e4"];

m01 = poesimport(year, month, day, "m01", datafields);
m03 = poesimport(year, month, day, "m03", datafields);
n15 = poesimport(year, month, day, "n15", datafields);
n18 = poesimport(year, month, day, "n18", datafields);
n19 = poesimport(year, month, day, "n19", datafields);
% poes= poesimport(year, month, day, sat, datafields);

poes.time = [m01.time; m03.time; n15.time; n18.time; n19.time];
poes.mag_lat_foot = [m01.mag_lat_foot; m03.mag_lat_foot; n15.mag_lat_foot; n18.mag_lat_foot; n19.mag_lat_foot];
poes.mep_ele_tel0_flux_e2 = [m01.mep_ele_tel0_flux_e2; m03.mep_ele_tel0_flux_e2; n15.mep_ele_tel0_flux_e2; n18.mep_ele_tel0_flux_e2; n19.mep_ele_tel0_flux_e2];
poes.mep_ele_tel0_flux_e3 = [m01.mep_ele_tel0_flux_e3; m03.mep_ele_tel0_flux_e3; n15.mep_ele_tel0_flux_e3; n18.mep_ele_tel0_flux_e3; n19.mep_ele_tel0_flux_e3];
poes.mep_ele_tel0_flux_e4 = [m01.mep_ele_tel0_flux_e4; m03.mep_ele_tel0_flux_e4; n15.mep_ele_tel0_flux_e4; n18.mep_ele_tel0_flux_e4; n19.mep_ele_tel0_flux_e4];
poes.mep_ele_tel90_flux_e2 = [m01.mep_ele_tel90_flux_e2; m03.mep_ele_tel90_flux_e2; n15.mep_ele_tel90_flux_e2; n18.mep_ele_tel90_flux_e2; n19.mep_ele_tel90_flux_e2];
poes.mep_ele_tel90_flux_e3 = [m01.mep_ele_tel90_flux_e3; m03.mep_ele_tel90_flux_e3; n15.mep_ele_tel90_flux_e3; n18.mep_ele_tel90_flux_e3; n19.mep_ele_tel90_flux_e3];
poes.mep_ele_tel90_flux_e4 = [m01.mep_ele_tel90_flux_e4; m03.mep_ele_tel90_flux_e4; n15.mep_ele_tel90_flux_e4; n18.mep_ele_tel90_flux_e4; n19.mep_ele_tel90_flux_e4];


% get non-equatorial northern-hemisphere indices
noneq = poes.mag_lat_foot > 45;
time_noneq = poes.time(noneq);
mlat_noneq = poes.mag_lat_foot(noneq);
e2_0_noneq = poes.mep_ele_tel0_flux_e2(noneq);
e3_0_noneq = poes.mep_ele_tel0_flux_e3(noneq);
e4_0_noneq = poes.mep_ele_tel0_flux_e4(noneq);

% moving average of electron fluxes
% data cadence: 0.5 Hz --> 5-point moving mean has 10-second window
% mm_e2_0 = movmean(poes.mep_ele_tel0_flux_e2, 5, "omitnan");
% mm_e3_0 = movmean(poes.mep_ele_tel0_flux_e3, 5, "omitnan");
% mm_e4_0 = movmean(poes.mep_ele_tel0_flux_e4, 5, "omitnan");

mm_e2_0 = movmean(e2_0_noneq, 5, "omitnan");
mm_e3_0 = movmean(e3_0_noneq, 5, "omitnan");
mm_e4_0 = movmean(e4_0_noneq, 5, "omitnan");

% find maxima
% get indices of rising and falling magnetic latitude; find maximum
% electron flux on each channel for each rising and falling mlat window

[flux_e2_0_max, ind_e2_0_max] = findpeaks(mm_e2_0, "MinPeakDistance",120, "MinPeakProminence", 1000);
[flux_e3_0_max, ind_e3_0_max] = findpeaks(mm_e3_0, "MinPeakDistance",120, "MinPeakProminence", 500);
[flux_e4_0_max, ind_e4_0_max] = findpeaks(mm_e4_0, "MinPeakDistance",120, "MinPeakProminence", 500);

time_e2_0_max = time_noneq(ind_e2_0_max);
time_e3_0_max = time_noneq(ind_e3_0_max);
time_e4_0_max = time_noneq(ind_e4_0_max);

mlat_e2_0_max = mlat_noneq(ind_e2_0_max);
mlat_e3_0_max = mlat_noneq(ind_e3_0_max);
mlat_e4_0_max = mlat_noneq(ind_e4_0_max);


% % d/dt mlat
% mm_mlat = movmean(poes.mag_lat_foot,50,"omitnan"); % smooth latitude curve
% dmlat = zeros(size(mm_mlat));
% dmlat_previous = zeros(size(mm_mlat));
% for i = 2:length(dmlat)-1
%     dmlat(i) = mm_mlat(i) - mm_mlat(i-1);
%     dmlat_previous(i+1) = dmlat(i);
% end
% 
% % sign changes
% mlat_window_edges = sign(dmlat_previous).*sign(dmlat) ~= 1;
% mlat_northern_window_edges = find(mlat_window_edges & noneq);
% % find flux maxima, times, and mlats
% 
% flux_e2_0_max = zeros(length(mlat_northern_window_edges)-1,1);
% time_e2_0_max = zeros(length(mlat_northern_window_edges)-1,1);
% mlat_e2_0_max = zeros(length(mlat_northern_window_edges)-1,1);
% 
% for j = 2:length(mlat_northern_window_idx)
%     window = mlat_northern_window_edges(j-1):mlat_northern_window_edges(j);
%     e2_window = poes.mep_ele_tel0_flux_e2(window);
%     time_window = poes.time(window);
%     mlat_window = poes.mag_lat_foot(window);
%     [flux_e2_0_max(j),maxind] = max(e2_window,[], "omitnan");
%     time_e2_0_max(j) = time_window(maxind);
%     mlat_e2_0_max(j) = mlat_window(maxind);
% 
% end
%% plot

colors = crameri('-lajolla', 5);
colors = colors(2:end-1, :);

figure(1)
t1 = tiledlayout(5,1,"TileSpacing","compact");
nexttile([2 1])
hold off
semilogy(datetime(poes.time, "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e2, '-', "Color",[0.8 0.8 0.8]);
hold on
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e2(noneq), '.', "Color",colors(1,:));
% semilogy(datetime(time_noneq, "ConvertFrom", "datenum"), mm_e2_0, '^', "Color",colors(1,:));
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e3(noneq), '.', "Color",colors(2,:));
% semilogy(datetime(time_noneq, "ConvertFrom", "datenum"), mm_e3_0, '^', "Color",colors(2,:));
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e4(noneq), '.', "Color",colors(3,:));
% semilogy(datetime(time_noneq, "ConvertFrom", "datenum"), mm_e4_0, '^', "Color",colors(3,:));

semilogy(datetime(time_e2_0_max, "ConvertFrom", "datenum"), flux_e2_0_max, '*', "Color",colors(1,:));
semilogy(datetime(time_e3_0_max, "ConvertFrom", "datenum"), flux_e3_0_max, '*', "Color",colors(2,:));
semilogy(datetime(time_e4_0_max, "ConvertFrom", "datenum"), flux_e4_0_max, '*', "Color",colors(3,:));


ylabel("0 degree electron flux")

nexttile([2 1])
hold off
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel90_flux_e2(noneq), '.', "Color",colors(1,:));
hold on
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel90_flux_e3(noneq), '.', "Color",colors(2,:));
semilogy(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mep_ele_tel90_flux_e4(noneq), '.', "Color",colors(3,:));
ylabel("90 degree electron flux")

nexttile
hold off
plot(datetime(poes.time, "ConvertFrom", "datenum"), poes.mag_lat_foot, '.');
hold on
plot(datetime(poes.time(noneq), "ConvertFrom", "datenum"), poes.mag_lat_foot(noneq), '.');
% plot(datetime(poes.time(mlat_northern_window_edges), "ConvertFrom", "datenum"), poes.mag_lat_foot(mlat_northern_window_edges), 'm*');
ylabel("magnetic latitude of foot point")

title(t1, "Electron fluxes with magnetic latitude")

figure(2)
hold off
semilogy(poes.mag_lat_foot, poes.mep_ele_tel0_flux_e2, '.');
hold on
semilogy(poes.mag_lat_foot, poes.mep_ele_tel0_flux_e3, '.');
semilogy(poes.mag_lat_foot, poes.mep_ele_tel0_flux_e4, '.');
ylabel("electron flux")

figure(3)
hold off
scatter(datetime(time_e2_0_max, "ConvertFrom","datenum"), mlat_e2_0_max, 10, colors(1,:), "filled");
hold on
scatter(datetime(time_e3_0_max, "ConvertFrom","datenum"), mlat_e3_0_max, 10, colors(2,:), "filled");
scatter(datetime(time_e4_0_max, "ConvertFrom","datenum"), mlat_e4_0_max, 10, colors(3,:), "filled");
ylabel("magnetic latitude (\circ)")
ylim([45 90])
legend("E2", "E3", "E4")
title("magnetic latitude of northern hemisphere peak 0-degree flux")
