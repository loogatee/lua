

DEFAULT_DIRECTORY = "C:\\PerfDataFiles"
DEFAULT_IPADDR    = "192.168.11.115"




require( "iuplua" )
require( "iupluacontrols" )
socket = require 'socket' 
require( "string" )
require( "math"   )
bit = require( "bit" )






if package.config:sub(1,1)  == '/' then

    DEFAULT_DIRECTORY = "/tmp/zPerfFiles"
    SYSLOG_PATH       = DEFAULT_DIRECTORY .. "/APerfSysLog.txt"
    GLOBAL_OSTYPE     = 'LINUX'

else

    require 'ex'
    require 'alien'

    shell32 = alien.load('Shell32.dll')
    shell32.ShellExecuteA:types("pointer","pointer","pointer","pointer", "pointer","pointer","int")
    SHexec = shell32.ShellExecuteA

    SYSLOG_PATH     = DEFAULT_DIRECTORY .. "\\APerfSysLog.txt"
    OUTFILES_PATH   = DEFAULT_DIRECTORY .. "\\tmp"
    C9_PATH         = OUTFILES_PATH     .. "\\cmd_9.vbs"
    GLOBAL_OSTYPE   = 'WINDOWS'

end



--                       10        20        30        40        50        60
--              123456789012345678901234567890123456789012345678901234567890
DIALOG_WIDTH = "                                                            "
logfileFD    = ''


LOOK_NONE               = 0
LOOK_START_MAKE         = 1
LOOK_EEV_CONTROL_ACTIVE = 2
LOOK_MAKE_COMPLETE      = 3

COLOR_YELLOW   = 0
COLOR_GRAY     = 1

PROGRAM_BEGIN  = 0
PROGRAM_FINISH = 1

RETV_FAIL      = 0
RETV_TIMER     = 1
RETV_SUCCEED   = 2

MSTATE_CMD_NONE            = 0
MSTATE_CMD_TEST_CONN1      = 1
MSTATE_CMD_GET_SERIALNUM   = 2
MSTATE_PRE_MONITOR_AND_LOG = 3
MSTATE_MONITOR_AND_LOG     = 4
MSTATE_DO_TERMINATE        = 5



FULL_CMD_LOG     = {}
main_state       = MSTATE_CMD_NONE
begin_finish     = PROGRAM_BEGIN
color_toggle     = COLOR_GRAY
completion_time  = 0

times_no_data = 0
ShowLog_Counter = 0

SUCCESS_MSG = " *** Success! *** "
FAIL_MSG    = "   *** FAIL ***   "
BLANK_MSG   = "                  "

First_Comms_Has_Run = false
First_Comms_Addr    = ""
GLOBAL_fname        = ""
GLOBAL_dt           = 0
GLOBAL_mc           = 0
GLOBAL_Status       = "None                               "
GLOBAL_13           = 0
GLOBAL_T            = {}
Got_Make_Complete   = false
look_for_state      =  LOOK_NONE

timer1 = iup.timer{ time=1000,  run="NO" }               -- 1000 is 1 second





img_green = iup.image{
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },  
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }, 
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 },
  { 10,10,10,10,10,10,10,10,10,10,10,10,10,10 }
  ; colors = { "0 1 0", "255 0 0", "255 255 0" }
}

img_red = iup.image{
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },  
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }, 
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2,2 }
  ; colors = { "0 1 0", "255 0 0", "255 255 0" }
}


img_yellow = iup.image{
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },  
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }, 
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 },
  { 3,3,3,3,3,3,3,3,3,3,3,3,3,3 }
  ; colors = { "0 1 0", "255 0 0", "255 255 0" }
}

img_gray = iup.image{
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },  
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }, 
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 },
  { 8,8,8,8,8,8,8,8,8,8,8,8,8,8 }
  ; colors = { "0 1 0", "255 0 0", "255 255 0" }
}

function os_sleep( parm )
  if GLOBAL_OSTYPE == 'LINUX' then
      local a = string.format('sleep %.1f', parm/1000)
      os.execute(a)
  else
      os.sleep(parm,1000)
  end
end

function SysPrint( parm )
    SyslogFD:write(parm);
    SyslogFD:flush()
    print(parm)
    io.flush()
end

--
--  Send:   <cr><lf><cr>
--  Get:
--          FW_VERSION = git: COOLDATA_80_19
--          Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio (double)
--          > 
--
function FirstComms()
    local SS,Status,T

    os_sleep(500)
    conn:send("\n\r\n")
    os_sleep(500)                 -- half second
    conn:receive(3)

    Status = ''
    T      = {}

    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
        if SS ~= nil then T[#T+1] = SS end
    end

    SS = table.concat(T)

    if #T > 1 and SS:find('COOLDATA') ~= nil and SS:find('Lua.org,') ~= nil and T[#T-1] == '>' and T[#T] == ' ' then
        SysPrint(SS)
        First_Comms_Has_Run = true
        return 1
    else
        First_Comms_Has_Run = false
        return 0
    end
end


--
--  Surprisingly, timer1.time is typed as a string.
--  That seriously messed me up for awhile!
--
function CMD_Get_SerialNum()
    local SS,Status,a,S1

    main_state = MSTATE_CMD_NONE
    Status     = ''

    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
        if SS ~= nil then GLOBAL_T[#GLOBAL_T+1] = SS end
    end

    SS = table.concat(GLOBAL_T)
    a  = string.find(SS,"ZZ")                         -- finds the echo of the command string sent

    if a ~= nil then
        a = string.find(SS,"ZZ%d%d%d%d%d",a+1)        -- makes sure the entire 5 digits is there after the 'ZZ'
        if a ~= nil then
            S1 = string.sub(SS,a+2,a+6)
            SN_tbox.value = S1
            SysPrint(S1 .. '\n')
        elseif timer1.time == '500' then
            timer1.time = 1500 
            SysPrint("CMD_Get_SerialNum: (1) \n")
            main_state = MSTATE_CMD_GET_SERIALNUM
            timer1.run  = "YES"
        else
            SN_tbox.value = "xxxxx"
            SysPrint(SS)
        end
    elseif timer1.time == '500' then
        timer1.time = 1500
        SysPrint("CMD_Get_SerialNum: (2)\n")
        main_state = MSTATE_CMD_GET_SERIALNUM
        timer1.run  = "YES"
    else
        SN_tbox.value = "xxxxx"
        SysPrint('a' .. SS)
    end
end



function do_CMD_Test_Conn1()

    SysPrint("Trying " .. IP_tbox.value .. " ... ")

    if Close_Then_Connect() == 1 and FirstComms() == 1 then
        img_C.image = img_green
        return 1
    end

    img_C.image = img_red
    return 0
end

function CMD_Test_Conn1()
    do_CMD_Test_Conn1()
    main_state = MSTATE_CMD_NONE
end

function ltrim(s)
  return (s:gsub("^%s*", ""))
end

function CMD_Pre_Monitor_Log()
    conn:send("setcvar('AlwaysDisallowMelt','1')\n");  os_sleep(200); rddump()
    conn:send("setcvar('AlwaysDisallowMake','0')\n");  os_sleep(200); rddump()
    conn:send("setcvar('SingleMelt',        '0')\n");  os_sleep(200); rddump()
    conn:send("setcvar('SysProductionMode', '3')\n");  os_sleep(200); rddump()
    conn:send("setcvar('SingleMake',        '1')\n");  os_sleep(200); rddump()

    GLOBAL_13 = 0
    GLOBAL_T  = {}

    main_state     = MSTATE_MONITOR_AND_LOG
    timer1.run     = "YES"
    times_no_data  = 0
    look_for_state =  LOOK_START_MAKE
end

function CMD_Monitor_Log()
    local Status,SS

    ShowLog_Counter = ShowLog_Counter+1
    if ShowLog_Counter == 4 then
        Show_LogFile_Button()
    end

    do_color_toggle(img_4)

    Status = ''

    while GLOBAL_13 < 2 do
        SS,Status = conn:receive(1)
        if SS ~= nil then
            GLOBAL_T[#GLOBAL_T+1] = SS
            if SS:byte() == 13 then GLOBAL_13=GLOBAL_13+1 end
        end
        if Status == 'timeout' then break end
    end

    if #GLOBAL_T > 1 and GLOBAL_13 == 2 then

        GLOBAL_13 = 0
        SS = table.concat(GLOBAL_T)
        GLOBAL_T = {}

        if look_for_state == LOOK_START_MAKE then
            if SS:find("Start Make") ~= nil then
                look_for_state = LOOK_EEV_CONTROL_ACTIVE
                lbl_SM.title   =  "Make, Looking for 'EEV control active'"
            end
        elseif look_for_state == LOOK_EEV_CONTROL_ACTIVE then
            if SS:find("EEV control active") ~= nil then
                look_for_state = LOOK_MAKE_COMPLETE
                lbl_SM.title   =  "Make, Looking for 'Make complete'"
            end
        elseif look_for_state == LOOK_MAKE_COMPLETE then

            if SS:find("Make complete") ~= nil then
                Got_Make_Complete = true
                look_for_state = LOOK_NONE
                lbl_SM.title   = "Make complete"
                main_state = MSTATE_DO_TERMINATE                         -- state machine the terminate function
                conn:send("setcvar('SingleMake','0')\n")
                terminate_count = 0                                      -- state machine uses this to count
            else
                if GLOBAL_mc == 5 then
                local n1,n2,S1,S2

                S1="x";S2="x"

                n1 = SS:find("SYp="); if n1 ~= nil then
                    n2 = SS:find("CSp",n1)
                    if n2 ~= nil then S1 = SS:sub(n1+4,n2-2) end
                end

                n1 = SS:find("TWt="); if n1 ~= nil then
                    n2 = SS:find("CBt",n1)
                    if n2 ~= nil then S2 = SS:sub(n1+4,n2-2) end
                end

                lbl_SM.title = string.format("Make, SYp=%s TWt=%s",ltrim(S1),ltrim(S2))
            end
            end

        end

        logfileFD:write(SS)
        logfileFD:flush()
        if GLOBAL_mc == 5 then
            GLOBAL_mc = 0
        io.write(SS)
        io.flush()
        else
            GLOBAL_mc = GLOBAL_mc + 1
        end
        times_no_data = 0

    else
        times_no_data = times_no_data + 1
        if times_no_data > 100 then
            times_no_data = 0
            io.write( "zzz 100 Times zzz\n" )
            io.flush()
        end
    end

    timer1.run = "YES"

end


--
--
--
function CMD_Do_Terminate()

    terminate_count = terminate_count + 1

    if terminate_count == 1 then
        conn:send("setcvar('SingleMelt','0')\n");           os_sleep(200);  rddump()
    elseif terminate_count == 2 then
        conn:send("setcvar('AlwaysDisallowMelt','1')\n");   os_sleep(200);  rddump()
    elseif terminate_count == 3 then
        conn:send("setcvar('AlwaysDisallowMake','1')\n");   os_sleep(200);  rddump()
    end

    if terminate_count <= 7 then
        CMD_Monitor_Log()
    else
        main_state   = MSTATE_CMD_NONE
        if Got_Make_Complete == true then
            img_4.image  = img_green                                 --     Change color to gray
            Got_Make_Complete = false
        else
        img_4.image  = img_gray                                  --     Change color to gray
        end
        color_toggle = COLOR_GRAY                               --     update indicator
        logfileFD:close()
        SysPrint( "xxxxxxxxxx Terminate\n" )
        conn:send("setcvar('SysProductionMode','0')\n");  os_sleep(200); rdshow()
        lbl_SM.title   = "Idle"
    end
end


--
--
function timer1:action_cb()

    timer1.run = "NO"

    if     main_state == MSTATE_CMD_TEST_CONN1       then   CMD_Test_Conn1()
    elseif main_state == MSTATE_CMD_GET_SERIALNUM    then   CMD_Get_SerialNum()
    elseif main_state == MSTATE_PRE_MONITOR_AND_LOG  then   CMD_Pre_Monitor_Log()
    elseif main_state == MSTATE_MONITOR_AND_LOG      then   CMD_Monitor_Log()
    elseif main_state == MSTATE_DO_TERMINATE         then   CMD_Do_Terminate()
    end

    return iup.DEFAULT
end


--  'conn' is meant to be a Global
--
--       returns 1 if good, 0 if bad
--
function Close_Then_Connect()
    local R,S

    if First_Comms_Addr ~= "" then
        conn:close()
    end

    First_Comms_Has_Run = false
    os_sleep(200)
    conn = socket.tcp() 
    R,S = conn:connect(IP_tbox.value,23)

    if R == nil then
        SysPrint("Close_Then_Connect: Error with conn:connect: " .. S .. "\n")
        conn:close()
        return 0
    else
        First_Comms_Addr = IP_tbox.value
        os_sleep(400)
        conn:settimeout(0)
        return 1
    end
end

function rdshow()
    local Status,T,SS

    Status = ''; T = {}
    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
        if SS ~= nil then T[#T+1] = SS end
    end

    SS = table.concat(T)
    SysPrint(SS)
end

function rddump()
    local Status,SS
    Status = ''
    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
    end
end

function btn_cb_MakeMelt(self)
  local T,s1,fname

  SysPrint(os.date() .. ':  btn MakeMelt\n')

  if main_state == MSTATE_CMD_NONE then                                            -- NOP unless idle

    if First_Comms_Has_Run == false or First_Comms_Addr ~= IP_tbox.value then      -- Assure Connectivity to the board
        if do_CMD_Test_Conn1() == 0 then
            iup.Message("Socket Error", "ERROR!\n\rconn:connect()")
            return iup.DEFAULT
        end
    end

    s1 = SN_tbox.value                                                             -- Retrieve/Validate the SerialNumber
    if s1:len() ~= 5 or s1:find('%d%d%d%d%d') == nil then
        iup.Message("BAD S/N", "ERROR!\n\rS/N is 5 Digits")
        return iup.DEFAULT
    end

    T = os.date("*t",os.time())                                                    -- Assign Filename based on SN
    if GLOBAL_OSTYPE == 'LINUX' then
        fname = string.format("%s/M%s_%d%02d%02d_%02d%02d%02d.txt",DEFAULT_DIRECTORY,SN_tbox.value,T.year,T.month,T.day,T.hour,T.min,T.sec)
    else
        fname = string.format("%s\\M%s_%d%02d%02d_%02d%02d%02d.txt",DEFAULT_DIRECTORY,SN_tbox.value,T.year,T.month,T.day,T.hour,T.min,T.sec)
    end
    GLOBAL_fname = fname

    logfileFD = io.open(fname, 'w');                                               -- Open up the LogFile
    if logfileFD == nil then
        iup.Message("file open error", "ERROR opening:\n\r" .. fname)
        return iup.DEFAULT
    end

    main_state          = MSTATE_PRE_MONITOR_AND_LOG
    timer1.time         = 300                                                      -- timer at 300 milliseconds
    timer1.run          = "YES"                                                    --    and GO!
    lbl_SM.title        = "Make, Looking for 'Start Make'"
    btn_ShowLog.visible = "NO"
    ShowLog_Counter     = 0
  end

  return iup.DEFAULT
end

function btn_cb_Terminate(self)
    SysPrint(os.date() .. ':  btn Terminate\n')

    if main_state == MSTATE_MONITOR_AND_LOG then                 -- only terminate when in this state
        main_state = MSTATE_DO_TERMINATE                         -- state machine the terminate function
        conn:send("setcvar('SingleMake','0')\n")                 -- Terminates the 1-second data
        terminate_count = 0                                      -- state machine uses this to count
        lbl_SM.title   = "Terminating..."
    end

    return iup.DEFAULT
end


function btn_cb_TestConnectivity(self)
  SysPrint(os.date() .. ':  btn TestConnectivity\n')

  if main_state == MSTATE_CMD_NONE then
    main_state   = MSTATE_CMD_TEST_CONN1
    img_C.image  = img_gray
    timer1.time  = 100
    timer1.run   = "YES"
  end

  return iup.DEFAULT
end


function btn_cb_GetSN(self)
  SysPrint(os.date() .. ':  btn GetSN\n')

  if main_state == MSTATE_CMD_NONE then

    if First_Comms_Has_Run == false or First_Comms_Addr ~= IP_tbox.value then
        if do_CMD_Test_Conn1() == 0 then
            SN_tbox.value = 'xxxxx'
            return
        end
    end

    conn:send("Q=PB1_ConfigData.Board_Mac_Address; print(string.format('ZZ%05d',(Q[5]*256)+Q[6]))\n")

    main_state  = MSTATE_CMD_GET_SERIALNUM
    timer1.time = 500                                           
    timer1.run  = "YES"
    GLOBAL_T    = {}

    btn_ShowLog.visible = "NO"                                  -- Makes the 'ShowLog' button visible.
  end

  return iup.DEFAULT
end



function do_color_toggle(StatusImage)
  if GLOBAL_dt == 1 then
    GLOBAL_dt = 0
    if color_toggle == COLOR_GRAY then                          -- IF current color is Gray
        StatusImage.image = img_yellow                          --     Change color to yellow
        color_toggle = COLOR_YELLOW                             --     update indicator
    else                                                        -- ELSE color will be yellow
        StatusImage.image = img_gray                            --     Change color to gray
        color_toggle = COLOR_GRAY                               --     update indicator
    end
  else
    GLOBAL_dt = 1
  end
end


function Show_LogFile_Button()

    if GLOBAL_OSTYPE == 'WINDOWS' then

local tmps = [[
Set WshShell = CreateObject("WScript.Shell")
Set objFSO   = CreateObject("Scripting.FileSystemObject")
WshShell.Run "%comspec% /c C:\windows\system32\notepad.exe ]] .. GLOBAL_fname .. [[", 0, true
Set WshShell = Nothing
]]
        os.remove(C9_PATH)
        fd=io.open(C9_PATH, 'w'); fd:write(tmps); fd:close()
    end

    btn_ShowLog.title   = " Show " .. GLOBAL_fname .. " "
    btn_ShowLog.visible = "YES"                              -- Makes the 'ShowLog' button visible.
end


function Log_Button_CB()
    if GLOBAL_OSTYPE == 'WINDOWS' then
        local e_cmd = "/C start /min " .. C9_PATH             -- Makes full command name
        SHexec(0,"open","cmd.exe",e_cmd,0,0)                  -- executes the VB script, causing the command to run
    else
        os.execute('/usr/bin/gvim ' .. GLOBAL_fname .. ' &')
    end
end

function isdir(path)
        function exists(file)
           local ok, err, code = os.rename(file, file)
           if not ok then
              if code == 13 then return true end
           end
           return ok, err
        end
   return exists(path.."/")
end


function create_OutFiles()

    if isdir(DEFAULT_DIRECTORY) == nil then
        if GLOBAL_OSTYPE == 'WINDOWS' then
            os.mkdir(DEFAULT_DIRECTORY)
        else
            os.execute('mkdir ' .. DEFAULT_DIRECTORY)
        end
    end

    if GLOBAL_OSTYPE == 'WINDOWS' then
        if isdir(OUTFILES_PATH) == nil then
            os.mkdir(OUTFILES_PATH)
        end
    end

    SyslogFD=io.open(SYSLOG_PATH, 'a+');
    SysPrint("\n\n================================ " .. os.date() .. "\n");
end



create_OutFiles()


lbl_0    = iup.label { title = " Directory:  " .. DEFAULT_DIRECTORY, ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_1    = iup.label { title = " IP Addr:    ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_SN   = iup.label { title = " S/N:        ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_2    = iup.label { title = "                    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_4    = iup.label { title = "Performing Scan:    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_SM   = iup.label { title =  GLOBAL_Status,                       ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_ST   = iup.label { title = " Status:  ",                         ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }

img_4 = iup.label { image = img_gray, ALIGNMENT="ARIGHT:ABOTTOM" }
img_C = iup.label { image = img_gray, ALIGNMENT="ARIGHT:ABOTTOM" }


btn_TestConny = iup.button {
    title         = " Test Connectivity ",
    action        = btn_cb_TestConnectivity,
    font          = "COURIER_NORMAL_14",
    impressborder = "YES",
}

btn_ShowLog = iup.button {
    title         = "               Show Logfile                        ",
    action        = Log_Button_CB,
    font          = "COURIER_NORMAL_11",
    impressborder = "YES",
    visible       = "NO",
}

btn_GetSN = iup.button {
    title         = " Get S/N ",
    action        = btn_cb_GetSN,
    font          = "COURIER_NORMAL_14",
    impressborder = "YES",
    visible       = "YES",
}

btn_MakeMelt = iup.button {
    title         = " Make ",
    action        = btn_cb_MakeMelt,
    font          = "COURIER_NORMAL_14",
    impressborder = "YES",
    visible       = "YES",
}

btn_Terminate = iup.button {
    title         = " Terminate ",
    action        = btn_cb_Terminate,
    font          = "COURIER_NORMAL_14",
    impressborder = "YES",
    visible       = "YES",
}

lbl_empt0  = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt00 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt01 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt02 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt03 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt04 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt05 = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_empt06 = iup.label { title = "           ",  ALIGNMENT="ARIGHT:ATOP" }
lbl_empt1  = iup.label { title = "            ", ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_empt2  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_empt3  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP" }
lbl_empt4  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP" }
lbl_empt5  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP" }
lbl_empt6  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP" }
lbl_empt7  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP" }
lbl_empt8  = iup.label { title = "       ",      ALIGNMENT="ARIGHT:ATOP" }
lbl_emptG  = iup.label { title = "          ",   ALIGNMENT="ARIGHT:ATOP" }
lbl_emptI  = iup.label { title = "           ",  ALIGNMENT="ARIGHT:ATOP" }
lbl_emptJ  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptK  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptL  = iup.label { title = "    ",         ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptN  = iup.label { title = "    ",         ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptO  = iup.label { title = "    ",         ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptF  = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptH  = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_vers   = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }

lbl_emptM  = iup.label { title = "                                            ",  ALIGNMENT="ARIGHT:ATOP" }

IP_tbox = iup.text{size="80x",value=DEFAULT_IPADDR,font="COURIER_NORMAL_12",ALIGNMENT="ACENTER"}
SN_tbox = iup.text{size="60x",value="",            font="COURIER_NORMAL_12",ALIGNMENT="ACENTER"}





conn = socket.tcp() 




dlg = iup.dialog {
  iup.hbox {

     iup.hbox{lbl_empt01},

     iup.vbox {
        iup.hbox{lbl_emptG},
            iup.frame {
               iup.vbox {
                   iup.hbox{lbl_emptH},
                   iup.hbox{lbl_0},
                   iup.hbox{lbl_emptJ},
               },
            },
        iup.hbox{lbl_empt00},
            iup.frame {
                iup.vbox {
                    iup.hbox{lbl_emptF},
                    iup.hbox{lbl_1,IP_tbox},
                    iup.hbox{lbl_emptK},
                    iup.hbox{lbl_empt1,btn_TestConny,lbl_emptI,img_C},
                    iup.hbox{lbl_empt2},
                },
            },
        iup.hbox{lbl_empt04},
            iup.frame {
                iup.vbox {
                    iup.hbox{lbl_vers},
                    iup.hbox{lbl_SN,SN_tbox,lbl_emptL,btn_GetSN},
                    iup.hbox{lbl_2},
                    iup.hbox{lbl_empt4},
                    iup.hbox{lbl_empt05,btn_MakeMelt,lbl_empt06,img_4,lbl_emptM,btn_Terminate},
                    iup.hbox{lbl_empt5},
                    iup.hbox{lbl_emptO},
                    iup.hbox{lbl_ST,lbl_SM},
                    iup.hbox{lbl_empt6},
                    iup.hbox{lbl_empt7},
                    iup.hbox{lbl_empt8,btn_ShowLog},
                    iup.hbox{lbl_emptN},
                },
            },
        iup.hbox{lbl_empt03},
     },

     iup.hbox{lbl_empt02},

  },
  title = "Bear Performance Testing   1.01",
}

dlg:showxy(iup.CENTER, iup.CENTER)

if (iup.MainLoopLevel()==0) then
    iup.MainLoop()
end






















