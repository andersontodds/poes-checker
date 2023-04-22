% mlat_poes_flux.m
% Todd Anderson
% December 3 2022
%
% Find mean POES electron flux at different magnetic latitude bins

% load POES data and concatenate different satellites into single struct
% load POES data files
year = 2022;
month = 11;
% day = 01;

for day = 1%:30

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
    poes.L_IGRF = [m01.L_IGRF; m03.L_IGRF; n15.L_IGRF; n18.L_IGRF; n19.L_IGRF];
    poes.MLT = [m01.MLT; m03.MLT; n15.MLT; n18.MLT; n19.MLT];
    poes.mep_ele_tel0_flux_e2 = [m01.mep_ele_tel0_flux_e2; m03.mep_ele_tel0_flux_e2; n15.mep_ele_tel0_flux_e2; n18.mep_ele_tel0_flux_e2; n19.mep_ele_tel0_flux_e2];
    poes.mep_ele_tel0_flux_e3 = [m01.mep_ele_tel0_flux_e3; m03.mep_ele_tel0_flux_e3; n15.mep_ele_tel0_flux_e3; n18.mep_ele_tel0_flux_e3; n19.mep_ele_tel0_flux_e3];
    poes.mep_ele_tel0_flux_e4 = [m01.mep_ele_tel0_flux_e4; m03.mep_ele_tel0_flux_e4; n15.mep_ele_tel0_flux_e4; n18.mep_ele_tel0_flux_e4; n19.mep_ele_tel0_flux_e4];
    poes.mep_ele_tel90_flux_e2 = [m01.mep_ele_tel90_flux_e2; m03.mep_ele_tel90_flux_e2; n15.mep_ele_tel90_flux_e2; n18.mep_ele_tel90_flux_e2; n19.mep_ele_tel90_flux_e2];
    poes.mep_ele_tel90_flux_e3 = [m01.mep_ele_tel90_flux_e3; m03.mep_ele_tel90_flux_e3; n15.mep_ele_tel90_flux_e3; n18.mep_ele_tel90_flux_e3; n19.mep_ele_tel90_flux_e3];
    poes.mep_ele_tel90_flux_e4 = [m01.mep_ele_tel90_flux_e4; m03.mep_ele_tel90_flux_e4; n15.mep_ele_tel90_flux_e4; n18.mep_ele_tel90_flux_e4; n19.mep_ele_tel90_flux_e4];
    
%     % save combined data file
%     poesfile = sprintf("data/poes_combined_%04g%02g%02g.mat", year, month, day);
%     save(poesfile, "poes");

%     % define mlat bins
%     mlatrange = [50 70];
%     mlat_bin_edges = mlatrange(1):mlat_bin_width:mlatrange(2); % grid-registered bins
% 
% 
%     % define time bins for averaging
%     timebin = linspace(datenum(year, month, day), datenum(year, month, day+1), 145);
%     timebin = timebin';
% 
%     colors = crameri('-lajolla', length(mlat_bin_edges)+2);
%     colors = colors(2:end-2, :);
%     
%     figure(5)
%     hold off
%     
%     % get the subset of POES time series made in each mlat bin
%     for i = 1:length(mlat_bin_edges)-1
% %         in_bin = round(poes.mag_lat_foot) == mlatrange(i);
%         in_bin = poes.mag_lat_foot > mlat_bin_edges(i) & poes.mag_lat_foot < mlat_bin_edges(i+1);
%         e3_ratio = poes.mep_ele_tel0_flux_e3(in_bin)./poes.mep_ele_tel90_flux_e3(in_bin);
% 
%         % average poes values in time bins
% %         e3_0_binavg = zeros(size(timebin));
% %         for j = 1:length(timebin)-1
% %             in_time = poes.time > timebin(j) & poes.time < timebin(j+1);
% %             e3_0_binavg(j) = mean(poes.mep_ele_tel0_flux_e3(in_bin & in_time), "omitnan");
% %         end
%         semilogy(datetime(poes.time(in_bin), "ConvertFrom", "datenum"), e3_ratio, '.', "Color", colors(i,:));
% %         semilogy(datetime(poes.time(in_bin), "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e3(in_bin), '.', "Color", colors(i,:));
%         hold on
% %         semilogy(datetime(timebin, "ConvertFrom", "datenum"), e3_0_binavg, "-", "Color", colors(i,:))
%     end
%     
% %     ylim([1E2 1E7])
%     ylabel("electron flux (cm^{-2} sr^{-1} keV^{-1} s^{-1})")
%     cb = colorbar("eastoutside");
%     cb.Colormap = colors;
%     caxis([mlatrange(1) mlatrange(end)]);
%     cb.Label.String = "magnetic latitude (\circ)";
% 
%     title("0-degree E3 electron flux at different magnetic latitudes, all satellites")
%     
%     figname = sprintf("figures/poes_e3_0_mlat_%04g%02g%02g.jpg", year, month, day);
% %     saveas(gcf, figname);

end
