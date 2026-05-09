"""
TAIR Localization Launch File
------------------------------
Launches TurtleBot3 in Gazebo + slam-toolbox in LOCALIZATION mode
using a previously saved map.

Usage:
  ros2 launch tair_bringup tair_localize.launch.py map_file:=/workspace/maps/sim_warehouse_v1

The map_file argument should point to the .yaml file (without extension)
saved by map_saver_cli.
"""

import os
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():
    tair_bringup_dir = get_package_share_directory('tair_bringup')
    turtlebot3_gazebo_dir = get_package_share_directory('turtlebot3_gazebo')

    slam_params_file = os.path.join(tair_bringup_dir, 'config', 'slam_toolbox_params.yaml')
    rviz_config_file = os.path.join(tair_bringup_dir, 'config', 'rviz_config.rviz')

    use_sim_time = LaunchConfiguration('use_sim_time', default='true')
    map_file = LaunchConfiguration('map_file')

    # ── Launch arguments ─────────────────────────────────────────────────────
    declare_use_sim_time = DeclareLaunchArgument(
        'use_sim_time', default_value='true',
    )
    declare_map_file = DeclareLaunchArgument(
        'map_file',
        default_value='/workspace/maps/sim_warehouse_v1',
        description='Path to saved map file (without .yaml/.pgm extension)',
    )

    # ── TurtleBot3 in Gazebo ─────────────────────────────────────────────────
    gazebo_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(turtlebot3_gazebo_dir, 'launch', 'turtlebot3_world.launch.py')
        ),
    )

    # ── slam-toolbox in LOCALIZATION mode ────────────────────────────────────
    slam_localization_node = Node(
        package='slam_toolbox',
        executable='localization_slam_toolbox_node',
        name='slam_toolbox',
        output='screen',
        parameters=[
            slam_params_file,
            {
                'use_sim_time': use_sim_time,
                'mode': 'localization',
                'map_file_name': map_file,
            },
        ],
    )

    # ── RViz2 ────────────────────────────────────────────────────────────────
    rviz_node = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        output='screen',
        arguments=['-d', rviz_config_file],
        parameters=[{'use_sim_time': use_sim_time}],
    )

    return LaunchDescription([
        declare_use_sim_time,
        declare_map_file,
        gazebo_launch,
        slam_localization_node,
        rviz_node,
    ])
