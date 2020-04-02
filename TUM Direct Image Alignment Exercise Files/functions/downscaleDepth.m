function [ I_lvl ] = downscaleDepth( I, lvl)
%DOWNSCALEDEPTH Summary of this function goes here
%   Detailed explanation goes here

if lvl == 1
   I_lvl = I;
   return;
else
    I_tl = I(1:2:end, 1:2:end);
    I_tr = I(1:2:end, 2:2:end);
    I_bl = I(2:2:end, 1:2:end);
    I_br = I(2:2:end, 2:2:end);
    
    % Can't just normalize by 4 b/c some pixels may not have depth info
    % Normalize by number of pixels with depth information instead ->
    % sign(x) = 1 if positive, 0 if zero
    I_lvl = (I_tl + I_tr + I_bl + I_br) ./ (sign(I_tl) + sign(I_tr) + sign(I_bl) + sign(I_br));
    I_lvl(isnan(I_lvl)) = 0;
    I_lvl = downscaleDepth(I_lvl, lvl-1);
end

end