"use strict";

exports.fromArray = function(xs) {
  return new Float32Array(xs);
};

exports.toArray = function(xs) {
  return Array.prototype.slice.call(floatarr);
};

exports.length = function(float32array) {
  return float32array.length;
};

exports.map = function(float32array) {
  return float32array.map;
};

exports.reduce = function(float32array) {
  return function(cb) {
    return function(initialValue) {
      function uncurriedCb(accumulator, currentValue) {
        return cb(accumulator)(currentValue);
      }
      return float32array.reduce(uncurriedCb, initialValue);
    };
  };
};

exports.subarray = function(float32array) {
  return function(start) {
    return function(end) {
      return float32array.subarray(start, end);
    };
  };
};
