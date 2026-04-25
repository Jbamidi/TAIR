# TAIR — Rubik Pi 3 Development Environment Setup

**Project:** TAIR Indoor Mapping Drone  
**Board:** Thundercomm Rubik Pi 3 (Qualcomm QCS6490)  
**OS:** Ubuntu 24.04 LTS (Noble)  
**ROS Version:** ROS 2 Jazzy  
**Last Updated:** April 2026

---

## Hardware Overview

- **SoC:** Qualcomm Dragonwing QCS6490
- **CPU:** 8-core Kryo 670
- **RAM:** 8GB LPDDR4x
- **Storage:** 128GB UFS 2.2
- **NPU:** Hexagon 770 — 12 TOPS AI performance
- **Connectivity:** Wi-Fi 5, Bluetooth 5.2, USB 3.0, HDMI, 40-pin GPIO, CSI camera

---

## Powering On

The Rubik Pi 3 has **no power button** — it boots automatically when power is connected.

1. Plug a USB-C cable into the power port
2. Connect to a **5V/3A+ USB-C adapter** or Anker 20,000mAh power bank
3. Wait **30–45 seconds** for full boot

To verify it's booted:
```bash
ping rubikpi.local
# Or SSH in directly
ssh ubuntu@rubikpi.local
```

**Always shut down cleanly — never just unplug:**
```bash
sudo poweroff
```

---

## Accessing the Board

### SSH (Primary Method)

The board runs headless. Always access it via SSH.

```bash
ssh ubuntu@<IP_ADDRESS>
# or
ssh ubuntu@rubikpi.local
```

**Default credentials:**
- Username: `ubuntu`
- Password: *(ask Jashwanth)*

To find the board's IP on the network:
```bash
ping rubikpi.local
# Or check your router's connected devices for 'rubikpi'
```

> **Important:** Both your laptop and the Rubik Pi must be on the **same Wi-Fi network** for SSH to work.

### SSH Auto-start

SSH is configured to start automatically on every boot:
```bash
sudo systemctl is-enabled ssh   # Should print: enabled
sudo systemctl status ssh       # Should show: active (running)
```

### VS Code Remote SSH (Recommended for Development)

1. Install **VS Code** on your laptop
2. Install the **Remote - SSH** extension
3. `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
4. Enter: `ubuntu@<IP_ADDRESS>`

---

## Wi-Fi Management

```bash
# Scan networks
sudo nmcli dev wifi list

# Connect with password
sudo nmcli dev wifi connect "NetworkName" password "YourPassword"

# Connect, no password
sudo nmcli dev wifi connect "NetworkName"

# Check new IP
ip addr show wlan0
```

> **Note:** After switching Wi-Fi, the IP address changes. Get the new IP before SSHing.

---

## System Configuration

### APT Package Sources

The board ships with an empty `ubuntu.sources` file. This has been fixed. Sources configured at `/etc/apt/sources.list.d/ubuntu.sources`:

- `http://ports.ubuntu.com/ubuntu-ports` — main Ubuntu Noble repo (arm64)
- `http://packages.ros.org/ros2/ubuntu` — ROS 2 Jazzy packages
- `https://ppa.launchpadcontent.net/ubuntu-qcom-iot/qcom-ppa/ubuntu` — Qualcomm-specific packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Build Tools

Required for compiling ROS2 packages:
```bash
sudo apt install -y build-essential cmake
```

### I2C and Serial Tools

```bash
sudo apt install -y libi2c-dev i2c-tools
```

### Hardware Permissions

Run once — takes effect after next login:
```bash
# Serial port access (LiDAR via USB)
sudo usermod -a -G dialout $USER

# I2C access (IMU via GPIO)
sudo usermod -a -G i2c $USER
```

Verify:
```bash
groups $USER
# Should include: dialout i2c
```

---

## ROS 2 Jazzy Setup

### Why Jazzy (not Humble)?

Ubuntu 24.04 requires ROS 2 Jazzy. Humble is for Ubuntu 22.04 and will not install on this board.

| | Humble | Jazzy |
|---|---|---|
| Ubuntu | 22.04 | 24.04 ✅ |
| Support until | 2027 | 2029 |

### Sourcing ROS 2

ROS 2 is automatically sourced on every new terminal session via `.bashrc`:

```bash
source /opt/ros/jazzy/setup.bash   # Already in ~/.bashrc
```

To verify:
```bash
echo $ROS_DISTRO   # Should print: jazzy
```

> **Note:** `ros2 --version` returns an error on this build — use `echo $ROS_DISTRO` instead.

### TAIR Workspace

Located at `~/tair_ws/`:

```
~/tair_ws/
├── src/        ← ROS 2 packages
├── build/
├── install/
└── log/
```

The workspace is auto-sourced in `.bashrc`:
```bash
source ~/tair_ws/install/setup.bash
```

### Building the workspace
```bash
cd ~/tair_ws
colcon build
source install/setup.bash
```

### Installed ROS 2 Packages

| Package | Purpose |
|---|---|
| `ros-jazzy-ros-base` | Core ROS 2 runtime |
| `ros-jazzy-slam-toolbox` | LiDAR-based SLAM / mapping |
| `ros-jazzy-nav2-bringup` | Navigation stack |
| `ros-jazzy-pointcloud-to-laserscan` | Convert 3D pointcloud to 2D scan |
| `ros-jazzy-tf2-ros` | Transform tree management |
| `ros-jazzy-tf2-tools` | TF debugging utilities |
| `ros-jazzy-image-transport` | Efficient camera data transport |
| `ros-jazzy-image-pipeline` | Camera processing pipeline |
| `python3-colcon-common-extensions` | ROS 2 build tool |
| `python3-rosdep` | Dependency management |

---

## Sensor Drivers

### LiDAR — STL27L (ldlidar_stl_ros2)

**Repo:** https://github.com/ldrobotSensorTeam/ldlidar_stl_ros2

```bash
cd ~/tair_ws/src
git clone https://github.com/ldrobotSensorTeam/ldlidar_stl_ros2.git
```

**Required fix before building** (GCC 13 compatibility):  
Open `ldlidar_driver/src/logger/log_module.cpp` and add at the top:
```cpp
#include <pthread.h>
```

**Connection:**
- Physical: STL27L → ribbon → Waveshare adapter board → USB-A → Rubik Pi 3
- Port: `/dev/ttyUSB0`
- Baud rate: `921600` (critical — must match exactly)

**Launch file:** `stl27l.launch.py` (already configured correctly)

**Dry run (no hardware):**
```bash
ros2 launch ldlidar_stl_ros2 stl27l.launch.py
# Expected: serial error on /dev/ttyUSB0 — this is correct behavior
```

---

### IMU — MPU-9250 (ros2_mpu6050_driver)

**Repo:** https://github.com/hiwad-aziz/ros2_mpu6050_driver

```bash
cd ~/tair_ws/src
git clone https://github.com/hiwad-aziz/ros2_mpu6050_driver.git
```

**Required fixes before building** (GCC 13 compatibility):  
1. Install i2c library: `sudo apt install -y libi2c-dev i2c-tools`  
2. Open `include/mpu6050driver/mpu6050sensor.h` and add at the top:
```cpp
#include <array>
```

**Wiring (GPIO I2C):**

| Rubik Pi 3 GPIO Pin | IMU Pin | Wire Color |
|---|---|---|
| Pin 1 (3.3V) | VCC | Red |
| Pin 3 (SDA / GPIO2) | SDA | Orange/Yellow |
| Pin 5 (SCL / GPIO3) | SCL | Blue/Purple |
| Pin 6 (GND) | GND | Black |
| GND | AD0 | Black (sets I2C address to 0x68) |

> **Important:** Verify I2C pullups on GPIO2/GPIO3 with a multimeter before wiring.

**I2C bus:** `/dev/i2c-1` (default, no config change needed)  
**I2C address:** `0x68` (AD0 tied to GND)

**Verify IMU detected:**
```bash
i2cdetect -y 1   # Should show 0x68
```

**Publishes to:** `/imu` topic at 100Hz  
**Auto-calibrates** on startup

---

## TAIR Bringup Package

The main TAIR launch package is at `~/tair_ws/src/tair_bringup/`.  
Also lives in the GitHub repo at `ros2_ws/tair_bringup/`.

### Structure

```
tair_bringup/
├── launch/
│   └── tair_bringup.launch.py    ← Main launch file
├── config/
│   ├── slam_toolbox.yaml         ← SLAM config tuned for warehouse
│   └── mpu6050.yaml              ← IMU config
├── package.xml
└── CMakeLists.txt
```

### Running the full stack

```bash
ros2 launch tair_bringup tair_bringup.launch.py
```

This starts 4 nodes simultaneously:
1. **STL27L LiDAR node** — publishes `/scan`
2. **Static TF publisher** — `base_link → base_laser` (18cm height offset)
3. **IMU node** — publishes `/imu`
4. **SLAM Toolbox** — consumes `/scan`, publishes `/map`

**Without hardware plugged in:** LiDAR and IMU will error on missing devices — this is expected. SLAM Toolbox and TF will start normally.

### SLAM Toolbox Config

Key parameters in `config/slam_toolbox.yaml`:

| Parameter | Value | Notes |
|---|---|---|
| `resolution` | `0.05` | 5cm — good for warehouse detail |
| `max_laser_range` | `20.0` | Conservative (STL27L max is 25m) |
| `do_loop_closing` | `true` | Critical for long warehouse aisles |
| `map_frame` | `map` | |
| `base_frame` | `base_link` | |
| `scan_topic` | `/scan` | |

---

## GitHub Repository

**Repo:** https://github.com/Jbamidi/TAIR (private)  
**Local clone on board:** `~/TAIR_Github/`

```bash
# Clone (first time)
git clone -b jashwanth/phase1-setup https://github.com/Jbamidi/TAIR.git TAIR_Github

# Push changes
cd ~/TAIR_Github
git add .
git commit -m "your message"
git push origin jashwanth/phase1-setup
```

**Git identity configured:**
```bash
git config --global user.name "Jashwanth"
git config --global user.email "jbamidi@illinois.edu"
```

**Branches:**
- `main` — stable
- `jashwanth/phase1-setup` — hardware + ROS2 setup (this branch)
- `hemal/phase1-setup` — Hemal's software work
- `dev` — active development
- `cursor/ros2-docker-env` — Docker/ROS2 environment

---

## Useful ROS 2 Commands

```bash
# List active nodes
ros2 node list

# List active topics
ros2 topic list

# Monitor a topic in real time
ros2 topic echo /topic_name

# Check topic publish rate
ros2 topic hz /topic_name

# Launch a package
ros2 launch <package_name> <launch_file.py>

# Run a single node
ros2 run <package_name> <node_name>

# Check TF tree
ros2 run tf2_tools view_frames

# Smoke test (run in two terminals)
ros2 run demo_nodes_cpp talker
ros2 run demo_nodes_cpp listener
```

---

## Visualizing with RViz2

Since the board runs headless, run RViz2 on your **laptop** while the Rubik Pi streams ROS 2 topics over Wi-Fi.

```bash
# On your laptop (must have ROS 2 installed)
export ROS_DOMAIN_ID=0   # Must match the board
rviz2
```

Add these displays in RViz2:
- **LaserScan** → topic `/scan` — see raw LiDAR data
- **Map** → topic `/map` — see SLAM map building in real time
- **TF** — see coordinate frames

---

## Rebooting / Shutting Down

```bash
sudo reboot      # Reboot
sudo poweroff    # Shutdown
```

---

## Full Reset (Reflash OS)

> ⚠️ This wipes EVERYTHING. Only do this if the board is seriously broken.

1. Download **Qualcomm Launcher** from Thundercomm website
2. Download the **Ubuntu 24.04 image** for Rubik Pi 3
3. Put board into **EDL mode**: hold EDL button → plug in power → plug USB-C to PC
4. Open Qualcomm Launcher → select Rubik Pi + Ubuntu → Flash

---

## Key Context

| Topic | Details |
|---|---|
| Why terminal only? | Headless saves RAM/CPU for drone compute pipeline |
| Why Jazzy not Humble? | Ubuntu 24.04 requires Jazzy. Humble won't install. |
| APT sources fix | ubuntu.sources was empty on stock image — manually fixed |
| Fan noise | Normal — onboard cooling fan for QCS6490 chip |
| Leave Pi on all day? | Yes, fine — designed for 24/7 operation |
| NPU | 12 TOPS Hexagon 770 — future use for LiDAR/camera inference |
| SSH auto-start | Enabled via systemctl — survives every reboot |
| `ros2 --version` | Returns error on this build — use `echo $ROS_DISTRO` instead |
| Driver fixes | Both ldlidar and mpu6050 need manual header fixes on GCC 13 — see docs/driver_fixes.md |

---

*TAIR — Jashwanth & Hemal & Andrew — April 2026*
