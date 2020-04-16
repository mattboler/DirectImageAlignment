function [jacobian, residual] = deriveErrorNumeric( imageRef, depthRef, image, xi, K )
%DERIVEERRORNUMERIC Summary of this function goes here
%   Detailed explanation goes here

eps = 1e-8;

% Preallocate jacobian array
jacobian = zeros( size(imageRef, 1) * size(imageRef, 2), 6 );

residual = calcErr(imageRef, depthRef, image, xi, K, 0);


for j = 1 : 6
   generatorVec = zeros(1, 6);
   generatorVec(j) = eps;
   
   xPerturbed = se3Log( se3Exp(generatorVec) * se3Exp(xi) );
   jacobian(:, j) = ( calcErr(imageRef, depthRef, image, xPerturbed, K, 0) - residual ) / eps;
end


end

