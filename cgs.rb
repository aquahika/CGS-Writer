require_relative './bmpparser.rb'
#$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))


require_relative './titleblock.rb'
require_relative './datablock.rb'

def makeCGS(path) 

  filepath = File.expand_path(path)
  filename = File.basename(filepath,'.bmp')

  #p ARGV[0]
  print "入力ファイル\t:\t#{filepath}\n"
  print "紋紙名\t\t:\t#{filename}\n"

  bmp = bmpParse(filepath)

  titleblock = buildTitleBlock(filename:filename,mongamiCount:bmp.length)
  datablock  = buildDataBlock(bmp)




  cgs = Array.new(0x3400)
  cgs.fill(0x00)

  cgs[0,titleblock.length] = titleblock

  cgs += datablock

  p ((cgs.length-0x400) % 0x3400).to_s(16)

  
  #紋紙終了バイト(C4)があるアドレスのシリンダの先頭からのバイト数?をユーザー識別領域にいれる
  cgs[0x28,1] = (((cgs.length-0x400) % 0x3400) >> 8) & 0xFF


  # 全データサイズが0x3400の整数倍になるように0xE5で埋める
  i = 0
  (0x3400 - (cgs.length % 0x3400)).times do 
   cgs.push(0xE5)
   i+=1
  end

  print "ファイルサイズ\t:\t0x#{cgs.length.to_s(16)} byte, 0x#{(cgs.length/0x3400).to_s}シリンダ\n"

  writePath = File.expand_path("../cgs/#{filename}.cgs", __FILE__)
  File.binwrite(writePath,cgs.pack('C*'))

end