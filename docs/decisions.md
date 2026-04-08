# Technical Decisions Log

## Decision: Compute Platform

- Date: 2026-04-08
- Decision: Orange Pi 5 (fallback: Raspberry Pi 5)
- Reason: Sufficient for 2D SLAM, ROS2 compatible, lighter and cheaper than Jetson Orin NX
- Alternatives: Jetson Orin NX (overkill Phase 1), Raspberry Pi 4 (too slow for ROS2)

## Decision: LiDAR Sensor

- Date: 2026-04-08
- Decision: RPLiDAR S2 ($199)
- Reason: Budget-friendly, USB 3.0, well-supported in ROS2, adequate range for warehouse POC
- Alternatives: Livox Mid-360 (too expensive for Phase 1), depth camera (poor performance on reflective warehouse surfaces)

## Decision: SLAM Algorithm

- Date: 2026-04-08
- Decision: Hector SLAM for Phase 1
- Reason: Works with 2D LiDAR only (no odometry needed), well documented, easy to tune
- Alternatives: Cartographer (overkill), FAST-LIO2 (needs 3D LiDAR)
