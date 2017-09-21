"use strict";

var Pitchfinder = require("pitchfinder");

exports.detectPitchYIN = function (audiodata) {
  return (new Pitchfinder.YIN())(audiodata);
};
