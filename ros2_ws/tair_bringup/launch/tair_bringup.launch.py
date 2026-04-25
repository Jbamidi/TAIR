import os
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare

def generate_launch_description():

    # LiDAR node
    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([
            FindPackageShare('ldlidar_stl_ros2'),
            '/launch/stl27l.launch.py'
        ])
    )

    # IMU node
    imu_node = Node(
        package='mpu6050driver',
        executable='mpu6050driver',
        name='imu_publisher',
        output='screen',
        parameters=[
            os.path.join(
                os.path.expanduser('~'),
                'tair_ws/src/tair_bringup/config/mpu6050.yaml'
            )
        ]
    )

    # SLAM Toolbox node
    slam_node = Node(
        package='slam_toolbox',
        executable='async_slam_toolbox_node',
        name='slam_toolbox',
        output='screen',
        parameters=[
            os.path.join(
                os.path.expanduser('~'),
                'tair_ws/src/tair_bringup/config/slam_toolbox.yaml'
            )
        ]
    )

    return LaunchDescription([
        lidar_launch,
        imu_node,
        slam_node,
    ])
