# Driver Fixes — April 2026

## 1. ldlidar_stl_ros2
**File:** `ldlidar_driver/src/logger/log_module.cpp`  
**Fix:** Added `#include <pthread.h>` at the top of the file.  
**Reason:** GCC 13 on Ubuntu 24.04 no longer implicitly includes pthread — 
build fails with `pthread_mutex_init was not declared in this scope`.

## 2. ros2_mpu6050_driver
**File:** `include/mpu6050driver/mpu6050sensor.h`  
**Fix:** Added `#include <array>` at the top of the file.  
**Reason:** GCC 13 on Ubuntu 24.04 no longer implicitly includes array — 
build fails with `field has incomplete type const std::array`.

## Notes
- Both drivers are cloned from public GitHub repos into `~/tair_ws/src/`
- Apply these fixes after cloning before running `colcon build`
- Tested and working on Rubik Pi 3 (Ubuntu 24.04, ROS2 Jazzy, GCC 13)
