from datetime import datetime

import pandas as pd

from os import path as osp

import numpy as np
import quaternion
import torch

from src.utils_numpy_filter import NUMPYIEKF
from src.utils_time import custom_timestamp_sec_parser


class CustomChongQingDataset:
    _DATA_TIMESTAMP = 'DATA_TIMESTAMP'
    _PHONE_ACCELEROMETER_X = 'PHONE_ACCELEROMETER_X'
    _PHONE_ACCELEROMETER_Y = 'PHONE_ACCELEROMETER_Y'
    _PHONE_ACCELEROMETER_Z = 'PHONE_ACCELEROMETER_Z'
    _PHONE_GYROSCOPE_X = 'PHONE_GYROSCOPE_X'
    _PHONE_GYROSCOPE_Y = 'PHONE_GYROSCOPE_Y'
    _PHONE_GYROSCOPE_Z = 'PHONE_GYROSCOPE_Z'
    _GROUND_TRUTH_ACCELEROMETER_X = 'GROUND_TRUTH_ACCELEROMETER_X'
    _GROUND_TRUTH_ACCELEROMETER_Y = 'GROUND_TRUTH_ACCELEROMETER_Y'
    _GROUND_TRUTH_ACCELEROMETER_Z = 'GROUND_TRUTH_ACCELEROMETER_Z'
    _GROUND_TRUTH_GYROSCOPE_X = 'GROUND_TRUTH_GYROSCOPE_X'
    _GROUND_TRUTH_GYROSCOPE_Y = 'GROUND_TRUTH_GYROSCOPE_Y'
    _GROUND_TRUTH_GYROSCOPE_Z = 'GROUND_TRUTH_GYROSCOPE_Z'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_11 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_11'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_12 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_12'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_13 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_13'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_21 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_21'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_22 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_22'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_23 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_23'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_31 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_31'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_32 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_32'
    _GROUND_TRUTH_POSE_ROTATION_MATRIX_33 = 'GROUND_TRUTH_POSE_ROTATION_MATRIX_33'
    _GROUND_TRUTH_POSE_POSITION_X = 'GROUND_TRUTH_POSE_POSITION_X'
    _GROUND_TRUTH_POSE_POSITION_Y = 'GROUND_TRUTH_POSE_POSITION_Y'
    _GROUND_TRUTH_POSE_POSITION_Z = 'GROUND_TRUTH_POSE_POSITION_Z'
    _GROUND_TRUTH_VELOCITY_X = 'GROUND_TRUTH_VELOCITY_X'
    _GROUND_TRUTH_VELOCITY_Y = 'GROUND_TRUTH_VELOCITY_Y'
    _GROUND_TRUTH_VELOCITY_Z = 'GROUND_TRUTH_VELOCITY_Z'

    _CUSTOM_DATA_NAMES_LIST = [
        _DATA_TIMESTAMP,
        _PHONE_GYROSCOPE_X,
        _PHONE_GYROSCOPE_Y,
        _PHONE_GYROSCOPE_Z,
        _PHONE_ACCELEROMETER_X,
        _PHONE_ACCELEROMETER_Y,
        _PHONE_ACCELEROMETER_Z,
        _GROUND_TRUTH_GYROSCOPE_X,
        _GROUND_TRUTH_GYROSCOPE_Y,
        _GROUND_TRUTH_GYROSCOPE_Z,
        _GROUND_TRUTH_ACCELEROMETER_X,
        _GROUND_TRUTH_ACCELEROMETER_Y,
        _GROUND_TRUTH_ACCELEROMETER_Z,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_11,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_12,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_13,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_21,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_22,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_23,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_31,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_32,
        _GROUND_TRUTH_POSE_ROTATION_MATRIX_33,
        _GROUND_TRUTH_POSE_POSITION_X,
        _GROUND_TRUTH_POSE_POSITION_Y,
        _GROUND_TRUTH_POSE_POSITION_Z,
        _GROUND_TRUTH_VELOCITY_X,
        _GROUND_TRUTH_VELOCITY_Y,
        _GROUND_TRUTH_VELOCITY_Z
    ]

    @staticmethod
    def parse_aiimudr_dataset(folder):
        path = osp.join(folder, 'dayZeroOClockAlign', 'TrackSynchronized.csv')
        custom_raw_data = pd.read_csv(
            path,
            header=None,
            names=CustomChongQingDataset._CUSTOM_DATA_NAMES_LIST
        )

        custom_parse_data = custom_raw_data.copy(deep=True)

        custom_parse_data = custom_parse_data.iloc[7186:24801, :]

        custom_dataset_timestamp = custom_parse_data[CustomChongQingDataset._DATA_TIMESTAMP].to_numpy()
        custom_dataset_timestamp_size = custom_dataset_timestamp.shape[0]
        aiimudr_dataset_reference_timestamp = custom_dataset_timestamp[0]
        aiimudr_dataset_timestamp = custom_dataset_timestamp - aiimudr_dataset_reference_timestamp

        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_extract".format("2023_04_10", 8, "huawei_mate30")
        aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_piecewise_{}_{}_extract".format("2023_04_10", 8, "huawei_mate30", 11187, custom_dataset_timestamp_size)
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_piecewise_{}_{}_extract".format("2023_04_10", 8, "huawei_mate30", 11187, 15187)
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_integral_{}_{}_extract".format("2023_04_10", 9, "huawei_mate30", 1, custom_dataset_timestamp_size)
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_integral_{}_{}_extract".format("2023_04_10", 10, "huawei_msate30", 1, custom_dataset_timestamp_size)
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_integral_{}_{}_extract".format("2023_04_10", 11, "huawei_mate30", 1, custom_dataset_timestamp_size)
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}__extract".format("2023_04_13", 17, "huawei_mate30")
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}__extract".format("2023_04_13", 17, "huawei_mate30")
        # aiimudr_dataset_file_name = "{}_drive_{:0>4}_phone_{}_piecewise_{}_{}_extract".format("2023_04_13", 17, "huawei_mate30", 1, 44386)

        aiimudr_dataset_ground_truth_rotation_matrix = custom_parse_data.loc[
                                           :,
                                           [CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_11,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_12,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_13,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_21,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_22,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_23,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_31,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_32,
                                            CustomChongQingDataset._GROUND_TRUTH_POSE_ROTATION_MATRIX_33
                                            ]].to_numpy()
        aiimudr_dataset_ground_truth_ang = np.zeros((custom_dataset_timestamp_size, 3))
        for i in range(0, custom_dataset_timestamp_size):
            rotation_matrix_array = aiimudr_dataset_ground_truth_rotation_matrix[i, :]
            rotation_matrix = np.zeros((3, 3))
            rotation_matrix[0, 0] = rotation_matrix_array[0]
            rotation_matrix[0, 1] = rotation_matrix_array[1]
            rotation_matrix[0, 2] = rotation_matrix_array[2]
            rotation_matrix[1, 0] = rotation_matrix_array[3]
            rotation_matrix[1, 1] = rotation_matrix_array[4]
            rotation_matrix[1, 2] = rotation_matrix_array[5]
            rotation_matrix[2, 0] = rotation_matrix_array[6]
            rotation_matrix[2, 1] = rotation_matrix_array[7]
            rotation_matrix[2, 2] = rotation_matrix_array[8]
            aiimudr_dataset_ground_truth_ang[i, :] = NUMPYIEKF.to_rpy(rotation_matrix)

        aiimudr_dataset_ground_truth_v = custom_parse_data.loc[
                                         :,
                                         [CustomChongQingDataset._GROUND_TRUTH_VELOCITY_X,
                                          CustomChongQingDataset._GROUND_TRUTH_VELOCITY_Y,
                                          CustomChongQingDataset._GROUND_TRUTH_VELOCITY_Z
                                          ]].to_numpy()

        aiimudr_dataset_project_p = custom_parse_data.loc[
                                    :,
                                    [CustomChongQingDataset._GROUND_TRUTH_POSE_POSITION_X,
                                     CustomChongQingDataset._GROUND_TRUTH_POSE_POSITION_Y,
                                     CustomChongQingDataset._GROUND_TRUTH_POSE_POSITION_Z
                                     ]].to_numpy()
        aiimudr_dataset_ground_truth_p = aiimudr_dataset_project_p - aiimudr_dataset_project_p[0, :]

        aiimudr_dataset_observation = custom_parse_data.loc[
                                      :,
                                      [CustomChongQingDataset._PHONE_GYROSCOPE_X,
                                       CustomChongQingDataset._PHONE_GYROSCOPE_Y,
                                       CustomChongQingDataset._PHONE_GYROSCOPE_Z,
                                       CustomChongQingDataset._PHONE_ACCELEROMETER_X,
                                       CustomChongQingDataset._PHONE_ACCELEROMETER_Y,
                                       CustomChongQingDataset._PHONE_ACCELEROMETER_Z
                                       ]].to_numpy()

        # aiimudr_dataset_observation = custom_parse_data.loc[
        #                               :,
        #                               [CustomChongQingDataset._GROUND_TRUTH_GYROSCOPE_X,
        #                                CustomChongQingDataset._GROUND_TRUTH_GYROSCOPE_Y,
        #                                CustomChongQingDataset._GROUND_TRUTH_GYROSCOPE_Z,
        #                                CustomChongQingDataset._GROUND_TRUTH_ACCELEROMETER_X,
        #                                CustomChongQingDataset._GROUND_TRUTH_ACCELEROMETER_Y,
        #                                CustomChongQingDataset._GROUND_TRUTH_ACCELEROMETER_Z
        #                                ]].to_numpy()

        aiimudr_dataset_observation_length = aiimudr_dataset_observation.shape[0]
        rotated_aiimudr_dataset_observation = np.zeros_like(aiimudr_dataset_observation)
        rotation_from_phone_to_oxts_z = np.deg2rad(0)
        c = np.cos(rotation_from_phone_to_oxts_z)
        s = np.sin(rotation_from_phone_to_oxts_z)
        rotation_from_phone_to_oxts = np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])
        for i in range(0, aiimudr_dataset_observation_length):
            rotated_gyroscope_observation = rotation_from_phone_to_oxts.dot(
                aiimudr_dataset_observation[i, 0:3].reshape(3, 1))
            rotated_acceleration_observation = rotation_from_phone_to_oxts.dot(
                aiimudr_dataset_observation[i, 3:6].reshape(3, 1))
            rotated_aiimudr_dataset_observation[i, 0:3] = rotated_gyroscope_observation.reshape(1, 3)
            rotated_aiimudr_dataset_observation[i, 3:6] = rotated_acceleration_observation.reshape(1, 3)

        t = torch.from_numpy(aiimudr_dataset_timestamp)
        p_gt = torch.from_numpy(aiimudr_dataset_ground_truth_p)
        v_gt = torch.from_numpy(aiimudr_dataset_ground_truth_v)
        ang_gt = torch.from_numpy(aiimudr_dataset_ground_truth_ang)
        u = torch.from_numpy(rotated_aiimudr_dataset_observation)

        aiimudr_data = {
            't': t,
            'ang_gt': ang_gt,
            'v_gt': v_gt,
            'p_gt': p_gt,
            'u': u,
            'name': aiimudr_dataset_file_name,
            't0': aiimudr_dataset_reference_timestamp
        }

        return aiimudr_data
