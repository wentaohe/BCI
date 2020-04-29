base = 'I521_A0012';
window = 100;
overlap = 40;
downsamp = 40;
hist = 6;

me = 'mlautman';
pass_file = 'mla_ieeglogin.bin';
tic
disp('loading data')
data = load_data(base, me, pass_file);
toc

tic
disp('generating features')
data.train.features = gen_features(data.train.ecog, window, overlap);
toc

tic
disp('appending feature history')
data.train.features_hist = add_history(data.train.features, hist);
toc
% 
% tic
% disp('normalizing features')
% data.train.norm_feat_hist = normalized_features(data.train.features_hist);
% toc

tic
disp('downsampling the training data labels')
data.train.label_hist = downsample(data.train.label, downsamp, hist);
toc

[Xtrain, Ytrain, Xtest, Ytest, Xlo, Ylo] = train_test_split(...
    data.train.features_hist, data.train.label_hist, .6, true);

tic
disp('reducing dimensionality')
data.train.low_dim = 
toc


tic
disp('linear regression')
f = linear_reg(Xtrain, Ytrain);
toc

pred = Xtest*f;
for i = 1:5
    cor(i) = corr(Ytest(:,i), pred(:,i)); 
end
cor



tic
disp('lasso');
digits=cell(5,1);
fit_info=cell(5,1);

for i = 1:5
    [digits{i}, fit_info{i}] = lasso(Xtrain, Ytrain(:,i), 'Lambda', .03);
end
toc

for i = 1:5
    pred_lasso = Xtest*digits{i};
    cor_lasso(i) = corr(Ytest(:,i), pred_lasso); 
end
disp(cor_lasso)




% svm1 = svmtrain(Ytrain(:,1),Xtrain, '-s 0 -t 2 -g .01 -c 100.5 -w0 .01');
% [pred, acc, ~ ] = svmpredict(Ytest(:,1), Xtest, svm1);
