function [rotationError] = evaluateRotationError(seError)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
a = seError(1,1);
b = seError(2,2);
c = seError(3,3);
d = 0.5 * (a + b + c - 1.0);
rotationError = acos(max(min(d,1.0),-1.0));

end