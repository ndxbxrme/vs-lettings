#!/bin/bash
git pull
npm install
npm install -g grunt-cli
bower install
grunt build
#groupadd -r vsagency && useradd -m -r -g vsagency vsagency
su vsagency -c ". env.sh
screen -X -S VSAGENCY quit || true
screen -S VSAGENCY node --expose-gc server/app.js"