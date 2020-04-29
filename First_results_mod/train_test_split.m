function [Xtrain, Ytrain, Xtest, Ytest, Xlo, Ylo] = train_test_split(X, Y, split, randomize)
[n, ~] = size(X);

if randomize
    perm = randperm(n); 
else
    perm = 1:n;
end

split_i = floor(n * split);

% X
X_shuff = X(perm, :);
Xtrain = X_shuff(1:split_i-1, :);
Xtest = X_shuff(split_i:n, :);
Xlo = Xtest(1:2:size(Xtest,1),:);
Xtest = Xtest(2:2:size(Xtest,1), :);


% Y 
Y_shuff = Y(perm, :);
Ytrain = Y_shuff(1:split_i-1, :);
Ytest = Y_shuff(split_i:n, :);
Ylo = Ytest(1:2:size(Ytest,1),:);
Ytest = Ytest(2:2:size(Ytest,1), :);
end