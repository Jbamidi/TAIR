"""
TAIR Simulation Launch File
----------------------------
Launches:
  1. TurtleBot3 Waffle fake_node (ARM64-compatible, no Gazebo required)
     - Publishes /scan (simulated LiDAR), /odom, and TF tree
  2. robot_state_publisher (URDF → /tf static transforms)
  3. slam-toolbox in async mapping mode
  4. RViz2 with TAIR display config

Usage (inside Docker container):
  source /opt/ros/humble/setup.bash
  export TURTLEBOT3_MODEL=waffle
  cd /workspace/ros2_ws && colcon build --packages-select tair_bringup
  source install/setup.bash
  ros2 launch tair_bringup tair_sim.launch.py

Then in a separate terminal to drive the robot:
  ros2 run turtlebot3_teleop teleop_keyboard
"""

import os
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():
    # ── Paths ────────────────────────────────────────────────────────────────
    tair_bringup_dir = get_package_share_directory('tair_bringup')
    turtlebot3_fake_dir = get_package_share_directory('turtlebot3_fake_node')
    turtlebot3_desc_dir = get_package_share_directory('turtlebot3_description')

    slam_params_file = os.path.join(tair_bringup_dir, 'config', 'slam_toolbox_params.yaml')
    rviz_config_file = os.path.join(tair_bringup_dir, 'config', 'rviz_config.rviz')
    fake_node_params = os.path.join(turtlebot3_fake_dir, 'param', 'waffle.yaml')
    urdf_file = os.path.join(turtlebot3_desc_dir, 'urdf', 'turtlebot3_waffle.urdf')

    # ── Launch arguments ─────────────────────────────────────────────────────
    use_sim_time = LaunchConfiguration('use_sim_time', default='false')

    declare_use_sim_time = DeclareLaunchArgument(
        'use_sim_time',
        default_value='false',
        description='Use simulation clock (false for fake_node)',
    )

    # ── 1. robot_state_publisher ─────────────────────────────────────────────
    with open(urdf_file, 'r') as f:
        robot_description = f.read()

    robot_state_publisher = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        output='screen',
        parameters=[{
            'use_sim_time': use_sim_time,
            'robot_description': robot_description,
        }],
    )

    # ── 2. TurtleBot3 fake_node ──────────────────────────────────────────────
    fake_node = Node(
        package='turtlebot3_fake_node',
        executable='turtlebot3_fake_node',
        name='turtlebot3_fake_node',
        output='screen',
        parameters=[fake_node_params, {'use_sim_time': use_sim_time}],
    )

    # ── 3. slam-toolbox (async mapping mode) ─────────────────────────────────
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

    # ── 4. RViz2 ─────────────────────────────────────────────────────────────
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
        robot_state_publisher,
        fake_node,
        slam_toolbox_node,
        rviz_node,
    ])
