function orientationRotationMatrixFlat = convertOrientationRotationMatrixToFlat(orientationRotationMatrix)

orientationRotationMatrixPermute = permute(orientationRotationMatrix,[2 1 3]);
orientationRotationMatrixReshape = reshape(orientationRotationMatrixPermute,9,[]);
orientationRotationMatrixFlat = orientationRotationMatrixReshape';

end



