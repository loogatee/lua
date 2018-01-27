os.execute( "/usr/bin/gnome-terminal --command='telnet 192.168.11.200' &" )
os.execute( "sleep 2" )
os.execute( "ps -ef | grep telnet > OUTPUT.txt" )
