#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby

require 'pp'

titleBlock = File.binread(ARGV[0])

hash = Hash.new

hash["filename"]  = String(titleBlock[0,32]).strip!
hash["userID"]    = String(titleBlock[32,32])
hash["floppyAmount"]  = titleBlock[64]
hash["floppySerial"]  = titleBlock[65]
hash["eofFlag"]       = titleBlock[66]
hash["jacquardType"]       = titleBlock[67].unpack("C*")[0].to_s(2)
hash["bytePerRecord"]       = titleBlock[68]
hash["lastRecordTrackSide"] = titleBlock[69]
hash["lastRecordSector"] =  titleBlock[70]
hash["lastRecordKoshiban"] = "#{titleBlock[71,3]}\000".unpack("V*")[0]
hash["lastRecordRenban"] = titleBlock[74]
hash["lastRecordHiban"] = titleBlock[75]
hash["totalPinCount"] = titleBlock[76,2].unpack("v*")[0]
hash["totalMongamiCount"] = titleBlock[78,4].unpack("V*")[0]

pp hash


#=begin
mongamis = []
for i in 0...hash["totalMongamiCount"] do
  addr = 0x3400 + i*0x400

  break if (addr > titleBlock.length)

  mongami = titleBlock[addr,0x400].unpack("C*")


  cs = 0x00
  for i in 0..0x400-1 do
    cs = (cs + mongami[i]) & 0xFF
  end

#  cs = 0b100000000 - cs







  #p "#{sprintf("0x%06x", addr)} #{sprintf("0b%08b", mongami[0])} #{mongami[0,11]} , cs:#{mongami[0x400-1].to_s} calcCS:#{cs}"
   # break if (mongami[0] & 0b10000000) >> 7 == 0b1
end
#=end
