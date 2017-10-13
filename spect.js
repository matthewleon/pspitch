// create the audio context (chrome only for now)
if (! window.AudioContext) {
  if (! window.webkitAudioContext) {
    alert('no audiocontext found');
  }
  window.AudioContext = window.webkitAudioContext;
}

var context = new AudioContext();
var offContext; // declare size once we know how big it should be
//var offContext = new OfflineAudioContext(2,44100*20,44100);

var audioBuffer;
var sourceNode;
var analyser;
var javascriptNode;

// used for color distribution
var hot = new chroma.ColorScale({
  colors:['#000000', '#ff0000', '#ffff00', '#ffffff'],
  positions:[0, .25, .75, 1],
  mode:'rgb',
  limits:[0, 300]
});

// load the sound
//setupAudioNodes();
loadSound('scale/c1major.wav');


function setupAudio(buffer) {
  offContext = new OfflineAudioContext(
    buffer.numberOfChannels, buffer.length, buffer.sampleRate);
  // setup a javascript node
  javascriptNode = offContext.createScriptProcessor(2048, 1, 1);
  // connect to destination, else it isn't called
  javascriptNode.connect(offContext.destination);
  javascriptNode.onaudioprocess = onAudioProcess;


  // setup a analyzer
  analyser = offContext.createAnalyser();
  analyser.smoothingTimeConstant = 0;
  analyser.fftSize = 1024;

  // create a buffer source node
  sourceNode = offContext.createBufferSource();
  sourceNode.connect(analyser);
  analyser.connect(javascriptNode);

  //sourceNode.connect(offContext.destination);
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
  });
  //sourceNode.loop = true;
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
  if (sourceNode.playbackState == sourceNode.PLAYING_STATE) {
    drawSpectrogram(array);
  }
}

// get the offContext from the canvas to draw on
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var spectIndex = 0;
function drawSpectrogram(array) {
  // iterate over the elements from the array
  for (var i = 0; i < array.length; i++) {
    // draw each pixel with the specific color
    var value = array[i];
    ctx.fillStyle = hot.getColor(value).hex();
    ctx.fillRect(spectIndex, 512 - i, 1, 1);
  }

  // draw the copied image
  ctx.drawImage(canvas, 0, 0, 800, 512, 0, 0, 800, 512);
  spectIndex = spectIndex + 1;
}
