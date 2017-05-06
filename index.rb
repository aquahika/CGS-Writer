row = Array.new(16)
row.fill(0)

# Validation byte
# 0x00 ... Invalid
# 0x80 ... Valid
# 0x40 ... End of Index

validationByte = 0x80
startCylinder  = 0x0000
endCylinder    = 0x0000
filename       = "ABCDEF" #Less than 10 characters
eof            = 0x00     #Always 0x00


row[0] = validationByte
row[1] = (startCylinder >> 0) & 0xFF
row[2] = (startCylinder >> 8) & 0xFF
row[3] = (endCylinder   >> 8) & 0xFF
row[4] = (endCylinder   >> 8) & 0xFF
row[5,filename.bytesize] = filename.unpack('C*')

p row