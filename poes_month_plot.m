% poes_month_plot.m
% Todd Anderson
% December 8 2022
%
% Plot whole month of POES MEPED data

quiet_days = datetime(2022, 11, [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]);

mlatrange = [50 70];
mlat_bin_width = 1;
% mlat_bin_edges =
% mlatrange(1)-(mlat_bin_width/2):mlat_bin_width:mlatrange(2)+(mlat_bin_width/2);
% % cell-registered bins
mlat_bin_edges = mlatrange(1):mlat_bin_width:mlatrange(2); % grid-registered bins

colors = crameri('-lajolla', length(mlat_bin_edges)+2);
colors = colors(2:end-2, :);

startdt = datetime(2022, 11, 01);
enddt = datetime(2022, 12, 09);

time = [];
mlat = [];
e3_0 = [];
for dayrange = startdt:enddt
    poesfile = sprintf("data/poes_combined_%s.mat", datestr(dayrange, "yyyymmdd"));
    poes = importdata(poesfile);
    
    time = cat(1, time, poes.time);
    mlat = cat(1, mlat, poes.mag_lat_foot);
    e3_0 = cat(1, e3_0, poes.mep_ele_tel0_flux_e3);
end

f = figure(6);
hold off

for i = 1:length(mlat_bin_edges)-1
        in_bin = mlat > mlat_bin_edges(i) & mlat < mlat_bin_edges(i+1);
        %e3_0_in_mlat = poes.mep_ele_tel0_flux_e3(in_bin);

        % average poes values in time bins
%         e3_0_binavg = zeros(size(timebin));
%         for j = 1:length(timebin)-1
%             in_time = poes.time > timebin(j) & poes.time < timebin(j+1);
%             e3_0_binavg(j) = mean(poes.mep_ele_tel0_flux_e3(in_bin & in_time), "omitnan");
%         end

        semilogy(datetime(time(in_bin), "ConvertFrom", "datenum"), e3_0(in_bin), '.')
        hold on
%         semilogy(datetime(timebin, "ConvertFrom", "datenum"), e3_0_binavg, "-", "Color", colors(i,:))
end

semilogy([startdt enddt], [1E4 1E4], ":r", "LineWidth", 1.5);
% for q = 1:length(quiet_days)
%     vline(quiet_days(q));
% end

h = gca;
h.ColorOrder = colors;
h.Colormap = colors;
h.FontSize = 12;
ylim([1E2 1E7])
xlim([startdt, enddt])
y = ylabel("electron flux (cm^{-2} sr^{-1} keV^{-1} s^{-1})");
y.FontSize = 12;
t = title("0-degree E3 electron flux at different magnetic latitudes, all satellites");
t.FontSize = 15;

cb = colorbar('eastoutside');
cb.Label.String = "magnetic latitude (\circ)";
tickspace = 5;
% cb.Ticks =
% ((1:tickspace:mlatrange(2)+1-mlatrange(1))-0.5)./(mlatrange(2)+1-mlatrange(1));
cb.Ticks = ((mlatrange(1):tickspace:mlatrange(2))-mlatrange(1))./(mlatrange(2)-mlatrange(1));
cb.TickLabels = mlatrange(1):tickspace:mlatrange(2);
cb.Label.FontSize = 15;
cb.FontSize = 12;