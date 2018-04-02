#!/usr/bin/env bash

tmux new-session -d -s cchttp -c $PWD/control 'python3 -m http.server 2042'
tmux new-session -d -s cclisten -c $PWD/server 'python3 server.py'
