addpath('functions')

K = [517.3 0 318.6;	0 516.5 255.3; 0 0 1];
c2 = double(imreadbw('rgb/1305031102.175304.png'));
c1 = double(imreadbw('rgb/1305031102.275326.png'));

d2 = double(imread('depth/1305031102.160407.png'))/5000;
d1 = double(imread('depth/1305031102.262886.png'))/5000;

% result:
% approximately -0.0021    0.0057    0.0374   -0.0292   -0.0183   -0.0009

%%
K = [ 535.4  0 320.1;	0 539.2 247.6; 0 0 1];
c1 = double(imreadbw('rgb/1341847980.722988.png'));
c2 = double(imreadbw('rgb/1341847982.998783.png'));


d1 = double(imread('depth/1341847980.723020.png'))/5000;
d2 = double(imread('depth/1341847982.998830.png'))/5000;

% result:
%  approximately -0.2894 0.0097 -0.0439  0.0039 0.0959 0.0423


%%
% TODO

% We attempt to align an incoming image to a reference image and depth
% image

% Initilize estimate
xi = [0 0 0 0 0 0]';

% Using 5 pyramid levels
for level = 5 : -1 : 1
    % 1. Get downscaled image, depth image, and K
    KLevel = downscaleK(K, level);
    imageRef = downscaleImage(c1, level);
    depthRef = downscaleDepth(d1, level);
    image = downscaleImage(c2, level);
    
    
    % 2. For at most 20 iterations, perform Guass-Newton to minimize error
    prevErr = 1e10;
    for i = 1 : 20
        
    end
    
    % 3. Set pose estimate and move on to next level
    
    level
end
