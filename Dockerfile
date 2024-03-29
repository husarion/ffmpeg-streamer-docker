ARG ROS_DISTRO=iron
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-base

WORKDIR /ros2_ws2

RUN git clone -b rolling https://github.com/DominikN/image_common/ src/image_common && \
    git clone -b 3.2.0 https://github.com/ros-perception/image_transport_plugins src/image_transport_plugins && \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt update && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install --from-paths src --ignore-src -y && \
    colcon build

WORKDIR /ros2_ws

RUN apt update && \
    git clone https://github.com/husarion/ffmpeg_image_transport.git src/ffmpeg_image_transport && \
    vcs import src < src/ffmpeg_image_transport/ffmpeg_image_transport.repos && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
    . /ros2_ws2/install/setup.bash && \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
	rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build && \
    echo $(cat /ros2_ws/src/ffmpeg_image_transport/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') >> /version.txt
    
COPY params.yaml /
COPY run.sh /

ENV TYPE=ENCODER
ENV RAW_TOPIC=/camera/image_raw
ENV FFMPEG_TOPIC=/camera/image_raw/ffmpeg

CMD ["/run.sh"]
