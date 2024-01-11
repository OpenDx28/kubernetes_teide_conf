
# Configuración de Cluster Kubernetes en Teide

## configuración para el master

### Configuración de Loadbalancer

En nuestro entorno de sistema baremetal, que carece de una configuración de load balancing predeterminada para Kubernetes, hemos implementado un enfoque de simulación utilizando MetalLB. Este proceso se inicia con la creación de un 'configmap' en MetalLB, donde especificamos la dirección IP que será utilizada como la IP pública, configurando así un 'address pool'. Posteriormente, configuramos un servicio de tipo Load Balancer utilizando Traefik, indicándole que utilice el 'address pool' definido en MetalLB. Con esta configuración en su lugar, todos los ingresos (ingress) creados para diferentes servicios en nuestro sistema ahora se dirigirán eficientemente a través de esta IP pública asignada. Este enfoque nos permite gestionar el tráfico de red entrante de manera eficiente, asegurando una distribución equilibrada de las cargas a través de los servicios en nuestro clúster de Kubernetes.

videos relacionados:

https://www.youtube.com/watch?v=ZuRrpD3hL5I

https://www.youtube.com/watch?v=UrEN45uChpQ

## Configuración de Nodos en Teide

Esta sección detalla la configuración e instalación necesarias para integrar nodos adicionales al clúster de Kubernetes en Teide. La configuración de estos nodos se enlaza con el control plane ubicado en la IP 10.129.0.2 y una IP externa 193.147.109.10.

### Proceso de Configuración para Ubuntu 22.04:
1. **Ejecución del Script de Configuración de Nodos:** Primero, se ejecuta `nodes_conf.sh` en los nodos.
2. **Verificación y Solución de Problemas:** Tras la ejecución, se observa que, aunque el nodo se conecta al master, los pods entran en un estado de 'crashloopbackoff', reiniciándose continuamente. Este problema se atribuye a incompatibilidades entre la versión de Ubuntu y containerd.
3. **Configuración Específica de Containerd:** Para resolver esto, se ejecuta el script `containerd_conf_ubuntu2204.sh`.
4. **Reinicio del Nodo:**
    i. En el master, se ejecuta `kubectl drain worker node 1 --force --ignore-daemonsets`.
    ii. Se realiza un reinicio (`reboot`) en el servidor del nodo.
    iii. Finalmente, se ejecuta `kubectl uncordon node 1` en el master.

Tras este proceso, se espera que el nodo funcione correctamente.

### Trabajo Futuro:
- Simplificar el proceso de configuración en un solo paso.
- Realizar comprobaciones adicionales en los últimos comandos del script `nodes_conf.sh` para la compatibilidad con Ubuntu 20.04.

### Consideraciones Importantes:
- Se utilizan nodos tanto con Ubuntu 22.04 como con 20.04. Esta diversidad de versiones puede presentar desafíos en el mantenimiento de componentes comunes en los nodos, lo cual requiere una gestión cuidadosa para asegurar la compatibilidad y el funcionamiento óptimo del sistema.


