function [truthPoses, rgbImages, depthImages] = loadTUMData(path)
%LOADTUMDATA Summary of this function goes here
%   truthPoses, rgbImages, depthImages are 1xn cell arrays of their
%   respective data (4x4 matrix, image, image)

rgb_filename =  'aligned_rgb.txt';
rgb_depth_filename = 'aligned_rgb_depth.txt';
rbg_pose_filename = 'aligned_rgb_pose.txt';


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


