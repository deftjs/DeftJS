chai.use(function(chai, utils) {
	var assert = chai.assert;
	var expect = chai.expect;
	var Assertion = chai.Assertion;

	Assertion.addMethod('memberOf', function(array) {
		var value = utils.flag(this, 'object');
		this.assert(Ext.Array.contains(array, value), 'expected #{this} to be a member of ' + utils.inspect(array), 'expected #{this} to not be a member of ' + +utils.inspect(array));
	});

	Assertion.addMethod('membersOf', function(array) {
		var values = utils.flag(this, 'object');
		expect(values).to.be.an.Array;
		this.assert(Ext.Array.filter(values, function(value) {
			return !Ext.Array.contains(array, value);
		}).length === 0, 'expected #{this} to be members of ' + utils.inspect(array), 'expected #{this} to not be members of ' + +utils.inspect(array));
	});

	Assertion.addProperty('unique', function() {
		var values = utils.flag(this, 'object');
		expect(values).to.be.an.instanceOf(Array);
		this.assert(Ext.Array.unique(values).length === values.length, 'expected #{this} to be comprised of unique values', 'expected #{this} not to be comprised of unique values');
	});

	assert.eventuallyThrows = function(error, done, timeout) {
		if (timeout == null) {
			timeout = 50;
		}
		var originalHandler = window.onerror;
		var restored = false;
		window.onerror = function(message) {
			window.onerror = originalHandler;
			restored = true;
			expect(message).to.contain(error.message);
			done();
		};
		setTimeout(function() {
			if (!restored) {
				window.onerror = originalHandler;
				return done(new Error('expected ' + error + ' to be thrown within ' + timeout + 'ms'));
			}
		}, timeout);
	};
});
