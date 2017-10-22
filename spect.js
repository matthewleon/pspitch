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
    console.log('Rendering completed successfully');
    renderHfc(hfcArray);
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
  // iterate over the elements from the array
  for (var i = 0; i < array.length; i++) {
    // draw each pixel with the specific color
    // TODO: average values so that height is only 256?
    const value = array[i];
    ctx.fillStyle = hot.getColor(value).hex();
    ctx.fillRect(spectIndex, height - i, 1, 1);
  }
  spectIndex = spectIndex + 1;
}

function getHfc(arr) {
  return arr.reduce((accum, v, i) => accum + v * i, 0);
}

function renderHfc(arr) {
  const hfcCanvas = document.getElementById('hfc-canvas');
  const hfcCtx = hfcCanvas.getContext('2d');
  hfcCanvas.width = arr.length;
  const height = hfcCanvas.height;
  const maxVal = Math.max(...arr);
  hfcCtx.fillStyle = '#fff';
  for (var i = 0; i < arr.length; i++) {
    const value = Math.round((arr[i] / maxVal) * height);
    hfcCtx.fillRect(i, height - value, 1, 1);
  }
}
