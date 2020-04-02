function [I_lvl ] = downscaleImage(I, lvl)
%DOWNSCALEIMAGE Summary of this function goes here
%   Detailed explanation goes here

if lvl == 1
    I_lvl = I;
    return;
else
    I_tl = I(1:2:end, 1:2:end);
    I_tr = I(1:2:end, 2:2:end);
    I_bl = I(2:2:end, 1:2:end);
    I_br = I(2:2:end, 2:2:end);
    I_lvl = 0.25 * (I_tl + I_tr + I_bl + I_br);
    
    I_lvl = downscaleImage(I_lvl, lvl-1);
end

