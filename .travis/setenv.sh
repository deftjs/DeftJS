#!/bin/bash
#
# Set environment variables.
#
# Copyright (c) 2012-2013 DeftJS Framework Contributors - http://deftjs.org
# Open source under the MIT License - http://en.wikipedia.org/wiki/MIT_License

# Add Sencha Cmd to the path
PATH=~/bin/Sencha/Cmd/$SENCHA_CMD_VERSION/:$PATH

# Add Karma test runner to the path
PATH=~/$TRAVIS_BUILD_DIR/node_modules/karma/bin:$PATH

# Add CoffeeScript compiler to the path
PATH=~/$TRAVIS_BUILD_DIR/node_modules/coffee-script/bin:$PATH

export $PATH