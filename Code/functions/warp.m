function [ coords ] = warp( K, pixel, depth, twist)
%WARP Summary of this function goes here
%   Detailed explanation goes here

T = se3Exp(twist);
R = T(1:3, 1:3);
t = T(1:3, 4);
K_inv = inv(K);

world_point = depth * [pixel(1); pixel(2); 1];

warped_point = K * (R*K_inv * world_point + t);
coords = [warped_point(1) / warped_point(3); warped_point(2) / warped_point(3)];

end

