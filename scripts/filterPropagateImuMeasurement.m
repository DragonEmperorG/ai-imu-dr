function [outputFilterState] = filterPropagateImuMeasurement(inputFilterState,inputImuMeasurement)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

GRAVITY = [0 0 -9.80655]';
SKEW_GRAVITY = skew(GRAVITY);

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
inputFilterQSize = size(inputFilterState9NoiseCovariance,1);

dt = inputImuMeasurement{1,1};
dtdt = dt * dt;
inputImuMeasurementAngulerSpeed = (inputImuMeasurement{1,2})';
inputImuMeasurementAcceleration = (inputImuMeasurement{1,3})';
inputPseudoMeasurementForwardVelocity = inputImuMeasurement{1,4};

%%% Propagate
propagateState1AngulerSpeed = inputImuMeasurementAngulerSpeed - inputFilterState4AngulerSpeedBias;
propagateState1Phi = propagateState1AngulerSpeed * dt;
propagateState1Gamma0Phi = uppercaseGreekLetterGammaSubscript0(propagateState1Phi);
propagateState1RotationEstimation = inputFilterState1Rotation * propagateState1Gamma0Phi;
% State X2
propagateState1Gamma1Phi = uppercaseGreekLetterGammaSubscript1(propagateState1Phi);
propagateState2AccelerationEstimation = inputImuMeasurementAcceleration - inputFilterState5AccelerationBias;
propagateState2VelocityEstimation = inputFilterState2Velocity  ...
    + inputFilterState1Rotation * propagateState1Gamma1Phi * propagateState2AccelerationEstimation * dt + GRAVITY * dt;
% State X3
propagateState1Gamma2Phi = uppercaseGreekLetterGammaSubscript2(propagateState1Phi);
propagateState3TranslationEstimation = inputFilterState3Translation ...
    + inputFilterState2Velocity * dt ...
    + inputFilterState1Rotation * propagateState1Gamma2Phi * propagateState2AccelerationEstimation * dtdt ...
    + 0.5 * GRAVITY * dtdt;
% State X4
propagateState4AngularSpeedBias = inputFilterState4AngulerSpeedBias;
% State X5
propagateState5AccelerationBias = inputFilterState5AccelerationBias;
% State X6
propagateState6Rotation = inputFilterState6Rotation;
% State X7
propagateState7Transition = inputFilterState7Transition;

propagateStateCovarianceTransitionF = zeros(size(inputFilterState8StateCovariance));
propagateStateCovarianceTransitionF(4:6,1:3) = SKEW_GRAVITY;
propagateStateCovarianceTransitionF(7:9,4:6) = eye(3);
propagateStateCovarianceTransitionF(1:3,10:12) = - inputFilterState1Rotation;
propagateStateCovarianceTransitionF(4:6,10:12) = - skew(propagateState2VelocityEstimation) * inputFilterState1Rotation;
propagateStateCovarianceTransitionF(7:9,10:12) = - skew(propagateState3TranslationEstimation) * inputFilterState1Rotation;
propagateStateCovarianceTransitionF(4:6,13:15) = - inputFilterState1Rotation;
propagateStateCovarianceTransitionFdt = propagateStateCovarianceTransitionF .* dt;
propagateStateCovarianceTransitionFdtFdt = propagateStateCovarianceTransitionFdt * propagateStateCovarianceTransitionFdt;
propagateStateCovarianceTransitionFdtFdtFdt = propagateStateCovarianceTransitionFdtFdt * propagateStateCovarianceTransitionFdt;

propagateStateCovarianceTransitionAdjoint = zeros(inputFilterPSize,inputFilterQSize);
propagateStateCovarianceTransitionAdjoint(1:3,1:3) = inputFilterState1Rotation;
propagateStateCovarianceTransitionAdjoint(4:6,1:3) = skew(propagateState2VelocityEstimation) * inputFilterState1Rotation;
propagateStateCovarianceTransitionAdjoint(7:9,1:3) = skew(propagateState3TranslationEstimation) * inputFilterState1Rotation;
propagateStateCovarianceTransitionAdjoint(4:6,4:6) = inputFilterState1Rotation;
propagateStateCovarianceTransitionAdjoint(10:21,7:18) = eye(12);
propagateStateCovarianceTransitionAdjointdt = propagateStateCovarianceTransitionAdjoint * dt;
propagateNoiseCovariance = propagateStateCovarianceTransitionAdjointdt * inputFilterState9NoiseCovariance * propagateStateCovarianceTransitionAdjointdt';

propagateStateCovarianceTransitionPhi = eye(size(inputFilterState8StateCovariance)) + propagateStateCovarianceTransitionFdt + (1/2) .* propagateStateCovarianceTransitionFdtFdt + (1/6) .* propagateStateCovarianceTransitionFdtFdtFdt;
propagateStateCovariance = propagateStateCovarianceTransitionPhi * (inputFilterState8StateCovariance + propagateNoiseCovariance) * propagateStateCovarianceTransitionPhi';

%%% Update
updateStateSOBracket3FromCarToNav = propagateState1RotationEstimation * propagateState6Rotation';
updateStateSOBracket3FromNavToCar = updateStateSOBracket3FromCarToNav';
updateStateImuVelocityInCar = updateStateSOBracket3FromNavToCar * propagateState2VelocityEstimation;
updateStateCarVelocityInCar = updateStateImuVelocityInCar + propagateState6Rotation * skew(propagateState1AngulerSpeed) * propagateState7Transition;
updateStateSkewAngularSpeedInImu = skew(propagateState1AngulerSpeed);
updateStateJacobianA = propagateState6Rotation * skew(propagateState7Transition');
updateStateJacobianB = -skew(updateStateCarVelocityInCar);
updateStateJacobianC = propagateState6Rotation * updateStateSkewAngularSpeedInImu;

updateStateMeasurementTransitionH = zeros(3,inputFilterPSize);
updateStateMeasurementTransitionH(1:3,4:6) = updateStateSOBracket3FromNavToCar;
updateStateMeasurementTransitionH(1:3,10:12) = updateStateJacobianA;
updateStateMeasurementTransitionH(1:3,16:18) = updateStateJacobianB;
updateStateMeasurementTransitionH(1:3,19:21) = updateStateJacobianC;



useDeeplearnedMeasurement = true;
if useDeeplearnedMeasurement
    measurementCovarianceR = diag([3,3,3]);
    measurementError = [0; inputPseudoMeasurementForwardVelocity(2); 0] - updateStateCarVelocityInCar;
else    
    measurementIndex = [1 3];
    updateStateMeasurementTransitionH = updateStateMeasurementTransitionH(measurementIndex,:);
    % measurementCovarianceR = diag([15,8]);
    measurementCovarianceR = diag([3,3]);
    measurementError = - updateStateCarVelocityInCar;
end

updateStateMeasurementTransitionS = updateStateMeasurementTransitionH * propagateStateCovariance * updateStateMeasurementTransitionH' + measurementCovarianceR;
updateStateMeasurementTransitionK = (linsolve(updateStateMeasurementTransitionS,(propagateStateCovariance * updateStateMeasurementTransitionH')'))';

updateStateMeasurementTransitionDeltaX = updateStateMeasurementTransitionK * measurementError;
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

updateState1Rotation = updateStateSESubscript4Bracket3DeltaRotation * propagateState1RotationEstimation;
updateState2Velocity = updateStateSESubscript4Bracket3DeltaRotation * propagateState2VelocityEstimation + updateStateSESubscript4Bracket3DeltaVelocityInNav;

updateState3Translation = updateStateSESubscript4Bracket3DeltaRotation * propagateState3TranslationEstimation + updateStateSESubscript4Bracket3DeltaTransitionInNav;
updateState4AngulerSpeedBias = propagateState4AngularSpeedBias + updateStateMeasurementTransitionDeltaX(10:12);
updateState5AccelerationBias = propagateState5AccelerationBias + updateStateMeasurementTransitionDeltaX(13:15);

updateStateDeltaRotationFromImuToCar = SO3.exp(updateStateMeasurementTransitionDeltaX(16:18));
updateState6Rotation = updateStateDeltaRotationFromImuToCar * propagateState6Rotation;
updateState7Transition = propagateState7Transition + updateStateMeasurementTransitionDeltaX(19:21);

updateStateMeasurementTransitionIKH = eye(inputFilterPSize) - updateStateMeasurementTransitionK * updateStateMeasurementTransitionH;
updateStateCovariance = updateStateMeasurementTransitionIKH * propagateStateCovariance * updateStateMeasurementTransitionIKH' ...
    + updateStateMeasurementTransitionK * measurementCovarianceR * updateStateMeasurementTransitionK';
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
