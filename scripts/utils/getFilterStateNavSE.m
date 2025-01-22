function [filterStateNavSE] = getFilterStateNavSE(filterState)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

filterStateNavOrientation = getFilterStateNavOrientation(filterState);
filterStateNavPosition = getFilterStateNavPosition(filterState);
filterStateNavSEObject = se3(filterStateNavOrientation,filterStateNavPosition);

filterStateNavSE = tform(filterStateNavSEObject);

end