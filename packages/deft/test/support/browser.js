mocha.setup({
	ui: "bdd"
});

chai.should();

window.assert = chai.assert;
window.expect = chai.expect;

// Required for Phantom JS until 2.0 is released - it lacks Function.prototype.bind.
// Adaoted fron Modernizr - https://github.com/Modernizr/Modernizr/blob/master/src/fnBind.js
if (!Function.prototype.bind) {
	var slice = [].slice;
	Function.prototype.bind = function bind(that) {
		var target = this;
		if (typeof target != 'function') {
			throw new TypeError();
		}
		var args = slice.call(arguments, 1);
		var bound = function() {
			if (this instanceof bound) {
				var F = function(){};
				F.prototype = target.prototype;
				var self = new F();
				var result = target.apply(
					self,
					args.concat(slice.call(arguments))
				);
				if (Object(result) === result) {
					return result;
				}
				return self;
			} else {
				return target.apply(
					that,
					args.concat(slice.call(arguments))
				);
			}
		};
		return bound;
	};
}