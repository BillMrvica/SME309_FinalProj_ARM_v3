# install vivado package and put it in ~/Download 
cd ~
mkdir vivado-dir
mv ~/Downloads/Xilinx_Vivado_SDK_2018.3_1207_2324.tar ~/vivado-dir/
cd vivado-dir
tar -zxvf ./Xilinx_Vivado_SDK_2018.3_1207_2324.tar
rm -rf ./Xilinx_Vivado_SDK_2018.3_1207_2324.tar

# Install 

# Install Docker
brew install --cask docker

# Create Docker
docker pull ubuntu

docker ps    # show executing dockers
docker ps -a # show all the docker

xhost + # enable local host
docker run --name vivado --platform linux/amd64 -v ~/vivado-dir:/vivado -e DISPLAY=$DISPLAY  -i -t ubuntu bash 
docker run --name vivado --platform linux/amd64  -v ~/vivado-dir:/vivado -v /dev:/dev -v /tmp/.X11-unix:/tmp/.X11-unix:rw  -v ~/.Xauthority:/root/.Xauthority -e DISPLAY=docker.for.mac.host.internal:0  -i -t ubuntu /bin/bash
docker exec vivado /bin/bash

# install dependencies
apt update
apt -y --no-install-recommends install ca-certificates curl sudo xorg dbus dbus-x11 ubuntu-gnome-default-settings gtk2-engines lxappearance gedit
gedit # test whether x11 could be activated

# go to install package repository, run "xsetup" tool scripts
cd /vivado/Xilinx_Vivado_SDK_2018.3_1207_2324 # the name of the file might be different
./xsetup