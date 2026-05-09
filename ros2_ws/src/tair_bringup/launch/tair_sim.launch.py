"""
TAIR Simulation Launch File
----------------------------
Launches:
  1. TurtleBot3 Waffle in Gazebo (warehouse-like world)
  2. slam-toolbox in async mapping mode
  3. RViz2 with TAIR display config

Usage (inside Docker container):
  source /opt/ros/humble/setup.bash
  export TURTLEBOT3_MODEL=waffle
  cd /workspace/ros2_ws && colcon build --packages-select tair_bringup
  source install/setup.bash
  ros2 launch tair_bringup tair_sim.launch.py

Then in a separate terminal:
  ros2 run turtlebot3_teleop teleop_keyboard
"""

import os
from launch import LaunchDescription
from launch.actions import (
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    SetEnvironmentVariable,
)
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():
    # ── Paths ────────────────────────────────────────────────────────────────
    tair_bringup_dir = get_package_share_directory('tair_bringup')
    turtlebot3_gazebo_dir = get_package_share_directory('turtlebot3_gazebo')

    slam_params_file = os.path.join(tair_bringup_dir, 'config', 'slam_toolbox_params.yaml')
    rviz_config_file = os.path.join(tair_bringup_dir, 'config', 'rviz_config.rviz')

    # ── Launch arguments ─────────────────────────────────────────────────────
    use_sim_time = LaunchConfiguration('use_sim_time', default='true')

    declare_use_sim_time = DeclareLaunchArgument(
        'use_sim_time',
        default_value='true',
        description='Use simulation (Gazebo) clock',
    )

    # ── 1. TurtleBot3 in Gazebo ──────────────────────────────────────────────
    gazebo_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(turtlebot3_gazebo_dir, 'launch', 'turtlebot3_world.launch.py')
        ),
    )

    # ── 2. slam-toolbox (async mapping mode) ─────────────────────────────────
    slam_toolbox_node = Node(
        package='slam_toolbox',
        executable='async_slam_toolbox_node',
        name='slam_toolbox',
        output='screen',
        parameters=[
            slam_params_file,
            {'use_sim_time': use_sim_time},
        ],
    )

    # ── 3. RViz2 ─────────────────────────────────────────────────────────────
    rviz_node = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        output='screen',
        arguments=['-d', rviz_config_file],
        parameters=[{'use_sim_time': use_sim_time}],
    )

    # ── Assemble ─────────────────────────────────────────────────────────────
    return LaunchDescription([
        declare_use_sim_time,
        gazebo_launch,
        slam_toolbox_node,
        rviz_node,
    ])
