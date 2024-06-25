#!/bin/bash

sudo find $1 -type d -exec chmod 755 {} \;
sudo find $1 -type f -exec chmod 644 {} \;
sudo chown -R <%userName%>:<%userName%> $1
