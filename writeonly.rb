#!/usr/bin/env ruby

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

#
# Index Address = 0x2A04000
#

bs = 512

print "インデックスデータ書き込み中...\n"
`diskutil unmountDisk #{diskName}`
`sudo dd bs=512 seek=#{(0x2A04000 / bs).to_s} if=#{curDir}/raw/index of=/dev/r#{diskName}`

sleep 5

print "紋紙データ書き込み中...\n"
`diskutil unmountDisk #{diskName}`
`sudo dd bs=512 seek=#{(0x2A24000 / bs).to_s} if=#{curDir}/raw/chunk of=/dev/r#{diskName}`
`diskutil unmountDisk #{diskName}`
