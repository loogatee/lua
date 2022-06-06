#!/usr/bin/lua

require('string')

if arg[1] == nil then
    print("\nError: no filename entered")
    print("usage: jpr.lua filename")
    return
end


fd = io.open(arg[1], 'r')
if fd == nil then
    print('\nERROR: opening ' .. arg[1])
    return
end

--
--match_strings = {
--    "uint16_t Crc16(uint16_t crc, const void* buff, uint32_t count)",
--    "uint32_t Crc32(uint32_t crc, const void* buff, uint32_t count)",
--    "uint16_t Checksum16(uint16_t chk, const void* buff, uint32_t count)",
--    "uint8_t Checksum08(uint8_t chk, const void* buff, uint32_t count)",
--}
--T={}
--S = table.concat(T)
--fd = io.open("/home/john.reed/temp/tmptmptmp.tex", 'wb')
--fd:write(S)
--fd:close()


match_strings = {
    "void Rmi::",
    "Rmi::"
}





i     = 0
S     = ""
first = true

repeat

    Fdata = fd:read()
    i = i + 1

    if Fdata ~= nil then

        for j=1,#match_strings do

            if string.find(Fdata,match_strings[j],1,true) ~= nil then
                --print(i)

                if first == true then
                    first = false
                    S = string.format("%d",i)
                else
                    S = string.format("%s,%d",S,i)
                end
            end

        end

    end

--  if Fdata ~= nil then print(Fdata) end


until Fdata == nil



print(S)













