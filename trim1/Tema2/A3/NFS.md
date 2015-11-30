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

Esto no lo hacemos con Administrador, sino con nuestro usuario normal.
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

#2. SO OpenSUSE

Vamos a necesitar 2 máquinas GNU/Linux:

* MV OpenSUSE, será nuestro servidor NFS
	* Nombre de la máquina: nfs-server-08, tendremos que modificar el fichero '/etc/hostname' para establecer el nombre de la máquina.
	* IP estática 172.18.08.52
	* Modo puente
	
	![](images-opensuse/1.png)

    ![](images-opensuse/2.png)
    
* MV OpenSUSE, será nuestro cliente NFS:
	* Nombre de la máquina: nfs-client-08
	* IP estática 172.18.08.62
	* Modo puente
	
	![](images-opensuse/1cli.png)

    ![](images-opensuse/2cli.png)
   
##2.1. Servidor NFS

* Instalamos el servidor NFS por Yast. También podríamos instalarlo mediante la consola: 'apt-get install nfs-server'

* Creamos las siguientes carpetas y les asignamos permisos:

	![](images-opensuse/4.png)

* Configuramos el servidor NFS, abrimos el puerto en el cortafuegos e iniciamos automáticamente con el arranque:

	![](images-opensuse/3.png)

* Añadimos los recursos compartidos, y los configuramos de manera que en 'public' pueda acceder cualquiera y en 'private' solo la máquina cliente:

	![](images-opensuse/5.png)

	![](images-opensuse/6.png)

* Para iniciar y parar el servicio NFS, podemos hacerlo directamente desde el Yast o mediante comandos: 'systemctl start nfsserver.service'

* Lo comprobamos ejecutando 'showmount -e localhost', este comando nos muestra la lista de recursos exportados por el servidor NFS.

	![](images-opensuse/7.png)

* Comprobamos que el servicio está activo:

	![](images-opensuse/8.png)

##2.2. Cliente NFS

Comprobamos que las carpetas del servidor son accesibles desde el cliente:
	
* Primero comprobamos la conectividad desde el cliente hacia el servidor:
	
	![](images-opensuse/ping.png)
	
* Ejecutamos nmap para escanear y averiguar que servicios está ofreciendo la IP que escaneemos al exterior:
	
	![](images-opensuse/9.png)
	
* Mostramos la lista de recursos exportados por el servidor NFS:
	
	![](images-opensuse/10.png)

* Ahora pasamos a montar y usar cada recurso compartido. Primero creamos la carpeta '/mnt/remoto', y lo montamos directamente desde Yast:

	![](images-opensuse/14.png)

* Ejecutando el comando 'df -hT' nos aparecerá el recurso montado:

	![](images-opensuse/11.png)
	
* Haremos lo mismo con el recurso 'private'

	![](images-opensuse/15.png)
	
* Ya podemos crear carpetas o ficheros dentro de public, pero sólo nos permitirá leer en private:

	* Creamos un fichero dentro de public sin problema:

	![](images-opensuse/12.png)
	
	* Entramos en private e intentamos crear un fichero, vemos que nos indica que solo tenemos permisos de lectura:

	![](images-opensuse/13.png)
	
##2.3. Montaje automático

* Para que los recursos se monten automáticamente cada vez que se inicie el equipo en OpenSUSE usamos Yast o bien modificamos la configuración directamente en el fichero '/etc/fstab':

	![](images-opensuse/16.png)
	
<<<<<<< HEAD
=======
	
#3. Preguntas	

* ¿Nuestro cliente GNU/Linux NFS puede acceder al servidor Windows NFS? Comprobarlo.

* ¿Nuestro cliente Windows NFS podría acceder al servidor GNU/Linux NFS? Comprobarlo.

	* Montamos los dos recusos Linux en nuestro cliente Windows con los siguientes comandos:

		![](imagenes/20.png)
		
	* Comprobamos que se han montado.

		![](imagenes/21.png)
		
	* En Public comprobamos que podemos crear y eliminar archivos.

		![](imagenes/22.png)
		
	* En Private comprobamos que no podemos crear ni eliminar.

		![](imagenes/23.png)








>>>>>>> ups/master

