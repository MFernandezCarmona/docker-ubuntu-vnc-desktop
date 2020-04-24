#   docker build --build-arg repository_password=Q1JF1DEQuyefgdzY8x

ARG repository_password
ARG user_name

FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# =================================
# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl python-software-properties software-properties-common \
#    && sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
#    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
#    && add-apt-repository ppa:fcwu-tw/ppa \
#    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta  \
        dbus-x11 x11-utils \
        terminator \
		gedit \
        dirmngr \
        gnupg2 \		
		nano \
		less \
        aptitude \
        tmux \
#		arc-theme \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# =================================
# install ros (source: https://github.com/osrf/docker_images/blob/5399f380af0a7735405a4b6a07c6c40b867563bd/ros/kinetic/ubuntu/xenial/ros-core/Dockerfile)

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     dirmngr \
#     gnupg2 \
#     && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y  ros-kinetic-desktop ros-kinetic-rospack python-rosinstall-generator python-wstool python-pip  python-bloom \
    && rm -rf /var/lib/apt/lists/*

# =================================
# LCAS repos

# HACK: http://stackoverflow.com/questions/25193161/chfn-pam-system-error-intermittently-in-docker-hub-builds
RUN ln -s -f /bin/true /usr/bin/chfn

# Install LCAS key & Add repository
COPY public.key /tmp/
RUN apt-key add /tmp/public.key &&  apt-add-repository http://lcas.lincoln.ac.uk/ubuntu/main

# Add restricted repository
RUN if [ "$repository_password" ] ; then apt-add-repository https://restricted:$repository_password@lcas.lincoln.ac.uk/ubuntu/restricted; fi

# Mostly for developing.
RUN bash -c "rm -rf /etc/ros/rosdep; source /opt/ros/kinetic/setup.bash; rosdep init"
RUN curl -o /etc/ros/rosdep/sources.list.d/20-default.list https://raw.githubusercontent.com/LCAS/rosdistro/master/rosdep/sources.list.d/20-default.list && \
    curl -o /etc/ros/rosdep/sources.list.d/50-lcas.list https://raw.githubusercontent.com/LCAS/rosdistro/master/rosdep/sources.list.d/50-lcas.list
RUN mkdir -p /root/.config/rosdistro/ && \
    echo "index_url: https://raw.github.com/lcas/rosdistro/master/index.yaml" > /root/.config/rosdistro/index.yaml

# Install ILIAD  packages
RUN apt-get update && apt-get install -y ros-kinetic-iliad-launch-system \
                                         ros-kinetic-iliad-executive \
                                         ros-kinetic-iliad-launch-manipulation \
                                         ros-kinetic-iliad-leg-tracker \
                                         ros-kinetic-iliad-topological \
                                         ros-kinetic-navigation-oru \
                                         ros-kinetic-cliffmap-ros \
                                         ros-kinetic-cliffmap-rviz-plugin  \
                                         iproute \ 
                                         ros-kinetic-qsr-lib \
                   &&  apt-get clean


# Marc's stuff for mac stuff
RUN curl -o /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate && chmod +x /usr/local/bin/rmate 
# Needed in ILIAD
RUN pip install --upgrade pip
RUN pip install -U tmule

# tini for subreap
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

# homebrew tools
ADD image /

# more tools and dependencies
RUN pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

RUN cp /usr/share/applications/terminator.desktop /root/Desktop
RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
