function orientationEulerAngle = convertOrientationRotationMatrixToEulerAngle(orientationRotationMatrix, degrees)

orientationEulerAngle = rotm2eul(orientationRotationMatrix,'XYZ');

if degrees
    orientationEulerAngle = rad2deg(orientationEulerAngle);
end

end



