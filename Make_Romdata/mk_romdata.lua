
require "string"
bit = require("bit")
require "ihex"


INPUT_FILENAME = "Bootloader.X.production.hex"
END_ADDR       = "1FFF8"



--mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
--
--    Beginning of Code.   Perform Initialization.
--
--          - Filename is arg1, Ending_Address is arg2
--          - SearchString is the 0x2010 record
--          - Extended Linear Address is set to 0
--          - Lua array to hold all the data is init'ed to all 0xFF's
--
--
Fname                   = INPUT_FILENAME
KeyEndAddr              = tonumber( END_ADDR, 16 )

hFile,bArray,bArrayLen = ihex.LoadIntelHex( Fname, KeyEndAddr )


print(" ")
print(" ")
print("#pragma romdata new_bootloader_data = 0x5000")
print("const rom unsigned char  BLdata[] = {")
print(" ")


--mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
--
--    Calculate the checksum.   Ignore 6 bytes starting at 0x2010 (lua=0x2011)
--    Truncate the checksum to 16-bits.
--
csum = 0
k2   = 1

while k2 <= bArrayLen do
    ihex.dump_line_na( bArray, k2 )
    k2 = k2 + 16
end


print(" ")
print("};")
print(" ")
print("#pragma code")
print(" ")

