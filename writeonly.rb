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

def unmount(diskName)
  # リトライ回数
  cnt_retry = 0
  begin
    
    result = system("diskutil unmountDisk #{diskName}")
    #result = system("diskutil unmountDisk disk1")
    throw if !result
  rescue
    # カウンタインクリメント
    cnt_retry += 1
    # ４回までリトライする
    print "アンマウント失敗。リトライします。\n"
    sleep 3
    if cnt_retry < 5
      retry
    else
      throw "アンマウントに失敗しました。データは正常に書き込まれていません。"
    end
  end
end



bs = 0x4000

print "\n\nインデックスデータ書き込み準備中...\n"
    
unmount(diskName)
print "アンマウント成功、書き込み開始。[Control-Tで進捗表示]\n"
`sudo dd bs=#{bs.to_s} seek=#{(0x2A04000 / bs).to_s} if=#{curDir}/raw/index of=/dev/r#{diskName}`
print "インデックスデータ書き込み完了\n"



print "\n\n紋紙データ書き込み準備中...\n"
unmount(diskName)
print "アンマウント成功、書き込み開始。[Control-Tで進捗表示]\n"
`sudo dd bs=#{bs.to_s} seek=#{(0x2A24000 / bs).to_s} if=#{curDir}/raw/chunk of=/dev/r#{diskName}`
print "紋紙データ書き込み完了\n\n"
unmount(diskName)


print "正常に終了しました。 ディスクを取り外してください。\n"