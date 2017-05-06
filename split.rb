require 'pp'

startAddr = 0x2AFA800
endAddr   = 0x2B31C00

bin = File.binread('./empty.img',length=(endAddr - startAddr), offset=startAddr)

filename = String(bin[0,8]).strip!
p filename


File.binwrite("#{filename}.cgs",bin)


