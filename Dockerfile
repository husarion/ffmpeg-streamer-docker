# Use an official ROS 2 base image
FROM husarnet/ros:humble-ros-base

# # Install build tools
# RUN apt-get update && apt-get install -y \
#     python3-colcon-common-extensions \
#     python3-pip \
#     && rm -rf /var/lib/apt/lists/*

WORKDIR /ros2_ws


# Install Python dependencies
# RUN pip3 install -U setuptools

RUN apt update && \
    git clone https://github.com/husarion/ffmpeg_image_transport.git src/ffmpeg_image_transport && \
    vcs import src < src/ffmpeg_image_transport/ffmpeg_image_transport.repos && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
	rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install --from-paths src --ignore-src -r -y

# Build the package
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build

COPY params.yaml /
COPY run.sh /

ENV TYPE=ENCODER
ENV RAW_TOPIC=/camera/image_raw
ENV FFMPEG_TOPIC=/camera/image_raw/ffmpeg

CMD ["/run.sh"]

# # Command to run when starting the container
# CMD ["ros2", "run", "ffmpeg_republisher", "republish_ffmpeg_best_effort"]
