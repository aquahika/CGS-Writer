

original = File.binread('../cgs/ZENUPDW.cgs')
newer    = File.binread('./ZENUPDW.cgs')

newer[0x50,(0x3400)-0x50] = original[0x50,(0x3400)-0x50]

File.binwrite('newer.cgs',newer)