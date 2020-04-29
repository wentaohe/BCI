function features = gen_features(signal, window, r)

[n, d] = size(signal);
new_size = ceil(n/r);
Fs = 1000;
num_feats = 4;

% Common Average Reference (CAR) filtered signal
CAR = bsxfun(@minus,signal,mean(signal,2));


% line length
LLFn = @(x) sum(abs(diff(x)));
% area
Area = @(x) sum(abs(x));
% energy
Energy = @(x) sum(x.^2);
% zero-crossings
ZX = @(x) sum(abs(diff(sign(x-mean(x)))/2));
% crest factor
crest = @(x) 0.5*(max(x)-min(x))/rms(x);


features = zeros(new_size, d * num_feats);
for j = 1:new_size
    s = (j-1) * r + 1; % Start
    e = s + window - 1; % End
    
    for i=1:d
%         snip = signal(s:min(n,e),i);

        % Local Motor Potential
        features(j, (i-1) * num_feats + 1) = mean(signal(s:min(n,e),i));

        NFFT = length(CAR(s:min(n,e),i));
        
        Y = abs(fft(CAR(s:min(n,e),i), NFFT));
        
        F = abs(((0:1/NFFT:1-1/NFFT)*Fs).'-Fs/2);
        
        features(j, (i-1) * num_feats + 2) = ...
            mean(Y(find(F>=5 & F<15)));
        
        features(j, (i-1) * num_feats + 3) = ...
            mean(Y(find(F>=20 & F<25)));
        
        features(j, (i-1) * num_feats + 4) = ...
            mean(Y(find(F>=75 & F<115)));
        
        features(j, (i-1) * num_feats + 5) = ...
            sum(Y(find(F>=125 & F<160)));
        
        features(j, (i-1) * num_feats + 6) = ...
            sum(Y(find(F>=160 & F<175)));
        
        features(j, (i-1) * num_feats + 7) = ...
            LLFn(CAR(s:min(n,e),i));
        
        features(j, (i-1) * num_feats + 8) = ...
            Area(CAR(s:min(n,e),i));
        
        features(j, (i-1) * num_feats + 9) = ...
            Energy(CAR(s:min(n,e),i));
        
        features(j, (i-1) * num_feats + 10) = ...
            ZX(CAR(s:min(n,e),i));
        
        features(j, (i-1) * num_feats + 11) = ...
            kurtosis(CAR(s:min(n,e),i));
        
        features(j, (i-1) * num_feats + 12) = ...
            crest(CAR(s:min(n,e),i));
        
    end
end




% end