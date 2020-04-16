%% ELEC 7450 Digital Image Processing Final Project

addpath('functions')

% Pick a dataset

% path = '/disks/storage/Datasets/Navigation/TUM_RGBD/rgbd_dataset_freiburg1_room';
% path = '/disks/storage/Datasets/Navigation/TUM_RGBD/rgbd_dataset_freiburg1_rpy';
path = '/disks/storage/Datasets/Navigation/TUM_RGBD/rgbd_dataset_freiburg1_xyz';

%% Set up needed data
fx = 517.3;
fy = 516.5;
cx = 318.6;
cy = 255.3;
height = 480;
width = 640;

radial_distortion = [0.2624, -0.9531, 1.1633 ];
tangential_distortion = [ -0.0054, 0.0026 ];

cameraParams = cameraIntrinsics([fx, fy], [cx, cy], [height, width], ...
    'RadialDistortion', radial_distortion, ...
    'TangentialDistortion', tangential_distortion);