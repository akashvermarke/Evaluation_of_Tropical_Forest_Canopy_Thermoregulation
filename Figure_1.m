%%%%%%%%% Fig 1 Saptial Plots with humid & dry histograms

clc; clear; close all;

%% ==== Paths ====
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');

%% ==== Load Colormaps ====
n  = load("/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Colorbars/BlueDarkRed18.rgb") ./ 255;
n2 = load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Colorbars/cmp_b2r.rgb') ./ 255;
cmap_discrete_n  = n(round(linspace(1,size(n,1),12)),:);
cmap_discrete_n2 = n2(round(linspace(1,size(n2,1),12)),:);

%% ==== Load Coastlines ====
load coastlines;

%% ==== Grid ====
latitude_era5  = (31:-0.1:-31)'; 
longitude_era5 = (-180:0.1:179.9)';
lon_indices_era5 = longitude_era5 >= -120 & longitude_era5 <= 180;
lat_indices_era5 = latitude_era5 >= -30  & latitude_era5 <= 30;
latitude_era5  = latitude_era5(lat_indices_era5);
longitude_era5 = longitude_era5(lon_indices_era5);

%% ==== Load Data ====
file_types = {'lst','ta','rn','lh','sh'};
for i = 1:length(file_types)
    type = file_types{i};
    if(type<3)
        file_list = dir([type, '*itmax_hr_masked_mid_nph_p05.mat']);
    else
        file_list = dir([type, '*itmax_hr_masked_nph_p05.mat']);
    end
    if ~isempty(file_list)
        load(file_list(1).name);
    else
        error('Missing file for type: %s', type);
    end
end

load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/forest_aridity_correct.mat')
load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph/beta_tmax_all_months_years_nph.mat'); 

%% ==== Figure Settings ====
fontName = 'Arial';
fontSize = 14;
cbarFontSize = 12;
coastLineWidth = 1.2;
cmap1 = cmap_discrete_n;
cmap2 = cmap_discrete_n2;

%% ==== Prepare Variables ====
var1 = squeeze(lst_hourly_mean_all(lon_indices_era5,:,:)) - squeeze(ta_hourly_mean_all(lon_indices_era5,:,:));
var_beta = squeeze(beta_tmax(lon_indices_era5,:,:));
var2 = squeeze(rn_hourly_mean_all(lon_indices_era5,:,:));
var3 = squeeze(lh_hourly_mean_all(lon_indices_era5,:,:));
var4 = squeeze(sh_hourly_mean_all(lon_indices_era5,:,:));

var_list = {var1, var_beta, var2, -var3, -var4};
titles_map = {'(a) LST - T_{air} (°C)', '(b) \beta', '(c) R_n (W m^{-2})', '(d) LH (W m^{-2})', '(e) SH (W m^{-2})'};
caxis_list = {[-3 3], [0.5 1.5], [0 650], [0 400], [0 300]};
colormap_list = {cmap1, cmap1, cmap2, cmap2, cmap2};

%% ==== Create Figure ====
figure('Color','w','Position',[100 100 1400 2200]);

for i = 1:5
    %% ---------- Spatial Map ----------
    ax_map = subplot(5,2,(i-1)*2+1);
    data_map = var_list{i};
    pcolor(longitude_era5, latitude_era5, (data_map .* forest_humid(lon_indices_era5,lat_indices_era5))');
    shading flat;
    colormap(ax_map, colormap_list{i});
    caxis(caxis_list{i});
    hold on; plot(coastlon, coastlat, '-k', 'LineWidth', coastLineWidth);
    title(titles_map{i}, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight','bold');
    ylabel('Latitude');
    set(ax_map,'FontName',fontName,'FontSize',fontSize,'Layer','top');
    colorbar('FontSize',cbarFontSize);
    
    %% ---------- Histogram for Humid & Dry ----------
    ax_hist = subplot(5,2,(i-1)*2+2);
    
    % Humid pixels
    data_humid = data_map(forest_humid(lon_indices_era5,lat_indices_era5) > 0);
    % Dry pixels
    data_dry = data_map(forest_dry(lon_indices_era5,lat_indices_era5) > 0);
    
    hold on;
    yyaxis left
    ax_hist.YAxis(1).Color = [0 0 0];
    ax_hist.YAxis(2).Color = [0 0 0];
    histogram(data_humid(:), 50, 'FaceColor', [167/255, 199/255, 231/255], 'EdgeColor','none', 'DisplayName','Humid');
    yyaxis right
    histogram(data_dry(:), 50, 'FaceColor', [255/255 105/255 97/255], 'EdgeColor','none', 'DisplayName','Dry'); % grey for dry
    hold off;
    
    title(['Histogram of ', titles_map{i}], 'FontName', fontName, 'FontSize', fontSize);
    xlabel('Value'); ylabel('Frequency'); grid on; box on;
    legend('Location','best');
end

%% ==== Synchronize Axes for Maps ====
for i = 1:5
    ax_map = subplot(5,2,(i-1)*2+1);
    set(ax_map,'LineWidth',0.7,'Box','on','TickDir','in','XMinorTick','on','YMinorTick','on');
end
