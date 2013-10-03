#!/bin/bash
#
# Install Sencha Cmd.
#
# Copyright (c) 2012-2013 DeftJS Framework Contributors - http://deftjs.org
# Open source under the MIT License - http://en.wikipedia.org/wiki/MIT_License

wget http://cdn.sencha.com/cmd/$SENCHA_CMD_VERSION/SenchaCmd-$SENCHA_CMD_VERSION-linux-x64.run.zip
unzip -q SenchaCmd-$SENCHA_CMD_VERSION-linux-x64.run.zip
chmod +x SenchaCmd-$SENCHA_CMD_VERSION-linux-x64.run
./SenchaCmd-$SENCHA_CMD_VERSION-linux-x64.run --mode unattended