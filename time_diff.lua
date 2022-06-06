require 'string'
require 'bit'

-- UTC Time at Jan 1st, 2000   00:00:00
-- 7 hours before midnight
time_0 =
{
    year  = 1999,
    month = 12,
    day   = 31,
    hour  = 17,
    min   = 0,
    sec   = 0,
    wday  = 1,    -- Jan 1st, 2000 happens to fall on a Saturday
    yday  = 365,
    isdst = false,
}


current_time = os.date('*t')
t0           = os.time(time_0)
t1           = os.time(current_time)
tmptime      = string.format("    %d", os.difftime(t1,t0))
print('tmptime = ' .. tmptime)


inputs = {

 { '11/04/2018', '15:13:02', 10022, 6923, 3331 },

 { '11/18/2018', '10:14:12', 10521, 2566, 3332 },


 { '11/28/2018', '09:14:23', 6144,  3849, 3332 },
 { '11/30/2018', '10:14:23', 6149,  4361, 3332 },

 { '12/21/2018', '15:27:30', 9999,  2061, 3333 },

 { '12/27/2018', '16:02:31', 4400,  2832, 3333 },
 { '12/28/2018', '10:14:31', 7474,  3082, 3333 },
 { '12/31/2018', '10:14:31', 7483,  3850, 3333 },
 { '01/01/2019', '10:14:31', 7680,  4106, 3333 },
 { '01/02/2019', '10:14:26', 7482,  4362, 3333 },
 { '01/03/2019', '10:14:31', 7686,  4618, 3333 },
 { '01/04/2019', '10:14:36', 7694,  4874, 3333 },
 { '01/05/2019', '10:14:36', 7697,  5130, 3333 },
 { '01/05/2019', '13:51:52', 1825,  5134, 3333 },

}

function GetTimeX( i1, i2 )
    local mon,day,yr,hr,min,sec

    mon = string.sub(i1,1,2)
    day = string.sub(i1,4,5)
    yr  = string.sub(i1,7,10)

    hr  = string.sub(i2,1,2)
    min = string.sub(i2,4,5)
    sec = string.sub(i2,7,8)

    return yr,mon,day,hr,min,sec
end

function GetUpperLower( iParm )
   local L,U,z

   L = bit.band  (iParm,0xff)
   z = bit.rshift(iParm,8)
   U = bit.band  (z,0xff)

   return U,L
end

function GetTimeComponents( i1,i2,i3 )
    local M,S,D,H,Y,Mo

    M,S  = GetUpperLower(i1)
    D,H  = GetUpperLower(i2)
    Y,Mo = GetUpperLower(i3)

    Mo = Mo+1
    D  = D+1
    Y  = Y+2000

    return M,S,D,H,Y,Mo
end

for i=1,#inputs do

    I = inputs[i]
    mins,secs,day,hour,yr,mon = GetTimeComponents( I[3],I[4],I[5] )
    tmpS = string.format("%s %s    %02d:%02d:%02d   %02d/%02d/%02d",I[1],I[2],hour,mins,secs,mon,day,yr)

    a,b,c,d,e,f = GetTimeX( inputs[i][1], inputs[i][2])

    time_real =
    {
        year  = a,
        month = b,
        day   = c,
        hour  = d,
        min   = e,
        sec   = f,
        isdst = false
    }

    time_from_charger = 
    {
        year  = yr,
        month = mon,
        day   = day,
        hour  = hour,
        min   = mins,
        sec   = secs,
        isdst = false
    }

    t0 = os.time(time_real)
    t1 = os.time(time_from_charger)
    tmptime   = string.format("    %d", os.difftime(t0,t1))
    print(tmpS .. "         " .. tmptime)
    
end















