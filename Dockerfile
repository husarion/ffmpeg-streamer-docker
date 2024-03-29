ARG ROS_DISTRO=humble
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-base

WORKDIR /ros2_ws2

RUN apt update && apt install -y \
        ros-$ROS_DISTRO-cv-bridge && \
    git clone -b $ROS_DISTRO https://github.com/husarion/image_common/ src/image_common && \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt update && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install --from-paths src --ignore-src -y && \
    set -x && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    rm -rf build log src && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ros2_ws

RUN apt update && \
    git clone https://github.com/husarion/ffmpeg_image_transport.git src/ffmpeg_image_transport && \
    vcs import src < src/ffmpeg_image_transport/ffmpeg_image_transport.repos && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
	rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install --from-paths src --ignore-src -r -y && \
    source /ros2_ws2/install/setup.bash && \
    source /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    echo $(cat /ros2_ws/src/ffmpeg_image_transport/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') >> /version.txt && \
    rm -rf build log src && \
    rm -rf /var/lib/apt/lists/*
    
COPY params.yaml /
COPY run.sh /

ENV TYPE=ENCODER
ENV RAW_TOPIC=/camera/image_raw
ENV FFMPEG_TOPIC=/camera/image_raw/ffmpeg

RUN sed -i 's|# <additional-user-commands>|source "/ros2_ws2/install/setup.bash"|' /ros_entrypoint.sh

CMD ["/run.sh"]
