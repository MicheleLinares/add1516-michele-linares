#NFS (Network File System)

NFS es una forma de crear recursos en red para compartir con sistemas heterogéneos.

#1. SO Windows

Vamos a usar 2 máquinas:
* MV Windows 2008 Server (Enterprise) como servidor NFS.
    * El nombre de esta máquina sera: "Linares10WS".
    * IP estática: 172.18.10.22
    * Grupo de trabajo: AULA108

    ![](./imagenes/1.png)

    ![](./imagenes/2.png)

* MV Windows (Enterprise) como cliente NFS.
    * El nombre de esta máquina sera: "Linares10WC".
    * IP estática 172.18.10.12
    * Grupo de trabajo: AULA108

    ![](./imagenes/4.png)

    ![](./imagenes/3.png)
    

##1.1 Servidor NFS Windows


Instalación del servicio NFS en Windows 2008 Server
* Agregamos el rol `Servicios de Archivos`y damos a siguiente.

	![](./imagenes/5.png)

* Ahora marcamos `Servicios para NFS`.

	![](./imagenes/6.png)


Configurar el servidor NFS de la siguiente forma:
* Creamos la carpeta `c:\export\public`. Nos vamos a: `Propiedades -> Uso compartido NFS`, Acivamos la casilla para compartir esta carpeta y le damos permisos `lectura/escritura` para todos.

	![](./imagenes/8.png)

* Crear la carpeta `c:\export\private`. Nos vamos a: `Propiedades -> Uso compartido NFS`, Activamos la casilla para compartir esta carpeta y le damos permisos de `lectura` para todos.

	![](./imagenes/9.png)


* Ejecutamos el comando `showmount -e ip-del-servidor`, para comprobar los recursos compartidos.

	![](./imagenes/10.png)

##1.2 Cliente NFS


**Instalamos el soporte cliente NFS bajo Windows**
* Vamos a instalar el componente cliente NFS para Windows. Para ello vamos a `Panel de Control -> Programas -> Activar o desactivar características de Windows`.
* Nos desplazamos por el menú hasta localizar Servicios para NFS y dentro de este, Cliente NFS. 


	![](./imagenes/12.png)

**Iniciamos el servicio cliente NFS.**
* Para iniciar el servicio NFS en el cliente, mediante una consola con permisos de Administrador ejecutamos el siguiente comando: `nfsadmin client start`

	![](./imagenes/13.png)

**Montando el recurso**

Ahora necesitamos montar el recurso remoto para poder trabajar con él.
> Esto no lo hacemos con Administrador, sino con nuestro usuario normal.
* Montar recurso remoto: `mount –o anon,nolock,r,casesensitive \\\172.18.10.22\public *`
* Comprobar: `net use`
* Comprobar: `showmount -a 172.18.10.22`

	![](./imagenes/14.png)
	
* En el servidor ejecutamos el comando `showmount -e 172.18.10.22`, para comprobar los recursos compartidos.

	![](./imagenes/15.png)
    

* La letra de la unidad se asigna de forma automática, así que nos asignará la Z.

	![](./imagenes/16.png)


* Podemos comprobar que desde el cliente, accediendo a la carpeta `public`, no podemos crear nada ya que solo tenemos permisos de lectura.

	![](./imagenes/17.png)

