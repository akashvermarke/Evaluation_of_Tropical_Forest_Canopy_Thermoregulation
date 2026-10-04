%% Figure 5: EF vs LST-Tair

clc; clear; close all;

% Change directory and load data
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');
load('lst_ta_ef_ts_nph.mat');

% Data preparation (daily medians)
x(:,1) = daily_median_dT_dry;     y(:,1) = daily_median_EF_dry;
x(:,2) = daily_median_dT_humid;   y(:,2) = daily_median_EF_humid;

forest_types = {'(a) Dry','(b) Humid'};
marker_size  = 28;
fontname     = 'Arial';

% Axis limits
x_all    = x(:);
x_all    = x_all(~isnan(x_all));
axis_lims = [min(x_all)-1, max(x_all)+1];
ef_lims   = [0, 1];

figure('Position',[100,100,1300,600],'Color','w');

for f = 1:2
    subplot(1,2,f);
    valid_w = ~isnan(x(:,f)) & ~isnan(y(:,f));
    x1 = x(valid_w,f);
    y1 = y(valid_w,f);
    hold on;
    if numel(x1) > 10
        % Density-based coloring
        f1  = ksdensity([x1 y1],[x1 y1]);
        f1n = (f1 - min(f1)) / (max(f1) - min(f1));
        f1n = f1n.^0.6;

        cmap = parula(256);
        color_idx = max(1, round(f1n * 255) + 1);
        scatter(x1,y1,marker_size,cmap(color_idx,:), ...
            'filled','MarkerFaceAlpha',0.7,'MarkerEdgeAlpha',0.15);
    else
        scatter(x1,y1,marker_size,[0 0.4470 0.7410],'filled');
    end


    % Identity line (y = x)
    xline(0,'--k','LineWidth',1.8);

    % Axes & labels
    set(gca,'FontSize',12,'FontName',fontname,'LineWidth',1, ...
        'TickDir','in','Box','on','Layer','top','GridAlpha',0.15,'MinorGridAlpha',0.25);
    xlabel('LST - T_{air} (°C)','FontSize',14,'FontName',fontname);
    ylabel('EF','FontSize',14,'FontName',fontname);
    title(forest_types{f},'FontSize',16,'FontWeight','bold','FontName',fontname);

    xlim([-3 3])
    ylim(ef_lims);
    axis square;
   
end

set(gcf,'Renderer','painters'); 
