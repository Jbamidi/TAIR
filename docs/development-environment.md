# Development Environment (Mac Mini M4 / Apple Silicon)

This repo is developed on macOS with **ROS 2 Humble (Ubuntu 22.04)** running in a **Docker Desktop** Linux VM (ARM64).

## Prereqs (macOS)

- Docker Desktop installed and running
- A web browser (for RViz via noVNC)

### Check commands

```bash
docker --version
docker info
```

### Install commands (Homebrew)

```bash
brew install --cask docker
```

## Start the ROS 2 dev containers

This repo supports two dev containers:

- `ros2_vnc` (**recommended**): runs RViz in a virtual desktop you access in your browser (noVNC)
- `ros2` (optional): CLI ROS 2 container (no GUI)

From the repo root:

```bash
docker compose up -d --build ros2_vnc
```

## ROS 2 workspace layout

- Repo root is mounted into the container at `/workspace`
- ROS 2 workspace folder: `/workspace/ros2_ws`

## Build & run (inside the container)

Enter the container:

```bash
docker exec -it dim_ros2_vnc bash
```

Build:

```bash
cd /workspace/ros2_ws
colcon build
source install/setup.bash
```

## RViz on macOS

### Recommended: noVNC (works reliably on Apple Silicon)

This runs a virtual display + VNC server inside the container, and you view it in your browser.

Start the VNC stack:

```bash
docker compose up -d --build ros2_vnc
```

Open the noVNC web client at `http://localhost:6080/vnc.html` and click **Connect**.

Inside the VNC container:

```bash
docker exec -it dim_ros2_vnc bash
rviz2
```

### Optional: XQuartz (X11 apps; RViz often fails)

XQuartz can be useful for simple X11 apps, but RViz frequently fails on macOS+XQuartz due to GLX/OpenGL limitations. Prefer noVNC for RViz.

## Troubleshooting

### noVNC page doesn’t load

- Confirm the container is running and port 6080 is published:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker logs dim_ros2_vnc --tail 200
```

### RViz: OpenGL / GLX errors

- Use the **`ros2_vnc`** container and run RViz inside it.
- Verify OpenGL software renderer is available:

```bash
docker exec -it dim_ros2_vnc bash
glxinfo -B
```

If `glxinfo -B` shows Mesa `llvmpipe` and OpenGL 3.x, RViz should start.

