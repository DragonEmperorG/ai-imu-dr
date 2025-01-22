% 重置工作区环境
clearvars;
close all;
dbstop error;
% clc;

% 添加自定义工具类函数
TAG = "Coordinate Transformations";

cEulerAnglesDegList = [
    90, 0, 0;
    180, 0, 0;
    270, 0, 0;
    0, 0, 0;
    0, 90, 0;
    0, 270, 0;
    0, 0, 90;
    0, 0, 180;
    0, 0, 270;
];

cEulerAnglesRadList = deg2rad(cEulerAnglesDegList);

cEulerAnglesDegListLength = size(cEulerAnglesDegList,1);
for i = 1:cEulerAnglesDegListLength
    tRotationMatrices = eul2rotm(cEulerAnglesRadList(i,:),'XYZ');
    fprintf('%d & %d & %d \\\\\n',tRotationMatrices(1,1),tRotationMatrices(1,2),tRotationMatrices(1,3));
    fprintf('%d & %d & %d \\\\\n',tRotationMatrices(2,1),tRotationMatrices(2,2),tRotationMatrices(2,3));
    fprintf('%d & %d & %d \\\\\n',tRotationMatrices(3,1),tRotationMatrices(3,2),tRotationMatrices(3,3));
    fprintf('\n');
end



