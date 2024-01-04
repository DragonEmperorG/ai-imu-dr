function [filterStateCarOrientationEulerAngleDeg] = getFilterStateCarOrientationEulerAngleDeg(filterState)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

filterStateCarOrientationRotationMatrix = getFilterStateCarOrientation(filterState);
[filterStateCarOrientationEulerAnglePitch,filterStateCarOrientationEulerAngleRoll,filterStateCarOrientationEulerAngleYaw] = dcm2angle(filterStateCarOrientationRotationMatrix,'XYZ');
filterStateCarOrientationEulerAngleDeg = rad2deg(horzcat(filterStateCarOrientationEulerAnglePitch,filterStateCarOrientationEulerAngleRoll,filterStateCarOrientationEulerAngleYaw));

end