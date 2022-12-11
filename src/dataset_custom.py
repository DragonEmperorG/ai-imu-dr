from datetime import datetime

import pandas as pd

from os import path as osp

import numpy as np
import quaternion
import torch

from src.utils_time import custom_timestamp_sec_parser


class CustomDataset:
    _DATA_TIMESTAMP = 'DATA_TIMESTAMP'
    _PHONE_TIMESTAMP = 'PHONE_TIMESTAMP'
    _PHONE_ACCELEROMETER_X = 'PHONE_ACCELEROMETER_X'
    _PHONE_ACCELEROMETER_Y = 'PHONE_ACCELEROMETER_Y'
    _PHONE_ACCELEROMETER_Z = 'PHONE_ACCELEROMETER_Z'
    _PHONE_GYROSCOPE_X = 'PHONE_GYROSCOPE_X'
    _PHONE_GYROSCOPE_Y = 'PHONE_GYROSCOPE_Y'
    _PHONE_GYROSCOPE_Z = 'PHONE_GYROSCOPE_Z'
    _PHONE_GAME_ROTATION_VECTOR_X = 'PHONE_GAME_ROTATION_VECTOR_X'
    _PHONE_GAME_ROTATION_VECTOR_Y = 'PHONE_GAME_ROTATION_VECTOR_Y'
    _PHONE_GAME_ROTATION_VECTOR_Z = 'PHONE_GAME_ROTATION_VECTOR_Z'
    _PHONE_GAME_ROTATION_VECTOR_SCALAR = 'PHONE_GAME_ROTATION_VECTOR_SCALAR'
    _PHONE_ROTATION_VECTOR_X = 'PHONE_ROTATION_VECTOR_X'
    _PHONE_ROTATION_VECTOR_Y = 'PHONE_ROTATION_VECTOR_Y'
    _PHONE_ROTATION_VECTOR_Z = 'PHONE_ROTATION_VECTOR_Z'
    _PHONE_ROTATION_VECTOR_SCALAR = 'PHONE_ROTATION_VECTOR_SCALAR'
    _PHONE_GYROSCOPE_UNCALIBRATED_X = 'PHONE_GYROSCOPE_UNCALIBRATED_X'
    _PHONE_GYROSCOPE_UNCALIBRATED_Y = 'PHONE_GYROSCOPE_UNCALIBRATED_Y'
    _PHONE_GYROSCOPE_UNCALIBRATED_Z = 'PHONE_GYROSCOPE_UNCALIBRATED_Z'
    _PHONE_ORIENTATION_X = 'PHONE_ORIENTATION_X'
    _PHONE_ORIENTATION_Y = 'PHONE_ORIENTATION_Y'
    _PHONE_ORIENTATION_Z = 'PHONE_ORIENTATION_Z'
    _PHONE_MAGNETIC_FIELD_X = 'PHONE_MAGNETIC_FIELD_X'
    _PHONE_MAGNETIC_FIELD_Y = 'PHONE_MAGNETIC_FIELD_Y'
    _PHONE_MAGNETIC_FIELD_Z = 'PHONE_MAGNETIC_FIELD_Z'
    _PHONE_GRAVITY_X = 'PHONE_GRAVITY_X'
    _PHONE_GRAVITY_Y = 'PHONE_GRAVITY_Y'
    _PHONE_GRAVITY_Z = 'PHONE_GRAVITY_Z'
    _PHONE_LINEAR_ACCELERATION_X = 'PHONE_LINEAR_ACCELERATION_X'
    _PHONE_LINEAR_ACCELERATION_Y = 'PHONE_LINEAR_ACCELERATION_Y'
    _PHONE_LINEAR_ACCELERATION_Z = 'PHONE_LINEAR_ACCELERATION_Z'
    _PHONE_PRESSURE = 'PHONE_PRESSURE'
    _PHONE_GNSS_TIMESTAMP = 'PHONE_GNSS_TIMESTAMP'
    _PHONE_GNSS_LONGITUDE = 'PHONE_GNSS_LONGITUDE'
    _PHONE_GNSS_LATITUDE = 'PHONE_GNSS_LATITUDE'
    _PHONE_GNSS_ACCURACY = 'PHONE_GNSS_ACCURACY'
    _PHONE_ALKAID_REQUEST_TIMESTAMP = 'PHONE_ALKAID_REQUEST_TIMESTAMP'
    _PHONE_ALKAID_RESPONSIVE_TIMESTAMP = 'PHONE_ALKAID_RESPONSIVE_TIMESTAMP'
    _PHONE_ALKAID_MAP_TIMESTAMP = 'PHONE_ALKAID_MAP_TIMESTAMP'
    _PHONE_ALKAID_STATUS = 'PHONE_ALKAID_STATUS'
    _PHONE_ALKAID_TIMESTAMP = 'PHONE_ALKAID_TIMESTAMP'
    _PHONE_ALKAID_SYNCHRONIZE_TIMESTAMP = 'PHONE_ALKAID_SYNCHRONIZE_TIMESTAMP'
    _PHONE_ALKAID_LONGITUDE = 'PHONE_ALKAID_LONGITUDE'
    _PHONE_ALKAID_LATITUDE = 'PHONE_ALKAID_LATITUDE'
    _PHONE_ALKAID_HEIGHT = 'PHONE_ALKAID_HEIGHT'
    _PHONE_ALKAID_AZIMUTH = 'PHONE_ALKAID_AZIMUTH'
    _PHONE_ALKAID_SPEED = 'PHONE_ALKAID_SPEED'
    _ALKAID_TIMESTAMP = '_ALKAID_TIMESTAMP'
    _ALKAID_LONGITUDE = 'ALKAID_LONGITUDE'
    _ALKAID_LATITUDE = 'ALKAID_LATITUDE'
    _ALKAID_PROJECT_COORDINATE_X = 'ALKAID_PROJECT_COORDINATE_X'
    _ALKAID_PROJECT_COORDINATE_Y = 'ALKAID_PROJECT_COORDINATE_Y'
    _ALKAID_PROJECT_COORDINATE_DELTA_X = 'ALKAID_PROJECT_COORDINATE_DELTA_X'
    _ALKAID_PROJECT_COORDINATE_DELTA_Y = 'ALKAID_PROJECT_COORDINATE_DELTA_Y'
    _ALKAID_HEIGHT = 'ALKAID_HEIGHT'
    _ALKAID_AZIMUTH = 'ALKAID_AZIMUTH'
    _ALKAID_SPEED = 'ALKAID_SPEED'
    _ALKAID_AGE = 'ALKAID_AGE'

    _CUSTOM_DATA_NAMES_LIST = [
        _DATA_TIMESTAMP,
        _PHONE_ACCELEROMETER_X,
        _PHONE_ACCELEROMETER_Y,
        _PHONE_ACCELEROMETER_Z,
        _PHONE_GYROSCOPE_X,
        _PHONE_GYROSCOPE_Y,
        _PHONE_GYROSCOPE_Z,
        _PHONE_GAME_ROTATION_VECTOR_X,
        _PHONE_GAME_ROTATION_VECTOR_Y,
        _PHONE_GAME_ROTATION_VECTOR_Z,
        _PHONE_GAME_ROTATION_VECTOR_SCALAR,
        _PHONE_ROTATION_VECTOR_X,
        _PHONE_ROTATION_VECTOR_Y,
        _PHONE_ROTATION_VECTOR_Z,
        _PHONE_ROTATION_VECTOR_SCALAR,
        _PHONE_GYROSCOPE_UNCALIBRATED_X,
        _PHONE_GYROSCOPE_UNCALIBRATED_Y,
        _PHONE_GYROSCOPE_UNCALIBRATED_Z,
        _PHONE_ORIENTATION_X,
        _PHONE_ORIENTATION_Y,
        _PHONE_ORIENTATION_Z,
        _PHONE_MAGNETIC_FIELD_X,
        _PHONE_MAGNETIC_FIELD_Y,
        _PHONE_MAGNETIC_FIELD_Z,
        _PHONE_GRAVITY_X,
        _PHONE_GRAVITY_Y,
        _PHONE_GRAVITY_Z,
        _PHONE_LINEAR_ACCELERATION_X,
        _PHONE_LINEAR_ACCELERATION_Y,
        _PHONE_LINEAR_ACCELERATION_Z,
        _PHONE_PRESSURE,
        _PHONE_GNSS_TIMESTAMP,
        _PHONE_GNSS_LONGITUDE,
        _PHONE_GNSS_LATITUDE,
        _PHONE_GNSS_ACCURACY,
        _PHONE_ALKAID_REQUEST_TIMESTAMP,
        _PHONE_ALKAID_RESPONSIVE_TIMESTAMP,
        _PHONE_ALKAID_MAP_TIMESTAMP,
        _PHONE_ALKAID_STATUS,
        _PHONE_ALKAID_TIMESTAMP,
        _PHONE_ALKAID_SYNCHRONIZE_TIMESTAMP,
        _PHONE_ALKAID_LONGITUDE,
        _PHONE_ALKAID_LATITUDE,
        _PHONE_ALKAID_HEIGHT,
        _PHONE_ALKAID_AZIMUTH,
        _PHONE_ALKAID_SPEED,
        _ALKAID_TIMESTAMP,
        _ALKAID_LONGITUDE,
        _ALKAID_LATITUDE,
        _ALKAID_PROJECT_COORDINATE_X,
        _ALKAID_PROJECT_COORDINATE_Y,
        _ALKAID_PROJECT_COORDINATE_DELTA_X,
        _ALKAID_PROJECT_COORDINATE_DELTA_Y,
        _ALKAID_HEIGHT,
        _ALKAID_AZIMUTH,
        _ALKAID_SPEED,
        _ALKAID_AGE
    ]

    @staticmethod
    def parse_aiimudr_dataset(folder):
        path = osp.join(folder, 'trainVdrExperimentTimeTable.txt')
        custom_raw_data = pd.read_csv(
            path,
            header=0,
            names=CustomDataset._CUSTOM_DATA_NAMES_LIST
        )
        custom_parse_data = custom_raw_data.copy(deep=True)
        custom_parse_data[CustomDataset._DATA_TIMESTAMP] = custom_parse_data[CustomDataset._DATA_TIMESTAMP] \
            .map(custom_timestamp_sec_parser)

        custom_dataset_timestamp = custom_parse_data[CustomDataset._DATA_TIMESTAMP].to_numpy()

        aiimudr_dataset_reference_timestamp = custom_dataset_timestamp[0]
        aiimudr_dataset_timestamp = custom_dataset_timestamp - aiimudr_dataset_reference_timestamp

        aiimudr_dataset_datetime = datetime.utcfromtimestamp(aiimudr_dataset_reference_timestamp)
        aiimudr_dataset_file_name = "{}_drive_{:0>4}_extract".format(aiimudr_dataset_datetime.strftime("%Y_%m_%d"), 1)

        aiimudr_dataset_ground_truth_ang = custom_parse_data.loc[
                                      :,
                                      [CustomDataset._PHONE_ROTATION_VECTOR_X,
                                       CustomDataset._PHONE_ROTATION_VECTOR_Y,
                                       CustomDataset._PHONE_ROTATION_VECTOR_Z
                                       ]].to_numpy()

        aiimudr_dataset_ground_truth_v = custom_parse_data.loc[
                                      :,
                                      [CustomDataset._ALKAID_SPEED,
                                       CustomDataset._ALKAID_SPEED,
                                       CustomDataset._ALKAID_SPEED
                                       ]].to_numpy()

        aiimudr_dataset_ground_truth_p = custom_parse_data.loc[
                                      :,
                                      [CustomDataset._ALKAID_PROJECT_COORDINATE_X,
                                       CustomDataset._ALKAID_PROJECT_COORDINATE_Y,
                                       CustomDataset._ALKAID_HEIGHT
                                       ]].to_numpy()

        aiimudr_dataset_observation = custom_parse_data.loc[
                              :,
                              [CustomDataset._PHONE_GYROSCOPE_X,
                               CustomDataset._PHONE_GYROSCOPE_Y,
                               CustomDataset._PHONE_GYROSCOPE_Z,
                               CustomDataset._PHONE_ACCELEROMETER_X,
                               CustomDataset._PHONE_ACCELEROMETER_Y,
                               CustomDataset._PHONE_ACCELEROMETER_Z
                               ]].to_numpy()

        gyro = aiimudr_dataset_observation[:, 0:3]
        acce = aiimudr_dataset_observation[:, 3:6]

        ori = custom_parse_data.loc[
                              :,
                              [CustomDataset._PHONE_GAME_ROTATION_VECTOR_SCALAR,
                               CustomDataset._PHONE_GAME_ROTATION_VECTOR_X,
                               CustomDataset._PHONE_GAME_ROTATION_VECTOR_Y,
                               CustomDataset._PHONE_GAME_ROTATION_VECTOR_Z
                               ]].to_numpy()
        ori_q1 = quaternion.from_float_array(ori)
        ori_q2 = quaternion.from_euler_angles(np.deg2rad(0), np.deg2rad(0), np.deg2rad(-135))
        ori_q = ori_q2 * ori_q1

        gyro_q = quaternion.from_float_array(np.concatenate([np.zeros([gyro.shape[0], 1]), gyro], axis=1))
        acce_q = quaternion.from_float_array(np.concatenate([np.zeros([acce.shape[0], 1]), acce], axis=1))
        gyro_nav = quaternion.as_float_array(ori_q * gyro_q * ori_q.conj())[:, 1:]
        acce_nav = quaternion.as_float_array(ori_q * acce_q * ori_q.conj())[:, 1:]
        aiimudr_dataset_v = np.concatenate([gyro_nav, acce_nav], axis=1)

        t = torch.from_numpy(aiimudr_dataset_timestamp)
        p_gt = torch.from_numpy(aiimudr_dataset_ground_truth_p)
        v_gt = torch.from_numpy(aiimudr_dataset_ground_truth_v)
        ang_gt = torch.from_numpy(aiimudr_dataset_ground_truth_ang)
        u = torch.from_numpy(aiimudr_dataset_v)

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
