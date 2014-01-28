// Karma configuration
// Generated on Mon Jan 20 2014 05:41:33 GMT-0500 (EST)

module.exports = function(config) {
	config.set({

		// base path, that will be used to resolve files and exclude
		basePath: '../../..',


		// frameworks to use
		frameworks: ['mocha'],


		// list of files / patterns to load in the browser
		files: [
			'http://cdn.sencha.io/ext-4.0.7-gpl/ext-all.js',
			'build/deft-debug.js',

			'test/lib/chai-1.8.1/chai.js',
			'test/lib/sinon-1.7.3/sinon.js',
			'test/lib/sinon-chai-2.4.0/sinon-chai.js',
			'test/lib/sinon-sencha-1.0.0/sinon-sencha.js',

			'test/support/browser.js',
			'test/support/custom-assertions.js',

			'test/lib/mocha-as-promised-2.0.0/mocha-as-promised.js',
			'test/lib/chai-as-promised-4.1.0/chai-as-promised.js',

			'test/js/custom-assertions.js',

			'test/js/util/Function.js',
			'test/js/log/Logger.js',
			'test/js/ioc/Injector.js',
			'test/js/mixin/Injectable.js',
			'test/js/mixin/Controllable.js',
			'test/js/mvc/ViewController.js',
			'test/lib/promises-aplus-tests-2.0.3/promises-aplus-tests.js',
			'test/js/promise/Promise.js',
			'test/js/promise/Chain.js'
		],


		// list of files to exclude
		exclude: [
		],

		preprocessors: {
			'build/deft-debug.js': ['coverage']
		},

		coverageReporter: {
			type: 'html',
			dir: 'test/coverage/ext/4.0.7'
		},

		// test results reporter to use
		// possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
		reporters: ['dots'],


		// web server port
		port: 9876,


		// enable / disable colors in the output (reporters and logs)
		colors: true,


		// level of logging
		// possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
		logLevel: config.LOG_INFO,


		// enable / disable watching file and executing tests whenever any file changes
		autoWatch: true,


		// Start these browsers, currently available:
		// - Chrome
		// - ChromeCanary
		// - Firefox
		// - Opera (has to be installed with `npm install karma-opera-launcher`)
		// - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
		// - PhantomJS
		// - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
		browsers: ['Chrome'],


		// If browser does not capture in given timeout [ms], kill it
		captureTimeout: 60000,


		// Continuous Integration mode
		// if true, it capture browsers, run tests and exit
		singleRun: false
	});
};
