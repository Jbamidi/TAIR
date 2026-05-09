FROM --platform=linux/arm64 ros:humble-ros-base-jammy

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# ── Layer 1: Core ROS2 packages + GUI/VNC dependencies ──────────────────────
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-colcon-common-extensions \
    # ROS2 core messages & tools
    ros-humble-sensor-msgs \
    ros-humble-nav-msgs \
    ros-humble-geometry-msgs \
    ros-humble-tf2-ros \
    ros-humble-tf2-tools \
    ros-humble-rviz2 \
    ros-humble-robot-state-publisher \
    ros-humble-joint-state-publisher \
    ros-humble-xacro \
    # GUI / VNC stack
    x11-apps \
    mesa-utils \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libgl1-mesa-glx \
    iproute2 \
    netcat-openbsd \
    xvfb \
    xserver-xorg-core \
    xserver-xorg-video-dummy \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    vim \
    git \
    wget \
    curl \
  && rm -rf /var/lib/apt/lists/*

# ── Layer 2: TurtleBot3 (fake-node) + SLAM + Nav2 ───────────────────────────
# NOTE: Gazebo Classic binaries are not published for ARM64 in the Humble repos.
# turtlebot3-fake-node provides /scan, /odom, and TF without Gazebo — the
# correct approach for ARM64 Docker simulation.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    # TurtleBot3 simulation (fake-node replaces Gazebo for ARM64)
    ros-humble-turtlebot3-fake-node \
    ros-humble-turtlebot3-description \
    ros-humble-turtlebot3-msgs \
    ros-humble-turtlebot3-bringup \
    ros-humble-turtlebot3-teleop \
    # SLAM
    ros-humble-slam-toolbox \
    # Navigation / map tools
    ros-humble-nav2-map-server \
    ros-humble-nav2-bringup \
    ros-humble-nav2-lifecycle-manager \
    # Teleop
    ros-humble-teleop-twist-keyboard \
    # Rosbag for recording
    ros-humble-rosbag2-storage-default-plugins \
  && rm -rf /var/lib/apt/lists/*

# ── Environment: ROS2 + TurtleBot3 model ────────────────────────────────────
ENV TURTLEBOT3_MODEL=waffle
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc \
  && echo "export TURTLEBOT3_MODEL=waffle" >> /etc/bash.bashrc

# ── VNC entrypoint ──────────────────────────────────────────────────────────
COPY scripts/start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh
