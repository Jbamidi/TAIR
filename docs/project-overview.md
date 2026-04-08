# DIM — Dynamic Indoor Mapping

## One-Line Pitch

"We autonomously remap your warehouse at night so your floor plans, digital twins, and robot navigation are always accurate — without stopping operations."

## Team

- Hemal (CS background) — Software lead
- Jashwanth (EE/ECE background) — Hardware & embedded lead

## Current Phase

Phase 1 — Ground Cart POC

## Demo Success Criteria

1. Cart moves through a real space
2. Real-time map appears on laptop screen as it moves
3. Final floor plan is accurate and exportable as PNG/PGM

## Tech Stack

- Hardware: RPLiDAR S2, MPU-9250 IMU, Orange Pi 5, Raspberry Pi Camera v3
- OS: Ubuntu 22.04 (Docker on Mac for dev)
- Middleware: ROS2 Humble
- SLAM: Hector SLAM
- Visualization: RViz
- Language: Python (nodes), future C++ for performance
- Future: React + Three.js dashboard, REST API

## Phase Roadmap

- Phase 1 (~$534): Ground cart, 2D SLAM, demoable floor plan
- Phase 2 (~$1,137): Add drone, autonomous flight
- Phase 3 (~$5,934): 3D LiDAR, AI semantic labeling, dashboard
