#!/bin/bash
#
# Build Deft JS package with Sencha Cmd
#
# TODO move this to a Grunt task.
#
# Copyright (c) 2012-2013 DeftJS Framework Contributors - http://deftjs.org
# Open source under the MIT License - http://en.wikipedia.org/wiki/MIT_License

cd $TRAVIS_BUILD_DIR/packages/deft && sencha package build