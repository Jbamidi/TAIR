FROM --platform=linux/arm64 ros:humble-ros-base-jammy

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3-pip \
    ros-humble-sensor-msgs \
    ros-humble-nav-msgs \
    ros-humble-tf2-ros \
    ros-humble-rviz2 \
    ros-humble-robot-state-publisher \
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
  && (apt-get install -y --no-install-recommends ros-humble-hector-slam \
      || apt-get install -y --no-install-recommends ros-humble-slam-toolbox) \
  && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

COPY scripts/start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh
