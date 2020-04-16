addpath('functions')

K = [517.3 0 318.6;	0 516.5 255.3; 0 0 1];
c2 = double(imreadbw('rgb/1305031102.175304.png'));
c1 = double(imreadbw('rgb/1305031102.275326.png'));

d2 = double(imread('depth/1305031102.160407.png'))/5000;
d1 = double(imread('depth/1305031102.262886.png'))/5000;

% result:
% approximately -0.0021    0.0057    0.0374   -0.0292   -0.0183   -0.0009

%%
%{
K = [ 535.4  0 320.1;	0 539.2 247.6; 0 0 1];
c2 = double(imreadbw('rgb/1341847980.722988.png'));
c1 = double(imreadbw('rgb/1341847982.998783.png'));


d2 = double(imread('depth/1341847980.723020.png'))/5000;
d1 = double(imread('depth/1341847982.998830.png'))/5000;

% result:
%  approximately -0.2894 0.0097 -0.0439  0.0039 0.0959 0.0423
%}

%%
% TODO

% We attempt to align an incoming image to a reference image and depth
% image

% Initilize estimate
xi = [0 0 0 0 0 0]';
prevErr = 1e10;
threshold = 1e-5;

figure(1)
[initialR, initialErrorImage] = calcErr(c1, d1, c2, xi, K, 0);
imagesc(abs(initialErrorImage));
colormap(gray)
title("Initial Residuals")

% Using 5 pyramid levels
for level = 6 : -1 : 1
    % 1. Get downscaled image, depth image, and K
    KLevel = downscaleK(K, level);
    imageRef = downscaleImage(c1, level);
    depthRef = downscaleDepth(d1, level);
    image = downscaleImage(c2, level);
    
    
    % 2. For at most 20 iterations, perform Guass-Newton to minimize error
    for i = 1 : 15
        [jacobian, r] = deriveErrorNumeric(imageRef, depthRef, image, xi, KLevel);
        validIdx = ~isnan(sum(jacobian, 2));
        validJacobian = jacobian(validIdx, :);
        validR = r(validIdx, :);
        
        gaussNewtonUpdate = -inv(validJacobian' * validJacobian) * validJacobian' * validR;
        xi = se3Log( se3Exp(gaussNewtonUpdate) * se3Exp(xi) );
        
        err = mean(validR .* validR)
        if abs(prevErr - err) < threshold
            break
        else
            prevErr = err;
        end
    end
    level
end

xi
figure(2)
[finalR, errImage] = calcErr(imageRef, depthRef, image, xi, KLevel, 0);
imagesc(abs(errImage))
colormap(gray)
title("Final Residuals")
