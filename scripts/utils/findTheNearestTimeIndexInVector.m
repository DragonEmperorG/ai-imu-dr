function [index] = findTheNearestTimeIndexInVector(timeVector,timeTarget)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

timeVectorDist = abs(timeVector - timeTarget);

index = min(timeVectorDist);

end