function [horizantalTranslationError] = evaluateHorizantalTranslationError(seError)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
dx = seError(1,4);
dy = seError(2,4);
horizantalTranslationError = sqrt(dx * dx + dy * dy);

end