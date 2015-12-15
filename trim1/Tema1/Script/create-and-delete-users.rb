#!/usr/bin/ruby
# encoding: utf-8

#Borrado de la terminal
system ("clear")

#Soy root?
whoami = `whoami`
usuario = whoami.chop

if usuario != 'root'
	puts "Solo el usuario Root puede ejecutar este script"
	exit
end

#array de usuarios
comando = `cat userslist.txt` 
lineadatos = comando.split("\n")

#procesando los usuarios
lineadatos.each do |fila| 

	campos = fila.split(":")
	#si el email es distinto de vacio entra
	if campos[2] != ''
		#añadimos
		if campos[4] == 'add'
			puts "Creamos el usuario #{campos[0]}"	
			`useradd #{campos[0]} `
		end
		#eliminamos
		if campos[4] == 'delete'
			puts "Eliminamos el usuario #{campos[0]}"	
			`deluser #{campos[0]}`
		end
	#si no tiene email	
	else
		puts "ERROR: El usuario #{campos[0]} no tiene email"
	end
end
