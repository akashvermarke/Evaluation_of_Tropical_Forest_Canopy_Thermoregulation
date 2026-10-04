%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 7: Leaf Size vs LST-Tair Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% ==== Paths ====
cd('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph');

%% ==== Load Coastlines ====
load coastlines

%% ==== ERA5 Grid ====
latitude_era5  = (31:-0.1:-31)';
longitude_era5 = (-180:0.1:179.9)';

lon_indices_era5 = longitude_era5 >= -120 & longitude_era5 <= 180;
lat_indices_era5 = latitude_era5  >= -30  & latitude_era5  <= 30;

latitude_era5  = latitude_era5(lat_indices_era5);
longitude_era5 = longitude_era5(lon_indices_era5);

%% ==== Load Climate Data ====
file_types = {'lst','ta','rn','lh','sh'};

for i = 1:length(file_types)

    type = file_types{i};

    if i < 3
        file_list = dir([type '*itmax_hr_masked_mid_nph_p05.mat']);
    else
        file_list = dir([type '*itmax_hr_masked_nph_p05.mat']);
    end

    if ~isempty(file_list)
        load(file_list(1).name)
    else
        error(['Missing file for ' type])
    end
end

%% ==== Load Supporting Data ====
load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/forest_aridity_correct.mat')
load('/Users/averma2/Library/CloudStorage/OneDrive-ImperialCollegeLondon/PostDoc/Manuscript/manuscript_nph/data_nph/beta_tmax_all_months_years_nph.mat')

%% ==== Prepare Variables ====
% Assumes climate data are already cropped consistently

var_lst_ta = squeeze(lst_hourly_mean_all(lon_indices_era5,:,:)) ...
           - squeeze(ta_hourly_mean_all(lon_indices_era5,:,:));

var_beta   = squeeze(beta_tmax(lon_indices_era5,:,:));

% If still 3D, average over third dimension
if ndims(var_lst_ta) == 3
    var_lst_ta = mean(var_lst_ta, 3, 'omitnan');
end

if ndims(var_beta) == 3
    var_beta = mean(var_beta, 3, 'omitnan');
end

%% ======================================================================
%% LOAD LEAF SIZE DATA
%% ======================================================================

leaf_tbl = readtable('aal4760-wright-sm_data_set_s1.xlsx', ...
                     'Sheet', 'Global leaf size dataset', ...
                     'VariableNamingRule', 'preserve');

leaf_size = leaf_tbl.("Leaf size (cm2)");
lat_leaf  = leaf_tbl.Latitude;
lon_leaf  = leaf_tbl.Longitude;

%% Remove missing data
valid = ~isnan(leaf_size) & ~isnan(lat_leaf) & ~isnan(lon_leaf);

leaf_size = leaf_size(valid);
lat_leaf  = lat_leaf(valid);
lon_leaf  = lon_leaf(valid);

%% Convert longitude to ERA5 convention if needed
lon_leaf(lon_leaf < -180) = lon_leaf(lon_leaf < -180) + 360;
lon_leaf(lon_leaf > 180)  = lon_leaf(lon_leaf > 180)  - 360;

%% Remove non-positive leaf sizes before log transform
valid_pos = leaf_size > 0;
leaf_size = leaf_size(valid_pos);
lat_leaf  = lat_leaf(valid_pos);
lon_leaf  = lon_leaf(valid_pos);

%% Log-transform leaf size
leaf_size_log = log10(leaf_size);

%% Keep only points inside ERA5 cropped domain
in_domain = lon_leaf >= min(longitude_era5) & lon_leaf <= max(longitude_era5) & ...
            lat_leaf >= min(latitude_era5)  & lat_leaf <= max(latitude_era5);

leaf_size_log = leaf_size_log(in_domain);
leaf_size     = leaf_size(in_domain);
lat_leaf      = lat_leaf(in_domain);
lon_leaf      = lon_leaf(in_domain);

%% ======================================================================
%% MATCH LEAF SITES TO ERA5 GRID
%% ======================================================================

n_sites = numel(leaf_size_log);

lon_idx_all  = nan(n_sites,1);
lat_idx_all  = nan(n_sites,1);
lst_ta_sites = nan(n_sites,1);
beta_sites   = nan(n_sites,1);

for i = 1:n_sites

    % nearest ERA5 longitude
    [~, lon_idx] = min(abs(longitude_era5 - lon_leaf(i)));

    % nearest ERA5 latitude
    [~, lat_idx] = min(abs(latitude_era5 - lat_leaf(i)));

    lon_idx_all(i) = lon_idx;
    lat_idx_all(i) = lat_idx;

    % IMPORTANT:
    % This assumes var_lst_ta and var_beta are ordered as (lon, lat)
    lst_ta_sites(i) = var_lst_ta(lon_idx, lat_idx);
    beta_sites(i)   = var_beta(lon_idx, lat_idx);
end

%% Remove rows where climate is missing
valid2 = ~isnan(lst_ta_sites) & ~isnan(beta_sites) & ...
         ~isnan(lon_idx_all)  & ~isnan(lat_idx_all);

leaf_size_log = leaf_size_log(valid2);
leaf_size     = leaf_size(valid2);
lat_leaf      = lat_leaf(valid2);
lon_leaf      = lon_leaf(valid2);
lst_ta_sites  = lst_ta_sites(valid2);
beta_sites    = beta_sites(valid2);
lon_idx_all   = lon_idx_all(valid2);
lat_idx_all   = lat_idx_all(valid2);

%% ======================================================================
%% AGGREGATE BY ERA5 GRID CELL
%% ======================================================================

cell_id = [lon_idx_all, lat_idx_all];
[unique_cells, ~, ic] = unique(cell_id, 'rows');

n_cells = size(unique_cells, 1);

leaf_mean_cell = nan(n_cells,1);
lst_ta_cell    = nan(n_cells,1);
beta_cell      = nan(n_cells,1);
n_leaf_cell    = nan(n_cells,1);
lon_cell       = nan(n_cells,1);
lat_cell       = nan(n_cells,1);

for j = 1:n_cells

    ii = (ic == j);

    % mean log10 leaf size per grid cell
    leaf_mean_cell(j) = mean(leaf_size_log(ii), 'omitnan');

    % climate values for that grid cell
    idx_first = find(ii, 1, 'first');
    lst_ta_cell(j) = lst_ta_sites(idx_first);
    beta_cell(j)   = beta_sites(idx_first);

    % number of leaf records in the cell
    n_leaf_cell(j) = sum(ii);

    % grid-cell centre
    lon_cell(j) = longitude_era5(unique_cells(j,1));
    lat_cell(j) = latitude_era5(unique_cells(j,2));
end

%% Valid cells
valid_cell = ~isnan(leaf_mean_cell) & ~isnan(lst_ta_cell) & ~isnan(beta_cell);

x_lst  = lst_ta_cell(valid_cell);
x_beta = beta_cell(valid_cell);
y_leaf = leaf_mean_cell(valid_cell);

%% STATISTICS

% ----- Correlations: LST-Tair vs leaf size -----
[r_lst_p, p_lst_p] = corr(x_lst, y_leaf, 'rows', 'complete', 'type', 'Pearson');
[r_lst_s, p_lst_s] = corr(x_lst, y_leaf, 'rows', 'complete', 'type', 'Spearman');

% ----- Correlations: beta vs leaf size -----
[r_beta_p, p_beta_p] = corr(x_beta, y_leaf, 'rows', 'complete', 'type', 'Pearson');
[r_beta_s, p_beta_s] = corr(x_beta, y_leaf, 'rows', 'complete', 'type', 'Spearman');

%%  LINEAR REGRESSIONS


mdl_lst  = fitlm(x_lst,  y_leaf);
mdl_beta = fitlm(x_beta, y_leaf);

R2_lst      = mdl_lst.Rsquared.Ordinary;
R2_beta     = mdl_beta.Rsquared.Ordinary;
R2adj_lst   = mdl_lst.Rsquared.Adjusted;
R2adj_beta  = mdl_beta.Rsquared.Adjusted;

pfit_lst  = mdl_lst.Coefficients.pValue(2);
pfit_beta = mdl_beta.Coefficients.pValue(2);

%% ======================================================================
%% PLOTS
%% ======================================================================

figure('color','w','Position',[100 100 1100 450])

% ----------------------------------------------------------------------
% Panel 1: LST-Tair vs leaf size
% ----------------------------------------------------------------------
subplot(1,2,1)

scatter(x_lst, y_leaf, 50, 'filled', ...
    'MarkerFaceColor', [0.2 0.4 0.7], ...
    'MarkerFaceAlpha', 0.8)
hold on

% regression line
xfit1 = linspace(min(x_lst), max(x_lst), 200)';
yfit1 = predict(mdl_lst, xfit1);
plot(xfit1, yfit1, 'k-', 'LineWidth', 2)

xlabel('LST - T_{air} (°C)')
ylabel('log_{10}(Mean leaf size [cm^2])')
title('LST - T_{air} vs leaf size')
grid on
box on

text(0.05, 0.95, ...
    sprintf('r = %.2f\np = %.3g\nR^2 = %.2f', r_lst_p, p_lst_p, R2_lst), ...
    'Units', 'normalized', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 11, ...
    'BackgroundColor', 'w', ...
    'EdgeColor', [0.7 0.7 0.7])

% ----------------------------------------------------------------------
% Panel 2: beta vs leaf size
% ----------------------------------------------------------------------
subplot(1,2,2)

scatter(x_beta, y_leaf, 50, 'filled', ...
    'MarkerFaceColor', [0.2 0.6 0.3], ...
    'MarkerFaceAlpha', 0.8)
hold on

% regression line
xfit2 = linspace(min(x_beta), max(x_beta), 200)';
yfit2 = predict(mdl_beta, xfit2);
plot(xfit2, yfit2, 'k-', 'LineWidth', 2)

xlabel('\beta')
ylabel('log_{10}(Mean leaf size [cm^2])')
title('\beta vs leaf size')
grid on
box on

text(0.05, 0.95, ...
    sprintf('r = %.2f\np = %.3g\nR^2 = %.2f', r_beta_p, p_beta_p, R2_beta), ...
    'Units', 'normalized', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 11, ...
    'BackgroundColor', 'w', ...
    'EdgeColor', [0.7 0.7 0.7])
