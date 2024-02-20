# Instalación de Quantum ESPRESSO en Docker

## Especificaciones

* CUDA 12.3
* Nvidia HPC 24.1
* Ubuntu 22.04
* Quantum ESPRESSO 7.2

> En este documento solo se hará la construcción de una imagen que contenga Quantum SPRESSO instalado y compilado para su GPU, si desea hacer la instalación manual le recomendamos seguir esta otra documentación.

## Instalación de Docker

La imagen que se utiliza como base para construir ésta pertenece a [NVIDIA HPC SDK](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/nvhpc/tags); la cual contiene todas las herramientas y librerías necesarias para compilar Quantum ESPRESSO en nuestro GPU.

> Para más información sobre Nvidia High Performance Computing haga click [aquí](https://developer.nvidia.com/hpc-sdk)

Antes de construir la imagen es necesario que tenga instalado docker en su sistema, si no tiene instalado docker puede seguir estos pasos.

## Docker en Windows

### Descargar Docker Desktop

EL primer paso sería descargar el instalador de Docker Desktop de la página oficial de docker:

https://www.docker.com/products/docker-desktop/

Una vez descargado el instalador ejecútelo y siga los pasos de éste. El instalador le mostrará dos opciones de instalación, deje esos recuadros palomeados y proceda a instalar docker. Al finalizar la instalación le pedirá que reinicie la computadora, reinicie la computadora y cuando inicie otra vez sesión seleccione la configuración recomendada por docker para finalizar la instalación; no es necesario crear una cuenta de docker.

### WSL 2

El segundo paso será checar si tiene instalado windows subsystem for linux (WSL), puede utilizar el comando `wsl -l -v` en una terminal powershell y le mostrará un listado de ambientes que tiene y su versión, ejemplo:

```Powershell
  NAME                   STATE           VERSION
* Ubuntu-20.04           Running         2
  docker-desktop-data    Running         2
  docker-desktop         Running         2
```

En este ejemplo se puede ver que en `VERSION` indica 2, lo que quiere decir que WSL 2 está instalado correctamente; para docker, es necesario que WSL corra en esta versión; si cuenta con la versión de WSL 2 en las distribuciones de docker, el proceso de instalación termina aquí. 

En caso de no tener instalado WSL solo escriba en una terminal powershell: `wsl --install` y vuelva a probar el comando anterior: `wsl -l -v`.

Si ahora la versión es 1, tendrá que actualizar y definir como versión principal la número 2. El comando el siguiente:

``` Powershell
wsl --set-version NAME 2
```

Reemplace NAME por el nombre de la distribución que desee actualizar, en el caso de arriba el comando `wsl -l -v` muestra un listado de las disribuciones que se tiene, si instaló docker antes de llegar aquí, deberían salir las distribuciones de docker, las cuales debe actualizar a WSL 2.

Finalmente, debe de poner como default la versión 2 de WSL mediante este comando:

```Powershell
wsl --set-default-version 2
```

Esto ayudará a futuras intalaciones de distribuciones linux.

### Referencias

> Para más información puede consultar los siguientes links: <br>https://learn.microsoft.com/es-es/windows/wsl/install <br>https://docs.docker.com/desktop/wsl/

## Docker en Linux

Para instalar docker dentro en ubuntu puede primero depurar contenido que ya se tenga de docker mediante el siguiente comando:

```shell
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

Para instalar docker primero hay que añadir las llaves del repositorio de docker al sistema. Para ellos primero actualizaremos los repositorios de ubuntu:

```shell
sudo apt-get update
```

Después descargaremos las llaves con los siguientes comandos, en orden.


```shell
sudo apt-get install ca-certificates curl
```

```shell
sudo install -m 0755 -d /etc/apt/keyrings
```

```shell
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

```shell
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Una vez descargadas las llaves, añadiremos el repositorio a los archivos de apt.


```shell
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Volvemos a actualizar los repositorios:

```shell
sudo apt-get update
```

Ahora pasaremos a la instalación de docker, para instalar la versión más reciente de docker con sus paquetes utilizaremos el siguiente comando:

```Shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Finalmente, para verificar que docker se instaló correctamente correremos el siguiente comando:

```Shell
sudo docker run hello-world
```

Debería salirte lo siguiente:

```shell
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Si te salió el mensaje de arriba quiere decir que docker se instaló correctamente; sin embargo, docker necesita permisos de super usuario para poder correrse sin el comando sudo, por lo que tendrá que crear un grupo de docker y añadirle su usuario de la siguiente manera:

Crea un grupo llamado docker:

```shell
sudo groupadd docker
```

Añadimos el usuario principal al grupo:

```shell
sudo usermod -aG docker $USER
```

Reinicie la terminal.

De manera opcional, puede activar los cambios del grupo corriendo el siguiente comando:

```shell
newgrp docker
```

Ahora pruebe correr el comando de docker run sin el sudo:

```shell
docker run hello-world
```

Para terminar con el apartado de ubuntu, si quiere activar docker desktop en su sistema ubuntu deberá descargar el último [DEB package](https://desktop.docker.com/linux/main/amd64/137060/docker-desktop-4.27.2-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64). Para más información revice el último link de las referencias del final del apartado de linux.

Actualice los repositorios:

```shell
sudo apt-get update
```

Finalmente, diríjase a la carpeta donde se descargó el archivo de docker desktop e instale el paquete. En mi caso, la versión que se descargó en feb de 2024 es la siguiente:

```shell
sudo apt-get install ./docker-desktop-4.27.2-amd64.deb
```

**TIP:** puede escribir `sudo apt-get install ./docker` y rellenar lo demás presionando la tecla Tab.

Una vez descargado e instalado el paquete de docker desktop, vaya a la sección de aplicaciones y busque docker desktop.

![desktop](https://docs.docker.com/desktop/install/images/docker-app-in-apps.png)

> Para más información puede consultar los siguientes links: <br>https://docs.docker.com/engine/install/ubuntu/ <br>https://docs.docker.com/engine/install/linux-postinstall/ <br>https://docs.docker.com/desktop/install/linux-install/

## Construcción de la imagen

El archivo Dockerfile contiene los pasos de construcción de la imagen de Quantum Espresso; para empezar a construir la imagen se necesita abrir una terminal que esté dentro de la carpeta de este proyecto. Si se encuentra en VS code puede abrir una terminal en esta misma carpeta con el comando `ctrl + ñ` o en la parte superior hay una pestaña llamada terminal.

Tecleé el siguiente comando en la terminal:

```Powershell
docker build -t espresso .
```

Donde dice: espresso, es el nombre que se le dará a la imagen, la bandera `-t` nos permite asignarle un nombre a nuestra imagen, en este caso se puso espresso, pero puede ponerle como guste, solo al momento de correlo ponga el nombre que le asignó al comando docker run que se verá más adelante.

Este paso puede tardar hasta una hora dependiendo su conexión a internet o potencia de computadora.

Al final del proceso debería salir un mensaje como este:

```Powershell
[+] Building 1.4s (13/13) FINISHED                                                                            docker:default
 => [internal] load build definition from Dockerfile                                                                    0.0s
 => => transferring dockerfile: 1.09kB                                                                                  0.0s
 => [internal] load metadata for nvcr.io/nvidia/nvhpc:24.1-devel-cuda12.3-ubuntu22.04                                   1.2s
 => [internal] load .dockerignore                                                                                       0.0s
 => => transferring context: 355B                                                                                       0.0s
 => [1/8] FROM nvcr.io/nvidia/nvhpc:24.1-devel-cuda12.3-ubuntu22.04@sha256:171e2f5f2984f5413051fa11c5ac6432a301f36bef9  0.0s
 => [internal] load build context                                                                                       0.0s
 => => transferring context: 200B                                                                                       0.0s
 => CACHED [2/8] RUN apt-get update                                                                                     0.0s
 => CACHED [3/8] RUN apt-get install -y --no-install-recommends     apt-utils     autoconf     build-essential     qua  0.0s
 => CACHED [4/8] RUN cd /root &&     wget https://gitlab.com/QEF/q-e/-/archive/qe-7.2/q-e-qe-7.2.tar.gz &&     tar -zx  0.0s
 => CACHED [5/8] RUN cd /root/q-e-qe-7.2 &&     ./configure         --with-cuda=/opt/nvidia/hpc_sdk         --with-cud  0.0s
 => CACHED [6/8] RUN echo 'export PATH="/root/q-e-qe-7.2/bin:$PATH"' >> ~/.bashrc                                       0.0s
 => CACHED [7/8] WORKDIR /app/prueba                                                                                    0.0s
 => CACHED [8/8] COPY . .                                                                                               0.0s
 => exporting to image                                                                                                  0.0s
 => => exporting layers                                                                                                 0.0s
 => => writing image sha256:e454a46b2bb95b9536992c97d2f0ea2e9ef1642605ea54a6fdf7f6cf9d97599d                            0.0s
 => => naming to docker.io/library/espresso                                                                             0.0s

View build details: docker-desktop://dashboard/build/default/default/gna3nww2yt6yyklrglsq89etf

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview
```

Para corroborar que la imagen se haya construído puede escribir el siguiente comando en la terminal:

```Powershell
docker images
```

Si la imagen se construyó exitosamente debería salirte el listado de imágenes que se tienen de la siguiente manera:

```Powershell
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
espresso     latest    e454a46b2bb9   4 hours ago   15.2GB
```

También se puede revisar en el apartado de images de docker desktop.

Para correr la imagen de manera directa sin crear ningún en específico corra el siguiente comando:

```Powershell
docker run --gpus all -it espresso
```

Es importante poner `--gpus all` al comando para que la imagen pueda detectar todas las gpus de la computadora. Ahora, la bandera: `-it` nos sirve para poder entrar a la máquina virtual y poder controlar la terminal.

La salida debería ser la siguiente:

```shell
====================
== NVIDIA HPC SDK ==
====================
 
NVIDIA HPC SDK version 24.1
 
Copyright (c) 2024, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

WARNING: The NVIDIA Driver was not detected.  GPU functionality will not be available.
Use 'docker run --gpus all' to start this container; see
https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)

root@0c4887e73636:/app/prueba# 
```

> NOTA: si sale el mensaje de error: WARNING: The NVIDIA Driver was not detected. GPU functionality will not be available. <br>Escriba `nvidia-smi`, de enter y debería salirle información de la GPU, de ser así, ignore el mensaje de advertencia. 

La salida (en mi caso) es:

```shell
root@0c4887e73636:/app/prueba# 
```

Lo que indica que estoy dentro de la imagen que se creó exitosamente y puedo empezar a experimentar dentro de la imagen.
