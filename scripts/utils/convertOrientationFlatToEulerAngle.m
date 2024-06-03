function orientationEulerAngle = convertOrientationFlatToEulerAngle(orientationFlat, degrees)

orientationRotationMatrix = convertOrientationFlatToRotationMatrix(orientationFlat);
orientationEulerAngle = convertOrientationRotationMatrixToEulerAngle(orientationRotationMatrix, degrees);

end



