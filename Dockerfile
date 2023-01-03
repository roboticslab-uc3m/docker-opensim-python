ARG BASE_IMAGE=ubuntu:20.04
#Download base image ubuntu 20.04
FROM $BASE_IMAGE


# Dockerfile info
LABEL authors="jcgvicto@ing.uc3m.es, monte.igna@gmail.com"
LABEL version="0.1"
LABEL description="Docker image to run CI for iiwa-fri-gym."

RUN apt-get update

RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update

ARG USER=docker
# Run the next steps with bash
SHELL ["/bin/bash", "-c"]

# Install sudo
RUN apt-get install -y sudo

# Create new user `${USER}` and disable
# password and gecos for later
# --gecos explained well here:
# https://askubuntu.com/a/1195288/635348
RUN adduser --disabled-password \
    --gecos '' ${USER} || true

#  Add new user ${USER} to sudo group
RUN adduser ${USER} sudo || true

# Ensure sudo group users are not
# asked for a password when using
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

# now we can set USER to the
# user we just created
USER ${USER}
# Run the next steps with bash
SHELL ["/bin/bash", "-c"]

WORKDIR /home/${USER}/

# Install dependencies from package manager.
RUN sudo apt-get install --yes \
    build-essential \
    autotools-dev \
    autoconf \
    pkg-config \
    automake \
    libopenblas-dev \
    liblapack-dev \
    freeglut3-dev \
    libxi-dev \
    libxmu-dev \
    doxygen \
    python3 \
    python3-dev \
    python3-numpy \
    python3-setuptools \
    python3-pip \
    openjdk-8-jdk \
    libpcre3 \
    libpcre3-dev \
    byacc \
    git \
    gfortran \
    libtool \
    software-properties-common \
    wget

# Missind Dependencies
RUN sudo apt-get install -y --fix-missing \
    libadolc-dev \
    coinor-libipopt-dev

# Install cmake 3.15+
RUN mkdir -p ~/opensim-workspace/cmake && cd ~/opensim-workspace/cmake && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc > cmake.key && \
    sudo apt-key add cmake.key && \
    sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    sudo apt-get update && \
    sudo apt install --yes cmake cmake-curses-gui

# Set the number of cores to use for building.
ARG BUILD_CORES=4

# Download and install SWIG.
RUN mkdir -p ~/opensim-workspace/swig-source && cd ~/opensim-workspace/swig-source && \
    wget https://github.com/swig/swig/archive/refs/tags/rel-4.0.2.tar.gz && \
    tar xzf rel-4.0.2.tar.gz && cd swig-rel-4.0.2 && \
    sh autogen.sh && ./configure --prefix=$HOME/swig --disable-ccache && \
    make && make -j$BUILD_CORES install

# Download and install NetBeans 12.3.
RUN mkdir -p ~/opensim-workspace/Netbeans12.3 && cd ~/opensim-workspace/Netbeans12.3 && \
    wget -q https://archive.apache.org/dist/netbeans/netbeans/12.3/Apache-NetBeans-12.3-bin-linux-x64.sh && \
    chmod 755 Apache-NetBeans-12.3-bin-linux-x64.sh && \
    ./Apache-NetBeans-12.3-bin-linux-x64.sh --silent

# Get opensim-core.
RUN git clone https://github.com/opensim-org/opensim-core.git ~/opensim-workspace/opensim-core-source && \
    cd ~/opensim-workspace/opensim-core-source && \
    git checkout branch_4.4

# Build opensim-core dependencies.
RUN mkdir -p ~/opensim-workspace/opensim-core-source/dependencies/build && \
    cd ~/opensim-workspace/opensim-core-source/dependencies/build && \
    cmake ~/opensim-workspace/opensim-core-source/dependencies \
      -DCMAKE_INSTALL_PREFIX='~/opensim-workspace/opensim-core-dependencies/' \
      -DCMAKE_BUILD_TYPE='RelWithDebInfo' \
      -DSUPERBUILD_simbody=ON \
      -DSUPERBUILD_spdlog=ON \
      -DSUPERBUILD_ezc3d=ON \
      -DSUPERBUILD_docopt=ON \
      -DSUPERBUILD_BTK=OFF \
      -DOPENSIM_WITH_CASADI=ON \
      -DOPENSIM_WITH_TROPTER=ON && \
    make -j$BUILD_CORES

# Build opensim-core.
RUN mkdir -p ~/opensim-workspace/opensim-core-source/build && \
    cd ~/opensim-workspace/opensim-core-source/build && \
    cmake ../ \
      -DBUILD_JAVA_WRAPPING=ON \
      -DBUILD_PYTHON_WRAPPING=ON \
      -DBUILD_TESTING=OFF \
      -DCMAKE_BUILD_TYPE='RelWithDebInfo' \
      -DCMAKE_INSTALL_PREFIX='~/opensim-core' \
      -DOPENSIM_C3D_PARSER=ezc3d \
      -DOPENSIM_COPY_DEPENDENCIES=ON \
      -DOPENSIM_COPY_DEPENDENCIES=ON \
      -DOPENSIM_DEPENDENCIES_DIR='~/opensim-workspace/opensim-core-dependencies/' \
      -DOPENSIM_INSTALL_UNIX_FHS=OFF \
      -DOPENSIM_WITH_CASADI=ON \
      -DOPENSIM_WITH_TROPTER=ON \
      -DSWIG_DIR=~/swig/share/swig \
      -DSWIG_EXECUTABLE=~/swig/bin/swig/ \
      -DWITH_BTK=OFF \
      -DWITH_EZC3D=ON &&\
    make -j$BUILD_CORES && \
    make install

RUN cd ~/opensim-core/sdk/Python %% \
    sudo python3 setup.py install

RUN echo "export USER='$(whoami)'" >> ~/.bashrc

# Install dependencies that support WebGL https://stackoverflow.com/questions/69351416/docker-webgl-headless-chrome-error-passthrough-is-not-supported-gl-is-disa
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xorg xserver-xorg xvfb libx11-dev libxext-dev

CMD ["/bin/bash"]
