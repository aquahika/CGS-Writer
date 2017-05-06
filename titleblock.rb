def buildTitleBlock(filename:"Untitled",mongamiCount:)

titleBlock = Array.new(128)

  #Initialize Array
  titleBlock.fill(0)

  filename     = filename
  floppyAmount = 0x01
  floppySerial = 0x01
  eofFlag      = 0x01
  jacquardType = 0b11101000
  bytePerRecord = 0
  lastRecordTrackSide = 0x17
  lastRecordSector = 0x00
  lastRecordKoshiban = mongamiCount
  lastRecordRenban = 0x01
  lastRecordHiban = 0x01
  totalPinCount  = 8096
  totalMongamiCount = mongamiCount

  titleBlock[0,filename.unpack('C*').length] = filename.unpack('C*')

  #
  # User Defined 
  #

  titleBlock[32,1] = 0x00
  titleBlock[33,1] = 0x04
  titleBlock[34,1] = (mongamiCount >> 0) & 0xFF
  titleBlock[35,1] = (mongamiCount >> 8) & 0xFF
  titleBlock[36,1] = 0x00
  titleBlock[37,1] = 0x00
  titleBlock[38,1] = 0x30
  titleBlock[39,1] = 0x00
  #Hatena ..? End address?
  titleBlock[40,1] = 0x01
  titleBlock[41,1] = 0x01
  titleBlock[42,1] = 0x01



  titleBlock[64,1] = floppyAmount
  titleBlock[65,1] = floppySerial
  titleBlock[66,1] = eofFlag
  titleBlock[67,1] = jacquardType
  titleBlock[68,1] = bytePerRecord

  titleBlock[69,1] = lastRecordTrackSide
  titleBlock[70,1] = lastRecordSector

  titleBlock[71,1] = (lastRecordKoshiban >> 0)  & 0xFF
  titleBlock[72,1] = (lastRecordKoshiban >> 8)  & 0xFF
  titleBlock[73,1] = (lastRecordKoshiban >> 16) & 0xFF

  titleBlock[74,1] = lastRecordRenban
  titleBlock[75,1] = lastRecordHiban

  titleBlock[76,1] = (totalPinCount >> 0)  & 0xFF
  titleBlock[77,1] = (totalPinCount >> 8)  & 0xFF


  titleBlock[78,1] = (totalMongamiCount >> 0)  & 0xFF
  titleBlock[79,1] = (totalMongamiCount >> 8)  & 0xFF
  titleBlock[80,1] = (totalMongamiCount >> 16)  & 0xFF
  titleBlock[81,1] = (totalMongamiCount >> 24) & 0xFF


  throw "wrong parameter" if titleBlock.pack('C*').bytesize != 128

  return titleBlock
end

#p titleBlock(filename:"Hello",mongamiCount:300)




