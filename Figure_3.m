%% Figure 3: Spatial Plot for beta

clc; clear; close all;

%% Paths
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');

% Load colormap
n = load("/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Colorbars/GMT_panoply.rgb");

% Load shapefile
load('coastlines.mat')

% Latitude and longitude arrays
latitude_era5  = (31:-0.1:-31)';
longitude_era5 = (-180:0.1:179.9)';
lon_indices_era5 = longitude_era5 >= -120 & longitude_era5 <= 180;
lat_indices_era5 = latitude_era5 >= -30 & latitude_era5 <= 30;
latitude_era5  = latitude_era5(lat_indices_era5);
longitude_era5 = longitude_era5(lon_indices_era5);

% File list
file_list = dir('beta_itmax_hr_masked_nph_*.mat');
[~, order] = sort(str2double(regexp({file_list.name}, '\d+', 'match', 'once')));
file_list = file_list(order);

% Aridity mask
load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/forest_aridity_correct.mat')

% Months labels
months = {'(a) January','(b) February','(c) March','(d) April','(e) May','(f) June',...
          '(g) July','(h) August','(i) September','(j) October','(k) November','(l) December'};

%% Figure aesthetics
fig = figure('Color','w','Position',[100 100 1600 650]);

% Subplot grid (4 rows x 3 columns)
nRows = 4; nCols = 3;
hspace = 0.02; vspace = 0.04;
subplot_width  = (1 - (nCols+1)*hspace)/nCols;
subplot_height = (1 - (nRows+2)*vspace - 0.11); % reduce height to leave room for colorbar
subplot_height = subplot_height/nRows;

n_colors = 10;  % Use 10 discrete colors

for i = 1:12
    % Compute subplot position
    col = mod(i-1,nCols)+1;
    row = nRows - floor((i-1)/nCols);
    left = hspace + (col-1)*(subplot_width+hspace) + 0.015;
    bottom = vspace + (row-1)*(subplot_height+vspace) + 0.13; 
    ax = axes('Position',[left bottom subplot_width subplot_height]);

    % Load data
    fname = file_list(i).name;
    load(fname);  % variable: beta_tmax

    % Apply mask
    data = beta_tmax(lon_indices_era5,:).*forest_humid(lon_indices_era5,lat_indices_era5);
    data(data==0) = nan;

    % Plot
    pcolor(ax, longitude_era5, latitude_era5, data'); 
    shading(ax,'flat');

    % Discretized colormap
    idx = round(linspace(1, size(n,1), n_colors));
    cmap_discrete = n(idx,:);
    colormap(ax, cmap_discrete);
    caxis([0.5 1.5]);

    % Coastlines
    hold(ax,'on');
    plot(ax, coastlon, coastlat, 'k','LineWidth',0.6);

    % Axes formatting
    set(ax,'XTick',-120:60:180,'YTick',-30:10:30);
    axis(ax,[-120 180 -30 30])
    box(ax,'on')

    % Hide redundant tick labels
    if row~=1, set(ax,'XTickLabel',[]); end
    if col~=1, set(ax,'YTickLabel',[]); end

    % Axis labels
    if col==1
        ylabel(ax,'Latitude','FontSize',10,'FontName','Arial');
    end
    if row==1
        xlabel(ax,'Longitude','FontSize',10,'FontName','Arial');
    end

    % Title
    title(ax,months{i},'FontSize',10,'FontWeight','bold','FontName','Arial');
    set(ax,'FontName','Arial','FontSize',10,'Layer','top','LineWidth',0.8);

end

%% Colorbar below all plots
cb = colorbar('Position',[0.25 0.07 0.5 0.02],'Orientation','horizontal');
cb.Label.String = 'β_{Tmax}';
cb.Label.FontSize = 10;
cb.FontSize = 10;  
cb.Label.FontWeight = 'normal';
cb.Label.FontName = 'Arial';
cb.Label.FontAngle = 'italic';
cb.Ticks = linspace(0.5,1.5,11);
cb.TickDirection = 'out';

set(gcf,'Renderer','painters'); 

