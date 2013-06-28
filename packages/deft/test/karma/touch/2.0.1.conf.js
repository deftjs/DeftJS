// Karma configuration
// Generated on Wed Jun 05 2013 18:35:01 GMT-0400 (EDT)


// base path, that will be used to resolve files and exclude
basePath = '../../..';


// list of files / patterns to load in the browser
files = [
  MOCHA,
  MOCHA_ADAPTER,
  'http://cdn.sencha.io/touch/sencha-touch-2.0.1/sencha-touch-all.js',
  'build/deft-debug.js',

  'test/lib/mocha-as-promised-1.3.0/mocha-as-promised.js',
  'test/lib/chai-1.6.0/chai.js',
  'test/lib/chai-as-promised-3.3.0/chai-as-promised.js',
  'test/lib/sinon-1.6.0/sinon.js',
  'test/lib/sinon-chai-2.4.0/sinon-chai.js',
  'test/lib/sinon-sencha-1.0.0/sinon-sencha.js',

  'test/support/browser.js',
  'test/DeftJS-Promise-adapter.js',

  'test/js/log/Logger.js',
  'test/js/util/Function.js',
  'test/js/ioc/Injector.js',
  'test/js/mixin/Injectable.js',
  'test/js/mixin/Controllable.js',
  'test/js/mvc/ViewController.js',
  'test/lib/promises-aplus-tests-1.3.1/promises-aplus-tests.js',
  'test/js/promise/Promise.js',
  'test/js/promise/Chain.js'
];


// list of files to exclude
exclude = [

];

// preprocessors
preprocessors = {
  'build/deft-debug.js': 'coverage'
};

// test results reporter to use
// possible values: 'dots', 'progress', 'junit'
reporters = ['progress'];

// coverage report options
coverageReporter = {
  type : 'html',
  dir : 'test/coverage/touch/2.0.1'
}

// web server port
port = 9876;


// cli runner port
runnerPort = 9100;


// enable / disable colors in the output (reporters and logs)
colors = true;


// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;


// enable / disable watching file and executing tests whenever any file changes
autoWatch = true;


// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
//browsers = ['Chrome', 'Safari', 'Firefox', 'PhantomJS'];
browsers = ['Chrome'];


// If browser does not capture in given timeout [ms], kill it
captureTimeout = 60000;


// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;
