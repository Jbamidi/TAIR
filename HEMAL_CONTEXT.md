# Hemal's Working Context — TAIR Pre-Bay Sprint

**Last Updated:** May 9, 2026 — post-session update (Cursor + Claude Cowork)
**Purpose:** Drop this into any new Claude Cowork, Claude Code, or Cursor session to give full context on what Hemal is working on. This is the software-side companion to `TAIR_Context.md`.

---

## Who I Am

- **Hemal** — Co-Founder & Software Lead at TAIR
- Full-time CS engineer at Workday (day job) — TAIR is evenings/weekends
- ~10 hours/week available, broken into 1-2 hour sessions
- Develops on **Mac Mini M4** (Apple Silicon)
- Tools: **Cursor** (IDE), **Claude Cowork/Code** (AI), **Docker Desktop** (ROS2 containers)
- Email: hemaljassu@icloud.com

---

## What TAIR Is (30-second version)

Autonomous warehouse intelligence platform. A drone (Phase 2) or push-cart (Phase 1) scans warehouses nightly with LiDAR + barcode + RFID, builds a digital twin, reconciles against the WMS, and pushes corrected inventory before the morning shift. The drone is the sensor — the platform is the product.

Full context: see `TAIR_Context.md` in the repo root.

---

## The Situation Right Now (May 9, 2026)

**I have ~3.5 weeks** before Jashwanth (hardware co-founder) arrives in the Bay Area with physical hardware.

### What Exists (as of end of May 9 session)
- GitHub repo: `https://github.com/Jbamidi/TAIR` (private) — branch `hemal/phase1-setup` active, PR #2 open (draft), 7 commits
- Local clone: `~/Desktop/Repos/TAIR`
- Docker container: `tair_ros2_vnc` — **running**, ports bound (`0.0.0.0:6080->6080`), noVNC at `http://localhost:6080/vnc.html`
- `ros2 launch tair_bringup tair_sim.launch.py` — **confirmed working**: all 4 nodes start cleanly
  - `robot_state_publisher` — waffle URDF loaded, all TF segments published
  - `turtlebot3_fake_node` — initialised, `/scan` + `/odom` publishing
  - `slam_toolbox` — CeresSolver running, ready to map
  - `rviz2` — OpenGL 3.3, visible at `http://localhost:6080/vnc.html`
- `ros2_ws/src/tair_bringup` — built and passing, `rviz_config.rviz` fixed frame set to `odom`
- `slam-toolbox`, `turtlebot3_fake_node`, `nav2_map_server`, `teleop_twist_keyboard` all installed in container
- `docs/INTERFACE.md` — created
- `.gitattributes`, `.gitignore`, `.cursor/rules/session-handoff.mdc` — added
- MCPs configured in `~/.cursor/mcp.json`: Notion, GitHub (classic PAT), Docker ✓, PostgreSQL ✓, Railway ✓ (token set), Vercel ✓ (OAuth done)
- Node.js v26 installed via Homebrew (powers npx-based MCPs)

### What Does NOT Exist Yet
- No SLAM map built yet (sim is running — needs teleop drive + map_saver_cli)
- No saved map file (`/workspace/maps/`)
- No ROS bag recorded
- No FastAPI backend
- No React/Three.js dashboard

### Key Decision: Gazebo Classic → turtlebot3_fake_node
Gazebo Classic binaries (`ros-humble-gazebo-ros-pkgs`) are not published for ARM64 in the ROS 2 Humble apt repos. The correct simulation approach for Apple Silicon Docker is `turtlebot3_fake_node`, which publishes `/scan`, `/odom`, and the full TF tree without Gazebo. All launch files have been updated accordingly.

### Decision: Humble vs Jazzy
Stay on **Humble** for Docker dev. Jazzy migration happens when deploying to the Rubik Pi. Launch files and SLAM config are identical — it's a one-line base image change.

---

## My 4-Week Sprint Plan

### Week 1 (May 9–16): Fix Sim Environment ← IN PROGRESS
**Goal:** `turtlebot3_fake_node` + SLAM running in Docker, simulated LiDAR visible in RViz2, colcon build clean.

Completed (May 9):
- [x] Updated Dockerfile: `turtlebot3_fake_node`, `slam-toolbox`, `nav2_map_server`, `teleop_twist_keyboard`
- [x] Created `tair_bringup` package — builds clean in container
- [x] `tair_sim.launch.py` — `robot_state_publisher` + `turtlebot3_fake_node` (waffle.yaml params) + `slam_toolbox` + `rviz2`
- [x] `tair_localize.launch.py` (localization mode against saved map)
- [x] `slam_toolbox_params.yaml` (0.05m res, 20m range, loop closure on)
- [x] `rviz_config.rviz` — fixed frame set to `odom` so `/scan` ring is immediately visible
- [x] Container running, all 4 nodes confirmed starting cleanly
- [x] All commits pushed to `hemal/phase1-setup`, PR #2 open (draft), Jashwant added as reviewer
- [x] MCPs configured: Docker, PostgreSQL, Railway, Vercel, GitHub, Notion
- [x] `session-handoff.mdc` Cursor rule added (auto-updates context at session end)

**Still needed (your next session):**
- [ ] Open `http://localhost:6080/vnc.html` → RViz2 → verify `/scan` laser ring is visible (fixed frame = odom)
- [ ] Drive with teleop: `docker exec tair_ros2_vnc bash -c "source /opt/ros/humble/setup.bash && ros2 run turtlebot3_teleop teleop_keyboard"`
- [ ] Confirm `slam_toolbox` map builds as you drive
- [ ] Save map: `ros2 run nav2_map_server map_saver_cli -f /workspace/maps/sim_v1`
- [ ] Screen recording of SLAM pipeline (Week 1 deliverable)
- [ ] Revoke old GitHub PAT at github.com/settings/tokens once new one is confirmed working

### Week 2 (May 16–23): SLAM Pipeline in Sim ← NEXT
**Goal:** Full SLAM pipeline working end-to-end in simulation.

Tasks:
1. Install and configure `slam-toolbox` (async mode)
2. Drive simulated robot (teleop or scripted) through Gazebo warehouse
3. Build map in real-time via slam-toolbox
4. Save map: `ros2 run nav2_map_server map_saver_cli -f ~/maps/sim_warehouse_v1`
5. Reload saved map and localize against it (localization mode)
6. Tune slam-toolbox config: 0.05m resolution, 20m max range, loop closing on
7. Deliverable: saved map file + screen recording of SLAM pipeline

### Week 3 (May 23–30): Cloud Backend Scaffold
**Goal:** FastAPI + PostgreSQL running in Docker, data pipeline from ROS bag → cloud DB.

Tasks:
1. FastAPI scaffold with endpoints: `POST /scan`, `GET /inventory`, `GET /discrepancies`, `GET /map`
2. PostgreSQL in Docker alongside FastAPI
3. Schema: `scans`, `detections`, `facilities`, `maps` tables
4. ROS2 node that reads a rosbag and POSTs data to FastAPI
5. Test: record a sim run as a bag, replay through upload pipeline, confirm data in PostgreSQL
6. Stretch: deploy FastAPI to Railway, respond to `GET /healthcheck`
7. Deliverable: screenshot of pgAdmin showing simulated scan data + deployed Railway URL

### Week 4 (May 30–Jun 6): React + Three.js Dashboard Skeleton
**Goal:** Visualization layer with fake data, ready to plug in real data.

Tasks:
1. React app (Vite + TypeScript)
2. Three.js scene rendering 2D top-down map (occupancy grid or point cloud)
3. Fake API call to FastAPI returning stored map + detections as overlaid markers
4. Sidebar: detected tags list, accuracy score, "last scan" timestamp
5. Deploy frontend to Vercel, backend on Railway
6. Deliverable: public URL showing fake warehouse map with fake tag detections

---

## Repo Structure (Target)

```
TAIR/
├── ros2_ws/
│   └── src/
│       ├── tair_bringup/          # Master launch package
│       │   ├── launch/
│       │   │   └── tair_bringup.launch.py
│       │   ├── config/
│       │   │   └── slam_toolbox_params.yaml
│       │   ├── package.xml
│       │   └── CMakeLists.txt
│       ├── tair_barcode/          # Barcode detection node (Phase 1)
│       └── tair_cloud_bridge/     # ROS → FastAPI upload node
├── backend/
│   ├── app/
│   │   ├── main.py                # FastAPI app
│   │   ├── models.py              # SQLAlchemy models
│   │   ├── schemas.py             # Pydantic schemas
│   │   └── routers/
│   │       ├── scans.py
│   │       ├── inventory.py
│   │       └── maps.py
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
├── dashboard/
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   │   ├── WarehouseMap.tsx    # Three.js scene
│   │   │   └── Sidebar.tsx
│   │   └── api/
│   │       └── client.ts
│   ├── package.json
│   └── vite.config.ts
├── docs/
│   └── INTERFACE.md               # ROS2 topics, TF frames, API shapes
├── Dockerfile                     # ROS2 dev container
├── docker-compose.yml
├── TAIR_Context.md
├── HEMAL_CONTEXT.md               # This file
└── README.md
```

---

## Tech Stack Reference

| Layer | Tech | Notes |
|---|---|---|
| ROS2 | Humble (Docker, ARM64) | Jazzy migration deferred to Rubik Pi deployment |
| SLAM | slam-toolbox | NOT Hector SLAM, NOT Cartographer |
| Simulation | `turtlebot3_fake_node` | Gazebo Classic not available for ARM64 in Humble apt repos |
| Backend | FastAPI + PostgreSQL | Docker Compose locally, Railway for deploy |
| Frontend | React + Vite + Three.js + TypeScript | Vercel for deploy |
| Styling | Tailwind CSS | Matches marketing site |
| 3D | @react-three/fiber + @react-three/drei | Digital twin renderer |

---

## ROS2 Topics (Phase 1 Target)

| Topic | Type | Source |
|---|---|---|
| `/scan` | `sensor_msgs/LaserScan` | LiDAR (sim: turtlebot3_fake_node, real: STL27L) |
| `/imu/data` | `sensor_msgs/Imu` | IMU (sim: Gazebo plugin, real: MPU-9250) |
| `/map` | `nav_msgs/OccupancyGrid` | slam-toolbox |
| `/tf` | `tf2_msgs/TFMessage` | robot_state_publisher |
| `/barcode/detections` | custom msg or `std_msgs/String` | tair_barcode node |
| `/odom` | `nav_msgs/Odometry` | Wheel encoder sim or SLAM-derived |

---

## TF Tree (Phase 1)

```
map → odom → base_link
                ├── base_laser   (0, 0, 0.18m)
                ├── imu_link     (0, 0, 0.05m)
                └── camera_link  (0.10, 0, 0.10m)
```

---

## FastAPI Endpoints (Phase 1)

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/scans` | Upload a completed scan (map data + detections) |
| `GET` | `/api/scans` | List all scans |
| `GET` | `/api/scans/{id}` | Get scan details |
| `GET` | `/api/inventory` | Current inventory state |
| `GET` | `/api/discrepancies` | Mismatches between scans and expected inventory |
| `GET` | `/api/maps/{id}` | Retrieve a saved map |
| `GET` | `/api/healthcheck` | Health check for deployment verification |

---

## PostgreSQL Schema (Phase 1)

```sql
-- Facilities
CREATE TABLE facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Maps
CREATE TABLE maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID REFERENCES facilities(id),
    resolution FLOAT NOT NULL,        -- meters per pixel
    width INT NOT NULL,               -- grid width
    height INT NOT NULL,              -- grid height
    origin_x FLOAT NOT NULL,
    origin_y FLOAT NOT NULL,
    data BYTEA NOT NULL,              -- occupancy grid data
    created_at TIMESTAMP DEFAULT NOW()
);

-- Scans
CREATE TABLE scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID REFERENCES facilities(id),
    map_id UUID REFERENCES maps(id),
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'in_progress'
);

-- Detections
CREATE TABLE detections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID REFERENCES scans(id),
    detection_type VARCHAR(50) NOT NULL,  -- 'barcode' or 'rfid'
    tag_value VARCHAR(255) NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    confidence FLOAT,
    detected_at TIMESTAMP DEFAULT NOW()
);
```

---

## Key Constraints & Gotchas

1. **~10 hrs/week** — every task must fit in 1-2 hour chunks
2. **Docker is the dev environment** — don't install ROS2 natively on Mac
3. **noVNC for GUI** — RViz2 runs inside the container, viewed at `http://localhost:6080/vnc.html`
4. **ARM64 native** — the Docker container matches Rubik Pi architecture (no x86 emulation)
5. **No hardware available** — everything must work in simulation until Bay reunion
6. **Never run `npm audit fix --force`** — it destroys Next.js projects
7. **`.gitattributes` with `* text=auto eol=lf`** — prevents CRLF issues
8. **GCC 13 fixes needed on Rubik Pi** — add `#include <pthread.h>` to LiDAR driver, `#include <array>` to IMU driver (not relevant in sim, but document for later)

---

## Session Log

| Date | What Was Done | Next |
|------|--------------|------|
| May 9, 2026 | Dockerfile updated (fake_node + SLAM + Nav2), `tair_bringup` package created and building, `docs/INTERFACE.md` created, README + context files written, `.gitattributes` + `.gitignore` added, all MCPs configured (Docker/Postgres/Railway/Vercel/GitHub/Notion), Node.js v26 installed, container running, PR #2 opened on `hemal/phase1-setup`; then: `tair_sim.launch.py` fixed (added `robot_state_publisher` + `waffle.yaml` params), container launch confirmed (all 4 nodes clean), `rviz_config.rviz` fixed frame → `odom`, `session-handoff.mdc` rule added | Open RViz2 via noVNC, verify `/scan` ring, drive with teleop, save map, screen recording |

---

## How to Use This File

**New Cursor session:** Read this file automatically via `.cursor/rules/dev-environment.mdc`. Tell Cursor: "I'm working on [specific task]."

**New Claude Cowork session:** Upload this file. Say: "I'm Hemal working on TAIR. Here's my context. I want to work on [X]."

**New Claude Code session:** Reference this file. Say: "Read HEMAL_CONTEXT.md in the repo root for project context."

**Update this file** at the end of each work session — the Cursor rule `session-handoff.mdc` will prompt you to do this automatically.
