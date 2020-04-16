function [ r, err, imageTrans ] = calcErr( imageRef, depthRef, image, xi, K, display ) 
%CALCERR Summary of this function goes here
%   Detailed explanation goes here

T = se3Exp(xi);
R = T(1:3, 1:3);
t = T(1:3, 4);
invK = inv(K);

% Arrays holding new coordinate after transform
% Setting to a negative value will give NaN when interpolating
xCoords = zeros(size(imageRef)) - 100;
yCoords = zeros(size(imageRef)) - 100;

% for each point in reference image, transform into new image and store
% coordinates
for x = 1:size(imageRef, 2)
    for y = 1:size(imageRef, 1)
        % Subtract 1 from indeces because matlab uses 1-indexing :(
        pointRef = [x-1; y-1; 1] * depthRef(y, x);
        pointTrans = K * (R * invK * pointRef + t);
        
        % Check validity before adding to output arrays
        if depthRef(y, x) > 0 && pointTrans(3) > 0
           xCoords(y, x) = pointTrans(1) / pointTrans(3);
           yCoords(y, x) = pointTrans(2) / pointTrans(3);
        end
    end
end

% Interpolate to find values of image at transformed points
imageTrans = interp2(image, xCoords, yCoords);
err = imageRef - imageTrans;
r = reshape(err, [], 1);

if display == 1
    imagesc(err);
    colormap(gray);
    set(gca, 'CLim', [-1,1]);
end

end

