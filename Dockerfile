FROM nvidia/cudagl:11.2.1-devel-ubuntu20.04
MAINTAINER minchang <tjdalsckd@gmail.com>
RUN apt-get update &&  apt-get install -y -qq --no-install-recommends \
    libgl1 \
    libxext6 \ 
    libx11-6 \
   && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y wget
RUN apt-get install -y sudo curl
RUN sudo apt update && sudo apt install -y curl gnupg2 lsb-release
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
ENV TZ=Europe/Minsk
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tzdata \
    && rm -rf /var/lib/apt/lists/*
RUN apt update && DEBIAN_FRONTEND=noninteractive sudo apt install -y --no-install-recommends\
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget
# install some pip packages needed for testing
RUN python3 -m pip install -U \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  setuptools
RUN /bin/bash -c  "mkdir -p ~/ros2_galactic/src;cd ~/ros2_galactic;wget https://raw.githubusercontent.com/ros2/ros2/galactic/ros2.repos;vcs import ~/ros2_galactic/src < ros2.repos;apt upgrade -y;rosdep init;rosdep update ;"

RUN /bin/bash -c "rosdep install --from-paths ~/ros2_galactic/src --ignore-src -y --skip-keys 'fastcdr rti-connext-dds-5.3.1 urdfdom_headers' "
RUN /bin/bash -c "cd ~/ros2_galactic; colcon build --symlink-install"
RUN echo ". ~/ros2_galactic/install/local_setup.bash" > ~/.bashrc


EXPOSE 80
EXPOSE 443
