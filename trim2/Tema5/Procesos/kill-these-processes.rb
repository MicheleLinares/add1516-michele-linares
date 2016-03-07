#!/usr/bin/ruby
# encoding: utf-8
#Michele Linares
require 'rainbow'

def comprobar_root
	#Soy root?
	whoami = `whoami`
	usuario = whoami.chop

	if usuario != 'root'
		puts Rainbow("[ERROR]").color(:red)+" Solo el usuario Root puede ejecutar este script"
		exit 1
	end
end

def controlar_procesos(nombre,accion)

	buscar=`ps -ef|grep #{nombre} |grep -v grep |awk '{print $2}'`
	pid=buscar.split("\n")

	
	if (accion == "kill" or accion == "remove" or accion == "k" or accion == "r")
		
		pid.each do |aux|
		
			if (buscar != "")
			  system("kill -9 #{aux}")
			  puts Rainbow("_KILL_: Proceso #{nombre} eliminado.").color(:red)
			 
			end
		end	
    elsif (accion == "notify" or accion == "n")
		if (buscar != "")
		  puts Rainbow("NOTICE: Proceso #{nombre} en ejecución.").color(:green)
		end
	end	
end

#Borrado de la terminal
system ("clear")

comprobar_root

#lectura de fichero
fichero = `cat processes-black-list.txt` 
proceso = fichero.split("\n")

system("touch state.running")

#procesando el fichero
while (File.exist?"state.running") do
	proceso.each do |i| 

		campos = i.split(":")
		controlar_procesos(campos[0],campos[1])
	end
	
	sleep(5)	
end

