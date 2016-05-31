#!/bin/bash

echo " >> Starting nginx: "
/etc/init.d/nginx start

echo " >> Starting supervisor: "
/etc/init.d/supervisor start