require "string"
http = require("socket.http")
local s = http.request("http://192.168.11.200/show_flashregs")
local fd1=io.open('OUT.txt','w')
fd1:write(s)
fd1:close()


