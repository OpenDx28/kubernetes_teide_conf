# Configuración de Cluster Kubernetes en Teide

## configuración para el master


## Configuración para los nodos

Configuración e instalaciones para los añadir nodos al cluster en Teide con su contral plane en 10.129.0.2 esternal IP 193.147.109.10.

Para ubuntu 22.04, una vez ejecutado el script nodes_conf.sh, se debe ejecutar container_conf_ubuntu2204.sh

Por ahora se ha probado de la siguiente manera:
1. se ejecuta nodes_conf.sh
2. se comprueba que el master ve al node pero los pods están constantemente en crashloopbackoff reiniciándose constantemente. Esto se debe a un problema con la versión de ubuntu y containerd
3. se ejecuta el script containerd_conf_ubuntu2204.sh
4. se reinicia el nodo, para ello:
    1. se hace un kubectl drain worker node 1 --force --ignore-daemonsets en el master
    2. se hace un reboot en el server
    3. se hace un kubectl uncordon node 1 en el master

Una vez reiniciado el nodo debería funcionar normalmente

### trabajo futuro
Resumir todos los pasos a uno y hacer comprobaciones sobre los últimos comandos del script nodes_conf.sh para Ubuntu 20.04

### A tener en cuenta
Hay nodos con Ubuntu 22.04 y otros con 22.04. Esto puede ser un problema para temas de mantenimiento de los componentes comunes que hay en los nodos.


