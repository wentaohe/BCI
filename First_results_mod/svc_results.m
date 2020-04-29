function svc_pred = svc_results(Xtrain, Ytrain, Xtest, Ytest)
    svm1 = svmtrain(Ytrain(:,1),Xtrain, '-s 0 -t 2 -g .01 -d 10 -c 100.5 -q');
    [pred1, acc1, dv]   = svmpredict(Ytest, Xtest, svm1)
%     svm1 = svmtrain(Ytrain(:,1),Xtrain, '-s 0 -t 2 -g .01 -d 10 -c 100.5 -q');
%     [pred1, acc1, dv]   = svmpredict(Ytest, Xtest, svm1);

end
