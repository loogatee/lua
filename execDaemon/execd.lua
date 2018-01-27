

FNAME   = "cmds.lua"
infloop = 1

while infloop == 1 do

    fd = io.open(FNAME, 'r')
    if fd == nil then

        -- print("sleeping 5...")
        os.execute( "sleep 5" )

    else

        cmdfile = fd:read("*all")
        fd:close()
        os.execute( "rm " .. FNAME )


        assert(loadstring(cmdfile))()

    end


end

