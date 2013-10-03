#!/bin/bash
#
# Unpack the unencrypted private-key.json for the Sencha Cmd package repository.
#
# Copyright (c) 2012-2013 DeftJS Framework Contributors - http://deftjs.org
# Open source under the MIT License - http://en.wikipedia.org/wiki/MIT_License

if [ $TRAVIS_SECURE_ENV_VARS ] && [ -z "$private_key_json_{1..31}" ]; then echo '[ERR] No $private_key_json_{1..31} found !' ; exit 1; fi

echo -n $private_key_json_{1..31} >> ~/bin/Sencha/Cmd/repo/.sencha/repo/private-key.json.base64

base64 --decode --ignore-garbage ~/bin/Sencha/Cmd/repo/.sencha/repo/private-key.json.base64 > ~/bin/Sencha/Cmd/repo/.sencha/repo/private-key.json

chmod 644 ~/bin/Sencha/Cmd/repo/.sencha/repo/private-key.json

if [ -e ~/bin/Senha/Cmd/repo/.sencha/repo/private-key.json ]
then
  echo '[INF] $private_key_json_{1..31} unpacked to ~/bin/Senha/Cmd/repo/.sencha/repo/private-key.json'
elif
  echo '[ERR] Unknown error unpacking $private_key_json_{1..31} to ~/bin/Senha/Cmd/repo/.sencha/repo/private-key.json'; exit 1
fi