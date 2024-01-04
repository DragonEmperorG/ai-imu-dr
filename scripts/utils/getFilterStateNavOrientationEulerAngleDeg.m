function [filterStateNavOrientationEulerAngleDeg] = getFilterStateNavOrientationEulerAngleDeg(filterState)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

filterStateNavOrientationRotationMatrix = getFilterStateNavOrientation(filterState);
[filterStateNavOrientationEulerAnglePitch,filterStateNavOrientationEulerAngleRoll,filterStateNavOrientationEulerAngleYaw] = dcm2angle(filterStateNavOrientationRotationMatrix,'XYZ');
filterStateNavOrientationEulerAngleDeg = rad2deg(horzcat(filterStateNavOrientationEulerAnglePitch,filterStateNavOrientationEulerAngleRoll,filterStateNavOrientationEulerAngleYaw));

end