#1. Puppet

##1.1 Preparación MVs

- Vamos a usar 3 MV's con las siguientes configuraciones:

	* MV1 - master: Dará las órdenes de instalación/configuración a los clientes.
	    * SO GNU/Linux OpenSUSE 13.2
	    * IP estática 172.18.10.100
	    * Enlace: 172.18.0.1
	    * DNS: 8.8.4.4
	    * Nombre del equipo: master10
	    * Dominio = linares
	    * Instalar OpenSSH.
	* MV1 - client1: recibe órdenes del master.
	    * SO GNU/Linux OpenSUSE 13.2
	    * IP estática 172.18.10.101
	    * Enlace: 172.18.0.1
	    * DNS: 8.8.4.4
	    * Nombre del equipo: cli1alu10
	    * Dominio = primer-apellido-del-alumno
	    * Instalar OpenSSH.
	* MV3 - client2: recibe órdenes del master.
	    * SO Windows 7.
	    * IP estática 172.18.10.102
	    * Enlace: 172.18.0.1
	    * DNS: 8.8.4.4
	    * Nombre Netbios: cli2alu10
	    * Nombre del equipo: cli2alu10
	    * Grupo de trabajo = AULA108
	    * Instalar Servidor.
 
Cada MV debe tener configurada en su `/etc/hosts` al resto. 

**GNU/Linux**

- El fichero `/etc/hosts` tiene este contenido:


 	![](imagenes/3.png)

 **Windows**

- En el fichero hosts de Windows tenemos ese contenido:

 	![](imagenes/2.png)


##1.2 Comprobacion de las configuraciones

 En GNU/Linux, para comprobar que las configuraciones son correctas hacemos:
  
	date
	ip a
    route -n
    host www.google.es
    hostname -a
    hostname -f
    hostname -d
    ping master10
    ping master10.linares
    ping cli1alu10
    ping cli1alu10.linares
    ping cli2alu10
    ping cli2alu10.linares  

 	![](imagenes/4.png)
 	![](imagenes/5.png)

En Windows comprobamos con:

    date
    ipconfig
    route /PRINT
    nslookup www.google.es
    ping master10
    ping master10.linares
    ping cli1alu10
    ping cli1alu10.linares
    ping cli2alu10
    ping cli2alu10.linares

 	![](imagenes/6.png)
 	![](imagenes/7.png)


#2. Instalación y configuración Puppet

* Instalamos Puppet Master en la MV master10: `zypper install puppet-server puppet puppet-vim`.

  	![](imagenes/8.png)

* `systemctl status puppetmaster`: Consultar el estado del servicio.

 	![](imagenes/18.png)

* Preparamos los ficheros/directorios en el master10:

    mkdir /etc/puppet/files
	mkdir /etc/puppet/manifests
	mkdir /etc/puppet/manifests/classes
	touch /etc/puppet/files/readme.txt
	touch /etc/puppet/manifests/site.pp
	touch /etc/puppet/manifests/classes/hostlinux1.pp


##2.1 /etc/puppet/manifests/site.pp

* `/etc/puppet/manifests/site.pp` es el fichero principal de configuración 
de órdenes para los agentes/nodos puppet.
* Contenido de nuestro `site.pp`:
```
import "classes/*"

node default {
  include hostlinux1
}
```
> Esta configuración significa:
> * Todos los ficheros de configuración del directorio classes se añadirán a este fichero.
> * Todos los nodos/clientes van a usar la configuración `hostlinux1`

##2.3 /etc/puppet/manifests/classes/hostlinux1.pp

Como podemos tener muchas configuraciones, vamos a separarlas en distintos ficheros para
organizarnos mejor, y las vamos a guardar en la ruta `/etc/puppet/manifests/classes`

*Vamos a crear una primera configuración para máquina estándar GNU/Linux.
* Contenido para `/etc/puppet/manifiests/classes/hostlinux1.pp`:
```
class hostlinux1 {
  package { "tree": ensure => installed }
  package { "traceroute": ensure => installed }
  package { "geany": ensure => installed }
}
```

> **OJO**: La ruta del fichero es `/etc/puppet/manifests/classes/hostlinux1.pp`.

* Comprobar que tenemos los permisos adecuados en la ruta `/var/lib/puppet`.
* Reiniciamos el servicio `systemctl restart puppetmaster`.
* Comprobamos que el servicio está en ejecución de forma correcta.
    * `systemctl status puppetmaster`
    * `netstat -ntap`
* Consultamos log por si hay errores: `tail /var/log/puppet/*.log`
* Abrir el cortafuegos para el servicio.

#3. Instalación y configuración del cliente1

Instalación:
* Instalamos Agente Puppet en el cliente: `zypper install puppet`
* El cliente puppet debe ser informado de quien será su master. 
Para ello, añadimos a `/etc/puppet/puppet.conf`:

```
    [main]
    server=masterXX.primer-apellido-alumno
    ...
```
* Comprobar que tenemos los permisos adecuados en la ruta `/var/lib/puppet`.
* `systemctl status puppet`: Ver el estado del servicio puppet.
* `systemctl enable puppet`: Activar el servicio en cada reinicio de la máquina.
* `systemctl start puppet`: Iniciar el servicio puppet.
* `systemctl status puppet`: Ver el estado del servicio puppet.
* `netstat -ntap`: Muestra los servicios conectados a cada puerto.
* Comprobamos los log del cliente: `tail /var/log/puppet/puppet.log`

#4. Certificados

Antes de que el master acepte a cliente1 como cliente, se deben intercambiar los certificados entre 
ambas máquinas. Esto sólo hay que hacerlo una vez.

##4.1 Aceptar certificado

* Vamos al master y consultamos las peticiones pendiente de unión al master: `puppet cert list`
```
    root@master30# puppet cert list
    "cli1alu30.vargas" (D8:EC:E4:A2:10:55:00:32:30:F2:88:9D:94:E5:41:D6)
    root@master30#
```

> **En caso de no aparecer el certificado en espera*
>
> * Si no aparece el certificado del cliente en la lista de espera del servidor, quizás
el cortafuegos del servidor y/o cliente, está impidiendo el acceso.
> * Volver a reiniciar el servicio en el cliente y comprobar su estado.

* Aceptar al nuevo cliente desde el master `puppet cert sign "nombre-máquina-cliente"`
```
    root@master30# puppet cert sign "cli1alu30.vargas"
    notice: Signed certificate request for cli1alu30.vargas
    notice: Removing file Puppet::SSL::CertificateRequest cli1alu30.vargas at '/var/lib/puppet/ssl/ca/requests/cli1alu30.vargas.pem'

    root@master30# puppet cert list

    root@master30# puppet cert print cli1alu30.vargas
    Certificate:
    Data:
    ....
```

A continuación podemos ver una imagen de ejemplo, los datos no tienen que coincidir con
lo que se pide en el ejercicio.

![opensuse-puppet-cert-list.png](./images/opensuse-puppet-cert-list.png)

##4.2 Comprobación final

* Vamos a cliente1 y reiniciamos la máquina y/o el servicio Puppet.
* Comprobar que los cambios configurados en Puppet se han realizado.
* En caso contrario, ejecutar comando para comprobar errores: 
    * `puppet agent --test`
    * `puppet agent --server master30.vargas --test`
* Para ver el detalle de los errores, podemos reiniciar el servicio puppet en el cliente, y 
consultar el archivo de log del cliente: `tail /var/log/puppet/puppet.log`.
* Puede ser que tengamos algún mensaje de error de configuración del fichero 
`/etc/puppet/manifests/site.pp del master`. En tal caso, ir a los ficheros del master 
y corregir los errores de sintáxis.

> **¿Cómo eliminar certificados?** (*Esto NO HAY QUE HACERLO*)
> 
> Sólo es información, para el caso que tengamos que eliminar los certificados. Cuando tenemos
problemas con los certificados, o los identificadores de las máquinas han cambiado suele ser
buena idea eliminar los certificados y volverlos a generar con la nueva información.
> 
> Si tenemos problemas con los certificados, y queremos eliminar los certificados actuales, podemos hacer lo siguiente:
> * `puppet cert revoke cli1alu30.vargas`: Lo ejecutamos en el master para revocar certificado del cliente.
> * `puppet cert clean  cli1alu30.vargas`: Lo ejecutamos en el master para eliminar ficheros del certificado del cliente.
> *  `rm -rf /var/lib/puppet/ssl`: Lo ejecutamos en el cliente para eliminar los certificados del cliente.
>
> Consultar [URL https://wiki.tegnix.com/wiki/Puppet](https://wiki.tegnix.com/wiki/Puppet), para más información.

#5. Segunda versión del fichero pp

Ya hemos probado una configuración sencilla en PuppetMaster. 
Ahora vamos a pasar a configurar algo más complejo.

* Contenido para `/etc/puppet/manifests/classes/hostlinux2.pp`:

```
class hostlinux2 {
  package { "tree": ensure => installed }
  package { "traceroute": ensure => installed }
  package { "geany": ensure => installed }

  group { "jedy": ensure => "present", }
  group { "admin": ensure => "present", }

  user { 'obi-wan':
    home => '/home/obi-wan',
    shell => '/bin/bash',
    password => 'kenobi',
    groups => ['jedy','admin','root'] 
  }

  file { "/home/obi-wan":
    ensure => "directory",
    owner => "obi-wan",
    group => "jedy",
    mode => 750 
  }

  file { "/home/obi-wan/share":
    ensure => "directory",
    owner => "obi-wan",
    group => "jedy",
    mode => 750 
  }

  file { "/home/obi-wan/share/private":
    ensure => "directory",
    owner => "obi-wan",
    group => "jedy",
    mode => 700 
  }

  file { "/home/obi-wan/share/public":
    ensure => "directory",
    owner => "obi-wan",
    group => "jedy",
    mode => 755 
  }

/*
  package { "gnomine": ensure => purged }
  file {  '/opt/readme.txt' :
    source => 'puppet:///files/readme.txt', 
  }
*/

}
```

> Las órdenes anteriores de configuración de recursos puppet, tienen el significado siguiente:
>
> * **package**: indica paquetes que queremos que estén o no en el sistema.
> * **group**: creación o eliminación de grupos.
> * **user**: Creación o eliminación de usuarios.
> * **file**: directorios o ficheros para crear o descargar desde servidor.

* Modificar `/etc/puppet/manifests/site.pp` con:

```
import "classes/*"

node default {
  include hostlinux2
}
```
> Por defecto todos los nodos (máquinas clientes) van a coger la misma configuración.

#6. Cliente puppet windows

Vamos a configurar Puppet para atender también a clientes Windows.

Enlace de interés: 
* [http://docs.puppetlabs.com/windows/writing.html](http://docs.puppetlabs.com/windows/writing.html)

##6.1 Modificaciones en el Master

* En el master vamos a crear una configuración puppet para las máquinas windows, 
dentro del fichero `/etc/puppet/manifests/classes/hostwindows3.pp`, con el siguiente contenido:

```
class hostwindows3 {
  file {'C:\warning.txt':
    ensure => 'present',
    content => "Hola Mundo Puppet!",
  }
}
```

> De momento, esta configuración es muy básica. Al final la ampliaremos algo más.

* Ahora vamos a modificar el fichero `site.pp` del master, para que tenga en cuenta
la configuración de clientes GNU/Linux y clientes Windows, de la siguiente forma:

```
import "classes/*"

node 'cli1alu30.vargas' {
  include hostlinux2
}

node 'cli2alu30' {
  include hostwindows3
}
```

* Reiniciamos el servicio PuppetMaster.
* Ejecutamos el comando `facter`, para ver la versión de Puppet que está usando el master.

> Debemos instalar la misma versión de puppet en master y en los clientes

> **NOMBRES DE MÁQUINA**
> * El master GNU/Linux del ejemplo se llama `master30.vargas`
> * El cliente1 GNU/Linux del ejemplo se llama `cli1alu30.vargas`
> * El cliente2 Windows del ejemplo se llama `cli2alu30`

##6.2 Modificaciones en el cliente2

* Consultar URL:
    * [http://docs.puppetlabs.com/windows?/installing.html](http://docs.puppetlabs.com/windows?/installing.html)
    * [https://downloads.puppetlabs.com/windows/](https://downloads.puppetlabs.com/windows/)
* Ahora vamos a instalar AgentePuppet en Windows. Recordar que debemos instalar la misma versión en
ambos equipos (Usar comando `facter` para ver la versión de puppet).
* Reiniciamos.
* Debemos aceptar el certificado en el master para este nuevo cliente. Consultar apartado 4.

> Con los comandos siguentes podremos hacernos una idea de como terminar de configurar 
el fichero puppet del master para la máquina Windows.

* Iniciar consola puppet como administrador y probar los comandos: 
    * `puppet agent --server master30.vargas --test`: Comprobar el estado del agente puppet.
    * `puppet agent -t --debug --verbose`: Comprobar el estado del agente puppet.
    * `facter`: Para consultar datos de la máquina windows
    * `puppet resource user nombre-alumno1`: Para ver la configuración puppet del usuario.
    * `puppet resource file c:\Users`: Para var la configuración puppet de la carpeta.

Veamos imagen de ejemplo:

![puppet-resource-windows](./images/puppet-resource-windows.png)

* Configuración en el master del fichero `/etc/puppet/manifests/classes/hostwindows3.pp` 
para el cliente Windows:

```
class hostwindows3 {
  user { 'darth-sidius':
    ensure => 'present',
    groups => ['Administradores']
  }

  user { 'darth-maul':
    ensure => 'present',
    groups => ['Usuarios']
  }
}
```
* Crear un nuevo fichero de configuración para la máquina cliente Windows.
Nombrar el fichero con `/etc/puppet/manifests/classes/hostwindows4.pp`.
Incluir configuraciones elegidas por el alumno.

#7. Entrega

* El trabajo se entregará vía repositorio GitHub del alumno.
* Usaremos la etiqueta `puppet` para la entrega.
