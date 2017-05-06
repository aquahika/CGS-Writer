def bmpParse(path)

  bmp = File.binread(path)

  #Bitmap File Header
  fileheader = Hash.new

  fileheader[:byType]     = bmp[0x0000,2]
  fileheader[:bfSize]     = bmp[0x0002,4].unpack("S*")[0]
  fileheader[:bfOffBits]  = bmp[0x000A,4].unpack("S*")[0]

  #Bitmap InfoHeader
  infoheader = Hash.new
  infoheader[:biSize]     = bmp[0x000E,4].unpack("L<*")[0]
  infoheader[:biWidth]    = bmp[0x0012,4].unpack("l<")[0]
  infoheader[:biHeight]   = bmp[0x0016,4].unpack("l<")[0]
  infoheader[:biPlanes]   = bmp[0x001A,2].unpack("S<")[0]
  infoheader[:biBitCount] = bmp[0x001C,2].unpack("S<")[0]

  infoheader[:biSizeImage]    = bmp[0x0022,4].unpack("S<")[0]
  infoheader[:biXPixPerMeter] = bmp[0x0026,4].unpack("s<")[0]
  infoheader[:biYPixPerMeter] = bmp[0x002A,4].unpack("s<")[0]
  infoheader[:biClrUsed]      = bmp[0x002E,4].unpack("S<")[0]
  infoheader[:biCirImportant] = bmp[0x0032,4].unpack("S*")[0]


  #Error Handle
  throw "This is not Bitmap file"               if fileheader[:byType]     != "BM"
  throw "This is not Bitmap(Windows)"           if infoheader[:biSize]     != 40
  throw "Not Monochrome bitmap"                 if infoheader[:biBitCount] != 1
  throw "Width Error: Supports 8096 pixel only" if infoheader[:biWidth] != 8096


  lines = Array.new
  bytePerLine = infoheader[:biWidth]/8*infoheader[:biBitCount]


  addr = fileheader[:bfOffBits]
  for i in 0...infoheader[:biHeight] do
    lines[i] = bmp[addr,bytePerLine]
    addr += bytePerLine
  end

  return lines

end



