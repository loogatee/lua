local zmq = require "lzmq"



local version = zmq.version()
--print(string.format("zmq version: %d.%d.%d", version[1], version[2], version[3]))

local ctx = zmq.context()

-- local skt = ctx:socket{ zmq.REQ, linger = 0, rcvtimeo = 1000, connect = "ipc:///tmp/zmqfeeds/CmdChannel" }
local skt = ctx:socket{ zmq.REQ, connect = "ipc:///tmp/zmqfeeds/CmdChannel" }


X = "\001\000\164\010"     -- this will do the dloop     0x0100        CDCCMD_DLOOP = 0x0001 
skt:send(X)

SS = skt:recv()

if SS ~= nil then
    print("dloop result: " .. SS)
else
    print("recv returned nil")
end

skt:close()
ctx:destroy()
