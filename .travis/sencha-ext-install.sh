#!/bin/bash
#
# Install Sencha Ext JS
#
# Copyright (c) 2012-2013 DeftJS Framework Contributors - http://deftjs.org
# Open source under the MIT License - http://en.wikipedia.org/wiki/MIT_License

wget http://cdn.sencha.com/ext/commercial/ext-$SENCHA_EXT_VERSION-commercial.zip
unzip -q ext-$SENCHA_EXT_VERSION-commercial.zip
ln -sv `pwd`/ext-$SENCHA_EXT_VERSION* $TRAVIS_BUILD_DIR/../ext