%% Figure 6: LST vs Tair relation
% 
% 1. absolute values

clc; clear; close all;
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');

load('lst_ta_ts_nph.mat');

x(:,1) = daily_median_ta_dry;     y(:,1) = daily_median_lst_dry;
x(:,2) = daily_median_ta_humid;   y(:,2) = daily_median_lst_humid;

forest_types = {'(a) Dry', '(b) Humid'};
axis_lims = {[18 35], [25 32]};   % different limits for dry & humid

marker_size = 20;
fontname = 'Arial';

figure('Position',[100,100,1200,600],'Color','w');

for f = 1:2
    subplot(1,2,f);
    valid_w = ~isnan(x(:,f)) & ~isnan(y(:,f));
    x1 = x(valid_w,f);
    y1 = y(valid_w,f);
    hold on;

    if numel(x1) > 10
        % Density-based coloring
        f1 = ksdensity([x1 y1],[x1 y1]);  % density at each point
        f1n = (f1 - min(f1)) / (max(f1) - min(f1)); % normalize
        f1n = f1n.^0.6; % enhance contrast

        cmap = parula(256);
        % Map normalized density to colormap indices
        color_idx = max(1, round(f1n * 255) + 1);
        scatter(x1,y1,marker_size,cmap(color_idx,:), ...
            'filled','MarkerFaceAlpha',0.7,'MarkerEdgeAlpha',0.2);
    else
        scatter(x1,y1,marker_size,[0 0.4470 0.7410],'filled');
    end

    % Identity line
    plot(axis_lims{f},axis_lims{f},'--k','LineWidth',1.2);

    % Regression line
    if numel(x1) > 2
        p_w = polyfit(x1,y1,1);
        plot(axis_lims{f},polyval(p_w,axis_lims{f}),'-','Color','k','LineWidth',2);

        annotation_str = sprintf('β_{Tmax} = %.2f',p_w(1));
        text(0.05,0.9,annotation_str,'Units','normalized',...
            'FontSize',14,'FontWeight','normal','BackgroundColor','w','Margin',4,'FontName','Arial');


    end

    % Axes & labels
    set(gca,'FontSize',12,'FontName',fontname,'LineWidth',1, ...
        'TickDir','in','Box','on');
    xlabel('T_{air} (°C)','FontSize',14,'FontName',fontname);
    ylabel('LST (°C)','FontSize',14,'FontName',fontname);
    title(forest_types{f},'FontSize',16,'FontWeight','bold','FontName',fontname);

    xlim(axis_lims{f}); ylim(axis_lims{f}); axis square;
end

% Improve layout spacing
set(gcf,'Renderer','painters'); % vector-friendly for .eps export


%% Figure 6: 
% 
% 2. anomalies

clc; clear; 
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');

load('lst_ta_ts_nph.mat');

x1 = daily_median_ta_dry;     y1 = daily_median_lst_dry;
x2 = daily_median_ta_humid;   y2 = daily_median_lst_humid;

% Identify leap days (day-of-year 60 on leap years)
t = datetime(2015,1,1) + days(0:numel(x1)-1);   % construct time axis
isLeapDay = (month(t) == 2 & day(t) == 29);

% Number of years
nyears = 9;
ndays  = 365;

% Function to compute anomalies (remove leap days → reshape to 365 × nyears)
compute_anom = @(data) ...
    reshape(data(~isLeapDay), ndays, nyears) - ...
    mean(reshape(data(~isLeapDay), ndays, nyears), 2, 'omitnan');

% Compute anomalies
x1_anom = compute_anom(x1);
y1_anom = compute_anom(y1);
x2_anom = compute_anom(x2);
y2_anom = compute_anom(y2);

% Data prep
x(:,1) = x1_anom(:);
y(:,1) = y1_anom(:);
x(:,2) = x2_anom(:);
y(:,2) = y2_anom(:);

forest_types = {'(a) Dry', '(b) Humid'};
axis_lims = {[-7 7], [-3 3]};   % different limits for dry & humid
marker_size = 20;
fontname = 'Arial';

figure('Position',[100,100,1200,600],'Color','w');

for f = 1:2
    subplot(1,2,f);
    valid_w = ~isnan(x(:,f)) & ~isnan(y(:,f));
    x1 = x(valid_w,f);
    y1 = y(valid_w,f);
    hold on;

    if numel(x1) > 10
        % Density-based coloring
        f1 = ksdensity([x1 y1],[x1 y1]);  % density at each point
        f1n = (f1 - min(f1)) / (max(f1) - min(f1)); % normalize
        f1n = f1n.^0.6; % enhance contrast

        cmap = parula(256);
        % Map normalized density to colormap indices
        color_idx = max(1, round(f1n * 255) + 1);
        scatter(x1,y1,marker_size,cmap(color_idx,:), ...
            'filled','MarkerFaceAlpha',0.7,'MarkerEdgeAlpha',0.2);
    else
        scatter(x1,y1,marker_size,[0 0.4470 0.7410],'filled');
    end

    % Identity line
    plot(axis_lims{f},axis_lims{f},'--k','LineWidth',1.2);

    % Regression line
    if numel(x1) > 2
        p_w = polyfit(x1,y1,1);
        plot(axis_lims{f},polyval(p_w,axis_lims{f}),'-','Color','k','LineWidth',2);

        annotation_str = sprintf('β_{Tmax anomalies} = %.2f',p_w(1));
        text(0.05,0.9,annotation_str,'Units','normalized',...
            'FontSize',14,'FontWeight','normal','BackgroundColor','w','Margin',4,'FontName','Arial');


    end

    % Axes & labels
    set(gca,'FontSize',12,'FontName',fontname,'LineWidth',1, ...
        'TickDir','in','Box','on');
    xlabel('T_{air} (°C)','FontSize',14,'FontName',fontname);
    ylabel('LST (°C)','FontSize',14,'FontName',fontname);
    title(forest_types{f},'FontSize',16,'FontWeight','bold','FontName',fontname);

    xlim(axis_lims{f}); ylim(axis_lims{f}); axis square;
end

% Improve layout spacing
set(gcf,'Renderer','painters');

