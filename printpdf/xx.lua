#!/usr/bin/lua

require('string')




match_strings = {
    "void Rmi::",
    "Rmi::"
}

S = "void* Rmi::TRmiLink::PollTx(void* link)"


if string.find(S,"void* Rmi::",1,true) == 1 then
    print("good");
else
    print("bad");
end













