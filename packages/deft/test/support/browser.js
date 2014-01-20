window.global = window;
window.Test = {};
mocha.setup({
	ui: "bdd"
});

chai.should();

global.expect = chai.expect;
global.AssertionError = chai.AssertionError;
global.Assertion = chai.Assertion;
global.assert = chai.assert;