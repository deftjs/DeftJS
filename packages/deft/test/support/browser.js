window.global = window;
mocha.setup({
   ui : "bdd",
   ignoreLeaks : false
});

chai.should();

global.expect = chai.expect;
global.AssertionError = chai.AssertionError;
global.Assertion = chai.Assertion;
global.assert = chai.assert;