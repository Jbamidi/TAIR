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

# ── Layer 2: Add OSRF Gazebo repository (required for Gazebo Classic 11) ────
RUN apt-get update \
  && apt-get install -y --no-install-recommends gnupg lsb-release \
  && curl -sSL https://packages.osrfoundation.org/gazebo.key | apt-key add - \
  && echo "deb https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
     > /etc/apt/sources.list.d/gazebo-stable.list \
  && rm -rf /var/lib/apt/lists/*

# ── Layer 3: Gazebo Classic 11 + TurtleBot3 + SLAM + Nav2 ──────────────────
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    # Gazebo simulation
    ros-humble-gazebo-ros-pkgs \
    # TurtleBot3 simulation (cartographer + gazebo-ros2-control excluded — ARM64 build issues)
    ros-humble-turtlebot3-gazebo \
    ros-humble-turtlebot3-description \
    ros-humble-turtlebot3-navigation2 \
    ros-humble-turtlebot3-teleop \
    ros-humble-turtlebot3-msgs \
    ros-humble-turtlebot3-bringup \
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
ENV GAZEBO_MODEL_PATH=/opt/ros/humble/share/turtlebot3_gazebo/models
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc \
  && echo "export TURTLEBOT3_MODEL=waffle" >> /etc/bash.bashrc \
  && echo "export GAZEBO_MODEL_PATH=/opt/ros/humble/share/turtlebot3_gazebo/models" >> /etc/bash.bashrc

# ── VNC entrypoint ──────────────────────────────────────────────────────────
COPY scripts/start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh
