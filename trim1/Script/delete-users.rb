#!/usr/bin/ruby

fichero= `cat userslist.txt`
usuarios= fichero.split("\n")

usuarios.each do |n|
  `deluser #{n}`
end