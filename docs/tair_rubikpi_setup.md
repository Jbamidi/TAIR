# TAIR — Rubik Pi 3 Development Environment Setup

**Project:** TAIR Indoor Mapping Drone  
**Board:** Thundercomm Rubik Pi 3 (Qualcomm QCS6490)  
**OS:** Ubuntu 24.04 LTS (Noble)  
**ROS Version:** ROS 2 Jazzy  
**Date Setup:** April 2026

---

## Hardware Overview

- **SoC:** Qualcomm Dragonwing QCS6490
- **CPU:** 8-core Kryo 670
- **RAM:** 8GB LPDDR4x
- **Storage:** 128GB UFS 2.2
- **NPU:** Hexagon 770 — 12 TOPS AI performance
- **Connectivity:** Wi-Fi 5, Bluetooth 5.2, USB 3.0, HDMI, 40-pin GPIO, CSI camera

---

## Accessing the Board

### SSH (Primary Method)

The board runs headless. Always access it via SSH.

```bash
ssh ubuntu@<IP_ADDRESS>
```

**Default credentials:**
- Username: `ubuntu`
- Password: *(set on first boot — ask Jashwanth)*

To find the board's IP on the network:
```bash
# From another device on the same network
ping rubikpi.local
```

Or check your router's connected devices for `rubikpi`.

> **Important:** Both your laptop and the Rubik Pi must be on the **same Wi-Fi network** for SSH to work.

### SSH Auto-start

SSH is configured to start automatically on every boot:
```bash
sudo systemctl is-enabled ssh   # Should print: enabled
sudo systemctl status ssh       # Should show: active (running)
```

---

## Wi-Fi Management

### Switch to a different network
```bash
# Scan available networks
sudo nmcli dev wifi list

# Connect with password
sudo nmcli dev wifi connect "NetworkName" password "YourPassword"

# Connect with no password
sudo nmcli dev wifi connect "NetworkName"

# Check new IP after connecting
ip addr show wlan0
```

> **Note:** After switching Wi-Fi, the IP address will change. Get the new IP before SSHing in.

---

## System Configuration

### APT Package Sources

The board ships with an empty `ubuntu.sources` file. This has been fixed by adding the full Ubuntu Noble repos at:

```
/etc/apt/sources.list.d/ubuntu.sources
```

Sources configured:
- `http://ports.ubuntu.com/ubuntu-ports` — main Ubuntu Noble repo (arm64)
- `http://packages.ros.org/ros2/ubuntu` — ROS 2 Jazzy packages
- `https://ppa.launchpadcontent.net/ubuntu-qcom-iot/qcom-ppa/ubuntu` — Thundercomm Qualcomm-specific packages

To update packages:
```bash
sudo apt update && sudo apt upgrade -y
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
ros2 pkg list | head -20
```

### Workspace

The ROS 2 workspace for TAIR is located at:

```
~/tair_ws/
├── src/        ← Put your ROS 2 packages here
├── build/
├── install/
└── log/
```

The workspace is also auto-sourced in `.bashrc`:
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
| `ros-jazzy-pointcloud-to-laserscan` | Convert 3D pointcloud to 2D scan |
| `ros-jazzy-tf2-ros` | Transform tree management |
| `ros-jazzy-tf2-tools` | TF debugging utilities |
| `ros-jazzy-image-transport` | Efficient camera data transport |
| `ros-jazzy-image-pipeline` | Camera processing pipeline |
| `python3-colcon-common-extensions` | Build tool for ROS 2 packages |
| `python3-rosdep` | Dependency management |

---

## Useful ROS 2 Commands

```bash
# List all active nodes
ros2 node list

# List all active topics
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
```

---

## VS Code Remote SSH (Recommended for Development)

1. Install **VS Code** on your laptop
2. Install the **Remote - SSH** extension
3. `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
4. Enter: `ubuntu@<IP_ADDRESS>`

You'll get a full VS Code editor connected directly to the board.

---

## Visualizing with RViz2

Since the board runs headless, run RViz2 on your **laptop** while the Rubik Pi streams ROS 2 topics over Wi-Fi.

On your laptop (must have ROS 2 installed):
```bash
export ROS_DOMAIN_ID=0   # Must match the board's domain ID
rviz2
```

---

## Rebooting / Shutting Down

```bash
# Reboot
sudo reboot

# Shutdown
sudo poweroff

# Or hold PWR ON button for 12 seconds to force reboot
```

---

## Full Reset (Reflash OS)

If you need to start completely from scratch:

1. Download **Qualcomm Launcher** from Thundercomm's website
2. Download the **Ubuntu 24.04 image** for Rubik Pi 3
3. Put the board into **EDL mode**: hold EDL button → plug in power → plug USB-C to PC
4. Open Qualcomm Launcher → select Rubik Pi + Ubuntu → Flash

> ⚠️ This wipes everything. Only do this if the board is seriously broken.

---

## Contacts

- **Jashwanth** — Hardware, embedded firmware, overall system setup
- **Hemal** — Software / app side

---

*Last updated: April 2026*
