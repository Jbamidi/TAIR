# Hemal's Task Checklist — TAIR Pre-Bay Sprint

**Created:** May 9, 2026
**Last Updated:** May 9, 2026 (by Claude Cowork session)
**Sprint:** 4 weeks (~10 hrs/week = ~40 total hours)
**Deadline:** Bay reunion with Jashwanth (early June 2026)

---

## Prerequisites (Do These First)

### P1. Revoke Exposed GitHub Token
- [ ] **Status:** NOT DONE
- **Time:** 5 min
- **Tool:** Browser
- **Steps:**
  1. Go to https://github.com/settings/tokens
  2. Find and **delete/revoke** the token you shared in chat
  3. Generate a **new** fine-grained PAT scoped to the `Jbamidi/TAIR` repo (read/write for Contents, Pull requests, Issues)
  4. Store it securely (macOS Keychain, 1Password, or `~/.config/gh/hosts.yml`)

### P2. Set Up GitHub MCP in Claude Code (Optional but Recommended)
- [ ] **Status:** NOT DONE
- **Time:** 15 min
- **Tool:** Terminal + Claude Code
- **Steps:**
  1. Install the GitHub MCP server: `npm install -g @anthropic-ai/github-mcp-server` (or check latest instructions at https://docs.claude.com)
  2. Add to your Claude Code config (`~/.claude/mcp_servers.json`):
     ```json
     {
       "github": {
         "command": "github-mcp-server",
         "env": {
           "GITHUB_TOKEN": "your-new-token-here"
         }
       }
     }
     ```
  3. Restart Claude Code — verify with: "List open issues on Jbamidi/TAIR"

### P3. Verify Docker Desktop is Running
- [ ] **Status:** NOT DONE
- **Time:** 2 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  docker --version && docker info | head -5
  ```

### P4. Create Your Working Branch
- [ ] **Status:** NOT DONE — do this before rebuilding Docker
- **Time:** 2 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  git checkout -b hemal/phase1-setup
  git push -u origin hemal/phase1-setup
  ```

---

## Week 1: Fix Simulation Environment (~10 hrs)

### 1.1 Upgrade Dockerfile for Gazebo + TurtleBot3
- [x] **Status:** DONE (May 9 — Claude Cowork)
- **Time:** 1-2 hrs
- **Tool:** Cursor (with Claude) or Claude Code
- **What:** Update the Dockerfile to install Gazebo Classic 11 + TurtleBot3 packages + slam-toolbox + Nav2 map server + teleop
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  I need to update my Dockerfile and docker-compose.yml to add Gazebo simulation support.
  The current Dockerfile is at the repo root and uses `ros:humble-ros-base-jammy` (ARM64).

  Add these packages to the Dockerfile:
  - ros-humble-gazebo-ros-pkgs (Gazebo Classic 11 + ROS2 bridge)
  - ros-humble-turtlebot3-gazebo
  - ros-humble-turtlebot3-description
  - ros-humble-turtlebot3-navigation2
  - ros-humble-turtlebot3-teleop
  - ros-humble-slam-toolbox
  - ros-humble-nav2-map-server
  - ros-humble-teleop-twist-keyboard

  Also add these environment variables to the docker-compose.yml ros2_vnc service:
  - TURTLEBOT3_MODEL=waffle
  - GAZEBO_MODEL_PATH=/opt/ros/humble/share/turtlebot3_gazebo/models

  Keep the existing noVNC/RViz setup intact. Don't remove anything that already works.
  ```

### 1.2 Rebuild and Test Container
- [ ] **Status:** NOT DONE
- **Time:** 30 min (mostly waiting for build)
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  docker compose down
  docker compose up -d --build ros2_vnc
  docker exec -it dim_ros2_vnc bash
  # Inside container:
  echo $TURTLEBOT3_MODEL  # Should print "waffle"
  ros2 pkg list | grep -E "turtlebot3|gazebo|slam"
  ```

### 1.3 Launch TurtleBot3 in Gazebo Warehouse World
- [ ] **Status:** NOT DONE
- **Time:** 1 hr
- **Tool:** Terminal (inside Docker container) + noVNC browser
- **Prompt (Terminal inside container):**
  ```bash
  source /opt/ros/humble/setup.bash
  export TURTLEBOT3_MODEL=waffle
  ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
  ```
  Then open `http://localhost:6080/vnc.html` to see the Gazebo GUI.

  If Gazebo GUI doesn't render (common on ARM64 Docker), run headless:
  ```bash
  # In one terminal:
  ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py use_sim_time:=true
  # In another terminal:
  ros2 topic list  # Verify /scan, /odom, /tf etc. are publishing
  ros2 topic echo /scan --once  # Verify LiDAR data
  ```

### 1.4 View Simulated LiDAR in RViz2
- [ ] **Status:** NOT DONE
- **Time:** 30 min
- **Tool:** noVNC browser + Terminal
- **Steps:**
  1. Open `http://localhost:6080/vnc.html`
  2. In a new terminal inside the container:
     ```bash
     rviz2
     ```
  3. In RViz2: Add → By topic → `/scan` → `LaserScan`
  4. Set Fixed Frame to `odom` or `base_link`
  5. You should see the simulated LiDAR scan

### 1.5 Drive the Robot with Teleop
- [ ] **Status:** NOT DONE
- **Time:** 30 min
- **Tool:** Terminal (inside container)
- **Prompt (Terminal inside container):**
  ```bash
  # In a new terminal:
  source /opt/ros/humble/setup.bash
  export TURTLEBOT3_MODEL=waffle
  ros2 run turtlebot3_teleop teleop_keyboard
  ```
  Use WASD keys to drive the robot around the Gazebo world.

### 1.6 Create tair_bringup Package (Skeleton)
- [x] **Status:** DONE (May 9 — Claude Cowork) — package.xml, CMakeLists.txt, tair_sim.launch.py, tair_localize.launch.py, slam_toolbox_params.yaml, rviz_config.rviz all created
- **Time:** 1-2 hrs
- **Tool:** Cursor (with Claude) or Claude Code
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Create a ROS2 Python package called `tair_bringup` in `ros2_ws/src/tair_bringup/`.
  This is the master launch package for the TAIR project.

  For now, create a launch file that wraps the TurtleBot3 Gazebo launch with our SLAM config.
  The launch file should:
  1. Launch TurtleBot3 in Gazebo (turtlebot3_gazebo turtlebot3_world.launch.py)
  2. Launch slam-toolbox in async mode with a custom config
  3. Launch RViz2 with a saved config that shows /scan and /map

  Create these files:
  - ros2_ws/src/tair_bringup/package.xml
  - ros2_ws/src/tair_bringup/CMakeLists.txt (or setup.py for Python package)
  - ros2_ws/src/tair_bringup/launch/tair_sim.launch.py
  - ros2_ws/src/tair_bringup/config/slam_toolbox_params.yaml (0.05m resolution, 20m max range, loop closing on)
  - ros2_ws/src/tair_bringup/config/rviz_config.rviz (show /scan LaserScan + /map OccupancyGrid)

  Use ROS2 Humble conventions. The package should build with `colcon build`.
  ```

### 1.7 Build and Test tair_bringup
- [ ] **Status:** NOT DONE
- **Time:** 30 min
- **Tool:** Terminal (inside container)
- **Prompt (Terminal inside container):**
  ```bash
  cd /workspace/ros2_ws
  colcon build --packages-select tair_bringup
  source install/setup.bash
  ros2 launch tair_bringup tair_sim.launch.py
  ```

### 1.8 Record Screen Recording (Week 1 Deliverable)
- [ ] **Status:** NOT DONE
- **Time:** 15 min
- **Tool:** macOS Screen Recording (Cmd+Shift+5) on the noVNC browser window
- **Capture:** The Gazebo world + RViz2 showing simulated LiDAR scan

### 1.9 Commit and Push
- [ ] **Status:** NOT DONE
- **Time:** 5 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  git add -A
  git commit -m "feat: Gazebo sim + tair_bringup package + slam-toolbox config"
  git push
  ```

---

## Week 2: SLAM Pipeline in Simulation (~10 hrs)

### 2.1 Run slam-toolbox and Build a Map
- [ ] **Status:** NOT DONE
- **Time:** 2 hrs
- **Tool:** Terminal (inside container) + noVNC
- **Steps:**
  1. Launch the sim: `ros2 launch tair_bringup tair_sim.launch.py`
  2. In another terminal, drive with teleop: `ros2 run turtlebot3_teleop teleop_keyboard`
  3. Watch RViz2 — the `/map` topic should show the occupancy grid building in real-time
  4. Drive the robot through the entire Gazebo world

### 2.2 Save the Map
- [ ] **Status:** NOT DONE
- **Time:** 15 min
- **Tool:** Terminal (inside container)
- **Prompt (Terminal inside container):**
  ```bash
  mkdir -p /workspace/maps
  ros2 run nav2_map_server map_saver_cli -f /workspace/maps/sim_warehouse_v1
  # This creates sim_warehouse_v1.pgm + sim_warehouse_v1.yaml
  ```

### 2.3 Test Localization Mode (Reload Map)
- [ ] **Status:** NOT DONE
- **Time:** 1-2 hrs
- **Tool:** Cursor + Terminal
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  I need to create a second launch file for localization mode (not mapping mode).
  Create `ros2_ws/src/tair_bringup/launch/tair_localize.launch.py` that:
  1. Launches TurtleBot3 in Gazebo
  2. Launches slam-toolbox in LOCALIZATION mode (not mapping mode)
  3. Loads a pre-saved map from /workspace/maps/
  4. Launches RViz2

  The key slam-toolbox parameter difference is:
  - mode: localization (not mapping)
  - map_file_name: /workspace/maps/sim_warehouse_v1
  ```

### 2.4 Tune SLAM Parameters
- [ ] **Status:** NOT DONE
- **Time:** 2 hrs
- **Tool:** Cursor + Terminal (iterative tuning)
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Help me tune the slam-toolbox parameters in
  ros2_ws/src/tair_bringup/config/slam_toolbox_params.yaml

  The target environment is a warehouse with:
  - Large featureless aisles
  - Repetitive racking structures
  - 20m max LiDAR range
  - 0.05m desired map resolution

  Key parameters to tune:
  - resolution: 0.05
  - max_laser_range: 20.0
  - minimum_travel_distance: 0.3 (don't update too frequently)
  - minimum_travel_heading: 0.3
  - do_loop_closing: true
  - loop_search_maximum_distance: 3.0
  - use_scan_matching: true
  - scan_buffer_size: 10

  Explain each parameter and why these values work for warehouse environments.
  ```

### 2.5 Record a ROS Bag of a Full SLAM Run
- [ ] **Status:** NOT DONE
- **Time:** 30 min
- **Tool:** Terminal (inside container)
- **Prompt (Terminal inside container):**
  ```bash
  # While sim + SLAM are running:
  ros2 bag record /scan /odom /tf /tf_static /map -o /workspace/bags/sim_slam_run_1
  # Drive around, then Ctrl+C when done
  ```

### 2.6 Screen Recording + Commit (Week 2 Deliverable)
- [ ] **Status:** NOT DONE
- **Time:** 15 min
- **Tool:** macOS + Terminal
- **Steps:**
  1. Record screen of SLAM building a map in RViz2
  2. Commit:
     ```bash
     cd ~/Desktop/Repos/TAIR
     git add -A
     git commit -m "feat: SLAM pipeline working in sim, map saved, localization tested"
     git push
     ```

---

## Week 3: Cloud Backend Scaffold (~10 hrs)

### 3.1 Scaffold FastAPI Project
- [ ] **Status:** NOT DONE
- **Time:** 2-3 hrs
- **Tool:** Cursor (with Claude) — this is a big one, let Cursor generate the whole scaffold
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context. Pay special attention to the FastAPI
  Endpoints and PostgreSQL Schema sections.

  Create a complete FastAPI backend scaffold in the `backend/` directory at the repo root.
  This is the cloud backend for the TAIR warehouse intelligence platform.

  Create this structure:
  backend/
  ├── app/
  │   ├── __init__.py
  │   ├── main.py              # FastAPI app with CORS, health check
  │   ├── database.py          # SQLAlchemy async engine + session
  │   ├── models.py            # SQLAlchemy models (facilities, maps, scans, detections)
  │   ├── schemas.py           # Pydantic schemas for request/response
  │   └── routers/
  │       ├── __init__.py
  │       ├── scans.py         # POST /api/scans, GET /api/scans, GET /api/scans/{id}
  │       ├── inventory.py     # GET /api/inventory, GET /api/discrepancies
  │       └── maps.py          # GET /api/maps/{id}
  ├── alembic/                 # DB migrations (optional but nice)
  │   └── ...
  ├── Dockerfile
  ├── docker-compose.yml       # FastAPI + PostgreSQL
  ├── requirements.txt
  ├── .env.example
  └── README.md

  Requirements:
  - FastAPI with uvicorn
  - SQLAlchemy 2.0 (async) with asyncpg
  - PostgreSQL 15
  - Pydantic v2
  - UUID primary keys
  - Docker Compose for local dev (FastAPI on port 8000, PostgreSQL on 5432)
  - CORS enabled for localhost:5173 (Vite dev server) and any Vercel domain
  - GET /api/healthcheck returns {"status": "ok", "version": "0.1.0"}

  Use the exact schema from HEMAL_CONTEXT.md. Include seed data for testing
  (one facility, one map with fake occupancy grid data, one scan with 5 fake barcode detections).
  ```

### 3.2 Run and Test Backend Locally
- [ ] **Status:** NOT DONE
- **Time:** 30 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR/backend
  docker compose up -d --build
  # Wait for startup, then:
  curl http://localhost:8000/api/healthcheck
  curl http://localhost:8000/api/scans
  curl http://localhost:8000/api/inventory
  ```

### 3.3 Create ROS2 Cloud Bridge Node
- [ ] **Status:** NOT DONE
- **Time:** 2 hrs
- **Tool:** Cursor (with Claude)
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Create a ROS2 Python package called `tair_cloud_bridge` in `ros2_ws/src/tair_cloud_bridge/`.

  This node reads a rosbag file and uploads the scan data to the FastAPI backend.
  It should:
  1. Read a rosbag containing /scan, /map, /odom topics
  2. Extract the final occupancy grid from /map
  3. Extract any barcode detections (for now, generate fake ones at random positions on the map)
  4. POST the map data to http://localhost:8000/api/scans with the map + detections
  5. Print confirmation when upload succeeds

  Use the `rosbag2_py` API for reading bags.
  Use `requests` or `httpx` for HTTP calls.
  Include a simple CLI entry point: `ros2 run tair_cloud_bridge upload_bag --bag-path /workspace/bags/sim_slam_run_1`

  This is a ROS2 Python package (ament_python), not C++.
  ```

### 3.4 Test End-to-End Pipeline (Sim → Bag → Backend)
- [ ] **Status:** NOT DONE
- **Time:** 1 hr
- **Tool:** Terminal
- **Steps:**
  1. Make sure the FastAPI backend is running (`cd backend && docker compose up -d`)
  2. Enter the ROS2 container:
     ```bash
     docker exec -it dim_ros2_vnc bash
     cd /workspace/ros2_ws
     colcon build --packages-select tair_cloud_bridge
     source install/setup.bash
     ros2 run tair_cloud_bridge upload_bag --bag-path /workspace/bags/sim_slam_run_1
     ```
  3. Verify data in PostgreSQL:
     ```bash
     curl http://localhost:8000/api/scans | python3 -m json.tool
     ```

### 3.5 Deploy Backend to Railway (Stretch)
- [ ] **Status:** NOT DONE
- **Time:** 1-2 hrs
- **Tool:** Browser + Claude Cowork
- **Claude Cowork Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Help me deploy the FastAPI backend (in the `backend/` directory of my TAIR repo)
  to Railway. I need:
  1. A Railway project with two services: FastAPI app + PostgreSQL
  2. Environment variables configured (DATABASE_URL, etc.)
  3. The FastAPI app accessible at a public URL
  4. GET /api/healthcheck responding successfully

  Walk me through the Railway setup step by step.
  ```

### 3.6 Commit (Week 3 Deliverable)
- [ ] **Status:** NOT DONE
- **Time:** 5 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  git add -A
  git commit -m "feat: FastAPI backend + PostgreSQL + cloud bridge node + Railway deploy"
  git push
  ```

---

## Week 4: React + Three.js Dashboard (~10 hrs)

### 4.1 Scaffold React + Vite + Three.js Project
- [ ] **Status:** NOT DONE
- **Time:** 2-3 hrs
- **Tool:** Cursor (with Claude)
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Create a React + TypeScript dashboard in the `dashboard/` directory at the repo root.
  Delete the existing `dashboard/initial.txt` and `dashboard/README.md` files first.

  Use Vite (NOT Create React App). Set up:
  - React 18 + TypeScript
  - @react-three/fiber + @react-three/drei for 3D rendering
  - Tailwind CSS for styling
  - A simple API client that fetches from the FastAPI backend

  Create this structure:
  dashboard/
  ├── src/
  │   ├── App.tsx                    # Main app with layout
  │   ├── main.tsx                   # Entry point
  │   ├── components/
  │   │   ├── WarehouseMap.tsx       # Three.js scene - renders occupancy grid as a 2D top-down view
  │   │   ├── DetectionMarkers.tsx   # Overlay markers for barcode/RFID detections on the map
  │   │   └── Sidebar.tsx           # List of detections, accuracy score, last scan timestamp
  │   ├── api/
  │   │   └── client.ts             # Fetch from FastAPI (configurable base URL)
  │   └── types/
  │       └── index.ts              # TypeScript types matching Pydantic schemas
  ├── index.html
  ├── package.json
  ├── tsconfig.json
  ├── vite.config.ts
  ├── tailwind.config.js
  └── postcss.config.js

  Color palette (match TAIR brand):
  - Background: #0A0A0B
  - Surfaces: #111114
  - Primary text: #EDEDED
  - Secondary text: #9A9A9F
  - Accent: #00D4FF

  The WarehouseMap component should:
  1. Fetch a map from GET /api/maps/{id} (use a hardcoded ID for now)
  2. Render the occupancy grid as a plane with the grid data as a texture
  3. Overlay detection markers as colored dots/icons at their (x, y) positions
  4. OrbitControls for pan/zoom

  The Sidebar should show:
  - Facility name
  - Last scan timestamp
  - Number of detections
  - List of detections with tag values
  - An "accuracy score" (fake: 94.2%)

  Use FAKE data if the backend isn't running — hard-code a sample response as fallback.
  The API base URL should come from an env var: VITE_API_URL (default: http://localhost:8000).
  ```

### 4.2 Run Dashboard Locally
- [ ] **Status:** NOT DONE
- **Time:** 15 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR/dashboard
  npm install
  npm run dev
  # Open http://localhost:5173
  ```

### 4.3 Connect Dashboard to Live Backend
- [ ] **Status:** NOT DONE
- **Time:** 1 hr
- **Tool:** Cursor + Terminal
- **Steps:**
  1. Start the backend: `cd ~/Desktop/Repos/TAIR/backend && docker compose up -d`
  2. Start the dashboard: `cd ~/Desktop/Repos/TAIR/dashboard && VITE_API_URL=http://localhost:8000 npm run dev`
  3. Verify the dashboard fetches and renders real data from the backend
  4. Debug any CORS or data shape issues

### 4.4 Deploy Dashboard to Vercel
- [ ] **Status:** NOT DONE
- **Time:** 1 hr
- **Tool:** Browser + Terminal
- **Claude Cowork Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Help me deploy the React dashboard (in the `dashboard/` directory) to Vercel.
  I need:
  1. Vercel project pointing to the dashboard/ subdirectory of my GitHub repo
  2. Environment variable VITE_API_URL set to my Railway backend URL
  3. A public URL showing the dashboard

  Walk me through the Vercel setup step by step.
  ```

### 4.5 Polish and Record Demo (Week 4 Deliverable)
- [ ] **Status:** NOT DONE
- **Time:** 1 hr
- **Tool:** Browser + macOS Screen Recording
- **Steps:**
  1. Open the deployed Vercel URL
  2. Record a screen recording showing the dashboard with the warehouse map and detections
  3. This recording is a demo asset for gradCapital video and Awesome Foundation pitch

### 4.6 Commit (Week 4 Deliverable)
- [ ] **Status:** NOT DONE
- **Time:** 5 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  git add -A
  git commit -m "feat: React + Three.js dashboard with warehouse map visualization"
  git push
  ```

---

## Cross-Cutting Tasks (Do Anytime)

### X1. Create INTERFACE.md
- [x] **Status:** DONE (May 9 — Claude Cowork) — docs/INTERFACE.md created with topics, TF frames, API shapes, sensor ports, Docker env, conventions
- **Time:** 1 hr
- **Tool:** Cursor or Claude Cowork
- **Cursor Prompt:**
  ```
  Read HEMAL_CONTEXT.md for project context.

  Create `docs/INTERFACE.md` — the single source of truth for all interfaces between
  Hemal's software and Jashwanth's hardware/firmware.

  Include:
  1. All ROS2 topic names, message types, and QoS profiles
  2. All TF frame names and their transforms
  3. All FastAPI endpoint shapes (request/response JSON)
  4. Sensor port assignments (LiDAR: /dev/ttyUSB0, IMU: I2C bus 1 addr 0x68, Camera: /dev/video0)
  5. Launch file parameters and their defaults
  6. Docker container entry points and environment variables

  Use the data from HEMAL_CONTEXT.md and TAIR_Context.md.
  Format as a clean markdown document that both founders can reference.
  ```

### X2. Update README.md
- [x] **Status:** DONE (May 9 — Claude Cowork) — updated from 'DIM' to 'TAIR', added quick start, repo layout, context file links
- **Time:** 30 min
- **Tool:** Cursor
- **Cursor Prompt:**
  ```
  Update the README.md to reflect the current state of the TAIR project.
  The README currently says "Indoor Drone Startup (DIM)" and references ROS2 Humble.
  
  Update it to:
  - Project name: TAIR
  - Accurate description of the project
  - Updated repo layout reflecting backend/ and dashboard/ directories
  - Current quick-start instructions
  - Links to HEMAL_CONTEXT.md and TAIR_Context.md for full context
  
  Keep it concise — the context docs have the details.
  ```

### X3. Update docs/claude-context.md
- [x] **Status:** DONE (May 9 — Claude Cowork) — replaced with deprecation notice pointing to HEMAL_CONTEXT.md + TAIR_Context.md. Updated .cursor/rules/dev-environment.mdc too.
- **Time:** 15 min
- **Tool:** Cursor
- **What:** Replace the outdated `docs/claude-context.md` with a pointer to `HEMAL_CONTEXT.md` and `TAIR_Context.md`, or delete it entirely and update `.cursor/rules/dev-environment.mdc` to reference the new files.

### X4. Add .gitattributes
- [x] **Status:** DONE (May 9 — Claude Cowork)
- **Time:** 2 min
- **Tool:** Terminal
- **Prompt (Terminal):**
  ```bash
  cd ~/Desktop/Repos/TAIR
  echo "* text=auto eol=lf" > .gitattributes
  git add .gitattributes
  git commit -m "chore: add .gitattributes for consistent line endings"
  git push
  ```

---

## Execution Method Reference

| Tool | When to Use | How to Start |
|---|---|---|
| **Cursor** | Writing code, creating packages, editing files | Open TAIR repo in Cursor, use Cmd+K or chat with HEMAL_CONTEXT.md as context |
| **Claude Cowork** | Planning, deployment help, debugging complex issues, generating prompts | Open new Cowork session, upload HEMAL_CONTEXT.md |
| **Claude Code** | Terminal-heavy tasks, git operations, running builds, MCP integrations | `claude` in terminal from ~/Desktop/Repos/TAIR, reference HEMAL_CONTEXT.md |
| **Terminal** | Docker commands, git, running containers, testing endpoints | Standard macOS Terminal or Cursor's integrated terminal |
| **Browser** | noVNC (RViz2/Gazebo), Railway/Vercel dashboards, GitHub | Chrome or Safari |

---

## Progress Tracker

| Week | Status | Key Deliverable |
|---|---|---|
| Week 1 | 🟡 In Progress | Gazebo sim + RViz2 + tair_bringup package — Dockerfile updated, tair_bringup created. **Next: rebuild Docker, test Gazebo launch** |
| Week 2 | ⬜ Not Started | SLAM pipeline + saved map + localization |
| Week 3 | ⬜ Not Started | FastAPI + PostgreSQL + cloud bridge + Railway |
| Week 4 | ⬜ Not Started | React + Three.js dashboard + Vercel |
| Cross-cutting | ✅ Done | INTERFACE.md, README, .gitattributes, claude-context.md cleanup — all completed May 9 |

---

## Quick Reference: What Goes Where

| Task Type | Tool | Why |
|---|---|---|
| Create a new ROS2 package | **Cursor** | Multi-file scaffolding with AI assistance |
| Write a launch file | **Cursor** | Needs context of other files |
| Build ROS2 workspace | **Terminal** (inside Docker) | `colcon build` must run in container |
| Run Gazebo/RViz2 | **Terminal** + **noVNC browser** | GUI runs in container, viewed via browser |
| Create FastAPI backend | **Cursor** | Multi-file scaffold |
| Run/test backend | **Terminal** | Docker Compose commands |
| Create React dashboard | **Cursor** | Multi-file scaffold with Tailwind + Three.js |
| Deploy to Railway/Vercel | **Claude Cowork** or **Browser** | Step-by-step guidance needed |
| Git operations | **Terminal** or **Claude Code** | Branch, commit, push |
| Debug weird issues | **Claude Cowork** | Paste error, get diagnosis |
| Plan next steps | **Claude Cowork** | Upload context, discuss strategy |
