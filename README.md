# TAIR — Autonomous Indoor Intelligence Platform

Autonomous warehouse intelligence platform. A push-cart (Phase 1) or drone (Phase 2) scans warehouses with LiDAR + barcode + RFID, builds a digital twin, reconciles against the WMS, and pushes corrected inventory before the morning shift.

**Stage:** Pre-seed, Phase 1 (Ground Cart POC)
**Team:** 2 founders — Jashwanth (hardware), Hemal (software)
**GitHub:** Private repo

---

## Quick Start (Dev Environment)

Primary setup: **macOS Apple Silicon** with ROS2 Humble running in **Docker** (ARM64 native). RViz2 available via **noVNC** in your browser.

```bash
# Build and start the dev container
docker compose up -d --build ros2_vnc

# Open RViz/Gazebo desktop in browser
open http://localhost:6080/vnc.html

# Enter the container
docker exec -it tair_ros2_vnc bash

# Build the ROS2 workspace (inside container)
cd /workspace/ros2_ws
colcon build
source install/setup.bash

# Launch simulation with SLAM
ros2 launch tair_bringup tair_sim.launch.py

# In another terminal — drive the robot
ros2 run turtlebot3_teleop teleop_keyboard
```

---

## Repo Layout

```
TAIR/
├── ros2_ws/                    # ROS2 workspace
│   └── src/
│       └── tair_bringup/       # Master launch package (sim + SLAM + RViz)
├── backend/                    # FastAPI + PostgreSQL (coming Week 3)
├── dashboard/                  # React + Three.js digital twin (coming Week 4)
├── docs/
│   ├── INTERFACE.md            # Integration contract (topics, frames, APIs)
│   └── development-environment.md
├── hardware/                   # Hardware notes and BOM
├── scripts/                    # Docker helper scripts
├── Dockerfile                  # ROS2 Humble + Gazebo + TurtleBot3
├── docker-compose.yml
├── TAIR_Context.md             # Full project context (drop into any AI chat)
├── HEMAL_CONTEXT.md            # Hemal's working context + current sprint
└── HEMAL_TASK_CHECKLIST.md     # Task checklist with prompts
```

---

## Context Files

| File | Purpose |
|---|---|
| `TAIR_Context.md` | Full project context — company, tech stack, business model, roadmap |
| `HEMAL_CONTEXT.md` | Hemal's working context — current state, sprint plan, schemas |
| `HEMAL_TASK_CHECKLIST.md` | Detailed task checklist with copy-paste prompts for Cursor/Claude |
| `docs/INTERFACE.md` | Integration contract — ROS2 topics, TF frames, API shapes, sensor ports |

Drop any of these into a new Claude or Cursor session for instant context.
