

DEFAULT_DIRECTORY = "C:\\PerfDataFiles"
DEFAULT_IPADDR    = "192.168.11.115"




require( "iuplua" )
require( "iupluacontrols" )
socket = require 'socket' 
require( "string" )
require( "math"   )
bit = require( "bit" )


--   Windows and Linux Differences:
--      1.  The constants shown below
--      2.  Sleep().   See function os_sleep()
--      3.  method used for launching editor when button is pushed
--                See Show_LogFile_Button() and Log_Button_CB()
--      4.  mkdir().  See create_OutFiles()
--
if package.config:sub(1,1)  == '/' then

    DEFAULT_DIRECTORY = "/tmp/zPerfFiles"
    SYSLOG_PATH       = DEFAULT_DIRECTORY .. "/APerfSysLog.txt"
    FNAME_FMT         = "%s/M%s_%d%02d%02d_%02d%02d%02d.txt"
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
    FNAME_FMT       = "%s\\M%s_%d%02d%02d_%02d%02d%02d.txt"
    GLOBAL_OSTYPE   = 'WINDOWS'

end



--                                          10        20        30        40        50        60
--                                 123456789012345678901234567890123456789012345678901234567890
DIALOG_WIDTH                    = "                                                            "
GLOBAL_STATUS                   = "None                                       "

COLOR_YELLOW                    = 0
COLOR_GRAY                      = 1

MSTATE_CMD_NONE                 = 0
MSTATE_CMD_TEST_CONN1           = 1
MSTATE_CMD_GET_SERIALNUM        = 2
MSTATE_MAKE_PRE_MONITOR_AND_LOG = 3
MSTATE_MAKE_MONITOR_AND_LOG     = 4
MSTATE_DO_TERMINATE_MAKE        = 5
MSTATE_DO_TERMINATE_MELT        = 6

LOOK_NONE                       = 0
LOOK_START_MAKE                 = 1
LOOK_EEV_CONTROL_ACTIVE         = 2
LOOK_MAKE_COMPLETE              = 3


IMG_GREEN = iup.image{
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

IMG_RED = iup.image{
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


IMG_YELLOW = iup.image{
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

IMG_GRAY = iup.image{
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



GLOBALS = {
             main_state          = MSTATE_CMD_NONE,
             color_toggle        = COLOR_GRAY,
             times_no_data       = 0,
             ShowLog_Counter     = 0,
             LogfileFD           = '',
             SyslogFD            = '',
             First_Comms_Has_Run = false,
             First_Comms_Addr    = "",
             dotogg              = false,
             conn                = '',
             mout_count          = 0,
             Fname               = '',
             CR_count            = 0,
             TT                  = {},
             Got_Make_Complete   = false,
             look_for_state      = LOOK_NONE,
             timer1              = iup.timer{ time=1000,  run="NO" },               -- 1000 is 1 second
             terminate_count     = 0,
}




--  parm is in milliseconds.
--  500 = 1/2 second
function os_sleep( parm )
  if GLOBAL_OSTYPE == 'LINUX' then
      local a = string.format('sleep %.1f', parm/1000)
      os.execute(a)
  else
      os.sleep(parm,1000)
  end
end

function ltrim(s)
  return (s:gsub("^%s*", ""))
end

function isdir(path)
        function exists(file)
           local ok, err, code = os.rename(file, file)
           if not ok then
              if code == 13 then return true end
           end
           return ok, err
        end
   return exists(path .. "/")
end

function SysPrint( parm )
    GLOBALS.SyslogFD:write(parm)
    GLOBALS.SyslogFD:flush()
    print(parm)
    io.flush()
end

function do_color_toggle(StatusImage)
  if GLOBALS.dotogg == true then
      GLOBALS.dotogg = false
      if GLOBALS.color_toggle == COLOR_GRAY then                  -- IF current color is Gray
          StatusImage.image    = IMG_YELLOW                       --     Change color to yellow
          GLOBALS.color_toggle = COLOR_YELLOW                     --     update indicator
      else                                                        -- ELSE color will be yellow
          StatusImage.image    = IMG_GRAY                         --     Change color to gray
          GLOBALS.color_toggle = COLOR_GRAY                       --     update indicator
      end
  else
      GLOBALS.dotogg = true
  end
end

function rdshow()
    local T={}; local SS,Status

    while Status ~= 'timeout' do
        SS,Status = GLOBALS.conn:receive(1)
        if SS ~= nil then T[#T+1] = SS end
    end

    if #T >= 1 then
        SS = table.concat(T)
        SysPrint(SS)
    end
end

function rddump()
    local SS,Status
    while Status ~= 'timeout' do SS,Status = GLOBALS.conn:receive(1) end
end


--
--  Send:   <cr><lf><cr>
--  Get:
--          FW_VERSION = git: COOLDATA_80_19
--          Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio (double)
--          > 
--
function FirstComms()
    local SS,Status; local T={}

    os_sleep(500)                                   -- half second
    GLOBALS.conn:send("\n\r\n")                     -- Send <cr><lf><cr> to the CDC board.   It should respond back!
    os_sleep(500)                                   -- half second
    GLOBALS.conn:receive(3)                         -- the first 3 are something to do with the telnet protocol

    while Status ~= 'timeout' do                    -- done when receive returns 'timeout'
        SS,Status = GLOBALS.conn:receive(1)         --    read a single character
        if SS ~= nil then T[#T+1] = SS end          --    if valid char, accumulate it in 'T'
    end

    SS = table.concat(T)                            -- SS makes a string out of 'T'

    if #T > 1 and SS:find('COOLDATA') ~= nil and SS:find('Lua.org,') ~= nil and T[#T-1] == '>' and T[#T] == ' ' then     -- validate the response
        SysPrint(SS)
        GLOBALS.First_Comms_Has_Run = true          -- Global that says 'comms are good'
        return 1                                    -- 'good'
    else
        SysPrint(SS)                                -- might help with debug
        GLOBALS.First_Comms_Has_Run = false         -- Global that says 'comms not yet established'
        return 0                                    -- 'bad'
    end
end


--
--  Surprisingly, timer1.time is typed as a string.
--  That seriously messed me up for awhile!
--
function CMD_Get_SerialNum()
    local SS,Status,a,S1

    GLOBALS.main_state = MSTATE_CMD_NONE

    while Status ~= 'timeout' do                               -- 'timeout' returned when no chars are available
        SS,Status = GLOBALS.conn:receive(1)                    --    reads only 1 char
        if SS ~= nil then GLOBALS.TT[#GLOBALS.TT+1] = SS end   --    accumulates char if valid
    end

    SS = table.concat(GLOBALS.TT)                              -- converts all the individual chars into a string
    a  = string.find(SS,"ZZ")                                  -- finds the echo of the command string sent

    if a ~= nil then                                           -- nil when the echo'ed 'ZZ' is not found
        a = string.find(SS,"ZZ%d%d%d%d%d",a+1)                 -- makes sure the entire 5 digits are there after the 'ZZ'
        if a ~= nil then                                       -- will ne non-nil if found
            S1 = string.sub(SS,a+2,a+6)                        --   Get the 5 digits after the 'ZZ'
            SN_tbox.value = S1                                 --   S/N goes in the TextBox
            SysPrint('Serial Number: ' .. S1 .. '\n')          --   Shows S/N in the monitoring window
        elseif GLOBALS.timer1.time == '500' then               -- will be '500' 1st time through AND did not find the SN yet
            GLOBALS.timer1.time = 1500                         --   give it another 1 + 1/2 seconds
            SysPrint("CMD_Get_SerialNum: (1) \n")              --   indicates we got partial, 
            GLOBALS.main_state = MSTATE_CMD_GET_SERIALNUM      --   so this routine will get called again
            GLOBALS.timer1.run  = "YES"                        --   and will run the timer again
        else
            SN_tbox.value = "xxxxx"                            --   didn't find it.  shows x's in the TextBox
            SysPrint(SS)                                       --   Log and show on screen
        end
    elseif GLOBALS.timer1.time == '500' then                   -- nil returned on 1st try to read data coming back
        GLOBALS.timer1.time = 1500                             --   will try again in 1 + 1/2 seconds
        SysPrint("CMD_Get_SerialNum: (2)\n")                   --   indicates we got partial
        GLOBALS.main_state = MSTATE_CMD_GET_SERIALNUM          --   so this routine will get called again
        GLOBALS.timer1.run  = "YES"                            --   will run the timer
    else
        SN_tbox.value = "xxxxx"                                --   Never got anything back.  bummer
        SysPrint('a' .. SS)                                    --   Log and show on screen
    end
end


function common_CMD_Test_Conn1()
    SysPrint("Trying " .. IP_tbox.value .. " ... ")

    if Close_Then_Connect() == 1 and FirstComms() == 1 then
        img_C.image = IMG_GREEN
        return 1
    else
        img_C.image = IMG_RED
        return 0
    end
end

function CMD_Test_Conn1()
    common_CMD_Test_Conn1()
    GLOBALS.main_state = MSTATE_CMD_NONE
end


function CMD_Make_Pre_Monitor_Log()
    GLOBALS.conn:send("setcvar('AlwaysDisallowMelt','1')\n");  os_sleep(200); rddump()
    GLOBALS.conn:send("setcvar('AlwaysDisallowMake','0')\n");  os_sleep(200); rddump()
    GLOBALS.conn:send("setcvar('SingleMelt',        '0')\n");  os_sleep(200); rddump()
    GLOBALS.conn:send("setcvar('SysProductionMode', '3')\n");  os_sleep(200); rddump()
    GLOBALS.conn:send("setcvar('SingleMake',        '1')\n");  os_sleep(200); rddump()

    GLOBALS.main_state     = MSTATE_MAKE_MONITOR_AND_LOG
    GLOBALS.look_for_state = LOOK_START_MAKE
    GLOBALS.times_no_data  = 0
    GLOBALS.CR_count       = 0
    GLOBALS.TT             = {}
    GLOBALS.timer1.run     = "YES"
end

function CMD_Make_Monitor_Log()
    local SS,Status

    do_color_toggle(img_MakeResult)

    if GLOBALS.ShowLog_Counter == 4 then
        Show_LogFile_Button()
    else
        GLOBALS.ShowLog_Counter = GLOBALS.ShowLog_Counter+1
    end

    while GLOBALS.CR_count < 2 do
        SS,Status = GLOBALS.conn:receive(1)
        if SS ~= nil then
            GLOBALS.TT[#GLOBALS.TT+1] = SS
            if SS:byte() == 13 then GLOBALS.CR_count=GLOBALS.CR_count+1 end
        end
        if Status == 'timeout' then break end
    end

    if #GLOBALS.TT > 1 and GLOBALS.CR_count == 2 then

        GLOBALS.CR_count = 0
        SS               = table.concat(GLOBALS.TT)
        GLOBALS.TT       = {}

        if GLOBALS.look_for_state == LOOK_START_MAKE then
            if SS:find("Start Make") ~= nil then
                GLOBALS.look_for_state = LOOK_EEV_CONTROL_ACTIVE
                lbl_SM.title   =  "Make, Looking for 'EEV control active'"
            end
        elseif GLOBALS.look_for_state == LOOK_EEV_CONTROL_ACTIVE then
            if SS:find("EEV control active") ~= nil then
                GLOBALS.look_for_state = LOOK_MAKE_COMPLETE
                lbl_SM.title   =  "Make, Looking for 'Make complete'"
            end
        elseif GLOBALS.look_for_state == LOOK_MAKE_COMPLETE then                 -- Make is on-going.  Looking for 'Make complete'

            if SS:find("Make complete") ~= nil then                              -- Looking for this in the data stream
                GLOBALS.Got_Make_Complete = true                                 --   so Status Image turns green
                GLOBALS.look_for_state    = LOOK_NONE                            --   done, so not lookin for anything
                lbl_SM.title              = "Make complete"                      --   shown on the Dialog
                GLOBALS.main_state        = MSTATE_DO_TERMINATE_MAKE             --   state machine the terminate function
                GLOBALS.terminate_count   = 0                                    --   state machine uses this to count
                GLOBALS.conn:send("setcvar('SingleMake','0')\n")                 --   Make is OFF
            else                                                                 -- ELSE, make is not yet complete
                if GLOBALS.mout_count == 5 then                                  --   Count so that Screen output is every 5 seconds
                    local n1,n2,S1,S2
                    S1="x";S2="x"                                                --   Init to something/anything
                    n1 = SS:find("SYp="); if n1 ~= nil then                      --   Look for 'SYp' in the data
                        n2 = SS:find("CSp",n1)                                   --      Found 'SYp'.  Now find 'CSp'
                        if n2 ~= nil then S1 = SS:sub(n1+4,n2-2) end             --      Found both SYp and CSp. This extracts SYp value
                    end
                    n1 = SS:find("TWt="); if n1 ~= nil then                      --   Look for 'TWt' in the data
                        n2 = SS:find("CBt",n1)
                        if n2 ~= nil then S2 = SS:sub(n1+4,n2-2) end
                    end
                    lbl_SM.title = string.format("Make, SYp=%s TWt=%s",ltrim(S1),ltrim(S2))
                end
            end

        end

        GLOBALS.LogfileFD:write(SS)
        GLOBALS.LogfileFD:flush()
        if GLOBALS.mout_count == 5 then
            GLOBALS.mout_count = 0
            io.write(SS)
            io.flush()
        else
            GLOBALS.mout_count = GLOBALS.mout_count + 1
        end
        GLOBALS.times_no_data = 0

    else
        GLOBALS.times_no_data = GLOBALS.times_no_data + 1
        if GLOBALS.times_no_data > 100 then
            GLOBALS.times_no_data = 0
            io.write( "zzz 100 Times zzz\n" )
            io.flush()
        end
    end

    GLOBALS.timer1.run = "YES"

end


--
--
--
function CMD_Do_Terminate()

    GLOBALS.terminate_count = GLOBALS.terminate_count + 1

    if GLOBALS.terminate_count == 1 then
        if GLOBALS.main_state == MSTATE_DO_TERMINATE_MAKE then
            GLOBALS.conn:send("setcvar('SingleMelt','0')\n");       os_sleep(200);  rddump()
        else
            GLOBALS.conn:send("setcvar('SingleMake','0')\n");       os_sleep(200);  rddump()
        end
    elseif GLOBALS.terminate_count == 2 then
        GLOBALS.conn:send("setcvar('AlwaysDisallowMelt','1')\n");   os_sleep(200);  rddump()
    elseif GLOBALS.terminate_count == 3 then
        GLOBALS.conn:send("setcvar('AlwaysDisallowMake','1')\n");   os_sleep(200);  rddump()
    end

    if GLOBALS.terminate_count <= 7 then                                  -- this gives it awhile for data to come in
        CMD_Make_Monitor_Log()                                            -- sucks up data, gets the timer going again
    else
        GLOBALS.main_state = MSTATE_CMD_NONE                              -- termination done.  state = idle

        if GLOBALS.Got_Make_Complete == true then                         -- termination due to Make Complete ?
            img_MakeResult.image  = IMG_GREEN                             --     Yes!  Change Status Image to Green
            GLOBALS.Got_Make_Complete = false                             --     re-init the flag
        else
            img_MakeResult.image  = IMG_GRAY                              --     the Gray indicates 'not yet complete'
        end

        GLOBALS.color_toggle = COLOR_GRAY                                 -- So toggle knows what the current state is
        GLOBALS.LogfileFD:close()                                         -- Logfile officially closed
        SysPrint( "------------------   Terminate\n" )                    -- visual indicator both in syslog and screen
        GLOBALS.conn:send("setcvar('SysProductionMode','0')\n");          -- This will turn Off the 1-second data
        os_sleep(200)                                                     -- very short sleep
        rdshow()                                                          -- Suck up all the data
        lbl_SM.title = "Idle"                                             -- Shows 'Idle' on the Dialog
    end
end


--
--
function GLOBALS.timer1:action_cb()

    GLOBALS.timer1.run = "NO"

    if     GLOBALS.main_state == MSTATE_CMD_TEST_CONN1            then   CMD_Test_Conn1()
    elseif GLOBALS.main_state == MSTATE_CMD_GET_SERIALNUM         then   CMD_Get_SerialNum()
    elseif GLOBALS.main_state == MSTATE_MAKE_PRE_MONITOR_AND_LOG  then   CMD_Make_Pre_Monitor_Log()
    elseif GLOBALS.main_state == MSTATE_MAKE_MONITOR_AND_LOG      then   CMD_Make_Monitor_Log()
    elseif GLOBALS.main_state == MSTATE_DO_TERMINATE_MAKE         then   CMD_Do_Terminate()
    elseif GLOBALS.main_state == MSTATE_DO_TERMINATE_MELT         then   CMD_Do_Terminate()
    end

    return iup.DEFAULT
end


--
--       returns 1 if good, 0 if bad
--
function Close_Then_Connect()
    local R,S

    if GLOBALS.First_Comms_Addr ~= "" then                                      -- really have a valid socket to close?
        GLOBALS.conn:close()                                                    --   yeah. standard close
    end

    GLOBALS.First_Comms_Has_Run = false                                         -- 'good' Connection Indicator inits to false
    os_sleep(200)                                                               -- lets not rush into this
    GLOBALS.conn = socket.tcp()                                                 -- Opens up socket. Descriptor in 'GLOBALS.conn'
    R,S = GLOBALS.conn:connect(IP_tbox.value,23)                                -- Connect to the Telnet channel.  Lotta magic here!
    --R,S = GLOBALS.conn:connect(IP_tbox.value,49991)                           -- 49991 is Port Forward on the Riverside router

    if R == nil then                                                            -- if R is nil, that's not good
        SysPrint("Close_Then_Connect: Error with conn:connect: " .. S .. "\n")  --    Show error msg with connect()
        GLOBALS.conn:close()                                                    --    Close socket up
        return 0                                                                --    return Error Code
    else                                                                        -- Good connect!
        GLOBALS.First_Comms_Addr = IP_tbox.value                                --    Keep IP Addr where connect happened
        os_sleep(400)                                                           --    short little 400ms sleep
        GLOBALS.conn:settimeout(0)                                              --    Don't wait on characters.
        return 1                                                                --    return Good
    end
end


function btn_cb_Make(self)
  local T,s1,fname

  SysPrint(os.date() .. ':  btn Make\n')                                               -- Records the btn press

  if GLOBALS.main_state == MSTATE_CMD_NONE then                                        -- NOP unless idle

      if GLOBALS.First_Comms_Has_Run == false or GLOBALS.First_Comms_Addr ~= IP_tbox.value then    -- Connectivity to the board ??
          if common_CMD_Test_Conn1() == 0 then                                                     --    Try to connect
              iup.Message("Socket Error", "ERROR!\n\rconn:connect()")                              --    error message if unsuccessful
              return iup.DEFAULT                                                                   --    No comms. Did not make
          end
      end

      s1 = SN_tbox.value                                                               -- Retrieve/Validate the SerialNumber
      if s1:len() ~= 5 or s1:find('%d%d%d%d%d') == nil then                            -- Looking for 5 numeric digits
          iup.Message("BAD S/N", "ERROR!\n\rS/N is 5 Digits")                          -- Error Message Pops up
          return iup.DEFAULT
      end

      T = os.date("*t",os.time())                                                      -- Assign Filename based on SN
      fname = string.format(FNAME_FMT,DEFAULT_DIRECTORY,SN_tbox.value,T.year,T.month,T.day,T.hour,T.min,T.sec)
      GLOBALS.Fname = fname

      GLOBALS.LogfileFD = io.open(fname, 'w');                                         -- Open up the LogFile for writing
      if GLOBALS.LogfileFD == nil then                                                 -- Test for Error
          iup.Message("file open error", "ERROR opening:\n\r" .. fname)                -- Show Error message
          return iup.DEFAULT                                                           -- due to error, make was not entered
      end

      GLOBALS.main_state      = MSTATE_MAKE_PRE_MONITOR_AND_LOG                        -- This will send the commands
      GLOBALS.timer1.time     = 300                                                    -- timer at 300 milliseconds
      GLOBALS.timer1.run      = "YES"                                                  -- timer1 will run 
      lbl_SM.title            = "Make, Looking for 'Start Make'"                       -- update the Log Msg on the Dialog
      btn_ShowLog.visible     = "NO"                                                   -- Showlog button disappears
      GLOBALS.ShowLog_Counter = 0                                                      -- count for when Showlog Btn appears again

  end

  return iup.DEFAULT
end

function btn_cb_Terminate(self)
    SysPrint(os.date() .. ':  btn Terminate\n')

    if GLOBALS.main_state == MSTATE_MAKE_MONITOR_AND_LOG then            -- Currently in the 'Make' state ?
        GLOBALS.main_state = MSTATE_DO_TERMINATE_MAKE                    --   state machine the terminate function
        GLOBALS.conn:send("setcvar('SingleMake','0')\n")                 --   Stops the Make.  1-sec data still streaming
        GLOBALS.terminate_count = 0                                      --   state machine uses this to count
        lbl_SM.title    = "Terminating..."                               --   updates message on the Dialog
    elseif GLOBALS.main_state == MSTATE_MELT_MONITOR_AND_LOG then        -- Currently in the 'Melt' state ?
        GLOBALS.main_state = MSTATE_DO_TERMINATE_MELT                    --   state machine the terminate function
        GLOBALS.conn:send("setcvar('SingleMelt','0')\n")                 --   Stops the Melt.  1-sec data still streaming
        GLOBALS.terminate_count = 0                                      --   state machine uses this to count
        lbl_SM.title    = "Terminating..."                               --   updates message on the Dialog
    end

    return iup.DEFAULT
end


function btn_cb_TestConnectivity(self)
    SysPrint(os.date() .. ':  btn TestConnectivity\n')

    if GLOBALS.main_state == MSTATE_CMD_NONE then                       -- Gotta be idle for this button to work
        GLOBALS.main_state  = MSTATE_CMD_TEST_CONN1                     -- initialize the state machine 
        img_C.image         = IMG_GRAY                                  -- Status indicator set to gray
        GLOBALS.timer1.time = 100                                       -- timer will run in 100 milliseconds
        GLOBALS.timer1.run  = "YES"                                     -- yep
    end

    return iup.DEFAULT
end


function btn_cb_GetSN(self)
    SysPrint(os.date() .. ':  btn GetSN\n')

    if GLOBALS.main_state == MSTATE_CMD_NONE then                       -- Must be idle for this button to work

        if GLOBALS.First_Comms_Has_Run == false or
                      GLOBALS.First_Comms_Addr ~= IP_tbox.value then    -- Connectivity to the Board?
            if common_CMD_Test_Conn1() == 0 then                        --   Try to Connect
                SN_tbox.value = 'xxxxx'                                 --   No connection.  Show Xs in S/N
                return iup.DEFAULT                                      --   get s/n failed
            end
        end

        GLOBALS.conn:send("Q=PB1_ConfigData.Board_Mac_Address; print(string.format('ZZ%05d',(Q[5]*256)+Q[6]))\n")  -- cmd to retrieve S/N

        GLOBALS.main_state  = MSTATE_CMD_GET_SERIALNUM                  -- state machine initialized to here
        GLOBALS.timer1.time = 500                                       -- timer will run in 500 milliseconds
        GLOBALS.timer1.run  = "YES"                                     -- run the timer
        GLOBALS.TT          = {}                                        -- S/N accumulates in this array
        btn_ShowLog.visible = "NO"                                      -- Makes the 'ShowLog' button go away
    end

    return iup.DEFAULT
end





function Show_LogFile_Button()

    if GLOBAL_OSTYPE == 'WINDOWS' then

local tmps = [[
Set WshShell = CreateObject("WScript.Shell")
Set objFSO   = CreateObject("Scripting.FileSystemObject")
WshShell.Run "%comspec% /c C:\windows\system32\notepad.exe ]] .. GLOBALS.Fname .. [[", 0, true
Set WshShell = Nothing
]]
        os.remove(C9_PATH)
        fd=io.open(C9_PATH, 'w'); fd:write(tmps); fd:close()
    end

    btn_ShowLog.title   = " Show " .. GLOBALS.Fname .. " "
    btn_ShowLog.visible = "YES"                              -- Makes the 'ShowLog' button visible.
end


function Log_Button_CB()
    if GLOBAL_OSTYPE == 'WINDOWS' then
        local e_cmd = "/C start /min " .. C9_PATH             -- Makes full command name
        SHexec(0,"open","cmd.exe",e_cmd,0,0)                  -- executes the VB script, causing the command to run
    else
        os.execute('/usr/bin/gvim ' .. GLOBALS.Fname .. ' &')
    end
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

    GLOBALS.SyslogFD=io.open(SYSLOG_PATH, 'a+');
    SysPrint("\n\n================================ " .. os.date() .. "\n");
end



create_OutFiles()


lbl_0    = iup.label { title = " Directory:  " .. DEFAULT_DIRECTORY, ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_1    = iup.label { title = " IP Addr:    ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_SN   = iup.label { title = " S/N:        ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_2    = iup.label { title = "                    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_4    = iup.label { title = "Performing Scan:    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_SM   = iup.label { title =  GLOBAL_STATUS,                       ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_ST   = iup.label { title = " Status:  ",                         ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }

img_MakeResult = iup.label { image = IMG_GRAY, ALIGNMENT="ARIGHT:ABOTTOM" }
img_C = iup.label { image = IMG_GRAY, ALIGNMENT="ARIGHT:ABOTTOM" }


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

btn_Make = iup.button {
    title         = " Make ",
    action        = btn_cb_Make,
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





GLOBALS.conn = socket.tcp() 




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
                    iup.hbox{lbl_empt05,btn_Make,lbl_empt06,img_MakeResult,lbl_emptM,btn_Terminate},
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





















