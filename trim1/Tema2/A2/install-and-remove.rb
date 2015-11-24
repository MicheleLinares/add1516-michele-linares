#!/usr/bin/ruby
# encoding: utf-8
#Michele Linares

#Borrado de la terminal
system ("clear")

#Soy root?
whoami = `whoami`
usuario = whoami.chop

if usuario != 'root'
	puts "Solo el usuario Root puede ejecutar este script"
	exit
end

#lectura de fichero
fichero = `cat software-list.txt` 
paquetes = fichero.split("\n")

#procesando el fichero
paquetes.each do |i| 

  campos = i.split(":")
  
  #comprobacion del paquete
  paquete = `zypper search -i | grep "#{campos[0]}"` 

  #Instalamos
  if (campos[1] == 'install' or campos[1] =='i')
    if (paquete == "")  
      puts "Instalando #{campos[0]}"
      `zypper --non-interactive install #{campos[0]}`
    else
      puts "El paquete #{campos[0]} YA está instalado."
    end
	  
  #eliminamos	
  elsif (campos[1] == 'remove' or campos[1] == 'r')
    if (paquete == "")
      puts "El paquete #{campos[0]} NO está instalado, no lo puedo desinstalar."  
    else
      puts "Desinstalando #{campos[0]}"
      `zypper --non-interactive remove #{campos[0]}`
    end	    
  end
end
