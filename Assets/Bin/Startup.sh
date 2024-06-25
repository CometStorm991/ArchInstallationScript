#!/bin/bash

xrandr --output <%monitorName%> --mode <%resolution%> --rate <%refreshRate%>
sudo Brightness.sh -s 24000
redshift -P -O 4000
EmptyTrash.sh
exit
