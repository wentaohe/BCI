function [accuracy] = cross_validate(features,Labels)
% Cross Validation Function
%   Inputs are n x 5 ECoG/Label data sets, output is accuracy
%   Each block of 4000 samples = one 4 second trial


% Set up folds
numFolds % Number of folds
folds = cell(numFolds,1);
len = length(features);
foldOrder = randperm(len/4000); % Test indices in rand order

for i=1:10
    start = (i-1)*len/numFolds + 1; % Calclate each start index
    finish = i*len/numFolds; % Calculate each end index
    folds{i} = foldOrder(start:finish); % Assign each fold
end


% Calculate
% window = 100;
% overlap = 40;
% features = gen_features(features, window, overlap); % Get full set of features

predictions = zeros(len,5); % Results vector
for i=1:numFolds
    exclude = zeros(4000*length(folds{i}),1);
    for j=1:length(folds{i}) % Indices of all excluded samples
        exclude((j-1)*4000+1:j*4000) = (folds{i}(j)-1)*4000+1:folds{i}(j)*4000; % Get testing fold
    end
    indices = 1:len; % Index vector for all data samples
    indices(exclude) = [];  % Get training folds
    predictions(exclude,:) = predict(features(indices,:),Labels(indices); % Predict and return values (Needs to be written)
end


% Get Accuracy
hits = 0;
for i=1:len % For each sample prediction
    if predictions(i,:) == Labels(i,:)
        hits = hits+1;
    end
end

accuracy = hits/len;

end

