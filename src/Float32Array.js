"use strict";

exports.length = function(float32array) {
  return float32array.length;
};

exports.map = function(float32array) {
  return float32array.map;
};

exports.subarray = function(float32array) {
  return function(start) {
    return function(end) {
      return float32array.subarray(start, end);
    };
  };
};
