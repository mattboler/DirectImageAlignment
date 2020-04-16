function xi = directAlign(refImage, refDepth, newImage, K)
%DIRECTALIGN Summary of this function goes here
%   Detailed explanation goes here

xi = [0 0 0 0 0 0]';
prevErr = 1e10;
threshold = 1e-5;

% Using 5 pyramid levels
for level = 6 : -1 : 1
    % 1. Get downscaled image, depth image, and K
    KLevel = downscaleK(K, level);
    pyrRefImage = downscaleImage(refImage, level);
    pyrDepthRef = downscaleDepth(refDepth, level);
    pyrNewImage = downscaleImage(newImage, level);
    
    
    % 2. For at most 20 iterations, perform Guass-Newton to minimize error
    for i = 1 : 15
        [jacobian, r] = deriveErrorNumeric(pyrRefImage, pyrDepthRef, pyrNewImage, xi, KLevel);
        validIdx = ~isnan(sum(jacobian, 2));
        validJacobian = jacobian(validIdx, :);
        validR = r(validIdx, :);
        
        gaussNewtonUpdate = -inv(validJacobian' * validJacobian) * validJacobian' * validR;
        xi = se3Log( se3Exp(gaussNewtonUpdate) * se3Exp(xi) );
        
        err = mean(validR .* validR);
        if abs(prevErr - err) < threshold
            break
        else
            prevErr = err;
        end
    end
    level;
end

err;

end

