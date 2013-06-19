'use strict';

var adapter = {};

adapter.pending = function () {
	var deferred = Ext.create('Deft.Deferred');
	return {
		promise: deferred.promise,
		fulfill: deferred.resolve,
		reject: deferred.reject
	};
};

adapter.fulfilled = function (value) {
	var deferred = Ext.create('Deft.Deferred');
	deferred.resolve(value);
	return deferred.promise;
};

adapter.rejected = function (value) {
	var deferred = Ext.create('Deft.Deferred');
	deferred.reject(value);
	return deferred.promise;
};

global.adapter = adapter;