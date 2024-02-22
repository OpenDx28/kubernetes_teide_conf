#!bin/bash

# desinstalar helm chat si se trata de una instalación:

# para saber chart y release :
# helm list

# helm uninstal 
# helm uninstall [RELEASE_NAME]

# para reseat valores del chart 

# helm upgrade [RELEASE_NAME] [CHART] --reset-values

.

helm install --wait --generate-name -n nvidia-gpu-operator --create-namespace nvidia/gpu-operator

# después hacer reboot del nodo

k drain opendxgpu --force --ignore-daemonsets

# en el nodo de gpu
# reboot
k uncordon opendxgpu
