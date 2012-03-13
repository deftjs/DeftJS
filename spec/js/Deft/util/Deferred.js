/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/
/*
Jasmine test suite for Deft.util.Deferred
*/
describe('Deft.util.Deferred', function() {
  var createSpecsForThen;
  createSpecsForThen = function(thenFunction) {
    var cancelCallback, deferred, failureCallback, progressCallback, successCallback;
    deferred = null;
    successCallback = failureCallback = progressCallback = cancelCallback = null;
    beforeEach(function() {
      deferred = Ext.create('Deft.util.Deferred');
      successCallback = jasmine.createSpy();
      failureCallback = jasmine.createSpy();
      progressCallback = jasmine.createSpy();
      return cancelCallback = jasmine.createSpy();
    });
    it('should call success callback when resolved', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      expect(successCallback).toHaveBeenCalledWith('expected result');
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should call failure callback when rejected', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).toHaveBeenCalledWith('error message');
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should call progress callback when updated', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.update('progress');
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).toHaveBeenCalledWith('progress');
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should call cancel callback when cancelled', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).toHaveBeenCalledWith('reason');
    });
    it('should allow resolution after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.update('progress');
      deferred.resolve('expected result');
      expect(successCallback).toHaveBeenCalledWith('expected result');
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).toHaveBeenCalledWith('progress');
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should allow rejection after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.update('progress');
      deferred.reject('error message');
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).toHaveBeenCalledWith('error message');
      expect(progressCallback).toHaveBeenCalledWith('progress');
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should allow cancellation after update', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.update('progress');
      deferred.cancel('reason');
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).toHaveBeenCalledWith('progress');
      return expect(cancelCallback).toHaveBeenCalledWith('reason');
    });
    it('should not allow resolution after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      return expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow rejection after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      return expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow update after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      return expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow cancellation after resolution', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.resolve('expected result');
      return expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow resolution after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      return expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow rejection after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      return expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow update after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      return expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow cancellation after rejection', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.reject('error message');
      return expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow resolution after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      return expect(function() {
        return deferred.resolve('expected result');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow rejection after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      return expect(function() {
        return deferred.reject('error message');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow update after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      return expect(function() {
        return deferred.update('progress');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should not allow cancellation after cancellation', function() {
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      deferred.cancel('reason');
      return expect(function() {
        return deferred.cancel('reason');
      }).toThrow(new Error('Error: this Deferred has already been completed and cannot be modified.'));
    });
    it('should immediately call newly success callback when already resolved', function() {
      deferred.resolve('expected result');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(successCallback).toHaveBeenCalledWith('expected result');
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should immediately call newly failure callback when already rejected', function() {
      deferred.reject('error message');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).toHaveBeenCalledWith('error message');
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should immediately call newly added progress callback when already updated', function() {
      deferred.update('progress');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).toHaveBeenCalledWith('progress');
      return expect(cancelCallback).not.toHaveBeenCalled();
    });
    it('should immediately call newly added cancel callback when already cancelled', function() {
      deferred.cancel('reason');
      thenFunction(deferred, successCallback, failureCallback, progressCallback, cancelCallback);
      expect(successCallback).not.toHaveBeenCalled();
      expect(failureCallback).not.toHaveBeenCalled();
      expect(progressCallback).not.toHaveBeenCalled();
      return expect(cancelCallback).toHaveBeenCalledWith('reason');
    });
  };
  describe('then() with callbacks specified via method parameters', function() {
    return createSpecsForThen(function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then(successCallback, failureCallback, progressCallback, cancelCallback);
    });
  });
  describe('then() with callbacks specified via configuration Object', function() {
    return createSpecsForThen(function(deferred, successCallback, failureCallback, progressCallback, cancelCallback) {
      return deferred.then({
        success: successCallback,
        failure: failureCallback,
        progress: progressCallback,
        cancel: cancelCallback
      });
    });
  });
  return describe('always()', function() {
    var alwaysCallback, deferred;
    deferred = null;
    alwaysCallback = null;
    beforeEach(function() {
      deferred = Ext.create('Deft.util.Deferred');
      alwaysCallback = jasmine.createSpy();
      return deferred.always(alwaysCallback);
    });
    it('should call always callback when resolved', function() {
      deferred.resolve('expected value');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should call always callback when rejected', function() {
      deferred.reject('error message');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
    it('should not call always callback when updated', function() {
      deferred.update('progress');
      return expect(alwaysCallback).not.toHaveBeenCalled();
    });
    return it('should call always callback when cancelled', function() {
      deferred.cancel('reason');
      return expect(alwaysCallback).toHaveBeenCalled();
    });
  });
});
