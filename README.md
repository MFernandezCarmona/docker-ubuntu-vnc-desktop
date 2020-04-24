ros-kinetic-desktop-lcas
=========================

Docker image to provide HTML5 VNC interface to access ROS kinetic on Ubuntu 16.04 with the LXDE desktop environment and LCAS development software.
This is a fork of docker-ubuntu-vnc-desktop

Building your image
-------------------------

```
sudo docker build --tag ros-kinetic-desktop-lcas --build-arg repository_password=[RESTRICTED REPO PASSWORD] --network host .
```


Quick Start
-------------------------

Run the docker image and open port `6080` with access to your iliad workspace:

```
docker run -it -d -v /home/manolofc/workspace/iliad_ws:/home/manolofc/workspace/iliad_ws --rm -p 6080:80 ros-kinetic-desktop-lcas:latest
```

Browse http://127.0.0.1:6080/

