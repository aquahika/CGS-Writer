
# Control Byte 
# 0x24 0b 0010 0100  Start
# 0x04 0b 0000 0100  ... 
# 0xC4 0b 1100 0100  EOF

# 0
# b
# X ... EOF         1 = End of File , 0 = Other
# X ... EOD         If EOF = 1, this is also 1
# X ... OTHER REC   1 = Other , 0 = Mongami
# X ... DLT REC     1 = Deleted
# X ... Record Type  
# X ... Record Type 
# X ... Record Type
# X ... Drive Number 

def buildDataBlock(bmp)

  dataBlock = Array.new

  100.times do
  print ' ' 
  end
  print "|100%\n"

  p bmp.length
  for i in 0...(bmp.length) do
    print "¥" if i != 0 && (i % (((bmp.length).to_i)/100)) == 0
    dataRecord = Array.new(11)
    dataRecord.fill(0x00)

    case i
    when 0
      controlByte = 0x24
    when (bmp.length-1)
      controlByte = 0xC4
    else
      controlByte = 0x04
    end

    colorNumber = 0x00
    koshiban    = 0x000000 + i + 1

    renban      = 1
    hiban       = 1

    recordSerialNumber = 0x0000 + i + 1
    hibako      = 1


    dataRecord[0,1] = controlByte
    dataRecord[1,1] = colorNumber

    dataRecord[2,1] = (koshiban >>  0) & 0xFF
    dataRecord[3,1] = (koshiban >>  8) & 0xFF
    dataRecord[4,1] = (koshiban >> 16) & 0xFF

    dataRecord[5,1] = renban
    dataRecord[6,1] = hiban

    dataRecord[7,1] = (recordSerialNumber >> 0) & 0xFF
    dataRecord[8,1] = (recordSerialNumber >> 8) & 0xFF

    dataRecord[9,1] = hibako

    dataRecord += bmp[i].unpack('C*')

    #Calculate Checksum
    cs = 0x00
    dataRecord.each do |byte|
     cs = (cs + byte) & 0xFF 
    end
    cs = 0x100 - cs

    dataRecord.push(cs)

    dataBlock.concat(dataRecord)

    throw "dataBlock size error" if dataRecord.pack('C*').bytesize != 0x400

    dataRecord = nil
  end

  print " \n"

  return dataBlock

end

#require './bmpparser.rb'
#bmp = bmpParse('../bmp/ZENUPDW.bmp')
#p makeDataBlock(bmp)
