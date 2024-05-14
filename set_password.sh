#!/bin/bash
echo "root:0000" | chpasswd
echo "$USER:0000" | sudo chpasswd
