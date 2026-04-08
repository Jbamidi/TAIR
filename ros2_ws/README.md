# ROS2 Workspace

Built with ROS2 Humble on Ubuntu 22.04.

## Structure

- sensors/ — LiDAR and IMU driver nodes
- slam/ — Hector SLAM config and launch files
- navigation/ — Path planning, autonomous movement
- ai/ — Semantic labeling, change detection (Phase 3 only)

## Build

```
cd ros2_ws
colcon build
source install/setup.bash
```

## Launch (Phase 1)

```
ros2 launch slam/launch/mapping.launch.py
```
