# Indoor Drone Startup (DIM)

ROS 2 Humble project for indoor mapping/navigation. Primary dev setup is **macOS (Apple Silicon)** with ROS 2 running in **Docker** and RViz available via **noVNC** in your browser.

## Quick start (recommended)

See `docs/development-environment.md` for the full setup.

From the repo root:

```bash
docker compose up -d --build ros2_vnc
```

Open RViz desktop in browser:

- `http://localhost:6080/vnc.html` → **Connect**

Enter the container:

```bash
docker exec -it dim_ros2_vnc bash
```

Build the workspace:

```bash
cd /workspace/ros2_ws
colcon build
source install/setup.bash
```

Run RViz:

```bash
rviz2
```

## Repo layout

- `ros2_ws/`: ROS 2 workspace (packages live here)
- `docs/`: project documentation
- `hardware/`: hardware notes and wiring
- `dashboard/`: future UI/dashboard work

