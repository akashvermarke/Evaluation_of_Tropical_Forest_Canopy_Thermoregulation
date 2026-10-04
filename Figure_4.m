%% Figure 4: Diurnal Pattern
clc; clear; close all
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');
load('lst_ta_dirunal_ts_nph.mat')

hours = 1:24;
titles = {'(a) Dry','(b) Humid'};
colors = parula(24);

ta_all  = {spatial_median_ta_dry, spatial_median_ta_humid};
lst_all = {spatial_median_lst_dry, spatial_median_lst_humid};

%% Plot
fig = figure('Units','inches','Position',[1 1 10 4.5],'Color','w');

for i = 1:2
    subplot(1,2,i); hold on
    set(gca,'FontSize',12,'LineWidth',1,'Box','on','TickDir','in')
    prev_ta = NaN; prev_lst = NaN;

    % Determine axis limits dynamically so spread fits inside
    lst_min = min(lst_all{i}) - 1;
    lst_max = max(lst_all{i}) + 1;
    ta_min  = min(ta_all{i}) - 1;
    ta_max  = max(ta_all{i}) + 1;
    for h = hours
        ta_h  = ta_all{i}(h);
        lst_h = lst_all{i}(h);


        % Median point
        scatter(ta_h,lst_h,100,colors(h,:),'filled','MarkerEdgeColor','k');

        % Connect median points with thick hysteresis line
        if h > 1
            plot([prev_ta ta_h],[prev_lst lst_h],'Color',colors(h,:),'LineWidth',2);
            quiver(prev_ta,prev_lst,ta_h-prev_ta,lst_h-prev_lst,0,...
                'Color',colors(h,:),'MaxHeadSize',1.0,'LineWidth',2);
        end
        prev_ta = ta_h; prev_lst = lst_h;
    end

    % 1:1 line (45°)
    lims = [min(ta_min,lst_min) max(ta_max,lst_max)];
    plot(lims,lims,'k--','LineWidth',1);

    % Regression line + R²
    p = polyfit(ta_all{i}, lst_all{i},1);    yfit = polyval(p,lims);
    plot(lims,yfit,'k-','LineWidth',1);
    resid = lst_all{i}-polyval(p,ta_all{i});

    xlabel(['T_{air} (' char(176) 'C)'],'FontSize',12,'FontWeight','normal');
    ylabel(['LST (' char(176) 'C)'],'FontSize',12,'FontWeight','normal','FontName','Arial');
    title(titles{i},'FontSize',12,'FontWeight','bold');

    annotation_str = sprintf('β_{diurnal} = %.2f',p(1));
    text(0.05,0.9,annotation_str,'Units','normalized',...
        'FontSize',12,'FontWeight','normal','BackgroundColor','w','Margin',4,'FontName','Arial');

    % Axis equal for 45° line
    axis equal
    xlim(lims); ylim(lims);

    % X/Y ticks
    xticks(round(lims(1)):2:round(lims(2)));
    yticks(round(lims(1)):2:round(lims(2)));
end

%% Shared colorbar
colormap(parula(24));
caxis([1 24]);
cb = colorbar('Position',[0.93 0.2 0.02 0.6]);
cb.Ticks = [1 6 12 18 24];
cb.TickLabels = {'1','6','12','18','24'};
cb.Label.String = 'Hour of Day';
cb.FontSize = 12;
cb.FontName = 'Arial';
cb.Label.FontSize = 12;
%cb.Label.FontWeight = 'bold';

set(gcf,'Renderer','painters');        % stable vector renderer
set(gcf,'PaperPositionMode','auto');   % keep on-screen size
set(gcf,'InvertHardcopy','off');       % keep white background

