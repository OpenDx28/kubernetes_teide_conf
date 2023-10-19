#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

set -euxo pipefail

# Variable Declaration

KUBERNETES_VERSION="1.26.4-00"

# disable swap
sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y


sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# # INSTALO Docker

# https://docs.docker.com/engine/install/ubuntu/

# Set up Docker's Apt repository.

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install with master node docker version

ubuntu_version=$(lsb_release -r -s)

f [ "$ubuntu_version" == "20.04" ]; then
    VERSION_STRING="5:23.0.5-1~ubuntu.22.04~jammy"
elif [ "$ubuntu_version" == "22.04" ]; then
    VERSION_STRING="5:24.0.6-1~ubuntu.20.04~focal"
fi

CONTAINER_VERSION="1.6.20"

sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin


sudo systemctl start containerd # creo que o es necesario

sudo service docker start


sudo docker run hello-world

echo "Docker installed succesfully"

echo containerd version:

containerd --version





# ---

# Install kubelet, kubectl and Kubeadm

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"
sudo apt-get update -y
sudo apt-get install -y jq

local_ip="$(ip --json addr show eth0 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"

sudo sh -c "cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF"


# Create the drop-in file and add the content in one command
sudo sh -c 'echo "[Service]" > /etc/systemd/system/kubelet.service.d/0-containerd.conf'
sudo sh -c 'echo "Environment=\"KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock\"" >> /etc/systemd/system/kubelet.service.d/0-containerd.conf'

# reload system configuratio
systemctl daemon-reload


# THIS IS ALWAYS NEEDED IN UBUNTU 22.04 AND AFTER JOIN CONTAINERS APPLY containerd_conf_ubuntu2204.sh and reboot
# BUT MAYBE NOT NEEDED IN UBUNTU 20.04

sudo rm /etc/containerd/config.toml

systemctl restart containerd

# add node tu cluster using kubeadmin join command:

sudo kubeadm join 10.129.0.2:6443 --token jzzpr0.7gyd80qyea4128g2 --discovery-token-ca-cert-hash sha256:4b2e7feb8911fb0aa8a8ca1046c4c5157843ca7659a3f10f8c3048836c5d876e




# posible errpr when usinf kubeadm join: 

# [init] Using Kubernetes version: v1.24.1
# [preflight] Running pre-flight checks
# error execution phase preflight: [preflight] Some fatal errors occurred:
#         [ERROR CRI]: container runtime is not running: output: time="2023-01-19T15:05:35Z" level=fatal msg="validate service connection: CRI v1 runtime API is not implemented for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService"
# , error: exit status 1
# [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
# To see the stack trace of this error execute with --v=5 or higher

# solved: https://forum.linuxfoundation.org/discussion/862825/kubeadm-init-error-cri-v1-runtime-api-is-not-implemented

# 1. Set up the Docker repository as described in https://docs.docker.com/engine/install/ubuntu/#set-up-the-repository
# 2. Remove the old containerd:apt remove containerd
# 3. Update repository data and install the new containerd: apt update, apt install containerd.io
# 4. Remove the installed default config file: rm /etc/containerd/config.toml
# 5. Restart containerd: systemctl restart containerd