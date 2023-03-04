
// This takes the results of the fft and distributes them into something we see as more linear.

import processing.sound.*;
import java.time.*;

String fileName = "song.wav";
boolean doTrim = true;

int screenWidth = 1280;
int screenHeight = 1024;
int screenCentre = screenWidth / 2;

float widthScale = 0.8;
int scaledWidth = (int) ((screenWidth / 2) * widthScale); // the maximum width for the bars on each side (left and right.)

int framesPerSecond = 30;
int fftBands = 64;
int displayBands = 8;

int lineHeight = screenHeight / displayBands;
int lineHeightOffset = lineHeight / 2;

double millisPerFrame = 1000 / framesPerSecond;
int numFrames = 0;
int frameNo = 0;
Instant previous = Instant.now();
int samplesPerFrame;

FFT fft;
SoundFile soundFile;
float[] spectrum = new float[fftBands];

int[] reds = new int[displayBands];
int[] blues = new int[displayBands];

void setup() {
  size(1280, 1024);
  background(0);
  strokeWeight(lineHeight/2);
  frameRate(framesPerSecond);

  // set up the colours for the bands.
  double bandSlice = 1.0 / (displayBands-1);
  for (int i = 0; i < displayBands; i++) {
    double proportion = bandSlice * i;
    int portionOf256 = (int) (255.0 * proportion);
    reds[i] = 255 - portionOf256;
    blues[i] = portionOf256;
    //println("portion:", proportion, "portionOf256:", portionOf256, "red: ", reds[i], " blue: ", blues[i]);
  }

  fft = new FFT(this, fftBands);

  soundFile = new SoundFile(this, fileName);
  samplesPerFrame = (int) (soundFile.sampleRate() / framesPerSecond);
  numFrames = (int) Math.ceil(soundFile.frames() / samplesPerFrame);
  double duration = soundFile.frames() / soundFile.sampleRate();
  println("file: ", fileName, "numFrames: ", numFrames, " sound frames: ", soundFile.frames(), " duration: ", duration, "channels: ", soundFile.channels(), " sampleRate: ", soundFile.sampleRate(), " samplesPerFrame: ", samplesPerFrame);
}

void draw() {
  background(0);
  int startSample = frameNo * samplesPerFrame;
  int remainingSamples = soundFile.frames() - startSample;
  int samplesToDo = Math.max(samplesPerFrame, remainingSamples);

  if (samplesToDo > 0) {
    float[] samples = new float[samplesToDo * 2];
    soundFile.read(startSample, samples, 0, samplesToDo);

    float[] left = new float[samplesToDo];
    float[] right = new float[samplesToDo];

    int channelIndex = 0;

    for (int i = 0; i < samples.length; i += 2) {
      left[channelIndex] = samples[i];
      right[channelIndex] = samples[i + 1];
      channelIndex++;
    }

    if (doTrim) {
      left = trimArray(left);
      right = trimArray(right);
    }
    
    float[] leftFft = fft.analyzeSample(left, fftBands);
    float[] rightFft = fft.analyzeSample(right, fftBands);
    
    float[] leftMeta = combine(leftFft);
    float[] rightMeta = combine(rightFft);
    
    for (int i = 0; i < displayBands; i++) {
      int red = reds[i];
      int blue = blues[i];
      stroke(red, 0, blue);
      int y = height - (i*lineHeight + lineHeightOffset);
      int leftX = screenCentre - (int) (leftMeta[i] * scaledWidth);
      int rightX = screenCentre + (int) (rightMeta[i] * scaledWidth);
      line( leftX, y, screenCentre, y );
      line( screenCentre, y, rightX, y );
    }
  }

  saveFrame("data/f-#####.png");
  if (++frameNo >= numFrames) {
    println("We're done.");
    noLoop();
  }
}

float[] combine(float[] src) {
  float[] dest = new float[8];
  
  dest[0] = src[0];
  dest[1] = src[1];
  dest[2] = src[2];
  dest[3] = average(src, 3, 4);
  dest[4] = average(src, 5, 7);
  dest[5] = average(src, 8, 11);
  dest[6] = average(src, 12, 18) * 1.5f;
  dest[7] = average(src, 19, 31) * 2f;
  
  return dest;
}

float average(float[] src, int from, int to) {
  int numElements = to - from + 1;
  float sum = 0.0f;
  
  for (int i = 0; i < numElements; i++) {
    sum += src[from + i];
  }
  
  return (float) sum / numElements;
}

// Given a threshold, find the first and last values in the sample that are less than it, and trim the sample there.
// Then you end up with a sample that more or less starts and ends with something close to zero. This helps reduce the fft noise.
// If the resulting array has the length 8 or less, the original array is returned.

float[] trimArray(float src[]) {
  float threshold = 0.01f;
  int first = 0;
  int last = 0;

  for (int i = 0; i < src.length; i++) {
    if (Math.abs(src[i]) < threshold) {
      first = i;
      break;
    }
  }

  for (int i = src.length - 1; i >= 0; i--) {
    if (Math.abs(src[i]) < threshold) {
      last = i;
      break;
    }
  }
  
  int len = last - first + 1;
  //println(" src ", src.length, " len ", len, " first ", first, " last ", last);
  
  if (len > 8) {
    float[] dest = new float[len];
    for (int i = 0; i < len; i++) {
      dest[i] = src[first + i];
    }
    return dest;
  } else {
     return src;
  }
}
