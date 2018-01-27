#!/usr/bin/lua

require 'string'
bit = require('bit')


function make_VE( Incrc )
local b0,a,b,c,d,A,B

    b0 = string.format('%08X',Incrc)
    a  = bit.lshift(string.byte(b0,1),24)
    b  = bit.lshift(string.byte(b0,2),16)
    c  = bit.lshift(string.byte(b0,3),8)
    d  = string.byte(b0,4)
    A  = bit.bor(a,b,c,d)

    a  = bit.lshift(string.byte(b0,5),24)
    b  = bit.lshift(string.byte(b0,6),16)
    c  = bit.lshift(string.byte(b0,7),8)
    d  = string.byte(b0,8)
    B  = bit.bor(a,b,c,d)

    
    return string.format('%08X%08X',A,B)
end

A = 0x12345678

print( '0x12345678 = ' .. make_VE(A) )









