// create the audio context (chrome only for now)
if (! window.AudioContext) {
  if (! window.webkitAudioContext) {
    alert('no audiocontext found');
  }
  window.AudioContext = window.webkitAudioContext;
}

var context = new AudioContext();
var offContext; // declare size once we know how big it should be

var audioBuffer;
var sourceNode;
var analyser;
var javascriptNode;

var hfcArray = [];

// used for color distribution
var hot = new chroma.ColorScale({
  colors:['#000000', '#ff0000', '#ffff00', '#ffffff'],
  positions:[0, .25, .75, 1],
  mode:'rgb',
  limits:[0, 300]
});

// load the sound
loadSound('scale/c1major.wav');

function setupAudio(buffer) {
  offContext = new OfflineAudioContext(
    buffer.numberOfChannels, buffer.length, buffer.sampleRate);
  // setup a javascript node
  javascriptNode = offContext.createScriptProcessor(1024, 1, 1);
  // connect to destination, else it isn't called
  javascriptNode.connect(offContext.destination);
  javascriptNode.onaudioprocess = onAudioProcess;


  // setup a analyzer
  analyser = offContext.createAnalyser();
  analyser.smoothingTimeConstant = 0;
  analyser.fftSize = 512;

  // create a buffer source node
  sourceNode = offContext.createBufferSource();
  sourceNode.connect(analyser);
  analyser.connect(javascriptNode);

  //sourceNode.connect(offContext.destination);
}

function setupViz(buffer) {
  canvas.width = Math.ceil(buffer.length / javascriptNode.bufferSize);
  canvas.height = analyser.frequencyBinCount;
}

// load the specified sound
function loadSound(url) {
  var request = new XMLHttpRequest();
  request.open('GET', url, true);
  request.responseType = 'arraybuffer';

  // When loaded decode the data
  request.onload = function () {
    console.log('loaded');
    // decode the data
    context.decodeAudioData(request.response, function (buffer) {
      // when the audio is decoded play the sound
      console.log('decoded audio data');
      console.info(buffer);
      setupAudio(buffer);
      setupViz(buffer);
      playSound(buffer);
    }, onError);
  }
  request.send();
}


function playSound(buffer) {
  console.log('in playSound');
  sourceNode.buffer = buffer;
  sourceNode.start(0);
  offContext.startRendering().then(function(renderedBuffer) {
    console.log('Rendering completed successfully. Performing HFC.');
    const hfcThreshold = threshold(hfcArray);
    renderGraph(hfcArray, document.getElementById('hfc-canvas'));
    renderGraph(threshold(hfcArray), document.getElementById('threshold-canvas'));
  });
}

// log if an error occurs
function onError(e) {
    console.log(e);
}

// when the javascript node is called
// we use information from the analyzer node
// to draw the volume
function onAudioProcess() {
  // get the average for the first channel
  var array = new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteFrequencyData(array);

  // draw the spectrogram
  drawSpectrogram(array);
  hfcArray.push(getHfc(array));
}

// get the offContext from the canvas to draw on
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var spectIndex = 0;
function drawSpectrogram(array) {
  const height = analyser.frequencyBinCount;
  for (var i = 0; i < array.length; i++) {
    const value = array[i];
    ctx.fillStyle = hot.getColor(value).hex();
    ctx.fillRect(spectIndex, height - i, 1, 1);
  }
  spectIndex = spectIndex + 1;
}

function getHfc(arr) {
  return arr.reduce((accum, v, i) => accum + v * i, 0);
}

// TODO: check param sizes
function threshold(arr, windowSize = 2, d = 0, l = 1) {
  console.log('thresholding');
  console.log(arr);
  const thresholdArr = new Array(arr.length);
  const maxVal = Math.max(...arr);

  for (var i = 0; i < windowSize; i++)
    thresholdArr[i] = maxVal;

  for (var i = windowSize; i < arr.length - windowSize; i++) {
    var val = 0;
    for (var j = i - windowSize; j < i + windowSize; j++)
      val = val + arr[j];
    thresholdArr[i] = d + l * val / (windowSize * 2 + 1);
  }

  for (var i = arr.length - windowSize; i < arr.length; i++)
    thresholdArr[i] = maxVal;

  return thresholdArr;
}

function renderGraph(arr, canvasElem) {
  const canvasCtx = canvasElem.getContext('2d');
  canvasElem.width = arr.length;
  const height = canvasElem.height;
  const maxVal = Math.max(...arr);
  canvasCtx.fillStyle = '#fff';
  for (var i = 0; i < arr.length; i++) {
    const value = Math.round((arr[i] / maxVal) * height);
    canvasCtx.fillRect(i, height - value, 1, 1);
  }
}
