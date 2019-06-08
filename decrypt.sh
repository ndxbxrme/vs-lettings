#!/bin/bash
openssl aes-256-cbc -d -in env-enc.sh -out env.sh -k $VSLETTINGS_KEY
openssl aes-256-cbc -d -in key-enc.pem -out key.pem -k $VSLETTINGS_KEY
openssl aes-256-cbc -d -in cert-enc.pem -out cert.pem -k $VSLETTINGS_KEY

