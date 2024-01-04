function [outputFilterState] = filterUpdateOrientationMeasurement(inputFilterState,inputOrientationMeasurement)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

inputFilterState1Rotation = inputFilterState{1,1};
inputFilterState2Velocity = (inputFilterState{1,2})';
inputFilterState3Translation = (inputFilterState{1,3})';
inputFilterState4AngulerSpeedBias = (inputFilterState{1,4})';
inputFilterState5AccelerationBias = (inputFilterState{1,5})';
inputFilterState6Rotation = inputFilterState{1,6};
inputFilterState7Transition = (inputFilterState{1,7})';
inputFilterState8StateCovariance = inputFilterState{1,8};
inputFilterPSize = size(inputFilterState8StateCovariance,1);
inputFilterState9NoiseCovariance = inputFilterState{1,9};

inputOrientationMeasurementValue = (inputOrientationMeasurement{1,1});
inputOrientationMeasurementCovariance = inputOrientationMeasurement{1,2};

updateStateMeasurementTransitionH = zeros(3,inputFilterPSize);
updateStateMeasurementTransitionH(:,1:3) = eye(3);
updateStateMeasurementTransitionS = updateStateMeasurementTransitionH * inputFilterState8StateCovariance * updateStateMeasurementTransitionH' + inputOrientationMeasurementCovariance;
updateStateMeasurementTransitionK = (linsolve(updateStateMeasurementTransitionS,(inputFilterState8StateCovariance * updateStateMeasurementTransitionH')'))';

orientationMeasurementError = inputOrientationMeasurementValue * inputFilterState1Rotation';
% [U,~,V] = svd(orientationMeasurementError);
% S = eye(3);
% S(2,2) = det(U) * det(V);
orientationMeasurementErrorNormalize = trnorm(orientationMeasurementError);
orientationMeasurementErrorMatrixSO3 = SO3(orientationMeasurementErrorNormalize);
orientationMeasurementErrorMatrix = orientationMeasurementErrorMatrixSO3.log();
orientationMeasurementErrorVector = zeros(3,1);
orientationMeasurementErrorVector(1,1) = (orientationMeasurementErrorMatrix(3,2) - orientationMeasurementErrorMatrix(2,3)) * 0.5;
orientationMeasurementErrorVector(2,1) = (orientationMeasurementErrorMatrix(1,3) - orientationMeasurementErrorMatrix(3,1)) * 0.5;
orientationMeasurementErrorVector(3,1) = (orientationMeasurementErrorMatrix(2,1) - orientationMeasurementErrorMatrix(1,2)) * 0.5;
updateStateMeasurementTransitionDeltaX = updateStateMeasurementTransitionK * (orientationMeasurementErrorVector);

updateStateSESubscript4Bracket3RotationElement = updateStateMeasurementTransitionDeltaX(1:3);
updateStateSESubscript4Bracket3RotationElementNorm = norm(updateStateSESubscript4Bracket3RotationElement);
updateStateSESubscript4Bracket3RotationElementAxis = updateStateSESubscript4Bracket3RotationElement / updateStateSESubscript4Bracket3RotationElementNorm;
updateStateSESubscript4Bracket3RotationElementSkewAxis = skew(updateStateSESubscript4Bracket3RotationElementAxis);
updateStateSESubscript4Bracket3RotationElementJacobian = (sin(updateStateSESubscript4Bracket3RotationElementNorm) / updateStateSESubscript4Bracket3RotationElementNorm) * eye(3) ...
    + (1 - sin(updateStateSESubscript4Bracket3RotationElementNorm) / updateStateSESubscript4Bracket3RotationElementNorm) * (updateStateSESubscript4Bracket3RotationElementAxis * updateStateSESubscript4Bracket3RotationElementAxis') ...
    + ((1 - cos(updateStateSESubscript4Bracket3RotationElementNorm)) / updateStateSESubscript4Bracket3RotationElementNorm) * updateStateSESubscript4Bracket3RotationElementSkewAxis;

updateStateSESubscript4Bracket3DeltaRotation = cos(updateStateSESubscript4Bracket3RotationElementNorm) * eye(3) ...
    + (1 - cos(updateStateSESubscript4Bracket3RotationElementNorm)) * (updateStateSESubscript4Bracket3RotationElementAxis * updateStateSESubscript4Bracket3RotationElementAxis') ...
    + sin(updateStateSESubscript4Bracket3RotationElementNorm) * updateStateSESubscript4Bracket3RotationElementSkewAxis;
updateStateSESubscript4Bracket3OtherElement = zeros(3,2);
updateStateSESubscript4Bracket3OtherElement(1:3,1) = updateStateMeasurementTransitionDeltaX(4:6);
updateStateSESubscript4Bracket3OtherElement(1:3,2) = updateStateMeasurementTransitionDeltaX(7:9);
updateStateSESubscript4Bracket3DeltaOther = updateStateSESubscript4Bracket3RotationElementJacobian * updateStateSESubscript4Bracket3OtherElement;
updateStateSESubscript4Bracket3DeltaVelocityInNav = updateStateSESubscript4Bracket3DeltaOther(1:3,1);
updateStateSESubscript4Bracket3DeltaTransitionInNav = updateStateSESubscript4Bracket3DeltaOther(1:3,2);

updateState1Rotation = updateStateSESubscript4Bracket3DeltaRotation * inputFilterState1Rotation;
updateState2Velocity = updateStateSESubscript4Bracket3DeltaRotation * inputFilterState2Velocity ...
    + updateStateSESubscript4Bracket3DeltaVelocityInNav;
updateState3Translation = updateStateSESubscript4Bracket3DeltaRotation * inputFilterState3Translation ...
    + updateStateSESubscript4Bracket3DeltaTransitionInNav;
updateState4AngulerSpeedBias = inputFilterState4AngulerSpeedBias + updateStateMeasurementTransitionDeltaX(10:12);
updateState5AccelerationBias = inputFilterState5AccelerationBias + updateStateMeasurementTransitionDeltaX(13:15);

updateStateDeltaRotationFromImuToCar = SO3.exp(updateStateMeasurementTransitionDeltaX(16:18));
updateState6Rotation = updateStateDeltaRotationFromImuToCar * inputFilterState6Rotation;
updateState7Transition = inputFilterState7Transition + updateStateMeasurementTransitionDeltaX(19:21);

updateStateMeasurementTransitionIKH = eye(inputFilterPSize) - updateStateMeasurementTransitionK * updateStateMeasurementTransitionH;
updateStateCovariance = updateStateMeasurementTransitionIKH * inputFilterState8StateCovariance * updateStateMeasurementTransitionIKH' ...
    + updateStateMeasurementTransitionK * inputOrientationMeasurementCovariance * updateStateMeasurementTransitionK';
updateState8StateCovariance = (updateStateCovariance + updateStateCovariance') * 0.5;

outputFilterState = cell(1,9);
outputFilterState{1,1} = updateState1Rotation;
outputFilterState{1,2} = (updateState2Velocity)';
outputFilterState{1,3} = (updateState3Translation)';
outputFilterState{1,4} = (updateState4AngulerSpeedBias)';
outputFilterState{1,5} = (updateState5AccelerationBias)';
outputFilterState{1,6} = updateState6Rotation;
outputFilterState{1,7} = (updateState7Transition)';
outputFilterState{1,8} = updateState8StateCovariance;
outputFilterState{1,9} = inputFilterState9NoiseCovariance;