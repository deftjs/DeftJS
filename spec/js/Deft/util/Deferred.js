/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/
/*
Jasmine test suite for Deft.util.Deferred
*/
describe('Deft.util.Deferred', function() {
  var createSpecsForThen;
  createSpecsForThen = function(thenFunction, callbacksFactoryFunction) {
    var cancelCallback, deferred, failureCallback, progressCallback, successCallback;
    deferred = null;
    successCallback = failureCallback = progressCallback = cancelCallback = null;
    beforeEach(function() {
      var _ref;
      deferred = Ext.create('Deft.util.Deferred');
      return _ref = callbacksFactoryFunction(), successCallback = _ref.success, failureCallback = _ref.failure, progressCallback = _ref.progress, cancelCallback = _ref.cancel, _ref;
    });
    it('should call success callback when resolved', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      if (successCallback != null) {
        expect(successCallback).toHaveBeenCalledWith('expected result');
      }
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should call failure callback when rejected', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) {
        expect(failureCallback).toHaveBeenCalledWith('error message');
      }
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should call progress callback when updated', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.update('progress');
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).toHaveBeenCalledWith('progress');
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should call cancel callback when cancelled', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).toHaveBeenCalledWith('reason');
      }
    });
    it('should allow resolution after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(function() {
        deferred.update('progress');
        return deferred.resolve('expected result');
      }).not.toThrow();
      if (successCallback != null) {
        expect(successCallback).toHaveBeenCalledWith('expected result');
      }
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).toHaveBeenCalledWith('progress');
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should allow rejection after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(function() {
        deferred.update('progress');
        return deferred.reject('error message');
      }).not.toThrow();
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) {
        expect(failureCallback).toHaveBeenCalledWith('error message');
      }
      if (progressCallback != null) {
        expect(progressCallback).toHaveBeenCalledWith('progress');
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should allow cancellation after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(function() {
        deferred.update('progress');
        return deferred.cancel('reason');
      }).not.toThrow();
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).toHaveBeenCalledWith('progress');
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).toHaveBeenCalledWith('reason');
      }
    });
    it('should not allow resolution after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      if (successCallback != null) successCallback.reset();
      expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow rejection after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      if (successCallback != null) successCallback.reset();
      expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow update after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      if (successCallback != null) successCallback.reset();
      expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow cancellation after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      if (successCallback != null) successCallback.reset();
      expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow resolution after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      if (failureCallback != null) failureCallback.reset();
      expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow rejection after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      if (failureCallback != null) failureCallback.reset();
      expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow update after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      if (failureCallback != null) failureCallback.reset();
      expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow cancellation after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      if (failureCallback != null) failureCallback.reset();
      expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow resolution after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      if (cancelCallback != null) cancelCallback.reset();
      expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow rejection after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      if (cancelCallback != null) cancelCallback.reset();
      expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow update after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      if (cancelCallback != null) cancelCallback.reset();
      expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should not allow cancellation after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      if (cancelCallback != null) cancelCallback.reset();
      expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should immediately call newly added success callback when already resolved', function() {
      deferred.resolve('expected result');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      if (successCallback != null) {
        expect(successCallback).toHaveBeenCalledWith('expected result');
      }
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should immediately call newly added failure callback when already rejected', function() {
      deferred.reject('error message');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) {
        expect(failureCallback).toHaveBeenCalledWith('error message');
      }
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should immediately call newly added progress callback when already updated', function() {
      deferred.update('progress');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).toHaveBeenCalledWith('progress');
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).not.toHaveBeenCalled();
      }
    });
    it('should immediately call newly added cancel callback when already cancelled', function() {
      deferred.cancel('reason');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      if (successCallback != null) expect(successCallback).not.toHaveBeenCalled();
      if (failureCallback != null) expect(failureCallback).not.toHaveBeenCalled();
      if (progressCallback != null) {
        expect(progressCallback).not.toHaveBeenCalled();
      }
      if (cancelCallback != null) {
        return expect(cancelCallback).toHaveBeenCalledWith('reason');
      }
    });
  };
  describe('then() with callbacks specified via method parameters', function() {
    var callbacksFactoryFunction, thenFunction;
    thenFunction = function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then(successCallback, failureCallback, progressCallback, cancelCallback);
    };
    callbacksFactoryFunction = function() {
      return {
        success: jasmine.createSpy(),
        failure: jasmine.createSpy(),
        progress: jasmine.createSpy(),
        cancel: jasmine.createSpy()
      };
    };
    return createSpecsForThen(thenFunction, callbacksFactoryFunction);
  });
  describe('then() with callbacks specified via method parameters, with omitted callbacks', function() {
    var callbackNames, createCallbacksFactoryFunction, index, thenFunction, _results;
    thenFunction = function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then(successCallback, failureCallback, progressCallback, cancelCallback);
    };
    createCallbacksFactoryFunction = function(startIndex, endIndex) {
      var callbacksFactoryFunction;
      callbacksFactoryFunction = function() {
        var callbacks;
        callbacks = {};
        if (index !== 0) callbacks.success = jasmine.createSpy();
        if (index !== 1) callbacks.failure = jasmine.createSpy();
        if (index !== 2) callbacks.progress = jasmine.createSpy();
        if (index !== 3) callbacks.cancel = jasmine.createSpy();
        return callbacks;
      };
      return callbacksFactoryFunction;
    };
    callbackNames = ['success', 'failure', 'progress', 'cancel'];
    _results = [];
    for (index = 0; index <= 3; index++) {
      _results.push(describe("then() with callbacks specified via method parameters, omitting " + callbackNames[index] + " callback.", function() {
        return createSpecsForThen(thenFunction, createCallbacksFactoryFunction(index));
      }));
    }
    return _results;
  });
  describe('then() with callbacks specified via configuration Object', function() {
    var callbacksFactoryFunction, thenFunction;
    thenFunction = function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then({
        success: successCallback,
        failure: failureCallback,
        progress: progressCallback,
        cancel: cancelCallback
      });
    };
    callbacksFactoryFunction = function() {
      return {
        success: jasmine.createSpy(),
        failure: jasmine.createSpy(),
        progress: jasmine.createSpy(),
        cancel: jasmine.createSpy()
      };
    };
    return createSpecsForThen(thenFunction, callbacksFactoryFunction);
  });
  describe('then() with callbacks specified via configuration Object, with omitted callbacks', function() {
    var callbackNames, createCallbacksFactoryFunction, index, thenFunction, _results;
    thenFunction = function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then({
        success: successCallback,
        failure: failureCallback,
        progress: progressCallback,
        cancel: cancelCallback
      });
    };
    createCallbacksFactoryFunction = function(startIndex, endIndex) {
      var callbacksFactoryFunction;
      callbacksFactoryFunction = function() {
        var callbacks;
        callbacks = {};
        if (index !== 0) callbacks.success = jasmine.createSpy();
        if (index !== 1) callbacks.failure = jasmine.createSpy();
        if (index !== 2) callbacks.progress = jasmine.createSpy();
        if (index !== 3) callbacks.cancel = jasmine.createSpy();
        return callbacks;
      };
      return callbacksFactoryFunction;
    };
    callbackNames = ['success', 'failure', 'progress', 'cancel'];
    _results = [];
    for (index = 0; index <= 3; index++) {
      _results.push(describe("then() with callbacks specified via method parameters, omitting " + callbackNames[index] + " callback.", function() {
        return createSpecsForThen(thenFunction, createCallbacksFactoryFunction(index));
      }));
    }
    return _results;
  });
  return describe('always()', function() {
    var alwaysCallback, deferred;
    deferred = null;
    alwaysCallback = null;
    beforeEach(function() {
      deferred = Ext.create('Deft.util.Deferred');
      return alwaysCallback = jasmine.createSpy();
    });
    it('should call always callback when resolved', function() {
      deferred.always(alwaysCallback);
      deferred.resolve('expected value');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should call always callback when rejected', function() {
      deferred.always(alwaysCallback);
      deferred.reject('error message');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should not call always callback when updated', function() {
      deferred.always(alwaysCallback);
      deferred.update('progress');
      return expect(alwaysCallback).not.toHaveBeenCalled();
    });
    it('should call always callback when cancelled', function() {
      deferred.always(alwaysCallback);
      deferred.cancel('reason');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should immediately call always callback when already resolved', function() {
      deferred.resolve('expected value');
      deferred.always(alwaysCallback);
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should immediately call always callback when already rejected', function() {
      deferred.reject('error message');
      deferred.always(alwaysCallback);
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should not immediately call always callback when already updated', function() {
      deferred.update('progress');
      deferred.always(alwaysCallback);
      return expect(alwaysCallback).not.toHaveBeenCalled();
    });
    return it('should immediately call always callback when already cancelled', function() {
      deferred.cancel('reason');
      deferred.always(alwaysCallback);
      return expect(alwaysCallback).toHaveBeenCalled();
    });
  });
});
