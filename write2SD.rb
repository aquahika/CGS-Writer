#!/usr/bin/env ruby

require 'fileutils'

#ロードするパスにこのスクリプトがあるディレクトリを追加する
#$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
#$:.unshift File.dirname(__FILE__)

require_relative './cgs.rb'


# 対象のシステムディスクを探す
diskName = `diskUtil list`.split("\n").grep(/PCDOS/)

case diskName.length
  when 0
    throw "対象のディスクが見つかりません"
  when 1
    diskName = diskName[0]
  when 2..Float::INFINITY
    throw "対象のディスクは１枚のみ接続してください"
end


diskName = diskName.match(/disk\d/).to_s

p curDir = File.expand_path(File.dirname(__FILE__))

FileUtils.rm(Dir.glob("#{curDir}/raw/*"))
FileUtils.rm(Dir.glob("#{curDir}/cgs/*"))

bmpList =  Dir.glob("#{curDir}/bmp/*.bmp")

throw "ビットファイルがありません。bmp/ディレクトリにファイルをいれてください" if bmpList.length == 0

bmpList.each do |bmpPath|
  makeCGS(bmpPath)
end




cgsList = Dir.glob("#{curDir}/cgs/*.cgs")


#
#  Make index file
#


index = Array.new()
lastCylinder = 0x00
cgsList.each do |cgsPath|
  indexRow = Array.new(16).fill(0)
  cgsSize = File.size(cgsPath)

  throw "CGS file size error" if cgsSize%0x3400 != 0
  startCylinder = lastCylinder
  lastCylinder  = startCylinder + (cgsSize/0x3400) -1

  #p startCylinder.to_s(16),lastCylinder.to_s(16)

  indexRow[0,1] = 0x80

  #Start Cylinder
  indexRow[1,1] = (startCylinder >> 0) & 0xFF
  indexRow[2,1] = (startCylinder >> 8) & 0xFF

  #End Cylinder
  indexRow[3,1] = (lastCylinder >> 0) & 0xFF
  indexRow[4,1] = (lastCylinder >> 8) & 0xFF

  title = File.binread(cgsPath,10)
  indexRow[5,10] = title.unpack('C*')

  lastCylinder += 1
  index.push(indexRow)
end

# Make Index End
indexRow = Array.new(16).fill(0)
indexRow[0,1] = 0x40

#Start Cylinder
indexRow[1,1] = (lastCylinder >> 0) & 0xFF
indexRow[2,1] = (lastCylinder >> 8) & 0xFF

#End Cylinder
indexRow[3,1] = (0x3A6B >> 0) & 0xFF
indexRow[4,1] = (0x3A6B >> 8) & 0xFF

index.push(indexRow)

index.push(Array.new(0x3400*10 - index.flatten.length).fill(0x00))


File.binwrite("#{curDir}/raw/index",index.flatten.pack('C*'))


#
# Make CGS chunk
#

cgsList.each_with_index do |cgsPath,i|
  p cgsPath
  mongamiCount = File.binread(cgsPath,4,78).unpack('V*')[0]
  startCylinder = (index[i][1] << 0) & 0xFF + (index[i][2] << 8) & 0xFF
  startAddr = 0x2A24000 + 0x3400 * startCylinder
  endAddr   = startAddr + 0x3400 + (mongamiCount-1) * 0x400

  endAddrFixed  = (endAddr - 0x2803E00)/0x200

  endAddrFixedBytes = Array.new(4).fill(0)
  endAddrFixedBytes[0] = (endAddrFixed >>  0) & 0xFF
  endAddrFixedBytes[1] = (endAddrFixed >>  8) & 0xFF
  endAddrFixedBytes[2] = (endAddrFixed >> 16) & 0xFF
  endAddrFixedBytes[3] = (endAddrFixed >> 24) & 0xFF

  p startCylinder,startAddr.to_s(16),endAddr.to_s(16),endAddrFixed.to_s(16),endAddrFixedBytes
  File.binwrite(cgsPath,endAddrFixedBytes.pack('C*'),0x29)

  system("cat #{cgsPath} >> #{curDir}/raw/chunk")
end



#
# Write to SD card
#

#
# Index Address = 0x2A04000
#

bs = 512

print "インデックスデータ書き込み中...\n"
print "パスワードを入力してください\n"
`diskutil unmountDisk #{diskName}`
`sudo dd bs=512 seek=#{(0x2A04000 / bs).to_s} if=#{curDir}/raw/index of=/dev/r#{diskName}`

print "紋紙データ書き込み中...\n"
`diskutil unmountDisk #{diskName}`
`sudo dd bs=512 seek=#{(0x2A24000 / bs).to_s} if=#{curDir}/raw/chunk of=/dev/r#{diskName}`



print "終了しました\n"
