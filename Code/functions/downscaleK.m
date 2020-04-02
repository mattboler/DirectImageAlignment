function [ K_lvl ] = downscaleK( K, lvl )
%DOWNSCALEK Summary of this function goes here
%   Detailed explanation goes here

%{
lvl = 1: K IS K_lvl
lvl = 2: Halve once
lvl = 3: Halve twice
...
%}

if lvl == 1
    % Base case
    K_lvl = K;
    return;
else
    % Recursive case
    K_lvl = [K(1,1)/2, 0, (K(1,3)+0.5)/2 - 0.5; 0, K(2,2)/2, (K(2,3)+0.5)/2 - 0.5; 0 0 1];
    K_lvl = downscaleK(K_lvl, lvl-1);
end

end

