function orientationRotationMatrix = convertOrientationFlatToRotationMatrix(orientationFlat)

orientationFlatReshape = reshape(orientationFlat',3,3,[]);
orientationRotationMatrix = permute(orientationFlatReshape,[2 1 3]);

end



