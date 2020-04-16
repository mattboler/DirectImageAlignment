%% ELEC 7450 Digital Image Processing Final Project
clear all; close all; clc
addpath('functions')

% Pick a dataset

% DATASET TYPE
% pick based on number after freiburg in dataset
dataset_type = 1;
% dataset_type = 2;

data_path = 'rgbd_dataset_freiburg1_room';
% data_path = 'rgbd_dataset_freiburg1_rpy';
% data_path = 'rgbd_dataset_freiburg1_xyz';

base_path = ['..' filesep '..' filesep '0_data' filesep 'TUM_RGBD' filesep];
path = [base_path, data_path];
%% Set up needed data

if dataset_type == 1
    fx = 517.3;
    fy = 516.5;
    cx = 318.6;
    cy = 255.3;
    height = 480;
    width = 640;
    
    radial_distortion = [0.2624, -0.9531, 1.1633 ];
    tangential_distortion = [ -0.0054, 0.0026 ];
    
    
elseif dataset_type == 2
    fx = 520.9;
    fy = 521.0;
    cx = 325.1;
    cy = 249.7;
    height = 480;
    width = 640;
    
    radial_distortion = [0.2312, -0.7849, 0.9172 ];
    tangential_distortion = [ -0.0033, -0.0001 ];
end

rgbCameraParams = cameraIntrinsics([fx, fy], [cx, cy], [height, width], ...
    'RadialDistortion', radial_distortion, ...
    'TangentialDistortion', tangential_distortion);

K = rgbCameraParams.IntrinsicMatrix';

[truthPoses, rgbImages, depthImages, timestamps] = loadTUMData(path);

truthPositions = [];
estimatedPositions = [];
estimatedPoses = {};
times = [];

%% Initialize camera state

T_w_c = truthPoses{1};

T_c_w = inv(T_w_c);
P_c_in_w_1 = T_c_w(1:3, 4);

truthPositions(:, 1) = P_c_in_w_1;
estimatedPositions(:, 1) = P_c_in_w_1;
estimatedPoses{1} = T_w_c;
times(1) = timestamps{1};



refImageName = rgbImages{1};
refDepthName = depthImages{1};

refImage = double(imreadbw(refImageName));
refImage = undistortImage(refImage, rgbCameraParams);
refDepth = double(imreadbw(refDepthName));
refDepth = undistortImage(refDepth, rgbCameraParams);

for idx = 2 : 10
    idx
    times(idx) = timestamps{idx};
    newImageName = rgbImages{idx};
    newImage = double(imreadbw(newImageName));
    newImage = undistortImage(newImage, rgbCameraParams);
    
    newDepthName = depthImages{idx};
    newDepth = double(imreadbw(newDepthName));
    newDepth = undistortImage(newDepth, rgbCameraParams);
    
    % Do alignment!
    % ...
    
    xi = directAlign(refImage, refDepth, newImage, K);
    
    estDeltaPose = se3Exp(xi);
    
    prevEstPose = estimatedPoses{idx-1};
    newEstPose = estDeltaPose * prevEstPose;
    newTruthPose = truthPoses{idx};
    
    estimatedPoses{idx} = newEstPose;
    
    newEstT_c_w = inv(newEstPose);
    estimatedPositions(:, idx) = newEstT_c_w(1:3, 4);
    
    newTruthT_c_w = inv(newTruthPose);
    truthPositions(:, idx) = newTruthT_c_w(1:3, 4);
    
    refImage = newImage;
    refDepth = newDepth;
    
end

times = times - times(1);

positionDelta = (truthPositions - estimatedPositions);
positionError = sqrt( sum(positionDelta.^2, 1) );



