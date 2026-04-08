FROM --platform=linux/arm64 ros:humble-ros-base-jammy

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3-pip \
    ros-humble-hector-slam \
    ros-humble-sensor-msgs \
    ros-humble-nav-msgs \
    ros-humble-tf2-ros \
    ros-humble-rviz2 \
    ros-humble-robot-state-publisher \
    vim \
    git \
  && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc
