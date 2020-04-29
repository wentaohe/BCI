function norm_features = normalized_features(features)
    mean_feats = mean(features, 1);
    centered_feats = bsxfun(@minus, features, mean_feats);
    std_feats = std(centered_feats, 1);
    std_feats(std_feats==0.)=1;
    norm_features = bsxfun(@rdivide, centered_feats, std_feats);
    norm_features(:,1) = 1;
end