function orientationEulerAngle = convertOrientationRotationMatrixToEulerAngle(orientationRotationMatrix, degrees)

[orientationEulerAnglePitch,orientationEulerAngleRoll,orientationEulerAngleYaw] = dcm2angle(orientationRotationMatrix,'XYZ');
orientationEulerAngle = horzcat(orientationEulerAnglePitch,orientationEulerAngleRoll,orientationEulerAngleYaw);
if degrees
    orientationEulerAngle = rad2deg(orientationEulerAngle);
end

end



