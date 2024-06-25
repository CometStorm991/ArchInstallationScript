#!/bin/bash

gpg --decrypt .$1.tar.gpg > $1.tar
gpg-connect-agent reloadagent /bye
tar -xvf $1.tar
gio trash $1.tar
