function [translationError] = evaluateDataDrivenVelocity(seError)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
dx = seError(1,4);
dy = seError(2,4);
dz = seError(3,4);
translationError = sqrt(dx * dx + dy * dy + dz * dz);

end