#!/bin/bash

tar -cvf $1.tar $1
gpg -c --no-symkey-cache --symmetric --cipher-algo AES256 $1.tar
gio trash $1.tar
mv $1.tar.gpg .$1.tar.gpg
