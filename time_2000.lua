
require 'string'

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
tmptime      = string.format("    0x%08x,\n", os.difftime(t1,t0))


print('tmptime = ' .. tmptime)


