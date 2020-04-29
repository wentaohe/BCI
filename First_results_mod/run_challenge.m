%%
clear; clc; close all;

base_fid = {'I521_A0012', 'I521_A0013', 'I521_A0014'};
window = 100;
overlap = 40;
downsamp = 40;
hist = 6;

me = 'mlautman';
pass_file = 'mla_ieeglogin.bin';

%% Load data
data = cell(3,1);
for i = 1:3
    base = base_fid{i};
    
    tic
    disp(strcat('loading data #',int2str(i)))
    data{i} = load_data(base, me, pass_file);
    toc
    
end
%% save raw data
save('raw_data.mat', 'data');

%% Generate 1st Features
for i = 1:3
    tic
    s = 'generating features #';
    disp(strcat(s,int2str(i)))

    data{i}.train.features = gen_features(data{i}.train.ecog, window, overlap);
    data{i}.test.features = gen_features(data{i}.test.ecog, window, overlap);
    toc
    
    tic
    s ='downsampling the data labels #';
    disp(strcat(s,int2str(i)))
    
    data{i}.train.label_hist = downsample(data{i}.train.label, downsamp, hist);
    toc

end
%% save features
save('featured_data.mat', 'data');

%% add history
for i = 1:3    
    tic
    s='appending feature history #';
    disp(strcat(s,int2str(i)))
    
    data{i}.train.features_hist = add_history(data{i}.train.features, hist);
    data{i}.test.features_hist = add_history(data{i}.test.features, hist);
    toc
end
save('hist_data.mat', 'data');

%% train lasso
lasso_coeff = cell(3,5);

for i = 1:3    
    tic
    s = 'training lasso #';
    disp(strcat(s,int2str(i)))
    
    fit_info=cell(5,1);
    for j = 1:5
        [lasso_coeff{i, j}, fit_info{j}] = ...
            lasso(...
                data{i}.train.features_hist, ...
                data{i}.train.label_hist(:,j), ...
                'Lambda', .03);
    end
    toc
end
save('lasso_coeff.mat', 'lasso_coeff')

%% predict
predicted_dg = cell(3,1);

for i = 1:3
    s = 'making prediction #';
    disp(strcat(s,int2str(i)))
    
    predicted_dg{i} = zeros(size(data{i}.test.ecog,1), 5);
    for j = 1:5
        predictions = data{i}.test.features_hist * lasso_coeff{i,j};
        x = 1:length(predictions);
        xx = 1:1/downsamp:length(predictions)+1 - 1/downsamp;
        splined_pred = spline(x, predictions, xx)';
        
        if size(splined_pred,1) < size(data{i}.test.ecog,1)
            delta = size(data{i}.test.ecog,1) - size(splined_pred,1);
            resized_pred = [zeros(180,1); splined_pred];
        
        elseif size(splined_pred,1) > size(data{i}.test.ecog,1)
            delta =  size(splined_pred,1) - size(data{i}.test.ecog,1);
            resized_pred = splined_pred(delta+1:size(splined_pred,1));

        else
            resized_pred = splined_pred;
        end
        
        predicted_dg{i}(:,j) = resized_pred;
    end

end

save('predictions.mat', 'predicted_dg')