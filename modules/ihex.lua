

ihex = {}


--fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
--
--  Debug only.
--      A  -  the Array
--      i  -  index where start of dump occurs
--
--  If you want to display the 16 bytes that begin at 'C' address 0x3000, then parameter 'i' would
--  be 0x3001.   But then purely for display purposes it would display as '03000'.   This is so that
--  users can look at a hex dump in the PIC debugger, and compare that 1-to-1 with a dump produced by
--  this code.  
--
function ihex.dump_line( A, i )
    --                             00      02       04       06       08       0A        0C       0E
    print( string.format("%05X: %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X",
                           i-1,A[i],A[i+1],A[i+2],A[i+3],A[i+4],A[i+5],A[i+6],A[i+7],A[i+8],A[i+9],A[i+10],
                           A[i+11],A[i+12],A[i+13],A[i+14],A[i+15] ))
end


--fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
--
--   Same as above, but does not print out the Address Field ( %05X: )
--
function ihex.dump_line_na( A, i )
    --                         0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
    print( string.format("0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,",
                           A[i],A[i+1],A[i+2],A[i+3],A[i+4],A[i+5],A[i+6],A[i+7],A[i+8],A[i+9],A[i+10],A[i+11],A[i+12],A[i+13],A[i+14],A[i+15] ))
end





--fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
--
--   Takes a line of input from the .hex file, parses it out, and produces 4 output parameters:
--
--              1.    Address where the data starts
--              2.    Record Type.   There are 2 Record Types:
--                          - 0:  Normal Program Data
--                          - 4:  Extended Length Address Record
--              3.    Extended Length Address.   Only valid when Record Type = 4
--              4.    Array of Data Bytes.   Only Valid when Record Type = 0
--
--   Example of Normal Program Data Type:
--
--     :10304000F7CFE4FFF5CFE4FFF3CFE4FFF4CFE4FFE5
--      10 3040 00 F7 CF E4 FF F5 CF E4 FF F3 CF E4 FF F4 CF E4 FF E5
--          - 10        = 16 data bytes
--          - 3040      = starting Address of the Data
--          - 00        = Record Type = 0 = Normal Program Data
--          - F7,...,FF = The data
--          - E5        = Checksum on the data within this line
--
--
--   Example of Extended Length Address Record:
--
--     :020000040001F9
--      02 0000 04 0001 F9
--          - 02    = 2 data bytes
--          - 0000  = Filler, n/a for this record type
--          - 04    = Record Type = 4 = Extended Length Address Record
--          - 0001  = Extended Address = 1
--          - F9    = Checksum on the data within this line
--
--
local function Process_IntelHex( LineOfData )
   local k,bval,s1,Nbytes,Addr,Rtype,T,Ela

   s1     = string.sub( LineOfData, 1, 2 )
   Nbytes = tonumber  ( s1, 16 )

   s1     = string.sub( LineOfData, 3, 6 )
   Addr   = tonumber  ( s1, 16 )

   s1     = string.sub( LineOfData, 7, 8 )
   Rtype  = tonumber  ( s1, 16 )

   T   = {}
   k   = 9
   Ela = 0

   if Rtype == 4 then
      s1  = string.sub( LineOfData, k, k+3 )
      Ela = tonumber  ( s1, 16 )
      return Addr, Rtype, Ela, T
   end

   for i = 1,Nbytes do
      s1      = string.sub( LineOfData, k, k+1 )
      bval    = tonumber  ( s1, 16 )
      k       = k + 2
      T[#T+1] = bval
   end

   return Addr, Rtype, Ela, T
end




function ihex.LoadIntelHex( Fname, KeyEndAddr )
    local i,j,k,fd,hexFile,asciiLine,extended_linear_address
    local Addr, Datatype, ExtendedLA, DataArr, k2, binArray
    local FinalAddr, FinalLen, KeepAddr, KeepLen

    binArray = {}

    for i = 1,131072 do
       binArray[ i ] = 0xFF
    end

    fd = io.open(Fname, 'rb')
    if fd == nil then
        print('ERROR: opening ' .. Fname)
        return nil,nil,nil
    end
    hexFile = fd:read("*all")
    fd:close()


    extended_linear_address = 0

    i,j = string.find(hexFile,':',1)     -- finds the 1st ':'
    i,k = string.find(hexFile,':',j+1)   -- find the 2nd ':'

    repeat

        asciiLine = string.sub(hexFile,j+1,k-2)

        Addr, Datatype, ExtendedLA, DataArr = Process_IntelHex(asciiLine)

        if Datatype == 4 then
            extended_linear_address = 0x10000 * ExtendedLA
        else
            for k2=1,#DataArr do
                binArray[ extended_linear_address + Addr + k2 ] = DataArr[ k2 ]
            end

            if (extended_linear_address + Addr) == KeyEndAddr then
                FinalAddr = KeepAddr
                FinalLen  = KeepLen
            end

            KeepAddr = extended_linear_address + Addr
            KeepLen  = #DataArr
        end

        j   = k
        i,k = string.find(hexFile,':',j+1)

    until i == nil

    return  hexFile,binArray,(FinalAddr+FinalLen)

end


return ihex



