function features = gen_features(signal, window, r)

[n, d] = size(signal);
new_size = ceil(n/r);
Fs = 1000;
num_feats = 12;

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
    
    NFFT = 2^nextpow2(length(s:min(n,e)));
    F = abs(((0:1/NFFT:1-1/NFFT)*Fs));

    mask1 = find(F>=1 & F<60);
    mask2 = find(F>=60 & F<102);
    mask3 = find(F>=102 & F<202);
    mask4 = find(F>=202 & F<302);

    for i=1:d
        snip = signal(s:min(n,e),i);
        CAR_snip = CAR(s:min(n,e),i);
        s_f = (i-1) * num_feats;
        % Local Motor Potential

        Y = abs(fft(snip, NFFT));

        features(j, s_f + 1) = mean(snip);

                
        features(j, s_f + 2) = ...
            mean(Y(mask1));
        
        features(j, s_f + 3) = ...
            mean(Y(mask2));
        
        features(j, s_f + 4) = ...
            mean(Y(mask3));
        
        features(j, s_f + 5) = ...
            mean(Y(mask4));
        
        features(j, s_f + 6) = ...
            rms(CAR_snip);
        
        features(j, s_f + 7) = ...
            LLFn(CAR_snip);
        
        features(j, s_f + 8) = ...
            Area(CAR_snip);
        
        features(j, s_f + 9) = ...
            Energy(CAR_snip);
        
        features(j, s_f + 10) = ...
            ZX(CAR_snip);
        
        features(j, s_f + 11) = ...
            kurtosis(CAR_snip);
        
        features(j, s_f + 12) = ...
            crest(CAR_snip);
        
        if any(isnan(features(j, s_f+1:s_f + num_feats)))
            error(strcat(...
                'NAN on feature #', int2str(...
                    find(isnan(features(j, s_f+1:s_f + num_feats)))...
                ), ...
                'finger #', int2str(i), ...
                'row #', int2str(j) ...
            ))
        end
    end
end




% end