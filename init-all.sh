#!/bin/bash
git pull
npm install
npm install -g grunt-cli
bower install
grunt build
#groupadd -r vslettings && useradd -m -r -g vslettings vslettings
su vslettings -c ". env.sh
screen -X -S VSLETTINGS quit || true
screen -S VSLETTINGS node --no-warnings --expose-gc server/app.js"
