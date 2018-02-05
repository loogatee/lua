

require 'socket' 
-- require 'ex'




DiscoverMessage = 'Discovery: Who is out there?'

NETWORKS =
{
--     '255.255.255.255', 
--     '192.168.6.255',
     '192.168.20.255',
}

T={}
T[#T+1] = " "


for I,J in ipairs(NETWORKS) do

  Num_Timeouts = 0
  udp = socket.udp() 
  assert(udp:setoption('broadcast',true)) 
  assert(udp:setoption('dontroute',true)) 
  assert(udp:setsockname('0.0.0.0',30303)) 
  assert(udp:settimeout (1))
  assert(udp:sendto(DiscoverMessage, J, 30303)) 

  while Num_Timeouts < 2 do

    message,host = udp:receivefrom(1024)

    if message == nil then
      Num_Timeouts = Num_Timeouts + 1
    else
      if message ~= DiscoverMessage then
          A={}
          for w in string.gmatch(message,".-%c%c") do
              A[#A+1] = string.sub(w,1,-3)
          end

          T[#T+1] = string.format('%20s     %15s      %20s', host, A[1], A[2])
      end
    end

    -- os.sleep(500,1000)
    os.execute( "sleep 1" )

  end

  T[#T+1] = " "

  local S=table.concat(T,"\r\n")
  -- local fd1=io.open('z2.txt','w')
  -- fd1:write(S)
  -- fd1:close()
  print(S)

  udp:close() 

end



