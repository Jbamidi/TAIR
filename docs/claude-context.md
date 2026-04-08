# Claude Context — DIM Project

## Always Start Sessions With This File

### Project

Autonomous indoor drone mapping startup. POC goal: cart moves through room, real-time map on screen, floor plan exportable.

### Team

- Hemal: CS, software lead, Mac Mini M4, Cursor, Docker
- Jashwanth: EE/ECE, hardware lead, sensor wiring, FPGA

### Hardware (Phase 1)

- RPLiDAR S2 — 2D LiDAR, USB 3.0, 10Hz scan rate
- MPU-9250 — IMU, I2C, connected to GPIO
- Raspberry Pi Camera v3 — CSI ribbon cable
- Orange Pi 5 / Raspberry Pi 5 — runs Ubuntu 22.04 + ROS2

### ROS2 Topic Map

- /scan — LaserScan from RPLiDAR S2
- /imu/data — Imu from MPU-9250
- /image_raw — Image from Pi Camera
- /map — OccupancyGrid from Hector SLAM
- /odom — Odometry from SLAM
- /tf — Transform tree

### Data Pipeline

RPLiDAR → /scan → Sensor Fusion → Hector SLAM → /map → RViz (live) → PNG export

### Dev Environment

- Hemal: Mac Mini M4, Docker Ubuntu 22.04 ARM64
- ROS2 Humble inside Docker container
- GUI tools (RViz) run via Docker container + **noVNC** (browser at `http://localhost:6080/vnc.html`)
- Cursor: edit code on macOS; build/run inside container
- Repo: github.com/Jbamidi/Indoor-Drone-Startup

### Current Build Status

Docker + ROS 2 Humble dev environment is set up (ARM64). RViz works via noVNC.
Next step: add a first ROS 2 package/node in `ros2_ws` (e.g. simulated LiDAR), then integrate SLAM + navigation.
