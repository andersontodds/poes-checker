% mlat_poes_flux.m
% Todd Anderson
% December 3 2022
%
% Find mean POES electron flux at different magnetic latitude bins

% load POES data and concatenate different satellites into single struct
% load POES data files
year = 2022;
month = 11;
day = 07;

% for day = 1:28

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
    
    % define mlat bins
    mlatrange = 50:70;
    
    colors = crameri('-lajolla', length(mlatrange)+2);
    colors = colors(2:end-1, :);
    
    figure(5)
    hold off
    
    % get the subset of POES time series made in each mlat bin
    for i = 1:length(mlatrange)
        in_bin = round(poes.mag_lat_foot) == mlatrange(i);
    
        semilogy(datetime(poes.time(in_bin), "ConvertFrom", "datenum"), poes.mep_ele_tel0_flux_e3(in_bin), '.', "Color", colors(i,:))
        hold on
    end
    
    ylim([1E2 1E7])
    ylabel("electron flux (cm^{-2} sr^{-1} keV^{-1} s^{-1})")
    title("0-degree E3 electron flux at different magnetic latitudes, all satellites")
    
    figname = sprintf("figures/poes_e3_0_mlat_%04g%02g%02g.jpg", year, month, day);
    saveas(gcf, figname);

% end
