function [truthPoses, rgbImages, depthImages, rgbTimestamps] = loadTUMData(path)
%LOADTUMDATA Summary of this function goes here
%   truthPoses, rgbImages, depthImages are 1xn cell arrays of their
%   respective data (4x4 matrix, image, image)

rgb_filename =  'aligned_rgb.txt';
rgb_depth_filename = 'aligned_rgb_depth.txt';
rgb_pose_filename = 'aligned_rgb_pose.txt';

[rgbImages, rgbTimestamps, depthImages, ~] = readRgbD(path, rgb_depth_filename);
[~, ~, truthPoses, ~] = readTruth(path, rgb_pose_filename);


end

function [rgbFiles, rgbTimestamps, truthPoses, truthTimestamps] = readTruth(path, filename)
rgbFiles = {};
rgbTimestamps = {};
truthPoses = {};
truthTimestamps = {};

fid = fopen([path, filesep, filename], 'r');
tline = fgetl(fid);

while ischar(tline)
    lineCellArr = split(tline);
    %{
    LineCellArr is of form:
    * RGB time
    * RGB filename
    * Pose time
    * Pose x
    * Pose y
    * Pose z
    * Pose qx
    * Pose qy
    * Pose qz
    * Pose qw
    %}
    
    rgbTimestamps{end+1} = str2num(lineCellArr{1});
    rgbFiles{end+1} = [path, filesep, lineCellArr{2}];
    
    truthTimestamps{end+1} = str2num(lineCellArr{3});
    
    [x, y, z] = lineCellArr{4:6};
    [qx, qy, qz, qw] = lineCellArr{7:10};
    
    P_c_in_w = [str2num(x); str2num(y); str2num(z)];
    q_w_to_c = [str2num(qw), str2num(qx), str2num(qy), str2num(qz)];
    R_c_to_w = quat2rotm(q_w_to_c);
    
    T_w_to_c = [R_c_to_w', -R_c_to_w' * P_c_in_w; 0 0 0 1];
    
    truthPoses{end+1} = T_w_to_c;
    
    tline = fgetl(fid);
    
end
fclose(fid);
end

function [rgbFiles, rgbTimestamps, depthFiles, depthTimestamps] = readRgbD(path, filename)
% From combined RGB and DEPTH txt file, read everything
rgbFiles = {};
rgbTimestamps = {};
depthFiles = {};
depthTimestamps = {};

fid = fopen([path, filesep, filename], 'r');
tline = fgetl(fid);
while ischar(tline)
    % do what you will
    lineCellArr = split(tline);
    %{
    LineCellArr is of form:
    * RGB time
    * RGB filename
    * depth time
    * depth filename
    %}
    
    rgbTimestamps{end+1} = str2num(lineCellArr{1});
    rgbFiles{end+1} = [path, filesep, lineCellArr{2}];
    
    depthTimestamps{end+1} = str2num(lineCellArr{3});
    depthFiles{end+1} = [path, filesep, lineCellArr{4}];
    
    
    tline = fgetl(fid);
end
fclose(fid);

end


