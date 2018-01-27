
require 'string'
require 'socket.http'
require 'ltn12'



-- Fname = './ConfigData.lua'
--
--
-- fd = io.open(Fname, 'rb')
-- if fd == nil then
--     print('ERROR: opening up' .. Fname)
--     return
-- end


-- S1 = fd:read(100000)
-- fd:close()

S1 = [[ver:"2.0"\n
navId\n
"C-AHU1"\n\n
]]




response_body = {}
t             = {}

t[#t+1] = '-----------------------------41184676334'
t[#t+1] = 'Content-Disposition: form-data; name="theFile"; filename="a4.lua"'
t[#t+1] = 'Content-Type: application/binary'
t[#t+1] = ''
t[#t+1] = S1
t[#t+1] = '-----------------------------41184676334'
t[#t+1] = 'Content-Disposition: form-data; name="theCrc"'
t[#t+1] = ''
t[#t+1] = 'xx'
t[#t+1] = '-----------------------------41184676334'
t[#t+1] = 'Content-Disposition: form-data; name="theDst"'
t[#t+1] = ''
t[#t+1] = '/cflash/ConfigData.lua'
t[#t+1] = '-----------------------------41184676334'
t[#t+1] = 'Content-Disposition: form-data; name="done"'
t[#t+1] = ''
t[#t+1] = 'upload'
t[#t+1] = '-----------------------------41184676334--'
t[#t+1] = ''


request_body = table.concat(t,'\r\n')
rb_len       = string.format("%d",#request_body)

print(request_body)

--[[

print('sending http request....')


socket.http.request
{
    url     = "http://lg.loogatee.com/dopost",
    method  = "POST",
    headers = {
         ["Content-Type"] =  "multipart/form-data; boundary=---------------------------41184676334",
         ["Content-Length"] = rb_len,
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
}
print('Response = ' .. response_body[1])

]]--

