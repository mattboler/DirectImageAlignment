addpath('functions')

%{
K = [517.3 0 318.6;	0 516.5 255.3; 0 0 1];
c1 = double(imreadbw('rgb/1305031102.175304.png'));
c2 = double(imreadbw('rgb/1305031102.275326.png'));

d1 = double(imread('depth/1305031102.160407.png'))/5000;
d2 = double(imread('depth/1305031102.262886.png'))/5000;

% result:
% approximately -0.0021    0.0057    0.0374   -0.0292   -0.0183   -0.0009
%}
%%
%{
K = [ 535.4  0 320.1;	0 539.2 247.6; 0 0 1];
c1 = double(imreadbw('rgb/1341847980.722988.png'));
c2 = double(imreadbw('rgb/1341847982.998783.png'));


d1 = double(imread('depth/1341847980.723020.png'))/5000;
d2 = double(imread('depth/1341847982.998830.png'))/5000;

% result:
%  approximately -0.2894 0.0097 -0.0439  0.0039 0.0959 0.0423
%}

%%
K = [517.3 0 318.6;	0 516.5 255.3; 0 0 1];

c1 = double(imreadbw('rgb/1305031910.765238.png'));
c2 = double(imreadbw('rgb/1305031910.797230.png'));

d1 = double(imreadbw('depth/1305031910.771502.png'));
d2 = double(imreadbw('depth/1305031910.803249.png'));

% result:
%   0.0008 0.0002 0.0000 -0.0095 0.0072 0.0162
p1 = [-0.8683 0.6026 1.5627 0.8219 -0.3912 0.1615 -0.3811];
p2 = [-0.8674 0.6100 1.5631 0.8246 -0.3835 0.1609 -0.3836];

x1 = p1(1); y1 = p1(2); z1 = p1(3); qx1 = p1(4); qy1 = p1(5); qz1 = p1(6); qw1 = p1(7);

P_1_in_w = [x1; y1; z1];
q_1_to_w = [qw1, qx1, qy1, qz1];
R_1_to_w = quat2rotm(q_1_to_w);

T_w_to_1 = [R_1_to_w', -R_1_to_w' * P_1_in_w; 0 0 0 1];

x2 = p2(1); y2 = p2(2); z2 = p2(3); qx2 = p2(4); qy2 = p2(5); qz2 = p2(6); qw2 = p2(7);

P_2_in_w = [x2; y2; z2];
q_2_to_w = [qw2, qx2, qy2, qz2];
R_2_to_w = quat2rotm(q_2_to_w);

T_w_to_2 = [R_2_to_w', -R_2_to_w' * P_2_in_w; 0 0 0 1];

T_1_to_2_truth = T_w_to_2 * inv(T_w_to_1);

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

xi;
figure(2)
[finalR, errImage] = calcErr(imageRef, depthRef, image, xi, KLevel, 0);
imagesc(abs(errImage))
colormap(gray)
title("Final Residuals")

T_1_to_2_est = se3Exp(xi)
T_1_to_2_truth