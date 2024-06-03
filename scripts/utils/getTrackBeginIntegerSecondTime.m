function [trackBeginIntegerSecondTime, trackBeginIntegerSecondTimeIndex] = getTrackBeginIntegerSecondTime(trackTime)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

trackBeginTime = trackTime(1);
trackBeginIntegerSecondTime = ceil(trackBeginTime);

trackBeginIntegerSecondTimeIndex = find(trackTime == trackBeginIntegerSecondTime);

end