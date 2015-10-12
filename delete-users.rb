#!/usr/bin/ruby
# encoding: utf-8

fichero= `cat userslist.txt`
usuarios= fichero.split("\n")

usuarios.each do |n|
  `deluser #{n}`
end
