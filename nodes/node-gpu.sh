# in gpu node

#  1. install nvidia-container-toolkit
#  2. configure the nvidia-container-runtime

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd