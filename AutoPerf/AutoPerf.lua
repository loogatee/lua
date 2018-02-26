require( "iuplua" )
require( "iupluacontrols" )
socket = require 'socket' 
require( "string" )
require( "ex"     )
require( "alien"  )
require( "math"   )
bit = require( "bit" )

DEFAULT_DIRECTORY = "C:\\PerfDataFiles"
DEFAULT_IPADDR    = "192.168.11.115"



--                       10        20        30        40        50        60
--              123456789012345678901234567890123456789012345678901234567890
DIALOG_WIDTH = "                                                            "



SYSLOG_PATH = DEFAULT_DIRECTORY .. "\\APerfSysLog.txt"


--
-- How to avoid popup a window when use os.execute in lua:
--     http://stackoverflow.com/questions/18798044/how-to-avoid-popup-a-window-when-use-os-execute-in-lua
--
local shell32 = alien.load('Shell32.dll')
shell32.ShellExecuteA:types("pointer","pointer","pointer","pointer", "pointer","pointer","int")
local SHexec = shell32.ShellExecuteA


C9VB = [[
Set WshShell = CreateObject("WScript.Shell")
Set objFSO   = CreateObject("Scripting.FileSystemObject")
WshShell.Run "%comspec% /c C:\windows\system32\notepad.exe ]] .. SYSLOG_PATH .. [[", 0, true
Set WshShell = Nothing
]]


COLOR_YELLOW   = 0
COLOR_GRAY     = 1

PROGRAM_BEGIN  = 0
PROGRAM_FINISH = 1

RETV_FAIL      = 0
RETV_TIMER     = 1
RETV_SUCCEED   = 2

MSTATE_CMD_NONE           = 0
MSTATE_CMD_TEST_CONN1     = 1
MSTATE_CMD_GET_SERIALNUM  = 2


OUTFILES_PATH = DEFAULT_DIRECTORY .. "\\tmp"
C9_PATH       = OUTFILES_PATH     .. "\\cmd_9.vbs"
CMDOUT_PATH   = OUTFILES_PATH     .. "\\cmd_out.txt"
READY_PATH    = OUTFILES_PATH     .. "\\Ready.txt"

FULL_CMD_LOG     = {}
main_state       = MSTATE_CMD_NONE
begin_finish     = PROGRAM_BEGIN
color_toggle     = COLOR_GRAY
completion_time  = 0

SUCCESS_MSG = " *** Success! *** "
FAIL_MSG    = "   *** FAIL ***   "
BLANK_MSG   = "                  "

First_Comms_Has_Run = false
First_Comms_Addr    = ""

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

    os.sleep(500,1000)
    conn:send("\n\r\n")
    os.sleep(500,1000)       -- half second
    conn:receive(3)

    Status = ''
    T      = {}

    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
        if SS ~= nil then T[#T+1] = SS end
    end

    SS = table.concat(T)

    if #T > 1 and string.find(SS,'COOLDATA') ~= nil and string.find(SS,'Lua.org,') ~= nil and 
                     T[#T-1] == '>' and T[#T] == ' ' then
        SysPrint(SS)
        First_Comms_Has_Run = true
        return 1
    else
        First_Comms_Has_Run = false
        return 0
    end
end



--
--  called from the timer
--
function CMD_Get_SerialNum()
    local SS,Status,T,a,S1

    main_state = MSTATE_CMD_NONE

    Status = ''
    T      = {}

    while Status ~= 'timeout' do
        SS,Status = conn:receive(1)
        if SS ~= nil then T[#T+1] = SS end
    end

    SS = table.concat(T)
    a  = string.find(SS,"ZZ")

    if a ~= nil then
        a = string.find(SS,"ZZ",a+1)
        if a ~= nil then
            S1 = string.sub(SS,a+2,a+6)
            SN_tbox.value = S1
            SysPrint(S1 .. '\n')
        else
            SN_tbox.value = "xxxxx"
            SysPrint(SS)
        end
    else
        SN_tbox.value = "xxxxx"
        SysPrint(SS)
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


--
--
function timer1:action_cb()

    timer1.run = "NO"

    if     main_state == MSTATE_CMD_TEST_CONN1     then   CMD_Test_Conn1()
    elseif main_state == MSTATE_CMD_GET_SERIALNUM  then   CMD_Get_SerialNum()
    end

    return iup.DEFAULT
end


--  'conn' is meant to be a Global
--
--       returns 1 if good, 0 if bad
--
function Close_Then_Connect()
    local R,S

    conn:close()
    First_Comms_Has_Run = false
    os.sleep(200,1000)
    conn = socket.tcp() 
    R,S = conn:connect(IP_tbox.value,23)

    if R == nil then
        SysPrint("Close_Then_Connect: Error with conn:connect: " .. S .. "\n")
        conn:close()
        return 0
    else
        First_Comms_Addr = IP_tbox.value
        os.sleep(400,1000)
        conn:settimeout(0)
        return 1
    end
end


function btn_cb_MakeMelt(self)

    local T = os.date("*t",os.time())
    print(string.format("M%s_%d%02d%02d_%02d%02d%02d",SN_tbox.value,T.year,T.month,T.day,T.hour,T.min,T.sec))
    io.flush()

    return iup.DEFAULT
end



function btn_cb_TestConnectivity(self)
    main_state   = MSTATE_CMD_TEST_CONN1
    img_C.image  = img_gray
    timer1.time  = 100
    timer1.run   = "YES"
    return iup.DEFAULT
end


function btn_cb_GetSN(self)
    if First_Comms_Has_Run == false or First_Comms_Addr ~= IP_tbox.value then
        if do_CMD_Test_Conn1() == 0 then
            SN_tbox.value = 'xxxxx'
            return
        end
    end

    SysPrint("Retrieving Serial Number\n")
    conn:send("Q=PB1_ConfigData.Board_Mac_Address; print(string.format('ZZ%05d',(Q[5]*256)+Q[6]))\n")

    main_state  = MSTATE_CMD_GET_SERIALNUM
    timer1.time = 500
    timer1.run  = "YES"
    return iup.DEFAULT
end



function do_color_toggle(StatusImage)
    if color_toggle == COLOR_GRAY then                          -- IF current color is Gray
        StatusImage.image = img_yellow                          --     Change color to yellow
        color_toggle = COLOR_YELLOW                             --     update indicator
    else                                                        -- ELSE color will be yellow
        StatusImage.image = img_gray                            --     Change color to gray
        color_toggle = COLOR_GRAY                               --     update indicator
    end
end


function Show_LogFile_Button()
    local S = table.concat(FULL_CMD_LOG,'\n')                -- Command Log is kept in this variable: convert to a single string

    os.remove(LOGF_PATH)                                     -- removes file 'logfile.txt', if found
    local fd=io.open(LOGF_PATH, 'w')                         -- creates LogFile
    fd:write(S);                                             -- writes data to the LogFile
    fd:close()                                               -- Closes LogFile

    btn_ShowLog.visible = "YES"                              -- Makes the 'ShowLog' button visible.
end


function Log_Button_CB()
    local e_cmd = "/C start /min " .. C9_PATH             -- Makes full command name
    SHexec(0,"open","cmd.exe",e_cmd,0,0)                  -- executes the VB script, causing the command to run
end



function create_OutFiles()
    local EN,fd,xx,nn

    EN = os.dirent(DEFAULT_DIRECTORY)
    if EN == nil then
        os.mkdir(DEFAULT_DIRECTORY)
    end

    EN = os.dirent(OUTFILES_PATH)
    if EN == nil then
        os.mkdir(OUTFILES_PATH)
    end

    SyslogFD=io.open(SYSLOG_PATH, 'a+');
    SysPrint("\n\n================================ " .. os.date() .. "\n");

    os.remove(C9_PATH)
    fd=io.open(C9_PATH, 'w'); fd:write(C9VB); fd:close()
end



create_OutFiles()


lbl_0    = iup.label { title = " Directory:  " .. DEFAULT_DIRECTORY, ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_1    = iup.label { title = " IP Addr:    ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_SN   = iup.label { title = " S/N:        ",                      ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_2    = iup.label { title = "                    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_4    = iup.label { title = "Performing Scan:    ",               ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }
lbl_PF   = iup.label { title =  BLANK_MSG,                           ALIGNMENT="ALEFT", font = "COURIER_NORMAL_14" }

img_4 = iup.label { image = img_gray, ALIGNMENT="ARIGHT:ABOTTOM" }
img_C = iup.label { image = img_gray, ALIGNMENT="ARIGHT:ABOTTOM" }


btn_TestConny = iup.button {
    title         = " Test Connectivity ",
    action        = btn_cb_TestConnectivity,
    font          = "COURIER_NORMAL_14",
    impressborder = "YES",
}

btn_ShowLog = iup.button {
    title         = " Show Logfile ",
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
    title         = " Make/Melt ",
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
lbl_emptJ  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP",font="COURIER_NORMAL_14" }
lbl_emptK  = iup.label { title = " ",            ALIGNMENT="ARIGHT:ATOP",font="COURIER_NORMAL_14" }
lbl_emptL  = iup.label { title = "    ",         ALIGNMENT="ARIGHT:ATOP",font="COURIER_NORMAL_14" }
lbl_emptF  = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_emptH  = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }
lbl_vers   = iup.label { title = DIALOG_WIDTH,   ALIGNMENT="ARIGHT:ATOP", font="COURIER_NORMAL_14" }

lbl_emptM  = iup.label { title = "                                            ",  ALIGNMENT="ARIGHT:ATOP" }

IP_tbox = iup.text{size="80x",value=DEFAULT_IPADDR,font="COURIER_NORMAL_12",ALIGNMENT="ACENTER"}
SN_tbox = iup.text{size="60x",value="",            font="COURIER_NORMAL_12",ALIGNMENT="ACENTER"}



conn = socket.tcp() 
--assert(conn:connect(DEFAULT_IPADDR,23))
--os.sleep(400,1000)
--conn:settimeout(0)




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
                    iup.hbox{lbl_PF},
                    iup.hbox{lbl_empt6},
                    iup.hbox{lbl_empt7},
                    iup.hbox{lbl_empt8,btn_ShowLog},
                },
            },
        iup.hbox{lbl_empt03},
     },

     iup.hbox{lbl_empt02},

  },
  title = "Bear Performance Testing",
}

dlg:showxy(iup.CENTER, iup.CENTER)

if (iup.MainLoopLevel()==0) then
    iup.MainLoop()
end






















