# INTERFACE.md — TAIR Integration Contract

**Last Updated:** May 9, 2026
**Purpose:** Single source of truth for all interfaces between Hemal's software and Jashwanth's hardware/firmware. Both founders reference this file to prevent integration mismatches.

---

## 1. ROS2 Topics

| Topic | Message Type | Publisher | QoS | Notes |
|---|---|---|---|---|
| `/scan` | `sensor_msgs/LaserScan` | LiDAR driver (sim: Gazebo, real: `ldlidar_stl_ros2`) | Best Effort, Volatile | 360° scan, ~21,600 pts/sec |
| `/imu/data` | `sensor_msgs/Imu` | IMU driver (sim: Gazebo plugin, real: `ros2_mpu6050_driver`) | Best Effort, Volatile | Orientation + angular velocity + linear acceleration |
| `/odom` | `nav_msgs/Odometry` | Gazebo (sim) / wheel encoders (real, if added) | Best Effort, Volatile | Robot odometry |
| `/map` | `nav_msgs/OccupancyGrid` | `slam_toolbox` | Reliable, Transient Local | Built occupancy grid |
| `/tf` | `tf2_msgs/TFMessage` | `robot_state_publisher` + `slam_toolbox` | Reliable, Volatile | Transform tree |
| `/tf_static` | `tf2_msgs/TFMessage` | `robot_state_publisher` | Reliable, Transient Local | Static transforms |
| `/robot_description` | `std_msgs/String` | `robot_state_publisher` | Reliable, Transient Local | URDF XML |
| `/barcode/detections` | `std_msgs/String` (Phase 1) | `tair_barcode` node | Reliable, Volatile | JSON: `{"tag": "...", "x": 0.0, "y": 0.0, "confidence": 0.95}` |
| `/cmd_vel` | `geometry_msgs/Twist` | Teleop (sim) / Nav2 (autonomous) | Reliable, Volatile | Velocity commands to robot |

### Phase 2 Additions
| Topic | Message Type | Publisher | Notes |
|---|---|---|---|
| `/rfid/detections` | Custom msg TBD | `tair_rfid` node | UHF RFID reads from YRM100 |

---

## 2. TF Frame Tree

```
map
└── odom
    └── base_footprint          (TurtleBot3 convention)
        └── base_link
            ├── base_laser      (0, 0, 0.18m)   — LiDAR mount height
            ├── imu_link        (0, 0, 0.05m)   — IMU below LiDAR
            └── camera_link     (0.10, 0, 0.10m) — barcode cam, forward-mounted
```

**Notes:**
- TurtleBot3 Waffle uses `base_footprint` as the ground-plane frame and `base_link` slightly above it
- In sim, Gazebo publishes `odom → base_footprint`. On real hardware, this comes from wheel encoders or SLAM
- `map → odom` is published by slam-toolbox
- `base_link → sensor frames` are static transforms from the URDF

---

## 3. Sensor Port Assignments (Real Hardware — Rubik Pi)

| Sensor | Interface | Port / Address | Baud / Config | Driver Package |
|---|---|---|---|---|
| STL27L LiDAR | USB-TTL Serial | `/dev/ttyUSB0` | 921600 baud | `ldlidar_stl_ros2` |
| MPU-9250 IMU | I2C | Bus 1, Address `0x68` | — | `ros2_mpu6050_driver` |
| USB Webcam (barcode) | USB Video | `/dev/video0` | — | `tair_barcode` (pyzbar) |
| YRM100 RFID (Phase 2) | USB Serial | `/dev/ttyUSB1` (TBD) | 115200 baud | `tair_rfid` |

---

## 4. FastAPI Endpoints

**Base URL:** `http://localhost:8000` (local) or Railway deployment URL (production)

| Method | Path | Request Body | Response | Purpose |
|---|---|---|---|---|
| `GET` | `/api/healthcheck` | — | `{"status": "ok", "version": "0.1.0"}` | Health check |
| `POST` | `/api/scans` | See below | `Scan` object | Upload completed scan |
| `GET` | `/api/scans` | — | `List[Scan]` | List all scans |
| `GET` | `/api/scans/{id}` | — | `Scan` with detections | Get scan details |
| `GET` | `/api/inventory` | — | `List[Detection]` | Current inventory state |
| `GET` | `/api/discrepancies` | — | `List[Discrepancy]` | Mismatches |
| `GET` | `/api/maps/{id}` | — | `Map` object | Retrieve saved map |

### POST /api/scans — Request Body
```json
{
  "facility_id": "uuid",
  "map": {
    "resolution": 0.05,
    "width": 384,
    "height": 384,
    "origin_x": -10.0,
    "origin_y": -10.0,
    "data": "base64-encoded occupancy grid bytes"
  },
  "detections": [
    {
      "detection_type": "barcode",
      "tag_value": "SKU-12345",
      "position_x": 3.2,
      "position_y": -1.5,
      "confidence": 0.95
    }
  ]
}
```

---

## 5. Launch File Parameters

### `tair_sim.launch.py` (simulation with SLAM mapping)
| Parameter | Default | Description |
|---|---|---|
| `use_sim_time` | `true` | Use Gazebo simulation clock |

### `tair_localize.launch.py` (simulation with saved map)
| Parameter | Default | Description |
|---|---|---|
| `use_sim_time` | `true` | Use Gazebo simulation clock |
| `map_file` | `/workspace/maps/sim_warehouse_v1` | Path to saved map (no extension) |

---

## 6. Docker Environment

### Container: `tair_ros2_vnc` (primary dev container)
| Variable | Value | Purpose |
|---|---|---|
| `TURTLEBOT3_MODEL` | `waffle` | TurtleBot3 model for Gazebo |
| `GAZEBO_MODEL_PATH` | `/opt/ros/humble/share/turtlebot3_gazebo/models` | Gazebo model search path |
| `ROS_DOMAIN_ID` | `0` | ROS2 DDS domain |
| `DISPLAY` | `:1` | X11 display for VNC |

### Access
- **noVNC:** `http://localhost:6080/vnc.html`
- **VNC direct:** `localhost:5900`
- **Enter container:** `docker exec -it tair_ros2_vnc bash`
- **Workspace mount:** Host `./` → Container `/workspace`
- **ROS2 workspace:** `/workspace/ros2_ws`

---

## 7. Conventions

- **Branch names:** `hemal/phase1-setup`, `jashwanth/phase1-setup`
- **Commit prefixes:** `feat:`, `fix:`, `chore:`, `docs:`
- **Line endings:** LF only (`.gitattributes` enforced)
- **Python style:** Black formatter, 88 char line width
- **ROS2 version:** Humble (Docker), Jazzy (Rubik Pi target — migration later)
