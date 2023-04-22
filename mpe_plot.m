% mpe_plot.m
% Todd Anderson
% 22 April 2023
%
% Plot precipitating electrons from the MEPED Precipitating Electron (MPE)
% dataset (Pettit et al., 2021)

% % display contents of single file
% m01_file = "data/mpe/POES_combinedSpectrum_m01_BLC_v3_20221101.nc";
% ncdisp(m01_file)

year = 2022;
month = 11;
day = 7;

datafields = ["time"; "foflLat"; "foflLon"; ...
    "lValue"; "MLT"; ...
    "energy"; "BLC_Flux" ; "BLC_Angle"];

m01 = mpeimport(year, month, day, "m01", datafields);
m03 = mpeimport(year, month, day, "m03", datafields); % change to "m02" for 2018 and earlier
n15 = mpeimport(year, month, day, "n15", datafields);
n18 = mpeimport(year, month, day, "n18", datafields);
n19 = mpeimport(year, month, day, "n19", datafields);

%% plot BLC differential flux for each energy as a function of time


ei = 12; % energy index: [1, 27]

% colormap
colors = crameri('-lajolla', 5);
colors = colors(2:end, :);

figure(1)

tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
ax1 = nexttile;
hold off
semilogy(datetime(m03.time(m03.foflLat > 40),"ConvertFrom", "datenum"), m03.BLC_Flux(ei,m03.foflLat > 40), '.');
hold on
semilogy(datetime(m01.time(m01.foflLat > 40),"ConvertFrom", "datenum"), m01.BLC_Flux(ei,m01.foflLat > 40), '.');
semilogy(datetime(n15.time(n15.foflLat > 40),"ConvertFrom", "datenum"), n15.BLC_Flux(ei,n15.foflLat > 40), '.');
semilogy(datetime(n18.time(n18.foflLat > 40),"ConvertFrom", "datenum"), n18.BLC_Flux(ei,n18.foflLat > 40), '.');
semilogy(datetime(n19.time(n19.foflLat > 40),"ConvertFrom", "datenum"), n19.BLC_Flux(ei,n19.foflLat > 40), '.');
ylim([1E-5 1E5]);
colororder(ax1, colors);
% legend("E2", "E3", "E4");
title("MPE BLC Flux");

ax2 = nexttile;
hold off
plot(datetime(m03.time,"ConvertFrom", "datenum"), m03.BLC_Angle, '.');
% ylim([0 90]);
% colororder(ax2, colors);
% legend("E2", "E3", "E4");
title("MPE BLC Angle");


figure(2)
hold off
semilogy(m03.lValue, m03.BLC_Flux(ei,:), '.');
hold on
semilogy(m01.lValue, m01.BLC_Flux(ei,:), '.');
semilogy(n15.lValue, n15.BLC_Flux(ei,:), '.');
semilogy(n18.lValue, n18.BLC_Flux(ei,:), '.');
semilogy(n19.lValue, n19.BLC_Flux(ei,:), '.');
ylim([1E-5 1E5]);
xlim([0 20]);
colororder(colors);
% legend("E2", "E3", "E4");
title("MPE BLC Flux");